#!/usr/bin/env bash
# =============================================================================
# Genisys Graphics — V2.5 Upgrade & Bug-Fix Script
# Run from project root:  bash upgrade_v2_5.sh
# =============================================================================
set -euo pipefail

if [ ! -f "package.json" ] || [ ! -d "src" ]; then
  echo "✗ Run this script from the project root (where package.json & src/ live)."
  exit 1
fi

echo "▶ Genisys V2.5 — applying surgical upgrade…"
mkdir -p src/components src/hooks

# ─────────────────────────────────────────────────────────────────────────────
# 1. App.tsx — remove focus-dim body blur, mount GoldDustTrail
# ─────────────────────────────────────────────────────────────────────────────
cat << 'EOF' > src/App.tsx
import { useEffect, useState } from "react";
import ErrorBoundary from "@/components/ErrorBoundary";
import LiquidCanvas from "@/components/LiquidCanvas";
import EmberParticles from "@/components/EmberParticles";
import MagneticCursor from "@/components/MagneticCursor";
import GoldDustTrail from "@/components/GoldDustTrail";
import Preloader from "@/components/Preloader";
import VibeToggle from "@/components/VibeToggle";
import Navigation from "@/components/Navigation";
import Hero from "@/components/Hero";
import Gallery from "@/components/Gallery";
import About from "@/components/About";
import Process from "@/components/Process";
import Footer from "@/components/Footer";
import ContactModal from "@/components/ContactModal";
import Letterbox from "@/components/Letterbox";
import { useLenis } from "@/hooks/useLenis";

export default function App() {
  const [loaded, setLoaded] = useState(false);
  const [contactOpen, setContactOpen] = useState(false);
  useLenis();

  // V2.5: focus-dim REMOVED — was causing body text to render blurred & unreadable.

  useEffect(() => {
    const h = () => setContactOpen(true);
    window.addEventListener("open-contact", h);
    return () => window.removeEventListener("open-contact", h);
  }, []);

  return (
    <ErrorBoundary>
      <LiquidCanvas />
      <EmberParticles />
      <GoldDustTrail />
      <MagneticCursor />
      <Letterbox />

      {!loaded && <Preloader onDone={() => setLoaded(true)} />}

      <VibeToggle />

      <div className="relative z-10">
        <Navigation />
        <main>
          <Hero />
          <Gallery />
          <About />
          <Process />
        </main>
        <Footer onContact={() => setContactOpen(true)} />
      </div>

      <ContactModal open={contactOpen} onClose={() => setContactOpen(false)} />
    </ErrorBoundary>
  );
}
EOF

# ─────────────────────────────────────────────────────────────────────────────
# 2. index.css — kill blur on body text, brighten foreground, remove focus-dim blur
# ─────────────────────────────────────────────────────────────────────────────
cat << 'EOF' > src/index.css
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    /* Pitch-black operatic palette — V2.5: brightened foreground for readability */
    --background: 0 0% 2%;
    --foreground: 44 60% 88%;          /* light cream-gold, high contrast */

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

    /* Brand palette — V2.5: ONLY two real accents (gold + black) for fluid */
    --gold: 44 72% 54%;
    --gold-soft: 44 60% 78%;            /* brighter for body text */
    --gold-deep: 40 65% 32%;
    --cream: 44 55% 90%;                /* high-contrast cream */
    --void: 0 0% 4%;                    /* pitch black */
  }
  html, body, #root { background: hsl(0 0% 0%); color: hsl(var(--foreground)); }
  html { scroll-behavior: auto; -webkit-font-smoothing: antialiased; }
  body {
    font-family: Inter, system-ui, sans-serif;
    overflow-x: hidden;
    /* V2.5: explicit no filter on body — guarantees text never inherits a blur */
    filter: none !important;
  }
  * { @apply border-border; }
  ::selection { background: hsl(var(--gold) / 0.4); color: hsl(var(--cream)); }

  /* V2.5: NEVER blur readable text. Anything with these data attrs/tags stays sharp. */
  p, h1, h2, h3, h4, h5, h6, span, a, button, label, input, textarea, select, li, div[data-text] {
    filter: none !important;
  }
}

@layer utilities {
  .glass {
    background: linear-gradient(135deg, hsl(0 0% 100% / 0.06), hsl(0 0% 100% / 0.02));
    backdrop-filter: blur(22px) saturate(140%);
    -webkit-backdrop-filter: blur(22px) saturate(140%);
    border: 1px solid hsl(44 60% 60% / 0.18);
    box-shadow: 0 10px 40px -10px hsl(0 0% 0% / 0.7), inset 0 1px 0 hsl(0 0% 100% / 0.08);
  }
  .glass-strong {
    background: linear-gradient(135deg, hsl(0 0% 100% / 0.10), hsl(0 0% 100% / 0.03));
    backdrop-filter: blur(36px) saturate(160%);
    -webkit-backdrop-filter: blur(36px) saturate(160%);
    border: 1px solid hsl(44 70% 60% / 0.32);
    box-shadow: 0 20px 60px -15px hsl(0 0% 0% / 0.85), inset 0 1px 0 hsl(0 0% 100% / 0.12), inset 0 0 30px hsl(44 70% 50% / 0.05);
  }
  .specular::before {
    content: ""; position: absolute; inset: 0; border-radius: inherit; pointer-events: none;
    background: linear-gradient(115deg, transparent 30%, hsl(0 0% 100% / 0.18) 48%, transparent 56%);
    mix-blend-mode: overlay; opacity: 0.7;
  }
  .grain::after {
    content: ""; position: absolute; inset: 0; pointer-events: none; opacity: 0.18;
    background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='160' height='160'><filter id='n'><feTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='2' stitchTiles='stitch'/><feColorMatrix values='0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 0 .55 0'/></filter><rect width='100%' height='100%' filter='url(%23n)'/></svg>");
    mix-blend-mode: overlay; border-radius: inherit;
  }
  .chromatic { text-shadow: 0 0 1px hsl(44 70% 50% / 0.3); }
  .gold-text {
    background: linear-gradient(160deg, #FFE9A0 0%, #E8C76B 28%, #D4AF37 55%, #A8801F 82%, #6B4F12 100%);
    -webkit-background-clip: text; background-clip: text; color: transparent;
  }
  .gold-border-glow { box-shadow: 0 0 0 1px hsl(var(--gold) / 0.5), 0 0 24px hsl(var(--gold) / 0.45), inset 0 0 12px hsl(var(--gold) / 0.18); }
  .letterbox-bar { background: #000; position: fixed; left: 0; right: 0; z-index: 80; pointer-events: none; }

  /* V2.5: focus-dim is now opacity-only — NO blur filter on body text. */
  .focus-dim [data-focusable]:not([data-focused="true"]) { opacity: 0.55; transition: opacity .35s ease; }
  .focus-dim [data-focused="true"] { opacity: 1; transition: opacity .35s ease; z-index: 5; position: relative; }

  .no-scrollbar::-webkit-scrollbar { display: none; }
  .no-scrollbar { scrollbar-width: none; }

  /* V2.5: Audio equalizer bars */
  @keyframes eq-bar {
    0%, 100% { transform: scaleY(0.35); }
    50%      { transform: scaleY(1); }
  }
  .eq-bar { transform-origin: bottom center; animation: eq-bar 0.9s ease-in-out infinite; }

  /* V2.5: Border pulse fallback (preserved from v2) */
  @keyframes border-pulse {
    0%, 100% { box-shadow: 0 0 0 1px hsl(var(--gold) / 0.5), 0 0 18px hsl(var(--gold) / 0.35); }
    50%      { box-shadow: 0 0 0 1px hsl(var(--gold) / 0.8), 0 0 32px hsl(var(--gold) / 0.6); }
  }
  .animate-border-pulse { animation: border-pulse 2.4s ease-in-out infinite; }

  @keyframes shimmer { 0% { background-position: -200% 0; } 100% { background-position: 200% 0; } }
  .animate-shimmer { animation: shimmer 1.6s linear infinite; }

  @keyframes mesh-shift { 0%, 100% { transform: translate(0,0) scale(1); } 50% { transform: translate(2%, -1%) scale(1.05); } }
  .animate-mesh-shift { animation: mesh-shift 18s ease-in-out infinite; }
}
EOF

# ─────────────────────────────────────────────────────────────────────────────
# 3. Preloader — REMOVE all auto-bypass timers, manual ENTER only, + haptic
# ─────────────────────────────────────────────────────────────────────────────
cat << 'EOF' > src/components/Preloader.tsx
import { motion, AnimatePresence } from "framer-motion";
import { useState } from "react";
import { useScramble } from "@/hooks/useScramble";
import { requestGyroPermission } from "@/hooks/useGyroscope";
import { haptic } from "@/lib/haptics";

/**
 * Preloader V2.5
 * — NO setTimeout auto-unmount. NO progress interval auto-complete.
 * — Stays visible INDEFINITELY until user clicks ENTER EXPERIENCE.
 * — Triggers premium haptic vibration on enter.
 */
export default function Preloader({ onDone }: { onDone: () => void }) {
  const [exiting, setExiting] = useState(false);
  const title = useScramble("GENISYS GRAPHICS", 1100);
  const sub = useScramble("OPERATIC IDENTITY SYSTEMS", 1400);

  const enter = async () => {
    haptic([12, 40, 20]);              // crisp double-tap pattern
    await requestGyroPermission();
    setExiting(true);
    // Wait for exit animation, THEN unmount via parent
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
            <div className="font-mono text-[11px] tracking-[0.4em] text-gold/70 mb-4">SYSTEM // BOOT</div>
            <h1 className="font-display font-black text-3xl sm:text-5xl gold-text chromatic tracking-tight">{title}</h1>
            <div className="font-mono text-[11px] sm:text-xs tracking-[0.3em] text-cream/80 mt-3">{sub}</div>

            <div className="mt-8 w-full h-[2px] bg-white/5 rounded-full overflow-hidden">
              <motion.div
                className="h-full bg-gradient-to-r from-gold-deep via-gold to-cream"
                initial={{ width: "0%" }}
                animate={{ width: "100%" }}
                transition={{ duration: 1.6, ease: "easeOut" }}
              />
            </div>
            <div className="mt-2 font-mono text-[10px] tracking-[0.4em] text-gold/70">READY</div>

            <button
              onClick={enter}
              className="mt-8 px-8 py-3 rounded-md border border-gold/60 text-gold font-mono text-xs tracking-[0.3em] hover:bg-gold hover:text-black transition-colors animate-border-pulse"
            >
              ENTER EXPERIENCE
            </button>
            <p className="mt-3 text-[10px] font-mono text-cream/60">Tap to enable motion parallax & audio</p>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
EOF

# ─────────────────────────────────────────────────────────────────────────────
# 4. LazyImage — eliminate blur stuck-state. Razor-sharp instant snap.
# ─────────────────────────────────────────────────────────────────────────────
cat << 'EOF' > src/components/LazyImage.tsx
import { useEffect, useRef, useState, memo } from "react";

/**
 * LazyImage V2.5
 * — Renders <img> immediately (no IntersectionObserver gating).
 * — Uses native loading="lazy" + decoding="async" for performance.
 * — ZERO blur filters. Opacity-only fade-in (GPU-cheap, can never lock mid-state).
 * — Cached-image fallback: if .complete already true on mount, mark loaded instantly.
 */
const LazyImage = memo(function LazyImage({
  src,
  alt,
  className,
}: {
  src: string;
  alt: string;
  className?: string;
}) {
  const imgRef = useRef<HTMLImageElement>(null);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    const img = imgRef.current;
    if (img && img.complete && img.naturalWidth > 0) setLoaded(true);
  }, [src]);

  return (
    <div className={"relative overflow-hidden bg-white/[0.02] " + (className ?? "")}>
      {!loaded && (
        <div
          className="absolute inset-0 animate-shimmer pointer-events-none"
          style={{
            background: "linear-gradient(90deg, transparent, hsl(0 0% 100% / 0.05), transparent)",
            backgroundSize: "200% 100%",
          }}
        />
      )}
      <img
        ref={imgRef}
        src={src}
        alt={alt}
        loading="lazy"
        decoding="async"
        onLoad={() => setLoaded(true)}
        onError={() => setLoaded(true)}
        className={
          "w-full h-full object-cover transition-opacity duration-200 " +
          (loaded ? "opacity-100" : "opacity-0")
        }
      />
    </div>
  );
});

export default LazyImage;
EOF

# ─────────────────────────────────────────────────────────────────────────────
# 5. LiquidCanvas — TWO-COLOR shader (pitch black + dark metallic gold)
# ─────────────────────────────────────────────────────────────────────────────
cat << 'EOF' > src/components/LiquidCanvas.tsx
import { useEffect, useRef, useState } from "react";
import * as THREE from "three";
import { hasWebGL } from "@/lib/webgl";

/**
 * LiquidCanvas V2.5
 * STRICT two-color palette: void black (#0a0a0a) and dark metallic gold (~#3a2a08).
 * Heavily darkened so text remains the focal point.
 */
const FRAG = /* glsl */`
precision highp float;
uniform vec2 uRes;
uniform float uTime;
uniform vec2 uMouse;
varying vec2 vUv;

const vec3 C_VOID = vec3(0.039, 0.039, 0.039);   // #0a0a0a
const vec3 C_GOLD = vec3(0.227, 0.165, 0.047);   // dark metallic gold (~#3a2a0c)

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
  vec2 i = floor(p), f = fract(p);
  float a = hash(i), b = hash(i + vec2(1.0, 0.0));
  float c = hash(i + vec2(0.0, 1.0)), d = hash(i + vec2(1.0, 1.0));
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}
float fbm(vec2 p) {
  float v = 0.0, a = 0.5;
  for (int i = 0; i < 5; i++) { v += a * noise(p); p *= 2.02; a *= 0.5; }
  return v;
}

void main() {
  vec2 uv = vUv;
  vec2 p = (uv - 0.5) * vec2(uRes.x / uRes.y, 1.0);
  float t = uTime * 0.035;

  vec2 q = vec2(fbm(p + t), fbm(p + vec2(5.2, 1.3) - t));
  vec2 r = vec2(fbm(p + 4.0 * q + vec2(1.7, 9.2) + t * 0.6),
                fbm(p + 4.0 * q + vec2(8.3, 2.8) - t * 0.6));
  float f = fbm(p + 4.0 * r);

  vec2 m = (uMouse - 0.5) * vec2(uRes.x / uRes.y, 1.0);
  float md = exp(-3.5 * length(p - m));
  f += md * 0.18;

  // Strict two-color mix: void → dark gold based on fbm
  float mask = smoothstep(0.32, 0.78, f);
  vec3 col = mix(C_VOID, C_GOLD, mask);

  // Crush further to keep text focal
  col = pow(col, vec3(2.6));
  col *= 0.55;

  // Vignette
  float v = smoothstep(1.05, 0.18, length(uv - 0.5));
  col *= v;

  // Subtle grain
  float g = (hash(gl_FragCoord.xy + uTime) - 0.5) * 0.025;
  col += g;

  gl_FragColor = vec4(col, 1.0);
}
`;

const VERT = /* glsl */`
varying vec2 vUv;
void main() { vUv = uv; gl_Position = vec4(position, 1.0); }
`;

export default function LiquidCanvas() {
  const ref = useRef<HTMLCanvasElement>(null);
  const [supported, setSupported] = useState(true);

  useEffect(() => {
    if (!hasWebGL()) { setSupported(false); return; }
    const canvas = ref.current!;
    let renderer: THREE.WebGLRenderer;
    try {
      renderer = new THREE.WebGLRenderer({
        canvas,
        antialias: false,
        alpha: false,
        powerPreference: "low-power",
      });
    } catch (e) {
      console.warn("[LiquidCanvas] WebGL init failed", e);
      setSupported(false);
      return;
    }

    const dpr = Math.min(window.devicePixelRatio || 1, 1.25); // V2.5: tighter dpr cap
    renderer.setPixelRatio(dpr);
    renderer.setSize(window.innerWidth, window.innerHeight, false);
    renderer.setClearColor(0x000000, 1);

    const scene = new THREE.Scene();
    const camera = new THREE.Camera();
    const geo = new THREE.PlaneGeometry(2, 2);
    const uniforms = {
      uRes:   { value: new THREE.Vector2(window.innerWidth, window.innerHeight) },
      uTime:  { value: 0 },
      uMouse: { value: new THREE.Vector2(0.5, 0.5) },
    };
    const mat = new THREE.ShaderMaterial({ fragmentShader: FRAG, vertexShader: VERT, uniforms });
    const mesh = new THREE.Mesh(geo, mat);
    scene.add(mesh);

    const onResize = () => {
      renderer.setSize(window.innerWidth, window.innerHeight, false);
      uniforms.uRes.value.set(window.innerWidth, window.innerHeight);
    };
    const onMouse = (e: PointerEvent) => {
      uniforms.uMouse.value.set(e.clientX / window.innerWidth, 1 - e.clientY / window.innerHeight);
    };
    window.addEventListener("resize", onResize);
    window.addEventListener("pointermove", onMouse, { passive: true });

    // V2.5: Throttle to 30fps on mobile for buttery scrolling
    const isMobile = matchMedia("(pointer: coarse)").matches;
    const targetMs = isMobile ? 33 : 16;
    let raf = 0;
    const start = performance.now();
    let lastFrame = start;
    const tick = (now: number) => {
      raf = requestAnimationFrame(tick);
      if (now - lastFrame < targetMs) return;
      lastFrame = now;
      uniforms.uTime.value = (now - start) / 1000;
      try { renderer.render(scene, camera); }
      catch (e) { console.warn("[LiquidCanvas] render error", e); cancelAnimationFrame(raf); }
    };
    raf = requestAnimationFrame(tick);

    return () => {
      cancelAnimationFrame(raf);
      window.removeEventListener("resize", onResize);
      window.removeEventListener("pointermove", onMouse);
      geo.dispose();
      mat.dispose();
      renderer.dispose();
    };
  }, []);

  if (!supported) {
    return (
      <div aria-hidden className="fixed inset-0 z-0 pointer-events-none bg-black overflow-hidden">
        <div className="absolute inset-0 opacity-40"
          style={{ background: "radial-gradient(60% 50% at 50% 50%, hsl(var(--gold-deep)/.18), transparent 60%)" }} />
        <div className="absolute inset-0"
          style={{ background: "radial-gradient(120% 80% at 50% 50%, transparent 30%, #000 90%)" }} />
      </div>
    );
  }

  return <canvas ref={ref} aria-hidden className="fixed inset-0 z-0 w-full h-full block bg-black" />;
}
EOF

# ─────────────────────────────────────────────────────────────────────────────
# 6. ContactModal — scrollable on mobile (max-h-[85vh] overflow-y-auto)
# ─────────────────────────────────────────────────────────────────────────────
cat << 'EOF' > src/components/ContactModal.tsx
import { useState, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { X, Send, CheckCircle, AlertCircle } from "lucide-react";

interface Props { open: boolean; onClose: () => void; }
type Status = "idle" | "sending" | "sent" | "error";

export default function ContactModal({ open, onClose }: Props) {
  const [status, setStatus] = useState<Status>("idle");
  const formRef = useRef<HTMLFormElement>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formRef.current || status === "sending") return;
    setStatus("sending");
    try {
      const data = new FormData(formRef.current);
      const res = await fetch("https://api.web3forms.com/submit", { method: "POST", body: data });
      const json = await res.json();
      if (json.success) {
        setStatus("sent");
        setTimeout(() => { setStatus("idle"); onClose(); formRef.current?.reset(); }, 3000);
      } else setStatus("error");
    } catch { setStatus("error"); }
  };

  const handleClose = () => {
    if (status === "sending") return;
    setStatus("idle");
    onClose();
  };

  return (
    <AnimatePresence>
      {open && (
        <motion.div
          initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
          transition={{ duration: 0.3 }}
          className="fixed inset-0 z-[200] grid place-items-center p-4 sm:p-8"
          style={{
            backdropFilter: "blur(24px)",
            background: "radial-gradient(80% 60% at 50% 50%, rgba(212,175,55,0.07), rgba(0,0,0,0.94))",
          }}
          onClick={handleClose}
        >
          <motion.div
            initial={{ scale: 0.94, y: 32, opacity: 0 }}
            animate={{ scale: 1, y: 0, opacity: 1 }}
            exit={{ scale: 0.96, y: 16, opacity: 0 }}
            transition={{ duration: 0.42, ease: [0.7, 0, 0.3, 1] }}
            /* V2.5: max-h-[85vh] + overflow-y-auto so Send/Cancel always reachable */
            className="relative w-full max-w-lg max-h-[85vh] overflow-y-auto glass-strong specular grain rounded-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="relative px-7 pt-7 pb-5 border-b border-white/[0.06]">
              <div className="font-mono text-[10px] tracking-[0.45em] text-gold/80">
                SECURE CHANNEL · WEB3FORMS
              </div>
              <h2 className="mt-2 font-display font-black text-3xl sm:text-4xl gold-text chromatic">
                START A PROJECT
              </h2>
              <p className="mt-1.5 text-cream/80 text-sm">
                Tell us what you're building. We'll make it iconic.
              </p>
              <button
                onClick={handleClose}
                aria-label="Close contact modal"
                disabled={status === "sending"}
                style={{ zIndex: 9999 }}
                className="absolute top-6 right-6 grid place-items-center w-9 h-9 rounded-full glass-strong gold-border-glow disabled:opacity-40"
              >
                <X className="w-4 h-4 text-gold" />
              </button>
            </div>

            <div className="px-7 py-6">
              {status === "sent" ? (
                <motion.div
                  initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }}
                  className="flex flex-col items-center gap-4 py-8 text-center"
                >
                  <CheckCircle className="w-14 h-14 text-gold" strokeWidth={1.5} />
                  <div className="font-display font-black text-2xl gold-text">Transmission Received</div>
                  <p className="text-cream/80 text-sm max-w-xs">
                    Your brief is in. We'll respond within 24 hours with a direction.
                  </p>
                  <div className="font-mono text-[10px] tracking-[0.3em] text-gold/60">CLOSING IN 3s...</div>
                </motion.div>
              ) : (
                <form ref={formRef} onSubmit={handleSubmit} className="space-y-4">
                  <input type="hidden" name="access_key" value="a71a80eb-c0dc-4ad0-8a31-f89ae7687ee1" />
                  <input type="hidden" name="subject" value="New Project Inquiry — Genisys Studio" />
                  <input type="hidden" name="from_name" value="Genisys Contact Form" />
                  <input type="checkbox" name="botcheck" style={{ display: "none" }} defaultChecked={false} />

                  <div className="grid sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block font-mono text-[10px] tracking-[0.3em] text-gold/80 mb-1.5">YOUR NAME</label>
                      <input type="text" name="name" required placeholder="e.g. Jordan Mercer"
                        className="w-full bg-white/[0.04] border border-white/10 rounded-xl px-4 py-3 text-cream text-sm placeholder:text-cream/30 focus:outline-none focus:border-gold/50 transition-colors" />
                    </div>
                    <div>
                      <label className="block font-mono text-[10px] tracking-[0.3em] text-gold/80 mb-1.5">EMAIL ADDRESS</label>
                      <input type="email" name="email" required placeholder="you@brand.com"
                        className="w-full bg-white/[0.04] border border-white/10 rounded-xl px-4 py-3 text-cream text-sm placeholder:text-cream/30 focus:outline-none focus:border-gold/50 transition-colors" />
                    </div>
                  </div>

                  <div>
                    <label className="block font-mono text-[10px] tracking-[0.3em] text-gold/80 mb-1.5">PROJECT TYPE</label>
                    <div className="relative">
                      <select name="project_type"
                        className="w-full bg-white/[0.04] border border-white/10 rounded-xl px-4 py-3 text-cream text-sm focus:outline-none focus:border-gold/50 transition-colors appearance-none cursor-pointer">
                        <option value="Brand Identity System" className="bg-black">Brand Identity System</option>
                        <option value="Logo & Mark Design" className="bg-black">Logo &amp; Mark Design</option>
                        <option value="Cinematic Flyer / Campaign" className="bg-black">Cinematic Flyer / Campaign</option>
                        <option value="Packaging & Print" className="bg-black">Packaging &amp; Print</option>
                        <option value="Full Visual Direction" className="bg-black">Full Visual Direction</option>
                        <option value="Other" className="bg-black">Other — Let's Talk</option>
                      </select>
                      <div className="absolute right-4 top-1/2 -translate-y-1/2 pointer-events-none text-gold/60 text-xs">▾</div>
                    </div>
                  </div>

                  <div>
                    <label className="block font-mono text-[10px] tracking-[0.3em] text-gold/80 mb-1.5">YOUR BRIEF</label>
                    <textarea name="message" required rows={4}
                      placeholder="Tell us about your brand, vision, timeline, and budget..."
                      className="w-full bg-white/[0.04] border border-white/10 rounded-xl px-4 py-3 text-cream text-sm placeholder:text-cream/30 focus:outline-none focus:border-gold/50 transition-colors resize-none" />
                  </div>

                  {status === "error" && (
                    <div className="flex items-center gap-2 text-red-400">
                      <AlertCircle className="w-4 h-4 shrink-0" />
                      <span className="font-mono text-[10px] tracking-[0.2em]">
                        TRANSMISSION FAILED — CHECK CONNECTION AND RETRY.
                      </span>
                    </div>
                  )}

                  <div className="flex gap-3 pt-2">
                    <button type="button" onClick={handleClose}
                      className="flex-1 px-5 py-3.5 rounded-full border border-white/15 text-cream/80 font-mono text-xs tracking-[0.3em] hover:border-gold/50 hover:text-gold transition-colors">
                      CANCEL
                    </button>
                    <button type="submit" disabled={status === "sending"}
                      className="flex-[2] flex items-center justify-center gap-3 px-6 py-3.5 rounded-full bg-gold text-black font-semibold text-sm tracking-[0.15em] hover:bg-cream transition-colors disabled:opacity-50">
                      {status === "sending" ? "TRANSMITTING…" : (<>SEND <Send className="w-4 h-4" /></>)}
                    </button>
                  </div>
                </form>
              )}
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
EOF

# ─────────────────────────────────────────────────────────────────────────────
# 7. VibeToggle — equalizer animation when playing + haptic
# ─────────────────────────────────────────────────────────────────────────────
cat << 'EOF' > src/components/VibeToggle.tsx
import { useEffect, useRef, useState } from "react";
import { VolumeX } from "lucide-react";
import { useMagnetic } from "@/hooks/useMagnetic";
import { haptic } from "@/lib/haptics";

export default function VibeToggle() {
  const [on, setOn] = useState(false);
  const audio = useRef<HTMLAudioElement | null>(null);
  const btnRef = useMagnetic<HTMLButtonElement>(0.25);

  useEffect(() => {
    const a = new Audio("/vibe.mp3");
    a.loop = true;
    a.volume = 0.35;
    audio.current = a;
    return () => { a.pause(); a.src = ""; audio.current = null; };
  }, []);

  const toggle = async () => {
    haptic(15);
    if (!audio.current) return;
    if (on) { audio.current.pause(); setOn(false); }
    else {
      try { await audio.current.play(); setOn(true); }
      catch { setOn(false); }
    }
  };

  // V2.5: Equalizer bars — 4 gold bars, staggered animation
  const bars = [0, 0.18, 0.36, 0.12];

  return (
    <button
      ref={btnRef}
      onClick={toggle}
      aria-label={on ? "Mute ambient vibe" : "Play ambient vibe"}
      aria-pressed={on}
      className="fixed bottom-6 left-6 z-[90] grid place-items-center w-12 h-12 sm:w-14 sm:h-14 rounded-full glass-strong gold-border-glow animate-border-pulse"
    >
      <span className="absolute inset-0 rounded-full pointer-events-none"
        style={{ boxShadow: "inset 0 0 18px hsl(var(--gold)/.35)" }} />
      {on ? (
        <span className="flex items-end gap-[3px] h-5" aria-hidden>
          {bars.map((delay, i) => (
            <span
              key={i}
              className="eq-bar w-[3px] h-full rounded-sm bg-gold"
              style={{
                animationDelay: `${delay}s`,
                boxShadow: "0 0 8px hsl(var(--gold) / 0.85)",
              }}
            />
          ))}
        </span>
      ) : (
        <VolumeX className="w-5 h-5 text-gold" />
      )}
    </button>
  );
}
EOF

# ─────────────────────────────────────────────────────────────────────────────
# 8. NEW lib: haptics helper (safe across browsers)
# ─────────────────────────────────────────────────────────────────────────────
mkdir -p src/lib
cat << 'EOF' > src/lib/haptics.ts
/**
 * Premium haptic feedback wrapper for navigator.vibrate.
 * Silently no-ops on unsupported browsers (Safari iOS doesn't support vibrate;
 * the call is harmless). Subtle defaults for "premium" feel.
 */
export function haptic(pattern: number | number[] = 10) {
  try {
    const nav = typeof navigator !== "undefined" ? (navigator as Navigator & { vibrate?: (p: number | number[]) => boolean }) : null;
    if (nav && typeof nav.vibrate === "function") {
      nav.vibrate(pattern);
    }
  } catch {
    /* ignore */
  }
}
EOF

# ─────────────────────────────────────────────────────────────────────────────
# 9. NEW component: GoldDustTrail — pointer-tracking sparks
# ─────────────────────────────────────────────────────────────────────────────
cat << 'EOF' > src/components/GoldDustTrail.tsx
import { useEffect, useRef } from "react";

/**
 * GoldDustTrail V2.5
 * Pointer/touch trail of fading golden sparks. Canvas-based, GPU-friendly.
 * — Pointer events cover both mouse & touch (touch only emits during drag).
 * — Capped particle pool (no leaks).
 * — Auto-pauses when tab hidden.
 */
interface Spark {
  x: number; y: number; vx: number; vy: number;
  life: number; max: number; r: number;
}

export default function GoldDustTrail() {
  const ref = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = ref.current!;
    const ctx2d = canvas.getContext("2d");
    if (!ctx2d) return;
    const ctx = ctx2d;

    const dpr = Math.min(window.devicePixelRatio || 1, 1.5);
    let w = window.innerWidth, h = window.innerHeight;
    const resize = () => {
      w = window.innerWidth; h = window.innerHeight;
      canvas.width = w * dpr; canvas.height = h * dpr;
      canvas.style.width = w + "px"; canvas.style.height = h + "px";
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    };
    resize();

    const POOL_MAX = 80;
    const sparks: Spark[] = [];
    let lastSpawn = 0;
    let lx = 0, ly = 0;
    let active = false;
    const isCoarse = matchMedia("(pointer: coarse)").matches;

    const spawn = (x: number, y: number, count = 2) => {
      for (let i = 0; i < count && sparks.length < POOL_MAX; i++) {
        sparks.push({
          x: x + (Math.random() - 0.5) * 6,
          y: y + (Math.random() - 0.5) * 6,
          vx: (Math.random() - 0.5) * 0.6,
          vy: (Math.random() - 0.5) * 0.6 - 0.15,
          life: 0,
          max: 600 + Math.random() * 500,
          r: 0.8 + Math.random() * 1.6,
        });
      }
    };

    const onMove = (e: PointerEvent) => {
      // On touch devices only emit during press-drag
      if (isCoarse && e.pressure === 0 && e.pointerType === "touch") return;
      const now = performance.now();
      const dx = e.clientX - lx, dy = e.clientY - ly;
      const dist = Math.hypot(dx, dy);
      if (now - lastSpawn > 18 || dist > 14) {
        spawn(e.clientX, e.clientY, dist > 30 ? 3 : 2);
        lastSpawn = now;
      }
      lx = e.clientX; ly = e.clientY;
    };

    const onDown = (e: PointerEvent) => { active = true; lx = e.clientX; ly = e.clientY; };
    const onUp = () => { active = false; };

    window.addEventListener("resize", resize);
    window.addEventListener("pointermove", onMove, { passive: true });
    window.addEventListener("pointerdown", onDown, { passive: true });
    window.addEventListener("pointerup", onUp, { passive: true });

    let raf = 0, last = performance.now(), running = true;
    const onVis = () => { running = !document.hidden; if (running) { last = performance.now(); raf = requestAnimationFrame(tick); } };
    document.addEventListener("visibilitychange", onVis);

    function tick(now: number) {
      if (!running) return;
      const dt = Math.min(48, now - last); last = now;
      ctx.clearRect(0, 0, w, h);
      ctx.globalCompositeOperation = "lighter";
      for (let i = sparks.length - 1; i >= 0; i--) {
        const s = sparks[i];
        s.life += dt;
        if (s.life >= s.max) { sparks.splice(i, 1); continue; }
        s.x += s.vx * dt * 0.06;
        s.y += s.vy * dt * 0.06;
        s.vy += 0.0008 * dt; // gentle gravity
        const t = s.life / s.max;
        const alpha = (1 - t) * 0.85;
        ctx.shadowBlur = 10 + s.r * 4;
        ctx.shadowColor = `hsl(44 90% 60% / ${alpha})`;
        ctx.fillStyle = `hsl(44 90% ${60 + s.r * 6}% / ${alpha})`;
        ctx.beginPath();
        ctx.arc(s.x, s.y, s.r * (1 - t * 0.6), 0, Math.PI * 2);
        ctx.fill();
      }
      ctx.shadowBlur = 0;
      raf = requestAnimationFrame(tick);
    }
    raf = requestAnimationFrame(tick);

    return () => {
      cancelAnimationFrame(raf);
      running = false;
      window.removeEventListener("resize", resize);
      window.removeEventListener("pointermove", onMove);
      window.removeEventListener("pointerdown", onDown);
      window.removeEventListener("pointerup", onUp);
      document.removeEventListener("visibilitychange", onVis);
    };
  }, []);

  return (
    <canvas
      ref={ref}
      aria-hidden
      className="fixed inset-0 z-[2] pointer-events-none"
    />
  );
}
EOF

# ─────────────────────────────────────────────────────────────────────────────
# 10. Gallery — haptic on tab clicks
# ─────────────────────────────────────────────────────────────────────────────
cat << 'EOF' > src/components/Gallery.tsx
import { useMemo, useState } from "react";
import { AnimatePresence } from "framer-motion";
import { portfolio, type Category, type PortfolioItem } from "@/data/portfolioData";
import PortfolioCard from "./PortfolioCard";
import Lightbox from "./Lightbox";
import { useScramble } from "@/hooks/useScramble";
import { useMagnetic } from "@/hooks/useMagnetic";
import { pulseLetterbox } from "./Letterbox";
import { haptic } from "@/lib/haptics";

const TABS: ("All" | Category)[] = ["All", "Flyers", "Logos", "Brand Identity"];

function Tab({
  label, active, onClick,
}: { label: string; active: boolean; onClick: () => void; }) {
  const text = useScramble(label.toUpperCase(), 700, active);
  const ref = useMagnetic<HTMLButtonElement>(0.3);
  return (
    <button
      ref={ref}
      onClick={onClick}
      data-magnetic
      className={
        "relative px-4 py-2 rounded-full font-mono text-[10px] sm:text-[11px] tracking-[0.3em] transition-colors " +
        (active ? "bg-gold text-black gold-border-glow" : "text-cream/85 hover:text-gold border border-white/10")
      }
    >
      {text}
    </button>
  );
}

export default function Gallery() {
  const [filter, setFilter] = useState<"All" | Category>("All");
  const [open, setOpen] = useState<PortfolioItem | null>(null);
  const heading = useScramble("SELECTED WORK", 1100, filter);

  const items = useMemo(
    () => (filter === "All" ? portfolio : portfolio.filter((p) => p.category === filter)),
    [filter]
  );

  const setF = (f: "All" | Category) => {
    if (f === filter) return;
    haptic(8);              // V2.5: subtle tap on category change
    pulseLetterbox();
    setFilter(f);
  };

  return (
    <section id="work" className="relative px-4 sm:px-8 py-24">
      <div className="max-w-6xl mx-auto">
        <div className="flex items-end justify-between gap-4 mb-8 flex-wrap">
          <div>
            <div className="font-mono text-[10px] tracking-[0.4em] text-gold/80">VISUAL PORTFOLIO</div>
            <h2 className="mt-2 font-display font-black text-4xl sm:text-6xl gold-text chromatic">{heading}</h2>
          </div>
          <div className="flex flex-wrap gap-2">
            {TABS.map((t) => (
              <Tab key={t} label={t} active={filter === t} onClick={() => setF(t)} />
            ))}
          </div>
        </div>

        <div className="columns-1 sm:columns-2 lg:columns-3 gap-5">
          <AnimatePresence mode="popLayout">
            {items.map((item) => (
              <PortfolioCard key={item.id} item={item} onOpen={setOpen} />
            ))}
          </AnimatePresence>
        </div>
      </div>
      <Lightbox item={open} onClose={() => setOpen(null)} />
    </section>
  );
}
EOF

# ─────────────────────────────────────────────────────────────────────────────
# 11. Footer — haptic on contact button
# ─────────────────────────────────────────────────────────────────────────────
cat << 'EOF' > src/components/Footer.tsx
import { useScramble } from "@/hooks/useScramble";
import { haptic } from "@/lib/haptics";

interface Props { onContact: () => void; }

export default function Footer({ onContact }: Props) {
  const sign = useScramble("GENISYS GRAPHICS // 2026", 900);

  const handleContact = () => {
    haptic([10, 30, 15]);
    onContact();
  };

  return (
    <footer className="relative px-6 pt-12 pb-28 mt-12">
      <div className="max-w-5xl mx-auto border-t border-white/[0.06] pt-8">
        <div className="flex flex-col sm:flex-row items-center justify-between gap-6">
          <div className="flex flex-col items-center sm:items-start gap-1">
            <div className="font-mono text-[10px] tracking-[0.4em] text-gold/80">{sign}</div>
            <div className="font-mono text-[9px] tracking-[0.25em] text-cream/50">
              OPERATIC BRAND &amp; IDENTITY DESIGN
            </div>
          </div>

          <button
            onClick={handleContact}
            className="inline-flex items-center gap-2.5 px-7 py-3 rounded-full glass-strong gold-border-glow font-mono text-xs tracking-[0.35em] text-gold hover:text-cream transition-colors animate-border-pulse"
          >
            CONTACT
            <span className="text-gold/70">→</span>
          </button>
        </div>

        <div className="mt-8 flex flex-col sm:flex-row items-center justify-between gap-3">
          <div className="font-mono text-[9px] tracking-[0.3em] text-cream/40">
            © 2026 GENISYS GRAPHICS. ALL RIGHTS RESERVED.
          </div>
          <div className="font-mono text-[9px] tracking-[0.25em] text-cream/40">
            CRAFTED WITH PRECISION · NO SHORTCUTS · NO COMPROMISES
          </div>
        </div>
      </div>
    </footer>
  );
}
EOF

# ─────────────────────────────────────────────────────────────────────────────
# 12. NUKE WhatsAppBar — leave a stub so any stale import doesn't break build
# ─────────────────────────────────────────────────────────────────────────────
cat << 'EOF' > src/components/WhatsAppBar.tsx
// V2.5: WhatsAppBar fully removed from the experience.
// Contact is now handled exclusively via the Web3Forms <ContactModal />,
// triggered by the sleek "CONTACT" button in <Footer />.
// Stub kept ONLY so any stale import resolves without breaking the build.
export default function WhatsAppBar() { return null; }
EOF

echo ""
echo "✓ Genisys V2.5 upgrade complete."
echo ""
echo "  Fixes applied:"
echo "   • Stuck blur-up      → LazyImage rebuilt, opacity-only fade, no IO gating"
echo "   • Body text contrast → --foreground brightened, blur stripped from text"
echo "   • Lightbox z-index   → 9999 (already), VibeToggle moved to bottom-left"
echo "   • Contact modal      → max-h-[85vh] + overflow-y-auto"
echo "   • Preloader          → manual ENTER only, no setTimeout auto-bypass"
echo "   • WebGL fluid        → strict 2-color (void + dark gold), heavily darkened"
echo "   • WhatsApp bar       → nuked; sleek Footer Contact button → modal"
echo ""
echo "  V2.5 features:"
echo "   • Mobile haptic feedback (Preloader / Tabs / Contact)"
echo "   • Interactive gold-dust pointer trail (GoldDustTrail.tsx)"
echo "   • Audio equalizer visualizer in VibeToggle when playing"
echo ""
echo "▶ Restart your dev server (npm run dev / pnpm dev / bun dev) to see changes."
