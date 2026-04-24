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
