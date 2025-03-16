import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  optimizeDeps: {
    exclude: ["lucide-react"], // Ensure this is necessary
  },
  build: {
    outDir: "dist", // Specify the output directory (default is 'dist')
    sourcemap: true, // Enable source maps for easier debugging (optional)
  },
  server: {
    port: 3000, // Specify the port for the development server (optional)
  },
});
