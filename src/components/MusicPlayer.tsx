/**
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
