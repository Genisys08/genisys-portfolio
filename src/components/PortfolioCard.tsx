import { useRef, useState }   from "react";
import { motion }              from "framer-motion";
import LazyImage               from "./LazyImage";
import { useGyroscopeTilt }    from "@/contexts/GyroscopeContext";
import { haptic }              from "@/lib/haptics";
import type { PortfolioItem }  from "@/data/portfolioData";

interface Props {
  item:           PortfolioItem;
  onOpen:         (i: PortfolioItem) => void;
  entranceDelay?: number;
}

export default function PortfolioCard({ item, onOpen, entranceDelay = 0 }: Props) {
  const ref      = useRef<HTMLDivElement>(null);
  const t        = useGyroscopeTilt();
  const [focused,  setFocused]  = useState(false);
  const [preview,  setPreview]  = useState(false);

  const sx     = t.x * 22;
  const sy     = t.y * 22 + 18;
  const shadow = `${-sx}px ${sy}px 40px hsl(var(--gold) / 0.28), 0 0 0 1px hsl(var(--gold) / 0.18)`;

  // ── UPGRADE-5: Long-press preview ─────────────────────────────────────
  const longPressTimer = useRef<ReturnType<typeof setTimeout> | null>(null);

  const onTouchStart = () => {
    longPressTimer.current = setTimeout(() => {
      haptic(15);
      setPreview(true);
    }, 600);
  };
  const cancelLongPress = () => {
    if (longPressTimer.current) {
      clearTimeout(longPressTimer.current);
      longPressTimer.current = null;
    }
  };
  const onTouchEnd = () => {
    cancelLongPress();
    // Keep preview visible briefly so the user can see it
    setTimeout(() => setPreview(false), 500);
  };

  return (
    <>
      <motion.div
        ref={ref}
        layout
        initial={{ opacity: 0, y: 28 }}
        animate={{ opacity: 1, y: 0 }}
        exit={{ opacity: 0, y: 12 }}
        transition={{
          duration: 0.6,
          delay:    entranceDelay,          // UPGRADE-3: waterfall cascade
          ease:     [0.7, 0, 0.3, 1],
        }}
        data-focusable
        data-focused={focused || undefined}
        onMouseEnter={() => setFocused(true)}
        onMouseLeave={() => setFocused(false)}
        onFocus={() => setFocused(true)}
        onBlur={() => setFocused(false)}
        onClick={() => onOpen(item)}
        onTouchStart={onTouchStart}
        onTouchEnd={onTouchEnd}
        onTouchMove={cancelLongPress}
        className="card-scanline relative group cursor-pointer mb-5 break-inside-avoid rounded-2xl overflow-hidden glass specular grain"
        style={{ boxShadow: shadow }}
      >
        {/* AESTHETIC-2: Gold scanline sweep element */}
        <div
          className="scan-line absolute inset-x-0 top-0 h-[2px] z-10 pointer-events-none"
          style={{
            background: "linear-gradient(90deg, transparent 0%, hsl(44 85% 65% / 0.9) 40%, hsl(44 95% 80%) 50%, hsl(44 85% 65% / 0.9) 60%, transparent 100%)",
            boxShadow:  "0 0 8px hsl(44 80% 60% / 0.8)",
          }}
        />

        <LazyImage
          src={item.imagePath}
          alt={item.title}
          className={item.tall ? "aspect-[3/4]" : "aspect-[4/5]"}
        />

        <div className="absolute inset-0 bg-gradient-to-t from-black/85 via-black/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
        <div className="absolute inset-x-0 bottom-0 p-4 translate-y-2 group-hover:translate-y-0 opacity-0 group-hover:opacity-100 transition-all duration-500">
          <div className="font-mono text-[10px] tracking-[0.3em] text-gold/80">
            {item.category.toUpperCase()}
          </div>
          <div className="text-cream font-semibold text-sm sm:text-base mt-1">
            {item.title}
          </div>
        </div>
      </motion.div>

      {/* UPGRADE-5: Long-press floating full-image preview */}
      {preview && (
        <div
          className="fixed inset-0 z-[115] grid place-items-center pointer-events-none"
          aria-hidden
        >
          <motion.div
            initial={{ opacity: 0, scale: 0.88 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.22, ease: [0.7, 0, 0.3, 1] }}
            className="w-[72vw] max-w-xs rounded-2xl overflow-hidden glass-strong gold-border-glow shadow-2xl"
          >
            <img
              src={item.imagePath}
              alt={item.title}
              className="w-full h-auto block"
            />
            <div className="p-3 font-mono text-[9px] tracking-[0.25em] text-gold/80 text-center">
              HOLD TO PREVIEW · TAP TO OPEN
            </div>
          </motion.div>
        </div>
      )}
    </>
  );
}
