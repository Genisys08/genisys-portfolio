import { motion } from "framer-motion";
import { Check, X, ArrowLeft } from "lucide-react";
import { useScramble } from "@/hooks/useScramble";
import { useMagnetic } from "@/hooks/useMagnetic";
import { PRICING, STUDIO } from "@/data/siteConfig";
import { navigateSection } from "@/lib/router";
import FAQ from "@/components/FAQ";
import Footer from "@/components/Footer";

function BackBtn() {
  const ref = useMagnetic<HTMLButtonElement>(0.3);
  return (
    <button
      ref={ref}
      onClick={() => navigateSection("top")}
      className="inline-flex items-center gap-2 font-mono text-[10px] tracking-[0.3em] text-gold/70 hover:text-gold transition-colors mb-10"
    >
      <ArrowLeft className="w-3 h-3" /> BACK TO HOME
    </button>
  );
}

interface Props { onContact: () => void; }

export default function ServicesPage({ onContact }: Props) {
  const heading = useScramble("SERVICES", 1100);

  return (
    <>
      <section className="relative px-4 sm:px-8 pt-32 pb-20 min-h-[60vh]">
        <div
          aria-hidden
          className="pointer-events-none absolute inset-0"
          style={{ background: "radial-gradient(ellipse 60% 50% at 50% 0%, hsl(44 65% 35% / 0.10), transparent)" }}
        />
        <div className="max-w-6xl mx-auto">
          <BackBtn />
          <div className="font-mono text-[10px] tracking-[0.5em] text-gold/70 mb-2">
            INVESTMENT TIERS
          </div>
          <h1 className="font-display font-black text-5xl sm:text-7xl gold-text chromatic mb-4">
            {heading}
          </h1>
          <p className="max-w-xl text-cream/65 text-sm sm:text-base leading-relaxed mb-4">
            Every engagement is fixed-price, clearly scoped, and built around one goal:
            a visual system that outlasts trends and outlasts competitors.
          </p>

          {/* Availability badge */}
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full glass mb-16"
            style={{ border: "1px solid hsl(var(--gold)/0.3)" }}>
            <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
            <span className="font-mono text-[10px] tracking-[0.3em] text-cream/80">
              {STUDIO.availability.accepting
                ? `NOW BOOKING · NEXT SLOT ${STUDIO.availability.nextSlot.toUpperCase()}`
                : "FULLY BOOKED · JOIN WAITLIST"}
            </span>
          </div>

          {/* Pricing grid */}
          <div className="grid sm:grid-cols-3 gap-5">
            {PRICING.map((tier, i) => (
              <motion.div
                key={tier.id}
                initial={{ opacity: 0, y: 28 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: i * 0.1, ease: [0.7, 0, 0.3, 1] }}
                className="relative flex flex-col rounded-2xl overflow-hidden"
                style={{
                  background: tier.highlight
                    ? "linear-gradient(145deg, hsl(0 0% 8%/0.98), hsl(0 0% 5%/0.98))"
                    : "linear-gradient(145deg, hsl(0 0% 6%/0.96), hsl(0 0% 3%/0.96))",
                  border: tier.highlight
                    ? "1px solid hsl(var(--gold)/0.55)"
                    : "1px solid hsl(0 0% 100%/0.07)",
                  boxShadow: tier.highlight
                    ? "0 0 40px hsl(var(--gold)/0.15), inset 0 1px 0 hsl(0 0% 100%/0.08)"
                    : "0 4px 24px hsl(0 0%  0%/0.6)",
                }}
              >
                {tier.highlight && (
                  <div className="absolute top-0 left-0 right-0 h-[2px]"
                    style={{ background: "linear-gradient(90deg, transparent, hsl(var(--gold)), transparent)" }} />
                )}
                {tier.highlight && (
                  <div className="absolute top-4 right-4 font-mono text-[9px] tracking-[0.3em] px-2 py-1 rounded-full"
                    style={{ background: "hsl(var(--gold)/0.15)", color: "hsl(var(--gold))", border: "1px solid hsl(var(--gold)/0.4)" }}>
                    MOST POPULAR
                  </div>
                )}
                <div className="p-6 pb-4">
                  <div className="font-mono text-[10px] tracking-[0.4em] text-gold/80 mb-3">
                    {tier.tier}
                  </div>
                  <div className="font-display font-black text-4xl gold-text mb-1">
                    {tier.price}
                  </div>
                  <div className="font-mono text-[10px] tracking-[0.2em] text-cream/50 mb-4">
                    {tier.period.toUpperCase()}
                  </div>
                  <p className="text-cream/60 text-xs leading-relaxed mb-1 italic">
                    {tier.tagline}
                  </p>
                  <p className="text-cream/70 text-sm leading-relaxed">
                    {tier.description}
                  </p>
                </div>

                <div className="px-6 pb-4 flex-1">
                  <div className="border-t border-white/[0.06] pt-4 space-y-2">
                    {tier.features.map(f => (
                      <div key={f} className="flex items-start gap-2.5 text-sm text-cream/75">
                        <Check className="w-3.5 h-3.5 text-gold mt-0.5 flex-none" />
                        <span>{f}</span>
                      </div>
                    ))}
                    {tier.notIncluded.map(f => (
                      <div key={f} className="flex items-start gap-2.5 text-sm text-cream/30">
                        <X className="w-3.5 h-3.5 mt-0.5 flex-none" />
                        <span>{f}</span>
                      </div>
                    ))}
                  </div>
                </div>

                <div className="p-6 pt-4">
                  <button
                    onClick={onContact}
                    className="w-full py-3.5 rounded-xl font-mono text-xs tracking-[0.3em] transition-all duration-300"
                    style={
                      tier.highlight
                        ? { background: "hsl(var(--gold))", color: "#000", fontWeight: 700 }
                        : { background: "transparent", border: "1px solid hsl(var(--gold)/0.4)", color: "hsl(var(--gold))" }
                    }
                  >
                    {tier.cta}
                  </button>
                </div>
              </motion.div>
            ))}
          </div>

          {/* Small print */}
          <p className="mt-8 text-center font-mono text-[10px] tracking-[0.2em] text-cream/35">
            ALL PRICES IN USD · PAYMENT VIA STRIPE, WISE, OR CRYPTO ·{" "}
            <a href={`mailto:${STUDIO.email}`} className="text-gold/50 hover:text-gold transition-colors">
              {STUDIO.email.toUpperCase()}
            </a>
          </p>
        </div>
      </section>

      <FAQ />
      <Footer onContact={onContact} />
    </>
  );
}
