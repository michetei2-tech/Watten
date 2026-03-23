'use strict';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {};

self.addEventListener('install', (event) => {
  self.skipWaiting();
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(Object.keys(RESOURCES));
    })
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(async function() {
    try {
      const contentCache = await caches.open(CACHE_NAME);
      const keys = await contentCache.keys();
      for (const request of keys) {
        const url = new URL(request.url);
        if (!RESOURCES[url.pathname.substring(1)]) {
          await contentCache.delete(request);
        }
      }
      self.clients.claim();
    } catch (err) {
      console.error('Failed to activate service worker:', err);
    }
  }());
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
