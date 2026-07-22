# PillMate Development Tasks

Status: MVP

อัปเดตล่าสุด: 22 กรกฎาคม 2026

สัญลักษณ์สถานะ

```text
✅ เสร็จแล้ว
⚠️ ทำบางส่วน
⬜ ยังไม่ได้ทำ
```

---

# สรุปภาพรวม

| Epic | หัวข้อ | สถานะ |
|---|---|---|
| Epic 1 | Project Setup | ✅ |
| Epic 2 | Medication Management | ✅ |
| Epic 3 | Medication Image | ✅ |
| Epic 4 | Schedule Management | ✅ |
| Epic 5 | Notification | ✅ |
| Epic 6 | Medication History | ✅ |
| Epic 7 | Dashboard | ⚠️ |
| Epic 8 | Testing | ⚠️ |
| Epic 9 | Quality | ⚠️ |

Milestone 1–3 เสร็จแล้ว เหลืองานใน Milestone 4 (Testing / UAT / Release) และงานค้างของ Dashboard

---

# Epic 1 : Project Setup

## TASK-001 ✅

Setup Flutter Project

Priority: P0

Checklist

- ✅ Create Flutter Project
- ✅ Configure Folder Structure
- ✅ Enable Null Safety

---

## TASK-002 ✅

Setup Dependencies

Priority: P0

Packages

- ✅ flutter_riverpod
- ✅ hive
- ✅ hive_flutter
- ✅ go_router
- ✅ image_picker
- ✅ flutter_local_notifications
- ✅ mocktail
- ✅ path_provider, timezone (เพิ่มภายหลังสำหรับระบบแจ้งเตือน)
- ✅ flutter_launcher_icons, flutter_native_splash (App Icon / Splash)

---

## TASK-003 ✅

Setup Architecture

Priority: P0

Checklist

- ✅ Create core module
- ✅ Create features module
- ✅ Create data/domain/presentation layers

---

# Epic 2 : Medication Management

## TASK-101 ✅

Create Medication Entity

Priority: P0

Deliverables

- ✅ Entity — `Medication`
- ✅ Model — `MedicationModel` (typeId 0)
- ✅ Mapper — `MedicationMapper`

---

## TASK-102 ✅

Create Medication Repository

Priority: P0

Deliverables

- ✅ Repository Contract — `MedicationRepository`
- ✅ Repository Implementation — `MedicationRepositoryImpl`

---

## TASK-103 ✅

Create Medication Local Data Source

Priority: P0

Deliverables

- ✅ Hive Adapter
- ✅ CRUD Operations

---

## TASK-104 ✅

Create Medication List Screen

Priority: P0

Deliverables

- ✅ List View — `MedicationListScreen` + `MedicationCard`
- ✅ Empty State — `EmptyState`

---

## TASK-105 ✅

Create Add Medication Screen

Priority: P0

Deliverables

- ✅ Form — `MedicationForm`
- ✅ Validation

---

## TASK-106 ✅

Create Edit Medication Screen

Priority: P0

Deliverables

- ✅ Update Function — `UpdateMedicationUseCase`

---

## TASK-107 ✅

Create Delete Medication Function

Priority: P0

Deliverables

- ✅ Delete Action (ลบตารางยาที่ผูกอยู่ด้วยผ่าน `DeleteSchedulesForMedicationUseCase`)
- ✅ Confirmation Dialog — `ConfirmDialog`

---

# Epic 3 : Medication Image

## TASK-201 ✅

Integrate Image Picker

Priority: P1

- ✅ `MedicationImagePicker` + `ImageStorageService` (คัดลอกไฟล์เก็บในเครื่อง)

---

## TASK-202 ✅

Support Camera Upload

Priority: P1

---

## TASK-203 ✅

Support Gallery Upload

Priority: P1

---

## TASK-204 ✅

Display Medication Image

Priority: P1

- ✅ แสดงในรายการยาและหน้าแก้ไข
- ⬜ ยังไม่แสดงรูปยาใน Notification (ดู TASK-406)

---

# Epic 4 : Schedule Management

## TASK-301 ✅

Create Schedule Entity

Priority: P0

- ✅ `Schedule` + `ScheduleFrequency` (daily / weekly / intervalHours / everyNDays)

---

## TASK-302 ✅

Create Schedule Repository

Priority: P0

---

## TASK-303 ✅

Create Schedule Screen

Priority: P0

- ✅ `ScheduleListScreen`, `AddScheduleScreen`, `EditScheduleScreen`

---

## TASK-304 ✅

Daily Schedule

Priority: P0

---

## TASK-305 ✅

Weekly Schedule

Priority: P0

- ✅ `ScheduleWeekdaySelector`

---

## TASK-306 ✅

Custom Schedule

Priority: P1

- ✅ ทุก X ชั่วโมง (`intervalHours` + `startTime`)
- ✅ ทุก X วัน (`everyNDays`) — เพิ่มเติมจากที่ระบุไว้เดิม
- ✅ ช่วงวันที่เริ่ม-สิ้นสุด (`ScheduleDateRangeField`)
- ✅ เปิด/ปิดใช้งานตารางโดยไม่ต้องลบ (`isActive`)

---

## TASK-307 ✅

Multiple Time Selection

Priority: P0

- ✅ `ScheduleTimeListEditor`

---

# Epic 5 : Notification

## TASK-401 ✅

Setup Notification Service

Priority: P0

- ✅ `NotificationService` + timezone + Android channel / iOS category

---

## TASK-402 ✅

Create Reminder Scheduler

Priority: P0

- ✅ `ScheduleOccurrenceCalculator` (Domain Service)
- ✅ `SyncRemindersUseCase` — ตั้งแจ้งเตือนล่วงหน้า 7 วัน แล้ว sync ใหม่ทุกครั้งที่เปิดแอป

---

## TASK-403 ✅

Schedule Notification

Priority: P0

---

## TASK-404 ✅

Notification Action

Priority: P0

Features

- ✅ Mark As Taken
- ✅ Snooze (เลื่อน 15 นาที)
- ✅ Follow-up Notification (เตือนซ้ำใน 15 นาทีถ้ายังไม่ยืนยัน)
- ✅ รองรับการกด action ตอนแอปปิดอยู่ (`notification_background_handler.dart`)
- ✅ แตะที่การแจ้งเตือนแล้วแสดง popup ยืนยัน (`MedicationTakenDialog`)

---

## TASK-405 ✅

Notification Permission

Priority: P0

- ✅ `RequestNotificationPermissionUseCase` เรียกตอนเปิดแอป
- ✅ Android manifest: `SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED`, `CAMERA`

---

## TASK-406 ⬜

Medication Image In Notification

Priority: P2

Deliverables

- ⬜ แสดงรูปภาพยาใน Notification (Android BigPictureStyle / iOS attachment)

อ้างอิง FR-02 และ FR-04 ใน requirements.md

---

# Epic 6 : Medication History

## TASK-501 ✅

Create History Entity

Priority: P0

- ✅ `MedicationHistory` + `IntakeStatus` (taken / snoozed / skipped)

---

## TASK-502 ✅

Create History Repository

Priority: P0

---

## TASK-503 ✅

Record Medication Intake

Priority: P0

- ✅ `RecordMedicationIntakeUseCase`
- ⚠️ บันทึกได้จริงเฉพาะ `taken` และ `snoozed` — ยังไม่มี UI สำหรับบันทึก `skipped`

---

## TASK-504 ✅

History Screen

Priority: P0

- ✅ `MedicationHistoryScreen` + `MedicationHistoryCard`

---

## TASK-505 ✅

Daily History Filter

Priority: P1

- ✅ `HistoryPeriodFilter.today`

---

## TASK-506 ✅

Monthly History Filter

Priority: P1

- ✅ `HistoryPeriodFilter.thisMonth` + ค้นหาชื่อยาใน `HistoryFilterBar`

---

# Epic 7 : Dashboard

## TASK-601 ✅

Dashboard Screen

Priority: P1

- ✅ `TodayDosesScreen` (แท็บ "ยาวันนี้")

---

## TASK-602 ✅

Today's Medication Section

Priority: P1

- ✅ `GetTodayDosesUseCase` + `DoseCard` + ยืนยันการทานเองได้

---

## TASK-603 ⬜

Next Reminder Card

Priority: P1

Deliverables

- ⬜ การ์ดแสดงเวลาทานยาถัดไป

---

## TASK-604 ⬜

Daily Summary Card

Priority: P1

Deliverables

- ⬜ จำนวนมื้อที่ทานแล้ว / ยังไม่ทาน
- ⬜ สถานะการรับประทานยาประจำวัน

---

# Epic 8 : Testing

## TASK-701 ✅

Repository Unit Test

Priority: P0

- ✅ medication, history, schedule, reminder

---

## TASK-702 ✅

Use Case Unit Test

Priority: P0

- ✅ ครบทุก UseCase หลัก + `ScheduleOccurrenceCalculator`

---

## TASK-703 ⬜

Provider Test

Priority: P1

- ⬜ ยังไม่มี test ของ Riverpod provider / notifier โดยตรง

---

## TASK-704 ⚠️

Widget Test

Priority: P1

- ✅ `medication_list_screen_test`, `medication_taken_dialog_test`
- ⬜ ยังขาด widget test ของหน้า schedule, history, today doses และ form ต่างๆ

---

# Epic 9 : Quality

## TASK-801 ⚠️

Analyzer Cleanup

Priority: P0

Target

- ✅ No Errors
- ✅ No Warnings
- ⚠️ เหลือ info 26 รายการ ทั้งหมดเป็น `prefer_initializing_formals` ใน constructor ของ
  UseCase / Repository / DataSource

---

## TASK-802 ⏳

Code Review

Priority: P0

- ทำต่อเนื่องผ่าน Pull Request (ดู Pull Request Rules ใน coding-guidelines.md)

---

## TASK-803 ✅

Documentation Update

Priority: P0

Update

- ✅ requirements.md — เพิ่มตาราง Implementation Status
- ✅ architecture.md — ปรับโครงสร้างโฟลเดอร์และ Notification Architecture ให้ตรงโค้ด
- ✅ coding-guidelines.md
- ✅ ai-context.md — แก้ CI/CD เป็น Jenkins และปรับ Feature List ตามสถานะจริง
- ✅ README.md — เขียนใหม่ทั้งฉบับ

---

# Epic 10 : Localization

## TASK-901 ⬜

Setup Localization

Priority: P2

Deliverables

- ⬜ สร้าง `lib/l10n/`
- ⬜ ย้ายข้อความ UI ที่ hardcode ภาษาไทยเข้า ARB file

---

# Definition Of Done

Feature จะถือว่าเสร็จเมื่อ

- Build ผ่าน
- Analyzer ผ่าน
- Unit Test ผ่าน
- UI ใช้งานได้จริง
- Documentation Update แล้ว
- ไม่มี Critical Bug

---

# MVP Milestone

Milestone 1 ✅

- Project Setup
- Medication Management

Milestone 2 ✅

- Schedule Management
- Notification

Milestone 3 ⚠️

- Medication History ✅
- Dashboard ⚠️ (เหลือ TASK-603, TASK-604)

Milestone 4 ⚠️

- Testing ⚠️ (เหลือ TASK-703, TASK-704)
- UAT ⬜
- Release 1.0 ⬜
