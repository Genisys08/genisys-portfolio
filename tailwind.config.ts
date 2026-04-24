import type { Config } from "tailwindcss";
export default {
  darkMode: ["class"],
  content: ["./index.html", "./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        border: "hsl(var(--border))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: { DEFAULT: "hsl(var(--primary))", foreground: "hsl(var(--primary-foreground))" },
        accent:  { DEFAULT: "hsl(var(--accent))",  foreground: "hsl(var(--accent-foreground))" },
        muted:   { DEFAULT: "hsl(var(--muted))",   foreground: "hsl(var(--muted-foreground))" },
        gold: {
          DEFAULT: "hsl(var(--gold))",
          soft:    "hsl(var(--gold-soft))",
          deep:    "hsl(var(--gold-deep))",
        },
        cobalt:     "hsl(var(--cobalt))",
        terracotta: "hsl(var(--terracotta))",
        teal:       "hsl(var(--teal))",
        cream:      "hsl(var(--cream))",
        forest:     "hsl(var(--forest))",
        slate:      "hsl(var(--slate))",
      },
      fontFamily: {
        /*
         * FIX v3: Cinzel Decorative added as display font — cinematic premium serif
         * for all font-display headings. Fallback chain ensures graceful degradation.
         */
        display: [
          "Cinzel Decorative",
          "Cinzel",
          "Inter",
          "system-ui",
          "sans-serif",
        ],
        mono: ["JetBrains Mono", "ui-monospace", "monospace"],
      },
      keyframes: {
        breathe:     { "0%,100%": { transform: "translateY(0) scale(1)" },         "50%": { transform: "translateY(-8px) scale(1.01)" } },
        meshShift:   { "0%,100%": { transform: "translate(0,0) rotate(0deg)" },    "50%": { transform: "translate(40px,-30px) rotate(180deg)" } },
        borderPulse: { "0%,100%": { opacity: "0.55", boxShadow: "0 0 18px hsl(var(--gold) / .35), inset 0 0 12px hsl(var(--gold) / .15)" }, "50%": { opacity: "1", boxShadow: "0 0 32px hsl(var(--gold) / .75), inset 0 0 18px hsl(var(--gold) / .35)" } },
        shimmer:     { "0%": { backgroundPosition: "-200% 0" }, "100%": { backgroundPosition: "200% 0" } },
        scanline:    { "0%": { transform: "translateY(-100%)" }, "100%": { transform: "translateY(100%)" } },
        emberFloat:  { "0%": { transform: "translateY(0) translateX(0)", opacity: "0" }, "10%,90%": { opacity: "1" }, "100%": { transform: "translateY(-120vh) translateX(40px)", opacity: "0" } },
      },
      animation: {
        breathe:        "breathe 6s ease-in-out infinite",
        "mesh-shift":   "meshShift 30s ease-in-out infinite",
        "border-pulse": "borderPulse 4s ease-in-out infinite",
        shimmer:        "shimmer 3s linear infinite",
        scanline:       "scanline 8s linear infinite",
        ember:          "emberFloat 18s linear infinite",
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
} satisfies Config;
