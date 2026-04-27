#!/usr/bin/env bash
# =============================================================================
#  GENISYS GRAPHICS — PATCH v3.8
#  Changes:
#    • Music bar removed from always-visible bottom strip
#    • Replaced with small circular button (same spot as old VibeToggle)
#    • Tap button → full music panel slides up (controls, playlist, visualiser)
#    • Panel has X to collapse back to the small button
#    • When music plays → ambient background EQ canvas appears behind all
#      content (z-[3], pointer-events-none, barely-visible gold bars)
# =============================================================================
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
echo "▶  Genisys v3.8 patch — starting …"

echo "  [1/3] Rewriting src/components/MusicPlayer.tsx …"
python3 - << 'PYEOF'
content = '''\
/**
 * MusicPlayer — v3.8
 *
 * Layout:
 *   • Small circular button (bottom-left, always present) — same spot as
 *     the old VibeToggle.  Shows EQ bars while playing, music icon while
 *     paused.
 *   • Tap button → panel slides up with full controls + playlist.
 *   • Panel X button → collapses back to just the small button.
 *   • While music plays → full-screen ambient EQ canvas sits behind all
 *     page content (z-3, pointer-events-none) as a living background.
 *
 * Add songs in  src/data/musicConfig.ts — no edits here needed.
 */
import { useEffect, useRef, useState } from "react";
import { AnimatePresence, motion }     from "framer-motion";
import {
  List, Music2, Pause, Play,
  SkipBack, SkipForward, Volume2, X,
} from "lucide-react";
import { PLAYLIST }  from "@/data/musicConfig";
import { haptic }    from "@/lib/haptics";

export default function MusicPlayer() {
  const [trackIdx, setTrackIdx] = useState(0);
  const [playing,  setPlaying]  = useState(false);
  const [open,     setOpen]     = useState(false);
  const [progress, setProgress] = useState(0);
  const [duration, setDuration] = useState(0);
  const [showList, setShowList] = useState(false);
  const [graphOk,  setGraphOk]  = useState(false);

  // Stable refs
  const audioRef      = useRef<HTMLAudioElement | null>(null);
  const ctxRef        = useRef<AudioContext | null>(null);
  const analyserRef   = useRef<AnalyserNode | null>(null);
  const bgCanvasRef   = useRef<HTMLCanvasElement | null>(null);
  const panCanvasRef  = useRef<HTMLCanvasElement | null>(null);
  const animRef       = useRef<number>(0);
  const playingRef    = useRef(false);
  const idxRef        = useRef(0);

  // ── 1. Single audio element ────────────────────────────────────────
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
    return () => {
      a.pause(); a.src = "";
      cancelAnimationFrame(animRef.current);
      ctxRef.current?.close();
    };
  }, []);

  // ── 2. Swap src on track change ────────────────────────────────────
  useEffect(() => {
    idxRef.current = trackIdx;
    const a = audioRef.current;
    if (!a) return;
    a.src = PLAYLIST[trackIdx].src;
    a.load();
    setProgress(0);
    if (playingRef.current) a.play().catch(() => setPlaying(false));
  }, [trackIdx]);

  // ── 3. Play / pause ────────────────────────────────────────────────
  useEffect(() => {
    playingRef.current = playing;
    const a = audioRef.current;
    if (!a) return;
    if (playing) {
      if (!ctxRef.current) {
        try {
          const AudioCtx =
            window.AudioContext ||
            (window as unknown as { webkitAudioContext: typeof AudioContext })
              .webkitAudioContext;
          const ctx = new AudioCtx();
          const src = ctx.createMediaElementSource(a);
          const an  = ctx.createAnalyser();
          an.fftSize              = 128;
          an.smoothingTimeConstant = 0.80;
          src.connect(an);
          an.connect(ctx.destination);
          ctxRef.current     = ctx;
          analyserRef.current = an;
          setGraphOk(true);
        } catch {
          console.warn("[MusicPlayer] Web Audio unavailable");
        }
      }
      ctxRef.current?.resume();
      a.play().catch(() => setPlaying(false));
    } else {
      a.pause();
    }
  }, [playing]);

  // ── 4. BG canvas: keep sized to viewport ──────────────────────────
  useEffect(() => {
    const resize = () => {
      const c = bgCanvasRef.current;
      if (!c) return;
      c.width  = window.innerWidth;
      c.height = window.innerHeight;
    };
    resize();
    window.addEventListener("resize", resize, { passive: true });
    return () => window.removeEventListener("resize", resize);
  }, []);

  // ── 5. Unified animation loop (draws bg + panel canvas each tick) ──
  useEffect(() => {
    const analyser = analyserRef.current;
    cancelAnimationFrame(animRef.current);

    // Helper: draw idle ghost bars on a canvas
    const drawIdle = (ctx: CanvasRenderingContext2D, w: number, h: number, cols: number, alpha: number) => {
      ctx.clearRect(0, 0, w, h);
      const bw = w / cols;
      for (let i = 0; i < cols; i++) {
        const barH = 2 + Math.sin(i * 0.6) * 2;
        ctx.fillStyle = `hsla(44,72%,54%,${alpha})`;
        ctx.fillRect(i * bw, h - barH, bw - 1, barH);
      }
    };

    if (!playing || !analyser) {
      // Idle states
      const bg  = bgCanvasRef.current;
      const pan = panCanvasRef.current;
      if (bg)  { const c = bg.getContext("2d");  if (c) c.clearRect(0, 0, bg.width, bg.height); }
      if (pan) { const c = pan.getContext("2d"); if (c) drawIdle(c, pan.width, pan.height, 20, 0.12); }
      return;
    }

    const bufLen  = analyser.frequencyBinCount;
    const freqData = new Uint8Array(bufLen);

    const tick = () => {
      animRef.current = requestAnimationFrame(tick);
      analyser.getByteFrequencyData(freqData);

      // ── Background canvas: wide ambient bars ──
      const bg = bgCanvasRef.current;
      if (bg && bg.width > 0) {
        const ctx = bg.getContext("2d");
        if (ctx) {
          ctx.clearRect(0, 0, bg.width, bg.height);
          // Use 16 buckets across the full width
          const cols = 16;
          const bw   = bg.width / cols;
          const step = Math.floor(bufLen / cols);
          for (let i = 0; i < cols; i++) {
            // Average a few bins per column for smooth large bars
            let sum = 0;
            for (let k = 0; k < step; k++) sum += freqData[i * step + k];
            const norm = (sum / step) / 255;
            const barH = norm * bg.height * 0.55;  // max 55% of screen height
            const alpha = 0.03 + norm * 0.05;       // 3–8% opacity — very subtle
            ctx.fillStyle = `hsla(44,72%,54%,${alpha})`;
            ctx.fillRect(i * bw, bg.height - barH, bw - 2, barH);
          }
        }
      }

      // ── Panel canvas: tight frequency bars ──
      const pan = panCanvasRef.current;
      if (pan && pan.width > 0) {
        const ctx = pan.getContext("2d");
        if (ctx) {
          ctx.clearRect(0, 0, pan.width, pan.height);
          const bw = pan.width / bufLen;
          for (let i = 0; i < bufLen; i++) {
            const norm = freqData[i] / 255;
            const h    = Math.max(2, norm * pan.height);
            ctx.fillStyle = `hsla(44,72%,54%,${0.22 + norm * 0.78})`;
            ctx.fillRect(i * bw, pan.height - h, bw - 1, h);
          }
        }
      }
    };
    tick();
    return () => cancelAnimationFrame(animRef.current);
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [playing, graphOk]);

  // ── Controls ───────────────────────────────────────────────────────
  const prevTrack  = () => {
    haptic(8);
    const a = audioRef.current;
    if (a && a.currentTime > 3) { a.currentTime = 0; return; }
    setTrackIdx(i => (i - 1 + PLAYLIST.length) % PLAYLIST.length);
  };
  const nextTrack  = () => { haptic(8); setTrackIdx(i => (i + 1) % PLAYLIST.length); };
  const togglePlay = () => { haptic(15); setPlaying(p => !p); };
  const openPanel  = () => { haptic(10); setOpen(true); };
  const closePanel = () => { haptic(8);  setOpen(false); setShowList(false); };

  const seek = (e: React.MouseEvent<HTMLDivElement>) => {
    const a = audioRef.current;
    if (!a || !duration) return;
    const r = e.currentTarget.getBoundingClientRect();
    a.currentTime = Math.max(0, Math.min(duration, ((e.clientX - r.left) / r.width) * duration));
  };

  const fmt = (s: number) =>
    (!isFinite(s) || isNaN(s))
      ? "0:00"
      : `${Math.floor(s / 60)}:${String(Math.floor(s % 60)).padStart(2, "0")}`;

  const track = PLAYLIST[trackIdx];
  const pct   = duration ? Math.min(100, (progress / duration) * 100) : 0;

  // EQ bars for the small button (same style as old VibeToggle)
  const eqDelays = [0, 0.18, 0.36, 0.12];

  return (
    <>
      {/* ── Ambient background EQ canvas ──────────────────────────── */}
      <canvas
        ref={bgCanvasRef}
        aria-hidden
        className="fixed inset-0 pointer-events-none"
        style={{ zIndex: 3 }}
      />

      {/* ── Music panel (slides up from button) ───────────────────── */}
      <AnimatePresence>
        {open && (
          <motion.div
            key="music-panel"
            initial={{ opacity: 0, y: 24, scale: 0.96 }}
            animate={{ opacity: 1, y: 0,  scale: 1    }}
            exit={{   opacity: 0, y: 16, scale: 0.97 }}
            transition={{ duration: 0.32, ease: [0.7, 0, 0.3, 1] }}
            className="fixed glass-strong specular rounded-2xl overflow-hidden"
            style={{
              bottom:    "5.5rem",           // sits just above the button
              left:      "1rem",
              width:     "min(320px, calc(100vw - 32px))",
              zIndex:    92,
              border:    "1px solid hsl(var(--gold)/0.25)",
              boxShadow: "0 8px 48px hsl(var(--gold)/0.08), inset 0 0 28px hsl(var(--gold)/0.03)",
            }}
          >
            {/* Panel header */}
            <div className="flex items-center justify-between px-4 py-3 border-b border-white/[0.06]">
              <div>
                <p className="font-mono text-[9px] tracking-[0.4em] text-gold/65">NOW PLAYING</p>
                <p className="font-mono text-[11px] tracking-[0.15em] text-cream/90 mt-0.5 truncate max-w-[200px]">
                  {track.title}
                </p>
              </div>
              <button
                onClick={closePanel}
                aria-label="Close player"
                className="grid place-items-center w-8 h-8 rounded-full glass transition-colors hover:text-gold text-cream/40"
                style={{ border: "1px solid hsl(var(--gold)/0.2)" }}
              >
                <X className="w-3.5 h-3.5" />
              </button>
            </div>

            {/* Visualiser */}
            <canvas
              ref={panCanvasRef}
              width={320}
              height={36}
              className="w-full block"
              aria-hidden
              style={{ opacity: playing ? 1 : 0.4, transition: "opacity 0.5s" }}
            />

            {/* Seek bar */}
            <div
              className="w-full cursor-pointer relative"
              style={{ height: "3px", background: "hsl(0 0% 100% / 0.07)" }}
              onClick={seek}
              role="slider"
              aria-label="Seek"
              aria-valuenow={Math.round(pct)}
              aria-valuemin={0}
              aria-valuemax={100}
            >
              <div
                className="absolute inset-y-0 left-0"
                style={{ width: `${pct}%`, background: "hsl(var(--gold)/0.85)", transition: "width 0.25s linear" }}
              />
            </div>

            {/* Time row */}
            <div className="flex justify-between px-4 pt-2 pb-0">
              <span className="font-mono text-[8px] text-cream/25">{fmt(progress)}</span>
              <span className="font-mono text-[8px] text-cream/25">{fmt(duration)}</span>
            </div>

            {/* Controls */}
            <div className="flex items-center justify-center gap-3 px-4 py-3">
              {PLAYLIST.length > 1 && (
                <button onClick={prevTrack} aria-label="Previous"
                  className="grid place-items-center w-8 h-8 rounded-lg text-cream/50 hover:text-gold transition-colors">
                  <SkipBack className="w-4 h-4" />
                </button>
              )}
              <button
                onClick={togglePlay}
                aria-label={playing ? "Pause" : "Play"}
                className="grid place-items-center w-12 h-12 rounded-full transition-all hover:scale-105"
                style={{ background: "hsl(var(--gold)/0.15)", border: "1px solid hsl(var(--gold)/0.45)" }}
              >
                {playing
                  ? <Pause className="w-5 h-5 text-gold" />
                  : <Play  className="w-5 h-5 text-gold translate-x-[1px]" />
                }
              </button>
              {PLAYLIST.length > 1 && (
                <button onClick={nextTrack} aria-label="Next"
                  className="grid place-items-center w-8 h-8 rounded-lg text-cream/50 hover:text-gold transition-colors">
                  <SkipForward className="w-4 h-4" />
                </button>
              )}
              <button
                onClick={() => setShowList(p => !p)}
                aria-label="Playlist"
                aria-expanded={showList}
                className={"grid place-items-center w-8 h-8 rounded-lg transition-colors ml-2 " +
                  (showList ? "text-gold bg-gold/10" : "text-cream/40 hover:text-gold")}
              >
                <List className="w-4 h-4" />
              </button>
            </div>

            {/* Playlist (collapsible) */}
            <AnimatePresence>
              {showList && (
                <motion.div
                  key="playlist"
                  initial={{ height: 0, opacity: 0 }}
                  animate={{ height: "auto", opacity: 1 }}
                  exit={{ height: 0, opacity: 0 }}
                  transition={{ duration: 0.28, ease: [0.7, 0, 0.3, 1] }}
                  style={{ overflow: "hidden" }}
                >
                  <div className="border-t border-white/[0.06]">
                    <p className="font-mono text-[8px] tracking-[0.4em] text-gold/50 px-4 py-2">
                      PLAYLIST
                    </p>
                    <div className="max-h-48 overflow-y-auto overscroll-contain" style={{ scrollbarWidth: "none" }}>
                      {PLAYLIST.map((t, i) => (
                        <button
                          key={t.id}
                          onClick={() => { haptic(8); setTrackIdx(i); setPlaying(true); setShowList(false); }}
                          className={"w-full flex items-center gap-3 px-4 py-2.5 text-left transition-colors hover:bg-white/[0.04] " +
                            (i === trackIdx ? "bg-gold/[0.07]" : "")}
                        >
                          <div
                            className="flex-none w-7 h-7 rounded-lg grid place-items-center"
                            style={{
                              background: `${t.accent ?? "#C8A84B"}18`,
                              border: `1px solid ${t.accent ?? "#C8A84B"}44`,
                            }}
                          >
                            {i === trackIdx && playing
                              ? <Volume2 className="w-3 h-3" style={{ color: t.accent ?? "#C8A84B" }} />
                              : <Music2  className="w-3 h-3 text-cream/30" />
                            }
                          </div>
                          <div className="flex-1 min-w-0">
                            <p className={"font-mono text-[10px] tracking-[0.1em] truncate " +
                              (i === trackIdx ? "text-gold" : "text-cream/70")}>
                              {t.title}
                            </p>
                            <p className="font-mono text-[8px] text-cream/28 truncate">{t.artist}</p>
                          </div>
                          {i === trackIdx && (
                            <span className="flex-none flex items-end gap-[2px]" style={{ height: "14px" }}>
                              {[0, 0.15, 0.3, 0.08].map((delay, j) => (
                                <span key={j} className={playing ? "eq-bar" : ""}
                                  style={{ display: "block", width: "2px", height: "100%",
                                    borderRadius: "1px", background: "hsl(var(--gold)/0.75)",
                                    transformOrigin: "bottom", animationDelay: `${delay}s` }} />
                              ))}
                            </span>
                          )}
                        </button>
                      ))}
                    </div>
                    <p className="font-mono text-[8px] tracking-[0.1em] text-cream/15 px-4 py-2 border-t border-white/[0.04]">
                      ADD TRACKS IN src/data/musicConfig.ts
                    </p>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </motion.div>
        )}
      </AnimatePresence>

      {/* ── Small circular button (always visible) ────────────────── */}
      <button
        onClick={openPanel}
        aria-label={playing ? "Music playing — open player" : "Open music player"}
        aria-expanded={open}
        className="fixed bottom-6 left-6 z-[91] grid place-items-center w-12 h-12 sm:w-14 sm:h-14 rounded-full glass-strong gold-border-glow animate-border-pulse"
      >
        <span className="absolute inset-0 rounded-full pointer-events-none"
          style={{ boxShadow: "inset 0 0 18px hsl(var(--gold)/.35)" }} />

        {playing ? (
          /* Live EQ bars while music plays */
          <span className="flex items-end gap-[3px] h-5" aria-hidden>
            {eqDelays.map((delay, i) => (
              <span
                key={i}
                className="eq-bar w-[3px] h-full rounded-sm bg-gold"
                style={{ animationDelay: `${delay}s`, boxShadow: "0 0 8px hsl(var(--gold)/0.85)" }}
              />
            ))}
          </span>
        ) : (
          /* Music note when paused */
          <Music2 className="w-5 h-5 text-gold" aria-hidden />
        )}
      </button>
    </>
  );
}
'''
open("src/components/MusicPlayer.tsx", "w").write(content)
print("  ✓  MusicPlayer.tsx rewritten")
PYEOF

# ─── 2. Bump version ─────────────────────────────────────────────────────────
echo "  [2/3] Bumping version to 3.8.0 …"
python3 - << 'PYEOF'
import json
p = json.load(open("package.json"))
p["version"] = "3.8.0"
json.dump(p, open("package.json", "w"), indent=2)
print("  ✓  version → 3.8.0")
PYEOF

# ─── 3. Verify ───────────────────────────────────────────────────────────────
echo "  [3/3] Verifying …"
python3 - << 'PYEOF'
import os
path = "src/components/MusicPlayer.tsx"
size = os.path.getsize(path)
# Quick sanity checks
src = open(path).read()
assert "bgCanvasRef"  in src, "missing bgCanvasRef"
assert "panCanvasRef" in src, "missing panCanvasRef"
assert "openPanel"    in src, "missing openPanel"
assert "closePanel"   in src, "missing closePanel"
assert "musicConfig"  in src, "missing musicConfig import"
print(f"  ✓  MusicPlayer.tsx  ({size:,} bytes, all checks pass)")
PYEOF

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  GENISYS v3.8 PATCH COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  HOW IT WORKS NOW:"
echo "    • Small gold circle button sits bottom-left (never in the way)"
echo "    • Shows live EQ bars while music is playing"
echo "    • Shows music note icon while paused"
echo "    • Tap it → panel slides up with full controls + playlist"
echo "    • X in panel collapses it back to just the button"
echo "    • Playing music → ambient gold EQ bars glow behind the page"
echo ""
echo "  Run:  npm run dev"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
