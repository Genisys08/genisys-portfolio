import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";
export function cn(...inputs: ClassValue[]) { return twMerge(clsx(inputs)); }
export const PALETTE = {
  gold:       [0.83, 0.69, 0.22],
  goldDeep:   [0.55, 0.42, 0.10],
  cobalt:     [0.10, 0.30, 0.95],
  terracotta: [0.85, 0.36, 0.22],
  teal:       [0.05, 0.55, 0.55],
  cream:      [0.95, 0.92, 0.82],
  forest:     [0.08, 0.30, 0.18],
  slate:      [0.30, 0.34, 0.40],
} as const;
