// CloudFlare Worker for Advanced Security & Performance

addEventListener('fetch', event => {
    event.respondWith(handleRequest(event.request));
});

async function handleRequest(request) {
    const url = new URL(request.url);

    // Security checks
    const securityResult = await performSecurityChecks(request);
    if (securityResult.block) {
        return new Response('Access Denied', {
            status: 403,
            headers: { 'Content-Type': 'text/plain' }
        });
    }

    // Rate limiting
    const rateLimitResult = await checkRateLimit(request);
    if (rateLimitResult.limited) {
        return new Response('Rate limit exceeded', {
            status: 429,
            headers: {
                'Content-Type': 'text/plain',
                'Retry-After': '60'
            }
        });
    }

    // API request preprocessing
    if (url.pathname.startsWith('/api/')) {
        return await handleApiRequest(request);
    }

    // Static content optimization
    if (url.pathname.match(/\.(js|css|png|jpg|jpeg|gif|svg)$/)) {
        return await handleStaticContent(request);
    }

    // Default: Forward to origin
    return await fetch(request);
}

async function performSecurityChecks(request) {
    const url = new URL(request.url);
    const userAgent = request.headers.get('User-Agent') || '';
    const ip = request.headers.get('CF-Connecting-IP');

    // Block suspicious user agents
    const suspiciousUAs = [
        'sqlmap', 'nikto', 'nmap', 'masscan', 'curl/7.', 'python-requests'
    ];

    if (suspiciousUAs.some(ua => userAgent.toLowerCase().includes(ua))) {
        return { block: true, reason: 'Suspicious User Agent' };
    }

    // Block SQL injection attempts
    const sqlPatterns = [
        /union\s+select/i,
        /or\s+1\s*=\s*1/i,
        /'\s*or\s*'1'\s*=\s*'1/i,
        /;\s*drop\s+table/i
    ];

    const queryString = url.search;
    if (sqlPatterns.some(pattern => pattern.test(queryString))) {
        return { block: true, reason: 'SQL Injection Attempt' };
    }

    // Block XSS attempts
    const xssPatterns = [
        /<script/i,
        /javascript:/i,
        /onload\s*=/i,
        /onerror\s*=/i
    ];

    if (xssPatterns.some(pattern => pattern.test(queryString))) {
        return { block: true, reason: 'XSS Attempt' };
    }

    return { block: false };
}

async function checkRateLimit(request) {
    const ip = request.headers.get('CF-Connecting-IP');
    const url = new URL(request.url);

    // Different limits for different endpoints
    let limit = 100; // default
    let window = 60; // 1 minute

    if (url.pathname.startsWith('/api/auth/')) {
        limit = 5; // Stricter for auth endpoints
        window = 300; // 5 minutes
    } else if (url.pathname.startsWith('/api/')) {
        limit = 50;
        window = 60;
    }

    const key = `rate_limit:${ip}:${url.pathname}`;

    // Check current count (would use KV storage in real implementation)
    const current = await RATE_LIMIT_KV.get(key);
    const count = current ? parseInt(current) : 0;

    if (count >= limit) {
        return { limited: true };
    }

    // Increment counter
    await RATE_LIMIT_KV.put(key, (count + 1).toString(), { expirationTtl: window });

    return { limited: false };
}

async function handleApiRequest(request) {
    const url = new URL(request.url);

    // Add security headers to API responses
    const response = await fetch(request);
    const newResponse = new Response(response.body, {
        status: response.status,
        statusText: response.statusText,
        headers: response.headers
    });

    // Add CORS headers
    newResponse.headers.set('Access-Control-Allow-Origin', 'https://app.attendkal.com');
    newResponse.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    newResponse.headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    // Security headers
    newResponse.headers.set('X-Content-Type-Options', 'nosniff');
    newResponse.headers.set('X-Frame-Options', 'DENY');
    newResponse.headers.set('X-XSS-Protection', '1; mode=block');
    newResponse.headers.set('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');

    return newResponse;
}

async function handleStaticContent(request) {
    // Optimize static content delivery
    const response = await fetch(request);

    if (response.ok) {
        const newResponse = new Response(response.body, {
            status: response.status,
            statusText: response.statusText,
            headers: response.headers
        });

        // Add caching headers
        newResponse.headers.set('Cache-Control', 'public, max-age=86400'); // 24 hours
        newResponse.headers.set('Expires', new Date(Date.now() + 86400000).toUTCString());

        return newResponse;
    }

    return response;
} 