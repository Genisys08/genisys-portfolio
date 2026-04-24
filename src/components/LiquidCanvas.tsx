import { useEffect, useRef, useState } from "react";
import * as THREE from "three";
import { hasWebGL } from "@/lib/webgl";

/**
 * LiquidCanvas V2.5
 * STRICT two-color palette: void black (#0a0a0a) and dark metallic gold (~#3a2a08).
 * Heavily darkened so text remains the focal point.
 */
const FRAG = /* glsl */`
precision highp float;
uniform vec2 uRes;
uniform float uTime;
uniform vec2 uMouse;
varying vec2 vUv;

const vec3 C_VOID = vec3(0.039, 0.039, 0.039);   // #0a0a0a
const vec3 C_GOLD = vec3(0.227, 0.165, 0.047);   // dark metallic gold (~#3a2a0c)

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
  vec2 i = floor(p), f = fract(p);
  float a = hash(i), b = hash(i + vec2(1.0, 0.0));
  float c = hash(i + vec2(0.0, 1.0)), d = hash(i + vec2(1.0, 1.0));
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}
float fbm(vec2 p) {
  float v = 0.0, a = 0.5;
  for (int i = 0; i < 5; i++) { v += a * noise(p); p *= 2.02; a *= 0.5; }
  return v;
}

void main() {
  vec2 uv = vUv;
  vec2 p = (uv - 0.5) * vec2(uRes.x / uRes.y, 1.0);
  float t = uTime * 0.035;

  vec2 q = vec2(fbm(p + t), fbm(p + vec2(5.2, 1.3) - t));
  vec2 r = vec2(fbm(p + 4.0 * q + vec2(1.7, 9.2) + t * 0.6),
                fbm(p + 4.0 * q + vec2(8.3, 2.8) - t * 0.6));
  float f = fbm(p + 4.0 * r);

  vec2 m = (uMouse - 0.5) * vec2(uRes.x / uRes.y, 1.0);
  float md = exp(-3.5 * length(p - m));
  f += md * 0.18;

  // Strict two-color mix: void → dark gold based on fbm
  float mask = smoothstep(0.32, 0.78, f);
  vec3 col = mix(C_VOID, C_GOLD, mask);

  // Crush further to keep text focal
  col = pow(col, vec3(2.6));
  col *= 0.55;

  // Vignette
  float v = smoothstep(1.05, 0.18, length(uv - 0.5));
  col *= v;

  // Subtle grain
  float g = (hash(gl_FragCoord.xy + uTime) - 0.5) * 0.025;
  col += g;

  gl_FragColor = vec4(col, 1.0);
}
`;

const VERT = /* glsl */`
varying vec2 vUv;
void main() { vUv = uv; gl_Position = vec4(position, 1.0); }
`;

export default function LiquidCanvas() {
  const ref = useRef<HTMLCanvasElement>(null);
  const [supported, setSupported] = useState(true);

  useEffect(() => {
    if (!hasWebGL()) { setSupported(false); return; }
    const canvas = ref.current!;
    let renderer: THREE.WebGLRenderer;
    try {
      renderer = new THREE.WebGLRenderer({
        canvas,
        antialias: false,
        alpha: false,
        powerPreference: "low-power",
      });
    } catch (e) {
      console.warn("[LiquidCanvas] WebGL init failed", e);
      setSupported(false);
      return;
    }

    const dpr = Math.min(window.devicePixelRatio || 1, 1.25); // V2.5: tighter dpr cap
    renderer.setPixelRatio(dpr);
    renderer.setSize(window.innerWidth, window.innerHeight, false);
    renderer.setClearColor(0x000000, 1);

    const scene = new THREE.Scene();
    const camera = new THREE.Camera();
    const geo = new THREE.PlaneGeometry(2, 2);
    const uniforms = {
      uRes:   { value: new THREE.Vector2(window.innerWidth, window.innerHeight) },
      uTime:  { value: 0 },
      uMouse: { value: new THREE.Vector2(0.5, 0.5) },
    };
    const mat = new THREE.ShaderMaterial({ fragmentShader: FRAG, vertexShader: VERT, uniforms });
    const mesh = new THREE.Mesh(geo, mat);
    scene.add(mesh);

    const onResize = () => {
      renderer.setSize(window.innerWidth, window.innerHeight, false);
      uniforms.uRes.value.set(window.innerWidth, window.innerHeight);
    };
    const onMouse = (e: PointerEvent) => {
      uniforms.uMouse.value.set(e.clientX / window.innerWidth, 1 - e.clientY / window.innerHeight);
    };
    window.addEventListener("resize", onResize);
    window.addEventListener("pointermove", onMouse, { passive: true });

    // V2.5: Throttle to 30fps on mobile for buttery scrolling
    const isMobile = matchMedia("(pointer: coarse)").matches;
    const targetMs = isMobile ? 33 : 16;
    let raf = 0;
    const start = performance.now();
    let lastFrame = start;
    const tick = (now: number) => {
      raf = requestAnimationFrame(tick);
      if (now - lastFrame < targetMs) return;
      lastFrame = now;
      uniforms.uTime.value = (now - start) / 1000;
      try { renderer.render(scene, camera); }
      catch (e) { console.warn("[LiquidCanvas] render error", e); cancelAnimationFrame(raf); }
    };
    raf = requestAnimationFrame(tick);

    return () => {
      cancelAnimationFrame(raf);
      window.removeEventListener("resize", onResize);
      window.removeEventListener("pointermove", onMouse);
      geo.dispose();
      mat.dispose();
      renderer.dispose();
    };
  }, []);

  if (!supported) {
    return (
      <div aria-hidden className="fixed inset-0 z-0 pointer-events-none bg-black overflow-hidden">
        <div className="absolute inset-0 opacity-40"
          style={{ background: "radial-gradient(60% 50% at 50% 50%, hsl(var(--gold-deep)/.18), transparent 60%)" }} />
        <div className="absolute inset-0"
          style={{ background: "radial-gradient(120% 80% at 50% 50%, transparent 30%, #000 90%)" }} />
      </div>
    );
  }

  return <canvas ref={ref} aria-hidden className="fixed inset-0 z-0 w-full h-full block bg-black" />;
}
