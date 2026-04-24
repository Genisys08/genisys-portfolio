export function hasWebGL(): boolean {
  if (typeof window === "undefined") return false;
  try {
    const c = document.createElement("canvas");
    const gl = (c.getContext("webgl2") || c.getContext("webgl") || c.getContext("experimental-webgl")) as WebGLRenderingContext | null;
    if (!gl) return false;
    // Smoke test
    const ext = gl.getExtension("WEBGL_lose_context");
    ext?.loseContext();
    return true;
  } catch {
    return false;
  }
}
