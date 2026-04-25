import { useScramble }      from "@/hooks/useScramble";
import { useGyroscopeTilt } from "@/contexts/GyroscopeContext";
import { useMagnetic }      from "@/hooks/useMagnetic";
import { useReducedMotion } from "@/hooks/useReducedMotion";
import { STUDIO }           from "@/data/siteConfig";
import { navigatePage }     from "@/lib/router";

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
          transform: reduced ? undefined : `translate3d(${t.x * -10}px, ${t.y * -8}px, 0)`,
        }}
      >
        {/* Availability badge */}
        <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full glass mb-6"
          style={{ border: "1px solid hsl(var(--gold)/0.25)" }}>
          <span className={
            "w-1.5 h-1.5 rounded-full " +
            (STUDIO.availability.accepting ? "bg-emerald-400 animate-pulse" : "bg-red-400")
          } />
          <span className="font-mono text-[9px] tracking-[0.35em] text-cream/65">
            {STUDIO.availability.accepting
              ? `NOW BOOKING · NEXT SLOT ${STUDIO.availability.nextSlot.toUpperCase()}`
              : "FULLY BOOKED — JOIN WAITLIST"}
          </span>
        </div>

        <div className="font-mono text-[10px] sm:text-xs tracking-[0.5em] text-gold/70">{eyebrow}</div>
        <h1 className="mt-6 font-display font-black tracking-tight leading-[0.95] text-[15vw] sm:text-[110px] gold-text chromatic">
          {title1}
        </h1>
        <h1 className="font-display font-black tracking-tight leading-[0.95] text-[15vw] sm:text-[110px] text-cream/90 chromatic">
          {title2}
        </h1>
        <p className="mt-8 text-cream/70 text-sm sm:text-base max-w-md mx-auto">{sub}</p>

        <div className="mt-10 flex flex-col sm:flex-row items-center justify-center gap-4">
          <a
            ref={ctaRef}
            href="#work"
            data-magnetic
            className="inline-flex items-center gap-3 px-7 py-3 rounded-full glass-strong gold-border-glow font-mono text-xs tracking-[0.3em] text-gold hover:text-cream transition-colors"
          >
            ENTER THE WORK →
          </a>
          <button
            onClick={() => navigatePage("services")}
            className="font-mono text-[11px] tracking-[0.3em] text-cream/50 hover:text-gold transition-colors"
          >
            VIEW PRICING
          </button>
        </div>
      </div>
    </section>
  );
}
