import { useEffect, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Menu, X } from "lucide-react";
import { useScramble } from "@/hooks/useScramble";
import { useMagnetic } from "@/hooks/useMagnetic";

const LINKS = [
  { id: "work",    label: "WORK"    },
  { id: "about",   label: "ABOUT"   },
  { id: "process", label: "PROCESS" },
];

function NavLink({
  id, label, onClick,
}: { id: string; label: string; onClick?: () => void }) {
  const text = useScramble(label, 700);
  const ref  = useMagnetic<HTMLAnchorElement>(0.3);
  return (
    <a
      ref={ref}
      href={`#${id}`}
      onClick={onClick}
      className="font-mono text-[11px] tracking-[0.35em] text-cream/80 hover:text-gold transition-colors px-2 py-1"
    >
      {text}
    </a>
  );
}

export default function Navigation() {
  const brand                     = useScramble("GENISYS", 900);
  const [open, setOpen]           = useState(false);
  const menuRef                   = useMagnetic<HTMLButtonElement>(0.25);

  // Body scroll lock while mobile menu is open
  useEffect(() => {
    if (!open) return;
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => { document.body.style.overflow = prev || "unset"; };
  }, [open]);

  const close = () => setOpen(false);

  return (
    <>
      {/* ── Top bar ─────────────────────────────────────────────────── */}
      <header className="fixed top-0 left-0 right-0 z-[70] flex items-center justify-between px-4 sm:px-8 pt-4">
        <a href="#top" className="font-display font-black text-base sm:text-lg gold-text tracking-tight">
          {brand}
        </a>

        {/* Desktop links */}
        <nav className="hidden sm:flex items-center gap-1 glass rounded-full px-3 py-1.5">
          {LINKS.map(l => <NavLink key={l.id} {...l} />)}
        </nav>

        {/* Mobile hamburger */}
        <button
          ref={menuRef}
          onClick={() => setOpen(true)}
          aria-label="Open navigation"
          className="sm:hidden grid place-items-center w-10 h-10 rounded-full glass gold-border-glow"
        >
          <Menu className="w-4 h-4 text-gold" />
        </button>
      </header>

      {/* ── Mobile full-screen overlay ───────────────────────────────── */}
      <AnimatePresence>
        {open && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.3 }}
            className="fixed inset-0 z-[150] grid place-items-center sm:hidden"
            style={{ background: "rgba(0,0,0,0.97)", backdropFilter: "blur(28px)" }}
          >
            {/* Close button */}
            <button
              onClick={close}
              aria-label="Close navigation"
              className="absolute top-5 right-5 grid place-items-center w-11 h-11 rounded-full glass-strong gold-border-glow"
            >
              <X className="w-5 h-5 text-gold" />
            </button>

            {/* Nav links */}
            <nav className="flex flex-col items-center gap-10">
              {LINKS.map((l, i) => (
                <motion.a
                  key={l.id}
                  href={`#${l.id}`}
                  onClick={close}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.4, delay: i * 0.08, ease: [0.7, 0, 0.3, 1] }}
                  className="font-display font-black text-5xl gold-text tracking-tight"
                >
                  {l.label}
                </motion.a>
              ))}

              <motion.button
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.4, delay: LINKS.length * 0.08, ease: [0.7, 0, 0.3, 1] }}
                onClick={() => {
                  close();
                  window.dispatchEvent(new Event("open-contact"));
                }}
                className="mt-2 px-8 py-3 rounded-full glass-strong gold-border-glow font-mono text-xs tracking-[0.3em] text-gold"
              >
                START A PROJECT
              </motion.button>
            </nav>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
