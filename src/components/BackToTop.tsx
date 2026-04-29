import { useEffect, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { ArrowUp } from "lucide-react";

export default function BackToTop({ raised = false }: { raised?: boolean }) {
  const [show, setShow] = useState(false);
  useEffect(() => {
    const h = () => setShow(window.scrollY > 600);
    window.addEventListener("scroll", h, { passive: true });
    return () => window.removeEventListener("scroll", h);
  }, []);

  return (
    <AnimatePresence>
      {show && (
        <motion.button
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          exit={{ opacity: 0, scale: 0.8 }}
          transition={{ duration: 0.3 }}
          onClick={() => window.scrollTo({ top: 0, behavior: "smooth" })}
          aria-label="Back to top"
          className="fixed right-6 z-[9400] w-11 h-11 grid place-items-center rounded-full glass-strong gold-border-glow"
          style={{
            bottom:     raised
              ? "max(calc(env(safe-area-inset-bottom, 0px) + 155px), 163px)"
              : "24px",
            transition: "bottom 0.4s cubic-bezier(0.7,0,0.3,1)",
          }}
        >
          <ArrowUp className="w-4 h-4 text-gold" />
        </motion.button>
      )}
    </AnimatePresence>
  );
}
