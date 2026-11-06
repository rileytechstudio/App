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
SW_PATH = os.path.join(BASE_DIR, "sw.js")

def bump_service_worker():
    if not os.path.exists(SW_PATH):
        return
    with open(SW_PATH, "r", encoding="utf-8") as f:
        sw_content = f.read()
    
    def repl(m):
        prefix = m.group(1)
        ver = int(m.group(2)) + 1
        return f"{prefix}{ver}';"

    new_sw_content = re.sub(r"(const CACHE_NAME = 'riley-pwa-v)(\d+)';", repl, sw_content)
    if new_sw_content != sw_content:
        with open(SW_PATH, "w", encoding="utf-8") as f:
            f.write(new_sw_content)
        m = re.search(r"const CACHE_NAME = '([^']+)';", new_sw_content)
        if m:
            print(f"Bumped Service Worker cache version to: {m.group(1)}")

def sync_assets():
    print("Synchronizing assets from preview/assets to assets/...")
    if not os.path.exists(DIST_ASSETS_DIR):
        os.makedirs(DIST_ASSETS_DIR)
    for item in os.listdir(SRC_ASSETS_DIR):
        s = os.path.join(SRC_ASSETS_DIR, item)
        d = os.path.join(DIST_ASSETS_DIR, item)
        if os.path.isfile(s):
            shutil.copy2(s, d)
        elif os.path.isdir(s):
            shutil.copytree(s, d, dirs_exist_ok=True)
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
      opacity: 0 !important;
      pointer-events: none !important;
      z-index: 1 !important;
      will-change: opacity !important;
    }

    .app-screen:not(.active),
    .app-screen:not(.active) * {
      pointer-events: none !important;
    }

    .app-screen.outgoing {
      opacity: 1 !important;
      pointer-events: none !important;
      z-index: 5 !important;
      transition: none !important;
    }

    .app-screen.active {
      opacity: 1 !important;
      pointer-events: auto !important;
      z-index: 10 !important;
      transition: opacity 0.22s cubic-bezier(0.25, 1, 0.5, 1) !important;
    }

    /* Base Full-Screen & Safe-Area Styles (Edge-to-edge true bleed on iOS PWA/Safari) */
    html {
      width: 100%;
      height: 100%;
      min-height: 100%;
      min-height: calc(100% + env(safe-area-inset-top, 0px) + env(safe-area-inset-bottom, 0px));
      margin: 0;
      padding: 0;
      overflow: hidden;
      background: #d4d7db;
      background-color: #d4d7db;
    }

    body {
      width: 100%;
      height: 100%;
      min-height: 100%;
      min-height: 100vh;
      margin: 0;
      padding: 0;
      overflow: hidden;
      background: #d4d7db;
      background-color: #d4d7db;
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
      background: #d4d7db;
      background-color: #d4d7db;
      border-radius: 0 !important;
      box-shadow: none !important;
      overflow: hidden;
      width: 100% !important;
      width: 100vw !important;
      height: 100% !important;
      min-height: 100% !important;
      min-height: 100vh !important;
      position: absolute !important;
      inset: 0 !important;
      display: flex;
      flex-direction: column;
    }

    /* Home Screen Full-Bleed Backdrop & Safe Area Layout (Zero chin gap on iOS) */
    html.home-active,
    body.home-active,
    body:has(#screenHome.active) {
      background-image: url('assets/HomeScreenBG.png') !important;
      background-size: cover !important;
      background-position: center bottom !important;
      background-repeat: no-repeat !important;
      background-color: #d4d7db !important;
    }
    body.home-active .device-screen,
    body:has(#screenHome.active) .device-screen {
      background-image: url('assets/HomeScreenBG.png') !important;
      background-size: cover !important;
      background-position: center bottom !important;
      background-repeat: no-repeat !important;
      background-color: #d4d7db !important;
    }

    #screenHome {
      position: absolute !important;
      inset: 0 !important;
      width: 100% !important;
      height: 100% !important;
      min-height: 100% !important;
      background-image: url('assets/HomeScreenBG.png') !important;
      background-size: cover !important;
      background-position: center bottom !important;
      background-repeat: no-repeat !important;
      background-color: #d4d7db !important;
      overflow: hidden !important;
    }

    #screenHome .home-bg-layer {
      position: absolute !important;
      inset: 0 !important;
      width: 100% !important;
      height: 100% !important;
      min-height: 100% !important;
      background-image: url('assets/HomeScreenBG.png') !important;
      background-size: cover !important;
      background-position: center bottom !important;
      background-repeat: no-repeat !important;
      transform: none !important;
      z-index: 1 !important;
      pointer-events: none !important;
    }

    #screenHome .home-bg-overlay {
      display: none !important;
    }

    /* Preparations & Games Screen Full-Bleed #f4f4f4 Backdrop & Safe Area Layout */
    #screenPreparations,
    #screenGames {
      background: #f4f4f4 !important;
      background-color: #f4f4f4 !important;
      background-image: none !important;
    }

    body.preparations-active,
    body.games-active,
    body:has(#screenPreparations.active),
    body:has(#screenGames.active) {
      background: #f4f4f4 !important;
      background-color: #f4f4f4 !important;
      background-image: none !important;
    }
    body.preparations-active .device-screen,
    body.games-active .device-screen,
    body:has(#screenPreparations.active) .device-screen,
    body:has(#screenGames.active) .device-screen {
      background: #f4f4f4 !important;
      background-color: #f4f4f4 !important;
      background-image: none !important;
    }

    #screenPreparations .home-bg-layer,
    #screenPreparations .home-bg-overlay,
    #screenGames .home-bg-layer,
    #screenGames .home-bg-overlay {
      display: none !important;
    }

    /* Matching Memory Game Screen Full-Bleed Rebranded Berry Backdrop & Safe Area Layout */
    #screenMatchingGame {
      background: #651b46 !important;
      background-color: #651b46 !important;
      background-image: url('assets/MatchingGameBG.png') !important;
      background-size: cover !important;
      background-position: center !important;
      background-repeat: no-repeat !important;
    }

    body:has(#screenMatchingGame.active) {
      background: #651b46 !important;
      background-color: #651b46 !important;
      background-image: url('assets/MatchingGameBG.png') !important;
      background-size: cover !important;
      background-position: center !important;
      background-repeat: no-repeat !important;
    }

    body:has(#screenMatchingGame.active) .device-screen {
      background: #651b46 !important;
      background-color: #651b46 !important;
      background-image: url('assets/MatchingGameBG.png') !important;
      background-size: cover !important;
      background-position: center !important;
      background-repeat: no-repeat !important;
    }

    /* Child Life Zone Jigsaw Puzzle Screen Full-Bleed Rebranded Berry Backdrop & Safe Area Layout */
    #screenCLZPuzzle {
      background: #591a3f !important;
      background-color: #591a3f !important;
      background-image: url('assets/PuzzleGameBG.png') !important;
      background-size: cover !important;
      background-position: center !important;
      background-repeat: no-repeat !important;
    }

    body:has(#screenCLZPuzzle.active) {
      background: #591a3f !important;
      background-color: #591a3f !important;
      background-image: url('assets/PuzzleGameBG.png') !important;
      background-size: cover !important;
      background-position: center !important;
      background-repeat: no-repeat !important;
    }

    body:has(#screenCLZPuzzle.active) .device-screen {
      background: #591a3f !important;
      background-color: #591a3f !important;
      background-image: url('assets/PuzzleGameBG.png') !important;
      background-size: cover !important;
      background-position: center !important;
      background-repeat: no-repeat !important;
    }

    #screenCLZPuzzle .puzzle-table-texture {
      display: none !important;
    }

    /* Home Custom Header: Always respect iOS Tablet Status Bar (Time and Battery) */
    .home-custom-header {
      padding-top: calc(env(safe-area-inset-top, 0px) + 16px) !important;
      padding-left: max(24px, env(safe-area-inset-left, 0px)) !important;
      padding-right: max(24px, env(safe-area-inset-right, 0px)) !important;
      padding-bottom: 0 !important;
      width: 100% !important;
      display: flex !important;
      justify-content: space-between !important;
      align-items: flex-start !important;
      position: relative !important;
      z-index: 30 !important;
      box-sizing: border-box !important;
      background: transparent !important;
      flex-shrink: 0 !important;
    }

    .home-header-left, .home-header-right {
      display: flex !important;
      align-items: center !important;
      z-index: 5 !important;
      min-width: 56px !important;
      height: 44px !important;
      min-height: 44px !important;
    }

    .home-header-right {
      justify-content: flex-end !important;
      gap: 12px !important;
    }

    .home-header-center {
      position: absolute !important;
      left: 50% !important;
      top: calc(env(safe-area-inset-top, 0px) + 38px) !important;
      transform: translate(-50%, -50%) !important;
      display: flex !important;
      align-items: center !important;
      justify-content: center !important;
      pointer-events: none !important;
      width: auto !important;
      max-width: calc(100% - 160px) !important;
      height: auto !important;
      z-index: 2 !important;
    }

    .home-logo-banner {
      height: 76px !important;
      max-height: 84px !important;
      max-width: 100% !important;
      object-fit: contain !important;
      filter: drop-shadow(0 3px 10px rgba(0, 0, 0, 0.09)) !important;
    }

    /* Rebranded Berry Liquid Glass Header Buttons (Back, Home, Settings) */
    .header-glass-btn {
      background: linear-gradient(145deg, rgba(148, 18, 98, 0.92) 0%, rgba(123, 3, 80, 0.90) 50%, rgba(99, 2, 64, 0.94) 100%) !important;
      backdrop-filter: blur(24px) saturate(190%) !important;
      -webkit-backdrop-filter: blur(24px) saturate(190%) !important;
      border: 1.5px solid rgba(255, 255, 255, 0.40) !important;
      box-shadow: 0 6px 18px rgba(78, 4, 52, 0.40), 0 2px 6px rgba(0, 0, 0, 0.16), inset 0 1.5px 1px 0 rgba(255, 255, 255, 0.55), inset 0 -1.5px 2px 0 rgba(0, 0, 0, 0.35) !important;
      border-radius: 50% !important;
      display: inline-flex !important;
      align-items: center !important;
      justify-content: center !important;
      transition: transform 0.20s cubic-bezier(0.34, 1.56, 0.64, 1), background 0.18s ease, box-shadow 0.18s ease, border-color 0.18s ease !important;
      box-sizing: border-box !important;
      flex-shrink: 0 !important;
      cursor: pointer !important;
      width: 44px !important;
      height: 44px !important;
      min-width: 44px !important;
      min-height: 44px !important;
    }

    .header-glass-btn:hover {
      background: linear-gradient(145deg, rgba(170, 25, 114, 0.95) 0%, rgba(142, 6, 92, 0.94) 50%, rgba(114, 3, 74, 0.96) 100%) !important;
      border-color: rgba(255, 255, 255, 0.65) !important;
      transform: scale(1.08) !important;
      box-shadow: 0 8px 24px rgba(78, 4, 52, 0.50), 0 3px 8px rgba(0, 0, 0, 0.22), inset 0 1.5px 1.5px 0 rgba(255, 255, 255, 0.75), inset 0 -1.5px 2px 0 rgba(0, 0, 0, 0.35) !important;
    }

    .header-glass-btn.home-setting-btn:hover {
      transform: scale(1.08) rotate(12deg) !important;
    }

    .header-glass-btn:active,
    .header-glass-btn.home-setting-btn:active {
      background: linear-gradient(145deg, rgba(110, 2, 72, 0.95) 0%, rgba(88, 2, 58, 0.96) 100%) !important;
      transform: scale(0.94) !important;
      box-shadow: 0 3px 10px rgba(78, 4, 52, 0.30), inset 0 1px 1px 0 rgba(255, 255, 255, 0.40) !important;
    }

    .header-glass-btn svg {
      width: 52% !important;
      height: 52% !important;
      fill: #ffffff !important;
      color: #ffffff !important;
      display: block !important;
      pointer-events: none !important;
      filter: drop-shadow(0 1px 2px rgba(0, 0, 0, 0.35)) !important;
    }

    .header-glass-btn svg path {
      fill: #ffffff !important;
    }

    /* Game and Procedure Header Navigation Buttons (Berry Liquid Glass) */
    .game-top-btn {
      display: inline-flex !important;
      align-items: center !important;
      gap: 6px !important;
      background: linear-gradient(145deg, rgba(148, 18, 98, 0.92) 0%, rgba(123, 3, 80, 0.90) 50%, rgba(99, 2, 64, 0.94) 100%) !important;
      backdrop-filter: blur(24px) saturate(190%) !important;
      -webkit-backdrop-filter: blur(24px) saturate(190%) !important;
      border: 1.5px solid rgba(255, 255, 255, 0.40) !important;
      box-shadow: 0 4px 14px rgba(78, 4, 52, 0.35), inset 0 1px 1px 0 rgba(255, 255, 255, 0.55), inset 0 -1px 2px 0 rgba(0, 0, 0, 0.35) !important;
      color: #ffffff !important;
      font-size: 14px !important;
      font-weight: 700 !important;
      padding: 6px 14px !important;
      border-radius: 20px !important;
      cursor: pointer !important;
      transition: background 0.18s ease, transform 0.20s cubic-bezier(0.34, 1.56, 0.64, 1), box-shadow 0.18s ease, border-color 0.18s ease !important;
    }

    .game-top-btn:hover {
      background: linear-gradient(145deg, rgba(170, 25, 114, 0.95) 0%, rgba(142, 6, 92, 0.94) 50%, rgba(114, 3, 74, 0.96) 100%) !important;
      border-color: rgba(255, 255, 255, 0.65) !important;
      transform: scale(1.05) !important;
      box-shadow: 0 6px 18px rgba(78, 4, 52, 0.45), inset 0 1.5px 1px 0 rgba(255, 255, 255, 0.70) !important;
    }

    .game-top-btn:active {
      background: linear-gradient(145deg, rgba(110, 2, 72, 0.95) 0%, rgba(88, 2, 58, 0.96) 100%) !important;
      transform: scale(0.95) !important;
      box-shadow: 0 2px 8px rgba(78, 4, 52, 0.30), inset 0 1px 1px 0 rgba(255, 255, 255, 0.40) !important;
    }

    .game-top-btn-icon {
      display: inline-flex !important;
      align-items: center !important;
      justify-content: center !important;
      width: 36px !important;
      height: 36px !important;
      background: linear-gradient(145deg, rgba(148, 18, 98, 0.92) 0%, rgba(123, 3, 80, 0.90) 50%, rgba(99, 2, 64, 0.94) 100%) !important;
      backdrop-filter: blur(24px) saturate(190%) !important;
      -webkit-backdrop-filter: blur(24px) saturate(190%) !important;
      border: 1.5px solid rgba(255, 255, 255, 0.40) !important;
      box-shadow: 0 4px 14px rgba(78, 4, 52, 0.35), inset 0 1px 1px 0 rgba(255, 255, 255, 0.55), inset 0 -1px 2px 0 rgba(0, 0, 0, 0.35) !important;
      color: #ffffff !important;
      border-radius: 50% !important;
      cursor: pointer !important;
      transition: background 0.18s ease, transform 0.20s cubic-bezier(0.34, 1.56, 0.64, 1), box-shadow 0.18s ease, border-color 0.18s ease !important;
    }

    .game-top-actions {
      display: inline-flex !important;
      align-items: center !important;
      gap: 8px !important;
    }

    .game-top-btn-icon:hover {
      background: linear-gradient(145deg, rgba(170, 25, 114, 0.95) 0%, rgba(142, 6, 92, 0.94) 50%, rgba(114, 3, 74, 0.96) 100%) !important;
      border-color: rgba(255, 255, 255, 0.65) !important;
      transform: scale(1.08) !important;
      box-shadow: 0 6px 18px rgba(78, 4, 52, 0.45), inset 0 1.5px 1px 0 rgba(255, 255, 255, 0.70) !important;
    }

    .game-top-btn-icon:active {
      background: linear-gradient(145deg, rgba(110, 2, 72, 0.95) 0%, rgba(88, 2, 58, 0.96) 100%) !important;
      transform: scale(0.94) !important;
      box-shadow: 0 2px 8px rgba(78, 4, 52, 0.30), inset 0 1px 1px 0 rgba(255, 255, 255, 0.40) !important;
    }

    .game-top-btn-icon svg {
      color: #ffffff !important;
      filter: drop-shadow(0 1px 2px rgba(0, 0, 0, 0.35)) !important;
    }

    .game-restart-btn:hover {
      transform: scale(1.08) rotate(45deg) !important;
    }

    #screenNGTube.maze-mode .game-top-btn {
      color: #ffffff !important;
      background: linear-gradient(145deg, rgba(148, 18, 98, 0.92) 0%, rgba(123, 3, 80, 0.90) 50%, rgba(99, 2, 64, 0.94) 100%) !important;
      backdrop-filter: blur(24px) saturate(190%) !important;
      -webkit-backdrop-filter: blur(24px) saturate(190%) !important;
      border: 1.5px solid rgba(255, 255, 255, 0.40) !important;
      box-shadow: 0 4px 16px rgba(78, 4, 52, 0.35), inset 0 1px 1px rgba(255, 255, 255, 0.55) !important;
    }

    #screenNGTube.maze-mode .game-top-btn-icon {
      color: #ffffff !important;
      background: linear-gradient(145deg, rgba(148, 18, 98, 0.92) 0%, rgba(123, 3, 80, 0.90) 50%, rgba(99, 2, 64, 0.94) 100%) !important;
      backdrop-filter: blur(24px) saturate(190%) !important;
      -webkit-backdrop-filter: blur(24px) saturate(190%) !important;
      border: 1.5px solid rgba(255, 255, 255, 0.40) !important;
      box-shadow: 0 4px 16px rgba(78, 4, 52, 0.35), inset 0 1px 1px rgba(255, 255, 255, 0.55) !important;
    }

    /* Consistent Navigation Header Across All Screens - Transparent floating header matching Home */
    .app-header, .about-header {
      padding-top: calc(env(safe-area-inset-top, 0px) + 16px) !important;
      padding-left: max(24px, env(safe-area-inset-left, 0px)) !important;
      padding-right: max(24px, env(safe-area-inset-right, 0px)) !important;
      padding-bottom: 0 !important;
      width: 100% !important;
      display: flex !important;
      justify-content: space-between !important;
      align-items: flex-start !important;
      position: relative !important;
      z-index: 30 !important;
      box-sizing: border-box !important;
      background: transparent !important;
      -webkit-backdrop-filter: none !important;
      backdrop-filter: none !important;
      border-bottom: none !important;
      box-shadow: none !important;
      flex-shrink: 0 !important;
    }

    .app-header::after, .about-header::after {
      display: none !important;
    }

    .app-header .header-left, .about-header .header-left,
    .app-header .header-right, .about-header .header-right {
      position: relative !important;
      z-index: 5 !important;
      display: flex !important;
      align-items: center !important;
      min-width: 56px !important;
      height: 44px !important;
      min-height: 44px !important;
    }

    .app-header .header-right, .about-header .header-right {
      justify-content: flex-end !important;
      gap: 12px !important;
    }

    .app-header .header-center, .about-header .header-center {
      position: absolute !important;
      left: 50% !important;
      top: calc(env(safe-area-inset-top, 0px) + 38px) !important;
      transform: translate(-50%, -50%) !important;
      display: flex !important;
      align-items: center !important;
      justify-content: center !important;
      pointer-events: none !important;
      width: auto !important;
      max-width: calc(100% - 160px) !important;
      height: auto !important;
      z-index: 2 !important;
    }

    .consistent-header-banner {
      height: 76px !important;
      max-height: 84px !important;
      max-width: 100% !important;
      object-fit: contain !important;
      filter: drop-shadow(0 3px 10px rgba(0, 0, 0, 0.09)) !important;
    }

    .pill-btn {
      background: linear-gradient(145deg, rgba(142, 26, 98, 0.92) 0%, rgba(119, 30, 82, 0.90) 50%, rgba(96, 20, 66, 0.94) 100%) !important;
      backdrop-filter: blur(24px) saturate(190%) !important;
      -webkit-backdrop-filter: blur(24px) saturate(190%) !important;
      border: 1.5px solid rgba(255, 255, 255, 0.38) !important;
      box-shadow: 0 8px 22px rgba(68, 12, 48, 0.38), 0 2px 6px rgba(0, 0, 0, 0.16), inset 0 1.5px 1px 0 rgba(255, 255, 255, 0.55), inset 0 -1.5px 2px 0 rgba(0, 0, 0, 0.32) !important;
      border-radius: 9999px !important;
      overflow: hidden !important;
      display: inline-flex !important;
      align-items: center !important;
      justify-content: center !important;
      box-sizing: border-box !important;
      cursor: pointer !important;
      outline: none !important;
      text-decoration: none !important;
      transition: transform 0.22s cubic-bezier(0.34, 1.56, 0.64, 1), background 0.18s ease, box-shadow 0.18s ease !important;
    }

    .pill-btn:hover {
      background: linear-gradient(145deg, rgba(165, 34, 114, 0.95) 0%, rgba(138, 32, 96, 0.94) 50%, rgba(112, 22, 78, 0.96) 100%) !important;
      border-color: rgba(255, 255, 255, 0.62) !important;
      transform: translateY(-2px) scale(1.035) !important;
      box-shadow: 0 10px 28px rgba(68, 12, 48, 0.48), 0 3px 8px rgba(0, 0, 0, 0.22), inset 0 1.5px 1.5px 0 rgba(255, 255, 255, 0.75), inset 0 -1.5px 2px 0 rgba(0, 0, 0, 0.32) !important;
    }

    .pill-btn:active {
      background: linear-gradient(145deg, rgba(105, 24, 72, 0.95) 0%, rgba(85, 16, 58, 0.96) 100%) !important;
      transform: translateY(1px) scale(0.96) !important;
      box-shadow: 0 4px 12px rgba(68, 12, 48, 0.28), inset 0 1px 1px 0 rgba(255, 255, 255, 0.38) !important;
    }

    .pill-btn-text {
      color: #ffffff !important;
      font-family: 'Roboto', -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif !important;
      font-weight: 400 !important;
      letter-spacing: 0.5px !important;
      text-transform: none !important;
      pointer-events: none !important;
      user-select: none !important;
      line-height: 1 !important;
      text-shadow: 0 1px 2px rgba(0, 0, 0, 0.35) !important;
    }

    #screenHome .screen-content {
      position: relative !important;
      width: 100% !important;
      height: 100% !important;
      padding-bottom: max(16px, env(safe-area-inset-bottom, 20px)) !important;
      box-sizing: border-box !important;
      overflow: hidden !important;
      display: flex !important;
      flex-direction: column !important;
      z-index: 10 !important;
    }

    #screenHome .home-body {
      overflow-y: hidden !important;
      scrollbar-width: none !important;
      -ms-overflow-style: none !important;
    }
    #screenHome .home-body::-webkit-scrollbar {
      display: none !important;
      width: 0 !important;
      height: 0 !important;
    }

    .prep-search-wrapper {
      padding: 22px 0 16px 0 !important;
      position: absolute !important;
      top: 0 !important;
      left: 0 !important;
      right: 0 !important;
      z-index: 25 !important;
      pointer-events: none !important;
      display: flex !important;
      justify-content: center !important;
      width: 100% !important;
    }

    .prep-search-bar {
      pointer-events: auto !important;
    }

    .prep-top-fade {
      position: absolute !important;
      top: 0 !important;
      left: 0 !important;
      right: 0 !important;
      z-index: 20 !important;
      pointer-events: none !important;
    }

    .prep-top-fade.visible {
      opacity: 1 !important;
    }

    .prep-scroll-viewport {
      padding-top: 92px !important;
    }

    .prep-ribbon-wrapper {
      display: none !important;
    }

    /* Arrow Controls (No Drop Shadow) */
    .arrow-btn,
    .arrow-btn:hover {
      filter: none !important;
    }

    /* Bottom Bar - Light Translucent Liquid Glass Toolbar matching original brand color */
    .prep-bottom-bar, .game-bottom-bar, .games-bottom-bar {
      position: absolute !important;
      bottom: 0 !important;
      left: 0 !important;
      right: 0 !important;
      width: 100% !important;
      margin: 0 !important;
      padding: 0 !important;
      background: linear-gradient(180deg, rgba(255, 255, 255, 0.45) 0%, rgba(255, 255, 255, 0.15) 100%),
                  url('assets/Bottom_Toolbar_Background.png') center bottom / 100% 100% no-repeat !important;
      backdrop-filter: blur(24px) saturate(180%) !important;
      -webkit-backdrop-filter: blur(24px) saturate(180%) !important;
      border-top: 1px solid rgba(255, 255, 255, 0.75) !important;
      box-shadow: 0 -3px 14px rgba(0, 0, 0, 0.05), inset 0 1.5px 1px 0 rgba(255, 255, 255, 0.90) !important;
      display: flex !important;
      align-items: center !important;
      justify-content: center !important;
    }

    /* Disappearing bottom purple fade when nowhere left to scroll */
    .prep-bottom-fade.hidden,
    .games-bottom-fade.hidden {
      opacity: 0 !important;
      pointer-events: none !important;
    }

    /* Inactive screens must never intercept pointer events or display */
    .app-screen:not(.active),
    .app-screen:not(.active) * {
      pointer-events: none !important;
    }

    /* Games Screen: Edge-to-edge animated scrolling canvas with header pinned strictly to top */
    #screenGames {
      background-color: #f4f4f4 !important;
      background: #f4f4f4 !important;
      color: #39373b !important;
      overflow: hidden !important;
      position: absolute !important;
      inset: 0 !important;
      width: 100% !important;
      height: 100% !important;
    }

    .games-top-fade {
      position: absolute !important;
      top: 0 !important;
      left: 0 !important;
      right: 0 !important;
      height: 150px !important;
      background: linear-gradient(to bottom, 
        rgba(244, 244, 244, 1) 0%, 
        rgba(244, 244, 244, 1) 28%, 
        rgba(244, 244, 244, 0.88) 48%, 
        rgba(244, 244, 244, 0.55) 68%, 
        rgba(244, 244, 244, 0.18) 88%, 
        rgba(244, 244, 244, 0) 100%
      ) !important;
      pointer-events: none !important;
      z-index: 24 !important;
      opacity: 0 !important;
      transition: opacity 0.35s ease !important;
    }

    .games-top-fade.visible {
      opacity: 1 !important;
    }

    .games-bottom-fade {
      position: absolute !important;
      bottom: 0 !important;
      left: 0 !important;
      right: 0 !important;
      height: 215px !important;
      background: linear-gradient(to top, 
        rgba(244, 244, 244, 1) 0%, 
        rgba(244, 244, 244, 1) 28%, 
        rgba(244, 244, 244, 0.88) 48%, 
        rgba(244, 244, 244, 0.55) 68%, 
        rgba(244, 244, 244, 0.18) 88%, 
        rgba(244, 244, 244, 0) 100%
      ) !important;
      pointer-events: none !important;
      z-index: 24 !important;
      opacity: 1 !important;
      transition: opacity 0.35s ease !important;
    }

    #screenGames .screen-content {
      position: absolute !important;
      top: 0 !important;
      left: 0 !important;
      right: 0 !important;
      bottom: 0 !important;
      width: 100% !important;
      height: 100% !important;
      display: flex !important;
      flex-direction: column !important;
      justify-content: flex-start !important;
      align-items: stretch !important;
      pointer-events: none !important;
      z-index: 25 !important;
    }

    #screenGames #gamesHeader {
      pointer-events: auto !important;
      flex-shrink: 0 !important;
      width: 100% !important;
      position: relative !important;
      z-index: 30 !important;
    }

    #screenGames .games-scroll-container {
      pointer-events: auto !important;
    }

    #screenGames .games-scroll-viewport {
      pointer-events: auto !important;
    }

    /* Child Life Zone Jigsaw Puzzle Overrides */
    #screenCLZPuzzle {
      display: none;
      position: absolute !important;
      inset: 0 !important;
      width: 100% !important;
      height: 100% !important;
      background: #591a3f !important;
      background-color: #591a3f !important;
      background-image: url('assets/PuzzleGameBG.png') !important;
      background-size: cover !important;
      background-position: center !important;
      background-repeat: no-repeat !important;
    }

    #screenCLZPuzzle.active {
      display: flex !important;
    }

    #screenCLZPuzzle:not(.active),
    #screenCLZPuzzle:not(.active) * {
      display: none !important;
      pointer-events: none !important;
      visibility: hidden !important;
    }

    #screenCLZPuzzle.active #puzzleHeader,
    #screenCLZPuzzle.active #puzzleTopBar {
      pointer-events: auto !important;
      flex-shrink: 0 !important;
      width: 100% !important;
    }

    #screenCLZPuzzle.active .puzzle-controls-container,
    #screenCLZPuzzle.active .puzzle-main-stage,
    #screenCLZPuzzle.active .puzzle-diff-btn,
    #screenCLZPuzzle.active .puzzle-tool-btn,
    #screenCLZPuzzle.active .puzzle-tray-card {
      pointer-events: auto !important;
    }

    /* Matching Memory Game Overrides */
    #screenMatchingGame {
      display: none;
      position: absolute !important;
      inset: 0 !important;
      width: 100% !important;
      height: 100% !important;
      background-image: url('assets/MatchingGameBG.png') !important;
      background-size: cover !important;
      background-position: center !important;
      background-repeat: no-repeat !important;
      background-color: #651b46 !important;
    }

    #screenMatchingGame .matching-controls-group .puzzle-diff-btn.active {
      color: #7b0350 !important;
    }

    #screenMatchingGame.active {
      display: flex !important;
      flex-direction: column !important;
      z-index: 10 !important;
    }

    #screenMatchingGame:not(.active),
    #screenMatchingGame:not(.active) * {
      display: none !important;
      pointer-events: none !important;
      visibility: hidden !important;
    }

    #screenMatchingGame.active #matchingTopBar {
      pointer-events: auto !important;
      flex-shrink: 0 !important;
      width: 100% !important;
    }

    /* Rebranded Liquid Glass White Top Navigation Buttons on Card Match & Puzzle Games */
    #screenCLZPuzzle .game-top-btn,
    #screenMatchingGame .game-top-btn {
      background: linear-gradient(135deg, rgba(255, 255, 255, 0.92) 0%, rgba(255, 255, 255, 0.78) 100%) !important;
      backdrop-filter: blur(20px) saturate(180%) !important;
      -webkit-backdrop-filter: blur(20px) saturate(180%) !important;
      border: 1.5px solid rgba(255, 255, 255, 0.90) !important;
      box-shadow: 0 4px 14px rgba(0, 0, 0, 0.20), inset 0 1px 1px 0 rgba(255, 255, 255, 0.95), inset 0 -1px 2px 0 rgba(0, 0, 0, 0.05) !important;
      color: #7b0350 !important;
      font-size: 14px !important;
      font-weight: 800 !important;
      padding: 7px 16px !important;
      border-radius: 999px !important;
      cursor: pointer !important;
      transition: background 0.18s ease, transform 0.20s cubic-bezier(0.34, 1.56, 0.64, 1), box-shadow 0.18s ease, border-color 0.18s ease, color 0.18s ease !important;
    }

    #screenCLZPuzzle .game-top-btn:hover,
    #screenMatchingGame .game-top-btn:hover {
      background: rgba(255, 255, 255, 0.98) !important;
      border-color: #ffffff !important;
      color: #5d023c !important;
      transform: scale(1.05) !important;
      box-shadow: 0 6px 20px rgba(0, 0, 0, 0.25), inset 0 1.5px 1px 0 #ffffff !important;
    }

    #screenCLZPuzzle .game-top-btn:active,
    #screenMatchingGame .game-top-btn:active {
      background: rgba(255, 255, 255, 0.82) !important;
      transform: scale(0.95) !important;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15), inset 0 1px 2px 0 rgba(0, 0, 0, 0.08) !important;
    }

    #screenCLZPuzzle .game-top-btn svg,
    #screenMatchingGame .game-top-btn svg {
      color: #7b0350 !important;
      stroke: #7b0350 !important;
      filter: none !important;
    }

    #screenCLZPuzzle .game-top-btn:hover svg,
    #screenMatchingGame .game-top-btn:hover svg {
      color: #5d023c !important;
      stroke: #5d023c !important;
    }

    #screenCLZPuzzle .game-top-btn-icon,
    #screenMatchingGame .game-top-btn-icon {
      background: linear-gradient(135deg, rgba(255, 255, 255, 0.92) 0%, rgba(255, 255, 255, 0.78) 100%) !important;
      backdrop-filter: blur(20px) saturate(180%) !important;
      -webkit-backdrop-filter: blur(20px) saturate(180%) !important;
      border: 1.5px solid rgba(255, 255, 255, 0.90) !important;
      box-shadow: 0 4px 14px rgba(0, 0, 0, 0.20), inset 0 1px 1px 0 rgba(255, 255, 255, 0.95), inset 0 -1px 2px 0 rgba(0, 0, 0, 0.05) !important;
      color: #7b0350 !important;
      width: 36px !important;
      height: 36px !important;
      border-radius: 50% !important;
      cursor: pointer !important;
      transition: background 0.18s ease, transform 0.20s cubic-bezier(0.34, 1.56, 0.64, 1), box-shadow 0.18s ease, border-color 0.18s ease, color 0.18s ease !important;
    }

    #screenCLZPuzzle .game-top-btn-icon:hover,
    #screenMatchingGame .game-top-btn-icon:hover {
      background: rgba(255, 255, 255, 0.98) !important;
      border-color: #ffffff !important;
      color: #5d023c !important;
      transform: scale(1.08) !important;
      box-shadow: 0 6px 20px rgba(0, 0, 0, 0.25), inset 0 1.5px 1px 0 #ffffff !important;
    }

    #screenCLZPuzzle .game-top-btn-icon:active,
    #screenMatchingGame .game-top-btn-icon:active {
      background: rgba(255, 255, 255, 0.82) !important;
      transform: scale(0.94) !important;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15), inset 0 1px 2px 0 rgba(0, 0, 0, 0.08) !important;
    }

    #screenCLZPuzzle .game-top-btn-icon svg,
    #screenMatchingGame .game-top-btn-icon svg {
      color: #7b0350 !important;
      filter: none !important;
    }

    #screenCLZPuzzle .game-top-btn-icon:hover svg,
    #screenMatchingGame .game-top-btn-icon:hover svg {
      color: #5d023c !important;
    }

    #screenCLZPuzzle .game-top-btn-icon svg path,
    #screenCLZPuzzle .game-top-btn-icon svg polygon,
    #screenCLZPuzzle .game-top-btn-icon svg line,
    #screenMatchingGame .game-top-btn-icon svg path,
    #screenMatchingGame .game-top-btn-icon svg polygon,
    #screenMatchingGame .game-top-btn-icon svg line {
      stroke: inherit;
      fill: inherit;
    }

    #screenCLZPuzzle .game-top-btn-icon svg[fill="currentColor"],
    #screenMatchingGame .game-top-btn-icon svg[fill="currentColor"] {
      fill: #7b0350 !important;
    }

    #screenCLZPuzzle .game-top-btn-icon:hover svg[fill="currentColor"],
    #screenMatchingGame .game-top-btn-icon:hover svg[fill="currentColor"] {
      fill: #5d023c !important;
    }

    #screenCLZPuzzle .game-top-btn-icon svg[fill="currentColor"] path,
    #screenMatchingGame .game-top-btn-icon svg[fill="currentColor"] path {
      fill: #7b0350 !important;
    }

    #screenCLZPuzzle .game-top-btn-icon:hover svg[fill="currentColor"] path,
    #screenMatchingGame .game-top-btn-icon:hover svg[fill="currentColor"] path {
      fill: #5d023c !important;
    }

    #screenCLZPuzzle .sound-toggle-btn.muted,
    #screenMatchingGame .sound-toggle-btn.muted {
      background: linear-gradient(135deg, rgba(255, 235, 240, 0.94) 0%, rgba(255, 220, 230, 0.85) 100%) !important;
      color: #b91c1c !important;
      border-color: rgba(239, 68, 68, 0.50) !important;
    }

    #screenCLZPuzzle .sound-toggle-btn.muted svg,
    #screenMatchingGame .sound-toggle-btn.muted svg {
      color: #b91c1c !important;
      stroke: #b91c1c !important;
    }

    #screenCLZPuzzle .puzzle-difficulty-selector,
    #screenMatchingGame .puzzle-difficulty-selector {
      background: rgba(255, 255, 255, 0.18) !important;
      border: 1px solid rgba(255, 255, 255, 0.35) !important;
      box-shadow: 0 4px 14px rgba(0, 0, 0, 0.20) !important;
    }

    #screenCLZPuzzle .puzzle-diff-btn.active,
    #screenMatchingGame .puzzle-diff-btn.active {
      background: linear-gradient(135deg, rgba(255, 255, 255, 0.98) 0%, rgba(255, 255, 255, 0.88) 100%) !important;
      color: #7b0350 !important;
      box-shadow: 0 3px 10px rgba(0, 0, 0, 0.25), inset 0 1px 1px #ffffff !important;
    }

    #screenCLZPuzzle .puzzle-tool-btn {
      background: rgba(255, 255, 255, 0.18) !important;
      border: 1px solid rgba(255, 255, 255, 0.35) !important;
      box-shadow: 0 4px 14px rgba(0, 0, 0, 0.20) !important;
      color: rgba(255, 255, 255, 0.90) !important;
      font-size: 13.5px !important;
      font-weight: 800 !important;
      padding: 6px 16px !important;
      border-radius: 999px !important;
      cursor: pointer !important;
      transition: background 0.18s ease, transform 0.20s cubic-bezier(0.34, 1.56, 0.64, 1), box-shadow 0.18s ease, border-color 0.18s ease, color 0.18s ease !important;
    }

    #screenCLZPuzzle .puzzle-tool-btn:hover {
      background: rgba(255, 255, 255, 0.28) !important;
      border-color: rgba(255, 255, 255, 0.55) !important;
      color: #ffffff !important;
      transform: scale(1.04) !important;
    }

    #screenCLZPuzzle .puzzle-tool-btn:active {
      transform: scale(0.96) !important;
    }

    #screenCLZPuzzle .puzzle-tool-btn.active {
      background: linear-gradient(135deg, rgba(255, 255, 255, 0.98) 0%, rgba(255, 255, 255, 0.88) 100%) !important;
      color: #7b0350 !important;
      border: 1px solid rgba(255, 255, 255, 0.90) !important;
      box-shadow: 0 3px 10px rgba(0, 0, 0, 0.25), inset 0 1px 1px #ffffff !important;
    }

    .matching-btn-primary {
      background: linear-gradient(135deg, #6bb5a3 0%, #5fa08f 48%, #478b7b 100%) !important;
      color: #ffffff !important;
      box-shadow: 0 4px 14px rgba(71, 139, 123, 0.40) !important;
      text-shadow: 0 1px 2px rgba(0, 0, 0, 0.16) !important;
    }

    .matching-btn-primary:hover {
      background: linear-gradient(135deg, #78bfae 0%, #5fa08f 48%, #4f9686 100%) !important;
      box-shadow: 0 6px 18px rgba(71, 139, 123, 0.50) !important;
    }

    .matching-btn-primary:active {
      transform: scale(0.96) !important;
      box-shadow: 0 2px 8px rgba(71, 139, 123, 0.35) !important;
    }

    /* Matching Game Completion Celebration Card Typography - Clean Neutral */
    #screenMatchingGame .matching-success-desc {
      color: #222222 !important;
    }

    #screenMatchingGame .matching-btn-outline {
      color: #000000 !important;
      border: 2px solid #000000 !important;
    }

    #screenMatchingGame .matching-btn-outline:hover {
      background: rgba(0, 0, 0, 0.06) !important;
    }

    #screenMatchingGame.active .matching-game-stage,
    #screenMatchingGame.active .matching-card {
      pointer-events: auto !important;
    }

    /* Nasogastric Tube (NG Tube) Procedure Overrides */
    #screenNGTube {
      background-color: #112529 !important;
    }

    #screenNGTube.active {
      display: block !important;
      opacity: 1 !important;
      pointer-events: auto !important;
      z-index: 10 !important;
    }

    #screenNGTube.active .ng-tube-content {
      position: relative !important;
      display: block !important;
      width: 100% !important;
      height: 100% !important;
      overflow: hidden !important;
    }

    #screenNGTube.active .game-top-bar button,
    #screenNGTube.active .ng-tube-top-prompt-bar,
    #screenNGTube.active .ng-tube-stage-wrapper,
    #screenNGTube.active .ng-tube-stage {
      pointer-events: auto !important;
    }

    /* Port Access Procedure Overrides */
    #screenPortAccess {
      background: linear-gradient(180deg, #8e97a1 0%, #768492 100%) !important;
    }

    body:has(#screenPortAccess.active) {
      background: #7d8b98 !important;
    }

    body:has(#screenPortAccess.active) .device-screen {
      background: #7d8b98 !important;
    }

    #screenPortAccess.active {
      display: block !important;
      opacity: 1 !important;
      pointer-events: auto !important;
      z-index: 10 !important;
    }

    #screenPortAccess.active .port-access-content {
      position: relative !important;
      display: block !important;
      width: 100% !important;
      height: 100% !important;
      overflow: hidden !important;
    }

    #screenPortAccess.active .game-top-bar button,
    #screenPortAccess.active .port-access-top-prompt-bar,
    #screenPortAccess.active .port-access-stage-wrapper,
    #screenPortAccess.active .port-access-stage,
    #screenPortAccess.active .port-access-stage *,
    #screenPortAccess.active .port-timer-modal,
    #screenPortAccess.active .port-timer-modal *,
    #screenPortAccess.active .port-victory-overlay,
    #screenPortAccess.active .port-victory-overlay * {
      pointer-events: auto !important;
    }

    .bottom-bar-tabs {
      display: flex !important;
      width: 100% !important;
      height: 100% !important;
      max-width: 1366px !important;
      margin: 0 auto !important;
      align-items: center !important;
      justify-content: space-between !important;
      gap: 4px !important;
      padding: 0 4px !important;
      box-sizing: border-box !important;
    }

    .bottom-tab-btn {
      flex: 1 !important;
      height: 100% !important;
      max-height: 92px !important;
      display: flex !important;
      align-items: center !important;
      justify-content: center !important;
      background: transparent !important;
      border: none !important;
      padding: 2px 0 !important;
      cursor: pointer !important;
      position: relative !important;
    }

    .bottom-tab-btn img {
      width: 100% !important;
      height: 100% !important;
      object-fit: fill !important;
      display: block !important;
      transition: filter 0.22s ease, transform 0.20s cubic-bezier(0.34, 1.56, 0.64, 1) !important;
    }

    .bottom-tab-btn.active img {
      filter: drop-shadow(0 4px 12px rgba(71, 139, 123, 0.40)) drop-shadow(0 1px 3px rgba(0, 0, 0, 0.15)) !important;
    }

    .bottom-tab-btn:hover img {
      filter: drop-shadow(0 4px 14px rgba(71, 139, 123, 0.35)) brightness(1.05) !important;
      transform: scale(1.015) !important;
    }

    .bottom-tab-btn:active img {
      transform: scale(0.985) !important;
      filter: drop-shadow(0 2px 6px rgba(71, 139, 123, 0.25)) !important;
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
            reg.addEventListener('updatefound', () => {
              const newWorker = reg.installing;
              if (newWorker) {
                newWorker.addEventListener('statechange', () => {
                  if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
                    console.log('New Riley PWA version installed, reloading...');
                    window.location.reload();
                  }
                });
              }
            });
          })
          .catch(err => console.warn('ServiceWorker registration error:', err));
      });

      let refreshing = false;
      let hadController = Boolean(navigator.serviceWorker.controller);
      navigator.serviceWorker.addEventListener('controllerchange', () => {
        if (!hadController) {
          hadController = true;
          return;
        }
        if (!refreshing) {
          refreshing = true;
          console.log('ServiceWorker controller changed, refreshing to activate new assets...');
          window.location.reload();
        }
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
  <meta name="theme-color" content="#d4d7db" />
  <meta name="apple-mobile-web-app-capable" content="yes" />
  <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />
  <meta name="apple-mobile-web-app-title" content="Riley" />
  <link rel="apple-touch-icon" href="./assets/icons/apple-touch-icon.png" />
  <link rel="icon" type="image/png" sizes="192x192" href="./assets/icons/icon-192.png" />
  <link rel="icon" type="image/png" sizes="512x512" href="./assets/icons/icon-512.png" />

  <!-- Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet" />

  <style>
{css.strip()}
  </style>
</head>
<body class="home-active">
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
    bump_service_worker()
    sync_assets()
    build_distribution()
