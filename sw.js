const CACHE_STATIC = 'dtz-pwa-v4';
const CACHE_IMAGES = 'dtz-images-v1';
const MAX_IMAGE_ENTRIES = 250;

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

// Limitar cantidad de imágenes en caché para no saturar memoria
async function trimCache(cacheName, maxItems) {
  try {
    const cache = await caches.open(cacheName);
    const keys = await cache.keys();
    if (keys.length > maxItems) {
      await cache.delete(keys[0]);
      trimCache(cacheName, maxItems);
    }
  } catch (e) {}
}

// Install event: cache essential files
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_STATIC)
      .then(cache => cache.addAll(urlsToCache))
  );
  self.skipWaiting();
});

// Activate event: clean up old caches manteniendo CACHE_STATIC y CACHE_IMAGES
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_STATIC && cacheName !== CACHE_IMAGES) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
  self.clients.claim();
});

// Fetch event:
// - Para imágenes (wsrv.nl, ibb.co, supabase storage, extensiones): Cache-First con almacenamiento en caché
// - Para resto: Network First con fallback a caché
self.addEventListener('fetch', event => {
  if (event.request.method !== 'GET') return;

  const url = new URL(event.request.url);

  // Ignorar /app/
  if (url.pathname.startsWith('/app/')) return;

  const isImage = event.request.destination === 'image' ||
    /\.(png|jpg|jpeg|webp|gif|svg)(\?.*)?$/i.test(url.pathname) ||
    url.hostname.includes('wsrv.nl') ||
    url.hostname.includes('ibb.co') ||
    (url.hostname.includes('supabase.co') && url.pathname.includes('/storage/'));

  if (isImage) {
    event.respondWith(
      caches.match(event.request).then(cachedResponse => {
        if (cachedResponse) {
          return cachedResponse;
        }
        return fetch(event.request).then(networkResponse => {
          if (networkResponse && (networkResponse.status === 200 || networkResponse.type === 'opaque')) {
            const clone = networkResponse.clone();
            caches.open(CACHE_IMAGES).then(cache => {
              cache.put(event.request, clone);
              trimCache(CACHE_IMAGES, MAX_IMAGE_ENTRIES);
            });
          }
          return networkResponse;
        }).catch(() => {
          return caches.match(event.request);
        });
      })
    );
    return;
  }

  // Para el resto: Network First con fallback a caché
  event.respondWith(
    fetch(event.request).catch(() => {
      return caches.match(event.request);
    })
  );
});
