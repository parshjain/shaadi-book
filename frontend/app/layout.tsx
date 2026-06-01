import type { Metadata, Viewport } from "next";
import type { ReactNode } from "react";
import { Inter, Cormorant_Garamond } from "next/font/google";
import "./globals.css";
import { Providers } from "./providers";
import { BottomNav } from "@/components/BottomNav";
import { UserMenu } from "@/components/UserMenu";
import { PushNotifications } from "@/components/PushNotifications";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-sans",
  display: "swap",
  weight: ["300", "400", "500", "600"],
});

const cormorant = Cormorant_Garamond({
  subsets: ["latin"],
  variable: "--font-serif",
  weight: ["300", "400", "500", "600", "700"],
  style: ["normal", "italic"],
  display: "swap",
});

export const metadata: Metadata = {
  title: "Baby Hasan Bets — Anusha & Alif",
  description: "Live prediction markets for Baby Hasan's gender reveal",
  manifest: "/manifest.json",
  metadataBase: new URL("https://babyhasanbets.com"),
  openGraph: {
    title: "Baby Hasan Bets — Anusha & Alif",
    description:
      "Place your bets on gender reveal predictions for Baby Hasan.",
    url: "https://babyhasanbets.com",
    siteName: "Baby Hasan Bets",
    images: [
      {
        url: "/og-image.svg",
        width: 1200,
        height: 630,
        alt: "Baby Hasan Bets — Gender Reveal Prediction Markets",
      },
    ],
    locale: "en_US",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "Baby Hasan Bets — Anusha & Alif",
    description:
      "Place your bets on gender reveal predictions for Baby Hasan.",
    images: ["/og-image.svg"],
  },
  icons: {
    icon: "/favicon.svg",
    apple: "/apple-touch-icon.png",
  },
  appleWebApp: {
    capable: true,
    statusBarStyle: "default",
    title: "Baby Hasan Bets",
  },
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
  themeColor: "#B8860B",
};

export default function RootLayout({
  children,
}: {
  children: ReactNode;
}) {
  return (
    <html lang="en" className={`${inter.variable} ${cormorant.variable}`}>
      <body className="min-h-screen bg-ivory text-charcoal font-sans">
        <Providers>
          {/* Push notification opt-in banner */}
          <PushNotifications />
          {/* Auth-aware user menu — hidden on /login */}
          <UserMenu />
          {children}
          <BottomNav />
        </Providers>
      </body>
    </html>
  );
}
