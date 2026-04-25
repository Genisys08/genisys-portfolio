import { useEffect } from "react";

/**
 * COMPAT-1 — iOS Safari Viewport Height Fix
 *
 * iOS Safari <15.4 does not support `dvh` units.  Tailwind's min-h-[100dvh]
 * silently fails on these devices, causing the Hero to be either too short or
 * to overflow into the address-bar zone.
 *
 * This hook writes --vh = 1% of the REAL innerHeight to the document root.
 * index.css then applies a @supports fallback: when `dvh` is unsupported,
 * #top (the Hero section) uses calc(var(--vh) * 100) instead.
 */
export function useVhFix(): void {
  useEffect(() => {
    const set = () => {
      document.documentElement.style.setProperty(
        "--vh",
        `${window.innerHeight * 0.01}px`,
      );
    };
    set();
    window.addEventListener("resize",            set, { passive: true });
    window.addEventListener("orientationchange", set, { passive: true });
    return () => {
      window.removeEventListener("resize",            set);
      window.removeEventListener("orientationchange", set);
    };
  }, []);
}
