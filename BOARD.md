# ADBOX Dev Board

> **Last updated:** 2026-03-04 | **Updated by:** Daniel (merge-approved)

This is the shared coordination file for all ADBOX vibe coders. Claude reads and updates this automatically at session start/end.

---

## Active Sessions

| Who | Machine | Worktree | Branch | Status | Started | Working On |
|-----|---------|----------|--------|--------|---------|------------|
| Daniel | Monster | merge-approved | merge-approved | Active | 2026-03-04 | Board planning, task assignment |

---

## Task Queue (Unassigned)

> **Target: CHS Hospital Demo — March 23, 2026**

### APPROVAL WORKFLOWS (location → brand → corporate hierarchy)

| # | Task | Priority | Notes |
|---|------|----------|-------|
| 1 | **DB: Add hierarchical fields to ai_approval_item** — Add `location_id`, `brand_id`, `approval_level` (enum: location/brand/corporate), `approval_chain_id`, `escalated_at`, `sla_deadline` columns | P0 - CRITICAL | Migration needed. Current model is flat (editor → admin). CHS needs 3-level chain. |
| 2 | **Backend: Approval chain state machine** — New service `approvalChainService.js` that routes items through location → brand → corporate levels. Auto-advance when level approves, block when rejected, support skip-level for items that don't need all 3. | P0 - CRITICAL | Depends on #1. Core logic for hierarchical approvals. |
| 3 | **Backend: Level-specific approval queues** — Extend approval routes to filter by approval_level. Location managers see location queue, brand managers see brand queue, corporate sees all. RBAC integration with existing 16 roles. | P0 - CRITICAL | Depends on #1, #2. Currently approvalGate middleware only checks roles 1,2,13. |
| 4 | **Backend: Approval notifications (hierarchical)** — When item advances levels, notify next-level approvers. When rejected, notify submitter + all previous approvers. Email + in-app. | P1 - HIGH | Depends on #2. Current notifications only go to admins. |
| 5 | **Backend: Approval delegation + SLA/escalation** — Allow approvers to delegate to another user at same level. Auto-escalate to next level if SLA deadline passes without action. | P1 - HIGH | Depends on #2. Nice-to-have for demo but shows enterprise readiness. |
| 6 | **Frontend: Approval queue UI** — New page/component showing pending approvals for current user's level. Approve/reject with comments, bulk actions, filter by location/brand. | P0 - CRITICAL | Depends on #3. No frontend approval UI exists currently. |
| 7 | **Frontend: Approval chain status tracker** — Visual indicator on content/campaigns showing where they are in the approval chain (location ✓ → brand pending → corporate waiting). | P1 - HIGH | Depends on #2. Adds visibility to the approval process. |

### CONTENT STUDIO

| # | Task | Priority | Notes |
|---|------|----------|-------|
| 8 | **Frontend: National buying workflow UI** — Add explicit "Buy Nationally" option to campaign purchase flow. Currently campaigns can be corporate or location-specific but no dedicated national buying interface. | P1 - HIGH | Content Studio backend is functional (33K line controller). Campaign wizard has 9 channels. This is a UI gap only. |
| 9 | **Backend: Content version history improvements** — FileVersion model exists but needs UI exposure. Add endpoint to list versions, diff versions, restore previous version. | P2 - MEDIUM | FileVersion model already in DB. Mostly frontend work. |

### RBAC / PERMISSIONS

| # | Task | Priority | Notes |
|---|------|----------|-------|
| 10 | **Backend: Flesh out Role + UserRole models** — Current Role model is minimal (id/name only). Add `level` (location/brand/corporate), `permissions` JSON field, `is_approval_role` flag. UserRole needs `location_id` and `brand_id` scoping. | P0 - CRITICAL | Needed for approval hierarchy. Current rbacService has 16 hardcoded roles but no level awareness. |
| 11 | **Backend: Permissions service upgrade** — Current permissionsService.js is just API wrappers. Needs actual permission checking logic: can user X approve at level Y for location Z? | P1 - HIGH | Depends on #10. Critical for approval queues to work correctly. |

### POLISH / DEMO PREP

| # | Task | Priority | Notes |
|---|------|----------|-------|
| 12 | **Frontend: Dashboard demo data seeding** — Ensure CHS demo company has realistic dashboard data (campaigns, analytics, activity feed). Role-based dashboard templates already work. | P2 - MEDIUM | Activity tracking + feeds are fully functional. Just need demo content. |
| 13 | **Frontend: Campaign template library for CHS** — Pre-built campaign templates for hospital/healthcare vertical (patient outreach, community health, recruitment, service line promotion). | P2 - MEDIUM | Template system works. Need healthcare-specific templates. |
| 14 | **End-to-end approval flow smoke test** — Once #1-6 are done: create content as location user, approve at location level, approve at brand level, approve at corporate level, verify audit trail. | P0 - CRITICAL | Depends on #1-6. Must pass before demo. |

### BLOCKERS / DISCUSSION NEEDED

| # | Blocker | Who's Blocked | Waiting On | Since |
|---|---------|---------------|------------|-------|
| B1 | **Approval workflow architecture needs design review** — How many approval levels does CHS actually need? Do all content types require all 3 levels? What are the RBAC mappings (which of the 16 existing roles map to which approval level)? | Tasks #1-7 | Daniel (design decision) | 2026-03-04 |

---

## In Progress (Claimed)

| # | Task | Owner | Branch | Started | Status |
|---|------|-------|--------|---------|--------|
| — | No tasks claimed yet — unblock B1 first | — | — | — | — |

---

## Completed Today

| # | Task | Owner | Branch | Completed |
|---|------|-------|--------|-----------|
| — | — | — | — | — |

---

## Blockers

| # | Blocker | Who's Blocked | Waiting On | Since |
|---|---------|---------------|------------|-------|
| B1 | Approval workflow architecture design — need to decide: how many levels, which roles map where, which content types need full chain | Tasks #1-7, #10-11 | Daniel | 2026-03-04 |

---

## Port Allocation (Monster — `31XX/41XX`)

| Worktree | Owner | Frontend | Backend | Branch |
|----------|-------|----------|---------|--------|
| hurb-1 | Daniel | 3101 | 4101 | hurb-1 |
| hurb-2 | Daniel | 3102 | 4102 | hurb-2 |
| hurb-3 | Daniel | 3103 | 4103 | hurb-3 |
| hurb-4 | Daniel | 3104 | 4104 | hurb-4 |
| hurb-5 | Daniel | 3105 | 4105 | hurb-5 |
| hurb-6 | Daniel | 3106 | 4106 | hurb-6 |
| hurb-7 | Daniel | 3107 | 4107 | hurb-7 |
| hurb-8 | Daniel | 3108 | 4108 | hurb-8 |
| hurb-9 | Daniel | 3109 | 4109 | hurb-9 |
| hurb-10 | Daniel | 3110 | 4110 | hurb-10 |
| danbox | Dad | 3130 | 4130 | danbox |
| juhnk | Nick | 3120 | 4120 | juhnk |
| testing | Shared | 3150 | 4150 | testing |

**MacBook ports:** `30XX/40XX` (Daniel's laptop — separate from monster)

---

## Rules

1. **Claude updates this file** at session start (check in) and session end (check out)
2. **Don't edit manually** unless correcting stale data
3. **Commit + push** after every update: `cd /d/blackwave/board && git add -A && git commit -m "board update" && git push`
4. **Pull before reading**: `cd /d/blackwave/board && git pull`
