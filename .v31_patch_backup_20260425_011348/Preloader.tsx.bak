import { motion, AnimatePresence } from "framer-motion";
import { useState } from "react";
import { useScramble } from "@/hooks/useScramble";
import { requestGyroPermission } from "@/hooks/useGyroscope";
import { haptic } from "@/lib/haptics";

/**
 * Preloader V2.5
 * — NO setTimeout auto-unmount. NO progress interval auto-complete.
 * — Stays visible INDEFINITELY until user clicks ENTER EXPERIENCE.
 * — Triggers premium haptic vibration on enter.
 */
export default function Preloader({ onDone }: { onDone: () => void }) {
  const [exiting, setExiting] = useState(false);
  const title = useScramble("GENISYS GRAPHICS", 1100);
  const sub = useScramble("OPERATIC IDENTITY SYSTEMS", 1400);

  const enter = async () => {
    haptic([12, 40, 20]);              // crisp double-tap pattern
    await requestGyroPermission();
    setExiting(true);
    // Wait for exit animation, THEN unmount via parent
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
            <div className="font-mono text-[11px] tracking-[0.4em] text-gold/70 mb-4">SYSTEM // BOOT</div>
            <h1 className="font-display font-black text-3xl sm:text-5xl gold-text chromatic tracking-tight">{title}</h1>
            <div className="font-mono text-[11px] sm:text-xs tracking-[0.3em] text-cream/80 mt-3">{sub}</div>

            <div className="mt-8 w-full h-[2px] bg-white/5 rounded-full overflow-hidden">
              <motion.div
                className="h-full bg-gradient-to-r from-gold-deep via-gold to-cream"
                initial={{ width: "0%" }}
                animate={{ width: "100%" }}
                transition={{ duration: 1.6, ease: "easeOut" }}
              />
            </div>
            <div className="mt-2 font-mono text-[10px] tracking-[0.4em] text-gold/70">READY</div>

            <button
              onClick={enter}
              className="mt-8 px-8 py-3 rounded-md border border-gold/60 text-gold font-mono text-xs tracking-[0.3em] hover:bg-gold hover:text-black transition-colors animate-border-pulse"
            >
              ENTER EXPERIENCE
            </button>
            <p className="mt-3 text-[10px] font-mono text-cream/60">Tap to enable motion parallax & audio</p>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
