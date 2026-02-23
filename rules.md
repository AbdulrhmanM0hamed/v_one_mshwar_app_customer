# Migration Rules — Remove GetX & Restructure Project (Data + Presentation + Cubit)

## 0) الهدف الأساسي (Non-Negotiables)

1. ممنوع استخدام GetX نهائيًا:
   - ممنوع: Get.put / Get.find / GetBuilder / Obx / Rx / Get.to / Get.off / GetxController / Bindings / GetMiddleware / GetConnect.
   - أي Import لـ get: يُزال بالكامل.
   - أي خدمة/كونترولر GetX لازم يتعاد بناؤه بالهيكل الجديد.

2. نفس الوظيفة + نفس التصميم + نفس الصفحات:
   - UI لازم يفضل 1:1 كما هو: نفس Widgets، نفس Layout، نفس Texts، نفس Styles، نفس Navigation flow.
   - ممنوع “تحسين UI” أو “Refactor design” أو تغيير ترتيب عناصر.
   - ممنوع تغيير أسماء Routes أو سلوك التنقل، إلا إذا كان مرتبط بإزالة GetX فقط (ويتم محاكاته تمامًا).

3. نفس الـ Endpoints ونفس الـ request/response:
   - نفس URL، نفس Headers، نفس Body، نفس Query params، نفس parsing، نفس error handling behavior.
   - ممنوع تغيير Contract مع الـ Backend.

4. كل Feature تتنقل بالكامل:
   - أي Feature لا تعتبر “منتهية” إلا لما تشتغل بالكامل زي القديم.
   - ممنوع نقل جزء وترك جزء في GetX.

5. كل Feature لازم تُقرأ وتتفهم قبل الشغل:
   - افهم: الـ UI flow، مصادر البيانات، حالات التحميل/الخطأ، الكاش، صلاحيات المستخدم، الحالات الحديّة.
   - اعمل “Feature Map” صغير قبل التنفيذ: (Pages -> Data calls -> States -> Navigation).

---

## 1) الهيكلية الجديدة (مطلوبة)

المشروع يتقسم إلى:

- data/
  - model/
  - response_model/
  - repo/ (Repository + RepositoryImpl في نفس الملف)
  - di/ (Dependency Injection)

- presentation/
  - pages/
  - widgets/
  - cubits/

### 1.1 شكل Feature-based (موصى به)

lib/
core/
di/
network/
errors/
utils/
constants/
features/
<feature_name>/
data/
model/
response_model/
repo/
di/
presentation/
pages/
widgets/
cubits/

> ممنوع خلط ملفات Feature مع Feature أخرى.

---

## 2) قواعد Data Layer

### 2.1 Models

- model/: Models للدومين داخل التطبيق (كيانات/Entities بسيطة).
- response_model/: Models خاصة بالـ API response (DTO).
- ممنوع خلط UI logic داخل models.

### 2.2 Repository + RepositoryImpl في نفس الملف (شرط)

- ملف واحد مثلًا:
  - `user_repo.dart` يحتوي:
    - abstract class UserRepo
    - class UserRepoImpl implements UserRepo
- الـ RepoImpl يعتمد على Network client (Dio مثلًا) من core/network.

### 2.3 Network Rules

- ممنوع تكرار إعدادات Dio في كل Feature.
- core/network يحتوي:
  - Dio client config
  - interceptors
  - base options
  - logging (اختياري)

### 2.4 Error Handling Rules

- لازم Behavior الأخطاء يطابق القديم:
  - نفس الرسائل إن وجدت
  - نفس fallback إن موجود
- يفضل استخدام Result/Failure pattern لكن بدون تغيير السلوك النهائي.
- ممنوع رمي Exceptions لواجهة المستخدم بدون تحويلها لـ state.

---

## 3) قواعد Presentation Layer (UI ثابت + Cubit)

### 3.1 Pages

- كل صفحة تبقى زي ما هي في الشكل 1:1
- لو الصفحة قديمة بتستخدم GetX state:
  - يتم استبدالها بـ BlocBuilder/BlocListener (أو BlocConsumer) بدون تغيير layout.

### 3.2 Widgets

- Widgets تُنقل كما هي قدر الإمكان.
- ممنوع تحويل كل شيء Stateless/Stateful إلا للضرورة (لإزالة GetX فقط).

### 3.3 Cubits

- لكل Feature: Cubit أو أكثر حسب الحاجة.
- الحالات (States) لازم تغطي:
  - Initial
  - Loading
  - Success (مع الداتا)
  - Error (مع message)
- أي سلوك قديم (مثل pagination, refresh, retry) لازم يكون موجود.

---

## 4) أهم قاعدة: BlocProvider لازم يتوفر صح (منع Exceptions)

### 4.1 Provider مكانه

- ممنوع فتح صفحة تعتمد على Cubit بدون توفير BlocProvider فوقها في الشجرة.
- القاعدة:
  - لكل Page لها Cubit: يتم توفير BlocProvider في Route builder أو في صفحة Wrapper.
- لو في صفحات داخل feature تستخدم نفس Cubit:
  - استخدم BlocProvider.value عند الـ navigation لإعادة استخدام نفس instance.

### 4.2 قواعد Navigation بدون GetX

- استبدال Get.to بـ:
  - Navigator.push / pushNamed
- استبدال Get.off بـ:
  - Navigator.pushReplacement
- استبدال Get.offAll بـ:
  - Navigator.pushAndRemoveUntil

### 4.3 ممنوع الوصول لـ Cubit بطريقة خاطئة

- ممنوع: context.read في initState قبل ما BlocProvider يتبني.
- لو محتاج call عند فتح الصفحة:
  - استخدم:
    - WidgetsBinding.instance.addPostFrameCallback
    - أو BlocProvider create ثم call داخل create (بحذر)
- أي استخدام خاطئ يسبب exception لازم يتصلح مباشرة.

---

## 5) DI Rules (Dependency Injection)

- DI لكل Feature داخل:
  - features/<feature>/data/di/<feature>\_di.dart
- وفي core/di/ يوجد setup عام (إن احتجنا).

### 5.1 المسموح

- get_it (مفضل)
- injectable (اختياري)
- BlocProvider مش DI بديل — لكنه لتوفير الـ Cubit للـ UI.

### 5.2 ممنوع

- أي Service Locator من GetX
- أي static singletons غير مبررة

---

## 6) خطة الهجرة (Feature by Feature) — Mandatory

### 6.1 قبل نقل أي Feature

1. حصر صفحات الفيتشر:
   - List كل Pages + Widgets الأساسية.
2. حصر الـ Endpoints المستخدمة.
3. حصر حالات الـ UI:
   - Loading / Empty / Error / Success / Pagination إن وجدت.
4. حصر Navigation flow (من/إلى).

### 6.2 أثناء النقل

- أنشئ الهيكل الجديد للفيتشر.
- انقل UI كما هو أولاً (حتى لو لسه الداتا mock).
- أضف Cubit + States.
- اربط Repo بالـ Cubit.
- اربط الصفحة بـ BlocProvider + BlocBuilder/Listener.

### 6.3 بعد النقل

- تحقق من:
  - نفس الشكل 1:1
  - نفس الوظيفة 1:1
  - نفس الـ API calls
  - نفس الأخطاء/الرسائل
- ثم احذف أي GetX leftovers من الفيتشر بالكامل.

> ممنوع ترك “GetX جزء صغير” بحجة إنه صعب.

---

## 7) قواعد التسمية (Naming)

- Features: snake_case (مثال: user_profile)
- Cubit: PascalCase (UserProfileCubit)
- States: UserProfileState + sub states أو sealed classes.
- Files:
  - user_profile_page.dart
  - user_profile_cubit.dart
  - user_profile_state.dart
  - user_profile_repo.dart (contains interface + impl)

---

## 8) Acceptance Checklist (لازم تتعمل لكل Feature)

- [ ] لا يوجد أي import لـ get في feature
- [ ] UI مطابق 1:1 (Screenshots مقارنة لو متاح)
- [ ] Navigation نفس السلوك
- [ ] Endpoints مطابقة (URL/headers/body/params)
- [ ] لا يوجد runtime exceptions بسبب BlocProvider
- [ ] States تغطي كل الحالات القديمة
- [ ] Repo interface + impl في نفس الملف
- [ ] DI جاهز وتسجيل dependencies تم
- [ ] الكود قابل للقراءة ومفصول Data/Presentation

---

## 9) مثال Skeleton (Reference Only — لا تغيّر UI)

features/auth/
data/
model/
response_model/
repo/
auth_repo.dart (AuthRepo + AuthRepoImpl)
di/
auth_di.dart
presentation/
cubits/
auth_cubit.dart
auth_state.dart
pages/
login_page.dart
widgets/
login_form.dart

---

## 10) ممنوعات إضافية (Strict)

- ممنوع تغيير التصميم أو إضافة animations جديدة أو تحسينات.
- ممنوع تغيير الـ API أو refactor في backend contract.
- ممنوع دمج Features مع بعض.
- ممنوع تخطي “فهم الفيتشر” قبل الشغل.
- ممنوع شغل “نص Feature” وترك الباقي.
