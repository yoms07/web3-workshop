import "./globals.css";
import { Web3Providers } from "./providers";
import { Toaster } from "@/components/ui/sonner";

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={`antialiased font-mono dark bg-background`}>
        <Web3Providers>{children}</Web3Providers>
        <Toaster />
      </body>
    </html>
  );
}
