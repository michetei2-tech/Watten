'use strict';

const CACHE_NAME = 'watten-cache-v1';

// Liste der Dateien, die gecached werden sollen.
// Du kannst sie erweitern, aber diese Basis reicht für eine funktionierende PWA.
const RESOURCES = {
  "/Watten/": "index.html",
  "/Watten/index.html": "index.html",
  "/Watten/main.dart.js": "main.dart.js",
  "/Watten/flutter.js": "flutter.js",
  "/Watten/manifest.json": "manifest.json",
  "/Watten/favicon.png": "favicon.png",
  "/Watten/icons/Icon-192.png": "Icon-192.png",
  "/Watten/icons/Icon-512.png": "Icon-512.png"
};

self.addEventListener('install', (event) => {
  self.skipWaiting();
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(Object.keys(RESOURCES));
    })
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      const cache = await caches.open(CACHE_NAME);
      const keys = await cache.keys();

      // Entferne alte Dateien, die nicht mehr in RESOURCES stehen
      for (const request of keys) {
        const url = new URL(request.url);
        const path = url.pathname;
        if (!RESOURCES[path]) {
          await cache.delete(request);
        }
      }

      self.clients.claim();
    })()
  );
});

self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;

  event.respondWith(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.match(event.request).then((response) => {
        return (
          response ||
          fetch(event.request).then((response) => {
            cache.put(event.request, response.clone());
            return response;
          })
        );
      });
    })
  );
});
