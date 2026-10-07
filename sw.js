const CACHE_NAME = 'dtz-pwa-v3';
const urlsToCache = [
  './',
  './index.html',
  './admin.html',
  './reparaciones.html',
  './pedidos.html',
  './config.js',
  './manifest.json',
  './favicon.png',
  './nuevo_favicon.png'
];

// Install event: cache essential files
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        return cache.addAll(urlsToCache);
      })
  );
  self.skipWaiting();
});

// Activate event: clean up old caches
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
  self.clients.claim();
});

// Fetch event: network first, fallback to cache for PWA offline stability
self.addEventListener('fetch', event => {
  // Only handle GET requests
  if (event.request.method !== 'GET') return;

  // Ignorar las peticiones al subdirectorio /app/ para que no se mezcle con la PWA principal
  const url = new URL(event.request.url);
  if (url.pathname.startsWith('/app/')) {
    return;
  }

  event.respondWith(
    fetch(event.request).catch(() => {
      return caches.match(event.request);
    })
  );
});
