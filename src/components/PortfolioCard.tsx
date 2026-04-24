import { useRef, useState } from "react";
import { motion } from "framer-motion";
import LazyImage from "./LazyImage";
import { useGyroscope } from "@/hooks/useGyroscope";
import type { PortfolioItem } from "@/data/portfolioData";

export default function PortfolioCard({ item, onOpen }: { item: PortfolioItem; onOpen: (i: PortfolioItem) => void }) {
  const ref = useRef<HTMLDivElement>(null);
  const t = useGyroscope();
  const [focused, setFocused] = useState(false);

  const sx = t.x * 22;
  const sy = t.y * 22 + 18;
  const shadow = `${-sx}px ${sy}px 40px hsl(var(--gold) / 0.28), 0 0 0 1px hsl(var(--gold) / 0.18)`;

  return (
    <motion.div
      ref={ref}
      layout
      initial={{ opacity: 0, y: 24 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: 12 }}
      transition={{ duration: 0.55, ease: [0.7, 0, 0.3, 1] }}
      data-focusable
      data-focused={focused || undefined}
      onMouseEnter={() => setFocused(true)}
      onMouseLeave={() => setFocused(false)}
      onFocus={() => setFocused(true)}
      onBlur={() => setFocused(false)}
      onClick={() => onOpen(item)}
      className="relative group cursor-pointer mb-5 break-inside-avoid rounded-2xl overflow-hidden glass specular grain"
      style={{ boxShadow: shadow }}
    >
      <LazyImage src={item.imagePath} alt={item.title} className={item.tall ? "aspect-[3/4]" : "aspect-[4/5]"} />
      <div className="absolute inset-0 bg-gradient-to-t from-black/85 via-black/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
      <div className="absolute inset-x-0 bottom-0 p-4 translate-y-2 group-hover:translate-y-0 opacity-0 group-hover:opacity-100 transition-all duration-500">
        <div className="font-mono text-[10px] tracking-[0.3em] text-gold/80">{item.category.toUpperCase()}</div>
        <div className="text-cream font-semibold text-sm sm:text-base mt-1">{item.title}</div>
      </div>
    </motion.div>
  );
}
