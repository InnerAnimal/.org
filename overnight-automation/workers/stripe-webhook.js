// ==================================================================
// CLOUDFLARE WORKER 3: STRIPE WEBHOOK HANDLER
// ==================================================================
// Process all Stripe events, update Supabase, send emails

import { createClient } from '@supabase/supabase-js';

export default {
  async fetch(request, env) {
    if (request.method !== 'POST') {
      return new Response('Method not allowed', { status: 405 });
    }

    // Verify Stripe signature
    const signature = request.headers.get('stripe-signature');
    const body = await request.text();

    // TODO: Verify webhook signature with crypto
    // const event = stripe.webhooks.constructEvent(body, signature, env.STRIPE_WEBHOOK_SECRET);

    const event = JSON.parse(body);

    // Initialize Supabase client
    const supabase = createClient(
      env.SUPABASE_URL,
      env.SUPABASE_SERVICE_ROLE_KEY
    );

    // Handle different event types
    switch (event.type) {
      case 'checkout.session.completed':
        await handleCheckoutCompleted(event.data.object, supabase, env);
        break;

      case 'payment_intent.succeeded':
        await handlePaymentSucceeded(event.data.object, supabase, env);
        break;

      case 'payment_intent.failed':
        await handlePaymentFailed(event.data.object, supabase, env);
        break;

      case 'customer.subscription.created':
      case 'customer.subscription.updated':
      case 'customer.subscription.deleted':
        await handleSubscriptionChange(event.data.object, supabase, env);
        break;

      default:
        console.log(`Unhandled event type: ${event.type}`);
    }

    return new Response(JSON.stringify({ received: true }), {
      headers: { 'Content-Type': 'application/json' }
    });
  }
};

async function handleCheckoutCompleted(session, supabase, env) {
  // Update order in Supabase
  await supabase
    .from('orders')
    .update({
      status: 'completed',
      stripe_session_id: session.id,
      amount_total: session.amount_total
    })
    .eq('checkout_session_id', session.id);

  // Send confirmation email
  await sendEmail(env, {
    to: session.customer_details.email,
    subject: 'Order Confirmation - Meauxbility',
    template: 'order-confirmation',
    data: session
  });
}

async function handlePaymentSucceeded(paymentIntent, supabase, env) {
  await supabase
    .from('payments')
    .insert({
      stripe_payment_id: paymentIntent.id,
      amount: paymentIntent.amount,
      status: 'succeeded',
      customer_email: paymentIntent.receipt_email
    });
}

async function handlePaymentFailed(paymentIntent, supabase, env) {
  // Log failure
  await supabase
    .from('payment_failures')
    .insert({
      stripe_payment_id: paymentIntent.id,
      error_message: paymentIntent.last_payment_error?.message,
      customer_email: paymentIntent.receipt_email
    });

  // Alert admin
  await sendEmail(env, {
    to: 'sam@meauxbility.org',
    subject: 'Payment Failed Alert',
    template: 'payment-failure',
    data: paymentIntent
  });
}

async function handleSubscriptionChange(subscription, supabase, env) {
  await supabase
    .from('subscriptions')
    .upsert({
      stripe_subscription_id: subscription.id,
      customer_id: subscription.customer,
      status: subscription.status,
      current_period_end: new Date(subscription.current_period_end * 1000)
    });
}

async function sendEmail(env, { to, subject, template, data }) {
  // Implement email sending (SendGrid, Resend, etc.)
  // For now, just log
  console.log(`Email would be sent to ${to}: ${subject}`);
}
