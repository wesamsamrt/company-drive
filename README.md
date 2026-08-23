# مساحات الشركة

منصة داخلية عربية (RTL) لإدارة الملفات والتعاون حسب مساحات العمل: مصادقة، دعوات، صلاحيات خادمية، مجلدات، رفع وتنزيل، بحث وسجل نشاط.

## التشغيل

1. انسخ `.env.example` إلى `.env` واضبط `DATABASE_URL` و`AUTH_SECRET`.
2. أنشئ PostgreSQL، أو استخدم رابط Direct connection من Supabase.
3. نفذ:

```bash
npm install
npm run db:generate
npm run db:deploy
npm run db:seed
npm run dev
```

افتح `http://localhost:3000`. حساب البذرة: `admin@company.local` / `ChangeMe123!` (غيّره بعد الدخول). عند تطوير الـ schema لاحقًا استخدم `npm run db:migrate -- --name وصف_التعديل`.

## Supabase والتخزين

ضع رابط PostgreSQL من Supabase في `DATABASE_URL`. الملفات لا تخزن في قاعدة البيانات؛ `storage/` محليًا في التطوير. استبدل فقط `src/lib/storage.ts` لاحقًا بـ Supabase Storage أو S3.

## الحماية

كل API حساس يتحقق من العضوية والدور في `src/lib/access.ts`، لذلك لا يمكن تجاوز الصلاحيات عبر API. أنواع الرفع المدعومة: PDF/CSV/ZIP/Word/Excel والصور، وبحد 25MB.

## الإنتاج

```bash
npm run db:deploy
npm run build
npm start
```
