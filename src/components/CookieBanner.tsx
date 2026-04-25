import { useEffect, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";

const STORAGE_KEY = "genisys_cookie_ok";

export default function CookieBanner() {
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    try {
      if (!localStorage.getItem(STORAGE_KEY)) setVisible(true);
    } catch { setVisible(true); }
  }, []);

  const dismiss = () => {
    try { localStorage.setItem(STORAGE_KEY, "1"); } catch {}
    setVisible(false);
  };

  return (
    <AnimatePresence>
      {visible && (
        <motion.div
          initial={{ y: 80, opacity: 0 }}
          animate={{ y: 0,  opacity: 1 }}
          exit={{   y: 80, opacity: 0 }}
          transition={{ duration: 0.45, ease: [0.7, 0, 0.3, 1] }}
          className="fixed bottom-6 left-1/2 -translate-x-1/2 z-[9600] w-[calc(100vw-2rem)] max-w-xl"
        >
          <div className="glass-strong specular grain rounded-2xl px-5 py-4 flex flex-col sm:flex-row items-start sm:items-center gap-4">
            <p className="text-cream/70 text-xs leading-relaxed flex-1">
              This site uses cookies to analyse performance and improve your experience.
              No data is sold. Ever.{" "}
              <a href="#/studio" className="text-gold/80 hover:text-gold underline underline-offset-2">
                Privacy policy
              </a>
              .
            </p>
            <button
              onClick={dismiss}
              className="flex-none px-5 py-2 rounded-full glass gold-border-glow font-mono text-[10px] tracking-[0.3em] text-gold hover:text-cream transition-colors whitespace-nowrap"
            >
              GOT IT
            </button>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
