// Riley PWA Service Worker
const CACHE_NAME = 'riley-pwa-v20';
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
  './assets/GameArmBandaged.png',
  './assets/GameArmSwabbed.png',
  './assets/GameArmLotion.png',
  './assets/GameOintmentItem.png',
  './assets/GameWashclothItem.png',
  './assets/GameBandItem.png',
  './assets/GamePacketItem.png',
  './assets/GamePacketRippedItem.png',
  './assets/GameRipEffectItem.png',
  './assets/GamePacketWipeItem.png',
  './assets/GameIVNeedleItem.png',
  './assets/GameIVCatheterItem.png',
  './assets/GameTapeItem.png',
  './assets/GameTapeWrapped.png',
  './assets/GameYouDidIt.png',
  './assets/GameTubeItem.png',
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
  './assets/MaskBackground.png',
  './assets/Mask.png',
  './assets/ChapstickBoxClosed.png',
  './assets/ChapstickBoxOpen.png',
  './assets/BubblegumChapstick.png',
  './assets/StrawberryChapstick.png',
  './assets/BlueberryChapstick.png',
  './assets/CokeChapstick.png',
  './assets/StrawberryTrailEx.png',
  './assets/BlueberryTrailEx.png',
  './assets/BubblegumTrailEx.png',
  './assets/CokeTrailEx.png',
  './assets/StrawberryScent.png',
  './assets/BlueberryScent.png',
  './assets/BubblegumScent.png',
  './assets/CokeScent.png',
  './assets/Chapstick.mp3',
  './assets/ChapstickSelect.mp3',
  './assets/BoxOpen.mp3',
  './assets/BoxClose.mp3',
  './assets/MusicBG.mp3',
  './assets/Slime2.mp3',
  './assets/Bandage.mp3',
  './assets/ClothWipe.mp3',
  './assets/RubberBand.mp3',
  './assets/Rip.mp3',
  './assets/ClothWetWipe.mp3',
  './assets/Cloth Wet Wipe.mp3',
  './assets/Shot.mp3',
  './assets/YouDidIt.mp3',
  './assets/You Did It.mp3',
  './Music/Music BG.mp3',
  './Music/alex-morgan-toddler-kids-background-music-583241.mp3',
  './Music/atlasaudio-happy-kids-593047.mp3',
  './Music/desifreemusic-no-copyright-music-181373.mp3'
];

self.addEventListener('install', (event) => {
  self.skipWaiting();
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(PRECACHE_ASSETS).catch((err) => {
        console.warn('Precache individual asset warning:', err);
      });
    })
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((name) => {
          if (name !== CACHE_NAME) {
            console.log('Purging legacy cache:', name);
            return caches.delete(name);
          }
        })
      );
    }).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;

  // Network-First for Navigation (HTML) requests so fresh deploys load immediately
  if (event.request.mode === 'navigate') {
    event.respondWith(
      fetch(event.request).then((networkResponse) => {
        if (networkResponse && networkResponse.status === 200) {
          const responseToCache = networkResponse.clone();
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(event.request, responseToCache);
          });
        }
        return networkResponse;
      }).catch(() => {
        return caches.match('./index.html');
      })
    );
    return;
  }

  // Cache-First for static assets
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
      });
    })
  );
});
