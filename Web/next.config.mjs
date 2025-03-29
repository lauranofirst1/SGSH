/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    domains: ["localhost", "picsum.photos", "cytktlrbanxiswqurqth.supabase.co", "*"],
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'cytktlrbanxiswqurqth.supabase.co',
        port: '',
        pathname: '/storage/v1/object/public/**',
      },
    ],
  },
  reactStrictMode: true,
};

export default nextConfig;
