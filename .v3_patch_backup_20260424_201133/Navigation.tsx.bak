import { useScramble } from "@/hooks/useScramble";
import { useMagnetic } from "@/hooks/useMagnetic";

const links = [
  { id: "work", label: "WORK" },
  { id: "about", label: "ABOUT" },
  { id: "process", label: "PROCESS" },
];

function NavLink({ id, label }: { id: string; label: string }) {
  const text = useScramble(label, 700);
  const ref = useMagnetic<HTMLAnchorElement>(0.3);
  return (
    <a ref={ref} href={`#${id}`} className="font-mono text-[11px] tracking-[0.35em] text-cream/80 hover:text-gold transition-colors px-2 py-1">
      {text}
    </a>
  );
}

export default function Navigation() {
  const brand = useScramble("GENISYS", 900);
  return (
    <header className="fixed top-0 left-0 right-0 z-[70] flex items-center justify-between px-4 sm:px-8 pt-4">
      <a href="#top" className="font-display font-black text-base sm:text-lg gold-text tracking-tight">{brand}</a>
      <nav className="hidden sm:flex items-center gap-1 glass rounded-full px-3 py-1.5">
        {links.map(l => <NavLink key={l.id} {...l} />)}
      </nav>
    </header>
  );
}
