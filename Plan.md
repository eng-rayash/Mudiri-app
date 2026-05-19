خطة مشروع تطبيق "مديري" الإدارة التنفيذية والمكتب التنفيذي

اسم المشروع

مديري

تطبيق جوال احترافي يعمل بدون إنترنت لإدارة أعمال المدير العام والمكتب التنفيذي والسكرتارية.

---

الرؤية العامة للمشروع

تطوير تطبيق جوال احترافي يعمل بالكامل محليًا (Offline) لإدارة:

الاجتماعات

المواعيد

المهام

التوجيهات الإدارية

المتابعات

الأرشفة

التقارير

نشاط المدير التنفيذي اليومي

التطبيق يستهدف:

المدير العام

المدير التنفيذي

السكرتارية

رجال الأعمال

المكاتب التنفيذية

---

فلسفة النظام التشغيلية

دورة العمل الأساسية داخل النظام:

اجتماع ↓ مخرجات / قرارات ↓ مهام تنفيذ ↓ متابعة ↓ تغذية راجعة ↓ تقرير نهائي

الهدف من هذه الدورة:

ضمان تنفيذ القرارات

متابعة الأداء

توثيق العمل الإداري

تسهيل إدارة المكتب التنفيذي

---

نوع التطبيق

تطبيق جوال فقط

يعمل بدون إنترنت بالكامل

تخزين محلي داخل الجهاز

يدعم أندرويد أولًا

قابل للتوسع مستقبلًا لـ iOS

---

التقنيات المقترحة

Framework

Flutter

قاعدة البيانات المحلية

Hive أو SQLite

التنبيهات

flutter_local_notifications

الحماية

local_auth

إدارة الحالة

Riverpod أو Provider

---

الوحدات الأساسية (Core Modules)

1. Dashboard

2. Meetings

3. Appointments

4. Tasks

5. Work Matrix Execution

6. Directives

7. Visitors

8. Calls

9. Quick Notes

10. Archive

11. Reports

12. Contacts

13. Follow-ups

14. Notifications

15. Timeline

---

النماذج الإدارية المعتمدة

1. نموذج الاجتماعات

الحقول الأساسية

نوع الاجتماع

عنوان الاجتماع

التاريخ

الوقت

المكان

الحضور

هدف الاجتماع

جدول الأعمال

القرارات

مخرجات الاجتماع

المرفقات

حالة الاجتماع

حالات الاجتماع

مجدول

مكتمل

مؤجل

ملغي

---

2. نموذج المواعيد

يحتوي على

نوع الموعد

التاريخ

الوقت

الموقع

الشخص المرتبط

التذكير

الملاحظات

---

3. نموذج المهام

يحتوي على

عنوان المهمة

الوصف

الأولوية

الموعد النهائي

نسبة الإنجاز

المسؤول

المرفقات

حالة التنفيذ

---

4. نموذج تنفيذ مصفوفة العمل

يحتوي على

مخرجات الاجتماع

المهام المتفق عليها

الجهة المنفذة

الإجراءات المتخذة

نتائج التنفيذ / التغذية الراجعة

تاريخ التنفيذ

أسباب التعثر

حالة التنفيذ

الملاحظات

---

5. نموذج التوجيهات الإدارية

يحتوي على

نص التوجيه

الجهة المنفذة

تاريخ الإصدار

موعد التنفيذ

حالة التنفيذ

الملاحظات

المتابعة

---

6. نموذج الزوار

يحتوي على

اسم الزائر

الجهة

رقم التواصل

سبب الزيارة

وقت الدخول

وقت الخروج

الشخص المطلوب

الملاحظات

---

7. نموذج المكالمات

يحتوي على

اسم المتصل

الجهة

سبب الاتصال

وقت الاتصال

حالة الرد

هل يحتاج متابعة

الملاحظات

---

8. نموذج الملاحظات السريعة

يحتوي على

العنوان

النص

التاريخ

التصنيف

الأهمية

---

9. نموذج الملفات والأرشفة

يحتوي على

اسم الملف

نوع الملف

التصنيف

تاريخ الإضافة

مرتبط بأي سجل

الملاحظات

---

10. نموذج التقارير

أنواع التقارير

تقرير يومي

تقرير أسبوعي

تقرير الاجتماعات

تقرير التنفيذ

تقرير الأداء

---

11. نموذج جهات الاتصال

يحتوي على

الاسم

المنصب

الجهة

رقم التواصل

البريد الإلكتروني

آخر تواصل

الملاحظات

---

12. نموذج المتابعة

يحتوي على

العنصر المرتبط

نوع المتابعة

تاريخ المتابعة

حالة المتابعة

الملاحظات

النتيجة

---

Dashboard الذكي

يحتوي على

قسم اليوم

اجتماعات اليوم

المواعيد القادمة

المهام العاجلة

المتابعات المطلوبة

قسم الإحصائيات

عدد الاجتماعات

عدد المهام

نسبة الإنجاز

المهام المتأخرة

التوجيهات المفتوحة

قسم التنبيهات

اجتماع قريب

مهمة متأخرة

متابعة مطلوبة

قسم النشاط الأخير

آخر اجتماع

آخر مهمة

آخر اتصال

آخر توجيه

---

نظام الحالات الموحد

الحالات

جديد

قيد التنفيذ

بانتظار الرد

مكتمل

متأخر

متعثر

ملغي

---

نظام الأولويات

عاجل جدًا

عالي

متوسط

منخفض

---

الربط بين النماذج

النظام يعتمد على الربط بين:

الاجتماعات

المهام

المتابعات

التقارير

التوجيهات

الأرشيف

مثال: اجتماع ← ينتج مهام ← تحتاج متابعة ← تنتج تقرير

---

الميزات الأساسية

البحث الشامل

البحث داخل:

الاجتماعات

الملفات

الأشخاص

الملاحظات

المهام

التوجيهات

---

التقويم المركزي

يعرض:

الاجتماعات

المواعيد

المتابعات

الأحداث

---

التنبيهات المحلية

تنبيه اجتماع

تنبيه مهمة

تنبيه متابعة

ملخص يومي

---

نظام الأرشفة الذكية

التصنيف حسب:

التاريخ

الجهة

نوع السجل

المشروع

الاجتماع

---

النسخ الاحتياطي

تصدير JSON

تصدير SQLite

استيراد نسخة احتياطية

---

الحماية والأمان

بصمة

كلمة مرور

قفل تلقائي

حماية البيانات الحساسة

---

المرفقات

دعم:

PDF

الصور

ملفات Word

تسجيلات صوتية

---

التسجيل الصوتي

إضافة ملاحظات صوتية مرتبطة بالسجلات.

---

Quick Actions

إضافة اجتماع

إضافة مهمة

تسجيل اتصال

إضافة ملاحظة

---

Timeline التنفيذي

عرض جميع الأنشطة بشكل زمني مرتب.

---

الفلاتر والتصفية

مثل:

المهام المتأخرة

اجتماعات هذا الأسبوع

المتابعات المفتوحة

---

ميزة محضر الاجتماع الاحترافي

يتضمن:

جدول الأعمال

الحضور

القرارات

المهام

المسؤوليات

مواعيد التنفيذ

---

ميزة "يومي"

تعرض:

اجتماعات اليوم

المهام

المكالمات

التذكيرات

المتابعات

---

المساعد التنفيذي

ميزة ذكية تعرض:

المهام المتعثرة

المتابعات المتأخرة

الاجتماعات غير المكتملة

---

الهدف النهائي للمشروع

بناء تطبيق نظام تنفيذي احترافي لإدارة أعمال المدير العام والمكتب التنفيذي بطريقة منظمة وسريعة وعملية، مع إمكانية تطويره لاحقًا إلى منتج تجاري احترافي قابل للبيع للشركات والمؤسسات.

فلسفة تجربة المستخدم للنظام التنفيذي

التطبيق يجب أن يكون:

بسيط

سريع

احترافي

رسمي

واضح

قليل الخطوات

مناسب للمدراء التنفيذيين والسكرتارية

الهدف الأساسي: تقليل الوقت والضغطات المطلوبة للوصول للمعلومة أو تنفيذ الإجراء.

---

قواعد UX الأساسية

1. قاعدة الثلاث ضغطات

أي عملية داخل التطبيق يجب ألا تتجاوز 3 ضغطات قدر الإمكان.

---

2. إظهار المعلومات المهمة أولًا

الأولوية دائمًا لـ:

الحالة

التاريخ

الأولوية

الإجراءات المطلوبة

---

3. واجهة غير مزدحمة

استخدام:

بطاقات Cards

أيقونات واضحة

ألوان للحالات

خطوط واضحة

مساحات مريحة

---

الهيكل الرئيسي للتنقل

Bottom Navigation

الأقسام الرئيسية

1. الرئيسية

2. الاجتماعات

3. المهام

4. المتابعة

5. المزيد

---

شاشة البداية Splash

تحتوي على

شعار التطبيق

اسم التطبيق

تحميل سريع

ثم الانتقال إلى:

شاشة القفل أو التحقق بالبصمة

---

نظام الحماية والدخول

طرق الدخول

PIN Code

بصمة

Face Unlock مستقبلًا

---

الشاشة الرئيسية Dashboard

مكونات Dashboard

1. الشريط العلوي

يحتوي على:

اسم المستخدم

التاريخ

البحث

الإشعارات

---

2. ملخص اليوم

بطاقات سريعة تعرض:

اجتماعات اليوم

مهام اليوم

المتابعات

المواعيد القادمة

---

3. النشاط التنفيذي Timeline

يعرض آخر الأنشطة:

اجتماع

مهمة

متابعة

توجيه

---

4. التنبيهات المهمة

مثل:

مهمة متأخرة

اجتماع قريب

متابعة مطلوبة

---

5. الإجراءات السريعة Quick Actions

أزرار مباشرة:

اجتماع جديد

مهمة جديدة

تسجيل اتصال

ملاحظة سريعة

---

UX الملفات والأرشفة

التصنيفات

اجتماعات

مهام

تقارير

توجيهات

---

الميزات

المعاينة

البحث

الفرز

---

UX جهات الاتصال

البطاقة تحتوي على

الاسم

المنصب

الجهة

آخر تواصل

---

الإجراءات السريعة

اتصال

موعد

اجتماع

ملاحظة

---

UX المكالمات

تصميم سريع وبسيط

زر: تسجيل مكالمة

ثم:

الاسم

السبب

النتيجة

---

UX الملاحظات السريعة

Floating Action Button دائم

يفتح:

كتابة ملاحظة

تسجيل صوتي

---

UX Timeline التنفيذي

يعرض

كل الأنشطة بالترتيب الزمني:

الاجتماعات

المهام

المتابعات

الملفات

التوجيهات

---

UX الإشعارات

أنواع الإشعارات

تنبيه

تذكير

تأخير

متابعة

---

سلوك الإشعار

عند الضغط يفتح السجل المرتبط مباشرة.

---

---

الخطوط المعتمدة

الخطوط الأساسية للتطبيق

Tajawal

IBM Plex Sans Arabic

آلية الاستخدام

Tajawal للنصوص العامة والواجهات اليومية

IBM Plex Sans Arabic للعناوين والعناصر التنفيذية والاحترافية

---

الأيقونات المقترحة

Material Symbols

Lucide Icons

---

الميزات الإدارية المعتمدة

دعم كامل لإدارة السجلات

كل نموذج داخل النظام يدعم:

إضافة سجل جديد

تعديل السجل

حذف السجل

أرشفة السجل

استعادة السجل

نسخ السجل

---

Activity Log

أي تعديل داخل النظام يتم تسجيله تلقائيًا:

من قام بالتعديل

وقت التعديل

نوع التعديل

البيانات المعدلة

---

نظام المهام

يدعم:

إنشاء مهام مستقلة

إنشاء مهام ناتجة عن الاجتماعات

تحديث حالة التنفيذ

تحديد المسؤوليات

المتابعة المستمرة

---

الفلاتر والبحث والتصفية

جميع النماذج تدعم:

البحث اللحظي

الفلاتر حسب التاريخ

الفلاتر حسب الاسم

الفلاتر حسب الحالة

الفلاتر حسب الأولوية

الترتيب Sorting

---

الجداول الاحترافية Data Tables

إمكانية عرض البيانات على شكل:

Cards

Lists

Data Tables

---

التصدير والمشاركة

دعم تصدير البيانات بصيغ:

Excel

PDF

CSV

صورة

JSON

مع دعم:

المشاركة المباشرة

الحفظ داخل الجهاز

الطباعة مستقبلًا

---

مبادئ UX النهائية

التطبيق ليس مجرد أداة إدخال بيانات.

بل:

مركز قيادة تنفيذي

نظام متابعة وتنفيذ

واجهة احترافية سريعة

بيئة عمل يومية للمدير والسكرتارية

---

بعد المراجعة الملفات هذا تقييمي الكامل:

---

## ✅ ما هو ممتاز في الخطة

**الهيكل الفكري قوي جداً** — دورة العمل (اجتماع ← مهام ← متابعة ← تقرير) منطقية وصحيحة، وClean Architecture + Riverpod + Drift خيارات هندسية ناضجة.

---

## ⚠️ ملاحظاتي ومقترحاتي

### 1. 🔴 مشكلة حجم المشروع مقابل الـ MVP

الخطة الحالية تبدأ بـ **15 وحدة دفعة واحدة** — هذا خطأ استراتيجي كبير.

**المقترح:**
```
MVP الحقيقي = 4 وحدات فقط:
  Dashboard → Meetings → Tasks → Follow-ups

بعد الإطلاق تُضاف:
  Directives → Reports → Archive → Contacts
```

---

### 2. 🔴 غياب نموذج الصلاحيات (Roles)

الخطة تذكر "المدير والسكرتارية" لكن لا يوجد نظام صلاحيات في الـ ERD.

**المقترح — إضافة جدول `user_roles`:**
```
المدير العام    → يرى كل شيء + يعتمد
السكرتير        → يُدخل + يُعدّل
المشاهد         → قراءة فقط
```

---

### 3. 🟡 الـ ERD يحتاج تحسينات

مشكلتان تقنيتان:

**أولاً** — `related_record_type` + `related_record_id` في جداول `Followups` و`Archives` و`Notifications` هو **Polymorphic Association** — صعب الاستعلام عليه في SQLite.

**المقترح:**
```sql
-- بدلاً من polymorphic، استخدم nullable FKs:
followups (
  task_id       INTEGER REFERENCES tasks(id),
  meeting_id    INTEGER REFERENCES meetings(id),
  directive_id  INTEGER REFERENCES directives(id)
  -- فقط واحد منهم يكون NOT NULL
)
```

**ثانياً** — `Work_Execution_Matrix` هو في الواقع امتداد لجدول `Tasks`، يمكن دمجهما بحقل `execution_details` JSON لتبسيط الاستعلامات.

---

### 4. 🟡 UX — قاعدة الـ 3 ضغطات غير مطبقة فعلياً

الشاشات المصممة تحتوي على **Tabs + Filters + Search** في نفس الشاشة، وهذا يتعارض مع قاعدة الـ 3 ضغطات.

**المقترح — Smart Dashboard يقلص الضغطات:**
```
الشاشة الرئيسية تعرض:
  ● "اليوم" — كل شيء مجمع في بطاقة واحدة
  ● Contextual Actions — الإجراء الأكثر احتمالاً بزر واحد
  ● Smart Suggestions — "لديك اجتماع بعد ساعة"
```

---

### 5. 🟡 التصميم — Glassmorphism خطر على الأداء

Glassmorphism يستهلك GPU بشكل مرتفع على الأجهزة المتوسطة والضعيفة (وهي الغالبية في السوق المستهدف).

**المقترح — استخدم Neumorphism خفيف بدلاً منه:**
```dart
// بدلاً من BackdropFilter (ثقيل)
BoxDecoration(
  color: Color(0xFFF5F7FA),
  borderRadius: BorderRadius.circular(20),
  boxShadow: [
    BoxShadow(color: Color(0xFFD1D9E6), offset: Offset(6, 6), blurRadius: 12),
    BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 12),
  ],
)
```

---

### 6. 🟡 غياب استراتيجية الـ Sync المستقبلية

التطبيق Offline الآن، لكن الخطة تذكر "منتج تجاري مستقبلاً" — وهذا يعني Cloud Sync لاحقاً.

**المقترح — بنِ قاعدة البيانات جاهزة للـ Sync من اليوم:**
```sql
-- أضف لكل جدول:
created_at    INTEGER NOT NULL,
updated_at    INTEGER NOT NULL,
is_deleted    INTEGER DEFAULT 0,  -- Soft delete
sync_id       TEXT UNIQUE          -- UUID للمزامنة المستقبلية
```

---

### 7. 🟢 مقترح إضافي — Smart Shortcuts

**ميزة "الإجراء الذكي"** غائبة تماماً من الخطة وهي قاتلة للـ UX:
```
بعد إنشاء اجتماع → "إنشاء مهمة من الاجتماع؟" [زر واحد]
بعد تأخر مهمة   → "تحديث الحالة أو تمديد الموعد؟" [خياران]
في الصباح        → "ملخص يومك: 2 اجتماع، 5 مهام" [نوتيفكيشن ذكي]
```

---

### 8. 🟢 مقترح — نظام الـ Templates

غائب من الخطة وضروري جداً للمدير:
```
قوالب اجتماعات جاهزة:
  ● اجتماع أسبوعي (حضور + جدول أعمال محفوظ)
  ● مراجعة الأداء الشهري
  ● اجتماع إدارة الأزمات
```

---

---

# خطة التطبيق الكامل — المراجعة النهائية

---

## 🏗️ استراتيجية البناء الكامل (لا MVP)

بناء كامل لكن **بترتيب صحيح** — كل مرحلة تعمل وتُسلَّم:

```
المرحلة 1 — الأساس + الحماية + Dashboard + Meetings
المرحلة 2 — Tasks + Follow-ups + Work Matrix + Directives  
المرحلة 3 — Reports + Archive + Contacts + Appointments
المرحلة 4 — Calls + Visitors + Notes + Timeline
المرحلة 5 — Notifications + Backup + Export + Polish
```

---

## 🎨 نظام Neumorphism الاحترافي

### فلسفة التصميم
```
Soft UI + Executive Neumorphism
ليس الـ Neumorphism الكلاسيكي الثقيل
بل نسخة تنفيذية خفيفة وسريعة
```

### نظام الألوان المقترح

**Light Theme — الأساس:**
```dart
// خلفية موحدة (قلب الـ Neumorphism)
static const bgColor     = Color(0xFFE8EDF2);  // رمادي مزرق ناعم
static const shadowDark  = Color(0xFFC8CDD8);  // الظل الداكن
static const shadowLight = Color(0xFFFFFFFF);  // الظل الفاتح

// الألوان التنفيذية
static const navyDeep   = Color(0xFF1E3A5F);   // الهوية الرئيسية
static const navyMid    = Color(0xFF274C77);
static const goldAccent = Color(0xFFD4A373);   // الذهبي التنفيذي
static const surface    = Color(0xFFEEF2F7);   // سطح البطاقات

// الحالات
static const success    = Color(0xFF2E8B57);
static const warning    = Color(0xFFF4A261);
static const danger     = Color(0xFFD62828);
static const info       = Color(0xFF3B82F6);
```

**Dark Theme:**
```dart
static const bgColorDark     = Color(0xFF1E2530);
static const shadowDarkDark  = Color(0xFF161C26);
static const shadowLightDark = Color(0xFF2A3444);
static const surfaceDark     = Color(0xFF242D3A);
```

### مكونات Neumorphism الأساسية

```dart
// الـ Decoration الأساسي — يُستخدم في كل مكان
BoxDecoration neuFlat({
  double radius = 20,
  bool isDark = false,
}) => BoxDecoration(
  color: isDark ? bgColorDark : bgColor,
  borderRadius: BorderRadius.circular(radius),
  boxShadow: [
    BoxShadow(
      color: isDark ? shadowDarkDark : shadowDark,
      offset: Offset(6, 6),
      blurRadius: 14,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: isDark ? shadowLightDark : shadowLight,
      offset: Offset(-6, -6),
      blurRadius: 14,
      spreadRadius: 1,
    ),
  ],
);

// Pressed / Active state
BoxDecoration neuPressed({double radius = 20}) => BoxDecoration(
  color: bgColor,
  borderRadius: BorderRadius.circular(radius),
  boxShadow: [
    BoxShadow(
      color: shadowDark,
      offset: Offset(2, 2),
      blurRadius: 5,
    ),
    BoxShadow(
      color: shadowLight,
      offset: Offset(-2, -2),
      blurRadius: 5,
    ),
  ],
);

// Concave — للـ inputs
BoxDecoration neuConcave({double radius = 16}) => BoxDecoration(
  color: bgColor,
  borderRadius: BorderRadius.circular(radius),
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [shadowDark.withOpacity(0.4), bgColor],
  ),
  boxShadow: [
    BoxShadow(color: shadowDark, offset: Offset(4,4), blurRadius: 10),
    BoxShadow(color: shadowLight, offset: Offset(-4,-4), blurRadius: 10),
  ],
);
```

### نماذج الشاشات

```
Dashboard Card:        neuFlat(radius: 24)  + gold top border 3px
Meeting Card:          neuFlat(radius: 20)  + status color left bar 5px
Task Card:             neuFlat(radius: 16)  + progress bar neumorphic
Input Fields:          neuConcave(radius:16)+ label floating
Buttons (Primary):     neuFlat  → neuPressed (animation 150ms)
Bottom Nav:            neuFlat(radius: 0)   + selected item neuPressed
FAB:                   neuFlat(radius: 50)  + gold icon
Stats Widget:          neuFlat(radius: 20)  + number large bold navy
```

### قواعد التصميم الصارمة

```
✅ خلفية موحدة في كل الشاشات (bgColor فقط)
✅ الظلان دائماً: داكن bottom-right / فاتح top-left
✅ الـ radius ثابت لكل نوع مكوّن
✅ الحركة: 150ms cubic-bezier للضغط
✅ فقط عنصر واحد بالذهبي في كل شاشة
❌ لا خلفيات ملونة كثيرة
❌ لا تدرجات gradient ثقيلة
❌ لا Glassmorphism نهائياً
```

---

## 🔐 منظومة الأمان والحماية

### طبقات الأمان (4 طبقات)

```
الطبقة 1 — دخول التطبيق
الطبقة 2 — حماية البيانات
الطبقة 3 — حماية التصدير
الطبقة 4 — حماية النسخ الاحتياطي
```

### الطبقة 1 — دخول التطبيق

```dart
// خيارات المصادقة بالترتيب
enum AuthMethod {
  biometric,    // بصمة إصبع أو وجه (الأولوية الأولى)
  pin,          // PIN 6 أرقام (fallback)
  pattern,      // نمط (اختياري)
}

// سياسة القفل التلقائي
class LockPolicy {
  static const lockAfterSeconds = 60;   // قفل بعد 60 ثانية عدم نشاط
  static const maxWrongAttempts = 5;    // حظر بعد 5 محاولات خاطئة
  static const lockoutMinutes   = 10;   // حظر لمدة 10 دقائق
  static const requireAuthOnStart = true;
}

// التطبيق يخفي محتواه عند الـ Screenshot والـ App Switcher
// في initState:
FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
```

### الطبقة 2 — تشفير قاعدة البيانات

```dart
// SQLCipher بدلاً من SQLite العادي
// أضف للـ pubspec:
// sqflite_sqlcipher: ^2.3.0

class DatabaseService {
  static const _dbName = 'mudiri.db';

  // المفتاح يُولَّد عشوائياً عند أول تشغيل
  // ويُخزَّن في flutter_secure_storage (Keychain/Keystore)
  Future<String> _getOrCreateKey() async {
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
    
    var key = await storage.read(key: 'db_encryption_key');
    if (key == null) {
      key = _generateSecureKey(32); // 256-bit key
      await storage.write(key: 'db_encryption_key', value: key);
    }
    return key;
  }
  
  String _generateSecureKey(int length) {
    final random = Random.secure();
    final values = List<int>.generate(length, (_) => random.nextInt(256));
    return base64Url.encode(values);
  }
}
```

### الطبقة 3 — حماية البيانات الحساسة في الـ UI

```dart
// أي حقل حساس يُخفى تلقائياً
class SensitiveField extends StatefulWidget {
  // عرض النجوم *** بشكل افتراضي
  // يتطلب ضغطة مطولة للكشف + مصادقة بيومترية
}

// منع Screenshot داخل شاشات بعينها
class SecureScreen extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }
  
  @override
  void dispose() {
    FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    super.dispose();
  }
}
```

### الطبقة 4 — حماية التصدير والنسخ الاحتياطي

```dart
class BackupSecurity {
  // كل نسخة احتياطية مشفرة بكلمة مرور يختارها المستخدم
  // + metadata للتحقق من سلامة الملف
  
  Future<File> createEncryptedBackup(String password) async {
    final dbFile   = await _exportDatabase();
    final salt     = _generateSalt();
    final key      = _deriveKey(password, salt); // PBKDF2
    final encrypted = await _encryptAES256(dbFile.bytes, key);
    
    final backup = BackupFile(
      version:    '1.0',
      createdAt:  DateTime.now().toIso8601String(),
      checksum:   _sha256(dbFile.bytes),  // للتحقق عند الاستيراد
      encrypted:  base64Encode(encrypted),
      salt:       base64Encode(salt),
    );
    return _saveToFile(jsonEncode(backup.toJson()));
  }
  
  // عند الاستيراد: تحقق من الـ checksum قبل القبول
  Future<bool> validateAndRestore(File backup, String password) async { }
}
```

### سياسة الـ Activity Log الأمنية

```dart
// كل إجراء حساس يُسجَّل (لا يمكن حذفه)
enum SecurityAction {
  login,
  failedLogin,
  exportData,
  deleteRecord,
  backupCreated,
  backupRestored,
  settingsChanged,
}

class SecurityLog {
  // جدول مستقل غير قابل للحذف من الواجهة
  // يحتفظ بآخر 500 إجراء
  // يتضمن: timestamp, action, details, deviceInfo
}
```

---

## 📋 جدول Drift المحدّث (مع حقول الأمان والـ Sync)

```dart
// أضف لكل جدول هذه الحقول الإلزامية:
class BaseColumns {
  IntColumn  get id         => integer().autoIncrement()();
  TextColumn get syncId     => text().withDefault(Constant(_uuid()))(); // للمستقبل
  IntColumn  get createdAt  => integer()();  // Unix timestamp
  IntColumn  get updatedAt  => integer()();
  BoolColumn get isDeleted  => boolean().withDefault(Constant(false))(); // Soft delete
  TextColumn get createdBy  => text().nullable()();  // للـ multi-user لاحقاً
}
```

---

## 🗂️ ترتيب ملفات المشروع النهائي

```
lib/
├── core/
│   ├── security/
│   │   ├── auth_service.dart          ← بصمة + PIN
│   │   ├── encryption_service.dart    ← AES-256
│   │   ├── secure_storage.dart        ← Keychain/Keystore
│   │   ├── lock_manager.dart          ← قفل تلقائي
│   │   └── security_logger.dart       ← سجل أمني
│   ├── database/
│   │   ├── app_database.dart          ← Drift + SQLCipher
│   │   ├── dao/                       ← واحد لكل جدول
│   │   └── migrations/
│   ├── theme/
│   │   ├── neu_colors.dart            ← ألوان Neumorphism
│   │   ├── neu_decorations.dart       ← الظلال والـ Box
│   │   ├── neu_components.dart        ← المكونات الجاهزة
│   │   ├── app_typography.dart
│   │   └── app_theme.dart
│   ├── router/
│   ├── services/
│   └── utils/
│
├── features/
│   ├── auth/                          ← أول ما يُبنى
│   ├── dashboard/
│   ├── meetings/
│   ├── tasks/
│   ├── followups/
│   ├── directives/
│   ├── reports/
│   ├── archive/
│   ├── contacts/
│   ├── appointments/
│   ├── calls/
│   ├── visitors/
│   ├── notes/
│   ├── timeline/
│   └── settings/
│
└── shared/
    ├── widgets/
    │   ├── neu_card.dart
    │   ├── neu_button.dart
    │   ├── neu_input.dart
    │   ├── neu_bottom_nav.dart
    │   ├── status_badge.dart
    │   └── priority_chip.dart
    └── extensions/
```

---

## ✅ خلاصة القرارات النهائية

| القرار | الاختيار |
|--------|---------|
| التصميم | Neumorphism تنفيذي خفيف |
| قاعدة البيانات | Drift + **SQLCipher** (مشفرة) |
| تشفير المفتاح | flutter_secure_storage (Keychain) |
| المصادقة | Biometric أولاً + PIN احتياطي |
| الـ Backup | مشفر AES-256 + PBKDF2 |
| الـ Soft Delete | إلزامي في كل جدول |
| حقول Sync | uuid + timestamps في كل جدول |
| Screenshot | محظور داخل التطبيق |

---