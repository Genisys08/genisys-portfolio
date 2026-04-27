import { motion } from "framer-motion";
import { ArrowLeft } from "lucide-react";
import { useScramble } from "@/hooks/useScramble";
import { useMagnetic } from "@/hooks/useMagnetic";
import { SOCIAL, STUDIO } from "@/data/siteConfig";
import SocialIcon from "@/components/SocialIcon";
import { navigateSection } from "@/lib/router";
import Footer from "@/components/Footer";

const TOOLS = [
  "Adobe Illustrator", "Adobe Photoshop", "Adobe InDesign",
  "Figma", "After Effects", "Premiere Pro",
  "Blender", "Procreate", "Notion",
];

const VALUES = [
  { title: "Precision over speed",   body: "Every decision is intentional. We would rather deliver late and correct than fast and mediocre." },
  { title: "Restraint is a skill",   body: "The most powerful designs often feature what was removed. We know when to stop." },
  { title: "Cinematic standards",    body: "We evaluate our work the way a film critic evaluates a frame. Composition, tension, rhythm, impact." },
  { title: "No shortcuts. Ever.",    body: "Templates are not used. Stock is not used. Every mark is original, every system is bespoke." },
];

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

export default function StudioPage({ onContact }: Props) {
  const heading = useScramble("THE STUDIO", 1100);

  return (
    <>
      <section className="relative px-4 sm:px-8 pt-32 pb-20">
        <div
          aria-hidden
          className="pointer-events-none absolute inset-0"
          style={{ background: "radial-gradient(ellipse 50% 40% at 20% 30%, hsl(44 65% 35% / 0.08), transparent)" }}
        />
        <div className="max-w-5xl mx-auto">
          <BackBtn />

          {/* ── Header ─────────────────────────────────────────────── */}
          <div className="font-mono text-[10px] tracking-[0.5em] text-gold/70 mb-2">STUDIO PROFILE</div>
          <h1 className="font-display font-black text-5xl sm:text-7xl gold-text chromatic mb-16">{heading}</h1>

          {/* ── Bio card ──────────────────────────────────────────── */}
          <motion.div
            initial={{ opacity: 0, y: 24 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, ease: [0.7, 0, 0.3, 1] }}
            className="relative glass-strong specular grain rounded-2xl p-8 sm:p-12 mb-12"
          >
            <div className="flex flex-col sm:flex-row gap-8 sm:gap-12">
              {/* Avatar / initials */}
              <div className="flex-none">
                <div
                  className="w-24 h-24 sm:w-32 sm:h-32 rounded-2xl grid place-items-center font-display font-black text-3xl sm:text-4xl gold-text"
                  style={{
                    background: "linear-gradient(145deg, hsl(44 70% 10%), hsl(44 50% 7%))",
                    border:     "1px solid hsl(var(--gold)/0.35)",
                    boxShadow:  "0 0 30px hsl(var(--gold)/0.15)",
                  }}
                >
                  JO
                </div>
                {/* Social icons row */}
                <div className="mt-4 flex gap-2 flex-wrap">
                  {Object.entries(SOCIAL).slice(0, 4).map(([platform, url]) => (
                    <a
                      key={platform}
                      href={url}
                      target="_blank"
                      rel="noopener noreferrer"
                      title={platform}
                      className="w-8 h-8 grid place-items-center rounded-lg font-mono text-[9px] transition-all duration-200 hover:scale-110"
                      style={{ background: "hsl(var(--gold)/0.08)", border: "1px solid hsl(var(--gold)/0.2)", color: "hsl(var(--gold)/0.7)" }}
                    >
                      <SocialIcon platform={platform} size={15} />
                    </a>
                  ))}
                </div>
              </div>

              <div>
                <div className="font-mono text-[10px] tracking-[0.4em] text-gold/70 mb-1">FOUNDER & CREATIVE DIRECTOR</div>
                <h2 className="font-display font-black text-2xl sm:text-3xl text-cream mb-4">John Osaze</h2>
                <p className="text-cream/70 text-sm sm:text-base leading-relaxed mb-4">
                  I started Genisys because I was tired of seeing brilliant brands get average design.
                  The work that ends up in museums, in cultural memory, on the walls of the most influential
                  spaces — that work was built with obsession. I wanted to bring that standard to every brief,
                  regardless of the client's size or industry.
                </p>
                <p className="text-cream/60 text-sm leading-relaxed">
                  Based in {STUDIO.location}. Working with founders, agencies, and cultural institutions worldwide.
                  Every project is handled personally. No outsourcing, no templates, no compromise.
                </p>
              </div>
            </div>
          </motion.div>

          {/* ── Values grid ───────────────────────────────────────── */}
          <div className="mb-14">
            <div className="font-mono text-[10px] tracking-[0.4em] text-gold/70 mb-6">CORE PRINCIPLES</div>
            <div className="grid sm:grid-cols-2 gap-4">
              {VALUES.map((v, i) => (
                <motion.div
                  key={i}
                  initial={{ opacity: 0, y: 16 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.5, delay: i * 0.08, ease: [0.7, 0, 0.3, 1] }}
                  className="relative glass specular grain rounded-2xl p-6"
                >
                  <div className="font-display font-black text-lg text-cream mb-2">{v.title}</div>
                  <p className="text-cream/60 text-sm leading-relaxed">{v.body}</p>
                </motion.div>
              ))}
            </div>
          </div>

          {/* ── Tools ─────────────────────────────────────────────── */}
          <div className="mb-14">
            <div className="font-mono text-[10px] tracking-[0.4em] text-gold/70 mb-6">TOOLS & STACK</div>
            <div className="flex flex-wrap gap-2">
              {TOOLS.map(tool => (
                <span
                  key={tool}
                  className="px-3 py-1.5 rounded-full font-mono text-[10px] tracking-[0.2em] text-cream/70"
                  style={{ background: "hsl(var(--gold)/0.07)", border: "1px solid hsl(var(--gold)/0.2)" }}
                >
                  {tool.toUpperCase()}
                </span>
              ))}
            </div>
          </div>

          {/* ── CTA ───────────────────────────────────────────────── */}
          <div className="text-center pt-8 border-t border-white/[0.06]">
            <p className="text-cream/60 text-sm mb-6">Want to work together?</p>
            <button
              onClick={onContact}
              className="px-8 py-3.5 rounded-full glass-strong gold-border-glow font-mono text-xs tracking-[0.35em] text-gold hover:text-cream transition-colors animate-border-pulse"
            >
              START A CONVERSATION
            </button>
          </div>
        </div>
      </section>
      <Footer onContact={onContact} />
    </>
  );
}
