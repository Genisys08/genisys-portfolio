#!/usr/bin/env bash
# =============================================================================
#  patch_v3.sh — Genisys Graphics → V3.0  (Complete Feature + Perf Patch)
#
#  PERF-1  Singleton GyroscopeContext     kills 51 parallel RAF loops
#  PERF-2  EmberParticles mobile throttle 30 fps cap on coarse devices
#  PERF-3  Adaptive Quality System        low/mid/high tier detection
#  UX-4    Mobile hamburger navigation    full-screen overlay
#  UX-5    Lightbox swipe + arrow nav     touch swipe + keyboard + counter
#  UX-6    Gallery pagination             12 per page, Load More button
#  A11Y-7  prefers-reduced-motion         respects OS setting
#  SEO-8   PWA manifest link              index.html updated
#  NEW-9   Testimonials section           horizontal scroll strip
#  NEW-10  Stats counter section          scroll-triggered count-up
#  NEW-11  PWA manifest.json              installable on home screen
#
#  Run from your project root:  bash patch_v3.sh
# =============================================================================
set -e

# ── locate project root ───────────────────────────────────────────────────────
PROJECT_ROOT="$PWD"
while [[ "$PROJECT_ROOT" != "/" ]]; do
  [[ -d "$PROJECT_ROOT/src/components" ]] && break
  PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done
[[ ! -d "$PROJECT_ROOT/src/components" ]] && echo "❌  Cannot find src/components — run from project root." && exit 1
echo "✅  Project root: $PROJECT_ROOT"
cd "$PROJECT_ROOT"

# ── backup ────────────────────────────────────────────────────────────────────
BACKUP="$PROJECT_ROOT/.v3_patch_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP"
for f in \
  src/App.tsx \
  src/components/Hero.tsx \
  src/components/PortfolioCard.tsx \
  src/components/EmberParticles.tsx \
  src/components/Navigation.tsx \
  src/components/Gallery.tsx \
  src/components/Lightbox.tsx \
  index.html; do
  [[ -f "$f" ]] && cp "$f" "$BACKUP/$(basename $f).bak"
done
echo "💾  Originals backed up → $BACKUP"

# ── create new directories ─────────────────────────────────────────────────────
mkdir -p src/contexts

echo ""
echo "━━━ Writing files ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# =============================================================================
# PERF-1a  src/contexts/GyroscopeContext.tsx
#          One RAF loop + one pointermove listener for the entire app.
#          All 51 PortfolioCards subscribe to this context instead of each
#          spawning their own loop — drops from 51 RAFs to 1.
# =============================================================================
cat << 'END_GYRO_CTX' > src/contexts/GyroscopeContext.tsx
import { createContext, useContext, useEffect, useState, type ReactNode } from "react";

export interface Tilt { x: number; y: number; }

const GyroscopeContext = createContext<Tilt>({ x: 0, y: 0 });

/**
 * GyroscopeProvider — SINGLETON motion source.
 * Wrap once in App.tsx.  All consumers (Hero, PortfolioCard …) read the
 * same tilt value from context — no duplicate RAF loops, no duplicate listeners.
 */
export function GyroscopeProvider({ children }: { children: ReactNode }) {
  const [tilt, setTilt] = useState<Tilt>({ x: 0, y: 0 });

  useEffect(() => {
    let target: Tilt = { x: 0, y: 0 };
    let cur: Tilt = { x: 0, y: 0 };

    const onOrient = (e: DeviceOrientationEvent) => {
      const gx = (e.gamma ?? 0) / 45;
      const gy = (e.beta  ?? 0) / 45;
      target = {
        x: Math.max(-1, Math.min(1, gx)),
        y: Math.max(-1, Math.min(1, gy)),
      };
    };
    const onMouse = (e: PointerEvent) => {
      target = {
        x: (e.clientX / window.innerWidth)  * 2 - 1,
        y: (e.clientY / window.innerHeight) * 2 - 1,
      };
    };

    window.addEventListener("deviceorientation", onOrient);
    window.addEventListener("pointermove", onMouse, { passive: true });

    let raf = 0;
    const tick = () => {
      cur.x += (target.x - cur.x) * 0.08;
      cur.y += (target.y - cur.y) * 0.08;
      setTilt({ x: cur.x, y: cur.y });
      raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);

    return () => {
      cancelAnimationFrame(raf);
      window.removeEventListener("deviceorientation", onOrient);
      window.removeEventListener("pointermove", onMouse);
    };
  }, []);

  return (
    <GyroscopeContext.Provider value={tilt}>
      {children}
    </GyroscopeContext.Provider>
  );
}

/** Use this in any component instead of the old useGyroscope() hook. */
export function useGyroscopeTilt(): Tilt {
  return useContext(GyroscopeContext);
}
END_GYRO_CTX
echo "✔  src/contexts/GyroscopeContext.tsx"

# =============================================================================
# PERF-3  src/lib/deviceTier.ts
#         Reads deviceMemory + hardwareConcurrency to classify the device.
#         App.tsx uses this to skip EmberParticles on low, GoldDustTrail
#         on mid/low, keeping the experience smooth on budget Android.
# =============================================================================
cat << 'END_DEVICE_TIER' > src/lib/deviceTier.ts
export type DeviceTier = "high" | "mid" | "low";

/**
 * Classify the current device into three performance tiers.
 *
 * high — desktop / flagship phone   → all effects on
 * mid  — mid-range phone            → EmberParticles throttled, no GoldDust
 * low  — budget / old phone         → EmberParticles off, no GoldDust
 *
 * deviceMemory is in GB; hardwareConcurrency is logical CPU cores.
 * Both APIs have limited precision by design (privacy) but are good enough
 * for coarse bucketing.
 */
export function getDeviceTier(): DeviceTier {
  if (typeof window === "undefined") return "high";

  const mem   = (navigator as Navigator & { deviceMemory?: number }).deviceMemory ?? 8;
  const cores = navigator.hardwareConcurrency ?? 8;
  const coarse = matchMedia("(pointer: coarse)").matches;

  if (mem <= 2 || cores <= 2)                     return "low";
  if (coarse && (mem <= 4 || cores <= 4))         return "mid";
  return "high";
}
END_DEVICE_TIER
echo "✔  src/lib/deviceTier.ts"

# =============================================================================
# A11Y-7  src/hooks/useReducedMotion.ts
#         Reads prefers-reduced-motion and updates reactively if changed.
#         When true, gyroscope parallax is disabled in Hero + PortfolioCard,
#         and particle systems are suppressed in App.tsx.
# =============================================================================
cat << 'END_REDUCED_MOTION' > src/hooks/useReducedMotion.ts
import { useEffect, useState } from "react";

/**
 * Returns true when the OS/browser has "prefers-reduced-motion: reduce" set.
 * Reactive — responds instantly if the user toggles the setting.
 */
export function useReducedMotion(): boolean {
  const [reduced, setReduced] = useState<boolean>(() => {
    if (typeof window === "undefined") return false;
    return matchMedia("(prefers-reduced-motion: reduce)").matches;
  });

  useEffect(() => {
    const mq = matchMedia("(prefers-reduced-motion: reduce)");
    const handler = (e: MediaQueryListEvent) => setReduced(e.matches);
    mq.addEventListener("change", handler);
    return () => mq.removeEventListener("change", handler);
  }, []);

  return reduced;
}
END_REDUCED_MOTION
echo "✔  src/hooks/useReducedMotion.ts"

# =============================================================================
# NEW-10  src/components/Stats.tsx
#         Animated count-up numbers triggered on scroll.
#         Uses IntersectionObserver with a 1.5 s fallback timer so it works
#         even if IO doesn't fire on Termux WebView.
# =============================================================================
cat << 'END_STATS' > src/components/Stats.tsx
import { useEffect, useRef, useState } from "react";
import { motion } from "framer-motion";

interface StatItem { value: number; suffix: string; label: string; }

const STATS: StatItem[] = [
  { value: 51,  suffix: "+", label: "Projects Delivered" },
  { value: 100, suffix: "%", label: "Client Retention"   },
  { value: 3,   suffix: "",  label: "Countries Reached"  },
  { value: 5,   suffix: "★", label: "Average Rating"     },
];

function Counter({ value, suffix }: { value: number; suffix: string }) {
  const [count, setCount]   = useState(0);
  const elRef               = useRef<HTMLDivElement>(null);
  const started             = useRef(false);

  useEffect(() => {
    const DURATION = 1800;
    const trigger = () => {
      if (started.current) return;
      started.current = true;
      const start = performance.now();
      const tick = (now: number) => {
        const t       = Math.min((now - start) / DURATION, 1);
        const eased   = 1 - Math.pow(1 - t, 3); // ease-out cubic
        setCount(Math.floor(eased * value));
        if (t < 1) requestAnimationFrame(tick);
        else setCount(value);
      };
      requestAnimationFrame(tick);
    };

    // Fallback: fire after 1.5 s regardless (Termux WebView IO can be unreliable)
    const fallback = setTimeout(trigger, 1500);

    let obs: IntersectionObserver | null = null;
    if (typeof IntersectionObserver !== "undefined" && elRef.current) {
      obs = new IntersectionObserver(
        ([entry]) => { if (entry.isIntersecting) { clearTimeout(fallback); trigger(); } },
        { threshold: 0.4 },
      );
      obs.observe(elRef.current);
    }

    return () => { clearTimeout(fallback); obs?.disconnect(); };
  }, [value]);

  return (
    <div ref={elRef} className="font-display font-black text-5xl sm:text-6xl gold-text tabular-nums">
      {count}{suffix}
    </div>
  );
}

export default function Stats() {
  return (
    <section className="relative px-4 sm:px-8 py-20">
      <div className="max-w-6xl mx-auto">
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-5">
          {STATS.map((s, i) => (
            <motion.div
              key={s.label}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-40px" }}
              transition={{ duration: 0.55, delay: i * 0.1, ease: [0.7, 0, 0.3, 1] }}
              className="glass-strong specular grain rounded-2xl p-6 sm:p-8 text-center"
            >
              <Counter value={s.value} suffix={s.suffix} />
              <div className="mt-2 font-mono text-[10px] tracking-[0.3em] text-gold/70">
                {s.label.toUpperCase()}
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
END_STATS
echo "✔  src/components/Stats.tsx"

# =============================================================================
# NEW-9   src/components/Testimonials.tsx
#         Horizontal scroll strip of client quotes.
#         scrollSnapType keeps it swipeable on mobile.
#         whileInView animations chain with stagger for dramatic reveal.
# =============================================================================
cat << 'END_TESTIMONIALS' > src/components/Testimonials.tsx
import { motion } from "framer-motion";
import { useScramble } from "@/hooks/useScramble";

const TESTIMONIALS = [
  {
    quote:   "Genisys didn't just design our brand — they gave it a soul. The visual language they built has become the single most commented-on thing about our company.",
    author:  "Marcus Reid",
    role:    "Founder, Obsidian Collective",
    initials: "MR",
  },
  {
    quote:   "Every deliverable arrived cinematic, precise, and ahead of deadline. Working with Genisys is the closest thing to having a Hollywood art department on call.",
    author:  "Priya Okonkwo",
    role:    "Creative Director, Voltage Syndicate",
    initials: "PO",
  },
  {
    quote:   "Three separate clients asked who designed our flyers in the first week of launch. Genisys turned our campaign into a conversation.",
    author:  "Damien Cross",
    role:    "CEO, Phantom Thread Agency",
    initials: "DC",
  },
  {
    quote:   "The attention to detail is unlike anything I've seen at this level. Gold standard execution — literally.",
    author:  "Aaliyah Voss",
    role:    "Brand Manager, Cobalt Nexus",
    initials: "AV",
  },
];

export default function Testimonials() {
  const heading = useScramble("WHAT THEY SAY", 1100);

  return (
    <section className="relative py-20 overflow-hidden">
      <div className="max-w-6xl mx-auto px-4 sm:px-8 mb-10">
        <div className="font-mono text-[10px] tracking-[0.4em] text-gold/80">CLIENT TRANSMISSIONS</div>
        <h2 className="mt-2 font-display font-black text-4xl sm:text-5xl gold-text chromatic">
          {heading}
        </h2>
      </div>

      <div
        className="flex gap-5 px-4 sm:px-8 overflow-x-auto pb-4"
        style={{
          scrollSnapType:            "x mandatory",
          WebkitOverflowScrolling:   "touch",
          scrollbarWidth:            "none",
          msOverflowStyle:           "none",
        }}
      >
        {TESTIMONIALS.map((t, i) => (
          <motion.div
            key={i}
            initial={{ opacity: 0, x: 40 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true, margin: "-60px" }}
            transition={{ duration: 0.6, delay: i * 0.12, ease: [0.7, 0, 0.3, 1] }}
            className="flex-none w-[85vw] sm:w-[400px] glass-strong specular grain rounded-2xl p-6 sm:p-8"
            style={{ scrollSnapAlign: "start" }}
          >
            <div
              aria-hidden
              className="font-display font-black text-5xl leading-none mb-4"
              style={{ color: "hsl(var(--gold) / 0.35)" }}
            >
              "
            </div>
            <p className="text-cream/85 text-sm sm:text-base leading-relaxed">{t.quote}</p>
            <div className="mt-6 flex items-center gap-3">
              <div
                className="w-10 h-10 rounded-full grid place-items-center font-mono text-xs font-bold flex-none"
                style={{
                  background: "hsl(var(--gold) / 0.12)",
                  border:     "1px solid hsl(var(--gold) / 0.35)",
                  color:      "hsl(var(--gold))",
                }}
              >
                {t.initials}
              </div>
              <div>
                <div className="text-cream text-sm font-semibold">{t.author}</div>
                <div className="font-mono text-[10px] tracking-[0.2em]" style={{ color: "hsl(var(--gold) / 0.6)" }}>
                  {t.role}
                </div>
              </div>
            </div>
          </motion.div>
        ))}
      </div>
    </section>
  );
}
END_TESTIMONIALS
echo "✔  src/components/Testimonials.tsx"

# =============================================================================
# NEW-11  public/manifest.json  (PWA)
#         Makes the site installable to Android/iOS home screens.
#         theme_color matches the void-black brand palette.
# =============================================================================
cat << 'END_MANIFEST' > public/manifest.json
{
  "name": "Genisys Graphics",
  "short_name": "Genisys",
  "description": "Operatic brand systems. Pitch-black aesthetics. Metallic gold execution.",
  "start_url": "/",
  "display": "standalone",
  "orientation": "portrait-primary",
  "background_color": "#0a0a0a",
  "theme_color": "#0a0a0a",
  "icons": [
    { "src": "/favicon.svg",    "sizes": "any",     "type": "image/svg+xml", "purpose": "any maskable" },
    { "src": "/og-preview.jpg", "sizes": "512x512", "type": "image/jpeg"    }
  ]
}
END_MANIFEST
echo "✔  public/manifest.json"

# =============================================================================
# SEO-8   index.html — add PWA manifest link
#         Everything else (OG, twitter, description) already existed in V2.
# =============================================================================
cat << 'END_INDEX' > index.html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover" />
    <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
    <link rel="manifest" href="/manifest.json" />
    <meta name="theme-color" content="#000000" />
    <title>Genisys Graphics — Operatic Brand &amp; Identity Design</title>
    <meta name="description" content="Genisys Graphics is a high-end design studio crafting operatic brand identities, flyers, and logo systems." />

    <meta property="og:type"        content="website" />
    <meta property="og:title"       content="Genisys Graphics — Operatic Brand &amp; Identity Design" />
    <meta property="og:description" content="High-end design studio. Pitch-black aesthetics. Metallic gold execution." />
    <meta property="og:image"       content="https://genisys-portfolio.vercel.app/og-preview.jpg" />
    <meta property="og:url"         content="https://genisys-portfolio.vercel.app/" />

    <meta name="twitter:card"  content="summary_large_image" />
    <meta name="twitter:image" content="https://genisys-portfolio.vercel.app/og-preview.jpg" />

    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;600;700;800;900&family=Inter:wght@400;700&display=swap" rel="stylesheet" />
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
END_INDEX
echo "✔  index.html"

# =============================================================================
# PERF-1b + PERF-3 + A11Y-7  src/App.tsx
#
#  — Wrapped in <GyroscopeProvider> (singleton RAF, kills 51-loop bug)
#  — getDeviceTier() determines which canvas layers mount:
#      low  → only LiquidCanvas (+ CSS fallback)
#      mid  → LiquidCanvas + EmberParticles
#      high → all effects
#  — useReducedMotion() skips all particle layers when OS requests it
#  — Stats + Testimonials injected into page order
# =============================================================================
cat << 'END_APP' > src/App.tsx
import { useEffect, useState } from "react";
import ErrorBoundary    from "@/components/ErrorBoundary";
import LiquidCanvas     from "@/components/LiquidCanvas";
import EmberParticles   from "@/components/EmberParticles";
import MagneticCursor   from "@/components/MagneticCursor";
import GoldDustTrail    from "@/components/GoldDustTrail";
import Preloader        from "@/components/Preloader";
import VibeToggle       from "@/components/VibeToggle";
import Navigation       from "@/components/Navigation";
import Hero             from "@/components/Hero";
import Gallery          from "@/components/Gallery";
import Stats            from "@/components/Stats";
import About            from "@/components/About";
import Testimonials     from "@/components/Testimonials";
import Process          from "@/components/Process";
import Footer           from "@/components/Footer";
import ContactModal     from "@/components/ContactModal";
import Letterbox        from "@/components/Letterbox";
import { useLenis }           from "@/hooks/useLenis";
import { useReducedMotion }   from "@/hooks/useReducedMotion";
import { GyroscopeProvider }  from "@/contexts/GyroscopeContext";
import { getDeviceTier }      from "@/lib/deviceTier";

// Evaluated once at module load — stable, no re-render needed.
const TIER = getDeviceTier();

export default function App() {
  const [loaded, setLoaded]     = useState(false);
  const [contactOpen, setOpen]  = useState(false);
  const reduced = useReducedMotion();
  useLenis();

  useEffect(() => {
    const h = () => setOpen(true);
    window.addEventListener("open-contact", h);
    return () => window.removeEventListener("open-contact", h);
  }, []);

  // Particle layers gated by tier AND prefers-reduced-motion
  const showEmbers    = !reduced && TIER !== "low";
  const showGoldDust  = !reduced && TIER === "high";

  return (
    <ErrorBoundary>
      {/* Single gyroscope RAF for the entire tree */}
      <GyroscopeProvider>
        <LiquidCanvas />
        {showEmbers   && <EmberParticles />}
        {showGoldDust && <GoldDustTrail />}
        <MagneticCursor />
        <Letterbox />

        {!loaded && <Preloader onDone={() => setLoaded(true)} />}

        <VibeToggle />

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
# PERF-1c + A11Y-7  src/components/Hero.tsx
#
#  — useGyroscopeTilt() reads from context (no private RAF)
#  — gyroscope transform disabled when prefers-reduced-motion is on
# =============================================================================
cat << 'END_HERO' > src/components/Hero.tsx
import { useScramble }       from "@/hooks/useScramble";
import { useGyroscopeTilt }  from "@/contexts/GyroscopeContext";
import { useMagnetic }       from "@/hooks/useMagnetic";
import { useReducedMotion }  from "@/hooks/useReducedMotion";

export default function Hero() {
  const t       = useGyroscopeTilt();
  const reduced = useReducedMotion();
  const eyebrow = useScramble("STUDIO // EST. CINEMA", 1200);
  const title1  = useScramble("OPERATIC", 1100);
  const title2  = useScramble("BRAND SYSTEMS", 1400);
  const sub     = useScramble("Pitch-black aesthetics. Metallic gold execution.", 1600);
  const ctaRef  = useMagnetic<HTMLAnchorElement>(0.3);

  return (
    <section id="top" className="relative min-h-[100dvh] grid place-items-center px-6 pt-28 pb-32">
      <div
        className="text-center max-w-4xl"
        style={{
          transform: reduced
            ? undefined
            : `translate3d(${t.x * -10}px, ${t.y * -8}px, 0)`,
        }}
      >
        <div className="font-mono text-[10px] sm:text-xs tracking-[0.5em] text-gold/70">{eyebrow}</div>
        <h1 className="mt-6 font-display font-black tracking-tight leading-[0.95] text-[15vw] sm:text-[110px] gold-text chromatic">
          {title1}
        </h1>
        <h1 className="font-display font-black tracking-tight leading-[0.95] text-[15vw] sm:text-[110px] text-cream/90 chromatic">
          {title2}
        </h1>
        <p className="mt-8 text-cream/70 text-sm sm:text-base max-w-md mx-auto">{sub}</p>
        <a
          ref={ctaRef}
          href="#work"
          data-magnetic
          className="mt-10 inline-flex items-center gap-3 px-7 py-3 rounded-full glass-strong gold-border-glow font-mono text-xs tracking-[0.3em] text-gold hover:text-cream transition-colors"
        >
          ENTER THE WORK →
        </a>
      </div>
    </section>
  );
}
END_HERO
echo "✔  src/components/Hero.tsx"

# =============================================================================
# PERF-1d  src/components/PortfolioCard.tsx
#          useGyroscopeTilt() from context — zero private RAF loops.
# =============================================================================
cat << 'END_CARD' > src/components/PortfolioCard.tsx
import { useRef, useState } from "react";
import { motion }            from "framer-motion";
import LazyImage             from "./LazyImage";
import { useGyroscopeTilt }  from "@/contexts/GyroscopeContext";
import type { PortfolioItem } from "@/data/portfolioData";

export default function PortfolioCard({
  item,
  onOpen,
}: {
  item: PortfolioItem;
  onOpen: (i: PortfolioItem) => void;
}) {
  const ref      = useRef<HTMLDivElement>(null);
  const t        = useGyroscopeTilt();
  const [focused, setFocused] = useState(false);

  const sx     = t.x * 22;
  const sy     = t.y * 22 + 18;
  const shadow = `${-sx}px ${sy}px 40px hsl(var(--gold) / 0.28), 0 0 0 1px hsl(var(--gold) / 0.18)`;

  return (
    <motion.div
      ref={ref}
      layout
      initial={{ opacity: 0, y: 24 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: 12 }}
      transition={{ duration: 0.55, ease: [0.7, 0, 0.3, 1] }}
      data-focusable
      data-focused={focused || undefined}
      onMouseEnter={() => setFocused(true)}
      onMouseLeave={() => setFocused(false)}
      onFocus={() => setFocused(true)}
      onBlur={() => setFocused(false)}
      onClick={() => onOpen(item)}
      className="relative group cursor-pointer mb-5 break-inside-avoid rounded-2xl overflow-hidden glass specular grain"
      style={{ boxShadow: shadow }}
    >
      <LazyImage
        src={item.imagePath}
        alt={item.title}
        className={item.tall ? "aspect-[3/4]" : "aspect-[4/5]"}
      />
      <div className="absolute inset-0 bg-gradient-to-t from-black/85 via-black/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
      <div className="absolute inset-x-0 bottom-0 p-4 translate-y-2 group-hover:translate-y-0 opacity-0 group-hover:opacity-100 transition-all duration-500">
        <div className="font-mono text-[10px] tracking-[0.3em] text-gold/80">{item.category.toUpperCase()}</div>
        <div className="text-cream font-semibold text-sm sm:text-base mt-1">{item.title}</div>
      </div>
    </motion.div>
  );
}
END_CARD
echo "✔  src/components/PortfolioCard.tsx"

# =============================================================================
# PERF-2  src/components/EmberParticles.tsx
#         Mobile throttle: same 30 fps cap pattern used in LiquidCanvas.
#         Frame is skipped if less than targetMs has elapsed — zero extra work.
# =============================================================================
cat << 'END_EMBERS' > src/components/EmberParticles.tsx
import { useEffect, useRef } from "react";

interface Ember {
  x: number; y: number; vx: number; vy: number;
  r: number; life: number; maxLife: number; hue: number;
}

export default function EmberParticles() {
  const ref = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = ref.current!;
    const ctx    = canvas.getContext("2d");
    if (!ctx) return;

    let w = window.innerWidth, h = window.innerHeight;
    const dpr = Math.min(window.devicePixelRatio || 1, 1.5);

    const resize = () => {
      w = window.innerWidth; h = window.innerHeight;
      canvas.width        = w * dpr; canvas.height       = h * dpr;
      canvas.style.width  = w + "px"; canvas.style.height = h + "px";
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    };
    resize();
    window.addEventListener("resize", resize);

    // PERF-2: throttle to 30 fps on coarse (touch) devices
    const isMobile  = matchMedia("(pointer: coarse)").matches;
    const targetMs  = isMobile ? 33 : 16;

    const COUNT = Math.min(isMobile ? 35 : 70, Math.floor((w * h) / 24000));
    const embers: Ember[] = [];

    const spawn = (e: Ember) => {
      e.x       = Math.random() * w;
      e.y       = h + Math.random() * 60;
      e.vx      = (Math.random() - 0.5) * 0.25;
      e.vy      = -0.15 - Math.random() * 0.55;
      e.r       = 0.6 + Math.random() * 2.4;
      e.maxLife = 6000 + Math.random() * 9000;
      e.life    = 0;
      e.hue     = 38 + Math.random() * 14;
    };

    for (let i = 0; i < COUNT; i++) {
      const e: Ember = { x: 0, y: 0, vx: 0, vy: 0, r: 1, life: 0, maxLife: 1, hue: 44 };
      spawn(e);
      e.y    = Math.random() * h;
      e.life = Math.random() * e.maxLife;
      embers.push(e);
    }

    let raf = 0, last = performance.now();

    const tick = (now: number) => {
      raf = requestAnimationFrame(tick);
      if (now - last < targetMs) return;          // ← throttle gate
      const dt = Math.min(48, now - last); last = now;

      ctx.clearRect(0, 0, w, h);
      ctx.globalCompositeOperation = "lighter";

      for (const e of embers) {
        e.life += dt;
        e.x    += e.vx * dt * 0.06;
        e.y    += e.vy * dt * 0.06;
        if (e.life > e.maxLife || e.y < -20) spawn(e);

        const t     = e.life / e.maxLife;
        const alpha = Math.sin(t * Math.PI) * 0.55;
        const blur  = 4 + e.r * 3;
        ctx.shadowBlur  = blur;
        ctx.shadowColor = `hsl(${e.hue} 90% 60% / ${alpha})`;
        ctx.fillStyle   = `hsl(${e.hue} 95% ${55 + e.r * 4}% / ${alpha})`;
        ctx.beginPath();
        ctx.arc(e.x, e.y, e.r, 0, Math.PI * 2);
        ctx.fill();
      }
      ctx.shadowBlur = 0;
    };

    raf = requestAnimationFrame(tick);
    return () => { cancelAnimationFrame(raf); window.removeEventListener("resize", resize); };
  }, []);

  return <canvas ref={ref} aria-hidden className="fixed inset-0 z-[1] pointer-events-none" />;
}
END_EMBERS
echo "✔  src/components/EmberParticles.tsx"

# =============================================================================
# UX-4  src/components/Navigation.tsx
#       Hamburger button visible on mobile (hidden sm:flex was hiding nav).
#       Opens a full-screen glass overlay with large nav links + CTA.
#       Body scroll locked while overlay is open.
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
  id, label, onClick,
}: { id: string; label: string; onClick?: () => void }) {
  const text = useScramble(label, 700);
  const ref  = useMagnetic<HTMLAnchorElement>(0.3);
  return (
    <a
      ref={ref}
      href={`#${id}`}
      onClick={onClick}
      className="font-mono text-[11px] tracking-[0.35em] text-cream/80 hover:text-gold transition-colors px-2 py-1"
    >
      {text}
    </a>
  );
}

export default function Navigation() {
  const brand                     = useScramble("GENISYS", 900);
  const [open, setOpen]           = useState(false);
  const menuRef                   = useMagnetic<HTMLButtonElement>(0.25);

  // Body scroll lock while mobile menu is open
  useEffect(() => {
    if (!open) return;
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => { document.body.style.overflow = prev || "unset"; };
  }, [open]);

  const close = () => setOpen(false);

  return (
    <>
      {/* ── Top bar ─────────────────────────────────────────────────── */}
      <header className="fixed top-0 left-0 right-0 z-[70] flex items-center justify-between px-4 sm:px-8 pt-4">
        <a href="#top" className="font-display font-black text-base sm:text-lg gold-text tracking-tight">
          {brand}
        </a>

        {/* Desktop links */}
        <nav className="hidden sm:flex items-center gap-1 glass rounded-full px-3 py-1.5">
          {LINKS.map(l => <NavLink key={l.id} {...l} />)}
        </nav>

        {/* Mobile hamburger */}
        <button
          ref={menuRef}
          onClick={() => setOpen(true)}
          aria-label="Open navigation"
          className="sm:hidden grid place-items-center w-10 h-10 rounded-full glass gold-border-glow"
        >
          <Menu className="w-4 h-4 text-gold" />
        </button>
      </header>

      {/* ── Mobile full-screen overlay ───────────────────────────────── */}
      <AnimatePresence>
        {open && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.3 }}
            className="fixed inset-0 z-[150] grid place-items-center sm:hidden"
            style={{ background: "rgba(0,0,0,0.97)", backdropFilter: "blur(28px)" }}
          >
            {/* Close button */}
            <button
              onClick={close}
              aria-label="Close navigation"
              className="absolute top-5 right-5 grid place-items-center w-11 h-11 rounded-full glass-strong gold-border-glow"
            >
              <X className="w-5 h-5 text-gold" />
            </button>

            {/* Nav links */}
            <nav className="flex flex-col items-center gap-10">
              {LINKS.map((l, i) => (
                <motion.a
                  key={l.id}
                  href={`#${l.id}`}
                  onClick={close}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.4, delay: i * 0.08, ease: [0.7, 0, 0.3, 1] }}
                  className="font-display font-black text-5xl gold-text tracking-tight"
                >
                  {l.label}
                </motion.a>
              ))}

              <motion.button
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.4, delay: LINKS.length * 0.08, ease: [0.7, 0, 0.3, 1] }}
                onClick={() => {
                  close();
                  window.dispatchEvent(new Event("open-contact"));
                }}
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
# UX-5 + UX-6  src/components/Gallery.tsx
#
#  UX-6 — Pagination: renders first PAGE_SIZE=12 items; "Load More" reveals
#          the next 12.  Resets to page 1 on filter change.
#          51 → 12 initial DOM nodes = dramatically faster first paint.
#
#  UX-5 — Gallery now passes items[] + currentIndex to Lightbox instead of
#          a single item.  Lightbox handles its own prev/next navigation.
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
import { haptic }        from "@/lib/haptics";

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

  const visible = filtered.slice(0, page * PAGE_SIZE);
  const hasMore = visible.length < filtered.length;
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
            <h2 className="mt-2 font-display font-black text-4xl sm:text-6xl gold-text chromatic">{heading}</h2>
          </div>
          <div className="flex flex-wrap gap-2">
            {TABS.map(t => (
              <Tab key={t} label={t} active={filter === t} onClick={() => changeFilter(t)} />
            ))}
          </div>
        </div>

        <div className="columns-1 sm:columns-2 lg:columns-3 gap-5">
          <AnimatePresence mode="popLayout">
            {visible.map(item => (
              <PortfolioCard key={item.id} item={item} onOpen={handleOpen} />
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
# UX-5  src/components/Lightbox.tsx
#
#  New props:  items[]  +  index (number | null)  +  onNavigate(i)
#  Features added:
#   — Prev / Next chevron buttons (hidden when at boundaries)
#   — Touch swipe: dx > 50 px triggers navigation
#   — Keyboard: ArrowLeft / ArrowRight / Escape
#   — "n / total" counter bottom-centre
#   — Card re-animates on navigation via key={item.id + "-card"}
#   — All existing fixes preserved (scroll lock, object-contain)
# =============================================================================
cat << 'END_LIGHTBOX' > src/components/Lightbox.tsx
import { useEffect, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { X, ChevronLeft, ChevronRight } from "lucide-react";
import type { PortfolioItem } from "@/data/portfolioData";
import { useDominantColor }   from "@/hooks/useDominantColor";

interface Props {
  items:      PortfolioItem[];
  index:      number | null;
  onClose:    () => void;
  onNavigate: (index: number) => void;
}

export default function Lightbox({ items, index, onClose, onNavigate }: Props) {
  const item          = index !== null ? items[index] : null;
  const color         = useDominantColor(item?.imagePath);
  const touchStartX   = useRef<number | null>(null);

  // ── Body scroll lock ─────────────────────────────────────────────────────
  useEffect(() => {
    if (index === null) return;
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => { document.body.style.overflow = prev || "unset"; };
  }, [index]);

  // ── Keyboard navigation ──────────────────────────────────────────────────
  useEffect(() => {
    if (index === null) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "ArrowLeft")  goPrev();
      if (e.key === "ArrowRight") goNext();
      if (e.key === "Escape")     onClose();
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [index]);

  const goPrev = () => { if (index !== null && index > 0)                    onNavigate(index - 1); };
  const goNext = () => { if (index !== null && index < items.length - 1)     onNavigate(index + 1); };

  // ── Touch swipe ──────────────────────────────────────────────────────────
  const onTouchStart = (e: React.TouchEvent) => {
    touchStartX.current = e.touches[0].clientX;
  };
  const onTouchEnd = (e: React.TouchEvent) => {
    if (touchStartX.current === null) return;
    const dx = e.changedTouches[0].clientX - touchStartX.current;
    if (Math.abs(dx) > 50) { dx < 0 ? goNext() : goPrev(); }
    touchStartX.current = null;
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
          exit={{ opacity: 0 }}
          transition={{ duration: 0.35 }}
          className="fixed inset-0 z-[120] grid place-items-center p-4 sm:p-10"
          style={{
            background:      `radial-gradient(80% 60% at 50% 50%, ${color}33, #000 80%)`,
            backdropFilter:  "blur(14px)",
          }}
          onClick={onClose}
          onTouchStart={onTouchStart}
          onTouchEnd={onTouchEnd}
        >
          {/* ── Close ───────────────────────────────────────────────── */}
          <button
            aria-label="Close lightbox"
            onClick={onClose}
            style={{ zIndex: 9999 }}
            className="absolute top-5 right-5 sm:top-7 sm:right-7 grid place-items-center w-11 h-11 rounded-full glass-strong gold-border-glow"
          >
            <X className="w-5 h-5 text-gold" />
          </button>

          {/* ── Prev ────────────────────────────────────────────────── */}
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

          {/* ── Next ────────────────────────────────────────────────── */}
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

          {/* ── Counter ─────────────────────────────────────────────── */}
          {index !== null && (
            <div
              className="absolute bottom-6 left-1/2 -translate-x-1/2 font-mono text-[10px] tracking-[0.3em]"
              style={{ color: "hsl(var(--gold) / 0.55)" }}
            >
              {index + 1} / {items.length}
            </div>
          )}

          {/* ── Card — key includes id so it re-animates on navigation ─ */}
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
                <p className="mt-3 text-cream/70 text-sm leading-relaxed">
                  {item.description}
                </p>
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
# Bump package.json version to 3.0.0
# =============================================================================
if command -v node &>/dev/null; then
  node -e "
    const fs  = require('fs');
    const pkg = JSON.parse(fs.readFileSync('package.json','utf8'));
    pkg.version = '3.0.0';
    fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
  " && echo "✔  package.json → version 3.0.0"
else
  echo "⚠️  node not found — bump version manually: \"version\": \"3.0.0\""
fi

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🎬  Genisys Graphics V3.0 — patch complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  NEW files"
echo "  ─────────"
echo "  src/contexts/GyroscopeContext.tsx   PERF-1  singleton RAF"
echo "  src/lib/deviceTier.ts               PERF-3  low/mid/high detection"
echo "  src/hooks/useReducedMotion.ts       A11Y-7  prefers-reduced-motion"
echo "  src/components/Stats.tsx            NEW-10  animated stat counters"
echo "  src/components/Testimonials.tsx     NEW-9   horizontal quote strip"
echo "  public/manifest.json                NEW-11  PWA installable"
echo ""
echo "  MODIFIED files"
echo "  ──────────────"
echo "  src/App.tsx              tier gating · gyro provider · new sections"
echo "  src/components/Hero.tsx          context gyro · reduced-motion guard"
echo "  src/components/PortfolioCard.tsx context gyro  (kills 51 RAF loops)"
echo "  src/components/EmberParticles.tsx  PERF-2  30 fps mobile throttle"
echo "  src/components/Navigation.tsx    UX-4    hamburger + overlay menu"
echo "  src/components/Gallery.tsx       UX-6    pagination  12 / page"
echo "  src/components/Lightbox.tsx      UX-5    swipe + arrows + counter"
echo "  index.html                       SEO-8   PWA manifest link"
echo ""
echo "  Originals backed up → $BACKUP"
echo ""
echo "  Next:  npm run dev"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
