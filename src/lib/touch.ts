/**
 * COMPAT-3 — Robust touch detection.
 *
 * `matchMedia("(pointer: coarse)")` alone fails on:
 *   - Termux WebView (reports pointer:fine even on touchscreen)
 *   - Some Samsung Internet builds
 *   - Hybrid pointer devices
 *
 * This utility checks three independent signals and returns true if ANY fires.
 * Memoised at first call — the result never changes within a page session.
 */
let _cached: boolean | null = null;

export function isTouch(): boolean {
  if (_cached !== null) return _cached;
  if (typeof window === "undefined") return (_cached = false);
  _cached =
    matchMedia("(pointer: coarse)").matches ||
    "ontouchstart" in window             ||
    navigator.maxTouchPoints > 0;
  return _cached;
}
