import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "妈祖 · 圣杯问心",
  description: "了解妈祖文化与掷筊礼仪，在片刻静心中梳理自己的问题。仅供民俗文化体验，不作预测。",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="zh-CN">
      <body>{children}</body>
    </html>
  );
}
