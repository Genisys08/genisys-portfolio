import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "path";

export default defineConfig({
  plugins: [react()],
  resolve: { alias: { "@": path.resolve(__dirname, "./src") } },
  server: {
    host: "0.0.0.0",   // bind to all interfaces — reachable in Chrome on Android
    port: 5173,
    strictPort: true,   // fail loudly if 5173 is taken rather than silently moving
  },
});
