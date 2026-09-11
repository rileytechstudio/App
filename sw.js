// Riley PWA Service Worker
const CACHE_NAME = 'riley-pwa-v2';
const PRECACHE_ASSETS = [
  './',
  './index.html',
  './manifest.webmanifest',
  './assets/icons/icon-192.png',
  './assets/icons/icon-512.png',
  './assets/icons/apple-touch-icon.png',
  './assets/Background.jpg',
  './assets/GameBackground.png',
  './assets/GameTable.png',
  './assets/GameBag.png',
  './assets/GameArm.png',
  './assets/GameArmWithBand.png',
  './assets/GameLotionItem.png',
  './assets/GameOintmentItem.png',
  './assets/GameBandageItem.png',
  './assets/GameBandageWrapped.png',
  './assets/GameWashclothItem.png',
  './assets/GameBandItem.png',
  './assets/GamePacketItem.png',
  './assets/GamePacketRippedItem.png',
  './assets/GameRipEffectItem.png',
  './assets/GamePacketWipeItem.png',
  './assets/HeaderBanner.jpg',
  './assets/Home.png',
  './assets/Games.png',
  './assets/Preparations.png',
  './assets/ButtonIVStart.png',
  './assets/ButtonNGTube.png',
  './assets/ButtonPortAccess.png',
  './assets/ButtonBurnDress.png',
  './assets/About.png',
  './assets/Legal.png',
  './assets/IconBack.png',
  './assets/BottomBarGames.png',
  './assets/BottomBarPreparations.png',
  './assets/PurpleFade.png',
  './assets/RibbonEducationSelected.png',
  './assets/RibbonProceduresSelected.png',
  './Music/alex-morgan-toddler-kids-background-music-583241.mp3',
  './Music/atlasaudio-happy-kids-593047.mp3',
  './Music/desifreemusic-no-copyright-music-181373.mp3'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(PRECACHE_ASSETS).catch((err) => {
        console.warn('Precache individual asset warning:', err);
      });
    }).then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((name) => {
          if (name !== CACHE_NAME) {
            return caches.delete(name);
          }
        })
      );
    }).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;

  event.respondWith(
    caches.match(event.request).then((cachedResponse) => {
      if (cachedResponse) {
        return cachedResponse;
      }
      return fetch(event.request).then((networkResponse) => {
        if (!networkResponse || networkResponse.status !== 200 || networkResponse.type !== 'basic') {
          return networkResponse;
        }
        const responseToCache = networkResponse.clone();
        caches.open(CACHE_NAME).then((cache) => {
          cache.put(event.request, responseToCache);
        });
        return networkResponse;
      }).catch(() => {
        // Offline fallback for navigation requests
        if (event.request.mode === 'navigate') {
          return caches.match('./index.html');
        }
      });
    })
  );
});
