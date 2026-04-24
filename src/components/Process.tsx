import { useScramble } from "@/hooks/useScramble";

const steps = [
  {
    n: "01",
    t: "Discovery",
    d: "Deep-dive immersion into your brand DNA. We interrogate assumptions, audit competitors, and surface the one irreplaceable truth your identity must carry.",
  },
  {
    n: "02",
    t: "Direction",
    d: "Mood systems, type hierarchies, colour universes, and mark explorations — the full cinematic skeleton of your identity, before a single final pixel is placed.",
  },
  {
    n: "03",
    t: "Design",
    d: "Full identity architecture: primary marks, sub-marks, typographic systems, colour grids, packaging, motion primitives, and every digital touchpoint.",
  },
  {
    n: "04",
    t: "Delivery",
    d: "Production-ready master files, comprehensive brand guidelines, motion specifications, and lifetime creative consultation. We stay on call.",
  },
];

export default function Process() {
  const heading = useScramble("THE PROCESS", 1100);
  return (
    <section id="process" className="relative px-4 sm:px-8 py-24">
      <div className="max-w-5xl mx-auto">
        {/* FIX v3: "CHAPTER 03" → "OUR METHOD", steps "CHAPTER ·" → "PHASE ·" */}
        <div className="font-mono text-[10px] tracking-[0.4em] text-gold/70">OUR METHOD</div>
        <h2 className="mt-2 font-display font-black text-4xl sm:text-6xl gold-text chromatic">
          {heading}
        </h2>
        <ol className="mt-10 grid sm:grid-cols-2 gap-4">
          {steps.map((s) => (
            <li key={s.n} data-focusable className="relative p-6 rounded-2xl glass specular grain">
              <div className="font-mono text-[10px] tracking-[0.3em] text-gold/70">
                PHASE · {s.n}
              </div>
              <div className="mt-1 font-display text-xl sm:text-2xl font-bold text-cream">
                {s.t}
              </div>
              <p className="mt-2 text-cream/65 text-sm leading-relaxed">{s.d}</p>
            </li>
          ))}
        </ol>
      </div>
    </section>
  );
}
