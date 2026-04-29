/**
 * SettingsPage — v4.0
 * Dedicated settings page accessible from the hamburger nav SETTINGS link.
 */
import { useEffect } from "react";
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
  // Always start at the top when this page mounts
  useEffect(() => { window.scrollTo(0, 0); document.documentElement.scrollTop = 0; }, []);
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
