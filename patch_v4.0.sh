#!/usr/bin/env bash
# =============================================================================
#  GENISYS GRAPHICS — PATCH v4.0  "The Milestone"
#
#  CHANGES:
#    1. Three-dot button REMOVED from header
#    2. Music button moved INTO the header (right side) — never blocks content
#    3. MusicPlayer panel launches from header, not floating on screen
#    4. Hamburger menu rebuilt as a premium full-drawer with:
#         • Nav: WORK / SERVICES / STUDIO / PROCESS / FAQ  (FAQ was missing)
#         • Availability badge live from siteConfig
#         • Quick actions: Start a Project, Copy Email
#         • Settings section inline with all toggles + reset
#         • Social links row
#         • Build version at the very bottom
#    5. All floating buttons (music, back-to-top) tucked to safe corners
#    6. Version bumped to 4.0.0
# =============================================================================
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
echo "  Genisys v4.0 patch - starting ..."

# ─────────────────────────────────────────────────────────────────────────────
# 1. Rewrite Navigation — hamburger-only, music in header
# ─────────────────────────────────────────────────────────────────────────────
echo "  [1/4] Rewriting Navigation.tsx ..."
python3 << 'PYEOF'
content = r"""/**
 * Navigation — v4.0
 *
 * Top bar:  [hamburger]  GENISYS  [music-icon]
 *
 * Hamburger opens a full left-drawer containing:
 *   • Nav links (WORK / SERVICES / STUDIO / PROCESS / FAQ)
 *   • Live availability badge
 *   • Quick-action buttons (Start a Project, Copy Email)
 *   • Settings section — every toggle inline
 *   • Social links
 *   • Build version footer
 *
 * The music icon in the top-right is a compact header button that opens
 * the MusicPlayer panel — it no longer floats over the page.
 */
import { useEffect, useRef, useState } from "react";
import { AnimatePresence, motion }     from "framer-motion";
import {
  Menu, X, RotateCcw, Music2,
  Copy, Check, Zap, ChevronDown, ChevronUp,
} from "lucide-react";
import { useScramble }                        from "@/hooks/useScramble";
import { navigatePage, navigateSection, type Route } from "@/lib/router";
import { SOCIAL, STUDIO }                     from "@/data/siteConfig";
import SocialIcon                             from "@/components/SocialIcon";
import { useSettings, type Settings }         from "@/contexts/SettingsContext";

interface Props {
  route:          Route;
  /** Pass the playing state from MusicPlayer so the icon animates */
  musicPlaying?:  boolean;
  /** Callback to toggle the music panel open/closed */
  onMusicToggle?: () => void;
}

const PAGE_LINKS = [
  { label: "WORK",     action: () => navigateSection("work"),    page: null,       section: "work"    },
  { label: "SERVICES", action: () => navigatePage("services"),   page: "services", section: null      },
  { label: "STUDIO",   action: () => navigatePage("studio"),     page: "studio",   section: null      },
  { label: "PROCESS",  action: () => navigateSection("process"), page: null,       section: "process" },
  { label: "FAQ",      action: () => navigateSection("faq"),     page: null,       section: "faq"     },
] as const;

const SETTING_META: { key: keyof Settings; label: string; sub: string }[] = [
  { key: "particles",      label: "Ember Particles",   sub: "Floating gold sparks"   },
  { key: "aurora",         label: "Aurora Background", sub: "Colour-shift glow"      },
  { key: "goldDust",       label: "Gold Dust Trail",   sub: "Cursor sparkle trail"   },
  { key: "magneticCursor", label: "Magnetic Cursor",   sub: "Cursor blob effect"     },
  { key: "smoothScroll",   label: "Smooth Scroll",     sub: "Inertia scroll feel"    },
  { key: "clickBurst",     label: "Click Burst",       sub: "Tap sparkle burst"      },
  { key: "letterbox",      label: "Letterbox Bars",    sub: "Cinematic black bars"   },
  { key: "scrollVignette", label: "Scroll Vignette",   sub: "Edge fade on scroll"    },
  { key: "scrollProgress", label: "Progress Bar",      sub: "Top scroll indicator"   },
  { key: "commandPalette", label: "Command Palette",   sub: "Cmd+K quick search"     },
  { key: "reducedMotion",  label: "Reduce All Motion", sub: "Disables all animation" },
];

export default function Navigation({ route, musicPlaying, onMusicToggle }: Props) {
  const brand                        = useScramble("GENISYS", 900);
  const [open,          setOpen]     = useState(false);
  const [settingsOpen,  setSOOpen]   = useState(false);
  const [activeSection, setActive]   = useState("");
  const [copied,        setCopied]   = useState(false);
  const { settings, toggle, resetAll } = useSettings();
  const eqDelays = [0, 0.18, 0.36, 0.12];

  // Scroll-spy
  useEffect(() => {
    if (route.page !== "home") { setActive(""); return; }
    if (typeof IntersectionObserver === "undefined") return;
    const obs = new IntersectionObserver(
      entries => entries.forEach(e => { if (e.isIntersecting) setActive(e.target.id); }),
      { rootMargin: "-25% 0px -65% 0px", threshold: 0 },
    );
    ["work", "about", "process", "faq"].forEach(id => {
      const el = document.getElementById(id);
      if (el) obs.observe(el);
    });
    return () => obs.disconnect();
  }, [route.page]);

  // Lock scroll when drawer open
  useEffect(() => {
    if (!open) return;
    const sw = window.innerWidth - document.documentElement.clientWidth;
    document.body.style.overflow     = "hidden";
    document.body.style.paddingRight = `${sw}px`;
    return () => {
      document.body.style.overflow     = "";
      document.body.style.paddingRight = "";
    };
  }, [open]);

  useEffect(() => { setOpen(false); }, [route]);

  const isActive = (l: typeof PAGE_LINKS[number]) => {
    if (l.page    && route.page === l.page)                                return true;
    if (l.section && route.page === "home" && activeSection === l.section) return true;
    return false;
  };

  const copyEmail = async () => {
    try {
      await navigator.clipboard.writeText(STUDIO.email);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch { /**/ }
  };

  return (
    <>
      {/* ── Top bar ────────────────────────────────────────────────── */}
      <header
        className="fixed top-0 left-0 right-0 z-[70] flex items-center justify-between px-3"
        style={{
          height:               "56px",
          background:           "rgba(0,0,0,0.78)",
          backdropFilter:       "blur(22px)",
          WebkitBackdropFilter: "blur(22px)",
          borderBottom:         "1px solid hsl(var(--gold)/0.1)",
        }}
      >
        {/* LEFT — hamburger */}
        <button
          onClick={() => setOpen(true)}
          aria-label="Open menu"
          aria-expanded={open}
          className="grid place-items-center w-10 h-10 rounded-xl transition-colors hover:bg-white/[0.06] text-cream/65 hover:text-gold"
        >
          <Menu className="w-5 h-5" />
        </button>

        {/* CENTER — brand */}
        <button
          onClick={() => navigateSection("top")}
          className="font-display font-black text-base gold-text tracking-tight select-none"
        >
          {brand}
        </button>

        {/* RIGHT — compact music button */}
        <button
          onClick={onMusicToggle}
          aria-label={musicPlaying ? "Music playing — open player" : "Open music player"}
          className="grid place-items-center w-10 h-10 rounded-xl transition-colors hover:bg-white/[0.06]"
        >
          {musicPlaying ? (
            <span className="flex items-end gap-[2.5px] h-4" aria-hidden>
              {eqDelays.map((delay, i) => (
                <span
                  key={i}
                  className="eq-bar w-[2.5px] rounded-sm"
                  style={{
                    height:          "100%",
                    background:      "hsl(var(--gold))",
                    animationDelay:  `${delay}s`,
                    transformOrigin: "bottom",
                    boxShadow:       "0 0 5px hsl(var(--gold)/0.7)",
                  }}
                />
              ))}
            </span>
          ) : (
            <Music2 className="w-4 h-4 text-cream/50 hover:text-gold transition-colors" />
          )}
        </button>
      </header>

      {/* Spacer so page content clears the bar */}
      <div style={{ height: "56px" }} aria-hidden />

      {/* ── Full left drawer ───────────────────────────────────────── */}
      <AnimatePresence>
        {open && (
          <>
            {/* Backdrop */}
            <motion.div
              key="backdrop"
              initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
              transition={{ duration: 0.28 }}
              className="fixed inset-0 z-[148]"
              style={{ background: "rgba(0,0,0,0.65)", backdropFilter: "blur(4px)", WebkitBackdropFilter: "blur(4px)" }}
              onClick={() => setOpen(false)}
            />

            {/* Drawer */}
            <motion.div
              key="drawer"
              initial={{ x: "-100%" }} animate={{ x: 0 }} exit={{ x: "-100%" }}
              transition={{ duration: 0.38, ease: [0.7, 0, 0.3, 1] }}
              className="fixed top-0 left-0 bottom-0 z-[149] flex flex-col overflow-hidden"
              style={{
                width:                "min(320px, 88vw)",
                background:           "rgba(5,5,5,0.98)",
                backdropFilter:       "blur(40px)",
                WebkitBackdropFilter: "blur(40px)",
                borderRight:          "1px solid hsl(var(--gold)/0.14)",
              }}
            >

              {/* Drawer header */}
              <div className="flex items-center justify-between px-5 py-4 flex-none"
                style={{ borderBottom: "1px solid hsl(0 0% 100% / 0.055)" }}>
                <div className="flex items-center gap-2.5">
                  <span className="font-display font-black text-sm gold-text tracking-tight">GENISYS</span>
                  {/* Availability dot */}
                  {STUDIO.availability.accepting && (
                    <span
                      className="flex items-center gap-1.5 px-2 py-0.5 rounded-full font-mono text-[8px] tracking-[0.2em]"
                      style={{ background: "hsl(142 70% 45% / 0.12)", border: "1px solid hsl(142 70% 45% / 0.3)", color: "hsl(142 70% 55%)" }}
                    >
                      <span className="w-1.5 h-1.5 rounded-full bg-green-400 animate-pulse" />
                      OPEN
                    </span>
                  )}
                </div>
                <button
                  onClick={() => setOpen(false)}
                  aria-label="Close menu"
                  className="grid place-items-center w-8 h-8 rounded-xl text-cream/35 hover:text-gold transition-colors"
                  style={{ background: "hsl(0 0% 100% / 0.04)", border: "1px solid hsl(0 0% 100% / 0.07)" }}
                >
                  <X className="w-3.5 h-3.5" />
                </button>
              </div>

              {/* Scrollable body */}
              <div className="flex-1 overflow-y-auto overscroll-contain" style={{ scrollbarWidth: "none" }}>

                {/* ── Navigation links ───────────────────── */}
                <div className="px-3 pt-4 pb-2">
                  <p className="font-mono text-[8px] tracking-[0.45em] text-gold/40 px-2 mb-2">NAVIGATE</p>
                  <nav className="flex flex-col gap-0.5">
                    {PAGE_LINKS.map((l, i) => (
                      <motion.button
                        key={l.label}
                        onClick={() => { l.action(); setOpen(false); }}
                        initial={{ opacity: 0, x: -18 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ duration: 0.28, delay: 0.05 + i * 0.06, ease: [0.7, 0, 0.3, 1] }}
                        className={
                          "w-full flex items-center gap-3 px-4 py-3 rounded-xl text-left transition-colors " +
                          (isActive(l) ? "bg-gold/[0.09]" : "hover:bg-white/[0.04]")
                        }
                      >
                        {isActive(l) && (
                          <span className="w-[3px] h-4 rounded-full flex-none" style={{ background: "hsl(var(--gold))" }} />
                        )}
                        <span className={"font-mono text-[11px] tracking-[0.32em] " + (isActive(l) ? "text-gold" : "text-cream/65")}>
                          {l.label}
                        </span>
                      </motion.button>
                    ))}
                  </nav>
                </div>

                <div className="mx-5 my-3" style={{ height: "1px", background: "hsl(0 0% 100% / 0.055)" }} />

                {/* ── Quick actions ──────────────────────── */}
                <div className="px-3 pb-2">
                  <p className="font-mono text-[8px] tracking-[0.45em] text-gold/40 px-2 mb-2">QUICK ACTIONS</p>

                  <motion.button
                    initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.28, delay: 0.38 }}
                    onClick={() => { setOpen(false); window.dispatchEvent(new Event("open-contact")); }}
                    className="w-full flex items-center gap-3 px-4 py-3 rounded-xl text-left transition-colors hover:bg-gold/[0.07] mb-1"
                    style={{ border: "1px solid hsl(var(--gold)/0.2)", background: "hsl(var(--gold)/0.04)" }}
                  >
                    <Zap className="w-4 h-4 text-gold flex-none" />
                    <div>
                      <p className="font-mono text-[10px] tracking-[0.25em] text-gold">START A PROJECT</p>
                      {STUDIO.availability.accepting && (
                        <p className="font-mono text-[8px] text-cream/30 mt-0.5">
                          Next slot: {STUDIO.availability.nextSlot}
                        </p>
                      )}
                    </div>
                  </motion.button>

                  <motion.button
                    initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.28, delay: 0.44 }}
                    onClick={copyEmail}
                    className="w-full flex items-center gap-3 px-4 py-3 rounded-xl text-left transition-colors hover:bg-white/[0.04]"
                  >
                    {copied
                      ? <Check className="w-4 h-4 text-green-400 flex-none" />
                      : <Copy  className="w-4 h-4 text-cream/35 flex-none" />
                    }
                    <div>
                      <p className={"font-mono text-[10px] tracking-[0.2em] " + (copied ? "text-green-400" : "text-cream/60")}>
                        {copied ? "COPIED!" : "COPY EMAIL"}
                      </p>
                      <p className="font-mono text-[8px] text-cream/25 mt-0.5 truncate">{STUDIO.email}</p>
                    </div>
                  </motion.button>
                </div>

                <div className="mx-5 my-3" style={{ height: "1px", background: "hsl(0 0% 100% / 0.055)" }} />

                {/* ── Settings ───────────────────────────── */}
                <div className="px-3 pb-2">
                  <button
                    onClick={() => setSOOpen(p => !p)}
                    className="w-full flex items-center justify-between px-2 mb-1"
                  >
                    <p className="font-mono text-[8px] tracking-[0.45em] text-gold/40">EXPERIENCE SETTINGS</p>
                    {settingsOpen
                      ? <ChevronUp   className="w-3 h-3 text-cream/30" />
                      : <ChevronDown className="w-3 h-3 text-cream/30" />
                    }
                  </button>

                  <AnimatePresence initial={false}>
                    {settingsOpen && (
                      <motion.div
                        key="settings-body"
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: "auto", opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        transition={{ duration: 0.3, ease: [0.7, 0, 0.3, 1] }}
                        style={{ overflow: "hidden" }}
                      >
                        <div className="space-y-0.5 py-1">
                          {SETTING_META.map(({ key, label, sub }) => (
                            <button
                              key={key}
                              onClick={() => toggle(key)}
                              className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-left transition-colors hover:bg-white/[0.04]"
                            >
                              {/* Toggle pill */}
                              <div
                                className="flex-none relative w-9 h-[18px] rounded-full transition-all duration-300"
                                style={{
                                  background: settings[key] ? "hsl(var(--gold)/0.9)" : "hsl(0 0% 100% / 0.1)",
                                  border:     settings[key] ? "1px solid hsl(var(--gold))" : "1px solid hsl(0 0% 100% / 0.15)",
                                }}
                              >
                                <span
                                  className="absolute top-[2px] w-[14px] h-[14px] rounded-full transition-all duration-300"
                                  style={{
                                    left:       settings[key] ? "calc(100% - 16px)" : "2px",
                                    background: settings[key] ? "#000" : "hsl(0 0% 100% / 0.4)",
                                    boxShadow:  settings[key] ? "0 0 5px hsl(var(--gold)/0.5)" : "none",
                                  }}
                                />
                              </div>
                              <div className="flex-1 min-w-0">
                                <p className={"font-mono text-[9px] tracking-[0.15em] " +
                                  (settings[key] ? "text-cream/80" : "text-cream/28")}>
                                  {label}
                                </p>
                                <p className="font-mono text-[7px] text-cream/18 leading-snug">{sub}</p>
                              </div>
                            </button>
                          ))}
                        </div>

                        <button
                          onClick={resetAll}
                          className="mt-2 w-full flex items-center justify-center gap-2 py-2 rounded-xl font-mono text-[8px] tracking-[0.25em] text-cream/22 hover:text-gold transition-colors"
                          style={{ border: "1px solid hsl(0 0% 100% / 0.06)" }}
                        >
                          <RotateCcw className="w-3 h-3" />
                          RESET ALL TO DEFAULT
                        </button>
                      </motion.div>
                    )}
                  </AnimatePresence>
                </div>

                <div className="mx-5 my-3" style={{ height: "1px", background: "hsl(0 0% 100% / 0.055)" }} />

                {/* ── Socials ────────────────────────────── */}
                <div className="px-5 pb-4">
                  <p className="font-mono text-[8px] tracking-[0.45em] text-gold/40 mb-3">FOLLOW</p>
                  <div className="flex flex-wrap gap-2">
                    {Object.entries(SOCIAL).map(([platform, url]) => (
                      <a
                        key={platform}
                        href={url} target="_blank" rel="noopener noreferrer"
                        aria-label={platform}
                        className="w-9 h-9 grid place-items-center rounded-xl transition-all hover:scale-110"
                        style={{ background: "hsl(var(--gold)/0.07)", border: "1px solid hsl(var(--gold)/0.18)", color: "hsl(var(--gold)/0.65)" }}
                      >
                        <SocialIcon platform={platform} size={14} />
                      </a>
                    ))}
                  </div>
                </div>
              </div>

              {/* Drawer footer — version */}
              <div
                className="flex-none px-5 py-3 flex items-center justify-between"
                style={{ borderTop: "1px solid hsl(0 0% 100% / 0.055)" }}
              >
                <p className="font-mono text-[7px] tracking-[0.3em] text-cream/15">
                  GENISYS GRAPHICS © {new Date().getFullYear()}
                </p>
                <p className="font-mono text-[7px] tracking-[0.2em] text-cream/12">v4.0.0</p>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </>
  );
}
"""
open("src/components/Navigation.tsx", "w").write(content)
print("  ok  Navigation.tsx written")
PYEOF

# ─────────────────────────────────────────────────────────────────────────────
# 2. Rewrite MusicPlayer — remove floating button, controlled by header
# ─────────────────────────────────────────────────────────────────────────────
echo "  [2/4] Rewriting MusicPlayer.tsx ..."
python3 << 'PYEOF'
content = r"""/**
 * MusicPlayer — v4.0
 *
 * No longer a floating button.
 * Controlled via props from App.tsx which passes state up to Navigation.
 * The header music icon (in Navigation) calls onMusicToggle.
 * This component only renders:
 *   1. The ambient background EQ canvas (always present while playing)
 *   2. The sliding panel (opened/closed via the `open` prop)
 */
import { useEffect, useRef, useState, useImperativeHandle, forwardRef } from "react";
import { AnimatePresence, motion }     from "framer-motion";
import { List, Music2, Pause, Play, SkipBack, SkipForward, Volume2, X } from "lucide-react";
import { PLAYLIST }  from "@/data/musicConfig";
import { haptic }    from "@/lib/haptics";

export interface MusicPlayerHandle {
  playing: boolean;
}

interface Props {
  open:     boolean;
  onClose:  () => void;
}

const MusicPlayer = forwardRef<MusicPlayerHandle, Props>(function MusicPlayer(
  { open, onClose },
  ref,
) {
  const [trackIdx, setTrackIdx] = useState(0);
  const [playing,  setPlaying]  = useState(false);
  const [progress, setProgress] = useState(0);
  const [duration, setDuration] = useState(0);
  const [showList, setShowList] = useState(false);
  const [graphOk,  setGraphOk]  = useState(false);

  const audioRef      = useRef<HTMLAudioElement | null>(null);
  const ctxRef        = useRef<AudioContext | null>(null);
  const analyserRef   = useRef<AnalyserNode | null>(null);
  const bgCanvasRef   = useRef<HTMLCanvasElement | null>(null);
  const panCanvasRef  = useRef<HTMLCanvasElement | null>(null);
  const animRef       = useRef<number>(0);
  const playingRef    = useRef(false);
  const idxRef        = useRef(0);

  // Expose playing state to parent via ref
  useImperativeHandle(ref, () => ({ playing }), [playing]);

  // Single audio element
  useEffect(() => {
    const a   = new Audio(PLAYLIST[0].src);
    a.preload = "metadata";
    a.volume  = 0.42;
    a.addEventListener("timeupdate",     () => setProgress(a.currentTime));
    a.addEventListener("loadedmetadata", () => setDuration(a.duration || 0));
    a.addEventListener("ended", () => {
      const next = (idxRef.current + 1) % PLAYLIST.length;
      setTrackIdx(next);
      setPlaying(true);
    });
    audioRef.current = a;
    return () => { a.pause(); a.src = ""; cancelAnimationFrame(animRef.current); ctxRef.current?.close(); };
  }, []);

  // Swap src on track change
  useEffect(() => {
    idxRef.current = trackIdx;
    const a = audioRef.current;
    if (!a) return;
    a.src = PLAYLIST[trackIdx].src;
    a.load();
    setProgress(0);
    if (playingRef.current) a.play().catch(() => setPlaying(false));
  }, [trackIdx]);

  // Play / pause
  useEffect(() => {
    playingRef.current = playing;
    const a = audioRef.current;
    if (!a) return;
    if (playing) {
      if (!ctxRef.current) {
        try {
          const AudioCtx = window.AudioContext ||
            (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext;
          const ctx = new AudioCtx();
          const src = ctx.createMediaElementSource(a);
          const an  = ctx.createAnalyser();
          an.fftSize = 128; an.smoothingTimeConstant = 0.80;
          src.connect(an); an.connect(ctx.destination);
          ctxRef.current = ctx; analyserRef.current = an;
          setGraphOk(true);
        } catch { console.warn("[MusicPlayer] Web Audio unavailable"); }
      }
      ctxRef.current?.resume();
      a.play().catch(() => setPlaying(false));
    } else {
      a.pause();
    }
  }, [playing]);

  // Keep BG canvas sized to viewport
  useEffect(() => {
    const resize = () => {
      const c = bgCanvasRef.current;
      if (!c) return;
      c.width = window.innerWidth; c.height = window.innerHeight;
    };
    resize();
    window.addEventListener("resize", resize, { passive: true });
    return () => window.removeEventListener("resize", resize);
  }, []);

  // Animation loop
  useEffect(() => {
    const analyser = analyserRef.current;
    cancelAnimationFrame(animRef.current);

    if (!playing || !analyser) {
      const bg  = bgCanvasRef.current;
      const pan = panCanvasRef.current;
      if (bg)  { const c = bg.getContext("2d");  if (c) c.clearRect(0,0,bg.width,bg.height); }
      if (pan) {
        const c = pan.getContext("2d");
        if (c) {
          c.clearRect(0,0,pan.width,pan.height);
          const cols = 24, bw = pan.width/cols;
          for (let i=0;i<cols;i++) {
            const h = 2 + Math.sin(i*0.6)*2;
            c.fillStyle = `hsla(44,72%,54%,0.1)`;
            c.fillRect(i*bw, pan.height-h, bw-1, h);
          }
        }
      }
      return;
    }

    const bufLen = analyser.frequencyBinCount;
    const freq   = new Uint8Array(bufLen);

    const tick = () => {
      animRef.current = requestAnimationFrame(tick);
      analyser.getByteFrequencyData(freq);

      // Background — wide subtle bars
      const bg = bgCanvasRef.current;
      if (bg && bg.width > 0) {
        const ctx = bg.getContext("2d");
        if (ctx) {
          ctx.clearRect(0,0,bg.width,bg.height);
          const cols = 16, bw = bg.width/cols, step = Math.floor(bufLen/cols);
          for (let i=0;i<cols;i++) {
            let sum=0; for (let k=0;k<step;k++) sum+=freq[i*step+k];
            const norm=(sum/step)/255;
            ctx.fillStyle=`hsla(44,72%,54%,${0.025+norm*0.045})`;
            ctx.fillRect(i*bw, bg.height-norm*bg.height*0.5, bw-2, norm*bg.height*0.5);
          }
        }
      }

      // Panel visualiser
      const pan = panCanvasRef.current;
      if (pan && pan.width > 0) {
        const ctx = pan.getContext("2d");
        if (ctx) {
          ctx.clearRect(0,0,pan.width,pan.height);
          const bw = pan.width/bufLen;
          for (let i=0;i<bufLen;i++) {
            const norm=freq[i]/255, h=Math.max(2,norm*pan.height);
            ctx.fillStyle=`hsla(44,72%,54%,${0.22+norm*0.78})`;
            ctx.fillRect(i*bw, pan.height-h, bw-1, h);
          }
        }
      }
    };
    tick();
    return () => cancelAnimationFrame(animRef.current);
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [playing, graphOk]);

  const prevTrack  = () => { haptic(8); const a=audioRef.current; if(a&&a.currentTime>3){a.currentTime=0;return;} setTrackIdx(i=>(i-1+PLAYLIST.length)%PLAYLIST.length); };
  const nextTrack  = () => { haptic(8); setTrackIdx(i=>(i+1)%PLAYLIST.length); };
  const togglePlay = () => { haptic(15); setPlaying(p=>!p); };

  const seek = (e: React.MouseEvent<HTMLDivElement>) => {
    const a=audioRef.current; if(!a||!duration) return;
    const r=e.currentTarget.getBoundingClientRect();
    a.currentTime=Math.max(0,Math.min(duration,((e.clientX-r.left)/r.width)*duration));
  };

  const fmt = (s: number) =>
    (!isFinite(s)||isNaN(s)) ? "0:00"
      : `${Math.floor(s/60)}:${String(Math.floor(s%60)).padStart(2,"0")}`;

  const track = PLAYLIST[trackIdx];
  const pct   = duration ? Math.min(100,(progress/duration)*100) : 0;

  return (
    <>
      {/* Ambient BG EQ canvas */}
      <canvas
        ref={bgCanvasRef}
        aria-hidden
        className="fixed inset-0 pointer-events-none"
        style={{ zIndex: 3 }}
      />

      {/* Sliding panel — opens from top bar */}
      <AnimatePresence>
        {open && (
          <>
            {/* Backdrop */}
            <motion.div
              key="mp-backdrop"
              initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
              transition={{ duration: 0.22 }}
              className="fixed inset-0 z-[88]"
              style={{ background: "rgba(0,0,0,0.45)" }}
              onClick={onClose}
            />

            {/* Panel — drops down from just below the header */}
            <motion.div
              key="mp-panel"
              initial={{ opacity: 0, y: -16, scale: 0.97 }}
              animate={{ opacity: 1,  y: 0,  scale: 1    }}
              exit={{   opacity: 0,  y: -10, scale: 0.98 }}
              transition={{ duration: 0.3, ease: [0.7, 0, 0.3, 1] }}
              className="fixed z-[89] glass-strong specular rounded-2xl overflow-hidden"
              style={{
                top:       "64px",
                right:     "12px",
                width:     "min(300px, calc(100vw - 24px))",
                border:    "1px solid hsl(var(--gold)/0.25)",
                boxShadow: "0 8px 48px hsl(var(--gold)/0.08)",
              }}
            >
              {/* Header row */}
              <div className="flex items-center justify-between px-4 py-3 border-b border-white/[0.06]">
                <div>
                  <p className="font-mono text-[8px] tracking-[0.45em] text-gold/60">NOW PLAYING</p>
                  <p className="font-mono text-[11px] tracking-[0.12em] text-cream/90 mt-0.5 truncate max-w-[180px]">
                    {track.title}
                  </p>
                </div>
                <button onClick={onClose} aria-label="Close player"
                  className="grid place-items-center w-8 h-8 rounded-full text-cream/35 hover:text-gold transition-colors"
                  style={{ background: "hsl(0 0% 100%/0.04)", border: "1px solid hsl(0 0% 100%/0.08)" }}>
                  <X className="w-3.5 h-3.5" />
                </button>
              </div>

              {/* Visualiser */}
              <canvas ref={panCanvasRef} width={300} height={36} className="w-full block" aria-hidden
                style={{ opacity: playing ? 1 : 0.45, transition: "opacity 0.5s" }} />

              {/* Seek bar */}
              <div className="w-full cursor-pointer relative" style={{ height: "3px", background: "hsl(0 0% 100%/0.07)" }}
                onClick={seek} role="slider" aria-label="Seek" aria-valuenow={Math.round(pct)} aria-valuemin={0} aria-valuemax={100}>
                <div className="absolute inset-y-0 left-0"
                  style={{ width:`${pct}%`, background:"hsl(var(--gold)/0.85)", transition:"width 0.25s linear" }} />
              </div>

              {/* Time */}
              <div className="flex justify-between px-4 pt-2">
                <span className="font-mono text-[8px] text-cream/22">{fmt(progress)}</span>
                <span className="font-mono text-[8px] text-cream/22">{fmt(duration)}</span>
              </div>

              {/* Controls */}
              <div className="flex items-center justify-center gap-3 px-4 py-3">
                {PLAYLIST.length > 1 && (
                  <button onClick={prevTrack} aria-label="Previous"
                    className="grid place-items-center w-8 h-8 rounded-lg text-cream/50 hover:text-gold transition-colors">
                    <SkipBack className="w-4 h-4" />
                  </button>
                )}
                <button onClick={togglePlay} aria-label={playing ? "Pause" : "Play"}
                  className="grid place-items-center w-12 h-12 rounded-full transition-all hover:scale-105"
                  style={{ background:"hsl(var(--gold)/0.14)", border:"1px solid hsl(var(--gold)/0.45)" }}>
                  {playing ? <Pause className="w-5 h-5 text-gold" /> : <Play className="w-5 h-5 text-gold translate-x-[1px]" />}
                </button>
                {PLAYLIST.length > 1 && (
                  <button onClick={nextTrack} aria-label="Next"
                    className="grid place-items-center w-8 h-8 rounded-lg text-cream/50 hover:text-gold transition-colors">
                    <SkipForward className="w-4 h-4" />
                  </button>
                )}
                <button onClick={() => setShowList(p=>!p)} aria-label="Playlist" aria-expanded={showList}
                  className={"grid place-items-center w-8 h-8 rounded-lg transition-colors ml-1 " +
                    (showList ? "text-gold bg-gold/10" : "text-cream/40 hover:text-gold")}>
                  <List className="w-4 h-4" />
                </button>
              </div>

              {/* Playlist */}
              <AnimatePresence>
                {showList && (
                  <motion.div key="playlist"
                    initial={{ height:0, opacity:0 }} animate={{ height:"auto", opacity:1 }} exit={{ height:0, opacity:0 }}
                    transition={{ duration:0.28, ease:[0.7,0,0.3,1] }} style={{ overflow:"hidden" }}>
                    <div className="border-t border-white/[0.06]">
                      <p className="font-mono text-[8px] tracking-[0.4em] text-gold/50 px-4 py-2">PLAYLIST</p>
                      <div className="max-h-44 overflow-y-auto overscroll-contain" style={{ scrollbarWidth:"none" }}>
                        {PLAYLIST.map((t,i) => (
                          <button key={t.id}
                            onClick={() => { haptic(8); setTrackIdx(i); setPlaying(true); setShowList(false); }}
                            className={"w-full flex items-center gap-3 px-4 py-2.5 text-left transition-colors hover:bg-white/[0.04] " +
                              (i===trackIdx ? "bg-gold/[0.07]" : "")}>
                            <div className="flex-none w-7 h-7 rounded-lg grid place-items-center"
                              style={{ background:`${t.accent??"#C8A84B"}18`, border:`1px solid ${t.accent??"#C8A84B"}44` }}>
                              {i===trackIdx&&playing
                                ? <Volume2 className="w-3 h-3" style={{ color:t.accent??"#C8A84B" }} />
                                : <Music2  className="w-3 h-3 text-cream/30" />
                              }
                            </div>
                            <div className="flex-1 min-w-0">
                              <p className={"font-mono text-[10px] tracking-[0.1em] truncate " + (i===trackIdx?"text-gold":"text-cream/70")}>{t.title}</p>
                              <p className="font-mono text-[8px] text-cream/28 truncate">{t.artist}</p>
                            </div>
                            {i===trackIdx && (
                              <span className="flex-none flex items-end gap-[2px]" style={{ height:"14px" }}>
                                {[0,0.15,0.3,0.08].map((delay,j) => (
                                  <span key={j} className={playing?"eq-bar":""}
                                    style={{ display:"block", width:"2px", height:"100%", borderRadius:"1px",
                                      background:"hsl(var(--gold)/0.75)", transformOrigin:"bottom", animationDelay:`${delay}s` }} />
                                ))}
                              </span>
                            )}
                          </button>
                        ))}
                      </div>
                    </div>
                  </motion.div>
                )}
              </AnimatePresence>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </>
  );
});

export default MusicPlayer;
"""
open("src/components/MusicPlayer.tsx", "w").write(content)
print("  ok  MusicPlayer.tsx written")
PYEOF

# ─────────────────────────────────────────────────────────────────────────────
# 3. Update App.tsx — wire music state to Navigation + MusicPlayer
# ─────────────────────────────────────────────────────────────────────────────
echo "  [3/4] Updating App.tsx ..."
python3 << 'PYEOF'
src = open("src/App.tsx").read()

# Replace MusicPlayer import to include the ref handle type
src = src.replace(
    'import MusicPlayer               from "@/components/MusicPlayer";',
    'import MusicPlayer, { type MusicPlayerHandle } from "@/components/MusicPlayer";',
)

# Add useRef to the react import if not already there
if 'useRef' not in src:
    src = src.replace(
        'import { useEffect, useState }   from "react";',
        'import { useEffect, useRef, useState } from "react";',
    )

# Add musicOpen state + musicRef after existing state declarations
old_state = '  const [contactOpen,   setOpen]          = useState(false);\n  const [cookieShowing, setCookieShowing] = useState(false);'
new_state  = (
    '  const [contactOpen,   setOpen]          = useState(false);\n'
    '  const [cookieShowing, setCookieShowing] = useState(false);\n'
    '  const [musicOpen,     setMusicOpen]     = useState(false);\n'
    '  const musicRef = useRef<MusicPlayerHandle>(null);'
)
if old_state in src:
    src = src.replace(old_state, new_state)

# Wire Navigation props
src = src.replace(
    '<Navigation route={route} />',
    '<Navigation route={route} musicPlaying={musicRef.current?.playing} onMusicToggle={() => setMusicOpen(p => !p)} />',
)

# Wire MusicPlayer props
src = src.replace(
    '<MusicPlayer />',
    '<MusicPlayer ref={musicRef} open={musicOpen} onClose={() => setMusicOpen(false)} />',
)

open("src/App.tsx", "w").write(src)
print("  ok  App.tsx updated")
PYEOF

# ─────────────────────────────────────────────────────────────────────────────
# 4. Bump version
# ─────────────────────────────────────────────────────────────────────────────
echo "  [4/4] Bumping version to 4.0.0 ..."
python3 << 'PYEOF'
import json
p = json.load(open("package.json"))
p["version"] = "4.0.0"
json.dump(p, open("package.json", "w"), indent=2)
print("  ok  version -> 4.0.0")
PYEOF

echo ""
echo "=================================================================="
echo "  GENISYS v4.0  PATCH COMPLETE"
echo "=================================================================="
echo ""
echo "  HEADER:"
echo "    ok Three-dot button gone"
echo "    ok Music icon lives in the header top-right"
echo "    ok EQ bars animate in header when music plays"
echo "    ok Music panel drops down from header — never blocks content"
echo ""
echo "  HAMBURGER MENU:"
echo "    ok WORK / SERVICES / STUDIO / PROCESS / FAQ (FAQ was missing)"
echo "    ok Live availability badge (green dot + OPEN)"
echo "    ok Start a Project — shows next available slot"
echo "    ok Copy Email — one tap copies your email"
echo "    ok Experience Settings — all 11 toggles inline, collapsible"
echo "    ok Reset All button"
echo "    ok Social links row"
echo "    ok Version + copyright footer"
echo ""
echo "  Run: npm run dev"
echo "=================================================================="
