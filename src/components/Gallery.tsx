import { useMemo, useState } from "react";
import { AnimatePresence } from "framer-motion";
import { portfolio, type Category, type PortfolioItem } from "@/data/portfolioData";
import PortfolioCard from "./PortfolioCard";
import Lightbox from "./Lightbox";
import { useScramble } from "@/hooks/useScramble";
import { useMagnetic } from "@/hooks/useMagnetic";
import { pulseLetterbox } from "./Letterbox";
import { haptic } from "@/lib/haptics";

const TABS: ("All" | Category)[] = ["All", "Flyers", "Logos", "Brand Identity"];

function Tab({
  label, active, onClick,
}: { label: string; active: boolean; onClick: () => void; }) {
  const text = useScramble(label.toUpperCase(), 700, active);
  const ref = useMagnetic<HTMLButtonElement>(0.3);
  return (
    <button
      ref={ref}
      onClick={onClick}
      data-magnetic
      className={
        "relative px-4 py-2 rounded-full font-mono text-[10px] sm:text-[11px] tracking-[0.3em] transition-colors " +
        (active ? "bg-gold text-black gold-border-glow" : "text-cream/85 hover:text-gold border border-white/10")
      }
    >
      {text}
    </button>
  );
}

export default function Gallery() {
  const [filter, setFilter] = useState<"All" | Category>("All");
  const [open, setOpen] = useState<PortfolioItem | null>(null);
  const heading = useScramble("SELECTED WORK", 1100, filter);

  const items = useMemo(
    () => (filter === "All" ? portfolio : portfolio.filter((p) => p.category === filter)),
    [filter]
  );

  const setF = (f: "All" | Category) => {
    if (f === filter) return;
    haptic(8);              // V2.5: subtle tap on category change
    pulseLetterbox();
    setFilter(f);
  };

  return (
    <section id="work" className="relative px-4 sm:px-8 py-24">
      <div className="max-w-6xl mx-auto">
        <div className="flex items-end justify-between gap-4 mb-8 flex-wrap">
          <div>
            <div className="font-mono text-[10px] tracking-[0.4em] text-gold/80">VISUAL PORTFOLIO</div>
            <h2 className="mt-2 font-display font-black text-4xl sm:text-6xl gold-text chromatic">{heading}</h2>
          </div>
          <div className="flex flex-wrap gap-2">
            {TABS.map((t) => (
              <Tab key={t} label={t} active={filter === t} onClick={() => setF(t)} />
            ))}
          </div>
        </div>

        <div className="columns-1 sm:columns-2 lg:columns-3 gap-5">
          <AnimatePresence mode="popLayout">
            {items.map((item) => (
              <PortfolioCard key={item.id} item={item} onOpen={setOpen} />
            ))}
          </AnimatePresence>
        </div>
      </div>
      <Lightbox item={open} onClose={() => setOpen(null)} />
    </section>
  );
}
