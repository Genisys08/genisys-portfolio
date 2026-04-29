#!/usr/bin/env bash
# =============================================================================
#  Genisys Portfolio — v4.0 Patch Script
#  Run from the ROOT of your project folder:  bash patch_v4.sh
# =============================================================================
set -e

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo ""
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║   GENISYS  ·  v4.0 Patch                    ║"
echo "  ║   Applying 7 fixes + Settings page           ║"
echo "  ╚══════════════════════════════════════════════╝"
echo ""

# ── Helper ────────────────────────────────────────────────────────────────────
write_file() {
  local path="$1"
  mkdir -p "$(dirname "$path")"
  # Content is piped via stdin (heredoc from caller)
  cat > "$path"
  echo "  ✔  $path"
}

# =============================================================================
# FILE 1 — src/lib/router.ts
# =============================================================================
write_file "$ROOT/src/lib/router.ts" << 'ROUTER_EOF'
import { useEffect, useState } from "react";

export type Route =
  | { page: "home" }
  | { page: "services" }
  | { page: "studio" }
  | { page: "settings" }
  | { page: "case-study"; id: string }
  | { page: "not-found" };

// Module-level pending scroll — set before navigating home
let _pendingScroll: string | null = null;

export function consumePendingScroll(): string | null {
  const s = _pendingScroll;
  _pendingScroll = null;
  return s;
}

function parseHash(hash: string): Route {
  if (!hash || hash === "#" || hash === "#/" || !hash.startsWith("#/")) {
    return { page: "home" };
  }
  const path = hash.slice(2);
  if (path === "services")         return { page: "services" };
  if (path === "studio")           return { page: "studio" };
  if (path === "settings")         return { page: "settings" };
  if (path.startsWith("work/"))    return { page: "case-study", id: path.slice(5) };
  return { page: "not-found" };
}

export function useRouter(): Route {
  const [route, setRoute] = useState<Route>(() => parseHash(window.location.hash));
  useEffect(() => {
    const handler = () => setRoute(parseHash(window.location.hash));
    window.addEventListener("hashchange", handler);
    return () => window.removeEventListener("hashchange", handler);
  }, []);
  return route;
}

export function navigatePage(path: string) {
  window.location.hash = `#/${path}`;
  window.scrollTo({ top: 0 });
}

export function navigateSection(sectionId: string) {
  _pendingScroll = sectionId;
  if (parseHash(window.location.hash).page !== "home") {
    window.location.hash = "#";
    window.scrollTo({ top: 0 });
  } else {
    setTimeout(() => {
      document.getElementById(sectionId)?.scrollIntoView({ behavior: "smooth" });
    }, 60);
    _pendingScroll = null;
  }
}
ROUTER_EOF

# =============================================================================
# FILE 2 — src/components/Navigation.tsx
# =============================================================================
write_file "$ROOT/src/components/Navigation.tsx" << 'NAV_EOF'
/**
 * Navigation — v4.0
 *
 * Top bar:  [hamburger]  GENISYS  [music-icon]
 *
 * Hamburger opens a full left-drawer containing:
 *   • Nav links (WORK / SERVICES / STUDIO / PROCESS / FAQ / SETTINGS)
 *   • Live availability badge
 *   • Quick-action buttons (Start a Project, Copy Email)
 *   • Social links
 *   • Build version footer
 *
 * SETTINGS navigates to the dedicated /settings page.
 */
import { useEffect, useRef, useState } from "react";
import { AnimatePresence, motion }     from "framer-motion";
import { Menu, X, Music2, Copy, Check, Zap } from "lucide-react";
import { useScramble }                       from "@/hooks/useScramble";
import { navigatePage, navigateSection, type Route } from "@/lib/router";
import { SOCIAL, STUDIO }                    from "@/data/siteConfig";
import SocialIcon                            from "@/components/SocialIcon";

interface Props {
  route:          Route;
  musicPlaying?:  boolean;
  onMusicToggle?: () => void;
}

const PAGE_LINKS = [
  { label: "WORK",     action: () => navigateSection("work"),    page: null,       section: "work"    },
  { label: "SERVICES", action: () => navigatePage("services"),   page: "services", section: null      },
  { label: "STUDIO",   action: () => navigatePage("studio"),     page: "studio",   section: null      },
  { label: "PROCESS",  action: () => navigateSection("process"), page: null,       section: "process" },
  { label: "FAQ",      action: () => navigateSection("faq"),     page: null,       section: "faq"     },
  { label: "SETTINGS", action: () => navigatePage("settings"),   page: "settings", section: null      },
] as const;

export default function Navigation({ route, musicPlaying, onMusicToggle }: Props) {
  const brand                      = useScramble("GENISYS", 900);
  const [open,        setOpen]     = useState(false);
  const [activeSection, setActive] = useState("");
  const [copied,      setCopied]   = useState(false);
  const eqDelays = [0, 0.18, 0.36, 0.12];

  // Scroll-spy — keep last active section highlighted
  useEffect(() => {
    if (route.page !== "home") return;
    if (typeof IntersectionObserver === "undefined") return;
    const obs = new IntersectionObserver(
      entries => { entries.forEach(e => { if (e.isIntersecting) setActive(e.target.id); }); },
      { rootMargin: "-15% 0px -55% 0px", threshold: 0 },
    );
    ["work", "about", "process", "faq"].forEach(id => {
      const el = document.getElementById(id);
      if (el) obs.observe(el);
    });
    return () => obs.disconnect();
  }, [route.page]);

  // Lock scroll when drawer open
  useEffect(() => {
    if (!open) return;
    const sw = window.innerWidth - document.documentElement.clientWidth;
    document.body.style.overflow     = "hidden";
    document.body.style.paddingRight = `${sw}px`;
    return () => {
      document.body.style.overflow     = "";
      document.body.style.paddingRight = "";
    };
  }, [open]);

  useEffect(() => { setOpen(false); }, [route]);

  const isActive = (l: typeof PAGE_LINKS[number]) => {
    if (l.page    && route.page === l.page)                                return true;
    if (l.section && route.page === "home" && activeSection === l.section) return true;
    return false;
  };

  const copyEmail = async () => {
    try {
      await navigator.clipboard.writeText(STUDIO.email);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch { /**/ }
  };

  return (
    <>
      {/* ── Top bar ─────────────────────────────────────────── */}
      <header
        className="fixed top-0 left-0 right-0 z-[70] flex items-center justify-between px-3"
        style={{
          height:               "56px",
          background:           "rgba(0,0,0,0.78)",
          backdropFilter:       "blur(22px)",
          WebkitBackdropFilter: "blur(22px)",
          borderBottom:         "1px solid hsl(var(--gold)/0.1)",
        }}
      >
        <button
          onClick={() => setOpen(true)}
          aria-label="Open menu"
          aria-expanded={open}
          className="grid place-items-center w-10 h-10 rounded-xl transition-colors hover:bg-white/[0.06] text-cream/65 hover:text-gold"
        >
          <Menu className="w-5 h-5" />
        </button>

        <button
          onClick={() => navigateSection("top")}
          className="font-display font-black text-base gold-text tracking-tight select-none"
        >
          {brand}
        </button>

        <button
          onClick={onMusicToggle}
          aria-label={musicPlaying ? "Music playing — open player" : "Open music player"}
          className="grid place-items-center w-10 h-10 rounded-xl transition-colors hover:bg-white/[0.06]"
        >
          {musicPlaying ? (
            <span className="flex items-end gap-[2.5px] h-4" aria-hidden>
              {eqDelays.map((delay, i) => (
                <span
                  key={i}
                  className="eq-bar w-[2.5px] rounded-sm"
                  style={{
                    height: "100%", background: "hsl(var(--gold))",
                    animationDelay: `${delay}s`, transformOrigin: "bottom",
                    boxShadow: "0 0 5px hsl(var(--gold)/0.7)",
                  }}
                />
              ))}
            </span>
          ) : (
            <Music2 className="w-4 h-4 text-cream/50 hover:text-gold transition-colors" />
          )}
        </button>
      </header>

      <div style={{ height: "56px" }} aria-hidden />

      {/* ── Drawer ──────────────────────────────────────────── */}
      <AnimatePresence>
        {open && (
          <>
            <motion.div
              key="backdrop"
              initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
              transition={{ duration: 0.28 }}
              className="fixed inset-0 z-[148]"
              style={{ background: "rgba(0,0,0,0.65)", backdropFilter: "blur(4px)", WebkitBackdropFilter: "blur(4px)" }}
              onClick={() => setOpen(false)}
            />

            <motion.div
              key="drawer"
              initial={{ x: "-100%" }} animate={{ x: 0 }} exit={{ x: "-100%" }}
              transition={{ duration: 0.38, ease: [0.7, 0, 0.3, 1] }}
              className="fixed top-0 left-0 bottom-0 z-[149] flex flex-col overflow-hidden"
              style={{
                width:                "min(320px, 88vw)",
                background:           "rgba(5,5,5,0.98)",
                backdropFilter:       "blur(40px)",
                WebkitBackdropFilter: "blur(40px)",
                borderRight:          "1px solid hsl(var(--gold)/0.14)",
              }}
            >
              {/* Drawer header */}
              <div className="flex items-center justify-between px-5 py-4 flex-none"
                style={{ borderBottom: "1px solid hsl(0 0% 100% / 0.055)" }}>
                <div className="flex items-center gap-2.5">
                  <span className="font-display font-black text-sm gold-text tracking-tight">GENISYS</span>
                  {STUDIO.availability.accepting && (
                    <span
                      className="flex items-center gap-1.5 px-2 py-0.5 rounded-full font-mono text-[8px] tracking-[0.2em]"
                      style={{ background: "hsl(142 70% 45% / 0.12)", border: "1px solid hsl(142 70% 45% / 0.3)", color: "hsl(142 70% 55%)" }}
                    >
                      <span className="w-1.5 h-1.5 rounded-full bg-green-400 animate-pulse" />
                      OPEN
                    </span>
                  )}
                </div>
                <button
                  onClick={() => setOpen(false)}
                  aria-label="Close menu"
                  className="grid place-items-center w-8 h-8 rounded-xl text-cream/35 hover:text-gold transition-colors"
                  style={{ background: "hsl(0 0% 100% / 0.04)", border: "1px solid hsl(0 0% 100% / 0.07)" }}
                >
                  <X className="w-3.5 h-3.5" />
                </button>
              </div>

              {/* Scrollable body */}
              <div className="flex-1 overflow-y-auto overscroll-contain" style={{ scrollbarWidth: "none" }}>

                {/* ── Nav links ──────────────────────────── */}
                <div className="px-3 pt-4 pb-2">
                  <p className="font-mono text-[8px] tracking-[0.45em] text-gold/40 px-2 mb-2">NAVIGATE</p>
                  <nav className="flex flex-col gap-0.5">
                    {PAGE_LINKS.map((l, i) => (
                      <motion.button
                        key={l.label}
                        onClick={() => { l.action(); setOpen(false); }}
                        initial={{ opacity: 0, x: -18 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ duration: 0.28, delay: 0.05 + i * 0.06, ease: [0.7, 0, 0.3, 1] }}
                        className={
                          "w-full flex items-center gap-3 px-4 py-3 rounded-xl text-left transition-colors " +
                          (isActive(l) ? "bg-gold/[0.09]" : "hover:bg-white/[0.04]")
                        }
                      >
                        {isActive(l) && (
                          <span className="w-[3px] h-4 rounded-full flex-none" style={{ background: "hsl(var(--gold))" }} />
                        )}
                        <span className={"font-mono text-[11px] tracking-[0.32em] " + (isActive(l) ? "text-gold" : "text-cream/65")}>
                          {l.label}
                        </span>
                      </motion.button>
                    ))}
                  </nav>
                </div>

                <div className="mx-5 my-3" style={{ height: "1px", background: "hsl(0 0% 100% / 0.055)" }} />

                {/* ── Quick actions ──────────────────────── */}
                <div className="px-3 pb-2">
                  <p className="font-mono text-[8px] tracking-[0.45em] text-gold/40 px-2 mb-2">QUICK ACTIONS</p>

                  <motion.button
                    initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.28, delay: 0.44 }}
                    onClick={() => { setOpen(false); window.dispatchEvent(new Event("open-contact")); }}
                    className="w-full flex items-center gap-3 px-4 py-3 rounded-xl text-left transition-colors hover:bg-gold/[0.07] mb-1"
                    style={{ border: "1px solid hsl(var(--gold)/0.2)", background: "hsl(var(--gold)/0.04)" }}
                  >
                    <Zap className="w-4 h-4 text-gold flex-none" />
                    <div>
                      <p className="font-mono text-[10px] tracking-[0.25em] text-gold">START A PROJECT</p>
                      {STUDIO.availability.accepting && (
                        <p className="font-mono text-[8px] text-cream/30 mt-0.5">
                          Next slot: {STUDIO.availability.nextSlot}
                        </p>
                      )}
                    </div>
                  </motion.button>

                  <motion.button
                    initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.28, delay: 0.50 }}
                    onClick={copyEmail}
                    className="w-full flex items-center gap-3 px-4 py-3 rounded-xl text-left transition-colors hover:bg-white/[0.04]"
                  >
                    {copied
                      ? <Check className="w-4 h-4 text-green-400 flex-none" />
                      : <Copy  className="w-4 h-4 text-cream/35 flex-none" />
                    }
                    <div>
                      <p className={"font-mono text-[10px] tracking-[0.2em] " + (copied ? "text-green-400" : "text-cream/60")}>
                        {copied ? "COPIED!" : "COPY EMAIL"}
                      </p>
                      <p className="font-mono text-[8px] text-cream/25 mt-0.5 truncate">{STUDIO.email}</p>
                    </div>
                  </motion.button>
                </div>

                <div className="mx-5 my-3" style={{ height: "1px", background: "hsl(0 0% 100% / 0.055)" }} />

                {/* ── Socials ────────────────────────────── */}
                <div className="px-5 pb-4">
                  <p className="font-mono text-[8px] tracking-[0.45em] text-gold/40 mb-3">FOLLOW</p>
                  <div className="flex flex-wrap gap-2">
                    {Object.entries(SOCIAL).map(([platform, url]) => (
                      <a
                        key={platform}
                        href={url} target="_blank" rel="noopener noreferrer"
                        aria-label={platform}
                        className="w-9 h-9 grid place-items-center rounded-xl transition-all hover:scale-110"
                        style={{ background: "hsl(var(--gold)/0.07)", border: "1px solid hsl(var(--gold)/0.18)", color: "hsl(var(--gold)/0.65)" }}
                      >
                        <SocialIcon platform={platform} size={14} />
                      </a>
                    ))}
                  </div>
                </div>
              </div>

              {/* Drawer footer */}
              <div
                className="flex-none px-5 py-3 flex items-center justify-between"
                style={{ borderTop: "1px solid hsl(0 0% 100% / 0.055)" }}
              >
                <p className="font-mono text-[7px] tracking-[0.3em] text-cream/15">
                  GENISYS GRAPHICS © {new Date().getFullYear()}
                </p>
                <p className="font-mono text-[7px] tracking-[0.2em] text-cream/12">v4.0.0</p>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </>
  );
}
NAV_EOF

# =============================================================================
# FILE 3 — src/components/ContactModal.tsx
# =============================================================================
write_file "$ROOT/src/components/ContactModal.tsx" << 'CONTACT_EOF'
import { useState, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { X, Send, CheckCircle, AlertCircle } from "lucide-react";

interface Props { open: boolean; onClose: () => void; }
type Status = "idle" | "sending" | "sent" | "error";

export default function ContactModal({ open, onClose }: Props) {
  const [status, setStatus] = useState<Status>("idle");
  const formRef = useRef<HTMLFormElement>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formRef.current || status === "sending") return;

    const key = import.meta.env.VITE_WEB3FORMS_KEY;
    if (!key) {
      console.error("VITE_WEB3FORMS_KEY is not set in your .env file.");
      setStatus("error");
      return;
    }

    setStatus("sending");
    try {
      const data = new FormData(formRef.current);
      const res  = await fetch("https://api.web3forms.com/submit", { method: "POST", body: data });
      const json = await res.json();
      if (json.success) {
        setStatus("sent");
        setTimeout(() => { setStatus("idle"); onClose(); formRef.current?.reset(); }, 5000);
      } else {
        setStatus("error");
      }
    } catch { setStatus("error"); }
  };

  const handleClose = () => {
    if (status === "sending") return;
    setStatus("idle");
    onClose();
  };

  return (
    <AnimatePresence>
      {open && (
        <motion.div
          initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
          transition={{ duration: 0.3 }}
          className="fixed inset-0 z-[200] grid place-items-center p-4 sm:p-8"
          style={{ background: "rgba(0,0,0,0.88)", backdropFilter: "blur(20px)", WebkitBackdropFilter: "blur(20px)" }}
          onClick={handleClose}
        >
          <motion.div
            initial={{ scale: 0.95, y: 20 }} animate={{ scale: 1, y: 0 }} exit={{ scale: 0.97, y: 10 }}
            transition={{ duration: 0.4, ease: [0.7, 0, 0.3, 1] }}
            className="relative w-full max-w-lg glass-strong specular grain rounded-2xl overflow-hidden"
            onClick={e => e.stopPropagation()}
          >
            {/* Header */}
            <div className="flex items-center justify-between p-6 pb-0">
              <div>
                <div className="font-mono text-[9px] tracking-[0.4em] text-gold/70 mb-1">NEW ENQUIRY</div>
                <h2 className="font-display font-black text-2xl gold-text">Start a Project</h2>
              </div>
              <button
                onClick={handleClose}
                disabled={status === "sending"}
                className="grid place-items-center w-9 h-9 rounded-full glass transition-opacity disabled:opacity-30"
                style={{ border: "1px solid hsl(var(--gold)/0.25)" }}
              >
                <X className="w-4 h-4 text-gold" />
              </button>
            </div>

            {/* Success state */}
            {status === "sent" && (
              <motion.div
                initial={{ opacity: 0, scale: 0.9 }} animate={{ opacity: 1, scale: 1 }}
                className="flex flex-col items-center gap-4 px-6 py-12 text-center"
              >
                <CheckCircle className="w-14 h-14 text-emerald-400" />
                <div className="font-display font-black text-2xl gold-text">Message Sent</div>
                <p className="text-cream/65 text-sm leading-relaxed max-w-sm">
                  We'll review your brief and get back to you within 24 hours.
                  Expect something cinematic.
                </p>
                <button
                  onClick={handleClose}
                  className="mt-2 px-6 py-2.5 rounded-full glass gold-border-glow font-mono text-[10px] tracking-[0.3em] text-gold hover:text-cream transition-colors"
                >
                  CLOSE
                </button>
                <p className="font-mono text-[9px] tracking-[0.2em] text-cream/30">
                  Auto-closing in 5 seconds
                </p>
              </motion.div>
            )}

            {/* Error state */}
            {status === "error" && (
              <div className="flex flex-col items-center gap-3 px-6 py-8 text-center">
                <AlertCircle className="w-10 h-10 text-red-400" />
                <p className="text-cream/70 text-sm">
                  Message could not be delivered right now.
                </p>
                {import.meta.env.VITE_CONTACT_EMAIL && (
                  <a
                    href={`mailto:${import.meta.env.VITE_CONTACT_EMAIL}?subject=Project%20Enquiry`}
                    className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full glass-strong gold-border-glow font-mono text-[10px] tracking-[0.3em] text-gold hover:text-cream transition-colors"
                  >
                    EMAIL US DIRECTLY →
                  </a>
                )}
                <button
                  onClick={() => setStatus("idle")}
                  className="font-mono text-[10px] tracking-[0.3em] text-cream/40 hover:text-gold transition-colors mt-1"
                >
                  TRY AGAIN
                </button>
              </div>
            )}

            {/* Form */}
            {(status === "idle" || status === "sending") && (
              <form ref={formRef} onSubmit={handleSubmit} className="p-6 pt-5 space-y-4">
                <input type="hidden" name="access_key" value={import.meta.env.VITE_WEB3FORMS_KEY ?? ""} />
                <input type="hidden" name="subject" value="New Project Enquiry — Genisys Graphics" />
                <input type="checkbox" name="botcheck" className="hidden" style={{ display: "none" }} />

                {[
                  { name: "name",    label: "Name",           type: "text",  placeholder: "Your full name" },
                  { name: "email",   label: "Email",          type: "email", placeholder: "your@email.com" },
                  { name: "company", label: "Brand / Company",type: "text",  placeholder: "Optional" },
                ].map(f => (
                  <div key={f.name}>
                    <label className="block font-mono text-[9px] tracking-[0.35em] text-gold/70 mb-1.5">
                      {f.label.toUpperCase()}
                    </label>
                    <input
                      name={f.name} type={f.type} placeholder={f.placeholder}
                      required={f.name !== "company"}
                      className="w-full px-4 py-2.5 rounded-xl text-cream text-sm placeholder:text-cream/30 focus:outline-none focus:ring-1 focus:ring-gold/40"
                      style={{ background: "hsl(0 0% 8%/0.8)", border: "1px solid hsl(var(--gold)/0.2)" }}
                    />
                  </div>
                ))}

                <div>
                  <label className="block font-mono text-[9px] tracking-[0.35em] text-gold/70 mb-1.5">
                    BRIEF
                  </label>
                  <textarea
                    name="message" rows={4} required
                    placeholder="Tell us about your project, timeline, and budget range…"
                    className="w-full px-4 py-2.5 rounded-xl text-cream text-sm placeholder:text-cream/30 focus:outline-none focus:ring-1 focus:ring-gold/40 resize-none"
                    style={{ background: "hsl(0 0% 8%/0.8)", border: "1px solid hsl(var(--gold)/0.2)" }}
                  />
                </div>

                <button
                  type="submit" disabled={status === "sending"}
                  className="w-full py-3 rounded-xl font-mono text-xs tracking-[0.35em] transition-all disabled:opacity-60 flex items-center justify-center gap-2"
                  style={{ background: "hsl(var(--gold))", color: "#000", fontWeight: 700 }}
                >
                  {status === "sending" ? (
                    <><span className="w-3.5 h-3.5 border-2 border-black/30 border-t-black rounded-full animate-spin" /> SENDING…</>
                  ) : (
                    <><Send className="w-3.5 h-3.5" /> SEND BRIEF</>
                  )}
                </button>
              </form>
            )}
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
CONTACT_EOF

# =============================================================================
# FILE 4 — src/pages/SettingsPage.tsx  (NEW FILE)
# =============================================================================
write_file "$ROOT/src/pages/SettingsPage.tsx" << 'SETTINGS_EOF'
/**
 * SettingsPage — v4.0
 * Dedicated settings page accessible from the hamburger nav SETTINGS link.
 */
import { motion }               from "framer-motion";
import { ArrowLeft, RotateCcw } from "lucide-react";
import { useScramble }          from "@/hooks/useScramble";
import { useMagnetic }          from "@/hooks/useMagnetic";
import { navigateSection }      from "@/lib/router";
import { useSettings, type Settings } from "@/contexts/SettingsContext";
import Footer                   from "@/components/Footer";

const SETTING_META: { key: keyof Settings; label: string; sub: string; group: string }[] = [
  { key: "aurora",         label: "Aurora Background",  sub: "Colour-shift ambient glow",        group: "VISUAL FX"    },
  { key: "particles",      label: "Ember Particles",    sub: "Floating gold sparks",              group: "VISUAL FX"    },
  { key: "goldDust",       label: "Gold Dust Trail",    sub: "Cursor sparkle trail (high-end)",   group: "VISUAL FX"    },
  { key: "letterbox",      label: "Letterbox Bars",     sub: "Cinematic black bars top & bottom", group: "VISUAL FX"    },
  { key: "scrollVignette", label: "Scroll Vignette",    sub: "Edge fade darkens on scroll",       group: "VISUAL FX"    },
  { key: "magneticCursor", label: "Magnetic Cursor",    sub: "Cursor blob / hover pull effect",   group: "INTERACTIONS" },
  { key: "clickBurst",     label: "Click Burst",        sub: "Tap sparkle burst on every click",  group: "INTERACTIONS" },
  { key: "smoothScroll",   label: "Smooth Scroll",      sub: "Lenis inertia scroll feel",         group: "INTERACTIONS" },
  { key: "commandPalette", label: "Command Palette",    sub: "Cmd + K quick navigation",          group: "INTERACTIONS" },
  { key: "scrollProgress", label: "Progress Bar",       sub: "Top-bar scroll progress indicator", group: "UI"           },
  { key: "reducedMotion",  label: "Reduce All Motion",  sub: "Disables every animation globally", group: "ACCESSIBILITY"},
];

const GROUPS = ["VISUAL FX", "INTERACTIONS", "UI", "ACCESSIBILITY"] as const;

function BackBtn() {
  const ref = useMagnetic<HTMLButtonElement>(0.3);
  return (
    <button
      ref={ref}
      onClick={() => navigateSection("top")}
      className="inline-flex items-center gap-2 font-mono text-[10px] tracking-[0.3em] text-gold/70 hover:text-gold transition-colors mb-10"
    >
      <ArrowLeft className="w-3 h-3" /> BACK TO HOME
    </button>
  );
}

interface Props { onContact: () => void; }

export default function SettingsPage({ onContact }: Props) {
  const heading = useScramble("SETTINGS", 1100);
  const { settings, toggle, resetAll } = useSettings();

  return (
    <>
      <section className="relative px-4 sm:px-8 pt-32 pb-20 min-h-screen">
        <div
          aria-hidden
          className="pointer-events-none absolute inset-0"
          style={{ background: "radial-gradient(ellipse 50% 40% at 70% 10%, hsl(44 65% 35% / 0.08), transparent)" }}
        />
        <div className="max-w-2xl mx-auto">
          <BackBtn />
          <div className="font-mono text-[10px] tracking-[0.5em] text-gold/70 mb-2">EXPERIENCE CONTROLS</div>
          <h1 className="font-display font-black text-5xl sm:text-7xl gold-text chromatic mb-4">{heading}</h1>
          <p className="text-cream/50 text-sm leading-relaxed mb-12 max-w-md">
            Tune every visual and interactive effect to match your device and preferences.
            Changes apply instantly and are saved to this browser.
          </p>

          <div className="space-y-8">
            {GROUPS.map((group) => {
              const items = SETTING_META.filter(m => m.group === group);
              return (
                <motion.div
                  key={group}
                  initial={{ opacity: 0, y: 16 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.5, delay: GROUPS.indexOf(group) * 0.07, ease: [0.7, 0, 0.3, 1] }}
                >
                  <div className="font-mono text-[9px] tracking-[0.45em] text-gold/45 mb-3">{group}</div>
                  <div className="space-y-1">
                    {items.map(({ key, label, sub }) => (
                      <button
                        key={key}
                        onClick={() => toggle(key)}
                        className="w-full flex items-center gap-4 px-5 py-4 rounded-2xl text-left transition-colors hover:bg-white/[0.03]"
                        style={{
                          background: settings[key] ? "hsl(var(--gold)/0.05)" : "hsl(0 0% 100% / 0.02)",
                          border:     settings[key] ? "1px solid hsl(var(--gold)/0.2)" : "1px solid hsl(0 0% 100% / 0.06)",
                        }}
                      >
                        {/* Toggle pill */}
                        <div
                          className="flex-none relative w-11 h-6 rounded-full transition-all duration-300"
                          style={{
                            background: settings[key] ? "hsl(var(--gold)/0.9)" : "hsl(0 0% 100% / 0.08)",
                            border:     settings[key] ? "1px solid hsl(var(--gold))" : "1px solid hsl(0 0% 100% / 0.12)",
                          }}
                        >
                          <span
                            className="absolute top-[3px] w-[18px] h-[18px] rounded-full transition-all duration-300"
                            style={{
                              left:       settings[key] ? "calc(100% - 21px)" : "3px",
                              background: settings[key] ? "#000" : "hsl(0 0% 100% / 0.35)",
                              boxShadow:  settings[key] ? "0 0 8px hsl(var(--gold)/0.5)" : "none",
                            }}
                          />
                        </div>
                        <div className="flex-1 min-w-0">
                          <p className={"font-mono text-[11px] tracking-[0.2em] " + (settings[key] ? "text-cream/90" : "text-cream/40")}>
                            {label}
                          </p>
                          <p className="font-mono text-[9px] text-cream/25 leading-snug mt-0.5">{sub}</p>
                        </div>
                        <span
                          className="flex-none font-mono text-[8px] tracking-[0.2em] px-2 py-1 rounded-full"
                          style={{
                            background: settings[key] ? "hsl(var(--gold)/0.12)" : "hsl(0 0% 100% / 0.04)",
                            color:      settings[key] ? "hsl(var(--gold))"       : "hsl(0 0% 100% / 0.2)",
                            border:     settings[key] ? "1px solid hsl(var(--gold)/0.3)" : "1px solid hsl(0 0% 100% / 0.06)",
                          }}
                        >
                          {settings[key] ? "ON" : "OFF"}
                        </span>
                      </button>
                    ))}
                  </div>
                </motion.div>
              );
            })}
          </div>

          <motion.div
            initial={{ opacity: 0 }} animate={{ opacity: 1 }}
            transition={{ duration: 0.4, delay: 0.5 }}
            className="mt-10 pt-8 border-t border-white/[0.06] flex items-center justify-between"
          >
            <p className="font-mono text-[9px] tracking-[0.2em] text-cream/30">
              Settings are saved per-browser automatically.
            </p>
            <button
              onClick={resetAll}
              className="flex items-center gap-2 px-5 py-2.5 rounded-full font-mono text-[9px] tracking-[0.25em] text-cream/40 hover:text-gold transition-colors"
              style={{ border: "1px solid hsl(0 0% 100% / 0.08)" }}
            >
              <RotateCcw className="w-3 h-3" />
              RESET DEFAULTS
            </button>
          </motion.div>
        </div>
      </section>
      <Footer onContact={onContact} />
    </>
  );
}
SETTINGS_EOF

# =============================================================================
# FILE 5 — src/pages/ServicesPage.tsx  (patched — min-h-screen + no fake email)
# =============================================================================
write_file "$ROOT/src/pages/ServicesPage.tsx" << 'SERVICES_EOF'
import { motion } from "framer-motion";
import { Check, X, ArrowLeft } from "lucide-react";
import { useScramble } from "@/hooks/useScramble";
import { useMagnetic } from "@/hooks/useMagnetic";
import { PRICING, STUDIO } from "@/data/siteConfig";
import { navigateSection } from "@/lib/router";
import FAQ from "@/components/FAQ";
import Footer from "@/components/Footer";

function BackBtn() {
  const ref = useMagnetic<HTMLButtonElement>(0.3);
  return (
    <button
      ref={ref}
      onClick={() => navigateSection("top")}
      className="inline-flex items-center gap-2 font-mono text-[10px] tracking-[0.3em] text-gold/70 hover:text-gold transition-colors mb-10"
    >
      <ArrowLeft className="w-3 h-3" /> BACK TO HOME
    </button>
  );
}

interface Props { onContact: () => void; }

export default function ServicesPage({ onContact }: Props) {
  const heading = useScramble("SERVICES", 1100);

  return (
    <>
      <section className="relative px-4 sm:px-8 pt-32 pb-20 min-h-screen">
        <div
          aria-hidden
          className="pointer-events-none absolute inset-0"
          style={{ background: "radial-gradient(ellipse 60% 50% at 50% 0%, hsl(44 65% 35% / 0.10), transparent)" }}
        />
        <div className="max-w-6xl mx-auto">
          <BackBtn />
          <div className="font-mono text-[10px] tracking-[0.5em] text-gold/70 mb-2">
            INVESTMENT TIERS
          </div>
          <h1 className="font-display font-black text-5xl sm:text-7xl gold-text chromatic mb-4">
            {heading}
          </h1>
          <p className="max-w-xl text-cream/65 text-sm sm:text-base leading-relaxed mb-4">
            Every engagement is fixed-price, clearly scoped, and built around one goal:
            a visual system that outlasts trends and outlasts competitors.
          </p>

          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full glass mb-16"
            style={{ border: "1px solid hsl(var(--gold)/0.3)" }}>
            <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
            <span className="font-mono text-[10px] tracking-[0.3em] text-cream/80">
              {STUDIO.availability.accepting
                ? `NOW BOOKING · NEXT SLOT ${STUDIO.availability.nextSlot.toUpperCase()}`
                : "FULLY BOOKED · JOIN WAITLIST"}
            </span>
          </div>

          <div className="grid sm:grid-cols-3 gap-5">
            {PRICING.map((tier, i) => (
              <motion.div
                key={tier.id}
                initial={{ opacity: 0, y: 28 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: i * 0.1, ease: [0.7, 0, 0.3, 1] }}
                className="relative flex flex-col rounded-2xl overflow-hidden"
                style={{
                  background: tier.highlight
                    ? "linear-gradient(145deg, hsl(0 0% 8%/0.98), hsl(0 0% 5%/0.98))"
                    : "linear-gradient(145deg, hsl(0 0% 6%/0.96), hsl(0 0% 3%/0.96))",
                  border: tier.highlight
                    ? "1px solid hsl(var(--gold)/0.55)"
                    : "1px solid hsl(0 0% 100%/0.07)",
                  boxShadow: tier.highlight
                    ? "0 0 40px hsl(var(--gold)/0.15), inset 0 1px 0 hsl(0 0% 100%/0.08)"
                    : "0 4px 24px hsl(0 0%  0%/0.6)",
                }}
              >
                {tier.highlight && (
                  <div className="absolute top-0 left-0 right-0 h-[2px]"
                    style={{ background: "linear-gradient(90deg, transparent, hsl(var(--gold)), transparent)" }} />
                )}
                {tier.highlight && (
                  <div className="absolute top-4 right-4 font-mono text-[9px] tracking-[0.3em] px-2 py-1 rounded-full"
                    style={{ background: "hsl(var(--gold)/0.15)", color: "hsl(var(--gold))", border: "1px solid hsl(var(--gold)/0.4)" }}>
                    MOST POPULAR
                  </div>
                )}
                <div className="p-6 pb-4">
                  <div className="font-mono text-[10px] tracking-[0.4em] text-gold/80 mb-3">{tier.tier}</div>
                  <div className="font-display font-black text-4xl gold-text mb-1">{tier.price}</div>
                  <div className="font-mono text-[10px] tracking-[0.2em] text-cream/50 mb-4">{tier.period.toUpperCase()}</div>
                  <p className="text-cream/60 text-xs leading-relaxed mb-1 italic">{tier.tagline}</p>
                  <p className="text-cream/70 text-sm leading-relaxed">{tier.description}</p>
                </div>

                <div className="px-6 pb-4 flex-1">
                  <div className="border-t border-white/[0.06] pt-4 space-y-2">
                    {tier.features.map(f => (
                      <div key={f} className="flex items-start gap-2.5 text-sm text-cream/75">
                        <Check className="w-3.5 h-3.5 text-gold mt-0.5 flex-none" />
                        <span>{f}</span>
                      </div>
                    ))}
                    {tier.notIncluded.map(f => (
                      <div key={f} className="flex items-start gap-2.5 text-sm text-cream/30">
                        <X className="w-3.5 h-3.5 mt-0.5 flex-none" />
                        <span>{f}</span>
                      </div>
                    ))}
                  </div>
                </div>

                <div className="p-6 pt-4">
                  <button
                    onClick={onContact}
                    className="w-full py-3.5 rounded-xl font-mono text-xs tracking-[0.3em] transition-all duration-300"
                    style={
                      tier.highlight
                        ? { background: "hsl(var(--gold))", color: "#000", fontWeight: 700 }
                        : { background: "transparent", border: "1px solid hsl(var(--gold)/0.4)", color: "hsl(var(--gold))" }
                    }
                  >
                    {tier.cta}
                  </button>
                </div>
              </motion.div>
            ))}
          </div>

          <p className="mt-8 text-center font-mono text-[10px] tracking-[0.2em] text-cream/35">
            ALL PRICES IN USD · PAYMENT VIA STRIPE, WISE, OR CRYPTO
            {import.meta.env.VITE_CONTACT_EMAIL && (
              <> ·{" "}
                <a
                  href={`mailto:${import.meta.env.VITE_CONTACT_EMAIL}`}
                  className="text-gold/50 hover:text-gold transition-colors"
                >
                  {(import.meta.env.VITE_CONTACT_EMAIL as string).toUpperCase()}
                </a>
              </>
            )}
          </p>
        </div>
      </section>

      <FAQ />
      <Footer onContact={onContact} />
    </>
  );
}
SERVICES_EOF

# =============================================================================
# FILE 6 — src/pages/StudioPage.tsx  (patched — min-h-screen added)
# =============================================================================
# Only patch the section opening tag — leave rest untouched
STUDIO_FILE="$ROOT/src/pages/StudioPage.tsx"
if grep -q 'className="relative px-4 sm:px-8 pt-32 pb-20"' "$STUDIO_FILE"; then
  sed -i 's/className="relative px-4 sm:px-8 pt-32 pb-20"/className="relative px-4 sm:px-8 pt-32 pb-20 min-h-screen"/' "$STUDIO_FILE"
  echo "  ✔  $STUDIO_FILE  (section tag patched)"
else
  echo "  ⚠  StudioPage section tag not found — check manually if min-h-screen is already present."
fi

# =============================================================================
# FILE 7 — src/App.tsx  (add SettingsPage import + case)
# =============================================================================
APP_FILE="$ROOT/src/App.tsx"

# Add import if missing
if ! grep -q "SettingsPage" "$APP_FILE"; then
  sed -i "s|import NotFoundPage.*from \"@/pages/NotFoundPage\";|import NotFoundPage               from \"@/pages/NotFoundPage\";\nimport SettingsPage               from \"@/pages/SettingsPage\";|" "$APP_FILE"
  echo "  ✔  $APP_FILE  (SettingsPage import added)"
fi

# Add route case if missing
if ! grep -q 'case "settings"' "$APP_FILE"; then
  sed -i "s|case \"case-study\": return <CaseStudyPage|case \"settings\":   return <SettingsPage onContact={() => setOpen(true)} />;\n      case \"case-study\": return <CaseStudyPage|" "$APP_FILE"
  echo "  ✔  $APP_FILE  (settings route case added)"
fi

# =============================================================================
echo ""
echo "  ╔══════════════════════════════════════════════════════════════════╗"
echo "  ║  All patches applied.                                           ║"
echo "  ║                                                                 ║"
echo "  ║  Reminder — add these to your .env file if not already done:   ║"
echo "  ║    VITE_WEB3FORMS_KEY=your_key_here                            ║"
echo "  ║    VITE_CONTACT_EMAIL=your_real@email.com                      ║"
echo "  ║                                                                 ║"
echo "  ║  Then:  npm run dev                                             ║"
echo "  ╚══════════════════════════════════════════════════════════════════╝"
echo ""
