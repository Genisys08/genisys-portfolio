import { useEffect, useState }  from "react";
import ErrorBoundary             from "@/components/ErrorBoundary";
import LiquidCanvas              from "@/components/LiquidCanvas";
import EmberParticles            from "@/components/EmberParticles";
import MagneticCursor            from "@/components/MagneticCursor";
import GoldDustTrail             from "@/components/GoldDustTrail";
import Preloader                 from "@/components/Preloader";
import VibeToggle                from "@/components/VibeToggle";
import Navigation                from "@/components/Navigation";
import Hero                      from "@/components/Hero";
import Gallery                   from "@/components/Gallery";
import Stats                     from "@/components/Stats";
import About                     from "@/components/About";
import Testimonials              from "@/components/Testimonials";
import Process                   from "@/components/Process";
import Footer                    from "@/components/Footer";
import ContactModal              from "@/components/ContactModal";
import Letterbox                 from "@/components/Letterbox";
import AuroraBackground          from "@/components/AuroraBackground";
import ScrollVignette            from "@/components/ScrollVignette";
import { useLenis }              from "@/hooks/useLenis";
import { useVhFix }              from "@/hooks/useVhFix";
import { useReducedMotion }      from "@/hooks/useReducedMotion";
import { GyroscopeProvider }     from "@/contexts/GyroscopeContext";
import { getDeviceTier }         from "@/lib/deviceTier";

const TIER = getDeviceTier();

export default function App() {
  const [loaded, setLoaded]    = useState(false);
  const [contactOpen, setOpen] = useState(false);
  const reduced = useReducedMotion();
  useLenis();
  useVhFix();   // COMPAT-1: writes --vh for iOS Safari dvh fallback

  useEffect(() => {
    const h = () => setOpen(true);
    window.addEventListener("open-contact", h);
    return () => window.removeEventListener("open-contact", h);
  }, []);

  const showEmbers   = !reduced && TIER !== "low";
  const showGoldDust = !reduced && TIER === "high";
  const showAurora   = !reduced && TIER !== "low";   // AESTHETIC-1

  return (
    <ErrorBoundary>
      <GyroscopeProvider>

        {/* ── Background layers (z-order: aurora → liquid → embers) ─── */}
        {showAurora && <AuroraBackground />}
        <LiquidCanvas />
        {showEmbers   && <EmberParticles />}
        {showGoldDust && <GoldDustTrail />}

        {/* ── Overlay layers ──────────────────────────────────────────── */}
        <MagneticCursor />
        <Letterbox />
        <ScrollVignette />   {/* AESTHETIC-3 */}

        {!loaded && <Preloader onDone={() => setLoaded(true)} />}
        <VibeToggle />

        {/* ── Page content ────────────────────────────────────────────── */}
        <div className="relative z-10">
          <Navigation />
          <main>
            <Hero />
            <Gallery />
            <Stats />
            <About />
            <Testimonials />
            <Process />
          </main>
          <Footer onContact={() => setOpen(true)} />
        </div>

        <ContactModal open={contactOpen} onClose={() => setOpen(false)} />
      </GyroscopeProvider>
    </ErrorBoundary>
  );
}
