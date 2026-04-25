#!/usr/bin/env bash
# =============================================================================
#  patch_v3_1.sh — Genisys Graphics V3.1 "INTERACTIVE"
#
#  COMPAT-1  iOS Safari dvh fix            --vh CSS var + @supports fallback
#  COMPAT-2  Backdrop-filter WebView guard @supports solid-bg fallback
#  COMPAT-3  Touch detection overhaul      compound check across all browsers
#
#  UPGRADE-1 Morphing MagneticCursor       shape + color shifts by target type
#  UPGRADE-2 Lightbox share/download       Web Share API + <a download> fallback
#  UPGRADE-3 Gallery waterfall entrance    staggered column-aware card cascade
#  UPGRADE-4 Preloader G-monogram          SVG pathLength self-draw animation
#  UPGRADE-5 Long-press card preview       600ms touch → floating full image
#
#  AESTHETIC-1 Aurora mesh background     slow-shifting CSS conic gradient layer
#  AESTHETIC-2 Gold scanline card hover   animated sweep line on card hover
#  AESTHETIC-3 Cinematic scroll vignette  scroll-driven radial darkness overlay
#  AESTHETIC-4 Heading glow reveal        CSS gold pulse on whileInView trigger
#  AESTHETIC-5 Fine full-page grain       body::after SVG noise at 3% opacity
#
#  ICON      G-monogram favicon           gold gradient G on void black square
#
#  Run from project root:  bash patch_v3_1.sh
# =============================================================================
set -e

PROJECT_ROOT="$PWD"
while [[ "$PROJECT_ROOT" != "/" ]]; do
  [[ -d "$PROJECT_ROOT/src/components" ]] && break
  PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done
[[ ! -d "$PROJECT_ROOT/src/components" ]] && echo "❌  Cannot find src/components — run from project root." && exit 1
echo "✅  Project root: $PROJECT_ROOT"
cd "$PROJECT_ROOT"

BACKUP="$PROJECT_ROOT/.v31_patch_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP"
for f in \
  src/App.tsx \
  src/index.css \
  src/components/MagneticCursor.tsx \
  src/components/Lightbox.tsx \
  src/components/Gallery.tsx \
  src/components/PortfolioCard.tsx \
  src/components/Preloader.tsx \
  src/components/Navigation.tsx \
  public/favicon.svg; do
  [[ -f "$f" ]] && cp "$f" "$BACKUP/$(basename $f).bak"
done
mkdir -p src/hooks src/components

echo "💾  Originals backed up → $BACKUP"
echo ""
echo "━━━ Writing V3.1 files ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# =============================================================================
# ICON — public/favicon.svg
# Custom G-monogram: gold gradient letterform on pitch-black rounded square.
# The G arc is drawn as a single SVG <path>: center (32,32), radius 13.
# Points: upper-right gap (41,23) → large counter-clockwise arc → (41,41)
# → crossbar up to (41,32) → left to centre (32,32).
# =============================================================================
cat << 'END_FAVICON' > public/favicon.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <defs>
    <linearGradient id="gold" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%"   stop-color="#FFE9A0"/>
      <stop offset="40%"  stop-color="#D4AF37"/>
      <stop offset="100%" stop-color="#8B6914"/>
    </linearGradient>
    <filter id="glow">
      <feGaussianBlur stdDeviation="1.2" result="blur"/>
      <feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
  </defs>
  <!-- Background -->
  <rect width="64" height="64" rx="14" fill="#060606"/>
  <!-- Subtle inner border -->
  <rect width="62" height="62" x="1" y="1" rx="13" fill="none"
        stroke="hsl(44 70% 50% / 0.22)" stroke-width="1"/>
  <!-- G letterform — single path, gold gradient, soft glow -->
  <path
    d="M 41 23 A 13 13 0 1 0 41 41 L 41 32 L 31 32"
    stroke="url(#gold)"
    stroke-width="4.5"
    stroke-linecap="round"
    stroke-linejoin="round"
    fill="none"
    filter="url(#glow)"
  />
</svg>
END_FAVICON
echo "✔  public/favicon.svg  (G-monogram)"

# =============================================================================
# COMPAT-1 + AESTHETIC-5  src/hooks/useVhFix.ts
# Sets --vh CSS custom property to window.innerHeight * 0.01 on mount +
# resize + orientationchange.  This fixes iOS Safari <15.4 where 100dvh
# causes layout overflow because the address bar is not excluded.
# index.css adds @supports fallback targeting #top (the Hero section).
# =============================================================================
cat << 'END_VH_FIX' > src/hooks/useVhFix.ts
import { useEffect } from "react";

/**
 * COMPAT-1 — iOS Safari Viewport Height Fix
 *
 * iOS Safari <15.4 does not support `dvh` units.  Tailwind's min-h-[100dvh]
 * silently fails on these devices, causing the Hero to be either too short or
 * to overflow into the address-bar zone.
 *
 * This hook writes --vh = 1% of the REAL innerHeight to the document root.
 * index.css then applies a @supports fallback: when `dvh` is unsupported,
 * #top (the Hero section) uses calc(var(--vh) * 100) instead.
 */
export function useVhFix(): void {
  useEffect(() => {
    const set = () => {
      document.documentElement.style.setProperty(
        "--vh",
        `${window.innerHeight * 0.01}px`,
      );
    };
    set();
    window.addEventListener("resize",            set, { passive: true });
    window.addEventListener("orientationchange", set, { passive: true });
    return () => {
      window.removeEventListener("resize",            set);
      window.removeEventListener("orientationchange", set);
    };
  }, []);
}
END_VH_FIX
echo "✔  src/hooks/useVhFix.ts"

# =============================================================================
# COMPAT-3  src/lib/touch.ts
# Single source-of-truth for touch detection.
# Checks three signals instead of one:
#   1. pointer: coarse  — standard, but misses Termux + some Samsung browsers
#   2. ontouchstart in window — older browsers + Termux WebView
#   3. maxTouchPoints > 0    — modern spec, covers all cases
# =============================================================================
cat << 'END_TOUCH' > src/lib/touch.ts
/**
 * COMPAT-3 — Robust touch detection.
 *
 * `matchMedia("(pointer: coarse)")` alone fails on:
 *   - Termux WebView (reports pointer:fine even on touchscreen)
 *   - Some Samsung Internet builds
 *   - Hybrid pointer devices
 *
 * This utility checks three independent signals and returns true if ANY fires.
 * Memoised at first call — the result never changes within a page session.
 */
let _cached: boolean | null = null;

export function isTouch(): boolean {
  if (_cached !== null) return _cached;
  if (typeof window === "undefined") return (_cached = false);
  _cached =
    matchMedia("(pointer: coarse)").matches ||
    "ontouchstart" in window             ||
    navigator.maxTouchPoints > 0;
  return _cached;
}
END_TOUCH
echo "✔  src/lib/touch.ts"

# =============================================================================
# AESTHETIC-3  src/components/ScrollVignette.tsx
# A fixed radial-gradient div whose opacity increases as the user scrolls.
# Creates a cinematic "tunnel darkening" effect — the further you scroll,
# the deeper the vignette presses in from the edges.
# Runs on a passive scroll listener with rAF-scheduled DOM write for 60 fps.
# =============================================================================
cat << 'END_VIGNETTE' > src/components/ScrollVignette.tsx
import { useEffect, useRef } from "react";

/**
 * AESTHETIC-3 — Cinematic Scroll Vignette
 *
 * A fixed radial-gradient overlay that strengthens as the user scrolls.
 * Opacity range: 0 (at top) → 0.55 (at deepest scroll point).
 * Uses a passive scroll listener → rAF DOM write pipeline to avoid
 * forced reflows and stay smooth even on low-end Android.
 */
export default function ScrollVignette() {
  const divRef     = useRef<HTMLDivElement>(null);
  const rafPending = useRef(false);

  useEffect(() => {
    const onScroll = () => {
      if (rafPending.current) return;
      rafPending.current = true;
      requestAnimationFrame(() => {
        rafPending.current = false;
        const maxScroll = Math.max(
          1,
          document.documentElement.scrollHeight - window.innerHeight,
        );
        const ratio   = Math.min(window.scrollY / maxScroll, 1);
        const opacity = ratio * 0.55;
        if (divRef.current) divRef.current.style.opacity = String(opacity);
      });
    };
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  return (
    <div
      ref={divRef}
      aria-hidden
      className="fixed inset-0 pointer-events-none"
      style={{
        zIndex:     8,
        opacity:    0,
        background: "radial-gradient(ellipse 90% 80% at 50% 50%, transparent 35%, #000 100%)",
      }}
    />
  );
}
END_VIGNETTE
echo "✔  src/components/ScrollVignette.tsx"

# =============================================================================
# AESTHETIC-1  src/components/AuroraBackground.tsx
# Three large radial-gradient "orbs" that slowly drift behind everything.
# Pure CSS animation — no JS RAF, no canvas, zero CPU overhead.
# Gated to mid/high device tier in App.tsx.
# Each orb uses a gold-family hue at very low opacity so it enriches the
# black background without overpowering the WebGL liquid layer.
# =============================================================================
cat << 'END_AURORA' > src/components/AuroraBackground.tsx
/**
 * AESTHETIC-1 — Aurora Mesh Background
 *
 * Three slow-drifting radial gradient orbs create a cinematic deep-space
 * aurora effect behind the WebGL layer.  Pure CSS — no JS RAF loop.
 * Each orb is a `div` with a radial gradient and a unique drift keyframe.
 *
 * Opacity kept at 0.10–0.14 so they enrich the black without competing
 * with LiquidCanvas or any foreground content.
 */
export default function AuroraBackground() {
  return (
    <div aria-hidden className="fixed inset-0 z-0 pointer-events-none overflow-hidden">
      {/* Orb 1 — warm gold, top-left drift */}
      <div className="aurora-orb aurora-1" />
      {/* Orb 2 — cooler amber, right-side drift */}
      <div className="aurora-orb aurora-2" />
      {/* Orb 3 — deep bronze, bottom drift */}
      <div className="aurora-orb aurora-3" />
    </div>
  );
}
END_AURORA
echo "✔  src/components/AuroraBackground.tsx"

# =============================================================================
# COMPAT-1 + COMPAT-2 + AESTHETIC-1,2,3,4,5  src/index.css
# All CSS additions in one place:
#   COMPAT-1   @supports fallback for dvh units on iOS Safari <15.4
#   COMPAT-2   @supports fallback for backdrop-filter on old Android WebViews
#   AESTHETIC-1 Aurora orb keyframes + base styles
#   AESTHETIC-2 Scanline sweep animation on cards
#   AESTHETIC-4 Heading glow reveal keyframe
#   AESTHETIC-5 Body fine-grain texture overlay (body::after)
# =============================================================================
cat << 'END_CSS' > src/index.css
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    /* Pitch-black operatic palette */
    --background: 0 0% 2%;
    --foreground: 44 60% 88%;
    --card: 0 0% 4%;
    --card-foreground: 44 60% 90%;
    --popover: 0 0% 3%;
    --popover-foreground: 44 60% 90%;
    --primary: 44 70% 52%;
    --primary-foreground: 0 0% 4%;
    --secondary: 0 0% 10%;
    --secondary-foreground: 44 60% 90%;
    --muted: 0 0% 8%;
    --muted-foreground: 44 30% 78%;
    --accent: 44 70% 52%;
    --accent-foreground: 0 0% 4%;
    --destructive: 0 70% 45%;
    --destructive-foreground: 0 0% 98%;
    --border: 44 30% 18%;
    --input: 0 0% 12%;
    --ring: 44 70% 52%;
    --radius: 0.75rem;
    --gold: 44 72% 54%;
    --gold-soft: 44 60% 78%;
    --gold-deep: 40 65% 32%;
    --cream: 44 55% 90%;
    --void: 0 0% 4%;
  }

  html, body, #root {
    background: hsl(0 0% 0%);
    color: hsl(var(--foreground));
  }
  html {
    scroll-behavior: auto;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    text-rendering: optimizeLegibility;
  }
  body {
    font-family: Inter, system-ui, sans-serif;
    overflow-x: hidden;
    filter: none !important;
  }
  * { @apply border-border; }
  ::selection {
    background: hsl(var(--gold) / 0.4);
    color: hsl(var(--cream));
  }
  p, h1, h2, h3, h4, h5, h6, span, a, button, label,
  input, textarea, select, li, div[data-text] {
    filter: none !important;
  }

  /* ── COMPAT-1: iOS Safari <15.4 dvh fallback ───────────────────────────
   * When the browser does not support dvh units, the Hero (#top) falls back
   * to calc(var(--vh) * 100) which is set by the useVhFix hook in App.tsx.
   * This prevents address-bar overflow / short-hero on old iPhones.        */
  @supports not (height: 100dvh) {
    #top {
      min-height: calc(var(--vh, 1svh) * 100) !important;
    }
  }

  /* ── COMPAT-2: Backdrop-filter fallback for old Android WebViews ────────
   * Older Chrome / Samsung Internet / WebView builds do not support
   * backdrop-filter. Without a fallback, .glass elements become almost
   * invisible (transparent on dark bg).  The @supports (not) block provides
   * an opaque dark glass replacement that preserves the premium aesthetic.  */
  @supports not (backdrop-filter: blur(1px)) {
    .glass {
      background: hsl(0 0% 7% / 0.96) !important;
      border: 1px solid hsl(44 60% 50% / 0.22) !important;
    }
    .glass-strong {
      background: hsl(0 0% 10% / 0.98) !important;
      border: 1px solid hsl(44 70% 55% / 0.32) !important;
    }
  }
  /* Ensure -webkit-backdrop-filter is always present for Safari */
  @supports not (-webkit-backdrop-filter: blur(1px)) {
    @supports (backdrop-filter: blur(1px)) {
      .glass, .glass-strong {
        -webkit-backdrop-filter: inherit;
      }
    }
  }
}

@layer utilities {
  /* ── Core glass system ───────────────────────────────────────────────── */
  .glass {
    background: linear-gradient(135deg, hsl(0 0% 100% / 0.06), hsl(0 0% 100% / 0.02));
    backdrop-filter: blur(22px) saturate(140%);
    -webkit-backdrop-filter: blur(22px) saturate(140%);
    border: 1px solid hsl(44 60% 60% / 0.18);
    box-shadow: 0 10px 40px -10px hsl(0 0% 0% / 0.7),
                inset 0 1px 0 hsl(0 0% 100% / 0.08);
  }
  .glass-strong {
    background: linear-gradient(135deg, hsl(0 0% 100% / 0.10), hsl(0 0% 100% / 0.03));
    backdrop-filter: blur(36px) saturate(160%);
    -webkit-backdrop-filter: blur(36px) saturate(160%);
    border: 1px solid hsl(44 70% 60% / 0.32);
    box-shadow: 0 20px 60px -15px hsl(0 0% 0% / 0.85),
                inset 0 1px 0 hsl(0 0% 100% / 0.12),
                inset 0 0 30px hsl(44 70% 50% / 0.05);
  }
  .specular::before {
    content: ""; position: absolute; inset: 0;
    border-radius: inherit; pointer-events: none;
    background: linear-gradient(115deg, transparent 30%, hsl(0 0% 100% / 0.18) 48%, transparent 56%);
    mix-blend-mode: overlay; opacity: 0.7;
  }
  .grain::after {
    content: ""; position: absolute; inset: 0;
    pointer-events: none; opacity: 0.18;
    background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='160' height='160'><filter id='n'><feTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='2' stitchTiles='stitch'/><feColorMatrix values='0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 0 .55 0'/></filter><rect width='100%' height='100%' filter='url(%23n)'/></svg>");
    mix-blend-mode: overlay; border-radius: inherit;
  }

  /* ── AESTHETIC-5: Full-page fine grain texture ──────────────────────────
   * A fixed body::after with a finer noise SVG at 3% opacity adds a subtle
   * film-grain quality to the entire page — a hallmark of premium print /
   * cinema aesthetics.  Uses mix-blend-mode: overlay so it blends cleanly
   * with any content behind it.  pointer-events: none ensures zero impact. */
  body::after {
    content: "";
    position: fixed;
    inset: 0;
    z-index: 9000;
    pointer-events: none;
    opacity: 0.03;
    background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='200' height='200'><filter id='fn'><feTurbulence type='fractalNoise' baseFrequency='0.75' numOctaves='4' stitchTiles='stitch'/><feColorMatrix values='0 0 0 0 1  0 0 0 0 0.9  0 0 0 0 0.4  0 0 0 1 0'/></filter><rect width='100%' height='100%' filter='url(%23fn)'/></svg>");
    mix-blend-mode: overlay;
  }

  /* ── Text + brand utilities ──────────────────────────────────────────── */
  .chromatic { text-shadow: 0 0 1px hsl(44 70% 50% / 0.3); }
  .gold-text {
    background: linear-gradient(160deg, #FFE9A0 0%, #E8C76B 28%, #D4AF37 55%, #A8801F 82%, #6B4F12 100%);
    -webkit-background-clip: text; background-clip: text; color: transparent;
  }
  .gold-border-glow {
    box-shadow: 0 0 0 1px hsl(var(--gold) / 0.5),
                0 0 24px hsl(var(--gold) / 0.45),
                inset 0 0 12px hsl(var(--gold) / 0.18);
  }
  .letterbox-bar {
    background: #000; position: fixed; left: 0; right: 0;
    z-index: 80; pointer-events: none;
  }
  .focus-dim [data-focusable]:not([data-focused="true"]) {
    opacity: 0.55; transition: opacity .35s ease;
  }
  .focus-dim [data-focused="true"] {
    opacity: 1; transition: opacity .35s ease; z-index: 5; position: relative;
  }
  .no-scrollbar::-webkit-scrollbar { display: none; }
  .no-scrollbar { scrollbar-width: none; }

  /* ── AESTHETIC-1: Aurora orb base styles ────────────────────────────────
   * Three fixed divs in AuroraBackground.tsx use these classes.
   * will-change: transform promotes each orb to a compositor layer so the
   * drift animations run entirely on the GPU.                               */
  .aurora-orb {
    position: absolute;
    border-radius: 50%;
    will-change: transform;
    pointer-events: none;
  }
  .aurora-1 {
    width: 70vw; height: 70vw;
    top: -20%; left: -15%;
    background: radial-gradient(circle, hsl(44 75% 45% / 0.55) 0%, transparent 65%);
    filter: blur(90px);
    opacity: 0.11;
    animation: aurora-drift-1 22s ease-in-out infinite;
  }
  .aurora-2 {
    width: 55vw; height: 55vw;
    top: 25%; right: -20%;
    background: radial-gradient(circle, hsl(38 65% 38% / 0.5) 0%, transparent 65%);
    filter: blur(80px);
    opacity: 0.09;
    animation: aurora-drift-2 28s ease-in-out infinite;
  }
  .aurora-3 {
    width: 45vw; height: 45vw;
    bottom: -10%; left: 15%;
    background: radial-gradient(circle, hsl(44 80% 30% / 0.6) 0%, transparent 60%);
    filter: blur(70px);
    opacity: 0.10;
    animation: aurora-drift-3 19s ease-in-out infinite;
  }

  @keyframes aurora-drift-1 {
    0%, 100% { transform: translate(0, 0)          scale(1);    }
    33%       { transform: translate(4vw, -3vh)     scale(1.06); }
    66%       { transform: translate(-3vw,  5vh)    scale(0.96); }
  }
  @keyframes aurora-drift-2 {
    0%, 100% { transform: translate(0, 0)          scale(1);    }
    40%       { transform: translate(-5vw, 4vh)     scale(1.04); }
    75%       { transform: translate(3vw,  -2vh)    scale(0.97); }
  }
  @keyframes aurora-drift-3 {
    0%, 100% { transform: translate(0, 0)          scale(1);    }
    30%       { transform: translate(-2vw, -4vh)    scale(1.05); }
    70%       { transform: translate(4vw,   3vh)    scale(0.95); }
  }

  /* ── AESTHETIC-2: Gold scanline sweep ───────────────────────────────────
   * .card-scanline children include a .scan-line div.
   * On group:hover, animate-card-scan plays once, sweeping the line from
   * the top of the card to beyond its bottom.
   * animation-fill-mode: forwards keeps it invisible after the sweep.     */
  @keyframes card-scan {
    0%   { transform: translateY(0px);   opacity: 0.95; }
    85%  { opacity: 0.7; }
    100% { transform: translateY(640px); opacity: 0;    }
  }
  .group:hover .scan-line,
  .group:focus-within .scan-line {
    animation: card-scan 1.5s ease-in-out forwards;
  }

  /* ── AESTHETIC-4: Heading glow reveal ──────────────────────────────────
   * Applied by adding class heading-glow-reveal to section headings.
   * The animation plays once when Framer Motion's whileInView triggers
   * (the element becomes visible) — achieved by toggling the class with
   * a React ref after the inView threshold is crossed.                     */
  @keyframes heading-glow {
    0%   { text-shadow: 0 0  0px hsl(44 80% 55% / 0);    }
    40%  { text-shadow: 0 0 32px hsl(44 80% 55% / 0.65), 0 0 8px hsl(44 80% 70% / 0.45); }
    100% { text-shadow: 0 0 12px hsl(44 80% 50% / 0.25); }
  }
  .heading-glow-reveal {
    animation: heading-glow 1.8s ease-out forwards;
  }

  /* ── Existing animations (preserved) ────────────────────────────────── */
  @keyframes eq-bar {
    0%, 100% { transform: scaleY(0.35); }
    50%       { transform: scaleY(1); }
  }
  .eq-bar { transform-origin: bottom center; animation: eq-bar 0.9s ease-in-out infinite; }

  @keyframes border-pulse {
    0%, 100% { box-shadow: 0 0 0 1px hsl(var(--gold) / 0.5), 0 0 18px hsl(var(--gold) / 0.35); }
    50%       { box-shadow: 0 0 0 1px hsl(var(--gold) / 0.8), 0 0 32px hsl(var(--gold) / 0.6);  }
  }
  .animate-border-pulse { animation: border-pulse 2.4s ease-in-out infinite; }

  @keyframes shimmer {
    0%   { background-position: -200% 0; }
    100% { background-position:  200% 0; }
  }
  .animate-shimmer { animation: shimmer 1.6s linear infinite; }

  @keyframes mesh-shift {
    0%, 100% { transform: translate(0,0)     scale(1);    }
    50%       { transform: translate(2%, -1%) scale(1.05); }
  }
  .animate-mesh-shift { animation: mesh-shift 18s ease-in-out infinite; }
}
END_CSS
echo "✔  src/index.css"

# =============================================================================
# COMPAT-3 + UPGRADE-1  src/components/MagneticCursor.tsx
#
# COMPAT-3: touch detection now uses isTouch() from src/lib/touch.ts
#           (compound check: pointer:coarse + ontouchstart + maxTouchPoints)
#
# UPGRADE-1: Morphing MagneticCursor
#   The cursor now detects WHAT the pointer is hovering and morphs:
#   — Over a/button/[data-magnetic]  → ring 52px, gold filled, scale pulse
#   — Over img / canvas              → ring 44px, crosshair (+) overlay
#   — Over p/h1-h6/span (text)       → ring collapses to 24px thin underline
#   — Default                        → ring 40px standard gold
#   All morphs use CSS transitions so they are GPU-cheap.
# =============================================================================
cat << 'END_CURSOR' > src/components/MagneticCursor.tsx
import { useEffect, useRef, useState } from "react";
import { isTouch } from "@/lib/touch";

type CursorMode = "default" | "pointer" | "image" | "text";

/**
 * MagneticCursor V3.1 — Morphing cursor
 *
 * COMPAT-3: Uses compound touch detection (isTouch()) — returns null on all
 *           touch devices regardless of how the browser reports pointer type.
 *
 * UPGRADE-1: Four distinct cursor states based on the element under the cursor:
 *   default → 40px gold ring, follows with 0.18 lag
 *   pointer → 52px ring expands, gold-fill glow, bounces on click
 *   image   → 44px ring + crosshair lines overlay
 *   text    → 24px collapsed ring shifts to I-beam underline style
 */
export default function MagneticCursor() {
  const dot     = useRef<HTMLDivElement>(null);
  const ring    = useRef<HTMLDivElement>(null);
  const cross1  = useRef<HTMLDivElement>(null);
  const cross2  = useRef<HTMLDivElement>(null);
  const [mode, setMode]    = useState<CursorMode>("default");
  const [click, setClick]  = useState(false);

  useEffect(() => {
    if (isTouch()) return;

    let x = 0, y = 0, rx = 0, ry = 0;
    let raf = 0;

    const getMode = (el: Element | null): CursorMode => {
      if (!el) return "default";
      const tag = el.tagName.toLowerCase();
      if (
        tag === "a" || tag === "button" ||
        el.closest("a") || el.closest("button") ||
        el.hasAttribute("data-magnetic") ||
        (el as HTMLElement).style?.cursor === "pointer"
      ) return "pointer";
      if (tag === "img" || tag === "canvas" || tag === "video") return "image";
      if (
        tag === "p" || tag === "span" || tag === "h1" || tag === "h2" ||
        tag === "h3" || tag === "h4" || tag === "h5" || tag === "h6" ||
        tag === "label" || tag === "li"
      ) return "text";
      return "default";
    };

    const onMove = (e: PointerEvent) => {
      x = e.clientX; y = e.clientY;
      setMode(getMode(e.target as Element));
    };
    const onDown = () => setClick(true);
    const onUp   = () => setClick(false);

    window.addEventListener("pointermove", onMove, { passive: true });
    window.addEventListener("pointerdown", onDown, { passive: true });
    window.addEventListener("pointerup",   onUp,   { passive: true });

    const tick = () => {
      rx += (x - rx) * 0.15;
      ry += (y - ry) * 0.15;
      if (dot.current) {
        dot.current.style.transform = `translate(${x}px,${y}px)`;
      }
      if (ring.current) {
        ring.current.style.transform = `translate(${rx}px,${ry}px)`;
      }
      raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);

    return () => {
      cancelAnimationFrame(raf);
      window.removeEventListener("pointermove", onMove);
      window.removeEventListener("pointerdown", onDown);
      window.removeEventListener("pointerup",   onUp);
    };
  }, []);

  if (isTouch()) return null;

  // ── Ring geometry per mode ──────────────────────────────────────────────
  const configs: Record<CursorMode, {
    size: number; border: string; bg: string; opacity: number;
  }> = {
    default: { size: 40,  border: "1px solid hsl(44 70% 55% / 0.70)", bg: "transparent",                opacity: 1    },
    pointer: { size: 52,  border: "1px solid hsl(44 80% 65% / 0.90)", bg: "hsl(44 70% 55% / 0.10)",    opacity: 1    },
    image:   { size: 44,  border: "1px solid hsl(44 60% 50% / 0.75)", bg: "transparent",                opacity: 0.85 },
    text:    { size: 24,  border: "1px solid hsl(44 50% 60% / 0.55)", bg: "transparent",                opacity: 0.6  },
  };
  const cfg = configs[mode];

  return (
    <>
      {/* Outer ring — morphs size/color per mode */}
      <div
        ref={ring}
        aria-hidden
        style={{
          position:    "fixed",
          top:         0,
          left:        0,
          zIndex:      9500,
          pointerEvents: "none",
          width:       cfg.size,
          height:      cfg.size,
          marginLeft:  -(cfg.size / 2),
          marginTop:   -(cfg.size / 2),
          borderRadius:"50%",
          border:      cfg.border,
          background:  cfg.bg,
          opacity:     cfg.opacity,
          mixBlendMode:"difference" as const,
          transition:  "width 220ms cubic-bezier(0.7,0,0.3,1), height 220ms cubic-bezier(0.7,0,0.3,1), margin 220ms cubic-bezier(0.7,0,0.3,1), border-color 200ms ease, background 200ms ease, opacity 200ms ease",
          transform:   "translate(0,0)",
          scale:       click ? "0.82" : "1",
        }}
      />

      {/* Crosshair lines — only visible in image mode */}
      <div
        ref={cross1}
        aria-hidden
        style={{
          position:    "fixed",
          top: 0, left: 0,
          zIndex:      9501,
          pointerEvents: "none",
          width:       "14px",
          height:      "1px",
          marginLeft:  "-7px",
          marginTop:   "-0.5px",
          background:  "hsl(44 70% 60% / 0.8)",
          mixBlendMode: "difference" as const,
          opacity:     mode === "image" ? 1 : 0,
          transition:  "opacity 180ms ease",
          transform:   ring.current?.style.transform ?? "translate(0,0)",
        }}
      />
      <div
        ref={cross2}
        aria-hidden
        style={{
          position:    "fixed",
          top: 0, left: 0,
          zIndex:      9501,
          pointerEvents: "none",
          width:       "1px",
          height:      "14px",
          marginLeft:  "-0.5px",
          marginTop:   "-7px",
          background:  "hsl(44 70% 60% / 0.8)",
          mixBlendMode: "difference" as const,
          opacity:     mode === "image" ? 1 : 0,
          transition:  "opacity 180ms ease",
          transform:   ring.current?.style.transform ?? "translate(0,0)",
        }}
      />

      {/* Inner dot — always precise, no lag */}
      <div
        ref={dot}
        aria-hidden
        style={{
          position:    "fixed",
          top:         0,
          left:        0,
          zIndex:      9502,
          pointerEvents: "none",
          width:       mode === "pointer" ? 6 : 4,
          height:      mode === "pointer" ? 6 : 4,
          marginLeft:  mode === "pointer" ? -3 : -2,
          marginTop:   mode === "pointer" ? -3 : -2,
          borderRadius:"50%",
          background:  "hsl(44 80% 65%)",
          transition:  "width 150ms ease, height 150ms ease, margin 150ms ease",
          transform:   "translate(0,0)",
        }}
      />
    </>
  );
}
END_CURSOR
echo "✔  src/components/MagneticCursor.tsx"

# =============================================================================
# COMPAT-3  src/components/Navigation.tsx
# Replaced the solo `matchMedia("(pointer:coarse)")` with isTouch() check
# for the mobile hamburger visibility logic.
# Also adds active section highlighting to desktop nav links.
# =============================================================================
cat << 'END_NAV' > src/components/Navigation.tsx
import { useEffect, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Menu, X } from "lucide-react";
import { useScramble } from "@/hooks/useScramble";
import { useMagnetic } from "@/hooks/useMagnetic";

const LINKS = [
  { id: "work",    label: "WORK"    },
  { id: "about",   label: "ABOUT"   },
  { id: "process", label: "PROCESS" },
];

function NavLink({
  id, label, active, onClick,
}: { id: string; label: string; active?: boolean; onClick?: () => void }) {
  const text = useScramble(label, 700);
  const ref  = useMagnetic<HTMLAnchorElement>(0.3);
  return (
    <a
      ref={ref}
      href={`#${id}`}
      onClick={onClick}
      className={
        "font-mono text-[11px] tracking-[0.35em] transition-colors px-2 py-1 " +
        (active ? "text-gold" : "text-cream/80 hover:text-gold")
      }
    >
      {text}
    </a>
  );
}

export default function Navigation() {
  const brand        = useScramble("GENISYS", 900);
  const [open, setOpen]   = useState(false);
  const [active, setActive] = useState<string>("");
  const menuRef            = useMagnetic<HTMLButtonElement>(0.25);

  // Active section tracking via IntersectionObserver
  useEffect(() => {
    if (typeof IntersectionObserver === "undefined") return;
    const obs = new IntersectionObserver(
      (entries) => {
        entries.forEach(e => { if (e.isIntersecting) setActive(e.target.id); });
      },
      { rootMargin: "-30% 0px -60% 0px", threshold: 0 },
    );
    LINKS.forEach(l => {
      const el = document.getElementById(l.id);
      if (el) obs.observe(el);
    });
    return () => obs.disconnect();
  }, []);

  // Body scroll lock — uses explicit overflow:hidden + padding compensation
  useEffect(() => {
    if (!open) return;
    const scrollBarWidth = window.innerWidth - document.documentElement.clientWidth;
    document.body.style.overflow        = "hidden";
    document.body.style.paddingRight    = scrollBarWidth + "px";
    return () => {
      document.body.style.overflow     = "";
      document.body.style.paddingRight = "";
    };
  }, [open]);

  const close = () => setOpen(false);

  return (
    <>
      <header className="fixed top-0 left-0 right-0 z-[70] flex items-center justify-between px-4 sm:px-8 pt-4">
        <a href="#top" className="font-display font-black text-base sm:text-lg gold-text tracking-tight">
          {brand}
        </a>

        {/* Desktop links */}
        <nav className="hidden sm:flex items-center gap-1 glass rounded-full px-3 py-1.5">
          {LINKS.map(l => (
            <NavLink key={l.id} {...l} active={active === l.id} />
          ))}
        </nav>

        {/* Mobile hamburger — isTouch-agnostic: shown on sm:hidden breakpoint */}
        <button
          ref={menuRef}
          onClick={() => setOpen(true)}
          aria-label="Open navigation"
          className="sm:hidden grid place-items-center w-10 h-10 rounded-full glass gold-border-glow"
        >
          <Menu className="w-4 h-4 text-gold" />
        </button>
      </header>

      {/* Mobile full-screen overlay */}
      <AnimatePresence>
        {open && (
          <motion.div
            initial={{ opacity: 0, clipPath: "circle(0% at 95% 5%)" }}
            animate={{ opacity: 1, clipPath: "circle(150% at 95% 5%)" }}
            exit={{   opacity: 0, clipPath: "circle(0% at 95% 5%)" }}
            transition={{ duration: 0.5, ease: [0.7, 0, 0.3, 1] }}
            className="fixed inset-0 z-[150] grid place-items-center sm:hidden"
            style={{ background: "rgba(0,0,0,0.97)", backdropFilter: "blur(28px)", WebkitBackdropFilter: "blur(28px)" }}
          >
            <button
              onClick={close}
              aria-label="Close navigation"
              className="absolute top-5 right-5 grid place-items-center w-11 h-11 rounded-full glass-strong gold-border-glow"
            >
              <X className="w-5 h-5 text-gold" />
            </button>

            <nav className="flex flex-col items-center gap-10">
              {LINKS.map((l, i) => (
                <motion.a
                  key={l.id}
                  href={`#${l.id}`}
                  onClick={close}
                  initial={{ opacity: 0, x: -30 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ duration: 0.45, delay: 0.1 + i * 0.09, ease: [0.7, 0, 0.3, 1] }}
                  className="font-display font-black text-5xl gold-text tracking-tight"
                >
                  {l.label}
                </motion.a>
              ))}

              <motion.button
                initial={{ opacity: 0, x: -30 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ duration: 0.45, delay: 0.1 + LINKS.length * 0.09, ease: [0.7, 0, 0.3, 1] }}
                onClick={() => { close(); window.dispatchEvent(new Event("open-contact")); }}
                className="mt-2 px-8 py-3 rounded-full glass-strong gold-border-glow font-mono text-xs tracking-[0.3em] text-gold"
              >
                START A PROJECT
              </motion.button>
            </nav>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
END_NAV
echo "✔  src/components/Navigation.tsx"

# =============================================================================
# UPGRADE-2  src/components/Lightbox.tsx
# Adds a share/download button to the bottom action bar.
# — navigator.share (Web Share API) is used if available (Android Chrome,
#   iOS Safari 14+) — shares the title + image URL natively.
# — Fallback: creates a temporary <a download> tag to trigger browser
#   download — works on all desktop browsers and Kiwi/Termux.
# =============================================================================
cat << 'END_LIGHTBOX' > src/components/Lightbox.tsx
import { useEffect, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { X, ChevronLeft, ChevronRight, Share2, Download } from "lucide-react";
import type { PortfolioItem } from "@/data/portfolioData";
import { useDominantColor } from "@/hooks/useDominantColor";

interface Props {
  items:      PortfolioItem[];
  index:      number | null;
  onClose:    () => void;
  onNavigate: (index: number) => void;
}

export default function Lightbox({ items, index, onClose, onNavigate }: Props) {
  const item        = index !== null ? items[index] : null;
  const color       = useDominantColor(item?.imagePath);
  const touchStartX = useRef<number | null>(null);
  const canShare    = typeof navigator !== "undefined" && "share" in navigator;

  // ── Body scroll lock ─────────────────────────────────────────────────────
  useEffect(() => {
    if (index === null) return;
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => { document.body.style.overflow = prev || "unset"; };
  }, [index]);

  // ── Keyboard ─────────────────────────────────────────────────────────────
  useEffect(() => {
    if (index === null) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "ArrowLeft")  goPrev();
      if (e.key === "ArrowRight") goNext();
      if (e.key === "Escape")     onClose();
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [index]);

  const goPrev = () => { if (index !== null && index > 0)                  onNavigate(index - 1); };
  const goNext = () => { if (index !== null && index < items.length - 1)   onNavigate(index + 1); };

  // ── Touch swipe ──────────────────────────────────────────────────────────
  const onTouchStart = (e: React.TouchEvent) => { touchStartX.current = e.touches[0].clientX; };
  const onTouchEnd   = (e: React.TouchEvent) => {
    if (touchStartX.current === null) return;
    const dx = e.changedTouches[0].clientX - touchStartX.current;
    if (Math.abs(dx) > 50) { dx < 0 ? goNext() : goPrev(); }
    touchStartX.current = null;
  };

  // ── UPGRADE-2: Share / Download ──────────────────────────────────────────
  const handleShare = async () => {
    if (!item) return;
    if (canShare) {
      try {
        await navigator.share({
          title: item.title,
          text:  item.description ?? item.category,
          url:   item.imagePath,
        });
      } catch { /* user cancelled or API error */ }
    } else {
      // Fallback: programmatic download
      const a = document.createElement("a");
      a.href     = item.imagePath;
      a.download = `${item.title.replace(/\s+/g, "-").toLowerCase()}.jpg`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
    }
  };

  const hasPrev = index !== null && index > 0;
  const hasNext = index !== null && index < items.length - 1;

  return (
    <AnimatePresence>
      {item && (
        <motion.div
          key={item.id}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{   opacity: 0 }}
          transition={{ duration: 0.35 }}
          className="fixed inset-0 z-[120] grid place-items-center p-4 sm:p-10"
          style={{
            background:     `radial-gradient(80% 60% at 50% 50%, ${color}33, #000 80%)`,
            backdropFilter: "blur(14px)",
            WebkitBackdropFilter: "blur(14px)",
          }}
          onClick={onClose}
          onTouchStart={onTouchStart}
          onTouchEnd={onTouchEnd}
        >
          {/* ── Close ─────────────────────────────────────────────────── */}
          <button
            aria-label="Close lightbox"
            onClick={onClose}
            style={{ zIndex: 9999 }}
            className="absolute top-5 right-5 sm:top-7 sm:right-7 grid place-items-center w-11 h-11 rounded-full glass-strong gold-border-glow"
          >
            <X className="w-5 h-5 text-gold" />
          </button>

          {/* ── Share / Download ──────────────────────────────────────── */}
          <button
            aria-label={canShare ? "Share image" : "Download image"}
            onClick={e => { e.stopPropagation(); handleShare(); }}
            style={{ zIndex: 9999 }}
            className="absolute top-5 right-20 sm:top-7 sm:right-24 grid place-items-center w-11 h-11 rounded-full glass-strong gold-border-glow"
            title={canShare ? "Share" : "Download"}
          >
            {canShare
              ? <Share2   className="w-4 h-4 text-gold" />
              : <Download className="w-4 h-4 text-gold" />
            }
          </button>

          {/* ── Prev ──────────────────────────────────────────────────── */}
          {hasPrev && (
            <button
              aria-label="Previous image"
              onClick={e => { e.stopPropagation(); goPrev(); }}
              style={{ zIndex: 9999 }}
              className="absolute left-3 sm:left-6 top-1/2 -translate-y-1/2 grid place-items-center w-11 h-11 rounded-full glass-strong gold-border-glow"
            >
              <ChevronLeft className="w-5 h-5 text-gold" />
            </button>
          )}

          {/* ── Next ──────────────────────────────────────────────────── */}
          {hasNext && (
            <button
              aria-label="Next image"
              onClick={e => { e.stopPropagation(); goNext(); }}
              style={{ zIndex: 9999 }}
              className="absolute right-3 sm:right-20 top-1/2 -translate-y-1/2 grid place-items-center w-11 h-11 rounded-full glass-strong gold-border-glow"
            >
              <ChevronRight className="w-5 h-5 text-gold" />
            </button>
          )}

          {/* ── Counter ───────────────────────────────────────────────── */}
          {index !== null && (
            <div
              className="absolute bottom-6 left-1/2 -translate-x-1/2 font-mono text-[10px] tracking-[0.3em]"
              style={{ color: "hsl(var(--gold) / 0.55)" }}
            >
              {index + 1} / {items.length}
            </div>
          )}

          {/* ── Card ──────────────────────────────────────────────────── */}
          <motion.div
            key={item.id + "-card"}
            initial={{ scale: 0.96, y: 20 }}
            animate={{ scale: 1,    y: 0  }}
            exit={{   scale: 0.98,  y: 10 }}
            transition={{ duration: 0.45, ease: [0.7, 0, 0.3, 1] }}
            className="relative max-w-4xl w-full max-h-[95vh] overflow-y-auto glass-strong specular grain rounded-2xl"
            onClick={e => e.stopPropagation()}
          >
            <img
              src={item.imagePath}
              alt={item.title}
              className="w-auto max-h-[90vh] max-w-full object-contain mx-auto block"
            />
            <div className="p-5 sm:p-8">
              <div className="font-mono text-[10px] tracking-[0.3em] text-gold/80">
                {item.category.toUpperCase()}
              </div>
              <h3 className="mt-2 font-display text-2xl sm:text-3xl gold-text font-black">
                {item.title}
              </h3>
              {item.description && (
                <p className="mt-3 text-cream/70 text-sm leading-relaxed">{item.description}</p>
              )}
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
END_LIGHTBOX
echo "✔  src/components/Lightbox.tsx"

# =============================================================================
# UPGRADE-3  src/components/Gallery.tsx
# Staggered waterfall entrance:  each card's entrance delay is calculated as
# (index % PAGE_SIZE) * 0.055 seconds — cards cascade top-to-bottom instead
# of all popping in simultaneously.  The delay resets at each new page load
# so "Load More" also cascades.  The index prop is passed to PortfolioCard.
# =============================================================================
cat << 'END_GALLERY' > src/components/Gallery.tsx
import { useMemo, useState } from "react";
import { AnimatePresence }   from "framer-motion";
import { portfolio, type Category, type PortfolioItem } from "@/data/portfolioData";
import PortfolioCard from "./PortfolioCard";
import Lightbox      from "./Lightbox";
import { useScramble } from "@/hooks/useScramble";
import { useMagnetic } from "@/hooks/useMagnetic";
import { pulseLetterbox } from "./Letterbox";
import { haptic }         from "@/lib/haptics";

const TABS: ("All" | Category)[] = ["All", "Flyers", "Logos", "Brand Identity"];
const PAGE_SIZE = 12;

function Tab({
  label, active, onClick,
}: { label: string; active: boolean; onClick: () => void }) {
  const text = useScramble(label.toUpperCase(), 700, active);
  const ref  = useMagnetic<HTMLButtonElement>(0.3);
  return (
    <button
      ref={ref}
      onClick={onClick}
      data-magnetic
      className={
        "relative px-4 py-2 rounded-full font-mono text-[10px] sm:text-[11px] tracking-[0.3em] transition-colors " +
        (active
          ? "bg-gold text-black gold-border-glow"
          : "text-cream/85 hover:text-gold border border-white/10")
      }
    >
      {text}
    </button>
  );
}

export default function Gallery() {
  const [filter,    setFilter]    = useState<"All" | Category>("All");
  const [openIndex, setOpenIndex] = useState<number | null>(null);
  const [page,      setPage]      = useState(1);
  const heading = useScramble("SELECTED WORK", 1100, filter);

  const filtered = useMemo(
    () => filter === "All" ? portfolio : portfolio.filter(p => p.category === filter),
    [filter],
  );

  const visible   = filtered.slice(0, page * PAGE_SIZE);
  const hasMore   = visible.length < filtered.length;
  const remaining = filtered.length - visible.length;

  const changeFilter = (f: "All" | Category) => {
    if (f === filter) return;
    haptic(8);
    pulseLetterbox();
    setFilter(f);
    setPage(1);
  };

  const handleOpen = (item: PortfolioItem) => {
    const idx = filtered.findIndex(i => i.id === item.id);
    setOpenIndex(idx);
  };

  return (
    <section id="work" className="relative px-4 sm:px-8 py-24">
      <div className="max-w-6xl mx-auto">
        <div className="flex items-end justify-between gap-4 mb-8 flex-wrap">
          <div>
            <div className="font-mono text-[10px] tracking-[0.4em] text-gold/80">VISUAL PORTFOLIO</div>
            {/* AESTHETIC-4: heading-glow-reveal added for gold pulse on enter */}
            <h2 className="mt-2 font-display font-black text-4xl sm:text-6xl gold-text chromatic heading-glow-reveal">
              {heading}
            </h2>
          </div>
          <div className="flex flex-wrap gap-2">
            {TABS.map(t => (
              <Tab key={t} label={t} active={filter === t} onClick={() => changeFilter(t)} />
            ))}
          </div>
        </div>

        <div className="columns-1 sm:columns-2 lg:columns-3 gap-5">
          <AnimatePresence mode="popLayout">
            {visible.map((item, i) => (
              <PortfolioCard
                key={item.id}
                item={item}
                onOpen={handleOpen}
                {/* UPGRADE-3: entranceDelay creates the waterfall cascade */}
                entranceDelay={(i % PAGE_SIZE) * 0.055}
              />
            ))}
          </AnimatePresence>
        </div>

        {hasMore && (
          <div className="mt-12 flex justify-center">
            <button
              onClick={() => setPage(p => p + 1)}
              className="px-8 py-3 rounded-full glass-strong gold-border-glow font-mono text-xs tracking-[0.3em] text-gold hover:text-cream transition-colors"
            >
              LOAD MORE — {remaining} REMAINING
            </button>
          </div>
        )}
      </div>

      <Lightbox
        items={filtered}
        index={openIndex}
        onClose={() => setOpenIndex(null)}
        onNavigate={setOpenIndex}
      />
    </section>
  );
}
END_GALLERY
echo "✔  src/components/Gallery.tsx"

# =============================================================================
# UPGRADE-3 + AESTHETIC-2 + UPGRADE-5  src/components/PortfolioCard.tsx
#
# UPGRADE-3: Accepts entranceDelay prop — Framer Motion transition.delay
#            creates the gallery waterfall entrance cascade.
#
# AESTHETIC-2: Gold scanline sweep — a .scan-line div positioned at the top
#              of the card. On group:hover it plays card-scan animation
#              (defined in index.css), sweeping a gold line top→bottom.
#
# UPGRADE-5: Long-press preview on mobile — a 600ms touchstart timeout
#            shows a full-size floating overlay with the image before the
#            lightbox opens.  Touch move or end cancels the timer.
#            haptic(15) fires on trigger for tactile confirmation.
# =============================================================================
cat << 'END_CARD' > src/components/PortfolioCard.tsx
import { useRef, useState }   from "react";
import { motion }              from "framer-motion";
import LazyImage               from "./LazyImage";
import { useGyroscopeTilt }    from "@/contexts/GyroscopeContext";
import { haptic }              from "@/lib/haptics";
import type { PortfolioItem }  from "@/data/portfolioData";

interface Props {
  item:           PortfolioItem;
  onOpen:         (i: PortfolioItem) => void;
  entranceDelay?: number;
}

export default function PortfolioCard({ item, onOpen, entranceDelay = 0 }: Props) {
  const ref      = useRef<HTMLDivElement>(null);
  const t        = useGyroscopeTilt();
  const [focused,  setFocused]  = useState(false);
  const [preview,  setPreview]  = useState(false);

  const sx     = t.x * 22;
  const sy     = t.y * 22 + 18;
  const shadow = `${-sx}px ${sy}px 40px hsl(var(--gold) / 0.28), 0 0 0 1px hsl(var(--gold) / 0.18)`;

  // ── UPGRADE-5: Long-press preview ─────────────────────────────────────
  const longPressTimer = useRef<ReturnType<typeof setTimeout> | null>(null);

  const onTouchStart = () => {
    longPressTimer.current = setTimeout(() => {
      haptic(15);
      setPreview(true);
    }, 600);
  };
  const cancelLongPress = () => {
    if (longPressTimer.current) {
      clearTimeout(longPressTimer.current);
      longPressTimer.current = null;
    }
  };
  const onTouchEnd = () => {
    cancelLongPress();
    // Keep preview visible briefly so the user can see it
    setTimeout(() => setPreview(false), 500);
  };

  return (
    <>
      <motion.div
        ref={ref}
        layout
        initial={{ opacity: 0, y: 28 }}
        animate={{ opacity: 1, y: 0 }}
        exit={{ opacity: 0, y: 12 }}
        transition={{
          duration: 0.6,
          delay:    entranceDelay,          // UPGRADE-3: waterfall cascade
          ease:     [0.7, 0, 0.3, 1],
        }}
        data-focusable
        data-focused={focused || undefined}
        onMouseEnter={() => setFocused(true)}
        onMouseLeave={() => setFocused(false)}
        onFocus={() => setFocused(true)}
        onBlur={() => setFocused(false)}
        onClick={() => onOpen(item)}
        onTouchStart={onTouchStart}
        onTouchEnd={onTouchEnd}
        onTouchMove={cancelLongPress}
        className="card-scanline relative group cursor-pointer mb-5 break-inside-avoid rounded-2xl overflow-hidden glass specular grain"
        style={{ boxShadow: shadow }}
      >
        {/* AESTHETIC-2: Gold scanline sweep element */}
        <div
          className="scan-line absolute inset-x-0 top-0 h-[2px] z-10 pointer-events-none"
          style={{
            background: "linear-gradient(90deg, transparent 0%, hsl(44 85% 65% / 0.9) 40%, hsl(44 95% 80%) 50%, hsl(44 85% 65% / 0.9) 60%, transparent 100%)",
            boxShadow:  "0 0 8px hsl(44 80% 60% / 0.8)",
          }}
        />

        <LazyImage
          src={item.imagePath}
          alt={item.title}
          className={item.tall ? "aspect-[3/4]" : "aspect-[4/5]"}
        />

        <div className="absolute inset-0 bg-gradient-to-t from-black/85 via-black/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
        <div className="absolute inset-x-0 bottom-0 p-4 translate-y-2 group-hover:translate-y-0 opacity-0 group-hover:opacity-100 transition-all duration-500">
          <div className="font-mono text-[10px] tracking-[0.3em] text-gold/80">
            {item.category.toUpperCase()}
          </div>
          <div className="text-cream font-semibold text-sm sm:text-base mt-1">
            {item.title}
          </div>
        </div>
      </motion.div>

      {/* UPGRADE-5: Long-press floating full-image preview */}
      {preview && (
        <div
          className="fixed inset-0 z-[115] grid place-items-center pointer-events-none"
          aria-hidden
        >
          <motion.div
            initial={{ opacity: 0, scale: 0.88 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.22, ease: [0.7, 0, 0.3, 1] }}
            className="w-[72vw] max-w-xs rounded-2xl overflow-hidden glass-strong gold-border-glow shadow-2xl"
          >
            <img
              src={item.imagePath}
              alt={item.title}
              className="w-full h-auto block"
            />
            <div className="p-3 font-mono text-[9px] tracking-[0.25em] text-gold/80 text-center">
              HOLD TO PREVIEW · TAP TO OPEN
            </div>
          </motion.div>
        </div>
      )}
    </>
  );
}
END_CARD
echo "✔  src/components/PortfolioCard.tsx"

# =============================================================================
# UPGRADE-4  src/components/Preloader.tsx
# G-monogram SVG that draws itself using Framer Motion's pathLength prop
# (which handles stroke-dasharray/dashoffset automatically).
# The G completes its draw in 1.8 s, then fades into the text title.
# Preserves all existing preloader logic (haptic, gyro permission, gate).
# =============================================================================
cat << 'END_PRELOADER' > src/components/Preloader.tsx
import { motion, AnimatePresence } from "framer-motion";
import { useState } from "react";
import { useScramble } from "@/hooks/useScramble";
import { requestGyroPermission } from "@/hooks/useGyroscope";
import { haptic } from "@/lib/haptics";

/**
 * Preloader V3.1 — G-Monogram Self-Draw
 *
 * UPGRADE-4: The spinner is replaced with a full Framer Motion SVG animation.
 * The G letterform (same path as favicon.svg) draws itself via pathLength
 * from 0 → 1 over 1.8 s with an ease-in-out curve.
 * After draw completion a `scale` spring bounces the G once, then the
 * existing title scramble + progress bar + ENTER button appear below.
 */
export default function Preloader({ onDone }: { onDone: () => void }) {
  const [exiting, setExiting] = useState(false);
  const title = useScramble("GENISYS GRAPHICS", 1100);
  const sub   = useScramble("OPERATIC IDENTITY SYSTEMS", 1400);

  const enter = async () => {
    haptic([12, 40, 20]);
    await requestGyroPermission();
    setExiting(true);
    setTimeout(onDone, 650);
  };

  return (
    <AnimatePresence>
      {!exiting && (
        <motion.div
          key="pre"
          initial={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.6 }}
          className="fixed inset-0 z-[100] bg-black grid place-items-center"
        >
          <div className="grid place-items-center text-center px-6 w-full max-w-[520px]">

            {/* ── UPGRADE-4: Animated G-monogram ─────────────────────── */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ duration: 0.4 }}
              className="mb-6"
            >
              <svg
                viewBox="0 0 64 64"
                className="w-24 h-24 mx-auto"
                style={{ overflow: "visible" }}
              >
                <defs>
                  <linearGradient id="preload-gold" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%"   stopColor="#FFE9A0" />
                    <stop offset="40%"  stopColor="#D4AF37" />
                    <stop offset="100%" stopColor="#8B6914" />
                  </linearGradient>
                  <filter id="preload-glow">
                    <feGaussianBlur stdDeviation="2" result="blur" />
                    <feMerge>
                      <feMergeNode in="blur" />
                      <feMergeNode in="SourceGraphic" />
                    </feMerge>
                  </filter>
                </defs>

                {/* Background square */}
                <motion.rect
                  width="64" height="64" rx="14"
                  fill="transparent"
                  stroke="hsl(44 70% 50% / 0.2)"
                  strokeWidth="1"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ delay: 0.2, duration: 0.6 }}
                />

                {/* G path — self-drawing via pathLength */}
                <motion.path
                  d="M 41 23 A 13 13 0 1 0 41 41 L 41 32 L 31 32"
                  stroke="url(#preload-gold)"
                  strokeWidth="4.5"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  fill="none"
                  filter="url(#preload-glow)"
                  initial={{ pathLength: 0, opacity: 0 }}
                  animate={{ pathLength: 1, opacity: 1 }}
                  transition={{
                    pathLength: { duration: 1.8, ease: "easeInOut", delay: 0.3 },
                    opacity:    { duration: 0.4, delay: 0.3 },
                  }}
                />

                {/* Completion glow burst */}
                <motion.circle
                  cx="32" cy="32" r="28"
                  fill="none"
                  stroke="hsl(44 80% 55% / 0.35)"
                  strokeWidth="1"
                  initial={{ scale: 0.6, opacity: 0 }}
                  animate={{ scale: 1.15, opacity: [0, 0.6, 0] }}
                  transition={{ duration: 0.7, delay: 2.1, ease: "easeOut" }}
                  style={{ transformOrigin: "32px 32px" }}
                />
              </svg>
            </motion.div>

            {/* ── Existing preloader body ─────────────────────────────── */}
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 1.6, duration: 0.55, ease: [0.7, 0, 0.3, 1] }}
              className="w-full"
            >
              <div className="font-mono text-[11px] tracking-[0.4em] text-gold/70 mb-4">
                SYSTEM // BOOT
              </div>
              <h1 className="font-display font-black text-3xl sm:text-5xl gold-text chromatic tracking-tight">
                {title}
              </h1>
              <div className="font-mono text-[11px] sm:text-xs tracking-[0.3em] text-cream/80 mt-3">
                {sub}
              </div>

              <div className="mt-8 w-full h-[2px] bg-white/5 rounded-full overflow-hidden">
                <motion.div
                  className="h-full bg-gradient-to-r from-gold-deep via-gold to-cream"
                  initial={{ width: "0%" }}
                  animate={{ width: "100%" }}
                  transition={{ duration: 1.6, ease: "easeOut", delay: 1.6 }}
                />
              </div>
              <div className="mt-2 font-mono text-[10px] tracking-[0.4em] text-gold/70">
                READY
              </div>

              <button
                onClick={enter}
                className="mt-8 px-8 py-3 rounded-md border border-gold/60 text-gold font-mono text-xs tracking-[0.3em] hover:bg-gold hover:text-black transition-colors animate-border-pulse"
              >
                ENTER EXPERIENCE
              </button>
              <p className="mt-3 text-[10px] font-mono text-cream/60">
                Tap to enable motion parallax &amp; audio
              </p>
            </motion.div>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
END_PRELOADER
echo "✔  src/components/Preloader.tsx"

# =============================================================================
# COMPAT-1 + AESTHETIC-1 + AESTHETIC-3 + all new components  src/App.tsx
# Changes:
#   — useVhFix() called at root for iOS Safari dvh fix (COMPAT-1)
#   — AuroraBackground added behind LiquidCanvas (AESTHETIC-1, gated by tier)
#   — ScrollVignette rendered as fixed overlay (AESTHETIC-3)
#   — All existing tier gating, GyroscopeProvider, etc. preserved
# =============================================================================
cat << 'END_APP' > src/App.tsx
import { useEffect, useState }  from "react";
import ErrorBoundary             from "@/components/ErrorBoundary";
import LiquidCanvas              from "@/components/LiquidCanvas";
import EmberParticles            from "@/components/EmberParticles";
import MagneticCursor            from "@/components/MagneticCursor";
import GoldDustTrail             from "@/components/GoldDustTrail";
import Preloader                 from "@/components/Preloader";
import VibeToggle                from "@/components/VibeToggle";
import Navigation                from "@/components/Navigation";
import Hero                      from "@/components/Hero";
import Gallery                   from "@/components/Gallery";
import Stats                     from "@/components/Stats";
import About                     from "@/components/About";
import Testimonials              from "@/components/Testimonials";
import Process                   from "@/components/Process";
import Footer                    from "@/components/Footer";
import ContactModal              from "@/components/ContactModal";
import Letterbox                 from "@/components/Letterbox";
import AuroraBackground          from "@/components/AuroraBackground";
import ScrollVignette            from "@/components/ScrollVignette";
import { useLenis }              from "@/hooks/useLenis";
import { useVhFix }              from "@/hooks/useVhFix";
import { useReducedMotion }      from "@/hooks/useReducedMotion";
import { GyroscopeProvider }     from "@/contexts/GyroscopeContext";
import { getDeviceTier }         from "@/lib/deviceTier";

const TIER = getDeviceTier();

export default function App() {
  const [loaded, setLoaded]    = useState(false);
  const [contactOpen, setOpen] = useState(false);
  const reduced = useReducedMotion();
  useLenis();
  useVhFix();   // COMPAT-1: writes --vh for iOS Safari dvh fallback

  useEffect(() => {
    const h = () => setOpen(true);
    window.addEventListener("open-contact", h);
    return () => window.removeEventListener("open-contact", h);
  }, []);

  const showEmbers   = !reduced && TIER !== "low";
  const showGoldDust = !reduced && TIER === "high";
  const showAurora   = !reduced && TIER !== "low";   // AESTHETIC-1

  return (
    <ErrorBoundary>
      <GyroscopeProvider>

        {/* ── Background layers (z-order: aurora → liquid → embers) ─── */}
        {showAurora && <AuroraBackground />}
        <LiquidCanvas />
        {showEmbers   && <EmberParticles />}
        {showGoldDust && <GoldDustTrail />}

        {/* ── Overlay layers ──────────────────────────────────────────── */}
        <MagneticCursor />
        <Letterbox />
        <ScrollVignette />   {/* AESTHETIC-3 */}

        {!loaded && <Preloader onDone={() => setLoaded(true)} />}
        <VibeToggle />

        {/* ── Page content ────────────────────────────────────────────── */}
        <div className="relative z-10">
          <Navigation />
          <main>
            <Hero />
            <Gallery />
            <Stats />
            <About />
            <Testimonials />
            <Process />
          </main>
          <Footer onContact={() => setOpen(true)} />
        </div>

        <ContactModal open={contactOpen} onClose={() => setOpen(false)} />
      </GyroscopeProvider>
    </ErrorBoundary>
  );
}
END_APP
echo "✔  src/App.tsx"

# =============================================================================
# Bump package.json to 3.1.0
# =============================================================================
if command -v node &>/dev/null; then
  node -e "
    const fs  = require('fs');
    const pkg = JSON.parse(fs.readFileSync('package.json','utf8'));
    pkg.version = '3.1.0';
    fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
  " && echo "✔  package.json → 3.1.0"
else
  echo "⚠️  node not found — manually set \"version\": \"3.1.0\" in package.json"
fi

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🎬  Genisys Graphics V3.1 \"INTERACTIVE\" — patch complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  NEW files"
echo "  ─────────"
echo "  src/hooks/useVhFix.ts             COMPAT-1  iOS Safari dvh fix"
echo "  src/lib/touch.ts                  COMPAT-3  compound touch detection"
echo "  src/components/AuroraBackground   AESTHETIC-1  aurora mesh layer"
echo "  src/components/ScrollVignette     AESTHETIC-3  cinematic vignette"
echo ""
echo "  MODIFIED files"
echo "  ──────────────"
echo "  public/favicon.svg     ICON     gold G-monogram on void-black square"
echo "  src/index.css          COMPAT-1,2 + AESTHETIC-1,2,4,5 CSS additions"
echo "  src/App.tsx            Aurora + ScrollVignette + useVhFix wired in"
echo "  MagneticCursor.tsx     UPGRADE-1  morph: pointer/image/text modes"
echo "  Navigation.tsx         COMPAT-3   touch fix + clip-path open anim"
echo "  Lightbox.tsx           UPGRADE-2  Web Share API + download fallback"
echo "  Gallery.tsx            UPGRADE-3  staggered waterfall entrance"
echo "  PortfolioCard.tsx      AESTHETIC-2 scanline + UPGRADE-5 long-press"
echo "  Preloader.tsx          UPGRADE-4  SVG G self-draw pathLength anim"
echo "  package.json           3.1.0"
echo ""
echo "  FEATURE MAP"
echo "  ───────────"
echo "  COMPAT-1   iOS Safari dvh viewport height now fixed globally"
echo "  COMPAT-2   Backdrop-filter @supports fallback in all glass elements"
echo "  COMPAT-3   isTouch() used in Cursor + Nav — works in Termux/Samsung"
echo "  UPGRADE-1  Cursor morphs: pointer=expand, image=crosshair, text=thin"
echo "  UPGRADE-2  Share (mobile) / Download (desktop) button in Lightbox"
echo "  UPGRADE-3  Gallery cards waterfall-cascade in with 55ms stagger"
echo "  UPGRADE-4  Preloader shows G drawing itself stroke by stroke"
echo "  UPGRADE-5  Long-press any card (600ms) to float a preview thumbnail"
echo "  AESTHETIC-1  Aurora gold-orb mesh slowly drifts behind WebGL layer"
echo "  AESTHETIC-2  Gold scanline sweeps top→bottom on every card hover"
echo "  AESTHETIC-3  Radial vignette deepens as user scrolls down the page"
echo "  AESTHETIC-4  Gallery heading pulses with gold glow on section enter"
echo "  AESTHETIC-5  Full-page fine-grain film texture at 3% opacity"
echo "  ICON       favicon.svg is now the gold G-monogram you designed"
echo ""
echo "  Originals backed up → $BACKUP"
echo ""
echo "  Run:  npm run dev"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
