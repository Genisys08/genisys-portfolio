import { useEffect, useRef } from "react";

/**
 * ScrollProgressBar — thin gold line at top of viewport.
 * Grows from 0 → 100% as the user scrolls through the page.
 * rAF-batched, passive listener — zero layout thrash.
 */
export default function ScrollProgressBar() {
  const barRef     = useRef<HTMLDivElement>(null);
  const rafPending = useRef(false);

  useEffect(() => {
    const update = () => {
      rafPending.current = false;
      const maxScroll = Math.max(
        1,
        document.documentElement.scrollHeight - window.innerHeight,
      );
      const pct = Math.min(100, (window.scrollY / maxScroll) * 100);
      if (!barRef.current) return;
      barRef.current.style.width   = pct + "%";
      // Glow brightens as you get deeper into the page
      const glowAlpha = 0.3 + (pct / 100) * 0.5;
      barRef.current.style.boxShadow = `0 0 ${6 + pct * 0.06}px hsl(44 80% 55% / ${glowAlpha})`;
    };

    const onScroll = () => {
      if (rafPending.current) return;
      rafPending.current = true;
      requestAnimationFrame(update);
    };

    window.addEventListener("scroll", onScroll, { passive: true });
    update(); // set initial state
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  return (
    /* Outer track — full-width 1px ghost line */
    <div
      aria-hidden
      className="fixed top-0 left-0 right-0 z-[9800] h-[2px] pointer-events-none"
      style={{ background: "hsl(44 60% 50% / 0.10)" }}
    >
      {/* Inner fill — gold gradient, grows with scroll */}
      <div
        ref={barRef}
        style={{
          height:     "100%",
          width:      "0%",
          background: "linear-gradient(90deg, hsl(44 60% 30%), hsl(44 80% 55%), hsl(44 95% 75%))",
          transition: "width 80ms linear",
          willChange: "width",
        }}
      />
    </div>
  );
}
