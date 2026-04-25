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
