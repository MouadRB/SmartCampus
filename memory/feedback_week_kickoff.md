---
name: Week Kickoff Workflow
description: Strict structure to follow when the user opens a new "Week N" task on SmartCampus — read context first, list prerequisites, plan, ask, wait
type: feedback
---

When the user opens a new Week N task on SmartCampus (kickoff prompts begin with "I want to INITIATE Week N: …" and include a SUCCESS BRIEF + RULES block), follow this exact rhythm before writing any code:

1. Read the referenced context files completely (README.md, prior WEEK reports, pubspec.yaml, plus any others called out).
2. Up front, list any native/scaffold prerequisites that block the work (e.g., missing `android/`/`ios/` folders, missing packages, missing entity fields).
3. Provide a 5-step (max) execution plan structured around their Clean Architecture-lite layering: Entity → Repository → UseCase → BLoC → Presentation. Don't merge layers.
4. Ask 2–4 clarifying questions via AskUserQuestion before doing anything destructive or scope-expanding.
5. Wait for explicit "go" alignment. Their kickoff prompts always include "DO NOT start writing yet" or "Only begin work once we've aligned" — honor that literally.

**Why:** They have repeatedly reinforced this structure (Week 3 UI design pass, Week 4 hardware integration). They want surgical, scope-bounded work that doesn't expand silently into adjacent layers; the alignment step is their gating mechanism. Skipping the plan/question phase would let scope drift into Domain or Data when they only authorized Presentation (or vice versa).

**How to apply:** Detect the kickoff pattern (Week N + SUCCESS BRIEF + RULES + "DO NOT start"). Don't call Edit/Write on Dart files until the user says "proceed" / "go" / "execute." Preliminary memory writes and read-only research are fine.
