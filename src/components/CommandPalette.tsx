import { useEffect, useRef, useState, useMemo } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Search, X, FileText, Layers, DollarSign, User } from "lucide-react";
import { portfolio } from "@/data/portfolioData";
import { navigatePage, navigateSection } from "@/lib/router";

interface Cmd { id: string; label: string; sub: string; icon: React.ReactNode; run: () => void; }

const PAGES: Cmd[] = [
  { id: "p-home",     label: "Home",            sub: "Go to homepage",    icon: <Layers     className="w-4 h-4" />, run: () => navigateSection("top")   },
  { id: "p-work",     label: "Work",            sub: "View portfolio",    icon: <Layers     className="w-4 h-4" />, run: () => navigateSection("work")  },
  { id: "p-services", label: "Services",        sub: "Pricing & tiers",   icon: <DollarSign className="w-4 h-4" />, run: () => navigatePage("services") },
  { id: "p-studio",   label: "Studio",          sub: "About Genisys",     icon: <User       className="w-4 h-4" />, run: () => navigatePage("studio")   },
  { id: "p-contact",  label: "Start a Project", sub: "Open contact form", icon: <FileText   className="w-4 h-4" />, run: () => window.dispatchEvent(new Event("open-contact")) },
];
const PROJECT_CMDS: Cmd[] = portfolio.filter(p => p.caseStudy).map(p => ({
  id: `cs-${p.id}`, label: p.title, sub: `Case Study · ${p.category}`,
  icon: <FileText className="w-4 h-4" />, run: () => navigatePage(`work/${p.id}`),
}));
const TOP_OFFSET = 96;

export default function CommandPalette() {
  const [open,     setOpen]    = useState(false);
  const [query,    setQuery]   = useState("");
  const [cursor,   setCursor]  = useState(0);
  const [vvHeight, setVvH]     = useState(window.visualViewport?.height ?? window.innerHeight);
  const inputRef = useRef<HTMLInputElement>(null);

  // FIX-7: shrink palette as soft keyboard rises
  useEffect(() => {
    const upd = () => setVvH(window.visualViewport?.height ?? window.innerHeight);
    upd();
    const vv = window.visualViewport;
    if (vv) { vv.addEventListener("resize", upd); vv.addEventListener("scroll", upd); }
    window.addEventListener("resize", upd);
    return () => {
      if (vv) { vv.removeEventListener("resize", upd); vv.removeEventListener("scroll", upd); }
      window.removeEventListener("resize", upd);
    };
  }, []);
  const paletteMaxH = Math.max(180, vvHeight - TOP_OFFSET - 16);

  useEffect(() => {
    const h = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === "k") { e.preventDefault(); setOpen(o => !o); setQuery(""); setCursor(0); }
      if (!open && e.key === "/") { e.preventDefault(); setOpen(true); setQuery(""); setCursor(0); }
      if (e.key === "Escape") setOpen(false);
    };
    window.addEventListener("keydown", h);
    return () => window.removeEventListener("keydown", h);
  }, [open]);

  useEffect(() => { if (open) setTimeout(() => inputRef.current?.focus(), 60); }, [open]);
  useEffect(() => {
    if (!open) return;
    document.body.style.overflow = "hidden";
    return () => { document.body.style.overflow = ""; };
  }, [open]);

  const all     = useMemo(() => [...PAGES, ...PROJECT_CMDS], []);
  const results = useMemo(() => {
    if (!query.trim()) return all;
    const q = query.toLowerCase();
    return all.filter(c => c.label.toLowerCase().includes(q) || c.sub.toLowerCase().includes(q));
  }, [query, all]);

  const onKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "ArrowDown") { e.preventDefault(); setCursor(c => Math.min(c + 1, results.length - 1)); }
    if (e.key === "ArrowUp")   { e.preventDefault(); setCursor(c => Math.max(c - 1, 0)); }
    if (e.key === "Enter" && results[cursor]) { results[cursor].run(); setOpen(false); }
    if (e.key === "Escape") setOpen(false);
  };

  return (
    <>
      <div className="fixed bottom-6 right-20 z-[88] hidden sm:flex items-center gap-1.5 pointer-events-none" style={{ opacity: 0.35 }}>
        <kbd className="font-mono text-[9px] tracking-[0.2em] px-1.5 py-0.5 rounded"
          style={{ background: "hsl(44 40% 20%/0.8)", border: "1px solid hsl(44 50% 35%/0.5)", color: "hsl(44 70% 65%)" }}>⌘K</kbd>
        <span className="font-mono text-[9px] tracking-[0.2em] text-cream/40">SEARCH</span>
      </div>
      <AnimatePresence>
        {open && (
          <motion.div
            initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
            transition={{ duration: 0.2 }}
            className="fixed inset-0 z-[9600] flex justify-center"
            style={{ background: "rgba(0,0,0,0.82)", backdropFilter: "blur(18px)", WebkitBackdropFilter: "blur(18px)",
              paddingTop: TOP_OFFSET + "px", paddingLeft: "1rem", paddingRight: "1rem", alignItems: "flex-start" }}
            onClick={() => setOpen(false)}
          >
            <motion.div
              initial={{ scale: 0.96, y: -12 }} animate={{ scale: 1, y: 0 }} exit={{ scale: 0.97, y: -8 }}
              transition={{ duration: 0.28, ease: [0.7, 0, 0.3, 1] }}
              className="w-full max-w-xl glass-strong specular grain rounded-2xl overflow-hidden flex flex-col"
              style={{ maxHeight: paletteMaxH + "px" }}
              onClick={e => e.stopPropagation()}
            >
              <div className="flex items-center gap-3 px-4 py-3.5 border-b border-white/[0.07] flex-none">
                <Search className="w-4 h-4 text-gold/60 flex-none" />
                <input ref={inputRef} value={query}
                  onChange={e => { setQuery(e.target.value); setCursor(0); }}
                  onKeyDown={onKeyDown}
                  placeholder="Search projects, pages, actions…"
                  className="flex-1 bg-transparent text-cream text-sm placeholder:text-cream/30 focus:outline-none" />
                <button type="button" onClick={() => setOpen(false)}>
                  <X className="w-4 h-4 text-cream/40 hover:text-gold transition-colors" />
                </button>
              </div>
              <ul className="overflow-y-auto py-2 flex-1">
                {results.length === 0 && (
                  <li className="px-4 py-8 text-center font-mono text-[10px] tracking-[0.3em] text-cream/35">NO RESULTS</li>
                )}
                {results.map((cmd, i) => (
                  <li key={cmd.id}>
                    <button type="button" onMouseEnter={() => setCursor(i)} onClick={() => { cmd.run(); setOpen(false); }}
                      className="w-full flex items-center gap-3 px-4 py-2.5 text-left transition-colors"
                      style={{ background: i === cursor ? "hsl(44 50% 40%/0.12)" : "transparent", borderLeft: i === cursor ? "2px solid hsl(var(--gold)/0.7)" : "2px solid transparent" }}>
                      <span style={{ color: i === cursor ? "hsl(var(--gold))" : "hsl(44 50% 55%/0.55)" }}>{cmd.icon}</span>
                      <div className="flex-1 min-w-0">
                        <div className="text-cream text-sm font-medium truncate">{cmd.label}</div>
                        <div className="font-mono text-[9px] tracking-[0.2em] text-cream/40 truncate">{cmd.sub}</div>
                      </div>
                      {i === cursor && (
                        <kbd className="flex-none font-mono text-[9px] px-1.5 py-0.5 rounded"
                          style={{ background: "hsl(44 40% 20%/0.6)", border: "1px solid hsl(44 50% 35%/0.5)", color: "hsl(44 70% 65%)" }}>↵</kbd>
                      )}
                    </button>
                  </li>
                ))}
              </ul>
              <div className="px-4 py-2 border-t border-white/[0.05] flex gap-4 flex-none">
                {[["↑↓","Navigate"],["↵","Open"],["Esc","Close"]].map(([k,l]) => (
                  <div key={k} className="flex items-center gap-1.5">
                    <kbd className="font-mono text-[9px] px-1 py-0.5 rounded"
                      style={{ background: "hsl(44 30% 15%/0.8)", border: "1px solid hsl(44 30% 30%/0.4)", color: "hsl(44 60% 60%)" }}>{k}</kbd>
                    <span className="font-mono text-[9px] tracking-[0.2em] text-cream/30">{l}</span>
                  </div>
                ))}
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
