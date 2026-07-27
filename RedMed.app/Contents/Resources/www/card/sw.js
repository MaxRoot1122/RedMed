// Offline cache for card/index.html — the NFC-tap emergency card fallback.
// After one successful load, repeat taps render with zero network,
// including in dead zones (Cache Storage ignores the #d= fragment, so
// every profile still renders correctly from the one cached shell).
var CACHE_NAME = "redmed-card-v2";
var ASSETS = [
  "./",
  "index.html",
  "../assets/icon.svg",
  "../assets/favicon-32.png",
  "../assets/apple-touch-icon.png"
];

self.addEventListener("install", function (event) {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(function (cache) { return cache.addAll(ASSETS); })
      .then(function () { return self.skipWaiting(); })
  );
});

self.addEventListener("activate", function (event) {
  event.waitUntil(
    caches.keys().then(function (keys) {
      return Promise.all(keys.filter(function (k) { return k !== CACHE_NAME; }).map(function (k) { return caches.delete(k); }));
    }).then(function () { return self.clients.claim(); })
  );
});

self.addEventListener("fetch", function (event) {
  if (event.request.method !== "GET") return;
  event.respondWith(
    caches.match(event.request).then(function (cached) {
      return cached || fetch(event.request);
    })
  );
});
