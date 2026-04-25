import { useEffect, useRef } from "react";

/**
 * AESTHETIC-3 — Cinematic Scroll Vignette
 *
 * A fixed radial-gradient overlay that strengthens as the user scrolls.
 * Opacity range: 0 (at top) → 0.55 (at deepest scroll point).
 * Uses a passive scroll listener → rAF DOM write pipeline to avoid
 * forced reflows and stay smooth even on low-end Android.
 */
export default function ScrollVignette() {
  const divRef     = useRef<HTMLDivElement>(null);
  const rafPending = useRef(false);

  useEffect(() => {
    const onScroll = () => {
      if (rafPending.current) return;
      rafPending.current = true;
      requestAnimationFrame(() => {
        rafPending.current = false;
        const maxScroll = Math.max(
          1,
          document.documentElement.scrollHeight - window.innerHeight,
        );
        const ratio   = Math.min(window.scrollY / maxScroll, 1);
        const opacity = ratio * 0.55;
        if (divRef.current) divRef.current.style.opacity = String(opacity);
      });
    };
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  return (
    <div
      ref={divRef}
      aria-hidden
      className="fixed inset-0 pointer-events-none"
      style={{
        zIndex:     8,
        opacity:    0,
        background: "radial-gradient(ellipse 90% 80% at 50% 50%, transparent 35%, #000 100%)",
      }}
    />
  );
}
