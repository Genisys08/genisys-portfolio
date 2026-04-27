import { useEffect, useRef } from "react";
import { isTouch } from "@/lib/touch";

interface Particle {
  x: number; y: number;
  vx: number; vy: number;
  life: number; maxLife: number;
  r: number; hue: number;
}

/**
 * ClickBurst — gold particle burst on every click/tap.
 * Renders onto a fixed full-screen canvas at z-index 9300 (below cursor,
 * above everything else). Passive pointermove listener so it can't block
 * scroll or click events.
 *
 * On touch devices: fires on touchstart instead of pointerdown, but uses
 * fewer particles (4 instead of 8) to stay GPU-cheap.
 */
export default function ClickBurst() {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current!;
    const ctx    = canvas.getContext("2d");
    if (!ctx) return;

    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    const resize = () => {
      canvas.width        = window.innerWidth  * dpr;
      canvas.height       = window.innerHeight * dpr;
      canvas.style.width  = window.innerWidth  + "px";
      canvas.style.height = window.innerHeight + "px";
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    };
    resize();
    window.addEventListener("resize", resize);

    const particles: Particle[] = [];

    const burst = (x: number, y: number, count = 8) => {
      for (let i = 0; i < count; i++) {
        const angle = (i / count) * Math.PI * 2 + Math.random() * 0.4;
        const speed = 1.8 + Math.random() * 2.8;
        particles.push({
          x, y,
          vx:      Math.cos(angle) * speed,
          vy:      Math.sin(angle) * speed - 1.2, // slight upward bias
          life:    0,
          maxLife: 420 + Math.random() * 280,
          r:       1.2 + Math.random() * 2.2,
          hue:     38 + Math.random() * 14,
        });
        if (particles.length > 200) particles.shift();
      }
    };

    const onPointerDown = (e: PointerEvent) => {
      if (e.pointerType === "touch") return; // handled by touchstart
      burst(e.clientX, e.clientY, 8);
    };
    const onTouch = (e: TouchEvent) => {
      for (const t of Array.from(e.changedTouches)) burst(t.clientX, t.clientY, 4);
    };

    window.addEventListener("pointerdown", onPointerDown, { passive: true });
    window.addEventListener("touchstart",  onTouch,       { passive: true });

    let raf = 0;
    const tick = () => {
      raf = requestAnimationFrame(tick);
      ctx.clearRect(0, 0, window.innerWidth, window.innerHeight);
      ctx.globalCompositeOperation = "lighter";

      let i = particles.length;
      while (i--) {
        const p = particles[i];
        p.life += 16;
        p.x += p.vx * 0.9;
        p.y += p.vy * 0.9;
        p.vy += 0.06; // gravity
        p.vx *= 0.96;

        if (p.life >= p.maxLife) { particles.splice(i, 1); continue; }

        const t     = p.life / p.maxLife;
        const alpha = Math.sin(t * Math.PI) * 0.75;
        ctx.shadowBlur  = 6 + p.r * 2;
        ctx.shadowColor = `hsl(${p.hue} 90% 65% / ${alpha})`;
        ctx.fillStyle   = `hsl(${p.hue} 95% 70% / ${alpha})`;
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.r * (1 - t * 0.4), 0, Math.PI * 2);
        ctx.fill();
      }
      ctx.shadowBlur = 0;
    };
    raf = requestAnimationFrame(tick);

    return () => {
      cancelAnimationFrame(raf);
      window.removeEventListener("resize",       resize);
      window.removeEventListener("pointerdown",  onPointerDown);
      window.removeEventListener("touchstart",   onTouch);
    };
  }, []);

  return (
    <canvas
      ref={canvasRef}
      aria-hidden
      className="fixed inset-0 pointer-events-none"
      style={{ zIndex: 9300 }}
    />
  );
}
