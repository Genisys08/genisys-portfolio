import { useEffect, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Menu, X } from "lucide-react";
import { useScramble } from "@/hooks/useScramble";
import { useMagnetic } from "@/hooks/useMagnetic";
import { navigatePage, navigateSection, type Route } from "@/lib/router";
import { SOCIAL } from "@/data/siteConfig";

interface Props { route: Route; }

const PAGE_LINKS = [
  { label: "WORK",     action: () => navigateSection("work"),    page: "home" as const },
  { label: "SERVICES", action: () => navigatePage("services"),   page: "services" as const },
  { label: "STUDIO",   action: () => navigatePage("studio"),     page: "studio" as const },
  { label: "PROCESS",  action: () => navigateSection("process"), page: "home" as const },
];

const SOCIAL_LABELS: Record<string, string> = {
  instagram: "IG", twitter: "X", behance: "BE",
  dribbble: "DR", tiktok: "TK", linkedin: "LI",
  youtube: "YT", pinterest: "PI",
};

export default function Navigation({ route }: Props) {
  const brand   = useScramble("GENISYS", 900);
  const [open, setOpen] = useState(false);
  const menuRef = useMagnetic<HTMLButtonElement>(0.25);

  useEffect(() => {
    if (!open) return;
    const sw = window.innerWidth - document.documentElement.clientWidth;
    document.body.style.overflow     = "hidden";
    document.body.style.paddingRight = sw + "px";
    return () => { document.body.style.overflow = ""; document.body.style.paddingRight = ""; };
  }, [open]);

  // Close overlay on route change
  useEffect(() => { setOpen(false); }, [route]);

  const close = () => setOpen(false);

  const isActive = (link: typeof PAGE_LINKS[0]) => {
    if (link.page === "services" && route.page === "services") return true;
    if (link.page === "studio"   && route.page === "studio")   return true;
    return false;
  };

  return (
    <>
      <header className="fixed top-0 left-0 right-0 z-[70] flex items-center justify-between px-4 sm:px-8 pt-4">
        <button
          onClick={() => navigateSection("top")}
          className="font-display font-black text-base sm:text-lg gold-text tracking-tight"
        >
          {brand}
        </button>

        {/* Desktop */}
        <nav className="hidden sm:flex items-center gap-1 glass rounded-full px-3 py-1.5">
          {PAGE_LINKS.map(l => (
            <DesktopNavLink key={l.label} label={l.label} active={isActive(l)} onClick={l.action} />
          ))}
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

      {/* Mobile overlay */}
      <AnimatePresence>
        {open && (
          <motion.div
            initial={{ opacity: 0, clipPath: "circle(0% at 95% 5%)" }}
            animate={{ opacity: 1, clipPath: "circle(150% at 95% 5%)" }}
            exit={{   opacity: 0, clipPath: "circle(0% at 95% 5%)" }}
            transition={{ duration: 0.5, ease: [0.7, 0, 0.3, 1] }}
            className="fixed inset-0 z-[150] flex flex-col justify-between py-16 px-8 sm:hidden"
            style={{ background: "rgba(0,0,0,0.97)", backdropFilter: "blur(28px)", WebkitBackdropFilter: "blur(28px)" }}
          >
            <button
              onClick={close}
              aria-label="Close navigation"
              className="absolute top-5 right-5 grid place-items-center w-11 h-11 rounded-full glass-strong gold-border-glow"
            >
              <X className="w-5 h-5 text-gold" />
            </button>

            {/* Page links */}
            <nav className="flex flex-col gap-8 mt-8">
              {PAGE_LINKS.map((l, i) => (
                <motion.button
                  key={l.label}
                  onClick={() => { l.action(); close(); }}
                  initial={{ opacity: 0, x: -30 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ duration: 0.4, delay: 0.1 + i * 0.08, ease: [0.7, 0, 0.3, 1] }}
                  className="font-display font-black text-5xl gold-text tracking-tight text-left"
                >
                  {l.label}
                </motion.button>
              ))}
            </nav>

            {/* Bottom: CTA + social row */}
            <div className="space-y-6">
              <motion.button
                initial={{ opacity: 0, y: 16 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.4, delay: 0.5, ease: [0.7, 0, 0.3, 1] }}
                onClick={() => { close(); window.dispatchEvent(new Event("open-contact")); }}
                className="w-full py-3 rounded-full glass-strong gold-border-glow font-mono text-xs tracking-[0.3em] text-gold"
              >
                START A PROJECT
              </motion.button>

              {/* Social icons */}
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.6 }}
                className="flex flex-wrap gap-3"
              >
                {Object.entries(SOCIAL).map(([platform, url]) => (
                  <a
                    key={platform}
                    href={url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="w-9 h-9 grid place-items-center rounded-lg font-mono text-[10px] font-bold transition-all hover:scale-110"
                    style={{ background: "hsl(var(--gold)/0.08)", border: "1px solid hsl(var(--gold)/0.2)", color: "hsl(var(--gold)/0.7)" }}
                  >
                    {SOCIAL_LABELS[platform] ?? platform.slice(0, 2).toUpperCase()}
                  </a>
                ))}
              </motion.div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}

function DesktopNavLink({ label, active, onClick }: { label: string; active: boolean; onClick: () => void }) {
  const text = useScramble(label, 700);
  const ref  = useMagnetic<HTMLButtonElement>(0.3);
  return (
    <button
      ref={ref}
      onClick={onClick}
      className={
        "font-mono text-[11px] tracking-[0.35em] transition-colors px-2 py-1 " +
        (active ? "text-gold" : "text-cream/80 hover:text-gold")
      }
    >
      {text}
    </button>
  );
}
