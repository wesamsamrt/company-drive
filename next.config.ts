import type { NextConfig } from "next";
const nextConfig: NextConfig = { outputFileTracingIncludes: { "/api/files/**": ["./storage/**/*"] } };
export default nextConfig;
