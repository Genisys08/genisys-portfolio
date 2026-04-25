/**
 * AESTHETIC-1 — Aurora Mesh Background
 *
 * Three slow-drifting radial gradient orbs create a cinematic deep-space
 * aurora effect behind the WebGL layer.  Pure CSS — no JS RAF loop.
 * Each orb is a `div` with a radial gradient and a unique drift keyframe.
 *
 * Opacity kept at 0.10–0.14 so they enrich the black without competing
 * with LiquidCanvas or any foreground content.
 */
export default function AuroraBackground() {
  return (
    <div aria-hidden className="fixed inset-0 z-0 pointer-events-none overflow-hidden">
      {/* Orb 1 — warm gold, top-left drift */}
      <div className="aurora-orb aurora-1" />
      {/* Orb 2 — cooler amber, right-side drift */}
      <div className="aurora-orb aurora-2" />
      {/* Orb 3 — deep bronze, bottom drift */}
      <div className="aurora-orb aurora-3" />
    </div>
  );
}
