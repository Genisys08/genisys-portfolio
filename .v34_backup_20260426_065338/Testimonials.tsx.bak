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
