import { motion } from "framer-motion";
import { useScramble } from "@/hooks/useScramble";
import { useMagnetic } from "@/hooks/useMagnetic";

export default function CtaSection() {
  const line1 = useScramble("READY TO BUILD", 1100);
  const line2 = useScramble("SOMETHING ICONIC?", 1300);
  const ref   = useMagnetic<HTMLButtonElement>(0.25);

  return (
    <section className="relative px-6 py-32 overflow-hidden">
      <div
        aria-hidden
        className="pointer-events-none absolute inset-0"
        style={{
          background: "radial-gradient(ellipse 70% 55% at 50% 50%, hsl(44 65% 35% / 0.12), transparent)",
        }}
      />
      <motion.div
        initial={{ opacity: 0, y: 32 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true, margin: "-80px" }}
        transition={{ duration: 0.7, ease: [0.7, 0, 0.3, 1] }}
        className="max-w-4xl mx-auto text-center"
      >
        <div className="font-mono text-[10px] tracking-[0.5em] text-gold/70 mb-6">
          NEW PROJECT INTAKE — OPEN
        </div>
        <h2 className="font-display font-black leading-[0.92] text-[11vw] sm:text-[90px] gold-text chromatic">
          {line1}
        </h2>
        <h2 className="font-display font-black leading-[0.92] text-[11vw] sm:text-[90px] text-cream/90 chromatic">
          {line2}
        </h2>
        <p className="mt-8 max-w-md mx-auto text-cream/65 text-sm sm:text-base leading-relaxed">
          We take on a limited number of projects each quarter to guarantee cinematic
          attention on every brief. Slots are finite.
        </p>
        <div className="mt-10 flex flex-col sm:flex-row items-center justify-center gap-4">
          <button
            ref={ref}
            onClick={() => window.dispatchEvent(new Event("open-contact"))}
            className="px-8 py-4 rounded-full glass-strong gold-border-glow font-mono text-xs tracking-[0.35em] text-gold hover:text-cream transition-colors animate-border-pulse"
          >
            START A PROJECT →
          </button>
          <a
            href="#/services"
            className="font-mono text-[11px] tracking-[0.3em] text-cream/55 hover:text-gold transition-colors"
          >
            VIEW PRICING FIRST
          </a>
        </div>
      </motion.div>
    </section>
  );
}
