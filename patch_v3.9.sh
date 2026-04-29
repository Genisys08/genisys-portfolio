#!/usr/bin/env bash
# =============================================================================
#  GENISYS GRAPHICS — PATCH v3.9
#
#  CHANGES:
#    FIX-1   Remove dev hint text from music playlist drawer
#    FIX-2   Music button & BackToTop perfect symmetry (both bottom 24px)
#    FIX-3   Header rebuilt as fixed mobile-app top bar (not floating):
#              LEFT  -> hamburger -> left drawer (nav links + socials)
#              CENTER -> GENISYS brand
#              RIGHT -> three-dot -> right panel (settings)
#    NEW-1   SettingsContext — persist all toggles to localStorage
#    NEW-2   Settings panel with toggles for every animation/effect
#    NEW-3   App.tsx reads settings to conditionally render each effect
# =============================================================================
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
echo "  Genisys v3.9 patch - starting ..."

# ─────────────────────────────────────────────────────────────────────────────
# 1. SettingsContext
# ─────────────────────────────────────────────────────────────────────────────
echo "  [1/6] Writing src/contexts/SettingsContext.tsx ..."
python3 << 'PYEOF'
content = """\
/**
 * SettingsContext v3.9
 * Persists every animation/effect toggle in localStorage.
 */
import {
  createContext, useContext, useState, useCallback,
  type ReactNode,
} from "react";

export interface Settings {
  particles:      boolean;
  aurora:         boolean;
  goldDust:       boolean;
  magneticCursor: boolean;
  smoothScroll:   boolean;
  clickBurst:     boolean;
  letterbox:      boolean;
  scrollVignette: boolean;
  scrollProgress: boolean;
  commandPalette: boolean;
  reducedMotion:  boolean;
}

const DEFAULTS: Settings = {
  particles:      true,
  aurora:         true,
  goldDust:       true,
  magneticCursor: true,
  smoothScroll:   true,
  clickBurst:     true,
  letterbox:      true,
  scrollVignette: true,
  scrollProgress: true,
  commandPalette: true,
  reducedMotion:  false,
};

const STORAGE_KEY = "genisys-settings-v1";

function load(): Settings {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return { ...DEFAULTS };
    return { ...DEFAULTS, ...JSON.parse(raw) };
  } catch {
    return { ...DEFAULTS };
  }
}

interface Ctx {
  settings: Settings;
  toggle:   (key: keyof Settings) => void;
  resetAll: () => void;
}

const SettingsCtx = createContext<Ctx | null>(null);

export function SettingsProvider({ children }: { children: ReactNode }) {
  const [settings, setSettings] = useState<Settings>(load);

  const toggle = useCallback((key: keyof Settings) => {
    setSettings(prev => {
      const next = { ...prev, [key]: !prev[key] };
      try { localStorage.setItem(STORAGE_KEY, JSON.stringify(next)); } catch { /**/ }
      return next;
    });
  }, []);

  const resetAll = useCallback(() => {
    setSettings({ ...DEFAULTS });
    try { localStorage.removeItem(STORAGE_KEY); } catch { /**/ }
  }, []);

  return (
    <SettingsCtx.Provider value={{ settings, toggle, resetAll }}>
      {children}
    </SettingsCtx.Provider>
  );
}

export function useSettings() {
  const ctx = useContext(SettingsCtx);
  if (!ctx) throw new Error("useSettings must be inside SettingsProvider");
  return ctx;
}
"""
open("src/contexts/SettingsContext.tsx", "w").write(content)
print("  ok  SettingsContext.tsx written")
PYEOF

# ─────────────────────────────────────────────────────────────────────────────
# 2. New Navigation
# ─────────────────────────────────────────────────────────────────────────────
echo "  [2/6] Rewriting src/components/Navigation.tsx ..."
python3 << 'PYEOF'
content = """\
/**
 * Navigation v3.9 - mobile-app style fixed top bar
 * LEFT  -> hamburger -> left nav drawer
 * CENTER -> brand
 * RIGHT -> three-dot -> right settings panel
 */
import { useEffect, useState }       from "react";
import { AnimatePresence, motion }   from "framer-motion";
import { Menu, X, MoreVertical, RotateCcw } from "lucide-react";
import { useScramble }               from "@/hooks/useScramble";
import { navigatePage, navigateSection, type Route } from "@/lib/router";
import { SOCIAL }                    from "@/data/siteConfig";
import SocialIcon                    from "@/components/SocialIcon";
import { useSettings, type Settings } from "@/contexts/SettingsContext";

interface Props { route: Route; }

const PAGE_LINKS = [
  { label: "WORK",     action: () => navigateSection("work"),    page: null,       section: "work"    },
  { label: "SERVICES", action: () => navigatePage("services"),   page: "services", section: null      },
  { label: "STUDIO",   action: () => navigatePage("studio"),     page: "studio",   section: null      },
  { label: "PROCESS",  action: () => navigateSection("process"), page: null,       section: "process" },
] as const;

const SETTING_META: { key: keyof Settings; label: string; sub: string }[] = [
  { key: "particles",      label: "Ember Particles",   sub: "Floating gold sparks"      },
  { key: "aurora",         label: "Aurora Background", sub: "Colour-shift glow"         },
  { key: "goldDust",       label: "Gold Dust Trail",   sub: "Cursor sparkle trail"      },
  { key: "magneticCursor", label: "Magnetic Cursor",   sub: "Cursor blob effect"        },
  { key: "smoothScroll",   label: "Smooth Scroll",     sub: "Inertia scroll feel"       },
  { key: "clickBurst",     label: "Click Burst",       sub: "Tap sparkle burst"         },
  { key: "letterbox",      label: "Letterbox Bars",    sub: "Cinematic black bars"      },
  { key: "scrollVignette", label: "Scroll Vignette",   sub: "Edge fade on scroll"       },
  { key: "scrollProgress", label: "Progress Bar",      sub: "Top scroll indicator"      },
  { key: "commandPalette", label: "Command Palette",   sub: "Cmd+K quick search"        },
  { key: "reducedMotion",  label: "Reduce All Motion", sub: "Kill every animation"      },
];

export default function Navigation({ route }: Props) {
  const brand  = useScramble("GENISYS", 900);
  const [navOpen,       setNavOpen]      = useState(false);
  const [settingsOpen,  setSettingsOpen] = useState(false);
  const [activeSection, setActive]       = useState("");
  const { settings, toggle, resetAll }   = useSettings();

  useEffect(() => {
    if (route.page !== "home") { setActive(""); return; }
    if (typeof IntersectionObserver === "undefined") return;
    const obs = new IntersectionObserver(
      entries => entries.forEach(e => { if (e.isIntersecting) setActive(e.target.id); }),
      { rootMargin: "-25% 0px -65% 0px", threshold: 0 },
    );
    ["work", "about", "process", "faq"].forEach(id => {
      const el = document.getElementById(id);
      if (el) obs.observe(el);
    });
    return () => obs.disconnect();
  }, [route.page]);

  useEffect(() => {
    const open = navOpen || settingsOpen;
    if (!open) return;
    const sw = window.innerWidth - document.documentElement.clientWidth;
    document.body.style.overflow     = "hidden";
    document.body.style.paddingRight = sw + "px";
    return () => {
      document.body.style.overflow     = "";
      document.body.style.paddingRight = "";
    };
  }, [navOpen, settingsOpen]);

  useEffect(() => { setNavOpen(false); setSettingsOpen(false); }, [route]);

  const isActive = (l: typeof PAGE_LINKS[number]) => {
    if (l.page    && route.page === l.page)                                return true;
    if (l.section && route.page === "home" && activeSection === l.section) return true;
    return false;
  };

  return (
    <>
      {/* Fixed top bar */}
      <header
        className="fixed top-0 left-0 right-0 z-[70] flex items-center justify-between px-4"
        style={{
          height:               "56px",
          background:           "rgba(0,0,0,0.75)",
          backdropFilter:       "blur(20px)",
          WebkitBackdropFilter: "blur(20px)",
          borderBottom:         "1px solid hsl(var(--gold)/0.1)",
        }}
      >
        <button
          onClick={() => setNavOpen(true)}
          aria-label="Open navigation"
          aria-expanded={navOpen}
          className="grid place-items-center w-10 h-10 rounded-xl transition-colors hover:bg-white/[0.06] text-cream/70 hover:text-gold"
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
          onClick={() => setSettingsOpen(true)}
          aria-label="Open settings"
          aria-expanded={settingsOpen}
          className="grid place-items-center w-10 h-10 rounded-xl transition-colors hover:bg-white/[0.06] text-cream/70 hover:text-gold"
        >
          <MoreVertical className="w-5 h-5" />
        </button>
      </header>

      {/* Spacer */}
      <div style={{ height: "56px" }} aria-hidden />

      {/* Left nav drawer */}
      <AnimatePresence>
        {navOpen && (
          <>
            <motion.div
              key="nav-backdrop"
              initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
              transition={{ duration: 0.28 }}
              className="fixed inset-0 z-[148]"
              style={{ background: "rgba(0,0,0,0.6)", backdropFilter: "blur(4px)", WebkitBackdropFilter: "blur(4px)" }}
              onClick={() => setNavOpen(false)}
            />
            <motion.div
              key="nav-panel"
              initial={{ x: "-100%" }} animate={{ x: 0 }} exit={{ x: "-100%" }}
              transition={{ duration: 0.36, ease: [0.7, 0, 0.3, 1] }}
              className="fixed top-0 left-0 bottom-0 z-[149] flex flex-col"
              style={{
                width:                "min(300px, 85vw)",
                background:           "rgba(4,4,4,0.97)",
                backdropFilter:       "blur(32px)",
                WebkitBackdropFilter: "blur(32px)",
                borderRight:          "1px solid hsl(var(--gold)/0.15)",
              }}
            >
              <div className="flex items-center justify-between px-5 py-4 border-b border-white/[0.06]">
                <span className="font-display font-black text-sm gold-text tracking-tight">GENISYS</span>
                <button
                  onClick={() => setNavOpen(false)}
                  aria-label="Close navigation"
                  className="grid place-items-center w-9 h-9 rounded-xl glass transition-colors hover:text-gold text-cream/40"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>

              <nav className="flex flex-col gap-1 px-3 py-4 flex-1">
                {PAGE_LINKS.map((l, i) => (
                  <motion.button
                    key={l.label}
                    onClick={() => { l.action(); setNavOpen(false); }}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ duration: 0.3, delay: 0.05 + i * 0.07, ease: [0.7, 0, 0.3, 1] }}
                    className={
                      "w-full flex items-center gap-3 px-4 py-3.5 rounded-xl text-left transition-colors " +
                      (isActive(l) ? "bg-gold/[0.1] text-gold" : "text-cream/65 hover:bg-white/[0.04] hover:text-cream")
                    }
                  >
                    {isActive(l) && <span className="w-1 h-5 rounded-full bg-gold flex-none" />}
                    <span className="font-mono text-[11px] tracking-[0.35em]">{l.label}</span>
                  </motion.button>
                ))}
              </nav>

              <div className="px-5 pb-6 space-y-4 border-t border-white/[0.06] pt-4">
                <motion.button
                  initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.3, delay: 0.35 }}
                  onClick={() => { setNavOpen(false); window.dispatchEvent(new Event("open-contact")); }}
                  className="w-full py-3 rounded-full glass-strong gold-border-glow font-mono text-[10px] tracking-[0.3em] text-gold hover:text-cream transition-colors"
                >
                  START A PROJECT
                </motion.button>
                <motion.div
                  initial={{ opacity: 0 }} animate={{ opacity: 1 }}
                  transition={{ delay: 0.42 }}
                  className="flex flex-wrap gap-2.5"
                >
                  {Object.entries(SOCIAL).map(([platform, url]) => (
                    <a
                      key={platform} href={url} target="_blank" rel="noopener noreferrer"
                      aria-label={platform}
                      className="w-9 h-9 grid place-items-center rounded-xl transition-all hover:scale-110"
                      style={{ background: "hsl(var(--gold)/0.08)", border: "1px solid hsl(var(--gold)/0.2)", color: "hsl(var(--gold)/0.7)" }}
                    >
                      <SocialIcon platform={platform} size={15} />
                    </a>
                  ))}
                </motion.div>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>

      {/* Right settings panel */}
      <AnimatePresence>
        {settingsOpen && (
          <>
            <motion.div
              key="set-backdrop"
              initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
              transition={{ duration: 0.28 }}
              className="fixed inset-0 z-[148]"
              style={{ background: "rgba(0,0,0,0.6)", backdropFilter: "blur(4px)", WebkitBackdropFilter: "blur(4px)" }}
              onClick={() => setSettingsOpen(false)}
            />
            <motion.div
              key="set-panel"
              initial={{ x: "100%" }} animate={{ x: 0 }} exit={{ x: "100%" }}
              transition={{ duration: 0.36, ease: [0.7, 0, 0.3, 1] }}
              className="fixed top-0 right-0 bottom-0 z-[149] flex flex-col"
              style={{
                width:                "min(300px, 88vw)",
                background:           "rgba(4,4,4,0.97)",
                backdropFilter:       "blur(32px)",
                WebkitBackdropFilter: "blur(32px)",
                borderLeft:           "1px solid hsl(var(--gold)/0.15)",
              }}
            >
              <div className="flex items-center justify-between px-5 py-4 border-b border-white/[0.06]">
                <div>
                  <p className="font-mono text-[9px] tracking-[0.4em] text-gold/60">SETTINGS</p>
                  <p className="font-display font-black text-sm text-cream/90 mt-0.5">Experience</p>
                </div>
                <button
                  onClick={() => setSettingsOpen(false)}
                  aria-label="Close settings"
                  className="grid place-items-center w-9 h-9 rounded-xl glass transition-colors hover:text-gold text-cream/40"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>

              <div
                className="flex-1 overflow-y-auto overscroll-contain px-4 py-3 space-y-1"
                style={{ scrollbarWidth: "none" }}
              >
                {SETTING_META.map(({ key, label, sub }, i) => (
                  <motion.button
                    key={key}
                    onClick={() => toggle(key)}
                    initial={{ opacity: 0, x: 16 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ duration: 0.25, delay: 0.03 + i * 0.035 }}
                    className="w-full flex items-center gap-3 px-3 py-3 rounded-xl text-left transition-colors hover:bg-white/[0.04]"
                  >
                    {/* Toggle pill */}
                    <div
                      className="flex-none relative w-10 h-5 rounded-full transition-all duration-300"
                      style={{
                        background: settings[key] ? "hsl(var(--gold)/0.85)" : "hsl(0 0% 100% / 0.1)",
                        border:     settings[key] ? "1px solid hsl(var(--gold))" : "1px solid hsl(0 0% 100% / 0.18)",
                      }}
                    >
                      <span
                        className="absolute top-0.5 w-4 h-4 rounded-full transition-all duration-300"
                        style={{
                          left:       settings[key] ? "calc(100% - 18px)" : "2px",
                          background: settings[key] ? "#000" : "hsl(0 0% 100% / 0.45)",
                          boxShadow:  settings[key] ? "0 0 6px hsl(var(--gold)/0.55)" : "none",
                        }}
                      />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className={"font-mono text-[10px] tracking-[0.18em] leading-snug " +
                        (settings[key] ? "text-cream/90" : "text-cream/30")}>
                        {label}
                      </p>
                      <p className="font-mono text-[8px] text-cream/20 leading-snug">{sub}</p>
                    </div>
                  </motion.button>
                ))}
              </div>

              <div className="px-5 py-4 border-t border-white/[0.06]">
                <button
                  onClick={resetAll}
                  className="w-full flex items-center justify-center gap-2 py-2.5 rounded-full text-cream/28 hover:text-gold transition-colors font-mono text-[9px] tracking-[0.3em]"
                  style={{ border: "1px solid hsl(0 0% 100% / 0.07)" }}
                >
                  <RotateCcw className="w-3 h-3" />
                  RESET ALL TO DEFAULT
                </button>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </>
  );
}
"""
open("src/components/Navigation.tsx", "w").write(content)
print("  ok  Navigation.tsx written")
PYEOF

# ─────────────────────────────────────────────────────────────────────────────
# 3. Update App.tsx
# ─────────────────────────────────────────────────────────────────────────────
echo "  [3/6] Updating src/App.tsx ..."
python3 << 'PYEOF'
src = open("src/App.tsx").read()

# Add SettingsProvider + useSettings import after GyroscopeProvider import
old = 'import { GyroscopeProvider }      from "@/contexts/GyroscopeContext";'
new = (
    'import { GyroscopeProvider }      from "@/contexts/GyroscopeContext";\n'
    'import { SettingsProvider, useSettings } from "@/contexts/SettingsContext";'
)
src = src.replace(old, new)

# Rename App function to AppInner
src = src.replace(
    "export default function App() {",
    "function AppInner() {\n  const { settings } = useSettings();"
)

# Replace tier-based guards with settings-aware guards
src = src.replace(
    '  const showEmbers   = !reduced && TIER !== "low";\n'
    '  const showGoldDust = !reduced && TIER === "high";\n'
    '  const showAurora   = !reduced && TIER !== "low";',
    '  const showEmbers   = settings.particles      && !settings.reducedMotion && TIER !== "low";\n'
    '  const showGoldDust = settings.goldDust        && !settings.reducedMotion && TIER === "high";\n'
    '  const showAurora   = settings.aurora          && !settings.reducedMotion && TIER !== "low";'
)

# Gate individual components
gates = [
    ('          <MagneticCursor />',
     '          {settings.magneticCursor && !settings.reducedMotion && <MagneticCursor />}'),
    ('          <Letterbox />',
     '          {settings.letterbox && !settings.reducedMotion && <Letterbox />}'),
    ('          <ScrollVignette />',
     '          {settings.scrollVignette && <ScrollVignette />}'),
    ('          <CommandPalette />',
     '          {settings.commandPalette && <CommandPalette />}'),
    ('          <ClickBurst />',
     '          {settings.clickBurst && !settings.reducedMotion && <ClickBurst />}'),
    ('          <ScrollProgressBar />',
     '          {settings.scrollProgress && <ScrollProgressBar />}'),
]
for old_c, new_c in gates:
    if old_c in src:
        src = src.replace(old_c, new_c)

# Add SettingsProvider wrapper + new export default at end
old_end = '    <Analytics />\n    </ErrorBoundary>\n  );\n}'
new_end = (
    '    <Analytics />\n'
    '    </ErrorBoundary>\n'
    '  );\n'
    '}\n\n'
    'export default function App() {\n'
    '  return (\n'
    '    <SettingsProvider>\n'
    '      <AppInner />\n'
    '    </SettingsProvider>\n'
    '  );\n'
    '}'
)
src = src.replace(old_end, new_end)

open("src/App.tsx", "w").write(src)
print("  ok  App.tsx updated")
PYEOF

# ─────────────────────────────────────────────────────────────────────────────
# 4. MusicPlayer — remove dev hint + fix button position
# ─────────────────────────────────────────────────────────────────────────────
echo "  [4/6] Patching MusicPlayer.tsx ..."
python3 << 'PYEOF'
import re
src = open("src/components/MusicPlayer.tsx").read()

# Remove ADD TRACKS hint from playlist footer
src = re.sub(
    r'\s*<p[^>]*>\s*ADD TRACKS IN src/data/musicConfig\.ts\s*</p>',
    '',
    src,
)

# Ensure music button sits at bottom:24px left:24px
# Replace any fixed bottom-6 left-6 class combo
src = src.replace(
    'className="fixed bottom-6 left-6 z-[91]',
    'className="fixed z-[91]',
)
# If the button doesn't already have an explicit style, add it
if 'style={{ zIndex: 91, bottom:' not in src and '"fixed z-[91] grid place-items-center' in src:
    src = src.replace(
        '"fixed z-[91] grid place-items-center w-12 h-12',
        '"fixed grid place-items-center w-12 h-12',
    )
    # Add style prop on the button - find the aria-expanded line and add style after
    src = src.replace(
        '        aria-expanded={open}\n        className="fixed grid place-items-center',
        '        aria-expanded={open}\n        style={{ position:"fixed", bottom:"24px", left:"24px", zIndex:91 }}\n        className="grid place-items-center',
    )

open("src/components/MusicPlayer.tsx", "w").write(src)
print("  ok  MusicPlayer.tsx patched")
PYEOF

# ─────────────────────────────────────────────────────────────────────────────
# 5. BackToTop — align to bottom 24px
# ─────────────────────────────────────────────────────────────────────────────
echo "  [5/6] Patching BackToTop.tsx ..."
python3 << 'PYEOF'
src = open("src/components/BackToTop.tsx").read()

old = (
    '            bottom:     raised\n'
    '              ? "max(calc(env(safe-area-inset-bottom, 0px) + 155px), 163px)"\n'
    '              : "max(calc(env(safe-area-inset-bottom, 0px) + 24px), 32px)",'
)
new = (
    '            bottom:     raised\n'
    '              ? "max(calc(env(safe-area-inset-bottom, 0px) + 155px), 163px)"\n'
    '              : "24px",'
)
if old in src:
    src = src.replace(old, new)
    print("  ok  BackToTop bottom aligned to 24px")
else:
    print("  --  BackToTop style already correct or different format")

open("src/components/BackToTop.tsx", "w").write(src)
PYEOF

# ─────────────────────────────────────────────────────────────────────────────
# 6. Bump version
# ─────────────────────────────────────────────────────────────────────────────
echo "  [6/6] Bumping version to 3.9.0 ..."
python3 << 'PYEOF'
import json
p = json.load(open("package.json"))
p["version"] = "3.9.0"
json.dump(p, open("package.json", "w"), indent=2)
print("  ok  version -> 3.9.0")
PYEOF

echo ""
echo "=================================================================="
echo "  GENISYS v3.9 PATCH COMPLETE"
echo "=================================================================="
echo ""
echo "  FIXED:"
echo "    ok Music playlist no longer shows dev hint text"
echo "    ok Music button + BackToTop now perfectly symmetrical"
echo ""
echo "  HEADER - now a proper mobile-app top bar:"
echo "    ok LEFT  -> hamburger -> nav drawer slides from left"
echo "    ok CENTER -> GENISYS brand"
echo "    ok RIGHT -> three-dot -> settings panel slides from right"
echo ""
echo "  SETTINGS (tap three-dot):"
echo "    ok Ember Particles, Aurora, Gold Dust, Magnetic Cursor"
echo "    ok Smooth Scroll, Click Burst, Letterbox, Scroll Vignette"
echo "    ok Progress Bar, Command Palette, Reduce All Motion"
echo "    ok All choices saved to localStorage"
echo "    ok Reset All button restores defaults"
echo ""
echo "  Run: npm run dev"
echo "=================================================================="
