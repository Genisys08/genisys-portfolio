import { motion, AnimatePresence } from "framer-motion";
import { X } from "lucide-react";
import type { PortfolioItem } from "@/data/portfolioData";
import { useDominantColor } from "@/hooks/useDominantColor";

export default function Lightbox({
  item,
  onClose,
}: {
  item: PortfolioItem | null;
  onClose: () => void;
}) {
  const color = useDominantColor(item?.imagePath);

  return (
    <AnimatePresence>
      {item && (
        <motion.div
          key={item.id}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.35 }}
          className="fixed inset-0 z-[120] grid place-items-center p-4 sm:p-10"
          style={{
            background: `radial-gradient(80% 60% at 50% 50%, ${color}33, #000 80%)`,
            backdropFilter: "blur(14px)",
          }}
          onClick={onClose}
        >
          {/*
           * FIX v3: Close button — explicit z-index 9999 via inline style.
           * Repositioned to top-right corner, separate from VibeToggle (now bottom-left).
           * Never trappable by any stacking context on the page.
           */}
          <button
            aria-label="Close lightbox"
            onClick={onClose}
            style={{ zIndex: 9999 }}
            className="absolute top-5 right-5 sm:top-7 sm:right-7 grid place-items-center w-11 h-11 rounded-full glass-strong gold-border-glow"
          >
            <X className="w-5 h-5 text-gold" />
          </button>

          <motion.div
            initial={{ scale: 0.96, y: 20 }}
            animate={{ scale: 1, y: 0 }}
            exit={{ scale: 0.98, y: 10 }}
            transition={{ duration: 0.45, ease: [0.7, 0, 0.3, 1] }}
            className="relative max-w-4xl w-full glass-strong specular grain rounded-2xl overflow-hidden"
            onClick={(e) => e.stopPropagation()}
          >
            <img
              src={item.imagePath}
              alt={item.title}
              className="w-full max-h-[70dvh] object-cover"
            />
            <div className="p-5 sm:p-8">
              <div className="font-mono text-[10px] tracking-[0.3em] text-gold/80">
                {item.category.toUpperCase()}
              </div>
              <h3 className="mt-2 font-display text-2xl sm:text-3xl gold-text font-black">
                {item.title}
              </h3>
              {item.description && (
                <p className="mt-3 text-cream/70 text-sm leading-relaxed">
                  {item.description}
                </p>
              )}
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
