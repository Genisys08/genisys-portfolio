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
