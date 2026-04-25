#!/usr/bin/env bash
# =============================================================================
#  patch_v3_2.sh — Genisys Graphics V3.2 "MULTI-PAGE"
#
#  NEW FILES
#  ─────────
#  src/data/siteConfig.ts         Master config — pricing, socials, studio info
#  src/lib/router.ts              Zero-dep hash-based SPA router
#  src/pages/HomePage.tsx         Home page (all existing sections)
#  src/pages/ServicesPage.tsx     Pricing tiers + feature breakdown
#  src/pages/StudioPage.tsx       Founder bio + philosophy + tools
#  src/pages/CaseStudyPage.tsx    Per-project deep-dive view
#  src/pages/NotFoundPage.tsx     Branded 404
#  src/components/ClientLogoStrip.tsx  Horizontal brand-marks ticker
#  src/components/CtaSection.tsx       Full-width "start a project" CTA
#  src/components/CookieBanner.tsx     GDPR dismissible cookie notice
#  src/components/BackToTop.tsx        Floating scroll-to-top button
#  src/components/FAQ.tsx              Expandable accordion
#
#  MODIFIED FILES
#  ──────────────
#  src/components/Navigation.tsx   Page links + social icon row + active page
#  src/components/Hero.tsx         Availability badge from siteConfig
#  src/components/Footer.tsx       Full social grid + sitemap + page links
#  src/App.tsx                     Router integration + all new components
#  index.html                      JSON-LD structured data
#
#  Run from project root:  bash patch_v3_2.sh
# =============================================================================
set -e

PROJECT_ROOT="$PWD"
while [[ "$PROJECT_ROOT" != "/" ]]; do
  [[ -d "$PROJECT_ROOT/src/components" ]] && break
  PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done
[[ ! -d "$PROJECT_ROOT/src/components" ]] && echo "❌  Cannot find src/components." && exit 1
echo "✅  Project root: $PROJECT_ROOT"
cd "$PROJECT_ROOT"

BACKUP="$PROJECT_ROOT/.v32_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP" src/data src/lib src/pages

for f in \
  src/App.tsx src/components/Navigation.tsx \
  src/components/Hero.tsx src/components/Footer.tsx \
  src/data/portfolioData.ts index.html; do
  [[ -f "$f" ]] && cp "$f" "$BACKUP/$(basename $f).bak"
done
echo "💾  Backed up → $BACKUP"
echo ""
echo "━━━ Writing V3.2 files ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# =============================================================================
# 1. src/data/siteConfig.ts
#    THE SINGLE FILE YOU EDIT FOR ALL SITE CONTENT.
#    Pricing, social links, availability, studio details — all here.
# =============================================================================
cat << 'END_CONFIG' > src/data/siteConfig.ts
// ============================================================
//  GENISYS SITE CONFIG
//  Edit this file to update pricing, social links, studio
//  info, and availability — no hunting through components.
// ============================================================

// ── Studio info ────────────────────────────────────────────
export const STUDIO = {
  name:     "Genisys Graphics",
  tagline:  "Operatic Brand & Identity Design",
  email:    "hello@genisysgraphics.com",      // ← YOUR EMAIL
  phone:    "+1 (000) 000-0000",              // ← YOUR PHONE (optional)
  location: "Available Worldwide",            // ← YOUR LOCATION
  founded:  "2024",
  // Availability badge shown in Hero + Services page
  availability: {
    accepting: true,                          // ← false = "Fully Booked"
    nextSlot:  "June 2026",                  // ← shown when accepting = true
  },
};

// ── Social links — replace # with your real URL ────────────
//    Every link listed here appears in Footer + mobile nav.
export const SOCIAL = {
  instagram: "https://instagram.com/genisysgraphics", // ← YOUR INSTAGRAM
  twitter:   "https://twitter.com/genisysgfx",        // ← YOUR X / TWITTER
  behance:   "https://behance.net/genisysgraphics",   // ← YOUR BEHANCE
  dribbble:  "https://dribbble.com/genisysgraphics",  // ← YOUR DRIBBBLE
  tiktok:    "https://tiktok.com/@genisysgraphics",   // ← YOUR TIKTOK
  linkedin:  "https://linkedin.com/company/genisys",  // ← YOUR LINKEDIN
  youtube:   "https://youtube.com/@genisysgraphics",  // ← YOUR YOUTUBE
  pinterest: "https://pinterest.com/genisysgraphics", // ← YOUR PINTEREST
};

// ── Client logo strip — shown on home page below Hero ──────
//    Replace "name" + "abbr" with real client names.
//    If you have a logo SVG/PNG, add "logo" field with the URL.
export const CLIENTS = [
  { name: "Obsidian Collective",   abbr: "OC" },
  { name: "Voltage Syndicate",     abbr: "VS" },
  { name: "Phantom Thread",        abbr: "PT" },
  { name: "Cobalt Nexus",          abbr: "CN" },
  { name: "Ironframe Studios",     abbr: "IF" },
  { name: "Parallax Agency",       abbr: "PA" },
  { name: "Rogue State Co.",       abbr: "RS" },
  { name: "Monolith Brand Group",  abbr: "MB" },
];

// ── Pricing tiers — edit name, price, features freely ──────
//    Add or remove objects in the array to add/remove tiers.
export const PRICING = [
  {
    id:          "ignition",
    tier:        "IGNITION",
    price:       "$350",                       // ← EDIT PRICE
    period:      "one-time",
    tagline:     "The spark.",
    description: "For founders who need a precise mark built for dominance. Rapid, unforgettable, final.",
    features: [
      "Primary logo + 2 alternates",
      "Full vector source files (AI, SVG, PDF)",
      "Brand colour palette (Hex, RGB, CMYK)",
      "Typography selection + pairing guide",
      "5–7 day turnaround",
      "2 revision rounds",
    ],
    notIncluded: [
      "Brand guidelines document",
      "Sub-marks & icon system",
      "Motion / animation files",
    ],
    cta:       "START IGNITION",
    highlight: false,
  },
  {
    id:          "architect",
    tier:        "ARCHITECT",
    price:       "$750",                       // ← EDIT PRICE
    period:      "one-time",
    tagline:     "The full structure.",
    description: "A complete identity system. Every mark, every colour, every type rule locked into a brand bible.",
    features: [
      "Everything in Ignition",
      "Sub-marks & icon system",
      "Full brand guidelines PDF (20+ pages)",
      "Social media template set (8 formats)",
      "Business card + letterhead design",
      "Motion logo animation (MP4 + WEBM)",
      "10–14 day turnaround",
      "4 revision rounds",
    ],
    notIncluded: [
      "Packaging design",
      "Full campaign assets",
    ],
    cta:       "BECOME AN ARCHITECT",
    highlight: true,                           // ← this tier gets the gold border
  },
  {
    id:          "sovereign",
    tier:        "SOVEREIGN",
    price:       "$1,500+",                    // ← EDIT PRICE (custom quote)
    period:      "per project",
    tagline:     "Total visual dominion.",
    description: "Full visual direction engagement. We embed into your brand and build everything from the ground up.",
    features: [
      "Everything in Architect",
      "Packaging & print design",
      "Full campaign asset suite",
      "Environmental / signage concepts",
      "3–4 week engagement",
      "Unlimited revisions",
      "Post-delivery creative retainer offer",
      "Dedicated project channel",
    ],
    notIncluded: [],
    cta:       "REQUEST SOVEREIGN BRIEF",
    highlight: false,
  },
];

// ── FAQ — edit questions / answers freely ──────────────────
export const FAQ = [
  {
    q: "How does the process work?",
    a: "We start with a discovery call or brief submission. Once scoped, we move through Discovery → Direction → Design → Delivery. You're involved at every gate — nothing ships without your approval.",
  },
  {
    q: "Do you work with startups?",
    a: "Absolutely. Some of our strongest work has come from zero-to-one brand builds. Early-stage founders get the same precision and attention as established companies.",
  },
  {
    q: "What if I need something not listed?",
    a: "Use the Sovereign tier as a starting point or contact us directly. We scope custom engagements for campaigns, product launches, motion packages, and ongoing creative direction.",
  },
  {
    q: "How many revision rounds do I get?",
    a: "Ignition includes 2 rounds, Architect includes 4, and Sovereign is unlimited. Additional rounds outside scope are billed at a flat session rate.",
  },
  {
    q: "What files do I receive?",
    a: "All deliverables come in print-ready and screen-ready formats: AI, EPS, SVG, PDF, PNG (transparent), and WEBP. Motion files ship as MP4 and WEBM.",
  },
  {
    q: "Can I pay in instalments?",
    a: "Yes. Projects above $500 can be split into 50% upfront / 50% on delivery. Sovereign engagements can be structured across milestones.",
  },
  {
    q: "Do you do rush projects?",
    a: "Rush delivery (under 48 hours) is available at a 50% premium when our schedule allows. Contact us to check availability before purchasing.",
  },
  {
    q: "What is your turnaround time?",
    a: "Ignition: 5–7 days. Architect: 10–14 days. Sovereign: 3–4 weeks. Rush options available. All timelines start after brief approval and deposit receipt.",
  },
];
END_CONFIG
echo "✔  src/data/siteConfig.ts"

# =============================================================================
# 2. src/lib/router.ts
#    Zero-dependency hash router.
#    Pages use #/ prefix:  #/services  #/studio  #/work/1
#    Section anchors (#work, #about) stay as scroll targets on home.
# =============================================================================
cat << 'END_ROUTER' > src/lib/router.ts
import { useEffect, useState } from "react";

export type Route =
  | { page: "home" }
  | { page: "services" }
  | { page: "studio" }
  | { page: "case-study"; id: string }
  | { page: "not-found" };

// Module-level pending scroll — set before navigating home
let _pendingScroll: string | null = null;

export function consumePendingScroll(): string | null {
  const s = _pendingScroll;
  _pendingScroll = null;
  return s;
}

function parseHash(hash: string): Route {
  // Pages are prefixed with #/ — anything else is a section scroll on home
  if (!hash || hash === "#" || hash === "#/" || !hash.startsWith("#/")) {
    return { page: "home" };
  }
  const path = hash.slice(2); // strip #/
  if (path === "services")         return { page: "services" };
  if (path === "studio")           return { page: "studio" };
  if (path.startsWith("work/"))    return { page: "case-study", id: path.slice(5) };
  return { page: "not-found" };
}

export function useRouter(): Route {
  const [route, setRoute] = useState<Route>(() => parseHash(window.location.hash));
  useEffect(() => {
    const handler = () => setRoute(parseHash(window.location.hash));
    window.addEventListener("hashchange", handler);
    return () => window.removeEventListener("hashchange", handler);
  }, []);
  return route;
}

/** Navigate to a page route */
export function navigatePage(path: string) {
  window.location.hash = `#/${path}`;
  window.scrollTo({ top: 0 });
}

/** Navigate to home then scroll to a section */
export function navigateSection(sectionId: string) {
  _pendingScroll = sectionId;
  if (parseHash(window.location.hash).page !== "home") {
    window.location.hash = "#";
    window.scrollTo({ top: 0 });
  } else {
    setTimeout(() => {
      document.getElementById(sectionId)?.scrollIntoView({ behavior: "smooth" });
    }, 60);
    _pendingScroll = null;
  }
}
END_ROUTER
echo "✔  src/lib/router.ts"

# =============================================================================
# 3. src/data/portfolioData.ts
#    Extended with optional caseStudy field on first 4 items.
#    All other items unchanged. Easily extendable.
# =============================================================================
cat << 'END_PORTFOLIO' > src/data/portfolioData.ts
export type Category = "Flyers" | "Logos" | "Brand Identity";

export interface CaseStudy {
  client:   string;
  year:     string;
  tags:     string[];
  brief:    string;
  approach: string;
  outcome:  string;
}

export interface PortfolioItem {
  id:          string;
  title:       string;
  category:    Category;
  imagePath:   string;
  description?: string;
  tall?:       boolean;
  caseStudy?:  CaseStudy;
}

export const portfolio: PortfolioItem[] = [
  {
    id: "1", title: "Genisys Core", category: "Flyers",
    imagePath: "https://i.ibb.co/RG3hm314/A-high-resolution-full-bleed-202604231850-jpeg-2.jpg",
    description: "The final artifact. The intersection of code, art, and absolute vision.", tall: true,
    caseStudy: {
      client: "Genisys Internal", year: "2025",
      tags: ["Brand Identity", "Flyer", "Cinematic"],
      brief: "Create a self-promotional piece that demonstrates the studio's full visual range — dark, precise, and immediately recognisable as Genisys.",
      approach: "We built the piece from a single constraint: every element must be able to stand alone. The typography anchors the layout; the texture system adds depth without noise. Three rounds of negative-space refinement produced the final composition.",
      outcome: "The piece became the studio's primary calling card. It has been referenced by three separate clients as the reason they made first contact.",
    },
  },
  {
    id: "2", title: "Overdrive", category: "Brand Identity",
    imagePath: "https://i.ibb.co/q3KsDf80/A-high-resolution-full-bleed-202604231851-jpeg.jpg",
    description: "Pushing the brand engine into the red. Relentless forward momentum.",
    caseStudy: {
      client: "Voltage Syndicate", year: "2025",
      tags: ["Brand Identity", "Logo", "Motion"],
      brief: "Voltage Syndicate needed a brand overhaul that matched their aggressive market positioning — a creative collective launching into the events industry.",
      approach: "The primary mark is built around a tension between the static and the kinetic. The custom letterforms are drawn with deliberate weight imbalance — stable at rest, explosive in motion. The brand colour system uses a near-black base with a single volt-yellow accent deployed sparingly.",
      outcome: "The brand launched at their flagship event to immediate industry attention. Two competitor agencies cited the identity as a benchmark within 60 days of release.",
    },
  },
  {
    id: "3", title: "Aftermath", category: "Flyers",
    imagePath: "https://i.ibb.co/bMtSFXry/A-high-resolution-full-bleed-202604231850-jpeg-1.jpg",
    description: "What remains when the dust settles. Stark, beautiful devastation.", tall: true,
    caseStudy: {
      client: "Phantom Thread Agency", year: "2025",
      tags: ["Flyer", "Campaign", "Event"],
      brief: "A one-night underground event needed a flyer system that would circulate on social media and feel like an artefact — not marketing material.",
      approach: "Treated the brief like a film poster commission. The composition is cinematic and asymmetric. Distressed texture layers give the piece physical weight. Typography was hand-tracked for maximum visual tension at both full-size and thumbnail scale.",
      outcome: "The event sold out in 18 hours. The flyer was shared 340+ times organically. Three promoters commissioned follow-up work directly from seeing the flyer in circulation.",
    },
  },
  {
    id: "4", title: "Sigma", category: "Logos",
    imagePath: "https://i.ibb.co/4gwQBF09/A-high-resolution-full-bleed-202604231850-jpeg.jpg",
    description: "The sum total of all visual elements functioning perfectly together.",
    caseStudy: {
      client: "Cobalt Nexus", year: "2026",
      tags: ["Logo", "Mark Design", "Identity"],
      brief: "A fintech startup entering a crowded market needed a mark that would read as established, authoritative, and innovative — simultaneously.",
      approach: "The Sigma mark abstracts the Greek letter into a modular geometric form. It works at 16px favicon scale and billboard scale without modification. The construction is based on a 12-unit grid — every relationship in the mark is mathematically derived.",
      outcome: "Cobalt Nexus used the mark on their Series A deck. Investors cited 'professional brand presence' as a differentiating factor in the funding conversation.",
    },
  },
  { id: "5",  title: "Rogue State",       category: "Flyers",         imagePath: "https://i.ibb.co/bgM3KJ15/A-high-resolution-full-bleed-202604231849-jpeg-1.jpg", description: "Breaking every design rule with deliberate, calculated precision.", tall: true },
  { id: "6",  title: "Monolith",          category: "Brand Identity", imagePath: "https://i.ibb.co/kgxjZx41/A-high-resolution-full-bleed-202604231849-jpeg.jpg",   description: "A massive, immovable brand presence. You cannot ignore it." },
  { id: "7",  title: "Heatwave",          category: "Flyers",         imagePath: "https://i.ibb.co/jqqGh7f/A-high-resolution-full-bleed-202604231848-jpeg-1.jpg",  description: "Thermal imaging aesthetics pushed to their absolute limits.", tall: true },
  { id: "8",  title: "Sentinel",          category: "Logos",          imagePath: "https://i.ibb.co/Z628pYzL/A-high-resolution-full-bleed-202604231848-jpeg.jpg",   description: "A watchful, ever-present mark. Silent but authoritative." },
  { id: "9",  title: "Oasis",             category: "Flyers",         imagePath: "https://i.ibb.co/GQfSKCTK/A-high-resolution-full-bleed-202604231847-jpeg-1.jpg", description: "A moment of visual serenity amidst the chaos of the timeline.", tall: true },
  { id: "10", title: "Blueprint",         category: "Brand Identity", imagePath: "https://i.ibb.co/DDCk30Ps/A-high-resolution-full-bleed-202604231846-jpeg-1.jpg", description: "The foundational schematic for an entire visual empire." },
  { id: "11", title: "Shattered Glass",   category: "Flyers",         imagePath: "https://i.ibb.co/ksNC9GKd/A-high-resolution-full-bleed-202604231846-jpeg.jpg",   description: "Fractured perspectives coalescing into a single, unified narrative.", tall: true },
  { id: "12", title: "Vortex",            category: "Logos",          imagePath: "https://i.ibb.co/Y7nWDg4B/A-high-resolution-full-bleed-202604231908-jpeg.jpg",   description: "Drawing the eye inexorably toward the center of gravity." },
  { id: "13", title: "Requiem",           category: "Flyers",         imagePath: "https://i.ibb.co/0jBWKJGt/A-high-resolution-full-bleed-202604231902-jpeg-1.jpg", description: "A dark, operatic masterpiece. Heavy brass energy visualized.", tall: true },
  { id: "14", title: "Catalyst",          category: "Brand Identity", imagePath: "https://i.ibb.co/hFwN9wsn/A-high-resolution-full-bleed-202604231902-jpeg.jpg",   description: "The spark that ignites the cultural shift. A brand built for momentum." },
  { id: "15", title: "Nightcall",         category: "Flyers",         imagePath: "https://i.ibb.co/twq2rpQC/A-high-resolution-full-bleed-202604231901-jpeg-1.jpg", description: "Neon-drenched streets translated into a static cinematic frame.", tall: true },
  { id: "16", title: "Parallax",          category: "Logos",          imagePath: "https://i.ibb.co/xqQrH96M/A-high-resolution-full-bleed-202604231901-jpeg.jpg",   description: "A mark that shifts meaning depending on the angle of approach." },
  { id: "17", title: "Distortion Unit",   category: "Flyers",         imagePath: "https://i.ibb.co/9m3pxqwv/A-high-resolution-full-bleed-202604231852-jpeg-1.jpg", description: "Weaponizing glitch art to create an unforgettable visual rhythm.", tall: true },
  { id: "18", title: "Ironclad",          category: "Brand Identity", imagePath: "https://i.ibb.co/8ntvDZkX/A-high-resolution-full-bleed-202604231852-jpeg.jpg",   description: "Unbreakable brand guidelines forged in the fires of rapid iteration." },
];
END_PORTFOLIO
echo "✔  src/data/portfolioData.ts"

# =============================================================================
# 4. src/components/ClientLogoStrip.tsx
#    Auto-scrolling marquee of client brand marks.
#    Duplicates the list so the loop is seamless.
#    Pauses on hover. Reads from siteConfig.CLIENTS.
# =============================================================================
cat << 'END_CLIENTS' > src/components/ClientLogoStrip.tsx
import { CLIENTS } from "@/data/siteConfig";

export default function ClientLogoStrip() {
  const doubled = [...CLIENTS, ...CLIENTS];
  return (
    <section className="relative py-10 overflow-hidden border-y border-white/[0.05]">
      <div className="font-mono text-[9px] tracking-[0.45em] text-gold/50 text-center mb-6">
        TRUSTED BY CREATIVE LEADERS
      </div>
      <div className="relative overflow-hidden">
        <div className="flex gap-12 animate-marquee hover:[animation-play-state:paused] w-max">
          {doubled.map((c, i) => (
            <div
              key={i}
              className="flex items-center gap-3 flex-none select-none group"
            >
              <div
                className="w-9 h-9 rounded-lg grid place-items-center font-mono text-[10px] font-bold flex-none transition-all duration-300 group-hover:scale-110"
                style={{
                  background: "hsl(var(--gold) / 0.08)",
                  border:     "1px solid hsl(var(--gold) / 0.25)",
                  color:      "hsl(var(--gold) / 0.7)",
                }}
              >
                {c.abbr}
              </div>
              <span className="font-mono text-[11px] tracking-[0.2em] text-cream/50 group-hover:text-cream/80 transition-colors whitespace-nowrap">
                {c.name.toUpperCase()}
              </span>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
END_CLIENTS
echo "✔  src/components/ClientLogoStrip.tsx"

# =============================================================================
# 5. src/components/CtaSection.tsx
#    Full-width cinematic "ready to build?" section before footer.
# =============================================================================
cat << 'END_CTA' > src/components/CtaSection.tsx
import { motion } from "framer-motion";
import { useScramble } from "@/hooks/useScramble";
import { useMagnetic } from "@/hooks/useMagnetic";

export default function CtaSection() {
  const line1 = useScramble("READY TO BUILD", 1100);
  const line2 = useScramble("SOMETHING ICONIC?", 1300);
  const ref   = useMagnetic<HTMLButtonElement>(0.25);

  return (
    <section className="relative px-6 py-32 overflow-hidden">
      <div
        aria-hidden
        className="pointer-events-none absolute inset-0"
        style={{
          background: "radial-gradient(ellipse 70% 55% at 50% 50%, hsl(44 65% 35% / 0.12), transparent)",
        }}
      />
      <motion.div
        initial={{ opacity: 0, y: 32 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true, margin: "-80px" }}
        transition={{ duration: 0.7, ease: [0.7, 0, 0.3, 1] }}
        className="max-w-4xl mx-auto text-center"
      >
        <div className="font-mono text-[10px] tracking-[0.5em] text-gold/70 mb-6">
          NEW PROJECT INTAKE — OPEN
        </div>
        <h2 className="font-display font-black leading-[0.92] text-[11vw] sm:text-[90px] gold-text chromatic">
          {line1}
        </h2>
        <h2 className="font-display font-black leading-[0.92] text-[11vw] sm:text-[90px] text-cream/90 chromatic">
          {line2}
        </h2>
        <p className="mt-8 max-w-md mx-auto text-cream/65 text-sm sm:text-base leading-relaxed">
          We take on a limited number of projects each quarter to guarantee cinematic
          attention on every brief. Slots are finite.
        </p>
        <div className="mt-10 flex flex-col sm:flex-row items-center justify-center gap-4">
          <button
            ref={ref}
            onClick={() => window.dispatchEvent(new Event("open-contact"))}
            className="px-8 py-4 rounded-full glass-strong gold-border-glow font-mono text-xs tracking-[0.35em] text-gold hover:text-cream transition-colors animate-border-pulse"
          >
            START A PROJECT →
          </button>
          <a
            href="#/services"
            className="font-mono text-[11px] tracking-[0.3em] text-cream/55 hover:text-gold transition-colors"
          >
            VIEW PRICING FIRST
          </a>
        </div>
      </motion.div>
    </section>
  );
}
END_CTA
echo "✔  src/components/CtaSection.tsx"

# =============================================================================
# 6. src/components/CookieBanner.tsx
#    GDPR dismissible banner. Remembers choice via localStorage.
# =============================================================================
cat << 'END_COOKIE' > src/components/CookieBanner.tsx
import { useEffect, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";

const STORAGE_KEY = "genisys_cookie_ok";

export default function CookieBanner() {
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    try {
      if (!localStorage.getItem(STORAGE_KEY)) setVisible(true);
    } catch { setVisible(true); }
  }, []);

  const dismiss = () => {
    try { localStorage.setItem(STORAGE_KEY, "1"); } catch {}
    setVisible(false);
  };

  return (
    <AnimatePresence>
      {visible && (
        <motion.div
          initial={{ y: 80, opacity: 0 }}
          animate={{ y: 0,  opacity: 1 }}
          exit={{   y: 80, opacity: 0 }}
          transition={{ duration: 0.45, ease: [0.7, 0, 0.3, 1] }}
          className="fixed bottom-6 left-1/2 -translate-x-1/2 z-[9600] w-[calc(100vw-2rem)] max-w-xl"
        >
          <div className="glass-strong specular grain rounded-2xl px-5 py-4 flex flex-col sm:flex-row items-start sm:items-center gap-4">
            <p className="text-cream/70 text-xs leading-relaxed flex-1">
              This site uses cookies to analyse performance and improve your experience.
              No data is sold. Ever.{" "}
              <a href="#/studio" className="text-gold/80 hover:text-gold underline underline-offset-2">
                Privacy policy
              </a>
              .
            </p>
            <button
              onClick={dismiss}
              className="flex-none px-5 py-2 rounded-full glass gold-border-glow font-mono text-[10px] tracking-[0.3em] text-gold hover:text-cream transition-colors whitespace-nowrap"
            >
              GOT IT
            </button>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
END_COOKIE
echo "✔  src/components/CookieBanner.tsx"

# =============================================================================
# 7. src/components/BackToTop.tsx
#    Appears after scrolling 600px. Smooth scroll to top on click.
# =============================================================================
cat << 'END_BTT' > src/components/BackToTop.tsx
import { useEffect, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { ArrowUp } from "lucide-react";

export default function BackToTop() {
  const [show, setShow] = useState(false);

  useEffect(() => {
    const handler = () => setShow(window.scrollY > 600);
    window.addEventListener("scroll", handler, { passive: true });
    return () => window.removeEventListener("scroll", handler);
  }, []);

  return (
    <AnimatePresence>
      {show && (
        <motion.button
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          exit={{   opacity: 0, scale: 0.8 }}
          transition={{ duration: 0.3 }}
          onClick={() => window.scrollTo({ top: 0, behavior: "smooth" })}
          aria-label="Back to top"
          className="fixed bottom-6 right-6 z-[9400] w-11 h-11 grid place-items-center rounded-full glass-strong gold-border-glow"
          style={{ zIndex: 9400 }}
        >
          <ArrowUp className="w-4 h-4 text-gold" />
        </motion.button>
      )}
    </AnimatePresence>
  );
}
END_BTT
echo "✔  src/components/BackToTop.tsx"

# =============================================================================
# 8. src/components/FAQ.tsx
#    Accordion — reads from siteConfig.FAQ.
#    Click to expand/collapse. Animated height via Framer Motion.
# =============================================================================
cat << 'END_FAQ' > src/components/FAQ.tsx
import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Plus, Minus } from "lucide-react";
import { FAQ as FAQ_DATA } from "@/data/siteConfig";
import { useScramble } from "@/hooks/useScramble";

export default function FAQ() {
  const [open, setOpen] = useState<number | null>(null);
  const heading = useScramble("COMMON QUESTIONS", 1100);

  return (
    <section id="faq" className="relative px-4 sm:px-8 py-24">
      <div className="max-w-3xl mx-auto">
        <div className="font-mono text-[10px] tracking-[0.4em] text-gold/80 mb-2">
          QUICK ANSWERS
        </div>
        <h2 className="font-display font-black text-4xl sm:text-5xl gold-text chromatic mb-10">
          {heading}
        </h2>

        <div className="space-y-3">
          {FAQ_DATA.map((item, i) => (
            <div
              key={i}
              className="glass specular grain rounded-2xl overflow-hidden"
            >
              <button
                onClick={() => setOpen(open === i ? null : i)}
                className="w-full flex items-center justify-between gap-4 px-6 py-5 text-left"
              >
                <span className="text-cream font-semibold text-sm sm:text-base leading-snug">
                  {item.q}
                </span>
                <span className="flex-none w-7 h-7 grid place-items-center rounded-full"
                  style={{ background: "hsl(var(--gold)/0.1)", border: "1px solid hsl(var(--gold)/0.3)" }}>
                  {open === i
                    ? <Minus className="w-3 h-3 text-gold" />
                    : <Plus  className="w-3 h-3 text-gold" />
                  }
                </span>
              </button>

              <AnimatePresence initial={false}>
                {open === i && (
                  <motion.div
                    key="content"
                    initial={{ height: 0, opacity: 0 }}
                    animate={{ height: "auto", opacity: 1 }}
                    exit={{   height: 0, opacity: 0 }}
                    transition={{ duration: 0.35, ease: [0.7, 0, 0.3, 1] }}
                    style={{ overflow: "hidden" }}
                  >
                    <div className="px-6 pb-5 text-cream/65 text-sm leading-relaxed border-t border-white/[0.05] pt-4">
                      {item.a}
                    </div>
                  </motion.div>
                )}
              </AnimatePresence>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
END_FAQ
echo "✔  src/components/FAQ.tsx"

# =============================================================================
# 9. src/pages/HomePage.tsx
#    All home sections in one place. Handles pending scroll from router.
# =============================================================================
cat << 'END_HOME' > src/pages/HomePage.tsx
import { useEffect } from "react";
import { consumePendingScroll } from "@/lib/router";
import Hero            from "@/components/Hero";
import ClientLogoStrip from "@/components/ClientLogoStrip";
import Gallery         from "@/components/Gallery";
import Stats           from "@/components/Stats";
import About           from "@/components/About";
import Testimonials    from "@/components/Testimonials";
import Process         from "@/components/Process";
import CtaSection      from "@/components/CtaSection";
import FAQ             from "@/components/FAQ";
import Footer          from "@/components/Footer";

interface Props { onContact: () => void; }

export default function HomePage({ onContact }: Props) {
  useEffect(() => {
    const target = consumePendingScroll();
    if (target) {
      const attempt = (tries: number) => {
        const el = document.getElementById(target);
        if (el) { el.scrollIntoView({ behavior: "smooth" }); return; }
        if (tries > 0) setTimeout(() => attempt(tries - 1), 80);
      };
      attempt(5);
    }
  }, []);

  return (
    <>
      <Hero />
      <ClientLogoStrip />
      <Gallery />
      <Stats />
      <About />
      <Testimonials />
      <Process />
      <CtaSection />
      <FAQ />
      <Footer onContact={onContact} />
    </>
  );
}
END_HOME
echo "✔  src/pages/HomePage.tsx"

# =============================================================================
# 10. src/pages/ServicesPage.tsx
#     Pricing tiers from siteConfig. Gold-bordered highlight tier.
#     Feature list with checkmarks. CTA to contact modal.
# =============================================================================
cat << 'END_SERVICES' > src/pages/ServicesPage.tsx
import { motion } from "framer-motion";
import { Check, X, ArrowLeft } from "lucide-react";
import { useScramble } from "@/hooks/useScramble";
import { useMagnetic } from "@/hooks/useMagnetic";
import { PRICING, STUDIO } from "@/data/siteConfig";
import { navigateSection } from "@/lib/router";
import FAQ from "@/components/FAQ";
import Footer from "@/components/Footer";

function BackBtn() {
  const ref = useMagnetic<HTMLButtonElement>(0.3);
  return (
    <button
      ref={ref}
      onClick={() => navigateSection("top")}
      className="inline-flex items-center gap-2 font-mono text-[10px] tracking-[0.3em] text-gold/70 hover:text-gold transition-colors mb-10"
    >
      <ArrowLeft className="w-3 h-3" /> BACK TO HOME
    </button>
  );
}

interface Props { onContact: () => void; }

export default function ServicesPage({ onContact }: Props) {
  const heading = useScramble("SERVICES", 1100);

  return (
    <>
      <section className="relative px-4 sm:px-8 pt-32 pb-20 min-h-[60vh]">
        <div
          aria-hidden
          className="pointer-events-none absolute inset-0"
          style={{ background: "radial-gradient(ellipse 60% 50% at 50% 0%, hsl(44 65% 35% / 0.10), transparent)" }}
        />
        <div className="max-w-6xl mx-auto">
          <BackBtn />
          <div className="font-mono text-[10px] tracking-[0.5em] text-gold/70 mb-2">
            INVESTMENT TIERS
          </div>
          <h1 className="font-display font-black text-5xl sm:text-7xl gold-text chromatic mb-4">
            {heading}
          </h1>
          <p className="max-w-xl text-cream/65 text-sm sm:text-base leading-relaxed mb-4">
            Every engagement is fixed-price, clearly scoped, and built around one goal:
            a visual system that outlasts trends and outlasts competitors.
          </p>

          {/* Availability badge */}
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full glass mb-16"
            style={{ border: "1px solid hsl(var(--gold)/0.3)" }}>
            <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
            <span className="font-mono text-[10px] tracking-[0.3em] text-cream/80">
              {STUDIO.availability.accepting
                ? `NOW BOOKING · NEXT SLOT ${STUDIO.availability.nextSlot.toUpperCase()}`
                : "FULLY BOOKED · JOIN WAITLIST"}
            </span>
          </div>

          {/* Pricing grid */}
          <div className="grid sm:grid-cols-3 gap-5">
            {PRICING.map((tier, i) => (
              <motion.div
                key={tier.id}
                initial={{ opacity: 0, y: 28 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: i * 0.1, ease: [0.7, 0, 0.3, 1] }}
                className="relative flex flex-col rounded-2xl overflow-hidden"
                style={{
                  background: tier.highlight
                    ? "linear-gradient(145deg, hsl(0 0% 8%/0.98), hsl(0 0% 5%/0.98))"
                    : "linear-gradient(145deg, hsl(0 0% 6%/0.96), hsl(0 0% 3%/0.96))",
                  border: tier.highlight
                    ? "1px solid hsl(var(--gold)/0.55)"
                    : "1px solid hsl(0 0% 100%/0.07)",
                  boxShadow: tier.highlight
                    ? "0 0 40px hsl(var(--gold)/0.15), inset 0 1px 0 hsl(0 0% 100%/0.08)"
                    : "0 4px 24px hsl(0 0%  0%/0.6)",
                }}
              >
                {tier.highlight && (
                  <div className="absolute top-0 left-0 right-0 h-[2px]"
                    style={{ background: "linear-gradient(90deg, transparent, hsl(var(--gold)), transparent)" }} />
                )}
                {tier.highlight && (
                  <div className="absolute top-4 right-4 font-mono text-[9px] tracking-[0.3em] px-2 py-1 rounded-full"
                    style={{ background: "hsl(var(--gold)/0.15)", color: "hsl(var(--gold))", border: "1px solid hsl(var(--gold)/0.4)" }}>
                    MOST POPULAR
                  </div>
                )}
                <div className="p-6 pb-4">
                  <div className="font-mono text-[10px] tracking-[0.4em] text-gold/80 mb-3">
                    {tier.tier}
                  </div>
                  <div className="font-display font-black text-4xl gold-text mb-1">
                    {tier.price}
                  </div>
                  <div className="font-mono text-[10px] tracking-[0.2em] text-cream/50 mb-4">
                    {tier.period.toUpperCase()}
                  </div>
                  <p className="text-cream/60 text-xs leading-relaxed mb-1 italic">
                    {tier.tagline}
                  </p>
                  <p className="text-cream/70 text-sm leading-relaxed">
                    {tier.description}
                  </p>
                </div>

                <div className="px-6 pb-4 flex-1">
                  <div className="border-t border-white/[0.06] pt-4 space-y-2">
                    {tier.features.map(f => (
                      <div key={f} className="flex items-start gap-2.5 text-sm text-cream/75">
                        <Check className="w-3.5 h-3.5 text-gold mt-0.5 flex-none" />
                        <span>{f}</span>
                      </div>
                    ))}
                    {tier.notIncluded.map(f => (
                      <div key={f} className="flex items-start gap-2.5 text-sm text-cream/30">
                        <X className="w-3.5 h-3.5 mt-0.5 flex-none" />
                        <span>{f}</span>
                      </div>
                    ))}
                  </div>
                </div>

                <div className="p-6 pt-4">
                  <button
                    onClick={onContact}
                    className="w-full py-3.5 rounded-xl font-mono text-xs tracking-[0.3em] transition-all duration-300"
                    style={
                      tier.highlight
                        ? { background: "hsl(var(--gold))", color: "#000", fontWeight: 700 }
                        : { background: "transparent", border: "1px solid hsl(var(--gold)/0.4)", color: "hsl(var(--gold))" }
                    }
                  >
                    {tier.cta}
                  </button>
                </div>
              </motion.div>
            ))}
          </div>

          {/* Small print */}
          <p className="mt-8 text-center font-mono text-[10px] tracking-[0.2em] text-cream/35">
            ALL PRICES IN USD · PAYMENT VIA STRIPE, WISE, OR CRYPTO ·{" "}
            <a href={`mailto:${STUDIO.email}`} className="text-gold/50 hover:text-gold transition-colors">
              {STUDIO.email.toUpperCase()}
            </a>
          </p>
        </div>
      </section>

      <FAQ />
      <Footer onContact={onContact} />
    </>
  );
}
END_SERVICES
echo "✔  src/pages/ServicesPage.tsx"

# =============================================================================
# 11. src/pages/StudioPage.tsx
#     Full founder bio, philosophy, tools, values.
# =============================================================================
cat << 'END_STUDIO' > src/pages/StudioPage.tsx
import { motion } from "framer-motion";
import { ArrowLeft } from "lucide-react";
import { useScramble } from "@/hooks/useScramble";
import { useMagnetic } from "@/hooks/useMagnetic";
import { SOCIAL, STUDIO } from "@/data/siteConfig";
import { navigateSection } from "@/lib/router";
import Footer from "@/components/Footer";

const TOOLS = [
  "Adobe Illustrator", "Adobe Photoshop", "Adobe InDesign",
  "Figma", "After Effects", "Premiere Pro",
  "Blender", "Procreate", "Notion",
];

const VALUES = [
  { title: "Precision over speed",   body: "Every decision is intentional. We would rather deliver late and correct than fast and mediocre." },
  { title: "Restraint is a skill",   body: "The most powerful designs often feature what was removed. We know when to stop." },
  { title: "Cinematic standards",    body: "We evaluate our work the way a film critic evaluates a frame. Composition, tension, rhythm, impact." },
  { title: "No shortcuts. Ever.",    body: "Templates are not used. Stock is not used. Every mark is original, every system is bespoke." },
];

function BackBtn() {
  const ref = useMagnetic<HTMLButtonElement>(0.3);
  return (
    <button
      ref={ref}
      onClick={() => navigateSection("top")}
      className="inline-flex items-center gap-2 font-mono text-[10px] tracking-[0.3em] text-gold/70 hover:text-gold transition-colors mb-10"
    >
      <ArrowLeft className="w-3 h-3" /> BACK TO HOME
    </button>
  );
}

interface Props { onContact: () => void; }

export default function StudioPage({ onContact }: Props) {
  const heading = useScramble("THE STUDIO", 1100);

  return (
    <>
      <section className="relative px-4 sm:px-8 pt-32 pb-20">
        <div
          aria-hidden
          className="pointer-events-none absolute inset-0"
          style={{ background: "radial-gradient(ellipse 50% 40% at 20% 30%, hsl(44 65% 35% / 0.08), transparent)" }}
        />
        <div className="max-w-5xl mx-auto">
          <BackBtn />

          {/* ── Header ─────────────────────────────────────────────── */}
          <div className="font-mono text-[10px] tracking-[0.5em] text-gold/70 mb-2">STUDIO PROFILE</div>
          <h1 className="font-display font-black text-5xl sm:text-7xl gold-text chromatic mb-16">{heading}</h1>

          {/* ── Bio card ──────────────────────────────────────────── */}
          <motion.div
            initial={{ opacity: 0, y: 24 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, ease: [0.7, 0, 0.3, 1] }}
            className="relative glass-strong specular grain rounded-2xl p-8 sm:p-12 mb-12"
          >
            <div className="flex flex-col sm:flex-row gap-8 sm:gap-12">
              {/* Avatar / initials */}
              <div className="flex-none">
                <div
                  className="w-24 h-24 sm:w-32 sm:h-32 rounded-2xl grid place-items-center font-display font-black text-3xl sm:text-4xl gold-text"
                  style={{
                    background: "linear-gradient(145deg, hsl(44 70% 10%), hsl(44 50% 7%))",
                    border:     "1px solid hsl(var(--gold)/0.35)",
                    boxShadow:  "0 0 30px hsl(var(--gold)/0.15)",
                  }}
                >
                  JO
                </div>
                {/* Social icons row */}
                <div className="mt-4 flex gap-2 flex-wrap">
                  {Object.entries(SOCIAL).slice(0, 4).map(([platform, url]) => (
                    <a
                      key={platform}
                      href={url}
                      target="_blank"
                      rel="noopener noreferrer"
                      title={platform}
                      className="w-8 h-8 grid place-items-center rounded-lg font-mono text-[9px] transition-all duration-200 hover:scale-110"
                      style={{ background: "hsl(var(--gold)/0.08)", border: "1px solid hsl(var(--gold)/0.2)", color: "hsl(var(--gold)/0.7)" }}
                    >
                      {platform.slice(0, 2).toUpperCase()}
                    </a>
                  ))}
                </div>
              </div>

              <div>
                <div className="font-mono text-[10px] tracking-[0.4em] text-gold/70 mb-1">FOUNDER & CREATIVE DIRECTOR</div>
                <h2 className="font-display font-black text-2xl sm:text-3xl text-cream mb-4">John Osaze</h2>
                <p className="text-cream/70 text-sm sm:text-base leading-relaxed mb-4">
                  I started Genisys because I was tired of seeing brilliant brands get average design.
                  The work that ends up in museums, in cultural memory, on the walls of the most influential
                  spaces — that work was built with obsession. I wanted to bring that standard to every brief,
                  regardless of the client's size or industry.
                </p>
                <p className="text-cream/60 text-sm leading-relaxed">
                  Based in {STUDIO.location}. Working with founders, agencies, and cultural institutions worldwide.
                  Every project is handled personally. No outsourcing, no templates, no compromise.
                </p>
              </div>
            </div>
          </motion.div>

          {/* ── Values grid ───────────────────────────────────────── */}
          <div className="mb-14">
            <div className="font-mono text-[10px] tracking-[0.4em] text-gold/70 mb-6">CORE PRINCIPLES</div>
            <div className="grid sm:grid-cols-2 gap-4">
              {VALUES.map((v, i) => (
                <motion.div
                  key={i}
                  initial={{ opacity: 0, y: 16 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.5, delay: i * 0.08, ease: [0.7, 0, 0.3, 1] }}
                  className="relative glass specular grain rounded-2xl p-6"
                >
                  <div className="font-display font-black text-lg text-cream mb-2">{v.title}</div>
                  <p className="text-cream/60 text-sm leading-relaxed">{v.body}</p>
                </motion.div>
              ))}
            </div>
          </div>

          {/* ── Tools ─────────────────────────────────────────────── */}
          <div className="mb-14">
            <div className="font-mono text-[10px] tracking-[0.4em] text-gold/70 mb-6">TOOLS & STACK</div>
            <div className="flex flex-wrap gap-2">
              {TOOLS.map(tool => (
                <span
                  key={tool}
                  className="px-3 py-1.5 rounded-full font-mono text-[10px] tracking-[0.2em] text-cream/70"
                  style={{ background: "hsl(var(--gold)/0.07)", border: "1px solid hsl(var(--gold)/0.2)" }}
                >
                  {tool.toUpperCase()}
                </span>
              ))}
            </div>
          </div>

          {/* ── CTA ───────────────────────────────────────────────── */}
          <div className="text-center pt-8 border-t border-white/[0.06]">
            <p className="text-cream/60 text-sm mb-6">Want to work together?</p>
            <button
              onClick={onContact}
              className="px-8 py-3.5 rounded-full glass-strong gold-border-glow font-mono text-xs tracking-[0.35em] text-gold hover:text-cream transition-colors animate-border-pulse"
            >
              START A CONVERSATION
            </button>
          </div>
        </div>
      </section>
      <Footer onContact={onContact} />
    </>
  );
}
END_STUDIO
echo "✔  src/pages/StudioPage.tsx"

# =============================================================================
# 12. src/pages/CaseStudyPage.tsx
#     Full project deep-dive. Reads from portfolioData caseStudy field.
#     Prev/next navigation between projects that have case studies.
# =============================================================================
cat << 'END_CS' > src/pages/CaseStudyPage.tsx
import { useMemo } from "react";
import { motion } from "framer-motion";
import { ArrowLeft, ArrowRight, ChevronLeft } from "lucide-react";
import { useScramble } from "@/hooks/useScramble";
import { portfolio } from "@/data/portfolioData";
import { navigatePage, navigateSection } from "@/lib/router";
import Footer from "@/components/Footer";

interface Props { id: string; onContact: () => void; }

export default function CaseStudyPage({ id, onContact }: Props) {
  const item = useMemo(() => portfolio.find(p => p.id === id), [id]);

  // Only items with case studies get their own page
  const csList = useMemo(() => portfolio.filter(p => p.caseStudy), []);
  const csIndex = csList.findIndex(p => p.id === id);

  const heading = useScramble(item?.title ?? "NOT FOUND", 1100);

  if (!item || !item.caseStudy) {
    return (
      <div className="min-h-screen grid place-items-center">
        <div className="text-center px-6">
          <div className="font-mono text-[10px] tracking-[0.4em] text-gold/70 mb-4">CASE STUDY</div>
          <h1 className="font-display font-black text-4xl gold-text mb-6">Not Found</h1>
          <button
            onClick={() => navigateSection("work")}
            className="px-6 py-3 rounded-full glass-strong gold-border-glow font-mono text-xs tracking-[0.3em] text-gold"
          >
            VIEW ALL WORK
          </button>
        </div>
      </div>
    );
  }

  const cs = item.caseStudy;

  return (
    <>
      <section className="relative px-4 sm:px-8 pt-32 pb-20">
        <div
          aria-hidden
          className="pointer-events-none absolute inset-0 z-0"
          style={{ background: "radial-gradient(ellipse 55% 45% at 50% 15%, hsl(44 65% 30% / 0.10), transparent)" }}
        />
        <div className="max-w-5xl mx-auto relative z-10">

          {/* Back */}
          <button
            onClick={() => navigateSection("work")}
            className="inline-flex items-center gap-2 font-mono text-[10px] tracking-[0.3em] text-gold/70 hover:text-gold transition-colors mb-10"
          >
            <ChevronLeft className="w-3 h-3" /> ALL WORK
          </button>

          {/* Tags */}
          <div className="flex flex-wrap gap-2 mb-4">
            {cs.tags.map(tag => (
              <span
                key={tag}
                className="px-3 py-1 rounded-full font-mono text-[9px] tracking-[0.25em] text-gold/70"
                style={{ background: "hsl(var(--gold)/0.08)", border: "1px solid hsl(var(--gold)/0.2)" }}
              >
                {tag.toUpperCase()}
              </span>
            ))}
          </div>

          <div className="font-mono text-[10px] tracking-[0.4em] text-gold/70 mb-2">CASE STUDY</div>
          <h1 className="font-display font-black text-5xl sm:text-7xl gold-text chromatic mb-2">{heading}</h1>
          <div className="font-mono text-[10px] tracking-[0.3em] text-cream/40 mb-12">
            CLIENT: {cs.client.toUpperCase()} · {cs.year}
          </div>

          {/* Hero image */}
          <motion.div
            initial={{ opacity: 0, scale: 0.98 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.7, ease: [0.7, 0, 0.3, 1] }}
            className="rounded-2xl overflow-hidden glass-strong mb-16"
            style={{ maxHeight: "65vh" }}
          >
            <img
              src={item.imagePath}
              alt={item.title}
              className="w-full h-full object-cover"
              style={{ maxHeight: "65vh" }}
            />
          </motion.div>

          {/* 3-column narrative */}
          <div className="grid sm:grid-cols-3 gap-8 mb-16">
            {[
              { label: "THE BRIEF",    text: cs.brief },
              { label: "THE APPROACH", text: cs.approach },
              { label: "THE OUTCOME",  text: cs.outcome },
            ].map((section, i) => (
              <motion.div
                key={i}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.55, delay: 0.1 + i * 0.1, ease: [0.7, 0, 0.3, 1] }}
                className="relative glass specular grain rounded-2xl p-6"
              >
                <div className="font-mono text-[10px] tracking-[0.4em] text-gold/70 mb-3">
                  {section.label}
                </div>
                <p className="text-cream/70 text-sm leading-relaxed">{section.text}</p>
              </motion.div>
            ))}
          </div>

          {/* Prev / Next case studies */}
          {csList.length > 1 && (
            <div className="flex items-center justify-between gap-4 border-t border-white/[0.06] pt-8">
              {csIndex > 0 ? (
                <button
                  onClick={() => navigatePage(`work/${csList[csIndex - 1].id}`)}
                  className="inline-flex items-center gap-2 font-mono text-[10px] tracking-[0.3em] text-gold/70 hover:text-gold transition-colors"
                >
                  <ArrowLeft className="w-3 h-3" />
                  {csList[csIndex - 1].title.toUpperCase()}
                </button>
              ) : <div />}
              {csIndex < csList.length - 1 && (
                <button
                  onClick={() => navigatePage(`work/${csList[csIndex + 1].id}`)}
                  className="inline-flex items-center gap-2 font-mono text-[10px] tracking-[0.3em] text-gold/70 hover:text-gold transition-colors"
                >
                  {csList[csIndex + 1].title.toUpperCase()}
                  <ArrowRight className="w-3 h-3" />
                </button>
              )}
            </div>
          )}

          {/* CTA */}
          <div className="mt-16 text-center">
            <p className="text-cream/55 text-sm mb-5">Like what you see?</p>
            <button
              onClick={onContact}
              className="px-8 py-3.5 rounded-full glass-strong gold-border-glow font-mono text-xs tracking-[0.35em] text-gold hover:text-cream transition-colors animate-border-pulse"
            >
              START YOUR PROJECT
            </button>
          </div>
        </div>
      </section>
      <Footer onContact={onContact} />
    </>
  );
}
END_CS
echo "✔  src/pages/CaseStudyPage.tsx"

# =============================================================================
# 13. src/pages/NotFoundPage.tsx
# =============================================================================
cat << 'END_404' > src/pages/NotFoundPage.tsx
import { motion } from "framer-motion";
import { navigateSection } from "@/lib/router";
import { useScramble } from "@/hooks/useScramble";

export default function NotFoundPage() {
  const code = useScramble("404", 900);
  const msg  = useScramble("PAGE NOT FOUND", 1100);

  return (
    <section className="min-h-screen grid place-items-center px-6">
      <motion.div
        initial={{ opacity: 0, y: 24 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, ease: [0.7, 0, 0.3, 1] }}
        className="text-center max-w-md"
      >
        <div
          className="font-display font-black text-[22vw] sm:text-[160px] leading-none mb-4"
          style={{ color: "hsl(var(--gold)/0.12)" }}
          aria-hidden
        >
          {code}
        </div>
        <div className="font-mono text-[10px] tracking-[0.45em] text-gold/70 mb-3">SIGNAL LOST</div>
        <h1 className="font-display font-black text-3xl sm:text-4xl gold-text chromatic mb-4">{msg}</h1>
        <p className="text-cream/55 text-sm leading-relaxed mb-8">
          The page you're looking for doesn't exist or was moved.
          Head back to the studio.
        </p>
        <button
          onClick={() => navigateSection("top")}
          className="px-8 py-3 rounded-full glass-strong gold-border-glow font-mono text-xs tracking-[0.35em] text-gold hover:text-cream transition-colors"
        >
          RETURN HOME
        </button>
      </motion.div>
    </section>
  );
}
END_404
echo "✔  src/pages/NotFoundPage.tsx"

# =============================================================================
# 14. src/components/Navigation.tsx
#     Multi-page nav: HOME · WORK · SERVICES · STUDIO
#     Desktop: page indicators with active highlight.
#     Mobile overlay: full links + social row + CTA.
# =============================================================================
cat << 'END_NAV' > src/components/Navigation.tsx
import { useEffect, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Menu, X } from "lucide-react";
import { useScramble } from "@/hooks/useScramble";
import { useMagnetic } from "@/hooks/useMagnetic";
import { navigatePage, navigateSection, type Route } from "@/lib/router";
import { SOCIAL } from "@/data/siteConfig";

interface Props { route: Route; }

const PAGE_LINKS = [
  { label: "WORK",     action: () => navigateSection("work"),    page: "home" as const },
  { label: "SERVICES", action: () => navigatePage("services"),   page: "services" as const },
  { label: "STUDIO",   action: () => navigatePage("studio"),     page: "studio" as const },
  { label: "PROCESS",  action: () => navigateSection("process"), page: "home" as const },
];

const SOCIAL_LABELS: Record<string, string> = {
  instagram: "IG", twitter: "X", behance: "BE",
  dribbble: "DR", tiktok: "TK", linkedin: "LI",
  youtube: "YT", pinterest: "PI",
};

export default function Navigation({ route }: Props) {
  const brand   = useScramble("GENISYS", 900);
  const [open, setOpen] = useState(false);
  const menuRef = useMagnetic<HTMLButtonElement>(0.25);

  useEffect(() => {
    if (!open) return;
    const sw = window.innerWidth - document.documentElement.clientWidth;
    document.body.style.overflow     = "hidden";
    document.body.style.paddingRight = sw + "px";
    return () => { document.body.style.overflow = ""; document.body.style.paddingRight = ""; };
  }, [open]);

  // Close overlay on route change
  useEffect(() => { setOpen(false); }, [route]);

  const close = () => setOpen(false);

  const isActive = (link: typeof PAGE_LINKS[0]) => {
    if (link.page === "services" && route.page === "services") return true;
    if (link.page === "studio"   && route.page === "studio")   return true;
    return false;
  };

  return (
    <>
      <header className="fixed top-0 left-0 right-0 z-[70] flex items-center justify-between px-4 sm:px-8 pt-4">
        <button
          onClick={() => navigateSection("top")}
          className="font-display font-black text-base sm:text-lg gold-text tracking-tight"
        >
          {brand}
        </button>

        {/* Desktop */}
        <nav className="hidden sm:flex items-center gap-1 glass rounded-full px-3 py-1.5">
          {PAGE_LINKS.map(l => (
            <DesktopNavLink key={l.label} label={l.label} active={isActive(l)} onClick={l.action} />
          ))}
        </nav>

        {/* Mobile hamburger */}
        <button
          ref={menuRef}
          onClick={() => setOpen(true)}
          aria-label="Open navigation"
          className="sm:hidden grid place-items-center w-10 h-10 rounded-full glass gold-border-glow"
        >
          <Menu className="w-4 h-4 text-gold" />
        </button>
      </header>

      {/* Mobile overlay */}
      <AnimatePresence>
        {open && (
          <motion.div
            initial={{ opacity: 0, clipPath: "circle(0% at 95% 5%)" }}
            animate={{ opacity: 1, clipPath: "circle(150% at 95% 5%)" }}
            exit={{   opacity: 0, clipPath: "circle(0% at 95% 5%)" }}
            transition={{ duration: 0.5, ease: [0.7, 0, 0.3, 1] }}
            className="fixed inset-0 z-[150] flex flex-col justify-between py-16 px-8 sm:hidden"
            style={{ background: "rgba(0,0,0,0.97)", backdropFilter: "blur(28px)", WebkitBackdropFilter: "blur(28px)" }}
          >
            <button
              onClick={close}
              aria-label="Close navigation"
              className="absolute top-5 right-5 grid place-items-center w-11 h-11 rounded-full glass-strong gold-border-glow"
            >
              <X className="w-5 h-5 text-gold" />
            </button>

            {/* Page links */}
            <nav className="flex flex-col gap-8 mt-8">
              {PAGE_LINKS.map((l, i) => (
                <motion.button
                  key={l.label}
                  onClick={() => { l.action(); close(); }}
                  initial={{ opacity: 0, x: -30 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ duration: 0.4, delay: 0.1 + i * 0.08, ease: [0.7, 0, 0.3, 1] }}
                  className="font-display font-black text-5xl gold-text tracking-tight text-left"
                >
                  {l.label}
                </motion.button>
              ))}
            </nav>

            {/* Bottom: CTA + social row */}
            <div className="space-y-6">
              <motion.button
                initial={{ opacity: 0, y: 16 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.4, delay: 0.5, ease: [0.7, 0, 0.3, 1] }}
                onClick={() => { close(); window.dispatchEvent(new Event("open-contact")); }}
                className="w-full py-3 rounded-full glass-strong gold-border-glow font-mono text-xs tracking-[0.3em] text-gold"
              >
                START A PROJECT
              </motion.button>

              {/* Social icons */}
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.6 }}
                className="flex flex-wrap gap-3"
              >
                {Object.entries(SOCIAL).map(([platform, url]) => (
                  <a
                    key={platform}
                    href={url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="w-9 h-9 grid place-items-center rounded-lg font-mono text-[10px] font-bold transition-all hover:scale-110"
                    style={{ background: "hsl(var(--gold)/0.08)", border: "1px solid hsl(var(--gold)/0.2)", color: "hsl(var(--gold)/0.7)" }}
                  >
                    {SOCIAL_LABELS[platform] ?? platform.slice(0, 2).toUpperCase()}
                  </a>
                ))}
              </motion.div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}

function DesktopNavLink({ label, active, onClick }: { label: string; active: boolean; onClick: () => void }) {
  const text = useScramble(label, 700);
  const ref  = useMagnetic<HTMLButtonElement>(0.3);
  return (
    <button
      ref={ref}
      onClick={onClick}
      className={
        "font-mono text-[11px] tracking-[0.35em] transition-colors px-2 py-1 " +
        (active ? "text-gold" : "text-cream/80 hover:text-gold")
      }
    >
      {text}
    </button>
  );
}
END_NAV
echo "✔  src/components/Navigation.tsx"

# =============================================================================
# 15. src/components/Hero.tsx
#     Availability badge from siteConfig. Otherwise unchanged.
# =============================================================================
cat << 'END_HERO' > src/components/Hero.tsx
import { useScramble }      from "@/hooks/useScramble";
import { useGyroscopeTilt } from "@/contexts/GyroscopeContext";
import { useMagnetic }      from "@/hooks/useMagnetic";
import { useReducedMotion } from "@/hooks/useReducedMotion";
import { STUDIO }           from "@/data/siteConfig";
import { navigatePage }     from "@/lib/router";

export default function Hero() {
  const t       = useGyroscopeTilt();
  const reduced = useReducedMotion();
  const eyebrow = useScramble("STUDIO // EST. CINEMA", 1200);
  const title1  = useScramble("OPERATIC", 1100);
  const title2  = useScramble("BRAND SYSTEMS", 1400);
  const sub     = useScramble("Pitch-black aesthetics. Metallic gold execution.", 1600);
  const ctaRef  = useMagnetic<HTMLAnchorElement>(0.3);

  return (
    <section id="top" className="relative min-h-[100dvh] grid place-items-center px-6 pt-28 pb-32">
      <div
        className="text-center max-w-4xl"
        style={{
          transform: reduced ? undefined : `translate3d(${t.x * -10}px, ${t.y * -8}px, 0)`,
        }}
      >
        {/* Availability badge */}
        <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full glass mb-6"
          style={{ border: "1px solid hsl(var(--gold)/0.25)" }}>
          <span className={
            "w-1.5 h-1.5 rounded-full " +
            (STUDIO.availability.accepting ? "bg-emerald-400 animate-pulse" : "bg-red-400")
          } />
          <span className="font-mono text-[9px] tracking-[0.35em] text-cream/65">
            {STUDIO.availability.accepting
              ? `NOW BOOKING · NEXT SLOT ${STUDIO.availability.nextSlot.toUpperCase()}`
              : "FULLY BOOKED — JOIN WAITLIST"}
          </span>
        </div>

        <div className="font-mono text-[10px] sm:text-xs tracking-[0.5em] text-gold/70">{eyebrow}</div>
        <h1 className="mt-6 font-display font-black tracking-tight leading-[0.95] text-[15vw] sm:text-[110px] gold-text chromatic">
          {title1}
        </h1>
        <h1 className="font-display font-black tracking-tight leading-[0.95] text-[15vw] sm:text-[110px] text-cream/90 chromatic">
          {title2}
        </h1>
        <p className="mt-8 text-cream/70 text-sm sm:text-base max-w-md mx-auto">{sub}</p>

        <div className="mt-10 flex flex-col sm:flex-row items-center justify-center gap-4">
          <a
            ref={ctaRef}
            href="#work"
            data-magnetic
            className="inline-flex items-center gap-3 px-7 py-3 rounded-full glass-strong gold-border-glow font-mono text-xs tracking-[0.3em] text-gold hover:text-cream transition-colors"
          >
            ENTER THE WORK →
          </a>
          <button
            onClick={() => navigatePage("services")}
            className="font-mono text-[11px] tracking-[0.3em] text-cream/50 hover:text-gold transition-colors"
          >
            VIEW PRICING
          </button>
        </div>
      </div>
    </section>
  );
}
END_HERO
echo "✔  src/components/Hero.tsx"

# =============================================================================
# 16. src/components/Footer.tsx
#     Full social grid (all 8 platforms) + sitemap links + page links.
# =============================================================================
cat << 'END_FOOTER' > src/components/Footer.tsx
import { useScramble }  from "@/hooks/useScramble";
import { haptic }       from "@/lib/haptics";
import { SOCIAL, STUDIO } from "@/data/siteConfig";
import { navigatePage, navigateSection } from "@/lib/router";

const SOCIAL_LABELS: Record<string, string> = {
  instagram: "Instagram", twitter: "X / Twitter", behance: "Behance",
  dribbble: "Dribbble", tiktok: "TikTok", linkedin: "LinkedIn",
  youtube: "YouTube", pinterest: "Pinterest",
};

const SOCIAL_SHORT: Record<string, string> = {
  instagram: "IG", twitter: "X", behance: "BE",
  dribbble: "DR", tiktok: "TK", linkedin: "LI",
  youtube: "YT", pinterest: "PI",
};

interface Props { onContact: () => void; }

export default function Footer({ onContact }: Props) {
  const sign = useScramble("GENISYS GRAPHICS // 2026", 900);

  const handleContact = () => { haptic([10, 30, 15]); onContact(); };

  return (
    <footer className="relative px-6 pt-16 pb-28 mt-4">
      <div className="max-w-5xl mx-auto">

        {/* ── Top row ─────────────────────────────────────────────── */}
        <div className="grid sm:grid-cols-3 gap-10 border-t border-white/[0.06] pt-10 mb-10">

          {/* Brand column */}
          <div>
            <div className="font-display font-black text-2xl gold-text mb-2">Genisys</div>
            <div className="font-mono text-[9px] tracking-[0.3em] text-cream/45 leading-relaxed mb-4">
              OPERATIC BRAND &amp; IDENTITY DESIGN<br />
              {STUDIO.location.toUpperCase()}
            </div>
            <a
              href={`mailto:${STUDIO.email}`}
              className="font-mono text-[10px] tracking-[0.2em] text-gold/65 hover:text-gold transition-colors"
            >
              {STUDIO.email}
            </a>
          </div>

          {/* Site map */}
          <div>
            <div className="font-mono text-[9px] tracking-[0.4em] text-gold/60 mb-4">NAVIGATE</div>
            <div className="space-y-2.5">
              {[
                { label: "Home",     fn: () => navigateSection("top") },
                { label: "Work",     fn: () => navigateSection("work") },
                { label: "Services", fn: () => navigatePage("services") },
                { label: "Studio",   fn: () => navigatePage("studio") },
                { label: "Process",  fn: () => navigateSection("process") },
                { label: "FAQ",      fn: () => navigateSection("faq") },
              ].map(link => (
                <button
                  key={link.label}
                  onClick={link.fn}
                  className="block font-mono text-[10px] tracking-[0.2em] text-cream/55 hover:text-gold transition-colors"
                >
                  {link.label.toUpperCase()}
                </button>
              ))}
            </div>
          </div>

          {/* Social column */}
          <div>
            <div className="font-mono text-[9px] tracking-[0.4em] text-gold/60 mb-4">FOLLOW THE WORK</div>
            <div className="grid grid-cols-4 gap-2">
              {Object.entries(SOCIAL).map(([platform, url]) => (
                <a
                  key={platform}
                  href={url}
                  target="_blank"
                  rel="noopener noreferrer"
                  title={SOCIAL_LABELS[platform]}
                  className="aspect-square grid place-items-center rounded-xl font-mono text-[10px] font-bold transition-all duration-200 hover:scale-110 hover:border-gold/50"
                  style={{
                    background: "hsl(var(--gold)/0.07)",
                    border:     "1px solid hsl(var(--gold)/0.18)",
                    color:      "hsl(var(--gold)/0.65)",
                  }}
                >
                  {SOCIAL_SHORT[platform]}
                </a>
              ))}
            </div>
            <p className="mt-3 font-mono text-[9px] tracking-[0.2em] text-cream/30 leading-relaxed">
              Update handles in<br />
              <span className="text-gold/40">src/data/siteConfig.ts</span>
            </p>
          </div>
        </div>

        {/* ── Bottom row ──────────────────────────────────────────── */}
        <div className="flex flex-col sm:flex-row items-center justify-between gap-4 border-t border-white/[0.04] pt-6">
          <div className="font-mono text-[9px] tracking-[0.3em] text-cream/35">
            © 2026 GENISYS GRAPHICS. ALL RIGHTS RESERVED.
          </div>
          <div className="flex items-center gap-4">
            <div className="font-mono text-[9px] tracking-[0.2em] text-cream/35">
              {sign}
            </div>
            <button
              onClick={handleContact}
              className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full glass-strong gold-border-glow font-mono text-[10px] tracking-[0.35em] text-gold hover:text-cream transition-colors animate-border-pulse"
            >
              CONTACT <span className="text-gold/60">→</span>
            </button>
          </div>
        </div>
      </div>
    </footer>
  );
}
END_FOOTER
echo "✔  src/components/Footer.tsx"

# =============================================================================
# 17. src/App.tsx — Router integration + all new components
# =============================================================================
cat << 'END_APP' > src/App.tsx
import { useEffect, useState }  from "react";
import ErrorBoundary             from "@/components/ErrorBoundary";
import LiquidCanvas              from "@/components/LiquidCanvas";
import EmberParticles            from "@/components/EmberParticles";
import MagneticCursor            from "@/components/MagneticCursor";
import GoldDustTrail             from "@/components/GoldDustTrail";
import Preloader                 from "@/components/Preloader";
import VibeToggle                from "@/components/VibeToggle";
import Navigation                from "@/components/Navigation";
import ContactModal              from "@/components/ContactModal";
import Letterbox                 from "@/components/Letterbox";
import AuroraBackground          from "@/components/AuroraBackground";
import ScrollVignette            from "@/components/ScrollVignette";
import CookieBanner              from "@/components/CookieBanner";
import BackToTop                 from "@/components/BackToTop";
import HomePage                  from "@/pages/HomePage";
import ServicesPage              from "@/pages/ServicesPage";
import StudioPage                from "@/pages/StudioPage";
import CaseStudyPage             from "@/pages/CaseStudyPage";
import NotFoundPage              from "@/pages/NotFoundPage";
import { useLenis }              from "@/hooks/useLenis";
import { useVhFix }              from "@/hooks/useVhFix";
import { useReducedMotion }      from "@/hooks/useReducedMotion";
import { GyroscopeProvider }     from "@/contexts/GyroscopeContext";
import { getDeviceTier }         from "@/lib/deviceTier";
import { useRouter }             from "@/lib/router";

const TIER = getDeviceTier();

export default function App() {
  const [loaded, setLoaded]    = useState(false);
  const [contactOpen, setOpen] = useState(false);
  const reduced = useReducedMotion();
  const route   = useRouter();
  useLenis();
  useVhFix();

  useEffect(() => {
    const h = () => setOpen(true);
    window.addEventListener("open-contact", h);
    return () => window.removeEventListener("open-contact", h);
  }, []);

  const showEmbers   = !reduced && TIER !== "low";
  const showGoldDust = !reduced && TIER === "high";
  const showAurora   = !reduced && TIER !== "low";

  const renderPage = () => {
    switch (route.page) {
      case "home":
        return <HomePage onContact={() => setOpen(true)} />;
      case "services":
        return <ServicesPage onContact={() => setOpen(true)} />;
      case "studio":
        return <StudioPage onContact={() => setOpen(true)} />;
      case "case-study":
        return <CaseStudyPage id={route.id} onContact={() => setOpen(true)} />;
      default:
        return <NotFoundPage />;
    }
  };

  return (
    <ErrorBoundary>
      <GyroscopeProvider>
        {showAurora   && <AuroraBackground />}
        <LiquidCanvas />
        {showEmbers   && <EmberParticles />}
        {showGoldDust && <GoldDustTrail />}

        <MagneticCursor />
        <Letterbox />
        <ScrollVignette />
        <CookieBanner />
        <BackToTop />

        {!loaded && <Preloader onDone={() => setLoaded(true)} />}
        <VibeToggle />

        <div className="relative z-10">
          <Navigation route={route} />
          <main>{renderPage()}</main>
        </div>

        <ContactModal open={contactOpen} onClose={() => setOpen(false)} />
      </GyroscopeProvider>
    </ErrorBoundary>
  );
}
END_APP
echo "✔  src/App.tsx"

# =============================================================================
# 18. src/index.css — add marquee keyframe for ClientLogoStrip
# =============================================================================
if ! grep -q "animate-marquee" src/index.css; then
  cat << 'END_MARQUEE' >> src/index.css

/* ClientLogoStrip marquee */
@keyframes marquee {
  0%   { transform: translateX(0); }
  100% { transform: translateX(-50%); }
}
.animate-marquee {
  animation: marquee 28s linear infinite;
}
END_MARQUEE
  echo "✔  src/index.css  (marquee keyframe appended)"
fi

# =============================================================================
# 19. index.html — JSON-LD structured data + canonical
# =============================================================================
cat << 'END_HTML' > index.html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover" />
    <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
    <link rel="manifest" href="/manifest.json" />
    <meta name="theme-color" content="#000000" />

    <title>Genisys Graphics — Operatic Brand &amp; Identity Design</title>
    <meta name="description" content="Genisys Graphics is a high-end design studio crafting operatic brand identities, flyers, and logo systems. Pitch-black aesthetics. Metallic gold execution." />
    <link rel="canonical" href="https://genisys-portfolio.vercel.app/" />

    <meta property="og:type"        content="website" />
    <meta property="og:title"       content="Genisys Graphics — Operatic Brand &amp; Identity Design" />
    <meta property="og:description" content="High-end design studio. Pitch-black aesthetics. Metallic gold execution." />
    <meta property="og:image"       content="https://genisys-portfolio.vercel.app/og-preview.jpg" />
    <meta property="og:url"         content="https://genisys-portfolio.vercel.app/" />

    <meta name="twitter:card"        content="summary_large_image" />
    <meta name="twitter:title"       content="Genisys Graphics" />
    <meta name="twitter:description" content="Operatic Brand &amp; Identity Design" />
    <meta name="twitter:image"       content="https://genisys-portfolio.vercel.app/og-preview.jpg" />

    <!-- JSON-LD structured data -->
    <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "ProfessionalService",
      "name": "Genisys Graphics",
      "description": "Operatic brand and identity design studio specialising in logos, brand systems, and cinematic flyers.",
      "url": "https://genisys-portfolio.vercel.app/",
      "logo": "https://genisys-portfolio.vercel.app/favicon.svg",
      "image": "https://genisys-portfolio.vercel.app/og-preview.jpg",
      "email": "hello@genisysgraphics.com",
      "areaServed": "Worldwide",
      "priceRange": "$350 - $1500+",
      "serviceType": [
        "Logo Design",
        "Brand Identity",
        "Visual Direction",
        "Flyer Design",
        "Packaging Design"
      ],
      "sameAs": [
        "https://instagram.com/genisysgraphics",
        "https://behance.net/genisysgraphics",
        "https://dribbble.com/genisysgraphics"
      ]
    }
    </script>

    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;600;700;800;900&family=Inter:wght@400;700&display=swap" rel="stylesheet" />
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
END_HTML
echo "✔  index.html  (JSON-LD structured data)"

# =============================================================================
# Bump version
# =============================================================================
if command -v node &>/dev/null; then
  node -e "
    const fs = require('fs');
    const p  = JSON.parse(fs.readFileSync('package.json','utf8'));
    p.version = '3.2.0';
    fs.writeFileSync('package.json', JSON.stringify(p,null,2)+'\n');
  " && echo "✔  package.json → 3.2.0"
fi

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🎬  Genisys Graphics V3.2 \"MULTI-PAGE\" — patch complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  NEW PAGES  (navigate via nav or hash URLs)"
echo "  ──────────"
echo "  /         Home — existing sections + ClientLogoStrip + CtaSection + FAQ"
echo "  #/services Services — 3 pricing tiers, features, FAQ"
echo "  #/studio   Studio — founder bio, values, tools"
echo "  #/work/1   Case study — per-project deep dive (items 1-4 have data)"
echo "  404        Branded not-found page"
echo ""
echo "  NEW FILES"
echo "  ─────────"
echo "  src/data/siteConfig.ts   ← EDIT PRICING, SOCIALS, AVAILABILITY HERE"
echo "  src/lib/router.ts        Hash-based SPA router, zero dependencies"
echo "  src/pages/HomePage.tsx"
echo "  src/pages/ServicesPage.tsx"
echo "  src/pages/StudioPage.tsx"
echo "  src/pages/CaseStudyPage.tsx"
echo "  src/pages/NotFoundPage.tsx"
echo "  src/components/ClientLogoStrip.tsx  Auto-scroll client marquee"
echo "  src/components/CtaSection.tsx       Full-width project CTA"
echo "  src/components/CookieBanner.tsx     GDPR banner (localStorage)"
echo "  src/components/BackToTop.tsx        Scroll-triggered floating btn"
echo "  src/components/FAQ.tsx              Accordion from siteConfig"
echo ""
echo "  MODIFIED FILES"
echo "  ──────────────"
echo "  Navigation.tsx   Multi-page links + social row in mobile overlay"
echo "  Hero.tsx         Availability badge from siteConfig"
echo "  Footer.tsx       8-platform social grid + sitemap + page links"
echo "  App.tsx          Router integration + CookieBanner + BackToTop"
echo "  index.html       JSON-LD ProfessionalService schema"
echo ""
echo "  QUICK EDIT GUIDE"
echo "  ────────────────"
echo "  Pricing tiers     → src/data/siteConfig.ts  PRICING array"
echo "  Social links      → src/data/siteConfig.ts  SOCIAL object"
echo "  Availability      → src/data/siteConfig.ts  STUDIO.availability"
echo "  Client names      → src/data/siteConfig.ts  CLIENTS array"
echo "  FAQ answers       → src/data/siteConfig.ts  FAQ array"
echo "  Case study copy   → src/data/portfolioData.ts  caseStudy fields"
echo ""
echo "  Originals backed up → $BACKUP"
echo "  Run:  npm run dev"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
