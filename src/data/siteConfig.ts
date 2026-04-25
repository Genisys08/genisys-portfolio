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
  { name: "Rainbow Collective",   abbr: "RC" },
  { name: "Voltage Syndicate",     abbr: "VS" },
  { name: "Phantom Thread",        abbr: "PT" },
  { name: "Cobalt Nexus",          abbr: "CN" },
  { name: "Ironframe Studios",     abbr: "IF" },
  { name: "Parallax Agency",       abbr: "PA" },
  { name: "Rogue State Co.",       abbr: "RS" },
  { name: "Tim Brand Group",  abbr: "TB" },
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
