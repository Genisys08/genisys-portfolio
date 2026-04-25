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
