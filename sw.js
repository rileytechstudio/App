// Riley PWA Service Worker
const CACHE_NAME = 'riley-pwa-v59';
const PRECACHE_ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './assets/SettingsTitleVoiceAssistant.png',
  './assets/SettingsTitleHaptics.png',
  './assets/SettingsTitleSoundEffects.png',
  './assets/SettingsBackgroundPattern.png',
  './assets/SettingsSingleGear.png',
  './assets/AboutChildsPlay.png',
  './assets/AboutDunkinJoy.png',
  './assets/AboutHomeButton.png',
  './assets/AboutSettingsButton.png',
  './assets/AboutRileyWagon.png',
  './assets/AboutRileyWagon.jpeg',
  './assets/Background Image.png',
  './assets/Background%20Image.png',
  './assets/BackgroundImage.png',
  './assets/Mask 2.png',
  './assets/Mask%202.png',
  './assets/Mask2.png',
  './assets/Person.png',
  './assets/Blink Open.png',
  './assets/Blink%20Open.png',
  './assets/BlinkOpen.png',
  './assets/Blink Closed.png',
  './assets/Blink%20Closed.png',
  './assets/BlinkClosed.png',
  './assets/Ready.png',
  './assets/ReadyCropped.png',
  './assets/Set.png',
  './assets/SetCropped.png',
  './assets/Breathe.png',
  './assets/BreatheCropped.png',
  './assets/You Did It 2.png',
  './assets/You%20Did%20It%202.png',
  './assets/YouDidIt2.png',
  './assets/You Did It 2 Cropped.png',
  './assets/You%20Did%20It%202%20Cropped.png',
  './assets/YouDidIt2Cropped.png',
  './assets/You Did It Chime.mp3',
  './assets/You%20Did%20It%20Chime.mp3',
  './assets/YouDidItChime.mp3',
  './assets/SlowBreath2.mp3',
  './assets/TimerBaseClean.png',
  './assets/Timer1Cropped.png',
  './assets/Timer2Cropped.png',
  './assets/Timer3Cropped.png',
  './assets/Timer2_5Cropped.png',
  './assets/Timer2.5Cropped.png',
  './assets/Timer3_5Cropped.png',
  './assets/Timer3.5Cropped.png',
  './assets/Timer4Cropped.png',
  './assets/Timer5Cropped.png',
  './assets/Timer.png',
  './assets/Timer%201.png',
  './assets/Timer%202.png',
  './assets/Timer%202.5.png',
  './assets/Timer%203.png',
  './assets/Timer%203.5.png',
  './assets/Timer%204.png',
  './assets/Timer 5.png',
  './assets/Timer%205.png',
  './assets/Background.jpg',
  './assets/GameBackground.png',
  './assets/GameTable.png',
  './assets/GameBag.png',
  './assets/GameBagClosed.png',
  './assets/GameArm.png',
  './assets/GameArmWithBand.png',
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
  './assets/Background Image.png',
  './assets/Background%20Image.png',
  './assets/MaskBackground.png',
  './assets/Mask Background.png',
  './assets/Mask.png',
  './assets/Mask 2.png',
  './assets/Mask2.png',
  './assets/Mask%202.png',
  './assets/Sticker Book Closed.png',
  './assets/StickerBookClosed.png',
  './assets/Sticker%20Book%20Closed.png',
  './assets/Sticker Book Open.png',
  './assets/StickerBookOpen.png',
  './assets/Sticker%20Book%20Open.png',
  './assets/Sticker Book Open Cropped.png',
  './assets/StickerBookOpenCropped.png',
  './assets/Sticker%20Book%20Open%20Cropped.png',
  './assets/Dino Sticker.png',
  './assets/DinoSticker.png',
  './assets/DinoStickerCropped.png',
  './assets/Fox Sticker.png',
  './assets/FoxSticker.png',
  './assets/FoxStickerCropped.png',
  './assets/Heart Sticker.png',
  './assets/HeartSticker.png',
  './assets/HeartStickerCropped.png',
  './assets/Rocket Sticker.png',
  './assets/RocketSticker.png',
  './assets/RocketStickerCropped.png',
  './assets/Star Sticker.png',
  './assets/StarSticker.png',
  './assets/StarStickerCropped.png',
  './assets/ChapstickBoxClosed.png',
  './assets/ChapstickBoxOpen.png',
  './assets/ChapstickBoxClosedCropped.png',
  './assets/ChapstickBoxCropped.png',
  './assets/Sparkle1.png',
  './assets/Sparkle2.png',
  './assets/Sparkle3.png',
  './assets/Sparkle4.png',
  './assets/Sparkle 1.png',
  './assets/Sparkle 2.png',
  './assets/Sparkle 3.png',
  './assets/Sparkle 4.png',
  './assets/Sparkle%201.png',
  './assets/Sparkle%202.png',
  './assets/Sparkle%203.png',
  './assets/Sparkle%204.png',
  './assets/BubblegumChapstick.png',
  './assets/StrawberryChapstick.png',
  './assets/BlueberryChapstick.png',
  './assets/CokeChapstick.png',
  './assets/StrawberryTrailEx.png',
  './assets/BlueberryTrailEx.png',
  './assets/BubblegumTrailEx.png',
  './assets/CokeTrailEx.png',
  './assets/StrawberryScent.png',
  './assets/StrawberryScent1.png',
  './assets/StrawberryScent2.png',
  './assets/BlueberryScent.png',
  './assets/BlueberryScent1.png',
  './assets/BlueberryScent2.png',
  './assets/BlueberryScent3.png',
  './assets/BubblegumScent.png',
  './assets/BubblegumScent1.png',
  './assets/BubblegumScent2.png',
  './assets/CokeScent.png',
  './assets/CokeScent1.png',
  './assets/CokeScent2.png',
  './assets/CokeScent3.png',
  './assets/Chapstick.mp3',
  './assets/Wax.mp3',
  './assets/Box Shake 2.mp3',
  './assets/BoxShake2.mp3',
  './assets/Box%20Shake%202.mp3',
  './assets/ChapstickSelect.mp3',
  './assets/BoxOpen.mp3',
  './assets/BoxClose.mp3',
  './assets/PageFlip.mp3',
  './assets/Page Flip.mp3',
  './assets/Page%20Flip.mp3',
  './assets/PageFlip2.mp3',
  './assets/Page Flip 2.mp3',
  './assets/Page%20Flip%202.mp3',
  './assets/MusicBG.mp3',
  './assets/Music BG.mp3',
  './assets/Music BG 6.mp3',
  './assets/MusicBG6.mp3',
  './assets/Music BG 7.mp3',
  './assets/MusicBG7.mp3',
  './assets/Music%20BG%207.mp3',
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
  './Music/Music BG 6.mp3',
  './Music/Music BG 7.mp3',
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
