# PillMate Development Tasks

Status: MVP

---

# Epic 1 : Project Setup

## TASK-001

Setup Flutter Project

Priority: P0

Checklist

- Create Flutter Project
- Configure Folder Structure
- Enable Null Safety

---

## TASK-002

Setup Dependencies

Priority: P0

Packages

- flutter_riverpod
- hive
- hive_flutter
- go_router
- image_picker
- flutter_local_notifications
- mocktail

---

## TASK-003

Setup Architecture

Priority: P0

Checklist

- Create core module
- Create features module
- Create data/domain/presentation layers

---

# Epic 2 : Medication Management

## TASK-101

Create Medication Entity

Priority: P0

Deliverables

- Entity
- Model
- Mapper

---

## TASK-102

Create Medication Repository

Priority: P0

Deliverables

- Repository Contract
- Repository Implementation

---

## TASK-103

Create Medication Local Data Source

Priority: P0

Deliverables

- Hive Adapter
- CRUD Operations

---

## TASK-104

Create Medication List Screen

Priority: P0

Deliverables

- List View
- Empty State

---

## TASK-105

Create Add Medication Screen

Priority: P0

Deliverables

- Form
- Validation

---

## TASK-106

Create Edit Medication Screen

Priority: P0

Deliverables

- Update Function

---

## TASK-107

Create Delete Medication Function

Priority: P0

Deliverables

- Delete Action
- Confirmation Dialog

---

# Epic 3 : Medication Image

## TASK-201

Integrate Image Picker

Priority: P1

---

## TASK-202

Support Camera Upload

Priority: P1

---

## TASK-203

Support Gallery Upload

Priority: P1

---

## TASK-204

Display Medication Image

Priority: P1

---

# Epic 4 : Schedule Management

## TASK-301

Create Schedule Entity

Priority: P0

---

## TASK-302

Create Schedule Repository

Priority: P0

---

## TASK-303

Create Schedule Screen

Priority: P0

---

## TASK-304

Daily Schedule

Priority: P0

---

## TASK-305

Weekly Schedule

Priority: P0

---

## TASK-306

Custom Schedule

Priority: P1

---

## TASK-307

Multiple Time Selection

Priority: P0

---

# Epic 5 : Notification

## TASK-401

Setup Notification Service

Priority: P0

---

## TASK-402

Create Reminder Scheduler

Priority: P0

---

## TASK-403

Schedule Notification

Priority: P0

---

## TASK-404

Notification Action

Priority: P0

Features

- Mark As Taken
- Snooze

---

## TASK-405

Notification Permission

Priority: P0

---

# Epic 6 : Medication History

## TASK-501

Create History Entity

Priority: P0

---

## TASK-502

Create History Repository

Priority: P0

---

## TASK-503

Record Medication Intake

Priority: P0

---

## TASK-504

History Screen

Priority: P0

---

## TASK-505

Daily History Filter

Priority: P1

---

## TASK-506

Monthly History Filter

Priority: P1

---

# Epic 7 : Dashboard

## TASK-601

Dashboard Screen

Priority: P1

---

## TASK-602

Today's Medication Section

Priority: P1

---

## TASK-603

Next Reminder Card

Priority: P1

---

## TASK-604

Daily Summary Card

Priority: P1

---

# Epic 8 : Testing

## TASK-701

Repository Unit Test

Priority: P0

---

## TASK-702

Use Case Unit Test

Priority: P0

---

## TASK-703

Provider Test

Priority: P1

---

## TASK-704

Widget Test

Priority: P1

---

# Epic 9 : Quality

## TASK-801

Analyzer Cleanup

Priority: P0

Target

- No Warnings
- No Errors

---

## TASK-802

Code Review

Priority: P0

---

## TASK-803

Documentation Update

Priority: P0

Update

- requirements.md
- architecture.md
- coding-guidelines.md
- ai-context.md

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

Milestone 1

- Project Setup
- Medication Management

Milestone 2

- Schedule Management
- Notification

Milestone 3

- Medication History
- Dashboard

Milestone 4

- Testing
- UAT
- Release 1.0