import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Plus, Minus } from "lucide-react";
import { FAQ as FAQ_DATA } from "@/data/siteConfig";
import { useScramble } from "@/hooks/useScramble";

export default function FAQ() {
  const [open, setOpen] = useState<number | null>(null);
  const heading = useScramble("COMMON QUESTIONS", 1100);

  return (
    <section id="faq" className="relative px-4 sm:px-8 py-24">
      <div className="max-w-3xl mx-auto">
        <div className="font-mono text-[10px] tracking-[0.4em] text-gold/80 mb-2">
          QUICK ANSWERS
        </div>
        <h2 className="font-display font-black text-4xl sm:text-5xl gold-text chromatic mb-10">
          {heading}
        </h2>

        <div className="space-y-3">
          {FAQ_DATA.map((item, i) => (
            <div
              key={i}
              className="glass specular grain rounded-2xl overflow-hidden"
            >
              <button
                onClick={() => setOpen(open === i ? null : i)}
                className="w-full flex items-center justify-between gap-4 px-6 py-5 text-left"
              >
                <span className="text-cream font-semibold text-sm sm:text-base leading-snug">
                  {item.q}
                </span>
                <span className="flex-none w-7 h-7 grid place-items-center rounded-full"
                  style={{ background: "hsl(var(--gold)/0.1)", border: "1px solid hsl(var(--gold)/0.3)" }}>
                  {open === i
                    ? <Minus className="w-3 h-3 text-gold" />
                    : <Plus  className="w-3 h-3 text-gold" />
                  }
                </span>
              </button>

              <AnimatePresence initial={false}>
                {open === i && (
                  <motion.div
                    key="content"
                    initial={{ height: 0, opacity: 0 }}
                    animate={{ height: "auto", opacity: 1 }}
                    exit={{   height: 0, opacity: 0 }}
                    transition={{ duration: 0.35, ease: [0.7, 0, 0.3, 1] }}
                    style={{ overflow: "hidden" }}
                  >
                    <div className="px-6 pb-5 text-cream/65 text-sm leading-relaxed border-t border-white/[0.05] pt-4">
                      {item.a}
                    </div>
                  </motion.div>
                )}
              </AnimatePresence>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
