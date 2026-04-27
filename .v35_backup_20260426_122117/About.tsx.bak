import { useScramble } from "@/hooks/useScramble";
import { useGyroscope } from "@/hooks/useGyroscope";

const stats = [
  { k: "120+", v: "Identities Shipped" },
  { k: "08",   v: "Industry Awards" },
  { k: "32",   v: "Countries Reached" },
  { k: "∞",    v: "Late-Night Iterations" },
];

export default function About() {
  const heading = useScramble("THE STUDIO", 1100);
  const t = useGyroscope();
  return (
    <section id="about" className="relative px-4 sm:px-8 py-24">
      <div className="max-w-5xl mx-auto">
        {/* FIX v3: "CHAPTER 02" → professional "STUDIO PROFILE" label */}
        <div className="font-mono text-[10px] tracking-[0.4em] text-gold/70">STUDIO PROFILE</div>
        <h2 className="mt-2 font-display font-black text-4xl sm:text-6xl gold-text chromatic">
          {heading}
        </h2>

        {/* FIX v3: Upgraded body copy — precise, premium, agency-grade */}
        <p className="mt-6 max-w-2xl text-cream/75 text-base sm:text-lg leading-relaxed">
          Genisys is a precision design studio obsessed with operatic visual systems — type that
          breathes, marks that command the room, and packaging that feels like an artifact from
          the future. We approach every brief the way a director approaches a feature film:
          every frame deliberate, every detail irreversible.
        </p>

        <div className="mt-12 grid grid-cols-2 sm:grid-cols-4 gap-3 sm:gap-5">
          {stats.map((s) => {
            const sx = t.x * 18;
            const sy = t.y * 18 + 14;
            return (
              <div
                key={s.v}
                data-focusable
                className="relative p-5 rounded-2xl glass specular grain"
                style={{
                  boxShadow: `${-sx}px ${sy}px 30px hsl(var(--gold) / 0.22), 0 0 0 1px hsl(var(--gold) / 0.16)`,
                }}
              >
                <div className="font-display font-black text-3xl sm:text-4xl gold-text">{s.k}</div>
                <div className="mt-1 font-mono text-[10px] tracking-[0.25em] text-cream/60">
                  {s.v.toUpperCase()}
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
