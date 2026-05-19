قواعد الذكاء الاصطناعي لمشروع "مديري"

AI Development Rules & Engineering Standards

---

1. القاعدة الأساسية

أي نموذج ذكاء اصطناعي أو Agent يعمل على المشروع يجب أن يتعامل مع المشروع كمنتج تنفيذي احترافي Production-Grade Application وليس كتطبيق تجريبي.

يجب أن تكون جميع القرارات:

هندسية

قابلة للتوسع

منظمة

قابلة للصيانة

متوافقة مع المعمارية المعتمدة

---

2. الالتزام بالمعمارية Architecture

إلزامي

يجب الالتزام الكامل بـ:

Clean Architecture

---

الطبقات المعتمدة

Presentation Layer
Domain Layer
Data Layer
Core Layer

---

ممنوع

❌ وضع Business Logic داخل UI
❌ الوصول المباشر لقاعدة البيانات من الواجهة
❌ خلط الخدمات داخل Widgets
❌ إنشاء ملفات عشوائية خارج الهيكل المعتمد

---

المطلوب

✅ فصل المسؤوليات Separation of Concerns
✅ استخدام Repository Pattern
✅ استخدام Use Cases
✅ جعل كل Feature مستقلة قدر الإمكان

---

3. إدارة الحالة State Management

المعتمد رسميًا

Riverpod فقط

---

ممنوع

❌ Provider التقليدي
❌ GetX
❌ Bloc
❌ MobX
❌ setState للحالات المعقدة

---

المطلوب

✅ استخدام:

NotifierProvider
AsyncNotifierProvider
StateNotifierProvider

✅ فصل الـ Providers حسب الـ Feature

✅ منع تضخم الـ Providers

✅ جعل الحالة قابلة للاختبار Testable

---

4. قاعدة البيانات Database Rules

المعتمد رسميًا

Drift ORM

SQLite

SQLCipher

---

ممنوع

❌ استخدام raw SQL بدون سبب هندسي واضح
❌ إنشاء جداول بدون timestamps
❌ استخدام Polymorphic Relations المعقدة
❌ حذف البيانات نهائيًا Hard Delete

---

المطلوب

كل جدول يجب أن يحتوي على:

id
syncId
createdAt
updatedAt
isDeleted

---

قواعد البيانات

✅ استخدام DAO لكل جدول
✅ استخدام Transactions عند العمليات الحرجة
✅ دعم Soft Delete
✅ تصميم جاهز للمزامنة مستقبلًا
✅ كتابة Migrations منظمة

---

5. نظام التصميم Design System

إلزامي

أي واجهة يجب أن تلتزم بالكامل بـ:

Executive Neumorphism Design System

---

ممنوع

❌ استخدام Glassmorphism
❌ استخدام ألوان عشوائية
❌ إنشاء Styles داخل Widgets مباشرة
❌ استخدام Shadows مختلفة عن النظام المعتمد
❌ استخدام أكثر من Accent Color بالشاشة

---

المطلوب

✅ استخدام ملفات Theme المركزية
✅ استخدام Components مشتركة
✅ الالتزام بالـ Radius المعتمد
✅ الالتزام بالـ Spacing System
✅ الالتزام بالـ Typography System

---

6. منع تكرار الكود DRY Principle

إلزامي

أي كود مكرر أكثر من مرتين يجب تحويله إلى:

Widget مشترك

Helper

Extension

Service

Utility

---

ممنوع

❌ نسخ ولصق Widgets
❌ تكرار Queries
❌ تكرار Logic
❌ تكرار تصميم العناصر

---

المطلوب

✅ Shared Components
✅ Reusable Widgets
✅ Centralized Utilities
✅ Generic Services

---

7. دعم اللغة العربية و RTL

إلزامي

التطبيق Arabic-First.

---

المطلوب

✅ دعم RTL كامل
✅ استخدام Directionality صحيحة
✅ دعم النصوص العربية بالكامل
✅ دعم الخطوط المعتمدة:

Tajawal

IBM Plex Sans Arabic

✅ اختبار جميع الشاشات على RTL

---

ممنوع

❌ Layouts تنكسر مع RTL
❌ استخدام محاذاة ثابتة Left فقط
❌ نصوص إنجليزية داخل الواجهات الأساسية

---

8. قواعد الـ UI/UX

المبادئ الأساسية

التطبيق يجب أن يكون:

سريع

واضح

احترافي

قليل الضغطات

مناسب للمدراء التنفيذيين

---

قاعدة الثلاث ضغطات

أي عملية رئيسية يجب ألا تتجاوز:

3 Clicks Maximum

---

المطلوب

✅ إظهار المعلومات المهمة أولًا
✅ استخدام Quick Actions
✅ استخدام Smart Suggestions
✅ تقليل التعقيد البصري
✅ تصميم مناسب للأجهزة المتوسطة

---

9. قواعد الأداء Performance Rules

ممنوع

❌ Widgets ضخمة
❌ إعادة بناء غير ضرورية
❌ عمليات ثقيلة داخل build()
❌ استخدام ListView غير محسنة
❌ استعلامات متكررة

---

المطلوب

✅ استخدام const Widgets
✅ استخدام Lazy Loading
✅ استخدام Pagination عند الحاجة
✅ تحسين الأداء للأجهزة الضعيفة
✅ تقليل استهلاك الذاكرة

---

10. قواعد الأمان Security Rules

إلزامي

أي بيانات داخل التطبيق تعتبر حساسة.

---

المطلوب

✅ استخدام SQLCipher
✅ استخدام flutter_secure_storage
✅ تشفير النسخ الاحتياطية
✅ دعم Biometric Authentication
✅ منع Screenshot داخل الشاشات الحساسة
✅ تسجيل العمليات الحساسة داخل Security Logs

---

ممنوع

❌ تخزين كلمات المرور كنص صريح
❌ حفظ المفاتيح داخل الكود
❌ تصدير بيانات بدون حماية
❌ كشف البيانات الحساسة داخل Logs

---

11. قواعد الملفات والتنظيم

هيكل Features

features/
 └── feature_name/
      ├── data/
      ├── domain/
      ├── presentation/
      ├── widgets/
      ├── providers/
      └── services/

---

ممنوع

❌ ملفات ضخمة جدًا
❌ Widgets بأكثر من 300 سطر
❌ Classes متعددة المسؤوليات
❌ وضع كل شيء داخل ملف واحد

---

12. قواعد الـ Naming Convention

إلزامي

الملفات

snake_case.dart

الكلاسات

PascalCase

المتغيرات والدوال

camelCase

---

أمثلة صحيحة

meeting_repository.dart
task_provider.dart
CreateMeetingUseCase

---

13. قواعد الـ Git و Versioning

المطلوب

✅ Commits واضحة
✅ Feature Branches
✅ Pull Requests منظمة
✅ Semantic Versioning

---

صيغة الـ Commit

feat:
fix:
refactor:
ui:
perf:
security:
docs:

---

14. قواعد إنشاء Features الجديدة

أي Feature جديدة يجب أن:

✅ تكون مستقلة
✅ تحتوي Providers خاصة بها
✅ تحتوي Repository خاص بها
✅ تحتوي Use Cases
✅ تدعم التوسعة مستقبلًا
✅ تدعم Offline First

---

15. قواعد الـ Offline First

إلزامي

التطبيق يجب أن يعمل بالكامل بدون إنترنت.

---

المطلوب

✅ جميع العمليات تعمل محليًا
✅ عدم الاعتماد على APIs
✅ حفظ البيانات محليًا دائمًا
✅ تصميم جاهز للـ Sync مستقبلًا

---

16. قواعد الـ AI Agent نفسه

أي AI يعمل على المشروع يجب أن:

✅ يحلل الهيكل الحالي قبل التعديل
✅ لا يكسر المعمارية
✅ لا ينشئ Dependencies غير ضرورية
✅ يعيد استخدام المكونات الموجودة
✅ يلتزم بالـ Theme System
✅ يكتب كود قابل للصيانة
✅ يضيف تعليقات هندسية عند الحاجة
✅ يفكر كمهندس برمجيات محترف وليس مولد أكواد فقط

---

17. قواعد جودة الكود

إلزامي

✅ Clean Code
✅ SOLID Principles
✅ Readable Code
✅ Scalable Code
✅ Maintainable Code

---

ممنوع

❌ Magic Numbers
❌ Hardcoded Strings
❌ Business Logic داخل Widgets
❌ Nested Widgets معقدة جدًا

---

18. قواعد الاختبارات Testing

المطلوب

✅ Unit Tests للمنطق
✅ Widget Tests للواجهات
✅ Repository Tests
✅ اختبار الحالات الحرجة

---

19. قواعد التوسع المستقبلي

التطبيق يجب أن يكون جاهزًا مستقبلًا لـ:

Cloud Sync

Multi-user

صلاحيات متقدمة

لوحة تحكم ويب

AI Assistant

OCR

Voice Commands

Analytics

---

20. القاعدة النهائية

أي قرار تقني داخل المشروع يجب أن يحقق:

الوضوح
الأداء
الأمان
القابلية للتوسع
سهولة الصيانة
تجربة استخدام احترافية