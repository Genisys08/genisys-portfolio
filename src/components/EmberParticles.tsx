import { useEffect, useRef } from "react";

interface Ember { x: number; y: number; vx: number; vy: number; r: number; life: number; maxLife: number; hue: number; }

export default function EmberParticles() {
  const ref = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = ref.current!;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    let w = window.innerWidth, h = window.innerHeight;
    const dpr = Math.min(window.devicePixelRatio || 1, 1.5);
    const resize = () => {
      w = window.innerWidth; h = window.innerHeight;
      canvas.width = w * dpr; canvas.height = h * dpr;
      canvas.style.width = w + "px"; canvas.style.height = h + "px";
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    };
    resize();
    window.addEventListener("resize", resize);

    const COUNT = Math.min(70, Math.floor((w * h) / 24000));
    const embers: Ember[] = [];
    const spawn = (e: Ember) => {
      e.x = Math.random() * w;
      e.y = h + Math.random() * 60;
      e.vx = (Math.random() - 0.5) * 0.25;
      e.vy = -0.15 - Math.random() * 0.55;
      e.r = 0.6 + Math.random() * 2.4;
      e.maxLife = 6000 + Math.random() * 9000;
      e.life = 0;
      e.hue = 38 + Math.random() * 14;
    };
    for (let i = 0; i < COUNT; i++) {
      const e: Ember = { x: 0, y: 0, vx: 0, vy: 0, r: 1, life: 0, maxLife: 1, hue: 44 };
      spawn(e); e.y = Math.random() * h; e.life = Math.random() * e.maxLife;
      embers.push(e);
    }

    let raf = 0, last = performance.now();
    const tick = (now: number) => {
      const dt = Math.min(48, now - last); last = now;
      ctx.clearRect(0, 0, w, h);
      ctx.globalCompositeOperation = "lighter";
      for (const e of embers) {
        e.life += dt;
        e.x += e.vx * dt * 0.06;
        e.y += e.vy * dt * 0.06;
        if (e.life > e.maxLife || e.y < -20) spawn(e);
        const t = e.life / e.maxLife;
        const alpha = Math.sin(t * Math.PI) * 0.55;
        const blur = 4 + e.r * 3;
        ctx.shadowBlur = blur;
        ctx.shadowColor = `hsl(${e.hue} 90% 60% / ${alpha})`;
        ctx.fillStyle = `hsl(${e.hue} 95% ${55 + e.r * 4}% / ${alpha})`;
        ctx.beginPath();
        ctx.arc(e.x, e.y, e.r, 0, Math.PI * 2);
        ctx.fill();
      }
      ctx.shadowBlur = 0;
      raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);

    return () => { cancelAnimationFrame(raf); window.removeEventListener("resize", resize); };
  }, []);

  return <canvas ref={ref} aria-hidden className="fixed inset-0 z-[1] pointer-events-none" />;
}
