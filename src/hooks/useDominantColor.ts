import { useEffect, useState } from "react";
export function useDominantColor(src?: string): string {
  const [color, setColor] = useState("#0a0a0a");
  useEffect(() => {
    if (!src) return;
    const img = new Image();
    img.crossOrigin = "anonymous";
    img.src = src;
    img.onload = () => {
      try {
        const c = document.createElement("canvas");
        c.width = 16; c.height = 16;
        const ctx = c.getContext("2d");
        if (!ctx) return;
        ctx.drawImage(img, 0, 0, 16, 16);
        const d = ctx.getImageData(0, 0, 16, 16).data;
        let r = 0, g = 0, b = 0, n = 0;
        for (let i = 0; i < d.length; i += 4) { r += d[i]; g += d[i+1]; b += d[i+2]; n++; }
        setColor(`rgb(${(r/n)|0},${(g/n)|0},${(b/n)|0})`);
      } catch { /* CORS — ignore */ }
    };
  }, [src]);
  return color;
}
