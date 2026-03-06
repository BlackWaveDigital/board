# Task References — File Paths & Context for Each Hurb

> **Purpose:** When a Claude session starts on a hurb, it reads BOARD.md for its task queue, then reads THIS file for the exact codebase paths, patterns, and context needed to build each task.
>
> **All paths relative to:** `/mnt/d/blackwave/adbox/testing/` (the latest codebase reference)
> **Your worktree is at:** `/mnt/d/blackwave/adbox/<your-worktree>/`
>
> **IMPORTANT:** Always read CLAUDE.md in your worktree first. It has 1200 lines of standards you MUST follow.

---

## hurb-1: Task #1 (DB Migration) then #7 (Status Tracker UI)

### Task #1: DB — Add hierarchical fields to ai_approval_item

**Read these first:**
```
backend/src/models/ai_approval_item.js          <- existing model, add fields here
backend/src/models/index.js                      <- model registry, check associations
backend/src/api/controllers/ai-approval.js       <- existing controller (verify backwards compat)
backend/src/api/routes/ai-approval.js            <- existing routes
```

**Migration pattern to follow:**
```
backend/src/migrations/                          <- look at recent migrations for naming convention
```

**New fields to add to ai_approval_item:**
- `location_id` (INTEGER, nullable, FK -> locations)
- `brand_id` (INTEGER, nullable, FK -> companies)
- `approval_level` (ENUM: 'location', 'brand', 'corporate', nullable)
- `approval_chain_id` (UUID, nullable)
- `escalated_at` (DATE, nullable)
- `sla_deadline` (DATE, nullable)
- `required_approval_depth` (INTEGER 1/2/3, nullable)

**Critical:** Migration must be backwards-compatible. All new fields nullable. Existing flat approval rows must continue to work.

### Task #7: Frontend — Approval chain status tracker (Phase 3, after #2 and #11 merge)

**Read these first:**
```
frontend/src/pages/campaign/components/          <- campaign detail components, add tracker here
frontend/src/pages/campaignsNew/Campaigns/       <- campaign list, add badge/pill here
frontend/src/components/ui/badge.tsx             <- existing badge component
frontend/src/components/ui/                      <- shadcn components available
```

**Pattern reference:** Look at how `CampaignStatusBadge` works:
```
frontend/src/components/campaigns/CampaignStatusBadge/CampaignStatusBadge.tsx
```

**Build:** Visual component `ApprovalChainTracker` showing `Location [check] -> Brand [pending] -> Corporate [waiting]`. Clickable to expand approver details.

---

## hurb-2: Task #10 (Role + UserRole Models)

### Task #10: Backend — Flesh out Role + UserRole models

**Read these first:**
```
backend/src/models/role.js                       <- add level enum, permissions JSON, is_approval_role
backend/src/models/user_role.js                  <- add location_id, brand_id scoping
backend/src/models/userrole_permission.js        <- existing permission linkage
backend/src/models/permission.js                 <- existing permissions
backend/src/services/rbacService.js              <- ADMIN_ROLES, add APPROVAL_ROLES grouping
backend/src/middleware/auth/permissionLoader.js   <- how permissions are loaded per request
```

**Design reference:** See BOARD.md "Design Decisions (B1)" for the approval hierarchy and role mapping.

---

## hurb-3: Task #12 (Demo Data), #13 (CHS Templates), E7, E6

### Task #12: Dashboard demo data seeding

**Read these first:**
```
backend/src/models/                              <- all models for entities to seed
backend/src/seeders/                             <- existing seeder patterns (if any)
frontend/src/pages/dashboard/                    <- dashboard pages to verify data shows
frontend/src/pages/dashboard/DashboardRouter.tsx <- role-based shell routing
frontend/src/pages/dashboard/roleTemplates.ts    <- dashboard templates per role
```

### Task #13: CHS campaign template library

**Read these first:**
```
frontend/src/pages/campaignsNew/                 <- campaign creation wizard
backend/src/models/campaign_package_config.js    <- campaign package/template model (if exists)
```

### Task E7: Ellianos company + locations + users setup

**Read these first:**
```
backend/src/models/company.js                    <- company model
backend/src/models/location.js                   <- location model
backend/src/models/location_group.js             <- location grouping
backend/src/models/user.js                       <- user model
backend/src/models/account.js                    <- account model (has access_scope, is_client_user)
backend/src/services/rbacService.js              <- role IDs and definitions
backend/src/api/controllers/location.js          <- location CRUD
```

**Create:** Ellianos company, coffee shop locations, brand admin user, location user accounts. Assign correct roles.

### Task E6: Meta account connection for Ellianos

**Read these first:**
```
backend/src/services/meta/                       <- Meta integration services
backend/src/services/metaAuthService.js          <- OAuth flow
backend/src/api/controllers/meta-analytics.js    <- analytics sync
backend/src/api/routes/analytics.js              <- analytics routes
```

**Action:** Submit Meta app review AND add Ellianos as test user as fallback.

---

## hurb-4: Task E1/B1 (Role Gate), E5 (Content Studio Access)

### Task E1/B1: Role gate for location users

**This is the most cross-cutting task. Read all of these:**

**Sidebar (where menu items are shown/hidden):**
```
frontend/src/theme/layout/components/sidebarTailwind/navigation.config.ts  <- RBAC menu config
frontend/src/theme/layout/components/sidebarTailwind/SidebarMenu.tsx        <- renders menu items
frontend/src/theme/layout/components/sidebarTailwind/index.tsx              <- sidebar root
frontend/src/theme/layout/components/sidebarTailwind/SidebarStore.tsx       <- sidebar state
```

**Route guards:**
```
frontend/src/routes/Routes.tsx                    <- main route definitions
frontend/src/routes/routeConfigs/campaignRoutes.tsx <- campaign route config
frontend/src/routes/routeConfigs/adminRoutes.tsx   <- admin route config
```

**Existing gate patterns:**
```
frontend/src/components/usage/FeatureGate.tsx     <- existing feature gate component
frontend/src/components/MobileAccessGuard/MobileAccessGuard.tsx <- mobile guard pattern
```

**Dashboard routing:**
```
frontend/src/pages/dashboard/DashboardRouter.tsx  <- maps role -> dashboard shell
frontend/src/pages/dashboard/roleTemplates.ts     <- dashboard content per role
```

**Backend RBAC:**
```
backend/src/services/rbacService.js               <- role definitions, ADMIN_ROLES
backend/src/models/role.js                        <- role model
backend/src/models/account.js                     <- access_scope, is_client_user fields
backend/src/middleware/auth/permissionLoader.js    <- permission loading
backend/src/middleware/approvalGate.js             <- existing gate middleware
```

**Build:** `<RoleGate>` component. For location users: hide Create Campaign button, hide campaign wizard, hide admin sidebar items. Show: Content Studio, campaign cards (browse), analytics (read-only), purchase flow.

**Key principle:** Same UI, role-based visibility. Do NOT build a separate location user UI.

### Task E5: Content Studio access for location users

**Read these first:**
```
frontend/src/pages/creativeAssets/index.tsx        <- Content Studio main page
frontend/src/pages/creativeAssets/configure/       <- configuration (may need hiding)
frontend/src/pages/creativeAssets/aiGenerate/      <- AI generation (may need hiding)
frontend/src/theme/layout/components/sidebarTailwind/navigation.config.ts <- add CS to location role
```

**Build:** Add Content Studio to location user's sidebar. They can browse + view + download. Hide creation/AI generation features per role.

---

## hurb-5: Task #15 (MVP Tracker Tab), then E2/B2 (Campaign Cards)

### Task #15: DevTracker — MVP Tracker + Roadmap tab

**Existing DevTracker structure (follow this pattern exactly):**
```
frontend/src/pages/superadmin/DevTracker/index.tsx              <- main page, tab definitions
frontend/src/pages/superadmin/DevTracker/tabs/DevelopersTab.tsx  <- example tab (pattern reference)
frontend/src/pages/superadmin/DevTracker/tabs/LeaderboardTab.tsx <- leaderboard tab
frontend/src/pages/superadmin/DevTracker/tabs/SystemTab.tsx      <- system tab
frontend/src/pages/superadmin/DevTracker/tabs/AlertsTab.tsx      <- alerts tab
frontend/src/pages/superadmin/DevTracker/tabs/ChangelogTab.tsx   <- changelog tab
frontend/src/pages/superadmin/DevTracker/tabs/IdeasTab.tsx       <- ideas tab
frontend/src/pages/superadmin/DevTracker/tabs/FeaturesTab.tsx    <- features tab
frontend/src/pages/superadmin/DevTracker/tabs/TasksTab.tsx       <- tasks tab (similar concept)
```

**DevTracker components (reuse these):**
```
frontend/src/pages/superadmin/DevTracker/components/DeveloperStatCard.tsx    <- dev card
frontend/src/pages/superadmin/DevTracker/components/LeaderboardCard.tsx      <- leaderboard
frontend/src/pages/superadmin/DevTracker/components/ActivityFeedCard.tsx     <- activity feed
frontend/src/pages/superadmin/DevTracker/components/ActiveBranchesCard.tsx   <- branch tracking
frontend/src/pages/superadmin/DevTracker/components/AIStatsCard.tsx          <- AI stats
frontend/src/pages/superadmin/DevTracker/components/CurrentWorkCard.tsx      <- current work
frontend/src/pages/superadmin/DevTracker/components/PerformanceScoresCard.tsx <- scores
```

**Backend services:**
```
backend/src/services/leaderboardService.js                                    <- scoring engine
backend/src/api/controllers/superadmin/developerController.js                 <- dev CRUD + stats
backend/src/api/controllers/superadmin/leaderboardController.js               <- leaderboard
backend/src/api/controllers/superadmin/branchTrackingController.js            <- branch/activity
backend/src/api/controllers/superadmin/teamDashboardController.js             <- team dashboard
backend/src/api/routes/superadmin.js                                          <- all dev-tracker routes
```

**Frontend API service:**
```
frontend/src/services/superadmin/devTracker.ts     <- all API call functions + types
frontend/src/hooks/queries/useSuperadminQueries.ts <- React Query hooks
frontend/src/hooks/queries/keys.ts                 <- query key definitions
```

**Models:**
```
backend/src/models/Developer.js                    <- developer model
backend/src/models/DeveloperMetricsDaily.js        <- daily metrics
backend/src/models/GithubCommit.js                 <- commit tracking
backend/src/models/GithubPullRequest.js            <- PR tracking
backend/src/models/GithubReview.js                 <- review tracking
backend/src/models/DeveloperSkill.js               <- skills
```

**Data to seed from:**
```
/mnt/d/blackwave/board/screenshots/MVP_BETA_COMPONENT_MATRIX.csv  <- component matrix
/mnt/d/blackwave/board/BOARD.md                                    <- worktree queues, tasks
/mnt/d/blackwave/board/ROADMAP.md                                  <- milestones, timelines
```

**New backend model needed: `MvpComponent`**
```
Fields: id, name, category (major/support), parent_id (self-ref), completion_pct,
stage (not_started/specced/backend_built/frontend_built/tested/qa_verified),
mapped_files (JSON), mapped_endpoints (JSON), assigned_developer_id (FK),
mvp_priority (critical/mvp/bonus), role_access (JSON), acceptance_criteria (TEXT),
last_signal_check (TIMESTAMP), eta_days (FLOAT)
```

**Build:** New "MVP Tracker" tab in DevTracker. Add to TABS array in index.tsx. Create MvpTrackerTab.tsx following existing tab patterns.

### Task E2/B2: Campaign cards for locations (after E1 done)

**Read these first:**
```
frontend/src/components/campaigns/CampaignCard/CampaignCard.tsx        <- existing campaign card
frontend/src/components/campaigns/CampaignCard/CampaignCardSkeleton.tsx
frontend/src/components/campaigns/CampaignCard/CampaignListRow.tsx
frontend/src/pages/campaignsNew/Campaigns/index.tsx                    <- campaign browser
frontend/src/pages/campaignsNew/Campaigns/PreviewCampaignModal.tsx     <- preview modal
frontend/src/components/campaigns/CampaignStatusBadge/CampaignStatusBadge.tsx
```

**Purchase flow (card links to this):**
```
frontend/src/pages/campaignsNew/CampaignCheckout/CampaignCheckout.tsx
frontend/src/pages/campaignsNew/CampaignCheckout/PaymentTypeSelector.tsx
```

**Backend:**
```
backend/src/api/controllers/ad-ops-orders/purchaseController.js
backend/src/services/campaignPurchaseService.js
backend/src/models/campaign_purchase.js
```

**Build:** Campaign cards that brand publishes to locations. Location users see these in the campaign browser with "Customize" and "Buy" actions. Extend existing CampaignCard component or create CampaignPurchaseCard.

---

## hurb-6: Task E3/B3 (Media Plan Review)

### Task E3/B3: Media plan review before purchase

**Read these first:**
```
frontend/src/pages/mediaTeam/Dashboard/index.tsx                         <- existing media team
frontend/src/pages/mediaTeam/Dashboard/components/ManageCampaignPlanModal.tsx
frontend/src/pages/campaignsNew/CampaignCheckout/CampaignCheckout.tsx    <- checkout (comes after review)
frontend/src/pages/campaignsNew/shared/PaymentDetails.tsx
```

**Backend data sources:**
```
backend/src/models/campaign_channel.js             <- channel allocations
backend/src/models/campaign_channel_inputs.js      <- channel details
backend/src/models/ad_kits_campaign_plan.js        <- campaign plan
backend/src/models/campaign_content_variation.js   <- content variations
backend/src/services/campaignChannelPopulator.js   <- auto-fill from location data
```

**Build:** `MediaPlanReview.tsx` — read-only summary page between campaign card and checkout. Shows: channel allocation table, flight dates, audience summary, budget. "I agree to this media plan" checkbox + "Proceed to Payment" button.

---

## hurb-7: Task E4 (Credit Allocation)

### Task E4: Credit allocation from brand to locations

**Read these first (credits system already exists):**
```
backend/src/models/CreditTransaction.js            <- transaction records
backend/src/models/CreditBalance.js                <- balance per entity
backend/src/models/CreditAllocation.js             <- allocation records
backend/src/api/controllers/credits.js             <- credits CRUD
backend/src/api/routes/credits.js                  <- credits routes
backend/src/services/creditBalanceService.js       <- balance calculations
```

**Frontend credits:**
```
frontend/src/pages/credits/PurchaseCredits.tsx      <- purchase page
frontend/src/pages/credits/AllocateCredits.tsx      <- allocation page (may already do what we need)
frontend/src/pages/campaignsNew/_components/Funding/CreditBalanceCard.tsx <- balance display
frontend/src/pages/campaignsNew/_components/Funding/index.tsx             <- funding component
frontend/src/theme/layout/components/sidebarTailwind/SidebarCreditBalance.tsx <- sidebar balance
frontend/src/pages/accountSettings/billingNew/CreditsSummarySection.tsx
```

**Checkout (where credits auto-apply):**
```
frontend/src/pages/campaignsNew/CampaignCheckout/CampaignCheckout.tsx
frontend/src/pages/campaignsNew/CampaignCheckout/PaymentTypeSelector.tsx
backend/src/api/controllers/payment.js
backend/src/api/routes/payment.js
```

**Build:** V1 manual credit allocation. Brand admin allocates credit balance to locations via AllocateCredits page. At checkout, location user sees credit balance and it auto-applies. Remainder paid by card.

---

## hurb-8: Task #2 (Approval State Machine), #4 (Notifications), #14 (E2E Test)

### Task #2: Backend — Approval chain state machine (BLOCKED: needs #1 and #10 merged)

**Read these first:**
```
backend/src/models/ai_approval_item.js             <- the model (after #1 migration adds fields)
backend/src/api/controllers/ai-approval.js         <- existing approval controller
backend/src/api/routes/ai-approval.js              <- existing routes
backend/src/services/rbacService.js                <- roles (after #10 adds approval roles)
```

**Audit trail pattern:**
```
backend/src/models/activity_log.js                 <- if exists, use for audit trail
backend/src/services/                              <- look for existing logging service
```

**Build:** New service `approvalChainService.js`. States: `pending -> location_approved -> brand_approved -> corporate_approved` (or `rejected` at any level). Each transition logs to audit trail.

### Task #4: Approval notifications (after #2 done)

**Read these first:**
```
backend/src/services/notification/                 <- notification service directory
backend/src/utils/socket.js                        <- Socket.io setup
frontend/src/helpers/socket.ts                     <- frontend socket helper
backend/src/services/emailService.js               <- SendGrid (if exists, or check for email utils)
```

**Build:** When item advances levels, notify next-level approvers (email + in-app). When rejected, notify submitter + all previous approvers.

---

## hurb-9: Task #11 (Permissions Upgrade), #5 (Delegation/SLA)

### Task #11: Backend — Permissions service upgrade (BLOCKED: needs #1 and #10 merged)

**Read these first:**
```
backend/src/services/rbacService.js                <- current RBAC logic
backend/src/middleware/auth/permissionLoader.js     <- how permissions load per request
backend/src/models/user_role.js                    <- user role model (after #10 adds scoping)
backend/src/models/role.js                         <- role model (after #10 adds level)
backend/src/middleware/approvalGate.js              <- existing approval gate
backend/src/api/controllers/location-permissions.js <- location permission patterns
```

**Build:** Extend permissionsService: "Can user X approve at level Y for location/brand Z?" Check role, role level, location_id/brand_id scoping. Super Admin (1) and Platform Admin (13) bypass all.

### Task #5: Approval delegation + SLA/escalation (after #11 done)

**Build on top of:** approvalChainService.js (from #2) and permissionsService (from #11).

**New endpoint:** `POST /api/v1/ai-approvals/:id/delegate` — move approval to another user at same level.

**SLA auto-escalation:** If `sla_deadline` passes without action, auto-advance to next level. Defaults: 24h location, 48h brand, 72h corporate. Configurable per company.

---

## hurb-10: Task #3 (Approval Queues), #6 (Approval Queue UI)

### Task #3: Backend — Level-specific approval queues (BLOCKED: needs #2 and #11 merged)

**Read these first:**
```
backend/src/api/controllers/ai-approval.js         <- extend with level filters
backend/src/api/routes/ai-approval.js              <- add query params
backend/src/services/approvalChainService.js       <- from #2
```

**Build:** Extend `/api/v1/ai-approvals` with `?level=location&location_id=X` and `?level=brand&brand_id=X`. Integrate with permissions service for RBAC filtering.

### Task #6: Frontend — Approval queue UI (after #3 done)

**Read these first:**
```
frontend/src/pages/                                <- look at existing list pages for patterns
frontend/src/components/ui/                        <- shadcn components (table, badge, button, dialog)
frontend/src/pages/superadmin/DevTracker/tabs/TasksTab.tsx <- similar list UI pattern
```

**Build:** New page at `/approvals`. Columns: item name, type, submitted by, date, approval level, SLA countdown. Actions: approve (optional comment), reject (comment required), delegate, bulk approve.

---

## juhnk (Nick): Task #8 (National Buying UI), #9 (Content Version History)

### Task #8: National buying workflow UI

**Read these first:**
```
frontend/src/pages/campaignsNew/                   <- campaign wizard
frontend/src/pages/campaignsNew/CampaignCheckout/  <- checkout flow
backend/src/models/campaign_organization_location.js <- multi-location campaigns
backend/src/services/campaignChannelPopulator.js    <- auto-fill logic
```

**Build:** Scope selector in campaign wizard: single location / multi-location / national. When "Buy Nationally": apply to all locations, aggregate pricing, single checkout.

### Task #9: Content version history improvements

**Read these first:**
```
backend/src/models/file_version.js                 <- FileVersion model (if exists)
backend/src/models/file.js                         <- File model
frontend/src/pages/creativeAssets/                  <- Content Studio
```

**Build:** Endpoints: list versions, diff two versions, restore previous version.
