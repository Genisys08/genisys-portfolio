import { useEffect, useRef, useState } from "react";

export default function MagneticCursor() {
  const dot = useRef<HTMLDivElement>(null);
  const ring = useRef<HTMLDivElement>(null);
  const [touch, setTouch] = useState(false);

  useEffect(() => {
    if (matchMedia("(pointer: coarse)").matches) { setTouch(true); return; }
    let x = 0, y = 0, rx = 0, ry = 0;
    const onMove = (e: PointerEvent) => { x = e.clientX; y = e.clientY; };
    window.addEventListener("pointermove", onMove);
    let raf = 0;
    const tick = () => {
      rx += (x - rx) * 0.18;
      ry += (y - ry) * 0.18;
      if (dot.current) dot.current.style.transform = `translate(${x}px, ${y}px)`;
      if (ring.current) ring.current.style.transform = `translate(${rx}px, ${ry}px)`;
      raf = requestAnimationFrame(tick);
    };
    tick();
    return () => { cancelAnimationFrame(raf); window.removeEventListener("pointermove", onMove); };
  }, []);

  if (touch) return null;
  return (
    <>
      <div ref={ring} aria-hidden className="pointer-events-none fixed top-0 left-0 z-[95] -ml-5 -mt-5 w-10 h-10 rounded-full border border-gold/70 mix-blend-difference" />
      <div ref={dot} aria-hidden className="pointer-events-none fixed top-0 left-0 z-[95] -ml-1 -mt-1 w-2 h-2 rounded-full bg-gold" />
    </>
  );
}
