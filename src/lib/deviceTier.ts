export type DeviceTier = "high" | "mid" | "low";

/**
 * Classify the current device into three performance tiers.
 *
 * high — desktop / flagship phone   → all effects on
 * mid  — mid-range phone            → EmberParticles throttled, no GoldDust
 * low  — budget / old phone         → EmberParticles off, no GoldDust
 *
 * deviceMemory is in GB; hardwareConcurrency is logical CPU cores.
 * Both APIs have limited precision by design (privacy) but are good enough
 * for coarse bucketing.
 */
export function getDeviceTier(): DeviceTier {
  if (typeof window === "undefined") return "high";

  const mem   = (navigator as Navigator & { deviceMemory?: number }).deviceMemory ?? 8;
  const cores = navigator.hardwareConcurrency ?? 8;
  const coarse = matchMedia("(pointer: coarse)").matches;

  if (mem <= 2 || cores <= 2)                     return "low";
  if (coarse && (mem <= 4 || cores <= 4))         return "mid";
  return "high";
}
