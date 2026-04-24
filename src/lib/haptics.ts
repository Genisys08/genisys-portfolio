/**
 * Premium haptic feedback wrapper for navigator.vibrate.
 * Silently no-ops on unsupported browsers (Safari iOS doesn't support vibrate;
 * the call is harmless). Subtle defaults for "premium" feel.
 */
export function haptic(pattern: number | number[] = 10) {
  try {
    const nav = typeof navigator !== "undefined" ? (navigator as Navigator & { vibrate?: (p: number | number[]) => boolean }) : null;
    if (nav && typeof nav.vibrate === "function") {
      nav.vibrate(pattern);
    }
  } catch {
    /* ignore */
  }
}
