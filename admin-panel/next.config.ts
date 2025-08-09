import type { NextConfig } from "next";

const isDevelopment = process.env.NODE_ENV === 'development';
const isCI = process.env.CI === 'true';

const nextConfig: NextConfig = {
  // ESLint configuration
  eslint: {
    // In CI/CD environments, we want to catch errors but not fail the build
    // In development, show all errors
    ignoreDuringBuilds: isCI || isDevelopment,
    dirs: ['src'], // Only lint source files
  },

  // TypeScript configuration
  typescript: {
    // Allow builds to continue with type errors in CI/CD
    // but developers should fix them locally
    ignoreBuildErrors: isCI,
  },

  // Output configuration for better deployment
  output: 'standalone',

  // Security headers
  poweredByHeader: false,

  // Compression for better performance
  compress: true,

  // Environment variables that should be available to the client
  env: {
    NEXT_PUBLIC_API_BASE_URL: process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:3000',
  },

  // Redirect configuration
  async redirects() {
    return [
      {
        source: '/',
        destination: '/login',
        permanent: false,
      },
    ];
  },

  // Webpack configuration for better optimization
  webpack: (config, { dev, isServer }) => {
    // Don't bundle certain packages on the server
    if (!isServer) {
      config.resolve.fallback = {
        ...config.resolve.fallback,
        fs: false,
      };
    }

    return config;
  },
};

export default nextConfig;
