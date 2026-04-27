import { Analytics } from "@vercel/analytics/react";
import { useEffect, useState }   from "react";
import { AnimatePresence, motion } from "framer-motion";
import ErrorBoundary              from "@/components/ErrorBoundary";
import LiquidCanvas               from "@/components/LiquidCanvas";
import EmberParticles             from "@/components/EmberParticles";
import MagneticCursor             from "@/components/MagneticCursor";
import GoldDustTrail              from "@/components/GoldDustTrail";
import Preloader                  from "@/components/Preloader";
import MusicPlayer               from "@/components/MusicPlayer";
import Navigation                 from "@/components/Navigation";
import ContactModal               from "@/components/ContactModal";
import Letterbox                  from "@/components/Letterbox";
import AuroraBackground           from "@/components/AuroraBackground";
import ScrollVignette             from "@/components/ScrollVignette";
import CookieBanner               from "@/components/CookieBanner";
import BackToTop                  from "@/components/BackToTop";
import ScrollProgressBar          from "@/components/ScrollProgressBar";
import CommandPalette             from "@/components/CommandPalette";
import ClickBurst                 from "@/components/ClickBurst";
import HomePage                   from "@/pages/HomePage";
import ServicesPage               from "@/pages/ServicesPage";
import StudioPage                 from "@/pages/StudioPage";
import CaseStudyPage              from "@/pages/CaseStudyPage";
import NotFoundPage               from "@/pages/NotFoundPage";
import { useLenis }               from "@/hooks/useLenis";
import { useVhFix }               from "@/hooks/useVhFix";
import { useReducedMotion }       from "@/hooks/useReducedMotion";
import { GyroscopeProvider }      from "@/contexts/GyroscopeContext";
import { ToastProvider }          from "@/contexts/ToastContext";
import { getDeviceTier }          from "@/lib/deviceTier";
import { useRouter }              from "@/lib/router";

const TIER = getDeviceTier();

export default function App() {
  const [loaded,        setLoaded]        = useState(false);
  const [contactOpen,   setOpen]          = useState(false);
  const [cookieShowing, setCookieShowing] = useState(false);

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

  // Unique key per page — drives AnimatePresence transition
  const pageKey = route.page === "case-study"
    ? `case-study-${route.id}`
    : route.page;

  const renderPage = () => {
    switch (route.page) {
      case "home":       return <HomePage     onContact={() => setOpen(true)} />;
      case "services":   return <ServicesPage onContact={() => setOpen(true)} />;
      case "studio":     return <StudioPage   onContact={() => setOpen(true)} />;
      case "case-study": return <CaseStudyPage id={route.id} onContact={() => setOpen(true)} />;
      default:           return <NotFoundPage />;
    }
  };

  return (
    <ErrorBoundary>
      <ToastProvider>
        <GyroscopeProvider>
          {showAurora   && <AuroraBackground />}
          <LiquidCanvas />
          {showEmbers   && <EmberParticles />}
          {showGoldDust && <GoldDustTrail />}
          <ClickBurst />
          <ScrollProgressBar />
          <MagneticCursor />
          <Letterbox />
          <ScrollVignette />
          <CommandPalette />
          <CookieBanner show={loaded} onVisibleChange={setCookieShowing} />
          <BackToTop raised={cookieShowing} />
          {!loaded && <Preloader onDone={() => setLoaded(true)} />}
          <MusicPlayer />

          <div className="relative z-10">
            <Navigation route={route} />
            <main>
              {/*
               * FIX-7: AnimatePresence mode="wait" fades the current page out
               * before fading the new one in. No more hard cuts between pages.
               * reduced-motion: instant transition (duration 0) via CSS class.
               */}
              <AnimatePresence mode="wait">
                <motion.div
                  key={pageKey}
                  initial={{ opacity: 0, y: reduced ? 0 : 12 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{   opacity: 0, y: reduced ? 0 : -8 }}
                  transition={{ duration: reduced ? 0 : 0.35, ease: [0.7, 0, 0.3, 1] }}
                >
                  {renderPage()}
                </motion.div>
              </AnimatePresence>
            </main>
          </div>

          <ContactModal open={contactOpen} onClose={() => setOpen(false)} />
        </GyroscopeProvider>
      </ToastProvider>
      <Analytics />
    </ErrorBoundary>
  );
}
