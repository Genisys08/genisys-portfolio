#!/usr/bin/env bash
# =============================================================================
#  GENISYS GRAPHICS — PATCH v3.7
# =============================================================================
#  VISITOR AUDIT (rated 3.5 / 5):
#
#  ✦ Positives: Stunning cinematic aesthetic, smooth page transitions,
#    gold-metallic palette is consistent, portfolio grid loads fast,
#    social icons now correct (v3.6 fix), contact form wired up.
#
#  ✗ BUG / FEATURE GAPS FOUND:
#
#  [FEATURE-1] Music: Only one song, no playlist, no track info, no
#              prev/next, no seek bar, basic 4-bar EQ only.
#              → Replace VibeToggle with full MusicPlayer:
#                 • Web Audio API frequency visualiser (canvas)
#                 • Scrollable playlist drawer (slides up from bar)
#                 • Prev / Play / Pause / Next controls
#                 • Seek bar with live progress
#                 • musicConfig.ts — drop new songs in 3 lines
#                 • Mini-bar sits bottom-left, never blocks content
#
#  [BUG-1]    VibeToggle had no track info, no way to know what's playing
#  [BUG-2]    No way to add more songs without editing component code
#  [BUG-3]    No prev/next — single loop with no escape
#  [BUG-4]    Visualiser only animated while music plays; idle state
#              shows nothing (blank button)
#  [BUG-5]    Audio element re-created every keystroke of VibeToggle
#              (was inside the click handler, not useEffect) — minor
#              but causes a tiny pop on toggle
# =============================================================================
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
echo "▶  Genisys v3.7 patch — starting …"

# ─── 1. Write musicConfig.ts ────────────────────────────────────────────────
echo "  [1/5] Writing src/data/musicConfig.ts …"
python3 - << 'PYEOF'
content = '''\
// =============================================================================
//  GENISYS MUSIC CONFIG
//  Add as many songs as you want here.
//
//  HOW TO ADD A SONG:
//    1. Drop the MP3 (or OGG/WAV) into the /public/ folder
//       (or create /public/music/ and put it there)
//    2. Copy one of the objects in PLAYLIST and fill in the details.
//    3. Save. Done. The player picks it up automatically.
// =============================================================================

export interface Track {
  /** Unique ID — any short string, no spaces */
  id:      string;
  /** Track title shown in the player */
  title:   string;
  /** Artist / label shown under the title */
  artist:  string;
  /**
   * Path to the audio file, relative to /public
   * Examples:
   *   "/vibe.mp3"               ← file is at public/vibe.mp3
   *   "/music/cinematic.mp3"    ← file is at public/music/cinematic.mp3
   */
  src:     string;
  /**
   * Hex accent colour shown on the playlist icon for this track.
   * Defaults to gold if omitted.
   */
  accent?: string;
}

// ─── ADD YOUR SONGS BELOW ────────────────────────────────────────────────────
export const PLAYLIST: Track[] = [
  {
    id:     "vibe-01",
    title:  "Dark Vibe",
    artist: "Genisys Studio",
    src:    "/vibe.mp3",
    accent: "#C8A84B",
  },

  // Uncomment and edit to add more tracks:
  // {
  //   id:     "vibe-02",
  //   title:  "Phantom Pulse",
  //   artist: "Genisys Studio",
  //   src:    "/music/phantom-pulse.mp3",
  //   accent: "#8B5CF6",
  // },
  // {
  //   id:     "vibe-03",
  //   title:  "Iron Frequency",
  //   artist: "Genisys Studio",
  //   src:    "/music/iron-frequency.mp3",
  //   accent: "#EF4444",
  // },
];
'''
open("src/data/musicConfig.ts", "w").write(content)
print("  ✓  musicConfig.ts written")
PYEOF

# ─── 2. Write MusicPlayer.tsx ────────────────────────────────────────────────
echo "  [2/5] Writing src/components/MusicPlayer.tsx …"
python3 - << 'PYEOF'
content = '''\
/**
 * MusicPlayer — v3.7
 *
 * Replaces the single-song VibeToggle with a full mini-player:
 *   • Web Audio API frequency-bar visualiser on a canvas
 *   • Seek bar with live playhead
 *   • Prev / Play-Pause / Next controls
 *   • Playlist drawer (slides up from the bar)
 *   • Non-intrusive: sits bottom-left, never blocks content
 *
 * Add songs in  src/data/musicConfig.ts — no component edits needed.
 */
import { useEffect, useRef, useState } from "react";
import { AnimatePresence, motion }     from "framer-motion";
import { List, Music, Pause, Play, SkipBack, SkipForward, Volume2, X } from "lucide-react";
import { PLAYLIST }  from "@/data/musicConfig";
import { haptic }    from "@/lib/haptics";

export default function MusicPlayer() {
  const [trackIdx,  setTrackIdx]  = useState(0);
  const [playing,   setPlaying]   = useState(false);
  const [progress,  setProgress]  = useState(0);
  const [duration,  setDuration]  = useState(0);
  const [showList,  setShowList]  = useState(false);
  const [graphOk,   setGraphOk]   = useState(false);

  // Stable refs — never cause re-renders
  const audioRef    = useRef<HTMLAudioElement | null>(null);
  const ctxRef      = useRef<AudioContext | null>(null);
  const analyserRef = useRef<AnalyserNode | null>(null);
  const canvasRef   = useRef<HTMLCanvasElement | null>(null);
  const animRef     = useRef<number>(0);
  const playingRef  = useRef(false);   // mirrors playing without causing effect loops
  const idxRef      = useRef(0);       // mirrors trackIdx for the "ended" callback

  // ── 1. Create single Audio element on mount ──────────────────────────
  useEffect(() => {
    const a      = new Audio(PLAYLIST[0].src);
    a.preload    = "metadata";
    a.volume     = 0.42;

    a.addEventListener("timeupdate",     () => setProgress(a.currentTime));
    a.addEventListener("loadedmetadata", () => setDuration(a.duration || 0));
    a.addEventListener("ended", () => {
      // Auto-advance to next track
      const next = (idxRef.current + 1) % PLAYLIST.length;
      setTrackIdx(next);
      setPlaying(true);
    });

    audioRef.current = a;
    return () => {
      a.pause();
      a.src = "";
      cancelAnimationFrame(animRef.current);
      ctxRef.current?.close();
    };
  }, []); // runs once

  // ── 2. Swap audio src when track changes ─────────────────────────────
  useEffect(() => {
    idxRef.current = trackIdx;
    const a = audioRef.current;
    if (!a) return;
    a.src = PLAYLIST[trackIdx].src;
    a.load();
    setProgress(0);
    if (playingRef.current) a.play().catch(() => setPlaying(false));
  }, [trackIdx]);

  // ── 3. Play / pause ───────────────────────────────────────────────────
  useEffect(() => {
    playingRef.current = playing;
    const a = audioRef.current;
    if (!a) return;

    if (playing) {
      // Build Web Audio graph on first play (requires user gesture)
      if (!ctxRef.current) {
        try {
          const AudioCtx =
            window.AudioContext ||
            (window as unknown as { webkitAudioContext: typeof AudioContext })
              .webkitAudioContext;
          const ctx = new AudioCtx();
          const src = ctx.createMediaElementSource(a);
          const an  = ctx.createAnalyser();
          an.fftSize   = 128;
          an.smoothingTimeConstant = 0.78;
          src.connect(an);
          an.connect(ctx.destination);
          ctxRef.current    = ctx;
          analyserRef.current = an;
          setGraphOk(true);
        } catch {
          // Older Safari / restricted context — audio still plays, no visualiser
          console.warn("[MusicPlayer] Web Audio API unavailable — visualiser disabled");
        }
      }
      ctxRef.current?.resume();
      a.play().catch(() => setPlaying(false));
    } else {
      a.pause();
    }
  }, [playing]);

  // ── 4. Visualiser animation loop ──────────────────────────────────────
  useEffect(() => {
    const canvas   = canvasRef.current;
    const analyser = analyserRef.current;
    cancelAnimationFrame(animRef.current);

    if (!canvas) return;
    const ctx2d = canvas.getContext("2d");
    if (!ctx2d) return;

    const W = canvas.width;
    const H = canvas.height;

    if (!playing || !analyser) {
      // Draw a gentle idle ghost pattern
      ctx2d.clearRect(0, 0, W, H);
      const cols = 24;
      const bw   = W / cols;
      for (let i = 0; i < cols; i++) {
        const h = 2 + Math.sin(i * 0.55) * 2;
        ctx2d.fillStyle = "hsla(44,72%,54%,0.12)";
        ctx2d.fillRect(i * bw, H - h, bw - 1, h);
      }
      return;
    }

    const bufLen = analyser.frequencyBinCount;
    const data   = new Uint8Array(bufLen);
    const bw     = W / bufLen;

    const tick = () => {
      animRef.current = requestAnimationFrame(tick);
      analyser.getByteFrequencyData(data);
      ctx2d.clearRect(0, 0, W, H);
      for (let i = 0; i < bufLen; i++) {
        const norm = data[i] / 255;
        const h    = Math.max(3, norm * H);
        ctx2d.fillStyle = `hsla(44,72%,54%,${0.22 + norm * 0.78})`;
        ctx2d.fillRect(i * bw, H - h, bw - 1, h);
      }
    };
    tick();
    return () => cancelAnimationFrame(animRef.current);
  // graphOk triggers re-subscription once the AnalyserNode is ready
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [playing, graphOk]);

  // ── Helpers ──────────────────────────────────────────────────────────
  const prevTrack  = () => {
    haptic(8);
    const a = audioRef.current;
    // If past 3 s, restart current track; else go to previous
    if (a && a.currentTime > 3) { a.currentTime = 0; return; }
    setTrackIdx(i => (i - 1 + PLAYLIST.length) % PLAYLIST.length);
  };
  const nextTrack  = () => { haptic(8); setTrackIdx(i => (i + 1) % PLAYLIST.length); };
  const togglePlay = () => { haptic(15); setPlaying(p => !p); };

  const seek = (e: React.MouseEvent<HTMLDivElement>) => {
    const a = audioRef.current;
    if (!a || !duration) return;
    const r = e.currentTarget.getBoundingClientRect();
    a.currentTime = Math.max(0, Math.min(duration, ((e.clientX - r.left) / r.width) * duration));
  };

  const fmt = (s: number) => {
    if (!isFinite(s) || isNaN(s)) return "0:00";
    return `${Math.floor(s / 60)}:${String(Math.floor(s % 60)).padStart(2, "0")}`;
  };

  const track = PLAYLIST[trackIdx];
  const pct   = duration ? Math.min(100, (progress / duration) * 100) : 0;

  return (
    <div
      className="fixed bottom-4 left-4 z-[90] flex flex-col gap-2 pointer-events-auto"
      style={{ width: "min(320px, calc(100vw - 32px))" }}
    >
      {/* ── Playlist drawer ─────────────────────────────────────────── */}
      <AnimatePresence>
        {showList && (
          <motion.div
            key="playlist"
            initial={{ opacity: 0, y: 14, scale: 0.96 }}
            animate={{ opacity: 1, y: 0,  scale: 1    }}
            exit={{   opacity: 0, y: 8,  scale: 0.97 }}
            transition={{ duration: 0.28, ease: [0.7, 0, 0.3, 1] }}
            className="w-full glass-strong specular rounded-2xl overflow-hidden"
            style={{ border: "1px solid hsl(var(--gold)/0.22)" }}
          >
            {/* Drawer header */}
            <div className="flex items-center justify-between px-4 py-2.5 border-b border-white/[0.05]">
              <span className="font-mono text-[9px] tracking-[0.4em] text-gold/70">THEME MUSIC</span>
              <button
                onClick={() => setShowList(false)}
                className="p-1 text-cream/35 hover:text-gold transition-colors"
                aria-label="Close playlist"
              >
                <X className="w-3.5 h-3.5" />
              </button>
            </div>

            {/* Track list */}
            <div
              className="max-h-56 overflow-y-auto overscroll-contain"
              style={{ scrollbarWidth: "none" }}
            >
              {PLAYLIST.map((t, i) => (
                <button
                  key={t.id}
                  onClick={() => {
                    haptic(8);
                    setTrackIdx(i);
                    setPlaying(true);
                    setShowList(false);
                  }}
                  className={
                    "w-full flex items-center gap-3 px-4 py-2.5 text-left transition-colors hover:bg-white/[0.04] " +
                    (i === trackIdx ? "bg-gold/[0.07]" : "")
                  }
                >
                  {/* Icon */}
                  <div
                    className="flex-none w-7 h-7 rounded-lg grid place-items-center"
                    style={{
                      background: `${t.accent ?? "#C8A84B"}18`,
                      border:     `1px solid ${t.accent ?? "#C8A84B"}44`,
                    }}
                  >
                    {i === trackIdx && playing ? (
                      <Volume2 className="w-3 h-3" style={{ color: t.accent ?? "#C8A84B" }} />
                    ) : (
                      <Music className="w-3 h-3 text-cream/30" />
                    )}
                  </div>

                  {/* Info */}
                  <div className="flex-1 min-w-0">
                    <p className={"font-mono text-[10px] tracking-[0.12em] truncate leading-tight " + (i === trackIdx ? "text-gold" : "text-cream/75")}>
                      {t.title}
                    </p>
                    <p className="font-mono text-[8px] text-cream/30 truncate leading-tight">{t.artist}</p>
                  </div>

                  {/* Live EQ bars for active track */}
                  {i === trackIdx && (
                    <span className="flex-none flex items-end gap-[2px]" style={{ height: "14px" }}>
                      {[0, 0.15, 0.3, 0.08].map((delay, j) => (
                        <span
                          key={j}
                          className={playing ? "eq-bar" : ""}
                          style={{
                            display:         "block",
                            width:           "2px",
                            height:          "100%",
                            borderRadius:    "1px",
                            background:      "hsl(var(--gold)/0.75)",
                            transformOrigin: "bottom",
                            animationDelay:  `${delay}s`,
                          }}
                        />
                      ))}
                    </span>
                  )}
                </button>
              ))}
            </div>

            {/* Footer hint */}
            <div className="px-4 py-2 border-t border-white/[0.04]">
              <p className="font-mono text-[8px] tracking-[0.15em] text-cream/18">
                ADD TRACKS IN  src/data/musicConfig.ts
              </p>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* ── Mini player bar ─────────────────────────────────────────── */}
      <div
        className="w-full glass-strong rounded-2xl overflow-hidden"
        style={{
          border:     "1px solid hsl(var(--gold)/0.22)",
          boxShadow:  "0 4px 32px hsl(var(--gold)/0.06), inset 0 0 24px hsl(var(--gold)/0.03)",
        }}
      >
        {/* Visualiser canvas */}
        <canvas
          ref={canvasRef}
          width={320}
          height={32}
          className="w-full block"
          aria-hidden
          style={{ opacity: playing ? 1 : 0.55, transition: "opacity 0.6s" }}
        />

        {/* Seek / progress bar */}
        <div
          className="w-full cursor-pointer relative"
          style={{ height: "3px", background: "hsl(0 0% 100% / 0.06)" }}
          onClick={seek}
          role="slider"
          aria-label="Seek"
          aria-valuenow={Math.round(pct)}
          aria-valuemin={0}
          aria-valuemax={100}
        >
          <div
            className="absolute inset-y-0 left-0"
            style={{
              width:      `${pct}%`,
              background: "hsl(var(--gold)/0.8)",
              transition: "width 0.25s linear",
            }}
          />
        </div>

        {/* Controls row */}
        <div className="flex items-center gap-1.5 px-3 py-2">
          {/* Track info */}
          <div className="flex-1 min-w-0 mr-1">
            <p className="font-mono text-[9px] tracking-[0.18em] text-gold truncate leading-snug">
              {track.title}
            </p>
            <p className="font-mono text-[8px] text-cream/30 truncate leading-snug">
              {track.artist}
            </p>
          </div>

          {/* Prev */}
          {PLAYLIST.length > 1 && (
            <button
              onClick={prevTrack}
              aria-label="Previous track"
              className="grid place-items-center w-7 h-7 rounded-lg text-cream/45 hover:text-gold transition-colors"
            >
              <SkipBack className="w-3.5 h-3.5" />
            </button>
          )}

          {/* Play / Pause */}
          <button
            onClick={togglePlay}
            aria-label={playing ? "Pause" : "Play"}
            className="grid place-items-center w-8 h-8 rounded-full flex-none transition-all hover:scale-105"
            style={{
              background: "hsl(var(--gold)/0.14)",
              border:     "1px solid hsl(var(--gold)/0.4)",
            }}
          >
            {playing
              ? <Pause className="w-3.5 h-3.5 text-gold" />
              : <Play  className="w-3.5 h-3.5 text-gold translate-x-[1px]" />
            }
          </button>

          {/* Next */}
          {PLAYLIST.length > 1 && (
            <button
              onClick={nextTrack}
              aria-label="Next track"
              className="grid place-items-center w-7 h-7 rounded-lg text-cream/45 hover:text-gold transition-colors"
            >
              <SkipForward className="w-3.5 h-3.5" />
            </button>
          )}

          {/* Playlist toggle */}
          <button
            onClick={() => { haptic(8); setShowList(p => !p); }}
            aria-label="Toggle playlist"
            aria-expanded={showList}
            className={
              "grid place-items-center w-7 h-7 rounded-lg transition-colors " +
              (showList ? "text-gold bg-gold/10" : "text-cream/35 hover:text-gold")
            }
          >
            <List className="w-3.5 h-3.5" />
          </button>

          {/* Time (desktop only) */}
          <span
            className="font-mono text-[8px] text-cream/22 ml-0.5 hidden sm:block flex-none"
            aria-label="Current time"
          >
            {fmt(progress)}
          </span>
        </div>
      </div>
    </div>
  );
}
'''
open("src/components/MusicPlayer.tsx", "w").write(content)
print("  ✓  MusicPlayer.tsx written")
PYEOF

# ─── 3. Update App.tsx — swap VibeToggle for MusicPlayer ─────────────────────
echo "  [3/5] Updating App.tsx …"
python3 - << 'PYEOF'
import sys

path = "src/App.tsx"
src  = open(path).read()

old_import = 'import VibeToggle                 from "@/components/VibeToggle";'
new_import  = 'import MusicPlayer               from "@/components/MusicPlayer";'

old_usage  = '<VibeToggle />'
new_usage  = '<MusicPlayer />'

if old_import not in src:
    print("  ⚠  VibeToggle import not found — checking for already-patched state …")
    if 'MusicPlayer' in src:
        print("  ✓  App.tsx already uses MusicPlayer — skipping")
        sys.exit(0)
    else:
        print("  ✗  Could not locate VibeToggle import — manual edit required")
        sys.exit(0)

src = src.replace(old_import, new_import).replace(old_usage, new_usage)
open(path, "w").write(src)
print("  ✓  App.tsx updated (VibeToggle → MusicPlayer)")
PYEOF

# ─── 4. Bump version ─────────────────────────────────────────────────────────
echo "  [4/5] Bumping package.json to 3.7.0 …"
python3 - << 'PYEOF'
import json
path = "package.json"
pkg  = json.load(open(path))
pkg["version"] = "3.7.0"
json.dump(pkg, open(path, "w"), indent=2)
print("  ✓  version → 3.7.0")
PYEOF

# ─── 5. Verify key files exist ───────────────────────────────────────────────
echo "  [5/5] Verifying outputs …"
python3 - << 'PYEOF'
import os, sys
checks = [
    ("src/data/musicConfig.ts",    "musicConfig.ts"),
    ("src/components/MusicPlayer.tsx", "MusicPlayer.tsx"),
]
ok = True
for path, label in checks:
    if os.path.exists(path):
        size = os.path.getsize(path)
        print(f"  ✓  {label}  ({size:,} bytes)")
    else:
        print(f"  ✗  MISSING: {label}")
        ok = False
if not ok:
    sys.exit(1)
PYEOF

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  GENISYS v3.7 PATCH COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  NEW FEATURES:"
echo "    ✓ Full music player replaces the old single-song toggle"
echo "    ✓ Web Audio API frequency visualiser (canvas, gold bars)"
echo "    ✓ Seek bar — tap anywhere on the progress line to jump"
echo "    ✓ Prev / Play-Pause / Next controls"
echo "    ✓ Playlist drawer (tap the list icon to open)"
echo "    ✓ Auto-advances to next track on song end"
echo "    ✓ Lives bottom-left — never blocks nav, lightbox, or modals"
echo ""
echo "  TO ADD MORE SONGS:"
echo "    1. Drop the MP3 into your /public/ folder"
echo "    2. Open  src/data/musicConfig.ts"
echo "    3. Copy the example block and fill in title / artist / src"
echo "    4. Save — that's it"
echo ""
echo "  Then run:  npm run dev"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
