# AI Context

## Project Name

PillMate

---

## Project Type

Mobile Application

---

## Purpose

แอปพลิเคชันสำหรับ

- แจ้งเตือนการทานยา
- บันทึกประวัติการทานยา
- เก็บข้อมูลรายการยา
- แสดงรูปภาพยา
- ช่วยให้ผู้ใช้ไม่ลืมทานยา

---

## Technology Stack

Frontend

- Flutter
- Dart

Architecture

- Clean Architecture

State Management

- Riverpod

Database

- Hive

Notification

- flutter_local_notifications

Navigation

- go_router

Image

- image_picker

Testing

- flutter_test
- mocktail

Version Control

- Git
- GitHub

CI/CD

- Jenkins (Jenkinsfile ที่ root ของโปรเจกต์ รันบน Windows agent)

Stage ของ Pipeline

```text
Environment → Dependencies → Analyze → Test → Build APK → Archive
```

---

## Architecture Rules

ใช้ Clean Architecture

```text
Presentation
 ↓
Domain
 ↓
Data
```

ห้าม

- UI เข้าถึง Database
- UI มี Business Logic
- UI เรียก Hive โดยตรง

---

## Folder Structure

```text
core/
features/
```

ทุก Feature ต้องมี

```text
data/
domain/
presentation/
```

ยกเว้น Feature ที่อ่านข้อมูลอย่างเดียว (เช่น dashboard) ที่ใช้ Repository ของ Feature อื่น
ผ่าน UseCase จึงไม่ต้องมี `data/`

Feature ที่มีจริงในโค้ด

```text
medication
reminder
history
dashboard
```

`l10n/` ยังไม่ถูกสร้าง ปัจจุบันข้อความ UI เป็นภาษาไทยแบบ hardcode

---

## Coding Rules

Comment

- ภาษาไทย

Class Name

- ภาษาอังกฤษ

Method Name

- ภาษาอังกฤษ

Variable Name

- ภาษาอังกฤษ

---

## State Management Rules

ใช้ Riverpod เท่านั้น

อนุญาต

- Provider
- FutureProvider
- AsyncNotifier

หลีกเลี่ยง

```dart
setState()
```

ยกเว้น local UI state ภายในหน้าจอเดียวที่ไม่กระทบ business logic เช่น สถานะปุ่มกำลังบันทึก
กรณีนี้ใช้ `ConsumerStatefulWidget` + `setState()` ได้ (ดูตัวอย่างที่ `today_doses_screen.dart`)

---

## Database Rules

ใช้ Hive เท่านั้น

ผ่าน Repository Pattern

```text
UI
 ↓
UseCase
 ↓
Repository
 ↓
LocalDataSource
 ↓
Hive
```

Box ที่ใช้งานจริง

```text
medications    (typeId 0)
schedules      (typeId 1)
histories      (typeId 2)
```

Repository ทุกตัวคืนค่าเป็น `Result<T>` ห้ามโยน Exception ขึ้นไปถึง UI

---

## Testing Rules

AI ต้องสร้าง

- Unit Test
- Mock Dependency

สำหรับ

- UseCase
- Repository
- Service

Coverage

```text
80%+
```

---

## Git Rules

Branch

```text
feature/*
bugfix/*
hotfix/*
```

Commit

```text
feat:
fix:
docs:
test:
refactor:
chore:
```

---

## Feature List

สถานะ: ✅ ทำแล้ว / ⬜ ยังไม่ทำ

### Medication

- ✅ Add Medication
- ✅ Edit Medication
- ✅ Delete Medication
- ✅ Medication Image (กล้อง + Gallery)
- ⬜ Search Medication

### Schedule

`ScheduleFrequency` ที่รองรับ

- ✅ daily — ทุกวัน
- ✅ weekly — เฉพาะวันในสัปดาห์ที่เลือก
- ✅ intervalHours — ทุก X ชั่วโมง
- ✅ everyNDays — ทุก X วัน
- ✅ หลายเวลาต่อวัน + ช่วงวันที่เริ่ม-สิ้นสุด + เปิด/ปิดใช้งานตาราง

### Reminder

- ✅ Local Notification
- ✅ Snooze (เลื่อน 15 นาที)
- ✅ Mark As Taken
- ✅ Follow-up Notification (เตือนซ้ำใน 15 นาทีถ้ายังไม่ยืนยัน)
- ✅ ยืนยันผ่าน Popup เมื่อแตะที่การแจ้งเตือน
- ✅ จัดการสิทธิ์ Android 14+ (ตรวจสิทธิ์ก่อนตั้ง, ถอยไปใช้ inexact alarm,
  ขอสิทธิ์แบบมีคำอธิบายผ่าน ReminderPermissionBanner, re-sync ตอนกลับเข้าแอป)
- ⬜ แสดงรูปภาพยาใน Notification

### History

- ✅ บันทึกสถานะ taken / snoozed / skipped
- ✅ Daily History (ตัวกรอง "วันนี้" เป็นค่าเริ่มต้น)
- ✅ Monthly History (ตัวกรอง "เดือนนี้")
- ✅ Search History (ค้นหาตามชื่อยา)
- ✅ การ์ดสรุปตามตัวกรอง (ทานแล้ว / เลื่อน / ข้าม)

### Dashboard

- ✅ Today's Medication (หน้า "ยาวันนี้" + ยืนยันการทานเอง)
- ✅ Daily Summary (การ์ดความคืบหน้า ทานแล้ว / เลื่อน / รอทาน)
- ⬜ Next Reminder

---

## AI Instructions

เมื่อ AI สร้างโค้ดใหม่

1. ใช้ Flutter + Dart เท่านั้น
2. ใช้ Riverpod ทุกครั้ง
3. ใช้ Clean Architecture
4. แยก Feature ตาม Folder Structure
5. Comment ภาษาไทย
6. Class และ Method ภาษาอังกฤษ
7. สร้าง Unit Test เสมอ
8. หลีกเลี่ยง StatefulWidget (ใช้ได้เฉพาะ local UI state ตามหัวข้อ State Management Rules)
9. Reuse Component เดิมก่อนสร้างใหม่
10. ห้ามแก้ไข Architecture ที่กำหนด
11. ห้ามเพิ่ม Dependency ใหม่โดยไม่มีเหตุผล
12. อัปเดต Documentation เมื่อเพิ่ม Feature ใหม่

---

## Definition of Done

Feature จะถือว่าเสร็จเมื่อ

- Build ผ่าน
- Analyzer ผ่าน
- Unit Test ผ่าน
- ไม่มี Warning สำคัญ
- ใช้งานได้จริง
- Documentation ถูกอัปเดต