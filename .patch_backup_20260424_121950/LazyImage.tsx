import { useEffect, useRef, useState, memo } from "react";

/**
 * LazyImage V2.5
 * — Renders <img> immediately (no IntersectionObserver gating).
 * — Uses native loading="lazy" + decoding="async" for performance.
 * — ZERO blur filters. Opacity-only fade-in (GPU-cheap, can never lock mid-state).
 * — Cached-image fallback: if .complete already true on mount, mark loaded instantly.
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

  useEffect(() => {
    const img = imgRef.current;
    if (img && img.complete && img.naturalWidth > 0) setLoaded(true);
  }, [src]);

  return (
    <div className={"relative overflow-hidden bg-white/[0.02] " + (className ?? "")}>
      {!loaded && (
        <div
          className="absolute inset-0 animate-shimmer pointer-events-none"
          style={{
            background: "linear-gradient(90deg, transparent, hsl(0 0% 100% / 0.05), transparent)",
            backgroundSize: "200% 100%",
          }}
        />
      )}
      <img
        ref={imgRef}
        src={src}
        alt={alt}
        loading="lazy"
        decoding="async"
        onLoad={() => setLoaded(true)}
        onError={() => setLoaded(true)}
        className={
          "w-full h-full object-cover transition-opacity duration-200 " +
          (loaded ? "opacity-100" : "opacity-0")
        }
      />
    </div>
  );
});

export default LazyImage;
