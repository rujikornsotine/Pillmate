# Product Requirements Document (PRD)

# PillMate

Version: 1.0

Status: MVP

Owner: Product Team

---

# Product Vision

PillMate คือแอปพลิเคชันมือถือที่ช่วยให้ผู้ใช้งานสามารถจัดการการรับประทานยาได้อย่างมีประสิทธิภาพ ลดความเสี่ยงจากการลืมทานยา การทานยาซ้ำ และช่วยให้สามารถเข้าถึงข้อมูลยาที่ใช้อยู่เป็นประจำได้ทุกที่ทุกเวลา

---

# Product Goal

## Goal 1

ช่วยให้ผู้ใช้งานไม่ลืมทานยา

Success Criteria

- ผู้ใช้ได้รับ Notification ตามเวลาที่กำหนด
- ผู้ใช้สามารถยืนยันการทานยาได้ทันที

---

## Goal 2

ช่วยให้ผู้ใช้ตรวจสอบได้ว่าทานยาแล้วหรือยัง

Success Criteria

- มีระบบบันทึกประวัติการทานยา
- ตรวจสอบย้อนหลังได้

---

## Goal 3

ช่วยให้ผู้ใช้จำชื่อยาและข้อมูลยาได้

Success Criteria

- เก็บชื่อยาได้
- เก็บรูปภาพยาได้
- ดูรายละเอียดได้ตลอดเวลา

---

# Problem Statement

ผู้ใช้งานจำนวนมาก

- ลืมทานยา
- จำไม่ได้ว่าทานยาไปแล้วหรือยัง
- ลืมชื่อยา
- ไม่มีประวัติการรับประทานยา
- ไม่สามารถเข้าถึงข้อมูลยาได้เมื่อเกิดเหตุฉุกเฉิน

---

# Target Users

## ผู้ป่วยโรคเรื้อรัง

ความต้องการ

- ไม่ลืมทานยา
- ตรวจสอบประวัติได้

---

## ผู้สูงอายุ

ความต้องการ

- ใช้งานง่าย
- มีรูปภาพยา
- ตัวอักษรขนาดใหญ่

---

## พนักงานออฟฟิศ

ความต้องการ

- แจ้งเตือนตรงเวลา
- ใช้งานง่ายระหว่างวัน

---

## ผู้เดินทางบ่อย

ความต้องการ

- ดูชื่อยาได้ทุกเวลา
- พกข้อมูลยาแทนการพกใบยา

---

# MVP Scope

## Feature 1

Medication Management

รายละเอียด

- เพิ่มยา
- แก้ไขยา
- ลบยา
- ดูรายละเอียด

Priority

P0

---

## Feature 2

Medication Image

รายละเอียด

- ถ่ายรูปยา
- เลือกรูปจาก Gallery
- แสดงรูปยา

Priority

P1

---

## Feature 3

Medication Schedule

รายละเอียด

- กำหนดเวลาการทานยา
- กำหนดวันในสัปดาห์
- กำหนดช่วงวันที่

Priority

P0

---

## Feature 4

Reminder Notification

รายละเอียด

- แจ้งเตือนตามเวลา
- Snooze
- Mark As Taken

Priority

P0

---

## Feature 5

Medication History

รายละเอียด

- เก็บประวัติ
- ดูย้อนหลัง

Priority

P0

---

## Feature 6

Dashboard

รายละเอียด

- ยาที่ต้องทานวันนี้
- เวลาทานยาถัดไป
- สรุปสถานะรายวัน

Priority

P1

---

# MVP Status

สถานะการพัฒนา ณ 22 กรกฎาคม 2026 (หลัง merge PR #3, #4, #5, #6)

| Feature | Priority | สถานะ | คงเหลือ |
|---|---|---|---|
| Feature 1 — Medication Management | P0 | ✅ | — |
| Feature 2 — Medication Image | P1 | ⚠️ | แสดงรูปยาใน Notification |
| Feature 3 — Medication Schedule | P0 | ✅ | — (รองรับเพิ่ม: ทุก X วัน) |
| Feature 4 — Reminder Notification | P0 | ✅ | — (รวมการจัดการสิทธิ์ปลุกตรงเวลาบน Android 14+) |
| Feature 5 — Medication History | P0 | ✅ | — |
| Feature 6 — Dashboard | P1 | ⚠️ | เวลาทานยาถัดไป |

รายละเอียดระดับ Task ดูที่ `tasks.md` และระดับ Requirement ดูที่ `requirements.md`

---

# User Stories

## Medication

### US-001

As a user

I want to add medication

So that I can manage my medicine list

Acceptance Criteria

- สามารถเพิ่มยาได้
- ข้อมูลถูกเก็บลงฐานข้อมูล

---

### US-002

As a user

I want to attach medication image

So that I can identify medicines easily

Acceptance Criteria

- แนบรูปได้
- ดูรูปได้

---

## Schedule

### US-003

As a user

I want to create medication schedule

So that I receive reminders automatically

Acceptance Criteria

- ตั้งเวลาได้
- บันทึกได้

---

## Reminder

### US-004

As a user

I want notification reminders

So that I do not forget medications

Acceptance Criteria

- Notification แสดงตามเวลา

---

### US-005

As a user

I want to mark medication as taken

So that the history is recorded

Acceptance Criteria

- ระบบบันทึกประวัติ

---

## History

### US-006

As a user

I want to view medication history

So that I know what I have taken

Acceptance Criteria

- ดูย้อนหลังได้

---

# Non Functional Requirements

## Performance

- Launch < 3 seconds
- Home Screen < 2 seconds

---

## Reliability

- Notification Success Rate > 95%

---

## Security

- Local Storage Only
- ไม่เก็บข้อมูลอ่อนไหว

---

## Maintainability

- Clean Architecture
- Unit Test Coverage 80%+

---

# Future Release

## Version 1.1

- Export History
- Medication Statistics

---

## Version 1.2

- Cloud Backup
- Multi Device Sync

---

## Version 2.0

- Authentication
- Family Sharing
- Doctor Report

---

# Success Metrics

- DAU > 70%
- Notification Success > 95%
- Crash Free Users > 99%
- User Satisfaction > 4.5/5