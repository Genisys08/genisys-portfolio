import { useEffect, useRef, useState } from "react";

const CHARS = "!<>-_\\/[]{}—=+*^?#________";

export function useScramble(text: string, durationMs = 900, trigger: any = null): string {
  const [out, setOut] = useState(text);
  const raf = useRef(0);
  useEffect(() => {
    let start = performance.now();
    const len = text.length;
    const tick = (now: number) => {
      const t = Math.min(1, (now - start) / durationMs);
      let s = "";
      for (let i = 0; i < len; i++) {
        const reveal = (i + 1) / len;
        if (t >= reveal) s += text[i];
        else if (text[i] === " ") s += " ";
        else s += CHARS[Math.floor(Math.random() * CHARS.length)];
      }
      setOut(s);
      if (t < 1) raf.current = requestAnimationFrame(tick);
    };
    raf.current = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf.current);
  }, [text, durationMs, trigger]);
  return out;
}
