import { useEffect, useRef, useState } from "react";
import { isTouch } from "@/lib/touch";

type CursorMode = "default" | "pointer" | "image" | "text";

/**
 * MagneticCursor V3.1 — Morphing cursor
 *
 * COMPAT-3: Uses compound touch detection (isTouch()) — returns null on all
 *           touch devices regardless of how the browser reports pointer type.
 *
 * UPGRADE-1: Four distinct cursor states based on the element under the cursor:
 *   default → 40px gold ring, follows with 0.18 lag
 *   pointer → 52px ring expands, gold-fill glow, bounces on click
 *   image   → 44px ring + crosshair lines overlay
 *   text    → 24px collapsed ring shifts to I-beam underline style
 */
export default function MagneticCursor() {
  const dot     = useRef<HTMLDivElement>(null);
  const ring    = useRef<HTMLDivElement>(null);
  const cross1  = useRef<HTMLDivElement>(null);
  const cross2  = useRef<HTMLDivElement>(null);
  const [mode, setMode]    = useState<CursorMode>("default");
  const [click, setClick]  = useState(false);

  useEffect(() => {
    if (isTouch()) return;

    let x = 0, y = 0, rx = 0, ry = 0;
    let raf = 0;

    const getMode = (el: Element | null): CursorMode => {
      if (!el) return "default";
      const tag = el.tagName.toLowerCase();
      if (
        tag === "a" || tag === "button" ||
        el.closest("a") || el.closest("button") ||
        el.hasAttribute("data-magnetic") ||
        (el as HTMLElement).style?.cursor === "pointer"
      ) return "pointer";
      if (tag === "img" || tag === "canvas" || tag === "video") return "image";
      if (
        tag === "p" || tag === "span" || tag === "h1" || tag === "h2" ||
        tag === "h3" || tag === "h4" || tag === "h5" || tag === "h6" ||
        tag === "label" || tag === "li"
      ) return "text";
      return "default";
    };

    const onMove = (e: PointerEvent) => {
      x = e.clientX; y = e.clientY;
      setMode(getMode(e.target as Element));
    };
    const onDown = () => setClick(true);
    const onUp   = () => setClick(false);

    window.addEventListener("pointermove", onMove, { passive: true });
    window.addEventListener("pointerdown", onDown, { passive: true });
    window.addEventListener("pointerup",   onUp,   { passive: true });

    const tick = () => {
      rx += (x - rx) * 0.15;
      ry += (y - ry) * 0.15;
      if (dot.current) {
        dot.current.style.transform = `translate(${x}px,${y}px)`;
      }
      if (ring.current) {
        ring.current.style.transform = `translate(${rx}px,${ry}px)`;
      }
      raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);

    return () => {
      cancelAnimationFrame(raf);
      window.removeEventListener("pointermove", onMove);
      window.removeEventListener("pointerdown", onDown);
      window.removeEventListener("pointerup",   onUp);
    };
  }, []);

  if (isTouch()) return null;

  // ── Ring geometry per mode ──────────────────────────────────────────────
  const configs: Record<CursorMode, {
    size: number; border: string; bg: string; opacity: number;
  }> = {
    default: { size: 40,  border: "1px solid hsl(44 70% 55% / 0.70)", bg: "transparent",                opacity: 1    },
    pointer: { size: 52,  border: "1px solid hsl(44 80% 65% / 0.90)", bg: "hsl(44 70% 55% / 0.10)",    opacity: 1    },
    image:   { size: 44,  border: "1px solid hsl(44 60% 50% / 0.75)", bg: "transparent",                opacity: 0.85 },
    text:    { size: 24,  border: "1px solid hsl(44 50% 60% / 0.55)", bg: "transparent",                opacity: 0.6  },
  };
  const cfg = configs[mode];

  return (
    <>
      {/* Outer ring — morphs size/color per mode */}
      <div
        ref={ring}
        aria-hidden
        style={{
          position:    "fixed",
          top:         0,
          left:        0,
          zIndex:      9500,
          pointerEvents: "none",
          width:       cfg.size,
          height:      cfg.size,
          marginLeft:  -(cfg.size / 2),
          marginTop:   -(cfg.size / 2),
          borderRadius:"50%",
          border:      cfg.border,
          background:  cfg.bg,
          opacity:     cfg.opacity,
          mixBlendMode:"difference" as const,
          transition:  "width 220ms cubic-bezier(0.7,0,0.3,1), height 220ms cubic-bezier(0.7,0,0.3,1), margin 220ms cubic-bezier(0.7,0,0.3,1), border-color 200ms ease, background 200ms ease, opacity 200ms ease",
          transform:   "translate(0,0)",
          scale:       click ? "0.82" : "1",
        }}
      />

      {/* Crosshair lines — only visible in image mode */}
      <div
        ref={cross1}
        aria-hidden
        style={{
          position:    "fixed",
          top: 0, left: 0,
          zIndex:      9501,
          pointerEvents: "none",
          width:       "14px",
          height:      "1px",
          marginLeft:  "-7px",
          marginTop:   "-0.5px",
          background:  "hsl(44 70% 60% / 0.8)",
          mixBlendMode: "difference" as const,
          opacity:     mode === "image" ? 1 : 0,
          transition:  "opacity 180ms ease",
          transform:   ring.current?.style.transform ?? "translate(0,0)",
        }}
      />
      <div
        ref={cross2}
        aria-hidden
        style={{
          position:    "fixed",
          top: 0, left: 0,
          zIndex:      9501,
          pointerEvents: "none",
          width:       "1px",
          height:      "14px",
          marginLeft:  "-0.5px",
          marginTop:   "-7px",
          background:  "hsl(44 70% 60% / 0.8)",
          mixBlendMode: "difference" as const,
          opacity:     mode === "image" ? 1 : 0,
          transition:  "opacity 180ms ease",
          transform:   ring.current?.style.transform ?? "translate(0,0)",
        }}
      />

      {/* Inner dot — always precise, no lag */}
      <div
        ref={dot}
        aria-hidden
        style={{
          position:    "fixed",
          top:         0,
          left:        0,
          zIndex:      9502,
          pointerEvents: "none",
          width:       mode === "pointer" ? 6 : 4,
          height:      mode === "pointer" ? 6 : 4,
          marginLeft:  mode === "pointer" ? -3 : -2,
          marginTop:   mode === "pointer" ? -3 : -2,
          borderRadius:"50%",
          background:  "hsl(44 80% 65%)",
          transition:  "width 150ms ease, height 150ms ease, margin 150ms ease",
          transform:   "translate(0,0)",
        }}
      />
    </>
  );
}
