# PillMate

แอปพลิเคชันมือถือสำหรับเตือนและติดตามการรับประทานยา ช่วยให้ผู้ใช้ไม่ลืมทานยา
ตรวจสอบย้อนหลังได้ว่าทานไปแล้วหรือยัง และเก็บข้อมูลยาพร้อมรูปภาพไว้ดูได้ตลอดเวลา

ข้อมูลทั้งหมดถูกจัดเก็บภายในเครื่อง (Hive) ใช้งานได้แบบออฟไลน์ ไม่มีการส่งข้อมูลออกนอกอุปกรณ์

---

## ฟีเจอร์

| ฟีเจอร์ | รายละเอียด |
|---|---|
| จัดการยา | เพิ่ม / แก้ไข / ลบยา เก็บชื่อ ขนาดยา จำนวนที่ทาน หมายเหตุ และรูปภาพยา |
| รูปภาพยา | ถ่ายรูปจากกล้องหรือเลือกจาก Gallery คัดลอกไฟล์เก็บไว้ในเครื่อง |
| ตารางยา | ทุกวัน / เฉพาะวันในสัปดาห์ / ทุก X ชั่วโมง / ทุก X วัน กำหนดได้หลายเวลาต่อวัน และกำหนดช่วงวันที่เริ่ม-สิ้นสุด |
| แจ้งเตือน | Local notification ตามเวลาที่ตั้งไว้ มีปุ่ม "ทานแล้ว" และ "เลื่อน" บนการแจ้งเตือน พร้อมแจ้งเตือนซ้ำหากยังไม่ยืนยัน |
| ยาวันนี้ | รายการมื้อยาที่ต้องทานในวันนี้ พร้อมการ์ดสรุปความคืบหน้า (ทานแล้ว / เลื่อน / รอทาน) และยืนยันการทานได้เอง |
| ประวัติ | บันทึกสถานะ ทานแล้ว / เลื่อน / ข้าม พร้อมการ์ดสรุปตามตัวกรอง กรองตามช่วงเวลา (ค่าเริ่มต้น "วันนี้") และค้นหาตามชื่อยา |

---

## Tech Stack

| ด้าน | เทคโนโลยี |
|---|---|
| Framework | Flutter (Dart SDK ^3.12.2) |
| State Management | `flutter_riverpod` ^3.3.2 |
| Local Database | `hive` ^2.2.3 + `hive_flutter` |
| Navigation | `go_router` ^17.3.0 |
| Notification | `flutter_local_notifications` ^22.0.1 + `timezone` |
| Image | `image_picker` + `path_provider` |
| Testing | `flutter_test` + `mocktail` |
| CI/CD | Jenkins (`Jenkinsfile`) |
| สถาปัตยกรรม | Clean Architecture (Presentation → Domain → Data) |

---

## เริ่มต้นใช้งาน

### สิ่งที่ต้องมี

- Flutter SDK (Dart ^3.12.2)
- Android SDK / Xcode สำหรับ build ลงอุปกรณ์จริง

### ติดตั้งและรัน

```bash
flutter pub get
```

```bash
flutter run
```

### คำสั่งที่ใช้บ่อย

ตรวจสอบ static analysis

```bash
flutter analyze
```

รัน unit test ทั้งหมด

```bash
flutter test
```

รัน test พร้อมวัด coverage

```bash
flutter test --coverage
```

build APK สำหรับ release

```bash
flutter build apk --release
```

สร้าง App Icon และ Splash Screen ใหม่หลังเปลี่ยนรูปใน `assets/icon/`

```bash
dart run flutter_launcher_icons
```

```bash
dart run flutter_native_splash:create
```

---

## โครงสร้างโปรเจกต์

```text
lib/
├── core/
│   ├── constants/      # HiveBoxes, ReminderConstants
│   ├── exceptions/     # AppException
│   ├── router/         # app_router.dart (go_router)
│   ├── services/       # NotificationService, ImageStorageService
│   ├── theme/          # AppTheme
│   ├── utils/          # Result<T>, IdGenerator, TimeOfDayFormatter
│   └── widgets/        # EmptyState, ConfirmDialog, ScaffoldWithNavBar,
│                       # GradientAppHeader, StatusBadge
│
├── features/
│   ├── medication/     # จัดการข้อมูลยา + รูปภาพยา
│   ├── reminder/       # ตารางยา + การตั้งเวลาแจ้งเตือน + สิทธิ์การแจ้งเตือน
│   ├── history/        # ประวัติการทานยา
│   └── dashboard/      # มื้อยาที่ต้องทานวันนี้
│
├── app.dart                            # Root widget + จัดการ action จากการแจ้งเตือน
│                                       # + re-sync ตอนแอปกลับมา foreground
├── main.dart                           # เปิด Hive box, init notification, ProviderScope
└── notification_background_handler.dart # จัดการ action ตอนแอปไม่ได้เปิดอยู่
```

แต่ละ feature แบ่งเป็น 3 ชั้นตาม Clean Architecture

```text
features/<feature>/
├── data/           # models (Hive), mappers, datasources, repositories (impl)
├── domain/         # entities, repositories (contract), usecases, services
└── presentation/   # screens, widgets, providers
```

> `dashboard` เป็น feature อ่านอย่างเดียว จึงไม่มีชั้น `data/` แต่ใช้ repository ของ feature อื่นผ่าน usecase

---

## สถาปัตยกรรม

### ทิศทาง Dependency

```text
Presentation → Domain ← Data
```

- Presentation เรียก UseCase ผ่าน Riverpod provider เท่านั้น
- Domain ไม่มี dependency กับ Flutter หรือ Hive
- Data แปลง Model ↔ Entity ผ่าน Mapper

การไหลของข้อมูล

```text
Screen → Provider → UseCase → Repository → LocalDataSource → Hive
```

### Error Handling

Repository ทุกตัวคืนค่าเป็น `Result<T>` ไม่โยน Exception ขึ้นไปถึง UI

```dart
result.when(
  success: (data) => ...,
  failure: (message) => ...,
);
```

### Dependency Injection

ใช้ Riverpod providers ล้วน ไม่ใช้ `get_it` หรือ `injectable`
Hive box และ `NotificationService` ถูกสร้างใน `main.dart` แล้ว override เข้า `ProviderScope`

### Local Database

Hive box ที่ใช้งานจริง

| Box | typeId | เก็บอะไร |
|---|---|---|
| `medications` | 0 | `MedicationModel` |
| `schedules` | 1 | `ScheduleModel` |
| `histories` | 2 | `MedicationHistoryModel` |

---

## ระบบแจ้งเตือน

แอปไม่มี background task ที่รันตลอดเวลา จึงใช้วิธี **ตั้งเวลาแจ้งเตือนล่วงหน้าเป็นหน้าต่าง 7 วัน**
แล้ว sync ใหม่ทุกครั้งที่เปิดแอป ทุกครั้งที่แอปกลับมา foreground และทุกครั้งที่แก้ไขตารางยา

```text
เปิดแอป / กลับเข้าแอป / แก้ตารางยา
        ↓
SyncRemindersUseCase
        ↓
ScheduleOccurrenceCalculator   → คำนวณมื้อยาล่วงหน้า 7 วัน
        ↓
ReminderRepository             → ตรวจสิทธิ์การปลุกตรงเวลาก่อนตั้ง (ครั้งเดียวต่อตาราง)
        ↓
NotificationService            → flutter_local_notifications
```

พฤติกรรมของการแจ้งเตือน (กำหนดใน `ReminderConstants`)

- ปุ่ม **ทานแล้ว** — บันทึกประวัติสถานะ `taken`
- ปุ่ม **เลื่อน** — บันทึกสถานะ `snoozed` และเลื่อนแจ้งเตือนออกไป 15 นาที
- **แตะที่ตัวการแจ้งเตือน** — เปิดแอปแล้วแสดง popup ยืนยันการทานยา
- **แจ้งเตือนซ้ำ** — หากยังไม่ยืนยันภายใน 15 นาที จะเตือนอีกครั้ง

การกดปุ่มบนการแจ้งเตือนขณะแอปปิดอยู่ ถูกจัดการใน `notification_background_handler.dart`
ซึ่งเปิด Hive box เองแล้วบันทึกประวัติผ่าน repository ตามปกติ

### สิทธิ์ที่ต้องใช้ (Android)

| Permission | ใช้ทำอะไร | ได้มายังไง |
|---|---|---|
| `CAMERA` | ถ่ายรูปยา | ขอตอนผู้ใช้กดถ่ายรูป |
| `POST_NOTIFICATIONS` | แสดงการแจ้งเตือน (Android 13+) | dialog ในแอป ขอตอนเปิดแอปครั้งแรก |
| `SCHEDULE_EXACT_ALARM` | ปลุกตรงเวลา | **Android 14+ ต้องให้ผู้ใช้เปิดเองในหน้าตั้งค่าระบบ** |
| `RECEIVE_BOOT_COMPLETED` | คงการแจ้งเตือนไว้หลังรีสตาร์ตเครื่อง | ได้อัตโนมัติ |

### การจัดการสิทธิ์การปลุกตรงเวลา

ตั้งแต่ **Android 14 (API 34)** เป็นต้นไป `SCHEDULE_EXACT_ALARM` จะไม่ถูกอนุญาตให้อัตโนมัติอีกต่อไป
(แอปนี้ `targetSdk = 36`) ถ้าสั่ง `zonedSchedule` แบบตรงเวลาโดยยังไม่ได้รับสิทธิ์ ปลั๊กอินจะโยน
`exact_alarms_not_permitted` ทันที และการแจ้งเตือน**ทุกรายการจะล้มเหลว**

แอปจึงจัดการไว้ 3 ชั้น

1. **ตรวจก่อนตั้ง** — `canScheduleExactAlarms()` ถามครั้งเดียวต่อหนึ่งตาราง แล้วส่งผลต่อให้ทุกมื้อ
2. **ถอยได้ ไม่ล้ม** — ถ้าไม่ได้รับสิทธิ์จะตั้งเป็น `inexactAllowWhileIdle` แทน เตือนคลาดเคลื่อน
   ไม่กี่นาทียังดีกว่าไม่เตือนเลย และยังดัก `PlatformException` เผื่อสิทธิ์ถูกปิดระหว่างที่กำลัง sync
3. **อธิบายก่อนขอ** — `ReminderPermissionBanner` แสดงเหนือทุกแท็บเมื่อสิทธิ์ยังไม่ครบ อธิบาย
   ผลกระทบและบอกว่าจะเจอหน้าไหนในการตั้งค่า ก่อนพาผู้ใช้ออกไป แล้วซ่อนตัวเองเมื่อสิทธิ์ครบ

เมื่อผู้ใช้กลับเข้าแอป (`AppLifecycleState.resumed`) แอปจะอ่านสถานะสิทธิ์ใหม่และ sync การแจ้งเตือนใหม่เสมอ
เพราะผู้ใช้เปลี่ยนสิทธิ์จากหน้าตั้งค่าของระบบได้ตลอดโดยที่แอปไม่รู้ตัว

ถ้า sync ไม่สำเร็จจะแสดง SnackBar ให้ผู้ใช้ทราบ — ห้ามปล่อยให้ล้มเหลวแบบเงียบๆ เพราะผู้ใช้
ไม่มีทางรู้เลยว่าการแจ้งเตือนไม่ถูกตั้ง

ตรวจสอบสิทธิ์บนเครื่องจริงได้ด้วย

```bash
adb shell cmd appops get com.example.pillmate SCHEDULE_EXACT_ALARM
```

---

## Navigation

3 แท็บหลักอยู่ใน `StatefulShellRoute.indexedStack` เพื่อคงสถานะของแต่ละแท็บ

| Path | หน้าจอ |
|---|---|
| `/` | ยาของฉัน |
| `/today` | ยาวันนี้ |
| `/history` | ประวัติ |

หน้าเพิ่ม/แก้ไขยาและตารางยา push เต็มจอทับ bottom navigation ผ่าน `rootNavigatorKey`

| Path | หน้าจอ |
|---|---|
| `/medications/add` | เพิ่มยา |
| `/medications/edit` | แก้ไขยา |
| `/medications/schedules` | ตารางยาของยาที่เลือก |
| `/medications/schedules/add` | เพิ่มตารางยา |
| `/medications/schedules/edit` | แก้ไขตารางยา |

---

## Testing

Unit test ครอบคลุม UseCase, Repository และ Service (`ScheduleOccurrenceCalculator`)
พร้อม widget test ของหน้ารายการยาและ popup ยืนยันการทานยา ใช้ `mocktail` สำหรับ mock dependency

```bash
flutter test
```

เป้าหมาย coverage 80%+

---

## CI/CD

`Jenkinsfile` เป็น declarative pipeline สำหรับ Windows agent มี stage ดังนี้

```text
Environment → Dependencies → Analyze → Test → Build APK → Archive
```

พารามิเตอร์ของ job

- `BUILD_MODE` — `release` หรือ `debug`
- `OBFUSCATE` — obfuscate โค้ด Dart (ใช้กับ release เท่านั้น)

การตั้งค่า Jenkins job และข้อกำหนดของ agent อธิบายไว้ในคอมเมนต์ส่วนหัวของ `Jenkinsfile`

---

## แนวทางการพัฒนา

- คอมเมนต์เป็น **ภาษาไทย** ส่วนชื่อ class / method / variable เป็น **ภาษาอังกฤษ**
- ชื่อไฟล์ใช้ `snake_case`
- ใช้ Riverpod เท่านั้นในการจัดการ state (ใช้ `setState()` ได้เฉพาะ local UI state ภายในหน้าจอ เช่น สถานะปุ่มกำลังโหลด)
- UI ห้ามเรียก Hive หรือ NotificationService โดยตรง
- Branch: `feature/*` `bugfix/*` `hotfix/*`
- Commit: `feat:` `fix:` `docs:` `test:` `refactor:` `chore:`

เอกสารฉบับเต็มอยู่ในโฟลเดอร์ `.context/`

| ไฟล์ | เนื้อหา |
|---|---|
| `.context/prd.md` | Product Requirements Document |
| `.context/requirements.md` | Business & Functional Requirements |
| `.context/architecture.md` | รายละเอียดสถาปัตยกรรม |
| `.context/coding-guidelines.md` | มาตรฐานการเขียนโค้ด |
| `.context/tasks.md` | รายการงานและสถานะ |
| `.context/ai-context.md` | สรุปบริบทโปรเจกต์สำหรับ AI |

โฟลเดอร์ `.skills/` เก็บ skill สำหรับ AI assistant เช่น `feature-generator`, `hive-database`,
`notification-system`, `flutter-riverpod-expert`, `code-review`, `testing`

---

## สิ่งที่ยังไม่ได้ทำ

- แสดงรูปภาพยาประกอบใน notification (FR-02, TASK-406)
- ค้นหารายการยาในหน้ารายการยา (FR-07)
- Dashboard: การ์ด "เวลาทานยาถัดไป" (FR-08, TASK-603) — ส่วนการ์ดสรุปสถานะรายวันทำแล้ว
- บันทึกสถานะ "ข้ามการทาน" — มีใน entity และแสดงผลได้ แต่ยังไม่มี UI ให้บันทึก (FR-05)
- Localization (`lib/l10n/`) — ปัจจุบันเป็นภาษาไทยแบบ hardcode

Roadmap ถัดไปดูได้ที่ `.context/prd.md` หัวข้อ Future Release
