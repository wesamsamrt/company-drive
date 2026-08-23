import "./globals.css";import type{Metadata}from"next";
export const metadata:Metadata={title:"مساحات الشركة",description:"منصة تعاون وإدارة ملفات داخلية"};
export default function Layout({children}:{children:React.ReactNode}){return <html lang="ar" dir="rtl"><body>{children}</body></html>}
