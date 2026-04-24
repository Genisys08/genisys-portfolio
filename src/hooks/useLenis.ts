import { useEffect } from "react";
import Lenis from "@studio-freight/lenis";
export function useLenis() {
  useEffect(() => {
    const lenis = new Lenis({ duration: 1.15, easing: (t: number) => 1 - Math.pow(1 - t, 3), smoothWheel: true });
    let raf = 0;
    const loop = (t: number) => { lenis.raf(t); raf = requestAnimationFrame(loop); };
    raf = requestAnimationFrame(loop);
    return () => { cancelAnimationFrame(raf); lenis.destroy(); };
  }, []);
}
