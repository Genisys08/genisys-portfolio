import { useScramble } from "@/hooks/useScramble";
import { haptic } from "@/lib/haptics";

interface Props { onContact: () => void; }

export default function Footer({ onContact }: Props) {
  const sign = useScramble("GENISYS GRAPHICS // 2026", 900);

  const handleContact = () => {
    haptic([10, 30, 15]);
    onContact();
  };

  return (
    <footer className="relative px-6 pt-12 pb-28 mt-12">
      <div className="max-w-5xl mx-auto border-t border-white/[0.06] pt-8">
        <div className="flex flex-col sm:flex-row items-center justify-between gap-6">
          <div className="flex flex-col items-center sm:items-start gap-1">
            <div className="font-mono text-[10px] tracking-[0.4em] text-gold/80">{sign}</div>
            <div className="font-mono text-[9px] tracking-[0.25em] text-cream/50">
              OPERATIC BRAND &amp; IDENTITY DESIGN
            </div>
          </div>

          <button
            onClick={handleContact}
            className="inline-flex items-center gap-2.5 px-7 py-3 rounded-full glass-strong gold-border-glow font-mono text-xs tracking-[0.35em] text-gold hover:text-cream transition-colors animate-border-pulse"
          >
            CONTACT
            <span className="text-gold/70">→</span>
          </button>
        </div>

        <div className="mt-8 flex flex-col sm:flex-row items-center justify-between gap-3">
          <div className="font-mono text-[9px] tracking-[0.3em] text-cream/40">
            © 2026 GENISYS GRAPHICS. ALL RIGHTS RESERVED.
          </div>
          <div className="font-mono text-[9px] tracking-[0.25em] text-cream/40">
            CRAFTED WITH PRECISION · NO SHORTCUTS · NO COMPROMISES
          </div>
        </div>
      </div>
    </footer>
  );
}
