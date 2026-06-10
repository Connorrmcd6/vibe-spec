// @ts-check
import { defineConfig } from "astro/config";
import vercel from "@astrojs/vercel";
import tailwindcss from "@tailwindcss/vite";

// https://astro.build/config
export default defineConfig({
  // Placeholder — update to the live domain once deployed, then sync the
  // homepage fields in ../.claude-plugin/{plugin,marketplace}.json.
  site: "https://vibe-spec.vercel.app",
  output: "static",
  adapter: vercel(),
  vite: {
    plugins: [tailwindcss()],
  },
});
