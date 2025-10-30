// ==================================================================
// CLOUDFLARE WORKER 2: IMAGE OPTIMIZATION
// ==================================================================
// Auto-optimize images for all 3 sites
// Compress, resize, convert to WebP

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    // Get image URL from query params
    const imageUrl = url.searchParams.get('url');
    const width = parseInt(url.searchParams.get('width') || '800');
    const quality = parseInt(url.searchParams.get('quality') || '85');
    const format = url.searchParams.get('format') || 'webp';

    if (!imageUrl) {
      return new Response('Missing image URL', { status: 400 });
    }

    // Check R2 cache first
    const cacheKey = `${imageUrl}_${width}_${quality}_${format}`;
    const cached = await env.MEDIA_ASSETS.get(cacheKey);

    if (cached) {
      return new Response(cached, {
        headers: {
          'Content-Type': `image/${format}`,
          'Cache-Control': 'public, max-age=31536000',
          'X-Cache': 'HIT'
        }
      });
    }

    // Fetch original image
    const response = await fetch(imageUrl);
    if (!response.ok) {
      return new Response('Failed to fetch image', { status: 502 });
    }

    // Use Cloudflare Image Resizing
    const optimized = await fetch(imageUrl, {
      cf: {
        image: {
          width,
          quality,
          format
        }
      }
    });

    const imageData = await optimized.arrayBuffer();

    // Store in R2 cache
    await env.MEDIA_ASSETS.put(cacheKey, imageData, {
      httpMetadata: {
        contentType: `image/${format}`,
      }
    });

    return new Response(imageData, {
      headers: {
        'Content-Type': `image/${format}`,
        'Cache-Control': 'public, max-age=31536000',
        'X-Cache': 'MISS'
      }
    });
  }
};
