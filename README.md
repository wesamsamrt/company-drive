# مساحات الشركة — Supabase Static

واجهة عربية ثابتة تعمل عبر GitHub Pages مع Supabase Auth وDatabase وStorage.

## ترقية المهام الاحترافية

بعد تشغيل قاعدة المشروع وترقية المهام الأولى، نفّذ ملف `supabase/upgrade_v4_tasks_pro.sql` كاملًا في **Supabase SQL Editor**. هذه الترقية تصلح خطأ تغيير الحالة وتضيف: مرفقات خاصة بالمهمة، قائمة إنجاز ونسبة تقدم، بحث وفلترة، وتعليقات وسجل نشاط.

لا تضع `config.js` في مستودع عام. ارفع فقط ملفات الواجهة بعد إبقاء قيم Supabase في `config.js` كما هي.
نسخة إنتاجية خالصة بـ HTML/CSS/JavaScript. لا تحتاج Node.js أو Prisma أو خادم محلي.

## الإعداد

1. أنشئ مشروع Supabase جديدًا؛ اختر **Frankfurt** لأنه أقرب المتاح عادةً لمنطقة السعودية من سيول.
2. من SQL Editor نفّذ كامل ملف `supabase/schema.sql`.
3. من Authentication > Providers > Email عطّل **Confirm email** مؤقتًا للاختبار، أو فعّل بريدك قبل تسجيل الدخول.
4. انسخ `config.example.js` وسمّ النسخة `config.js`، ثم ضع Project URL وanon/public key من Settings > API.
5. افتح `index.html` عبر GitHub Pages أو Netlify أو Vercel. لا تفتح `config.js` أو تستخدم service_role key.

## الترقية إلى الإصدار 2

نفّذ ملف `supabase/upgrade_v2.sql` كاملًا في SQL Editor، ثم استبدل `app.js` و`style.css` في مستودع GitHub بالنسخة الجديدة. تضيف الترقية لوحة تحكم محسّنة، ملخصات للمساحات والملفات، عرض شبكي/جدولي، معاينة وتنزيل الملفات، بحث، إنشاء/حذف/إعادة تسمية، إدارة دعوات، دليل موظفين وسجل نشاط.

## GitHub Pages

ارفع كل الملفات إلى مستودع GitHub **باستثناء `config.js`**. ثم Settings > Pages > Deploy from branch > `main` > `/ (root)`.

### متغيرات عامة

`anon/public key` آمن للواجهة فقط لأن RLS وسياسات Storage في ملف SQL هي التي تمنع الوصول غير المصرح به. لا تضع أي `service_role` key في المشروع.
