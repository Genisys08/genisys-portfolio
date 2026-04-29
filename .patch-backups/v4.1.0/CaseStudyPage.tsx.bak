import { useMemo } from "react";
import { motion } from "framer-motion";
import { ArrowLeft, ArrowRight, ChevronLeft } from "lucide-react";
import { useScramble } from "@/hooks/useScramble";
import { portfolio } from "@/data/portfolioData";
import { navigatePage, navigateSection } from "@/lib/router";
import Footer from "@/components/Footer";

interface Props { id: string; onContact: () => void; }

export default function CaseStudyPage({ id, onContact }: Props) {
  const item = useMemo(() => portfolio.find(p => p.id === id), [id]);

  // Only items with case studies get their own page
  const csList = useMemo(() => portfolio.filter(p => p.caseStudy), []);
  const csIndex = csList.findIndex(p => p.id === id);

  const heading = useScramble(item?.title ?? "NOT FOUND", 1100);

  if (!item || !item.caseStudy) {
    return (
      <div className="min-h-screen grid place-items-center">
        <div className="text-center px-6">
          <div className="font-mono text-[10px] tracking-[0.4em] text-gold/70 mb-4">CASE STUDY</div>
          <h1 className="font-display font-black text-4xl gold-text mb-6">Not Found</h1>
          <button
            onClick={() => navigateSection("work")}
            className="px-6 py-3 rounded-full glass-strong gold-border-glow font-mono text-xs tracking-[0.3em] text-gold"
          >
            VIEW ALL WORK
          </button>
        </div>
      </div>
    );
  }

  const cs = item.caseStudy;

  return (
    <>
      <section className="relative px-4 sm:px-8 pt-32 pb-20">
        <div
          aria-hidden
          className="pointer-events-none absolute inset-0 z-0"
          style={{ background: "radial-gradient(ellipse 55% 45% at 50% 15%, hsl(44 65% 30% / 0.10), transparent)" }}
        />
        <div className="max-w-5xl mx-auto relative z-10">

          {/* Back */}
          <button
            onClick={() => navigateSection("work")}
            className="inline-flex items-center gap-2 font-mono text-[10px] tracking-[0.3em] text-gold/70 hover:text-gold transition-colors mb-10"
          >
            <ChevronLeft className="w-3 h-3" /> ALL WORK
          </button>

          {/* Tags */}
          <div className="flex flex-wrap gap-2 mb-4">
            {cs.tags.map(tag => (
              <span
                key={tag}
                className="px-3 py-1 rounded-full font-mono text-[9px] tracking-[0.25em] text-gold/70"
                style={{ background: "hsl(var(--gold)/0.08)", border: "1px solid hsl(var(--gold)/0.2)" }}
              >
                {tag.toUpperCase()}
              </span>
            ))}
          </div>

          <div className="font-mono text-[10px] tracking-[0.4em] text-gold/70 mb-2">CASE STUDY</div>
          <h1 className="font-display font-black text-5xl sm:text-7xl gold-text chromatic mb-2">{heading}</h1>
          <div className="font-mono text-[10px] tracking-[0.3em] text-cream/40 mb-12">
            CLIENT: {cs.client.toUpperCase()} · {cs.year}
          </div>

          {/* Hero image */}
          <motion.div
            initial={{ opacity: 0, scale: 0.98 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.7, ease: [0.7, 0, 0.3, 1] }}
            className="rounded-2xl overflow-hidden glass-strong mb-16"
            style={{ maxHeight: "65vh" }}
          >
            <img
              src={item.imagePath}
              alt={item.title}
              className="w-full h-full object-cover"
              style={{ maxHeight: "65vh" }}
            />
          </motion.div>

          {/* 3-column narrative */}
          <div className="grid sm:grid-cols-3 gap-8 mb-16">
            {[
              { label: "THE BRIEF",    text: cs.brief },
              { label: "THE APPROACH", text: cs.approach },
              { label: "THE OUTCOME",  text: cs.outcome },
            ].map((section, i) => (
              <motion.div
                key={i}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.55, delay: 0.1 + i * 0.1, ease: [0.7, 0, 0.3, 1] }}
                className="relative glass specular grain rounded-2xl p-6"
              >
                <div className="font-mono text-[10px] tracking-[0.4em] text-gold/70 mb-3">
                  {section.label}
                </div>
                <p className="text-cream/70 text-sm leading-relaxed">{section.text}</p>
              </motion.div>
            ))}
          </div>

          {/* Prev / Next case studies */}
          {csList.length > 1 && (
            <div className="flex items-center justify-between gap-4 border-t border-white/[0.06] pt-8">
              {csIndex > 0 ? (
                <button
                  onClick={() => navigatePage(`work/${csList[csIndex - 1].id}`)}
                  className="inline-flex items-center gap-2 font-mono text-[10px] tracking-[0.3em] text-gold/70 hover:text-gold transition-colors"
                >
                  <ArrowLeft className="w-3 h-3" />
                  {csList[csIndex - 1].title.toUpperCase()}
                </button>
              ) : <div />}
              {csIndex < csList.length - 1 && (
                <button
                  onClick={() => navigatePage(`work/${csList[csIndex + 1].id}`)}
                  className="inline-flex items-center gap-2 font-mono text-[10px] tracking-[0.3em] text-gold/70 hover:text-gold transition-colors"
                >
                  {csList[csIndex + 1].title.toUpperCase()}
                  <ArrowRight className="w-3 h-3" />
                </button>
              )}
            </div>
          )}

          {/* CTA */}
          <div className="mt-16 text-center">
            <p className="text-cream/55 text-sm mb-5">Like what you see?</p>
            <button
              onClick={onContact}
              className="px-8 py-3.5 rounded-full glass-strong gold-border-glow font-mono text-xs tracking-[0.35em] text-gold hover:text-cream transition-colors animate-border-pulse"
            >
              START YOUR PROJECT
            </button>
          </div>
        </div>
      </section>
      <Footer onContact={onContact} />
    </>
  );
}
