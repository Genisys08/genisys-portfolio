#!/usr/bin/env bash
# =============================================================================
# patch_lightbox.sh — Genisys Graphics Design · UI Bug Patch
# Fixes: (1) 9:16 image cut-off  (2) ghost scroll on mobile  (3) blur-up effect
# Run from inside your project root:  bash patch_lightbox.sh
# =============================================================================

set -e

# ── Locate project root ───────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Walk up from CWD until we find the src/components directory
PROJECT_ROOT="$PWD"
while [[ "$PROJECT_ROOT" != "/" ]]; do
  if [[ -d "$PROJECT_ROOT/src/components" ]]; then
    break
  fi
  PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done

if [[ ! -d "$PROJECT_ROOT/src/components" ]]; then
  echo "❌  Cannot locate src/components — run this script from inside your project root."
  exit 1
fi

COMPONENTS="$PROJECT_ROOT/src/components"
echo "✅  Project root: $PROJECT_ROOT"

# ── Backup originals ──────────────────────────────────────────────────────────
BACKUP_DIR="$PROJECT_ROOT/.patch_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
for f in Lightbox.tsx LazyImage.tsx; do
  [[ -f "$COMPONENTS/$f" ]] && cp "$COMPONENTS/$f" "$BACKUP_DIR/$f" && echo "💾  Backed up $f → $BACKUP_DIR/$f"
done

# =============================================================================
# FILE 1 of 2 — src/components/Lightbox.tsx
# Fixes applied:
#   BUG 1 — Image changed from object-cover / max-h-[70dvh] to
#            object-contain / max-h-[90vh] / max-w-full / w-auto / mx-auto.
#            Card capped at max-h-[95vh] + overflow-y-auto so the caption
#            remains reachable on any viewport without clipping the image.
#   BUG 2 — useEffect sets document.body.style.overflow = 'hidden' when the
#            lightbox mounts (item is truthy) and restores it to 'unset' on
#            cleanup.  Prevents ghost-scroll on mobile.
# =============================================================================
cat << 'EOF' > "$COMPONENTS/Lightbox.tsx"
import { useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { X } from "lucide-react";
import type { PortfolioItem } from "@/data/portfolioData";
import { useDominantColor } from "@/hooks/useDominantColor";

export default function Lightbox({
  item,
  onClose,
}: {
  item: PortfolioItem | null;
  onClose: () => void;
}) {
  const color = useDominantColor(item?.imagePath);

  // ── BUG FIX #2 — Body Scroll Lock ────────────────────────────────────────
  // Fires whenever `item` changes. When a lightbox is open (item !== null),
  // we lock the body scroll so swiping on mobile doesn't ghost-scroll the page.
  // The cleanup function is guaranteed to run before the next effect AND on
  // unmount, so overflow is always restored even if the user navigates away.
  useEffect(() => {
    if (!item) return;
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = prev || "unset";
    };
  }, [item]);

  return (
    <AnimatePresence>
      {item && (
        <motion.div
          key={item.id}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.35 }}
          className="fixed inset-0 z-[120] grid place-items-center p-4 sm:p-10"
          style={{
            background: `radial-gradient(80% 60% at 50% 50%, ${color}33, #000 80%)`,
            backdropFilter: "blur(14px)",
          }}
          onClick={onClose}
        >
          {/*
           * FIX v3: Close button — explicit z-index 9999 via inline style.
           * Repositioned to top-right corner, separate from VibeToggle (now bottom-left).
           * Never trappable by any stacking context on the page.
           */}
          <button
            aria-label="Close lightbox"
            onClick={onClose}
            style={{ zIndex: 9999 }}
            className="absolute top-5 right-5 sm:top-7 sm:right-7 grid place-items-center w-11 h-11 rounded-full glass-strong gold-border-glow"
          >
            <X className="w-5 h-5 text-gold" />
          </button>

          {/*
           * max-h-[95vh] + overflow-y-auto: the card never exceeds the viewport.
           * For 9:16 images the user can scroll inside the card to read the
           * caption — the image itself is never clipped or cropped.
           */}
          <motion.div
            initial={{ scale: 0.96, y: 20 }}
            animate={{ scale: 1, y: 0 }}
            exit={{ scale: 0.98, y: 10 }}
            transition={{ duration: 0.45, ease: [0.7, 0, 0.3, 1] }}
            className="relative max-w-4xl w-full max-h-[95vh] overflow-y-auto glass-strong specular grain rounded-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            {/*
             * BUG FIX #1 — 9:16 / Portrait Image Cut-Off
             * ─────────────────────────────────────────────
             * BEFORE: w-full  max-h-[70dvh]  object-cover
             *   → object-cover fills the box and crops whatever overflows.
             *     Tall portrait images lose their top/bottom edges.
             *
             * AFTER:  w-auto  max-h-[90vh]  max-w-full  object-contain  mx-auto
             *   → object-contain scales the image DOWN to fit entirely inside
             *     the box.  max-h-[90vh] caps height at 90 % of the viewport.
             *     max-w-full prevents horizontal overflow.  w-auto lets the
             *     browser calculate the correct intrinsic width.  mx-auto
             *     centres landscape images that are narrower than the card.
             */}
            <img
              src={item.imagePath}
              alt={item.title}
              className="w-auto max-h-[90vh] max-w-full object-contain mx-auto block"
            />

            <div className="p-5 sm:p-8">
              <div className="font-mono text-[10px] tracking-[0.3em] text-gold/80">
                {item.category.toUpperCase()}
              </div>
              <h3 className="mt-2 font-display text-2xl sm:text-3xl gold-text font-black">
                {item.title}
              </h3>
              {item.description && (
                <p className="mt-3 text-cream/70 text-sm leading-relaxed">
                  {item.description}
                </p>
              )}
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
EOF

echo "✅  Patched: src/components/Lightbox.tsx  (Bug #1 + Bug #2)"

# =============================================================================
# FILE 2 of 2 — src/components/LazyImage.tsx
# Fixes applied:
#   BUG 3 — Cinematic blur-up using onLoad (zero IntersectionObserver).
#            Image renders with blur(10px) + opacity 0.4 from the first paint.
#            When the native onLoad event fires, the `loaded` state flips and
#            CSS transition (filter + opacity, 700 ms) animates to clear/full.
#            willChange: 'filter, opacity' promotes the element to its own
#            compositor layer — GPU-accelerated, safe on Termux WebView.
#            The existing shimmer skeleton is preserved; it fades out at the
#            same moment the image resolves.
#            Cached-image guard (img.complete) is kept so repeat-visits skip
#            the blur entirely and render sharp immediately.
# =============================================================================
cat << 'EOF' > "$COMPONENTS/LazyImage.tsx"
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
EOF

echo "✅  Patched: src/components/LazyImage.tsx  (Bug #3)"

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🎬  Genisys Graphics Design — Lightbox & Blur Patch complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Files modified"
echo "  ──────────────"
echo "  src/components/Lightbox.tsx"
echo "    ✔  Bug #1 — object-contain + max-h-[90vh] + max-w-full"
echo "                card capped at max-h-[95vh] overflow-y-auto"
echo "    ✔  Bug #2 — body scroll lock via useEffect / cleanup"
echo ""
echo "  src/components/LazyImage.tsx"
echo "    ✔  Bug #3 — cinematic blur-up via onLoad"
echo "                blur(10px)→blur(0px) + 0.4→1 opacity, 700 ms ease"
echo "                GPU-promoted via willChange"
echo ""
echo "  Originals backed up → $BACKUP_DIR"
echo ""
echo "  Next step: npm run dev  (or your Vite start command)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
