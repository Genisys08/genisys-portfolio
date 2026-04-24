import { useEffect, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { X, ChevronLeft, ChevronRight } from "lucide-react";
import type { PortfolioItem } from "@/data/portfolioData";
import { useDominantColor }   from "@/hooks/useDominantColor";

interface Props {
  items:      PortfolioItem[];
  index:      number | null;
  onClose:    () => void;
  onNavigate: (index: number) => void;
}

export default function Lightbox({ items, index, onClose, onNavigate }: Props) {
  const item          = index !== null ? items[index] : null;
  const color         = useDominantColor(item?.imagePath);
  const touchStartX   = useRef<number | null>(null);

  // ── Body scroll lock ─────────────────────────────────────────────────────
  useEffect(() => {
    if (index === null) return;
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => { document.body.style.overflow = prev || "unset"; };
  }, [index]);

  // ── Keyboard navigation ──────────────────────────────────────────────────
  useEffect(() => {
    if (index === null) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "ArrowLeft")  goPrev();
      if (e.key === "ArrowRight") goNext();
      if (e.key === "Escape")     onClose();
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [index]);

  const goPrev = () => { if (index !== null && index > 0)                    onNavigate(index - 1); };
  const goNext = () => { if (index !== null && index < items.length - 1)     onNavigate(index + 1); };

  // ── Touch swipe ──────────────────────────────────────────────────────────
  const onTouchStart = (e: React.TouchEvent) => {
    touchStartX.current = e.touches[0].clientX;
  };
  const onTouchEnd = (e: React.TouchEvent) => {
    if (touchStartX.current === null) return;
    const dx = e.changedTouches[0].clientX - touchStartX.current;
    if (Math.abs(dx) > 50) { dx < 0 ? goNext() : goPrev(); }
    touchStartX.current = null;
  };

  const hasPrev = index !== null && index > 0;
  const hasNext = index !== null && index < items.length - 1;

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
            background:      `radial-gradient(80% 60% at 50% 50%, ${color}33, #000 80%)`,
            backdropFilter:  "blur(14px)",
          }}
          onClick={onClose}
          onTouchStart={onTouchStart}
          onTouchEnd={onTouchEnd}
        >
          {/* ── Close ───────────────────────────────────────────────── */}
          <button
            aria-label="Close lightbox"
            onClick={onClose}
            style={{ zIndex: 9999 }}
            className="absolute top-5 right-5 sm:top-7 sm:right-7 grid place-items-center w-11 h-11 rounded-full glass-strong gold-border-glow"
          >
            <X className="w-5 h-5 text-gold" />
          </button>

          {/* ── Prev ────────────────────────────────────────────────── */}
          {hasPrev && (
            <button
              aria-label="Previous image"
              onClick={e => { e.stopPropagation(); goPrev(); }}
              style={{ zIndex: 9999 }}
              className="absolute left-3 sm:left-6 top-1/2 -translate-y-1/2 grid place-items-center w-11 h-11 rounded-full glass-strong gold-border-glow"
            >
              <ChevronLeft className="w-5 h-5 text-gold" />
            </button>
          )}

          {/* ── Next ────────────────────────────────────────────────── */}
          {hasNext && (
            <button
              aria-label="Next image"
              onClick={e => { e.stopPropagation(); goNext(); }}
              style={{ zIndex: 9999 }}
              className="absolute right-3 sm:right-20 top-1/2 -translate-y-1/2 grid place-items-center w-11 h-11 rounded-full glass-strong gold-border-glow"
            >
              <ChevronRight className="w-5 h-5 text-gold" />
            </button>
          )}

          {/* ── Counter ─────────────────────────────────────────────── */}
          {index !== null && (
            <div
              className="absolute bottom-6 left-1/2 -translate-x-1/2 font-mono text-[10px] tracking-[0.3em]"
              style={{ color: "hsl(var(--gold) / 0.55)" }}
            >
              {index + 1} / {items.length}
            </div>
          )}

          {/* ── Card — key includes id so it re-animates on navigation ─ */}
          <motion.div
            key={item.id + "-card"}
            initial={{ scale: 0.96, y: 20 }}
            animate={{ scale: 1,    y: 0  }}
            exit={{   scale: 0.98,  y: 10 }}
            transition={{ duration: 0.45, ease: [0.7, 0, 0.3, 1] }}
            className="relative max-w-4xl w-full max-h-[95vh] overflow-y-auto glass-strong specular grain rounded-2xl"
            onClick={e => e.stopPropagation()}
          >
            <img
              src={item.imagePath}
              alt={item.title}
              className="w-auto max-h-[90vh] max-w-full object-contain mx-auto block"
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
