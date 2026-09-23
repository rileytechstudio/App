#!/usr/bin/env python3
"""
Compiler script to build the pure, full-screen Progressive Web App (PWA)
distribution from the working development simulator template.
"""

import os
import re
import shutil

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC_HTML_PATH = os.path.join(BASE_DIR, "preview", "index.html")
SRC_ASSETS_DIR = os.path.join(BASE_DIR, "preview", "assets")
DIST_HTML_PATH = os.path.join(BASE_DIR, "index.html")
DIST_ASSETS_DIR = os.path.join(BASE_DIR, "assets")

def sync_assets():
    print("Synchronizing assets from preview/assets to assets/...")
    if not os.path.exists(DIST_ASSETS_DIR):
        os.makedirs(DIST_ASSETS_DIR)
    for item in os.listdir(SRC_ASSETS_DIR):
        s = os.path.join(SRC_ASSETS_DIR, item)
        d = os.path.join(DIST_ASSETS_DIR, item)
        if os.path.isfile(s):
            shutil.copy2(s, d)
    print("Assets synchronized successfully.")

def build_distribution():
    print(f"Reading source template from: {SRC_HTML_PATH}")
    with open(SRC_HTML_PATH, "r", encoding="utf-8") as f:
        src = f.read()

    # Extract CSS inside <style>...</style>
    style_match = re.search(r"<style>(.*?)</style>", src, re.DOTALL)
    if not style_match:
        raise ValueError("Could not find <style> block in source HTML")
    css = style_match.group(1)

    # Clean out simulator-only CSS rules
    # Remove header.sim-toolbar, main.sim-workspace, .device-shell
    css = re.sub(r"/\* Top Simulator Toolbar \*/.*?/\* Screen Bezel and Display Area \*/", "/* Screen Bezel and Display Area */", css, flags=re.DOTALL)
    css = re.sub(r"/\* Bottom Info Status Bar \*/.*?footer\.sim-status\s*\{[^}]*\}", "", css, flags=re.DOTALL)

    # Injected responsive distribution styles
    dist_css_overrides = """
    /* App Screen Stacking & Absolute Bounds - Guarantees correct screen layering */
    .app-screen {
      width: 100% !important;
      height: 100% !important;
      position: absolute !important;
      inset: 0 !important;
      display: flex !important;
      flex-direction: column !important;
      overflow: hidden !important;
      background-color: var(--riley-purple) !important;
      opacity: 0 !important;
      pointer-events: none !important;
      transition: opacity 0.28s ease !important;
    }

    .app-screen.active {
      opacity: 1 !important;
      pointer-events: auto !important;
      z-index: 10 !important;
    }

    /* Base Full-Screen & Safe-Area Styles */
    html, body {
      width: 100vw;
      height: 100vh;
      height: 100dvh;
      margin: 0;
      padding: 0;
      overflow: hidden;
      background: var(--riley-dark-purple, #411e8c);
      color: #e2e8f0;
      overscroll-behavior: none;
      -webkit-touch-callout: none;
      -webkit-tap-highlight-color: transparent;
      touch-action: pan-x pan-y;
      position: fixed;
      inset: 0;
    }

    /* Edge-to-Edge Responsive Canvas Across All Devices (iPad, Desktop & Mobile) */
    .device-screen {
      background: var(--riley-purple);
      border-radius: 0 !important;
      box-shadow: none !important;
      overflow: hidden;
      width: 100vw !important;
      height: 100vh !important;
      height: 100dvh !important;
      position: relative;
      display: flex;
      flex-direction: column;
    }

    .app-header {
      padding-top: env(safe-area-inset-top, 0px);
    }

    /* Bottom Bar Anchored Directly to Screen Bottom with Zero Padding Distortion */
    .prep-bottom-bar, .game-bottom-bar {
      position: absolute !important;
      bottom: 0 !important;
      left: 0 !important;
      right: 0 !important;
      width: 100% !important;
      margin: 0 !important;
      padding: 0 !important;
      background: url('assets/Bottom_Toolbar_Background.png') center bottom / 100% 100% no-repeat, rgba(28, 14, 56, 0.45) !important;
      backdrop-filter: blur(12px) !important;
      -webkit-backdrop-filter: blur(12px) !important;
      display: flex !important;
      align-items: center !important;
      justify-content: center !important;
    }
    """
    css += dist_css_overrides

    # Extract contents of <div class="device-screen">
    screen_match = re.search(r'<div class="device-screen"[^>]*>(.*?)<!-- ========================================================= -->\s*<!-- MODAL NAVIGATION', src, re.DOTALL)
    modal_match = re.search(r'(<!-- ========================================================= -->\s*<!-- MODAL NAVIGATION.*?</div>\s*</div>\s*</div>\s*</main>)', src, re.DOTALL)
    
    # Or simpler: find between <div class="device-screen"> and its matching closing </div> before </div>\s*</main>
    screen_start_idx = src.find('<div class="device-screen"')
    if screen_start_idx == -1:
        raise ValueError("Could not find <div class=\"device-screen\">")
    
    # Find outer simulator </main>
    main_end_idx = src.rfind('</main>')
    if main_end_idx == -1:
        raise ValueError("Could not find </main>")

    # The block inside <div class="device-screen"> ends right before </div>\s*</main>
    device_screen_block = src[screen_start_idx:main_end_idx]
    # Strip the single trailing </div> that closes #deviceShell, leaving the closing </div> for .device-screen
    device_screen_block = re.sub(r'</div>\s*$', '', device_screen_block.strip())

    # Extract <script>...</script>
    script_match = re.search(r"<script>(.*?)</script>", src, re.DOTALL)
    if not script_match:
        raise ValueError("Could not find <script> block in source HTML")
    js = script_match.group(1)

    # In distribution, switchScreen can safely ignore statusSpan and screenSelect
    # Prepend Service Worker registration to JS
    sw_registration = """
    // Register Riley PWA Service Worker
    if ('serviceWorker' in navigator) {
      window.addEventListener('load', () => {
        navigator.serviceWorker.register('./sw.js', { scope: './' })
          .then(reg => {
            console.log('Riley PWA ServiceWorker active with scope:', reg.scope);
            reg.update();
          })
          .catch(err => console.warn('ServiceWorker registration error:', err));
      });
    }
    """
    js = sw_registration + "\n" + js

    # Build final HTML
    dist_html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover" />
  <title>Riley - Pediatric Medical Procedure Prep</title>
  
  <!-- PWA & Mobile Web App Meta Tags -->
  <link rel="manifest" href="./manifest.webmanifest" />
  <meta name="theme-color" content="#411e8c" />
  <meta name="apple-mobile-web-app-capable" content="yes" />
  <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />
  <meta name="apple-mobile-web-app-title" content="Riley" />
  <link rel="apple-touch-icon" href="./assets/icons/apple-touch-icon.png" />
  <link rel="icon" type="image/png" sizes="192x192" href="./assets/icons/icon-192.png" />
  <link rel="icon" type="image/png" sizes="512x512" href="./assets/icons/icon-512.png" />

  <style>
{css.strip()}
  </style>
</head>
<body>
  {device_screen_block}

  <script>
{js.strip()}
  </script>
</body>
</html>
"""

    with open(DIST_HTML_PATH, "w", encoding="utf-8") as f:
        f.write(dist_html)

    print(f"Successfully compiled distribution: {DIST_HTML_PATH} ({len(dist_html)} bytes)")

if __name__ == "__main__":
    sync_assets()
    build_distribution()
