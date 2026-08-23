# مساحات الشركة — Supabase Static

نسخة إنتاجية خالصة بـ HTML/CSS/JavaScript. لا تحتاج Node.js أو Prisma أو خادم محلي.

## الإعداد

1. أنشئ مشروع Supabase جديدًا؛ اختر **Frankfurt** لأنه أقرب المتاح عادةً لمنطقة السعودية من سيول.
2. من SQL Editor نفّذ كامل ملف `supabase/schema.sql`.
3. من Authentication > Providers > Email عطّل **Confirm email** مؤقتًا للاختبار، أو فعّل بريدك قبل تسجيل الدخول.
4. انسخ `config.example.js` وسمّ النسخة `config.js`، ثم ضع Project URL وanon/public key من Settings > API.
5. افتح `index.html` عبر GitHub Pages أو Netlify أو Vercel. لا تفتح `config.js` أو تستخدم service_role key.

## GitHub Pages

ارفع كل الملفات إلى مستودع GitHub **باستثناء `config.js`**. ثم Settings > Pages > Deploy from branch > `main` > `/ (root)`.

### متغيرات عامة

`anon/public key` آمن للواجهة فقط لأن RLS وسياسات Storage في ملف SQL هي التي تمنع الوصول غير المصرح به. لا تضع أي `service_role` key في المشروع.
