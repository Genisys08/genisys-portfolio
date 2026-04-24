import { useEffect, useState } from "react";
import ErrorBoundary from "@/components/ErrorBoundary";
import LiquidCanvas from "@/components/LiquidCanvas";
import EmberParticles from "@/components/EmberParticles";
import MagneticCursor from "@/components/MagneticCursor";
import GoldDustTrail from "@/components/GoldDustTrail";
import Preloader from "@/components/Preloader";
import VibeToggle from "@/components/VibeToggle";
import Navigation from "@/components/Navigation";
import Hero from "@/components/Hero";
import Gallery from "@/components/Gallery";
import About from "@/components/About";
import Process from "@/components/Process";
import Footer from "@/components/Footer";
import ContactModal from "@/components/ContactModal";
import Letterbox from "@/components/Letterbox";
import { useLenis } from "@/hooks/useLenis";

export default function App() {
  const [loaded, setLoaded] = useState(false);
  const [contactOpen, setContactOpen] = useState(false);
  useLenis();

  // V2.5: focus-dim REMOVED — was causing body text to render blurred & unreadable.

  useEffect(() => {
    const h = () => setContactOpen(true);
    window.addEventListener("open-contact", h);
    return () => window.removeEventListener("open-contact", h);
  }, []);

  return (
    <ErrorBoundary>
      <LiquidCanvas />
      <EmberParticles />
      <GoldDustTrail />
      <MagneticCursor />
      <Letterbox />

      {!loaded && <Preloader onDone={() => setLoaded(true)} />}

      <VibeToggle />

      <div className="relative z-10">
        <Navigation />
        <main>
          <Hero />
          <Gallery />
          <About />
          <Process />
        </main>
        <Footer onContact={() => setContactOpen(true)} />
      </div>

      <ContactModal open={contactOpen} onClose={() => setContactOpen(false)} />
    </ErrorBoundary>
  );
}
