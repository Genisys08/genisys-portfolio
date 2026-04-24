import { createContext, useContext, useEffect, useState, type ReactNode } from "react";

export interface Tilt { x: number; y: number; }

const GyroscopeContext = createContext<Tilt>({ x: 0, y: 0 });

/**
 * GyroscopeProvider — SINGLETON motion source.
 * Wrap once in App.tsx.  All consumers (Hero, PortfolioCard …) read the
 * same tilt value from context — no duplicate RAF loops, no duplicate listeners.
 */
export function GyroscopeProvider({ children }: { children: ReactNode }) {
  const [tilt, setTilt] = useState<Tilt>({ x: 0, y: 0 });

  useEffect(() => {
    let target: Tilt = { x: 0, y: 0 };
    let cur: Tilt = { x: 0, y: 0 };

    const onOrient = (e: DeviceOrientationEvent) => {
      const gx = (e.gamma ?? 0) / 45;
      const gy = (e.beta  ?? 0) / 45;
      target = {
        x: Math.max(-1, Math.min(1, gx)),
        y: Math.max(-1, Math.min(1, gy)),
      };
    };
    const onMouse = (e: PointerEvent) => {
      target = {
        x: (e.clientX / window.innerWidth)  * 2 - 1,
        y: (e.clientY / window.innerHeight) * 2 - 1,
      };
    };

    window.addEventListener("deviceorientation", onOrient);
    window.addEventListener("pointermove", onMouse, { passive: true });

    let raf = 0;
    const tick = () => {
      cur.x += (target.x - cur.x) * 0.08;
      cur.y += (target.y - cur.y) * 0.08;
      setTilt({ x: cur.x, y: cur.y });
      raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);

    return () => {
      cancelAnimationFrame(raf);
      window.removeEventListener("deviceorientation", onOrient);
      window.removeEventListener("pointermove", onMouse);
    };
  }, []);

  return (
    <GyroscopeContext.Provider value={tilt}>
      {children}
    </GyroscopeContext.Provider>
  );
}

/** Use this in any component instead of the old useGyroscope() hook. */
export function useGyroscopeTilt(): Tilt {
  return useContext(GyroscopeContext);
}
