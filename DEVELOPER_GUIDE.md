# نظام إدارة الملفات في الأرشيف - دليل المطور

## نظرة عامة

تم تطوير نظام منظم لحفظ واسترجاع المستندات والملفات الخاصة بالمذكرات والأرشيف في تطبيق Mudiri.

## المشكلة الأصلية

- ملفات غير منظمة في مجلدات متعددة
- أسماء ملفات غير موحدة وصعب البحث عنها
- صعوبة إدارة الملفات المحذوفة
- عدم وضوح مسارات الملفات في قاعدة البيانات

## الحل المطبق

### 1. **FileStorageService** - خدمة مركزية

**الملف:** `lib/core/services/file_storage_service.dart`

**الدوال الأساسية:**

```dart
// الحصول على مجلد الأرشيف (ينشئه تلقائياً إذا لم يكن موجوداً)
Future<Directory> getArchiveDirectory()

// إنشاء اسم ملف موحد
static String generateFileName({
  required String title,
  String? referenceNumber,
  String extension = 'pdf',
})

// حفظ ملف في الأرشيف
Future<String> saveFile({
  required File sourceFile,
  required String filename,
})

// استرجاع ملف من الأرشيف
Future<File?> getFile(String? filePath)

// حذف ملف من الأرشيف
Future<bool> deleteFile(String? filePath)

// سرد جميع الملفات
Future<List<File>> listAllFiles()

// الحصول على حجم الملف
Future<int> getFileSize(String? filePath)
```

### 2. **تحديث ArchiveRepository**

**الملف:** `lib/features/archive/domain/archive_repository.dart`

تم تحديث الـ repository لاستخدام FileStorageService:

```dart
// الآن يحفظ الملف تلقائياً باسم منظم
await repository.createArchiveRecord(
  title: 'تقرير شهري',
  referenceNumber: '2025/001',
  localFilePath: '/temp/report.pdf',
  // ... باقي البيانات
);
```

**ما يحدث تلقائياً:**
1. ✅ إنشاء اسم موحد: `تقرير شهري-2025/001-1700000000.pdf`
2. ✅ حفظ الملف في `mudiri_archive/`
3. ✅ حفظ المسار الكامل في قاعدة البيانات
4. ✅ تسجيل العملية في السجلات

### 3. **ArchiveFileHelper** - أداة مساعدة

**الملف:** `lib/features/archive/presentation/archive_file_helper.dart`

دوال مساعدة لعمليات الملفات في الواجهة:

```dart
// فتح ملف من الأرشيف
ArchiveFileHelper.openFile(
  filePath: record.localFilePath,
  onError: (error) => showErrorMessage(error),
);

// عرض معلومات الملف
ArchiveFileHelper.buildFileInfoWidget(
  filePath: record.localFilePath,
  context: context,
);

// الحصول على حجم الملف بصيغة مقروءة
final size = await ArchiveFileHelper.getFileSizeDisplay(record.localFilePath);
```

## معايير التسمية

### الصيغة:
```
{موضوع}-{رقم}-{الطابع الزمني}.{الامتداد}
```

### قواعد التنظيف:
- الأحرف غير المسموحة (`\ / : * ? " < > |`) → `-`
- الفراغات المتعددة → `-`
- الفواصل المتعددة في الطرفين → يتم حذفها
- الطابع الزمني → يضمن عدم التضارب

### أمثلة:
```
تقرير الأداء-2025/01-1700000000.pdf
عقد التوظيف-خ-201-1700000100.docx
مذكرة إدارية-101-1700000200.xlsx
```

## البنية المجلدية

```
App Documents Directory
└── mudiri_archive/                          # مجلد الأرشيف الرئيسي
    ├── تقرير-2025-1700000000.pdf
    ├── مذكرة-101-1700000100.pdf
    ├── عقد-خ-201-1700000200.docx
    └── ...
```

## أمثلة استخدام

### مثال 1: حفظ مذكرة مع ملف

```dart
class CreateArchiveScreen extends ConsumerStatefulWidget {
  // ...
  
  Future<void> _submit() async {
    final repository = ref.read(archiveRepositoryProvider);
    
    // تم تحديثها لاستخدام FileStorageService تلقائياً
    await repository.createArchiveRecord(
      title: _titleController.text.trim(),
      referenceNumber: _refNumberController.text.trim(),
      documentDate: _gregorianDateStr,
      hijriDate: _hijriDateStr,
      directedEntity: _directedEntityController.text.trim(),
      category: finalCategory,
      localFilePath: localPdfPath, // يتم حفظه تلقائياً
      tags: '',
      notes: _notesController.text.trim(),
      isConfidential: _isConfidential,
    );
  }
}
```

### مثال 2: عرض قائمة الملفات وفتحها

```dart
// في شاشة عرض الأرشيف
archiveData.forEach((record) {
  // عرض معلومات الملف إن وُجد
  ArchiveFileHelper.buildFileInfoWidget(
    filePath: record.localFilePath,
    context: context,
  );
});
```

### مثال 3: استخدام FileStorageService مباشرة

```dart
final fileStorage = FileStorageService();

// إنشاء اسم موحد
final filename = FileStorageService.generateFileName(
  title: 'تقرير سنوي',
  referenceNumber: '2025',
  extension: 'pdf',
);

// حفظ ملف
final savedPath = await fileStorage.saveFile(
  sourceFile: File('/path/to/report.pdf'),
  filename: filename,
);

// استرجاع ملف
final file = await fileStorage.getFile(savedPath);

// حذف ملف
await fileStorage.deleteFile(savedPath);
```

## الفوائد

✅ **التنظيم:**
- جميع الملفات في مكان واحد
- أسماء موحدة وسهل البحث

✅ **الأمان:**
- إمكانية تطبيق أذونات على مجلد واحد
- سهل التحكم في الوصول

✅ **الأداء:**
- بحث سريع عن الملفات
- عدم تكرار الملفات

✅ **سهولة الصيانة:**
- إدارة مركزية
- سهل التتبع والحذف

## نقاط مهمة للمطورين

### عند التطوير:

1. **استخدم FileStorageService دائماً** للعمليات المتعلقة بالملفات

2. **لا تحفظ المسارات المطلقة** في قاعدة البيانات مباشرة - دع الخدمة تتولى ذلك

3. **تعامل مع الأخطاء** عند فتح الملفات:
```dart
ArchiveFileHelper.openFile(
  filePath: record.localFilePath,
  onError: (error) {
    print('Error: $error');
    // Show user-friendly error message
  },
);
```

4. **استخدم getFile() قبل أي عملية** للتحقق من وجود الملف

### الاختبار:

```dart
test('generateFileName creates proper names', () {
  final filename = FileStorageService.generateFileName(
    title: 'تقرير',
    referenceNumber: '2025/001',
    extension: 'pdf',
  );
  
  expect(filename, contains('تقرير'));
  expect(filename, contains('2025'));
  expect(filename.endsWith('.pdf'), true);
});
```

## الخطوات التالية

- [ ] إضافة فئات فرعية حسب نوع المستند
- [ ] دعم البحث المتقدم عن الملفات
- [ ] إمكانية ضغط الملفات
- [ ] سجل وصول شامل للملفات السرية
- [ ] نسخ احتياطية تلقائية

## المراجع

- `ARCHIVE_FILE_SYSTEM.md` - توثيق شامل للنظام
- `lib/core/services/file_storage_service.dart` - الكود المصدري
- `lib/features/archive/domain/archive_repository.dart` - تطبيق العملية
