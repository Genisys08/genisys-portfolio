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
