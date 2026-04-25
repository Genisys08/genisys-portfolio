import { CLIENTS } from "@/data/siteConfig";

export default function ClientLogoStrip() {
  const doubled = [...CLIENTS, ...CLIENTS];
  return (
    <section className="relative py-10 overflow-hidden border-y border-white/[0.05]">
      <div className="font-mono text-[9px] tracking-[0.45em] text-gold/50 text-center mb-6">
        TRUSTED BY CREATIVE LEADERS
      </div>
      <div className="relative overflow-hidden">
        <div className="flex gap-12 animate-marquee hover:[animation-play-state:paused] w-max">
          {doubled.map((c, i) => (
            <div
              key={i}
              className="flex items-center gap-3 flex-none select-none group"
            >
              <div
                className="w-9 h-9 rounded-lg grid place-items-center font-mono text-[10px] font-bold flex-none transition-all duration-300 group-hover:scale-110"
                style={{
                  background: "hsl(var(--gold) / 0.08)",
                  border:     "1px solid hsl(var(--gold) / 0.25)",
                  color:      "hsl(var(--gold) / 0.7)",
                }}
              >
                {c.abbr}
              </div>
              <span className="font-mono text-[11px] tracking-[0.2em] text-cream/50 group-hover:text-cream/80 transition-colors whitespace-nowrap">
                {c.name.toUpperCase()}
              </span>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
