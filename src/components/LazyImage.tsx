import { useEffect, useRef, useState, memo } from "react";

/**
 * LazyImage V3.0 — Cinematic Blur-Up
 *
 * Strategy
 * ─────────
 * • NO IntersectionObserver — it is unreliable inside Termux WebView and
 *   some Android Chrome versions.  The browser's native loading="lazy"
 *   handles deferred network fetching instead.
 * • Blur-up is driven entirely by the native <img> onLoad event, which
 *   fires reliably on every platform.
 * • Transitions are applied via inline styles (not Tailwind class-toggling)
 *   to avoid any Tailwind purge or JIT delay on first paint.
 * • willChange: 'filter, opacity' lifts the element onto a GPU layer,
 *   keeping the 700 ms transition silky on low-end Android hardware.
 * • Cached-image guard: if the browser already has the image (.complete),
 *   we skip the blur animation entirely and show it sharp on mount.
 */
const LazyImage = memo(function LazyImage({
  src,
  alt,
  className,
}: {
  src: string;
  alt: string;
  className?: string;
}) {
  const imgRef = useRef<HTMLImageElement>(null);
  const [loaded, setLoaded] = useState(false);

  // ── Cached-image guard ───────────────────────────────────────────────────
  // If the browser already holds this image in its cache, .complete is true
  // before React even mounts the component.  We skip the blur in that case.
  useEffect(() => {
    const img = imgRef.current;
    if (img && img.complete && img.naturalWidth > 0) {
      setLoaded(true);
    }
  }, [src]);

  return (
    <div className={"relative overflow-hidden bg-white/[0.02] " + (className ?? "")}>

      {/* Shimmer skeleton — visible until the image resolves */}
      {!loaded && (
        <div
          className="absolute inset-0 animate-shimmer pointer-events-none"
          style={{
            background:
              "linear-gradient(90deg, transparent, hsl(0 0% 100% / 0.05), transparent)",
            backgroundSize: "200% 100%",
          }}
        />
      )}

      {/*
       * BUG FIX #3 — Native Blur-Up Effect (onLoad, no IntersectionObserver)
       * ─────────────────────────────────────────────────────────────────────
       * BEFORE: opacity-only fade (blur removed in V2.5 due to IO failures).
       *
       * AFTER:
       *   Unloaded state → filter: blur(10px), opacity: 0.4
       *   Loaded state   → filter: blur(0px),  opacity: 1
       *   Transition     → both properties animate over 700 ms (ease)
       *
       * The `loaded` boolean is set by:
       *   a) onLoad  — native browser event, fires when the image decodes.
       *   b) onError — ensures the skeleton disappears even if src is broken.
       *   c) useEffect guard above — skips blur for already-cached images.
       *
       * willChange promotes the element to its own compositor layer so the
       * CSS transition runs on the GPU — crucial for 60 fps on mobile.
       */}
      <img
        ref={imgRef}
        src={src}
        alt={alt}
        loading="lazy"
        decoding="async"
        onLoad={() => setLoaded(true)}
        onError={() => setLoaded(true)}
        className="w-full h-full object-cover"
        style={{
          filter:     loaded ? "blur(0px)"  : "blur(10px)",
          opacity:    loaded ? 1            : 0.4,
          transition: "filter 700ms ease, opacity 700ms ease",
          willChange: "filter, opacity",
        }}
      />
    </div>
  );
});

export default LazyImage;
