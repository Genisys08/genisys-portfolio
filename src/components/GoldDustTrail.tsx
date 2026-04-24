import { useEffect, useRef } from "react";

/**
 * GoldDustTrail V2.5
 * Pointer/touch trail of fading golden sparks. Canvas-based, GPU-friendly.
 * — Pointer events cover both mouse & touch (touch only emits during drag).
 * — Capped particle pool (no leaks).
 * — Auto-pauses when tab hidden.
 */
interface Spark {
  x: number; y: number; vx: number; vy: number;
  life: number; max: number; r: number;
}

export default function GoldDustTrail() {
  const ref = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = ref.current!;
    const ctx2d = canvas.getContext("2d");
    if (!ctx2d) return;
    const ctx = ctx2d;

    const dpr = Math.min(window.devicePixelRatio || 1, 1.5);
    let w = window.innerWidth, h = window.innerHeight;
    const resize = () => {
      w = window.innerWidth; h = window.innerHeight;
      canvas.width = w * dpr; canvas.height = h * dpr;
      canvas.style.width = w + "px"; canvas.style.height = h + "px";
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    };
    resize();

    const POOL_MAX = 80;
    const sparks: Spark[] = [];
    let lastSpawn = 0;
    let lx = 0, ly = 0;
    let active = false;
    const isCoarse = matchMedia("(pointer: coarse)").matches;

    const spawn = (x: number, y: number, count = 2) => {
      for (let i = 0; i < count && sparks.length < POOL_MAX; i++) {
        sparks.push({
          x: x + (Math.random() - 0.5) * 6,
          y: y + (Math.random() - 0.5) * 6,
          vx: (Math.random() - 0.5) * 0.6,
          vy: (Math.random() - 0.5) * 0.6 - 0.15,
          life: 0,
          max: 600 + Math.random() * 500,
          r: 0.8 + Math.random() * 1.6,
        });
      }
    };

    const onMove = (e: PointerEvent) => {
      // On touch devices only emit during press-drag
      if (isCoarse && e.pressure === 0 && e.pointerType === "touch") return;
      const now = performance.now();
      const dx = e.clientX - lx, dy = e.clientY - ly;
      const dist = Math.hypot(dx, dy);
      if (now - lastSpawn > 18 || dist > 14) {
        spawn(e.clientX, e.clientY, dist > 30 ? 3 : 2);
        lastSpawn = now;
      }
      lx = e.clientX; ly = e.clientY;
    };

    const onDown = (e: PointerEvent) => { active = true; lx = e.clientX; ly = e.clientY; };
    const onUp = () => { active = false; };

    window.addEventListener("resize", resize);
    window.addEventListener("pointermove", onMove, { passive: true });
    window.addEventListener("pointerdown", onDown, { passive: true });
    window.addEventListener("pointerup", onUp, { passive: true });

    let raf = 0, last = performance.now(), running = true;
    const onVis = () => { running = !document.hidden; if (running) { last = performance.now(); raf = requestAnimationFrame(tick); } };
    document.addEventListener("visibilitychange", onVis);

    function tick(now: number) {
      if (!running) return;
      const dt = Math.min(48, now - last); last = now;
      ctx.clearRect(0, 0, w, h);
      ctx.globalCompositeOperation = "lighter";
      for (let i = sparks.length - 1; i >= 0; i--) {
        const s = sparks[i];
        s.life += dt;
        if (s.life >= s.max) { sparks.splice(i, 1); continue; }
        s.x += s.vx * dt * 0.06;
        s.y += s.vy * dt * 0.06;
        s.vy += 0.0008 * dt; // gentle gravity
        const t = s.life / s.max;
        const alpha = (1 - t) * 0.85;
        ctx.shadowBlur = 10 + s.r * 4;
        ctx.shadowColor = `hsl(44 90% 60% / ${alpha})`;
        ctx.fillStyle = `hsl(44 90% ${60 + s.r * 6}% / ${alpha})`;
        ctx.beginPath();
        ctx.arc(s.x, s.y, s.r * (1 - t * 0.6), 0, Math.PI * 2);
        ctx.fill();
      }
      ctx.shadowBlur = 0;
      raf = requestAnimationFrame(tick);
    }
    raf = requestAnimationFrame(tick);

    return () => {
      cancelAnimationFrame(raf);
      running = false;
      window.removeEventListener("resize", resize);
      window.removeEventListener("pointermove", onMove);
      window.removeEventListener("pointerdown", onDown);
      window.removeEventListener("pointerup", onUp);
      document.removeEventListener("visibilitychange", onVis);
    };
  }, []);

  return (
    <canvas
      ref={ref}
      aria-hidden
      className="fixed inset-0 z-[2] pointer-events-none"
    />
  );
}
