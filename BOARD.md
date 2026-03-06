# ADBOX Dev Board

> **Last updated:** 2026-03-06 | **Updated by:** Claude Code (board planning session)

This is the shared coordination file for all ADBOX vibe coders. Claude reads and updates this automatically at session start/end.

---

## Active Sessions

| Who | Machine | Worktree | Branch | Status | Started | Working On |
|-----|---------|----------|--------|--------|---------|------------|
| Daniel | Monster | board | main | Active | 2026-03-04 | Board planning, task assignment |
| Daniel | Monster | hurb-1 | hurb-1 | Idle | — | Awaiting assignment |
| Daniel | Monster | hurb-2 | hurb-2 | Idle | — | Awaiting assignment |
| Daniel | Monster | hurb-3 | hurb-3 | Active | 2026-03-05 | Task #12: Dashboard demo data seeding |

---

## Design Decisions (B1 — RESOLVED)

### Approval Hierarchy for CHS

**3-level approval chain:** Location -> Brand -> Corporate

| Approval Level | CHS Role | ADBOX Role(s) |
|---|---|---|
| **Location** | Hospital admin | Location User (3) or MLU (6) with user_role Owner (1) or Account Admin (2) |
| **Brand** | Regional/division director | Brand Admin (2) |
| **Corporate** | CHS corporate marketing | Super Admin (1) |

**Who can approve at location level?** Use existing secondary user_roles (Owner / Account Admin) — no new role needed. A Location User with user_role=Owner or Account Admin can approve at their location level.

**Content type routing:**

| Approval Depth | Content Types | Rationale |
|---|---|---|
| **3 levels** (location -> brand -> corporate) | Campaigns with spend (Social Ads, Digital Display, Video/Audio, Out Of Home) | Anything involving budget needs full chain |
| **2 levels** (location -> brand) | Assets, content library items, printing/brochures | Brand consistency but no corporate bottleneck |
| **1 level** (location only) | Optimizations, insights, pre-approved template fills | Low risk, fast turnaround |

**New DB fields on `ai_approval_item`:** `location_id`, `brand_id`, `approval_level` (enum: location/brand/corporate), `approval_chain_id`, `escalated_at`, `sla_deadline`, `required_approval_depth` (1/2/3).

---

## Task Queue — CHS Hospital Demo (March 23, 2026)

> **Build target:** Done by ~March 7. Test aggressively March 8-23.
> **Velocity reference:** Daniel averages ~32 commits/day across parallel worktrees.

### PHASE 1 — Start immediately, all parallel (no dependencies)

| # | Task | Worktree | Owner | Priority | Frontend Test Instructions |
|---|------|----------|-------|----------|---------------------------|
| 1 | **DB: Add hierarchical fields to ai_approval_item** — Add `location_id`, `brand_id`, `approval_level` (enum: location/brand/corporate), `approval_chain_id` (UUID), `escalated_at`, `sla_deadline`, `required_approval_depth` (integer 1/2/3). Migration must be backwards-compatible with existing flat approval rows (new fields nullable). | **hurb-1** | Daniel | P0 | After migration: check `/api/v1/ai-approvals` still returns existing items without errors. Create a new approval item via EVE chat and confirm new fields accept values. |
| 10 | **Backend: Flesh out Role + UserRole models** — Add `level` (enum: location/brand/corporate) to Role model. Add `permissions` JSON field, `is_approval_role` boolean. UserRole needs `location_id` and `brand_id` scoping so a user can be Brand Admin for a specific brand. Update rbacService ADMIN_ROLES and add APPROVAL_ROLES grouping. | **hurb-2** | Daniel | P0 | After migration: go to user management, verify existing roles still display correctly. Assign a user to a role scoped to a location — confirm it saves and shows in the user's profile. |
| 12 | **Frontend: Dashboard demo data seeding** — Seed a CHS demo company with: 5 locations (hospitals), 2 brands, 10+ campaigns across channels, realistic analytics data, activity feed entries. Use existing seeder patterns. Role-based dashboard templates already work — just need content to show. | **hurb-3** | Daniel | P2 | Log in as each CHS role level (location user, brand admin, super admin). Confirm dashboard shows relevant data, activity feed populates, and analytics charts render with the seeded data. |
| 13 | **Frontend: Campaign template library for CHS** — Create healthcare-specific campaign templates: patient outreach, community health events, recruitment campaigns, service line promotion, seasonal flu/wellness campaigns. Use existing template system. | **hurb-4** | Daniel | P2 | Go to campaign creation, verify CHS templates appear in the template picker. Select one and confirm it pre-fills correctly (copy, images, targeting). |
| 8 | **Frontend: National buying workflow UI** — Add explicit "Buy Nationally" option to campaign purchase flow. When selected: apply campaign to all locations under the brand, show aggregate pricing, single checkout. Campaign wizard has 9 channels — this adds a scope selector (single location / multi-location / national) before channel selection. | **juhnk** | Nick | P1 | In campaign wizard, look for the new scope selector. Pick "Buy Nationally", go through the flow, confirm it shows all locations and aggregate pricing. Test with single location too — should work as before. |

### PHASE 2 — After #1 and #10 merge

| # | Task | Worktree | Owner | Priority | Frontend Test Instructions |
|---|------|----------|-------|----------|---------------------------|
| 2 | **Backend: Approval chain state machine** — New service `approvalChainService.js`. Core logic: create chain with `required_approval_depth` (1/2/3), route through levels sequentially, auto-advance when level approves, block + notify on rejection, support skip-level for items with depth < 3. State transitions: `pending -> location_approved -> brand_approved -> corporate_approved` (or `rejected` at any level). Each transition logs to audit trail. | **hurb-1** | Daniel | P0 | Submit a campaign as a location user. Check it appears in the location approval queue with status "pending". Approve it at location level — confirm it advances to brand queue. Reject at brand level — confirm submitter gets notified and status shows rejected. |
| 11 | **Backend: Permissions service upgrade** — Extend permissionsService to answer: "Can user X approve at level Y for location/brand Z?" Check: user's role, user's role level, user's location_id/brand_id scoping from UserRole, and user_role (Owner/Account Admin for location approval). Super Admin (1) and Platform Admin (13) bypass all checks. | **hurb-2** | Daniel | P1 | Try approving an item you shouldn't have access to (wrong location, wrong level) — should get blocked. Try as Super Admin — should work for anything. Try as location user with Owner user_role — should be able to approve at location level only. |

### PHASE 3 — After #2 and #11 merge

| # | Task | Worktree | Owner | Priority | Frontend Test Instructions |
|---|------|----------|-------|----------|---------------------------|
| 3 | **Backend: Level-specific approval queues** — Extend `/api/v1/ai-approvals` routes to filter by `approval_level`. Location managers see only their location's pending items. Brand admins see their brand's items at brand level. Corporate sees everything. Integrate with upgraded permissions service for RBAC. Add query params: `?level=location&location_id=X` and `?level=brand&brand_id=X`. | **hurb-1** | Daniel | P0 | Log in as location user — approval queue should only show items for your location at location level. Log in as brand admin — should see brand-level items across locations in your brand. Log in as super admin — should see all items at all levels. |
| 4 | **Backend: Approval notifications (hierarchical)** — When item advances levels, notify next-level approvers via email + in-app notification. When rejected, notify submitter + all previous approvers in the chain. Use existing notification system (SendGrid for email, Socket.io for in-app). Include item details, approval chain status, and direct link to approval page. | **hurb-5** | Daniel | P1 | Approve an item at location level. Check that brand-level approvers get an in-app notification and email. Reject at brand level — check that the original submitter AND the location approver both get notified. |
| 5 | **Backend: Approval delegation + SLA/escalation** — Allow approvers to delegate to another user at same level via `POST /api/v1/ai-approvals/:id/delegate`. Auto-escalation: if `sla_deadline` passes without action, auto-advance to next level and mark `escalated_at`. SLA defaults: 24h for location, 48h for brand, 72h for corporate (configurable in company_approval_settings). | **hurb-6** | Daniel | P1 | Delegate an approval to another user — confirm it moves to their queue and leaves yours. For SLA: set a short deadline (override to 1 minute for testing), wait for it to pass, confirm item auto-escalates to next level. |
| 7 | **Frontend: Approval chain status tracker** — Visual component showing approval progress on campaigns/content: `Location [checkmark] -> Brand [pending] -> Corporate [waiting]`. Clickable to show who approved, when, and any comments. Show on campaign detail page and in campaign list as a badge/pill. | **hurb-7** | Daniel | P1 | Open a campaign that's mid-approval. Verify the status tracker shows correct state (which levels are done, which is pending). Click into it — should show approver names, timestamps, comments. Check it also appears as a compact badge in the campaign list view. |

### PHASE 4 — After #3 merges

| # | Task | Worktree | Owner | Priority | Frontend Test Instructions |
|---|------|----------|-------|----------|---------------------------|
| 6 | **Frontend: Approval queue UI** — New page at `/approvals` showing pending items for current user's level. Columns: item name, type, submitted by, submitted date, approval level, SLA countdown. Actions: approve (with optional comment), reject (comment required), delegate, bulk approve. Filter by location/brand, item type. Sort by SLA urgency. | **hurb-3** | Daniel | P0 | Navigate to /approvals. Verify you see only items relevant to your role/level. Approve one with a comment — confirm it disappears from your queue and appears in next level's queue. Reject one — confirm comment is required. Try bulk approve on 3 items. Check SLA countdown ticking. |

### PHASE 5 — After #1-6 all merged

| # | Task | Worktree | Owner | Priority | Frontend Test Instructions |
|---|------|----------|-------|----------|---------------------------|
| 14 | **End-to-end approval flow smoke test** — Full walkthrough: create content as CHS location user -> approve at location level -> approve at brand level -> approve at corporate level -> verify audit trail shows all 3 approvals with timestamps, approvers, comments. Test rejection at each level. Test delegation. Test SLA escalation. Test 1-level and 2-level flows for non-campaign content. | **hurb-8** | Daniel | P0 | This IS the test. Run through every scenario listed. Document any bugs as issues. |

### NICK (Content Studio) — Independent

| # | Task | Worktree | Owner | Priority | Frontend Test Instructions |
|---|------|----------|-------|----------|---------------------------|
| 9 | **Backend: Content version history improvements** — FileVersion model exists. Add endpoints: `GET /api/v1/files/:id/versions` (list versions with timestamps, author, size), `GET /api/v1/files/:id/versions/:versionId/diff` (diff two versions), `POST /api/v1/files/:id/versions/:versionId/restore` (restore previous version, creates new version). | **juhnk** | Nick | P2 | Upload a file, edit it a few times. Open version history — should show all versions with dates. Click diff between two versions. Restore an old version — confirm it becomes the current version and a new version entry is created. |

### DAD — Demo Prep

| # | Task | Worktree | Owner | Priority | Frontend Test Instructions |
|---|------|----------|-------|----------|---------------------------|
| 12 | **Frontend: Dashboard demo data seeding** | **danbox** | Dad | P2 | (see Phase 1 description above) |

> Note: #12 is listed in Phase 1 for Daniel (hurb-3) OR can be assigned to danbox for Dad — whoever picks it up first.

### TOOLING — DevTracker Enhancement

| # | Task | Worktree | Owner | Priority | Frontend Test Instructions |
|---|------|----------|-------|----------|---------------------------|
| 15 | **DevTracker: MVP Tracker tab** — Real-time component completion tracking. New tab in DevTracker showing all 21 major components + 100+ sub-components from the MVP Beta Component Matrix. Stage-based progress (0/20/40/60/80/100%) with automated signal detection (file existence, test pass rate, branch merge status, Sentry regressions) and manual gates (spec review, QA sign-off). Per-developer velocity-based ETA estimation. Links components to file paths, branches, and commits. Data model: `MvpComponent` (id, name, category, parent_id, completion_pct, stage, mapped_files JSON, mapped_endpoints JSON, assigned_developer_id, mvp_priority, role_access JSON, acceptance_criteria TEXT, last_signal_check). Seed from `MVP_BETA_COMPONENT_MATRIX.csv`. | **hurb-4** | Daniel | P1 | Navigate to DevTracker, click MVP Tracker tab. Verify all 21 major components display with sub-components expandable. Check completion percentages match reality. Click a component — should show mapped files, recent commits, assigned dev, stage gates. Verify the overall MVP % and ETA update when a component stage advances. |

---

## In Progress (Claimed)

| # | Task | Owner | Worktree | Started | Status |
|---|------|-------|----------|---------|--------|
| 12 | Dashboard demo data seeding | Daniel | hurb-3 | 2026-03-05 | Script written, ready for testing |

---

## Completed

| # | Task | Owner | Worktree | Completed |
|---|------|-------|----------|-----------|
| B1 | Approval workflow architecture design | Board Claude | board | 2026-03-04 |
| I1 | WSL recovery + storage overhaul (see CHANGELOG.md) | Daniel + Claude Code | — | 2026-03-06 |
| I2 | EVE rebuild — 3 instances on llama3.3:70b | Daniel + Claude Code | — | 2026-03-06 |
| I3 | Ollama + Llama 3.3 70B installed on D: | Daniel + Claude Code | — | 2026-03-06 |
| I4 | Automated weekly WSL backup (Sundays 4AM) | Daniel + Claude Code | — | 2026-03-06 |

---

## Blockers

| # | Blocker | Who's Blocked | Waiting On | Since |
|---|---------|---------------|------------|-------|
| I1 | F: drive (OWC SoftRAID) controller errors — dozens since Mar 3. Monitor. | All (data risk) | Investigation | 2026-03-03 |
| I2 | EVE RAG indexes partially rebuilt — `internal` done, `team` and `client` still need ingestion | EVE users | `eve ingest team` + `eve ingest client` | 2026-03-06 |

---

## Future Track: Ellianos (Franchisee Buying Experience)

> Not blocking CHS demo. Core insight: Ellianos franchisees need a "Dominos app" experience — frictionless campaign buying.
>
> **What already exists:** CampaignPackageConfig (pricing/packages), campaignChannelPopulator (auto-fill from location data), MLU multi-location drafts, template_variables on Content Studio templates. The backend infrastructure is largely built.
>
> **What's missing:** Needs hands-on review of the current location user experience to identify actual UX gaps. The 13-step campaign wizard is likely too heavy for a franchisee — may need a simplified "storefront" fast-path that leverages existing packages. Will scope after CHS demo work settles.

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
3. **All worktrees are on Monster** — read/write BOARD.md directly, no git pull needed for local coordination. All Claude sessions see the same file in real time.
4. **Git push is for backup and remote access** — commit + push periodically: `cd /d/blackwave/board && git add -A && git commit -m "board update" && git push`. Git workflow for ADBOX codebase is unchanged (branches, PRs, Railway deploys).
5. **Verify before reporting** — before updating a blocker or status, actually check the filesystem/system. Don't trust stale text. Run commands, check files, confirm state.
6. **48-hour staleness rule** — if a status hasn't been updated in 48h, it's suspect. Any session should flag and verify stale entries.
7. **When a hurb finishes a task**, it must include frontend test instructions in its completion message so Daniel knows what to verify
8. **Roadmap lives in ROADMAP.md** — BOARD.md is the real-time snapshot (what's happening now). ROADMAP.md is the plan (what's coming).
