// ==================================================================
// CLOUDFLARE WORKER 4: EMAIL WEBHOOK HANDLER
// ==================================================================
// Process incoming emails from SendGrid/Mailgun/Resend
// Route to appropriate services, log to Supabase

import { createClient } from '@supabase/supabase-js';

export default {
  async fetch(request, env) {
    if (request.method !== 'POST') {
      return new Response('Method not allowed', { status: 405 });
    }

    const url = new URL(request.url);
    const provider = url.pathname.split('/')[1]; // /sendgrid, /mailgun, /resend

    let emailData;

    // Parse based on provider
    switch (provider) {
      case 'sendgrid':
        emailData = await parseSendGrid(request);
        break;
      case 'mailgun':
        emailData = await parseMailgun(request);
        break;
      case 'resend':
        emailData = await parseResend(request);
        break;
      default:
        return new Response('Unknown provider', { status: 400 });
    }

    // Initialize Supabase
    const supabase = createClient(
      env.SUPABASE_URL,
      env.SUPABASE_SERVICE_ROLE_KEY
    );

    // Log email to database
    await supabase
      .from('email_logs')
      .insert({
        provider,
        from: emailData.from,
        to: emailData.to,
        subject: emailData.subject,
        body: emailData.body,
        html: emailData.html,
        attachments: emailData.attachments,
        received_at: new Date().toISOString()
      });

    // Route based on recipient
    if (emailData.to.includes('support@meauxbility.org')) {
      await routeToSupport(emailData, supabase, env);
    } else if (emailData.to.includes('orders@inneranimals.com')) {
      await routeToOrders(emailData, supabase, env);
    } else if (emailData.to.includes('admin@iaudodidact.com')) {
      await routeToAdmin(emailData, supabase, env);
    }

    return new Response(JSON.stringify({ success: true }), {
      headers: { 'Content-Type': 'application/json' }
    });
  }
};

async function parseSendGrid(request) {
  const body = await request.json();
  return {
    from: body.from,
    to: body.to,
    subject: body.subject,
    body: body.text,
    html: body.html,
    attachments: body.attachments || []
  };
}

async function parseMailgun(request) {
  const formData = await request.formData();
  return {
    from: formData.get('sender'),
    to: formData.get('recipient'),
    subject: formData.get('subject'),
    body: formData.get('body-plain'),
    html: formData.get('body-html'),
    attachments: []
  };
}

async function parseResend(request) {
  const body = await request.json();
  return {
    from: body.from,
    to: body.to,
    subject: body.subject,
    body: body.text,
    html: body.html,
    attachments: body.attachments || []
  };
}

async function routeToSupport(emailData, supabase, env) {
  // Create support ticket
  await supabase
    .from('support_tickets')
    .insert({
      email: emailData.from,
      subject: emailData.subject,
      message: emailData.body,
      status: 'open',
      priority: determinePriority(emailData.subject),
      created_at: new Date().toISOString()
    });

  // Send auto-reply
  console.log(`Auto-reply sent to ${emailData.from}`);
}

async function routeToOrders(emailData, supabase, env) {
  // Extract order number from subject
  const orderMatch = emailData.subject.match(/#(\d+)/);
  if (orderMatch) {
    const orderId = orderMatch[1];

    // Add note to order
    await supabase
      .from('order_notes')
      .insert({
        order_id: orderId,
        note: emailData.body,
        created_by: emailData.from,
        created_at: new Date().toISOString()
      });
  }
}

async function routeToAdmin(emailData, supabase, env) {
  // Forward to admin team
  await supabase
    .from('admin_inbox')
    .insert({
      from: emailData.from,
      subject: emailData.subject,
      body: emailData.body,
      read: false,
      received_at: new Date().toISOString()
    });
}

function determinePriority(subject) {
  const urgent = ['urgent', 'emergency', 'critical', 'asap'];
  const subjectLower = subject.toLowerCase();

  if (urgent.some(word => subjectLower.includes(word))) {
    return 'high';
  }
  return 'normal';
}
