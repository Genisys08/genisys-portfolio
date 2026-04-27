import { motion, AnimatePresence } from "framer-motion";
import { useState } from "react";
import { useScramble } from "@/hooks/useScramble";
import { requestGyroPermission } from "@/hooks/useGyroscope";
import { haptic } from "@/lib/haptics";

/**
 * Preloader V3.1 — G-Monogram Self-Draw
 *
 * UPGRADE-4: The spinner is replaced with a full Framer Motion SVG animation.
 * The G letterform (same path as favicon.svg) draws itself via pathLength
 * from 0 → 1 over 1.8 s with an ease-in-out curve.
 * After draw completion a `scale` spring bounces the G once, then the
 * existing title scramble + progress bar + ENTER button appear below.
 */
export default function Preloader({ onDone }: { onDone: () => void }) {
  const [exiting, setExiting] = useState(false);
  const title = useScramble("GENISYS GRAPHICS", 1100);
  const sub   = useScramble("OPERATIC IDENTITY SYSTEMS", 1400);

  const enter = async () => {
    haptic([12, 40, 20]);
    await requestGyroPermission();
    setExiting(true);
    setTimeout(onDone, 650);
  };

  return (
    <AnimatePresence>
      {!exiting && (
        <motion.div
          key="pre"
          initial={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.6 }}
          className="fixed inset-0 z-[100] bg-black grid place-items-center"
        >
          <div className="grid place-items-center text-center px-6 w-full max-w-[520px]">

            {/* ── UPGRADE-4: Animated G-monogram ─────────────────────── */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ duration: 0.4 }}
              className="mb-6"
            >
              <svg
                viewBox="0 0 64 64"
                className="w-24 h-24 mx-auto"
                style={{ overflow: "visible" }}
              >
                <defs>
                  <linearGradient id="preload-gold" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%"   stopColor="#FFE9A0" />
                    <stop offset="40%"  stopColor="#D4AF37" />
                    <stop offset="100%" stopColor="#8B6914" />
                  </linearGradient>
                  <filter id="preload-glow">
                    <feGaussianBlur stdDeviation="2" result="blur" />
                    <feMerge>
                      <feMergeNode in="blur" />
                      <feMergeNode in="SourceGraphic" />
                    </feMerge>
                  </filter>
                </defs>

                {/* Background square */}
                <motion.rect
                  width="64" height="64" rx="14"
                  fill="transparent"
                  stroke="hsl(44 70% 50% / 0.2)"
                  strokeWidth="1"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ delay: 0.2, duration: 0.6 }}
                />

                {/* G path — self-drawing via pathLength */}
                <motion.path
                  d="M 41 23 A 13 13 0 1 0 41 41 L 41 32 L 31 32"
                  stroke="url(#preload-gold)"
                  strokeWidth="4.5"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  fill="none"
                  filter="url(#preload-glow)"
                  initial={{ pathLength: 0, opacity: 0 }}
                  animate={{ pathLength: 1, opacity: 1 }}
                  transition={{
                    pathLength: { duration: 1.8, ease: "easeInOut", delay: 0.3 },
                    opacity:    { duration: 0.4, delay: 0.3 },
                  }}
                />

                {/* Completion glow burst */}
                <motion.circle
                  cx="32" cy="32" r="28"
                  fill="none"
                  stroke="hsl(44 80% 55% / 0.35)"
                  strokeWidth="1"
                  initial={{ scale: 0.6, opacity: 0 }}
                  animate={{ scale: 1.15, opacity: [0, 0.6, 0] }}
                  transition={{ duration: 0.7, delay: 2.1, ease: "easeOut" }}
                  style={{ transformOrigin: "32px 32px" }}
                />
              </svg>
            </motion.div>

            {/* ── Existing preloader body ─────────────────────────────── */}
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 1.6, duration: 0.55, ease: [0.7, 0, 0.3, 1] }}
              className="w-full"
            >
              <div className="font-mono text-[11px] tracking-[0.4em] text-gold/70 mb-4">
                SYSTEM // BOOT
              </div>
              <h1 className="font-display font-black text-3xl sm:text-5xl gold-text chromatic tracking-tight">
                {title}
              </h1>
              <div className="font-mono text-[11px] sm:text-xs tracking-[0.3em] text-cream/80 mt-3">
                {sub}
              </div>

              <div className="mt-8 w-full h-[2px] bg-white/5 rounded-full overflow-hidden">
                <motion.div
                  className="h-full bg-gradient-to-r from-gold-deep via-gold to-cream"
                  initial={{ width: "0%" }}
                  animate={{ width: "100%" }}
                  transition={{ duration: 1.6, ease: "easeOut", delay: 1.6 }}
                />
              </div>
              <div className="mt-2 font-mono text-[10px] tracking-[0.4em] text-gold/70">
                READY
              </div>

              <button
                onClick={enter}
                className="mt-8 px-8 py-3 rounded-md border border-gold/60 text-gold font-mono text-xs tracking-[0.3em] hover:bg-gold hover:text-black transition-colors animate-border-pulse"
              >
                ENTER EXPERIENCE
              </button>
              <p className="mt-3 text-[10px] font-mono text-cream/60">
                Tap to enable motion parallax &amp; audio
              </p>
            </motion.div>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
