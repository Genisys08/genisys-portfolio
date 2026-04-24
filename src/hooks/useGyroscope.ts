import { useEffect, useState } from "react";

export interface Tilt { x: number; y: number; }
export function useGyroscope(): Tilt {
  const [tilt, setTilt] = useState<Tilt>({ x: 0, y: 0 });
  useEffect(() => {
    let target: Tilt = { x: 0, y: 0 };
    let cur: Tilt = { x: 0, y: 0 };
    const onOrient = (e: DeviceOrientationEvent) => {
      const gx = (e.gamma ?? 0) / 45;
      const gy = (e.beta ?? 0) / 45;
      target = { x: Math.max(-1, Math.min(1, gx)), y: Math.max(-1, Math.min(1, gy)) };
    };
    const onMouse = (e: PointerEvent) => {
      target = { x: (e.clientX / window.innerWidth) * 2 - 1, y: (e.clientY / window.innerHeight) * 2 - 1 };
    };
    window.addEventListener("deviceorientation", onOrient);
    window.addEventListener("pointermove", onMouse);
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
  return tilt;
}

export async function requestGyroPermission(): Promise<boolean> {
  const anyDOE = (window as any).DeviceOrientationEvent;
  if (anyDOE && typeof anyDOE.requestPermission === "function") {
    try {
      const res = await anyDOE.requestPermission();
      return res === "granted";
    } catch { return false; }
  }
  return true;
}
