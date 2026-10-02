// Riley PWA Service Worker
const CACHE_NAME = 'riley-pwa-v120';
const PRECACHE_ASSETS = [
  './',
  './index.html',
  './manifest.webmanifest',
  './manifest.json',
  './assets/Character_OlderBoy_Solo.png',
  './assets/Character_OlderGirl_Solo.png',
  './assets/Character_YoungerBoy_Solo.png',
  './assets/Character_YoungerGirl_Solo.png',
  './assets/Skeleton_YoungerBoy_Assembled.png',
  './assets/bones/Bone_younger_boy_skull.png',
  './assets/bones/Bone_younger_boy_spine.png',
  './assets/bones/Bone_younger_boy_ribcage.png',
  './assets/bones/Bone_younger_boy_pelvis.png',
  './assets/bones/Bone_younger_boy_humerus_left.png',
  './assets/bones/Bone_younger_boy_radius_ulna_left.png',
  './assets/bones/Bone_younger_boy_hands_left.png',
  './assets/bones/Bone_younger_boy_humerus_right.png',
  './assets/bones/Bone_younger_boy_radius_ulna_right.png',
  './assets/bones/Bone_younger_boy_hands_right.png',
  './assets/bones/Bone_younger_boy_femur_left.png',
  './assets/bones/Bone_younger_boy_fibula_tibia_left.png',
  './assets/bones/Bone_younger_boy_feet_left.png',
  './assets/bones/Bone_younger_boy_femur_right.png',
  './assets/bones/Bone_younger_boy_fibula_tibia_right.png',
  './assets/bones/Bone_younger_boy_feet_right.png',
  './assets/Skeleton_OlderBoy_Assembled.png',
  './assets/bones/Bone_older_boy_skull.png',
  './assets/bones/Bone_older_boy_spine.png',
  './assets/bones/Bone_older_boy_ribcage.png',
  './assets/bones/Bone_older_boy_pelvis.png',
  './assets/bones/Bone_older_boy_humerus_left.png',
  './assets/bones/Bone_older_boy_radius_ulna_left.png',
  './assets/bones/Bone_older_boy_hands_left.png',
  './assets/bones/Bone_older_boy_humerus_right.png',
  './assets/bones/Bone_older_boy_radius_ulna_right.png',
  './assets/bones/Bone_older_boy_hands_right.png',
  './assets/bones/Bone_older_boy_femur_left.png',
  './assets/bones/Bone_older_boy_fibula_tibia_left.png',
  './assets/bones/Bone_older_boy_feet_left.png',
  './assets/bones/Bone_older_boy_femur_right.png',
  './assets/bones/Bone_older_boy_fibula_tibia_right.png',
  './assets/bones/Bone_older_boy_feet_right.png',
  './assets/Organs_Assembled.png',
  './assets/Organs_Assembled_Side.png',
  './assets/Magnifying Glass 1.png',
  './assets/Magnifying Glass 1 Transparent.png',
  './assets/Magnifying Glass 2.png',
  './assets/System Selection.png',
  './assets/System Selection 2.png',
  './assets/System_Box.png',
  './assets/System_Icon_Skeletal.png',
  './assets/System_Icon_Nervous.png',
  './assets/System_Icon_Muscular.png',
  './assets/System_Icon_Organ.png',
  './assets/System_Icon_Organ_Selected.png',
  './assets/Selected Background.png',
  './assets/Brain Illus 1.png',
  './assets/Brain Illus 2.png',
  './assets/Heart Illus 1.png',
  './assets/Heart Illus 2.png',
  './assets/Lungs Illus.png',
  './assets/Liver Illus.png',
  './assets/Stomach Illus.png',
  './assets/Intestines Illus.png',
  './assets/Kidney Illus.png',
  './assets/Bladder Illus.png',
  './assets/Trachea Illus.png',
  './assets/organs_frontal/Organ_lungs.png',
  './assets/organs_frontal/Organ_kidneys.png',
  './assets/organs_frontal/Organ_intestines.png',
  './assets/organs_frontal/Organ_stomach.png',
  './assets/organs_frontal/Organ_liver.png',
  './assets/organs_frontal/Organ_heart.png',
  './assets/organs_frontal/Organ_thyroid.png',
  './assets/organs_frontal/Organ_bladder.png',
  './assets/organs_frontal/Organ_brain.png',
  './assets/organs_side/Organ_lung_side.png',
  './assets/organs_side/Organ_kidneys_side.png',
  './assets/organs_side/Organ_intestines_side.png',
  './assets/organs_side/Organ_stomach_side.png',
  './assets/organs_side/Organ_liver_side.png',
  './assets/organs_side/Organ_heart_side.png',
  './assets/organs_side/Organ_thyroid_side.png',
  './assets/organs_side/Organ_bladder_side.png',
  './assets/organs_side/Organ_brain_side.png',
  './assets/Skeleton_Assembled.png',
  './assets/bones/Bone_skull.png',
  './assets/bones/Bone_spine.png',
  './assets/bones/Bone_ribcage.png',
  './assets/bones/Bone_humerus.png',
  './assets/bones/Bone_radius_ulna.png',
  './assets/bones/Bone_hands.png',
  './assets/bones/Bone_pelvis.png',
  './assets/bones/Bone_femur.png',
  './assets/bones/Bone_fibula_tibia.png',
  './assets/bones/Bone_feet.png',
  './assets/bones/Bone_humerus_left.png',
  './assets/bones/Bone_humerus_right.png',
  './assets/bones/Bone_radius_ulna_left.png',
  './assets/bones/Bone_radius_ulna_right.png',
  './assets/bones/Bone_hands_left.png',
  './assets/bones/Bone_hands_right.png',
  './assets/bones/Bone_femur_left.png',
  './assets/bones/Bone_femur_right.png',
  './assets/bones/Bone_fibula_tibia_left.png',
  './assets/bones/Bone_fibula_tibia_right.png',
  './assets/bones/Bone_feet_left.png',
  './assets/bones/Bone_feet_right.png',
  './assets/Curtain BG.png',
  './assets/CurtainBG.png',
  './assets/Curtains Parting.png',
  './assets/CurtainsParting.png',
  './assets/Curtain_Parting_Left.png',
  './assets/CurtainPartingLeft.png',
  './assets/Curtain_Parting_Right.png',
  './assets/CurtainPartingRight.png',
  './assets/Curtain_Closed_Left.png',
  './assets/CurtainClosedLeft.png',
  './assets/Curtain_Closed_Right.png',
  './assets/CurtainClosedRight.png',
  './assets/Title Sign.png',
  './assets/TitleSign.png',
  './assets/Title.png',
  './assets/Anatomy BG 1.png',
  './assets/AnatomyBG1.png',
  './assets/Older Boy.png',
  './assets/OlderBoy.png',
  './assets/Older Girl.png',
  './assets/OlderGirl.png',
  './assets/Younger Boy.png',
  './assets/YoungerBoy.png',
  './assets/Younger Girl.png',
  './assets/YoungerGirl.png',
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
  './assets/IVButton2.png',
  './assets/IV%20Button%202.png',
  './assets/ButtonMRI.png',
  './assets/MRIRoomLightsOn.png',
  './assets/MRIRoomLightsOff.png',
  './assets/MRIWelcomeScreen.png',
  './assets/MRIGirlWelcome.png',
  './assets/MRIFullBedEmpty.png',
  './assets/MRIFullBedGirl.png',
  './assets/MRIScannerNormal.png',
  './assets/MRIScannerGlow.png',
  './assets/MRIGlowTop.png',
  './assets/MRI Glow Top.png',
  './assets/Full Bed 2.png',
  './assets/Full Bed with Girl.png',
  './assets/MRIBedEmpty.png',
  './assets/MRIBedFull.png',
  './assets/MRI Bed Empty.png',
  './assets/MRI Bed Full.png',
  './assets/MRIGlow.png',
  './assets/MRI Glow.png',
  './assets/MRIBed.png',
  './assets/MRI Bed.png',
  './assets/MRIInside.png',
  './assets/MRISound.mp3',
  './assets/MRISoundL.png',
  './assets/MRISoundL1.png',
  './assets/MRISoundL2.png',
  './assets/MRISoundL3.png',
  './assets/MRISoundL4.png',
  './assets/MRISoundR.png',
  './assets/MRISoundR1.png',
  './assets/MRISoundR2.png',
  './assets/MRISoundR3.png',
  './assets/MRISoundR4.png',
  './assets/MRIRemoteController.png',
  './assets/MRIStressBall.png',
  './assets/MRIStressSquish1.png',
  './assets/MRIStressSquish2.png',
  './assets/MRIVideo.mp4',
  './assets/MRI Video 2.mp4',
  './assets/MRIVideo2.mp4',
  './assets/Handbell.png',
  './assets/Keyboard.png',
  './assets/Tambourine.png',
  './assets/MRIDance.png',
  './assets/MRI Dance.png',
  './assets/MRIDance.mp4',
  './assets/MRI Dance 2.mp4',
  './assets/MRI Dance.mp4',
  './assets/MRIContrast.mp4',
  './assets/MRI Contrast.mp4',
  './assets/MRIWOContrast.mp4',
  './assets/MRI WO Contrast.mp4',
  './assets/Monitors.png',
  './assets/Monitors 2.png',
  './assets/Monitors%202.png',
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
    caches.open(CACHE_NAME).then(async (cache) => {
      // Precache critical app core first
      const coreAssets = [
        './',
        './index.html',
        './manifest.webmanifest',
        './manifest.json'
      ];
      await cache.addAll(coreAssets).catch((err) => console.warn('Core precache warning:', err));

      // Precache all assets in batches to avoid network congestion and connection timeouts on mobile/tablets
      const batchSize = 15;
      for (let i = 0; i < PRECACHE_ASSETS.length; i += batchSize) {
        const batch = PRECACHE_ASSETS.slice(i, i + batchSize);
        await Promise.allSettled(
          batch.map((asset) =>
            fetch(asset, { cache: 'no-cache' }).then((res) => {
              if (res.ok) {
                return cache.put(asset, res);
              }
            }).catch((err) => {
              console.warn('Skipping precache asset:', asset, err);
            })
          )
        );
      }
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

// RFC 7233 Range Request Parser for video/audio streaming in Service Workers (Safari / iOS / iPadOS / Android PWA)
function parseRangeHeader(rangeHeader, totalSize) {
  if (!rangeHeader || !rangeHeader.startsWith('bytes=')) return null;
  const parts = rangeHeader.substring(6).split(',')[0].trim();
  const dashIndex = parts.indexOf('-');
  if (dashIndex === -1) return null;

  const startStr = parts.substring(0, dashIndex).trim();
  const endStr = parts.substring(dashIndex + 1).trim();

  let start = 0;
  let end = totalSize - 1;

  if (startStr === '' && endStr !== '') {
    // Suffix byte range: bytes=-500 (e.g. read last 500 bytes for MP4 moov atom)
    const suffix = parseInt(endStr, 10);
    if (isNaN(suffix)) return null;
    start = Math.max(0, totalSize - suffix);
    end = totalSize - 1;
  } else if (startStr !== '' && endStr === '') {
    // Open range: bytes=1024-
    start = parseInt(startStr, 10);
    if (isNaN(start)) return null;
    end = totalSize - 1;
  } else if (startStr !== '' && endStr !== '') {
    // Explicit range: bytes=0-1
    start = parseInt(startStr, 10);
    end = parseInt(endStr, 10);
    if (isNaN(start) || isNaN(end)) return null;
  } else {
    return null;
  }

  if (start > end || start >= totalSize || start < 0) {
    return { unsatisfiable: true, totalSize };
  }

  end = Math.min(end, totalSize - 1);
  return { start, end, totalSize };
}

// Find media response in cache across relative/absolute URLs and encoding variants
async function findCachedMedia(request) {
  const cache = await caches.open(CACHE_NAME);

  // 1. Match with request object directly (ignoring Range header)
  let res = await cache.match(request, { ignoreSearch: true });
  if (res) return res;

  // 2. Match with URL string directly
  const cleanUrl = request.url.split('?')[0].split('#')[0];
  res = await cache.match(cleanUrl, { ignoreSearch: true });
  if (res) return res;

  // 3. Match with decoded / encoded variants
  try {
    const decoded = decodeURI(cleanUrl);
    res = await cache.match(decoded, { ignoreSearch: true });
    if (res) return res;
  } catch (_) {}

  try {
    const encoded = encodeURI(cleanUrl);
    res = await cache.match(encoded, { ignoreSearch: true });
    if (res) return res;
  } catch (_) {}

  // 4. Match by pathname or filename across all cached entries
  try {
    const targetUrl = new URL(request.url);
    const targetPath = targetUrl.pathname;
    const targetFilename = targetPath.substring(targetPath.lastIndexOf('/') + 1);

    const keys = await cache.keys();
    for (const key of keys) {
      const keyUrl = new URL(key.url);
      const keyPath = keyUrl.pathname;
      const keyFilename = keyPath.substring(keyPath.lastIndexOf('/') + 1);

      if (keyPath === targetPath || decodeURIComponent(keyPath) === decodeURIComponent(targetPath)) {
        return await cache.match(key);
      }
      if (keyFilename && (keyFilename === targetFilename || decodeURIComponent(keyFilename) === decodeURIComponent(targetFilename))) {
        return await cache.match(key);
      }
    }
  } catch (_) {}

  return null;
}

// Serve media with HTTP 206 Partial Content support for iPadOS / iOS / Android standalone PWAs
async function handleMediaRangeRequest(request) {
  const rangeHeader = request.headers.get('range');

  // Attempt to locate media in cache
  let cachedResponse = await findCachedMedia(request);

  // If not cached, fetch once from network and cache full response for slicing
  if (!cachedResponse) {
    try {
      const netRes = await fetch(request.url, { cache: 'no-cache' });
      if (netRes && (netRes.status === 200 || netRes.status === 0)) {
        const cache = await caches.open(CACHE_NAME);
        cache.put(request.url, netRes.clone()).catch(() => {});
        cachedResponse = netRes;
      }
    } catch (err) {
      console.warn('Network fetch fallback failed for media in Service Worker:', request.url, err);
    }
  }

  // If still unavailable, fallback to browser native fetch
  if (!cachedResponse) {
    return fetch(request);
  }

  // If no Range header requested, return cached response
  if (!rangeHeader) {
    return cachedResponse;
  }

  // Parse Range and extract slice from full Blob
  const fullBlob = await cachedResponse.blob();
  const totalSize = fullBlob.size;

  const range = parseRangeHeader(rangeHeader, totalSize);
  if (!range) {
    return cachedResponse;
  }

  if (range.unsatisfiable) {
    return new Response(null, {
      status: 416,
      statusText: 'Range Not Satisfiable',
      headers: {
        'Content-Range': `bytes */${totalSize}`
      }
    });
  }

  const { start, end } = range;
  const chunk = fullBlob.slice(start, end + 1);
  const chunkSize = chunk.size;

  // Determine accurate Content-Type
  let contentType = fullBlob.type || cachedResponse.headers.get('content-type');
  if (!contentType || contentType === 'application/octet-stream') {
    const urlLower = request.url.toLowerCase();
    if (urlLower.endsWith('.mp4')) contentType = 'video/mp4';
    else if (urlLower.endsWith('.webm')) contentType = 'video/webm';
    else if (urlLower.endsWith('.mp3')) contentType = 'audio/mpeg';
    else if (urlLower.endsWith('.m4a')) contentType = 'audio/mp4';
    else contentType = 'video/mp4';
  }

  const responseHeaders = new Headers({
    'Content-Type': contentType,
    'Content-Range': `bytes ${start}-${end}/${totalSize}`,
    'Content-Length': String(chunkSize),
    'Accept-Ranges': 'bytes',
    'Cache-Control': 'public, max-age=31536000',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Range',
    'Access-Control-Expose-Headers': 'Content-Range, Content-Length, Accept-Ranges'
  });

  return new Response(chunk, {
    status: 206,
    statusText: 'Partial Content',
    headers: responseHeaders
  });
}

self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;

  const url = event.request.url;
  const isMedia = (
    event.request.destination === 'video' ||
    event.request.destination === 'audio' ||
    Boolean(event.request.headers.get('range')) ||
    /\.(mp4|m4a|mp3|webm|ogg)(\?.*)?$/i.test(url)
  );

  // Intercept Range requests and media streaming via RFC 7233 HTTP 206 partial content
  if (isMedia) {
    event.respondWith(handleMediaRangeRequest(event.request));
    return;
  }

  // Network-First for Navigation (HTML) requests so fresh deploys load immediately
  if (event.request.mode === 'navigate' || event.request.destination === 'document') {
    event.respondWith(
      fetch(event.request, { cache: 'no-cache' }).then((networkResponse) => {
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
