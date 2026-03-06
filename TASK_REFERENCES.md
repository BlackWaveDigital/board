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
backend/src/models/ai_approval_item.js                    <- existing model, add fields here
backend/src/models/company_approval_settings.js           <- company-level approval config
backend/src/models/content_approval_audit.js              <- existing audit model
backend/src/models/index.js                               <- model registry, check associations
backend/src/api/controllers/ai-approvals.js               <- existing approval controller
backend/src/api/controllers/ai-approvals-submit.js        <- submission controller
backend/src/api/routes/ai-approvals.js                    <- existing routes
backend/src/api/routes/approvals.js                       <- additional approval routes
```

**Existing approval migrations (naming convention reference):**
```
backend/src/migrations/20251119120000-create-ai-approval-items.js
backend/src/migrations/20251207300000-add-approval-source-fields.js
backend/src/migrations/20251207300001-create-company-approval-settings.js
backend/src/migrations/20251231210000-add-campaign-approval-gate-fields.js
backend/src/migrations/20251231210001-create-content-approval-audit.js
backend/src/migrations/20260302000000-add-per-action-approval-settings.js
backend/src/migrations/20260302000001-extend-ai-approval-items-enums.js
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
frontend/src/components/inbox/ApprovalPanel.tsx                <- existing approval UI
frontend/src/components/campaigns/AssetApproval/AssetApprovalToolbar.tsx
frontend/src/components/campaigns/AssetApproval/AssetApproveButton.tsx
frontend/src/components/dashboard/widgets/core/PendingApprovalsWidget.tsx <- dashboard widget
frontend/src/services/approvals.ts                             <- frontend approval API service
frontend/src/components/campaigns/CampaignStatusBadge/CampaignStatusBadge.tsx <- badge pattern
frontend/src/components/ui/badge.tsx                           <- shadcn badge
```

**Build:** Visual component `ApprovalChainTracker` showing `Location [check] -> Brand [pending] -> Corporate [waiting]`. Clickable to expand approver details. Show on campaign detail page and as compact badge in campaign list.

---

## hurb-2: Task #10 (Role + UserRole Models)

### Task #10: Backend — Flesh out Role + UserRole models

**Read these first:**
```
backend/src/models/role.js                        <- add level enum, permissions JSON, is_approval_role
backend/src/models/user_role.js                   <- add location_id, brand_id scoping
backend/src/models/userrole_permission.js         <- existing permission linkage
backend/src/models/permission.js                  <- existing permissions
backend/src/models/user_feature_permission.js     <- feature-level permissions
backend/src/services/rbacService.js               <- ADMIN_ROLES, add APPROVAL_ROLES grouping
backend/src/middleware/auth/permissionLoader.js    <- how permissions are loaded per request
```

**Existing permission migrations:**
```
backend/src/migrations/20221103055334-create-permission.js
backend/src/migrations/20221103055658-create-user-role-permission.js
backend/src/migrations/20251211200000-add-ad-ops-roles-and-permissions.js
```

**Design reference:** See BOARD.md "Design Decisions (B1)" for the approval hierarchy and role mapping.

---

## hurb-3: Task #12 (Demo Data), #13 (CHS Templates), E7, E6

### Task #12: Dashboard demo data seeding

**Read these first:**
```
backend/src/models/                               <- all models for entities to seed
backend/src/seeders/                              <- existing seeder patterns (if any)
frontend/src/pages/dashboard/DashboardRouter.tsx  <- role-based shell routing
frontend/src/pages/dashboard/roleTemplates.ts     <- dashboard templates per role
```

### Task #13: CHS campaign template library

**Read these first:**
```
frontend/src/pages/campaignsNew/                  <- campaign creation wizard
backend/src/models/campaign_package_config.js     <- campaign package/template model (if exists)
```

### Task E7: Ellianos company + locations + users setup

**Read these first:**
```
backend/src/models/company.js                     <- company model
backend/src/models/location.js                    <- location model
backend/src/models/location_group.js              <- location grouping
backend/src/models/location_group_data.js         <- group data
backend/src/models/location_additional_field.js   <- custom fields per location
backend/src/models/user_location_group.js         <- user-location assignment
backend/src/models/user.js                        <- user model
backend/src/models/account.js                     <- has access_scope, is_client_user, client_brand_ids
backend/src/services/rbacService.js               <- role IDs and definitions
backend/src/api/controllers/location.js           <- location CRUD
backend/src/api/routes/location.js                <- location routes
backend/src/services/locationCrossCheckService.js  <- location validation
```

**Create:** Ellianos company, coffee shop locations, brand admin user, location user accounts. Assign correct roles.

### Task E6: Meta account connection for Ellianos

**Read these first:**
```
backend/src/services/meta/                        <- Meta integration services
backend/src/services/metaAuthService.js           <- OAuth flow
backend/src/api/controllers/meta-analytics.js     <- analytics sync
backend/src/api/routes/analytics.js               <- analytics routes
```

**Action:** Submit Meta app review AND add Ellianos as test user as fallback.

---

## hurb-4: Task E1/B1 (Role Gate), E5 (Content Studio Access)

### Task E1/B1: Role gate for location users

**This is the most cross-cutting task. Read all of these:**

**Sidebar (where menu items are shown/hidden):**
```
frontend/src/theme/layout/components/sidebarTailwind/navigation.config.ts  <- RBAC menu config — THIS IS THE KEY FILE
frontend/src/theme/layout/components/sidebarTailwind/SidebarMenu.tsx        <- renders menu items
frontend/src/theme/layout/components/sidebarTailwind/index.tsx              <- sidebar root
frontend/src/theme/layout/components/sidebarTailwind/SidebarStore.tsx       <- sidebar state
frontend/src/theme/layout/components/sidebarTailwind/SidebarHeader.tsx
frontend/src/theme/layout/components/sidebarTailwind/SidebarActions.tsx
frontend/src/theme/layout/components/sidebarTailwind/FooterSidebar.tsx
frontend/src/theme/layout/components/sidebarTailwind/ManageLocationSidebar.tsx
frontend/src/theme/layout/components/sidebarTailwind/SidebarCreditBalance.tsx
```

**Route guards:**
```
frontend/src/routes/Routes.tsx                     <- main route definitions
frontend/src/routes/routeConfigs/campaignRoutes.tsx
frontend/src/routes/routeConfigs/adminRoutes.tsx
frontend/src/routes/route-manifest.json            <- route registry (check for regression)
```

**Existing gate patterns:**
```
frontend/src/components/usage/FeatureGate.tsx      <- existing feature gate component
frontend/src/components/MobileAccessGuard/MobileAccessGuard.tsx
```

**Dashboard routing:**
```
frontend/src/pages/dashboard/DashboardRouter.tsx   <- maps role -> dashboard shell
frontend/src/pages/dashboard/roleTemplates.ts      <- dashboard content per role
```

**Backend RBAC:**
```
backend/src/services/rbacService.js                <- role definitions, ADMIN_ROLES
backend/src/models/role.js
backend/src/models/account.js                      <- access_scope, is_client_user fields
backend/src/middleware/auth/permissionLoader.js
backend/src/middleware/approvalGate.js
backend/src/api/controllers/location-permissions.js
```

**Mobile (also needs role gating):**
```
frontend/src/components/mobile/MobileBottomNav.tsx
frontend/src/components/mobile/MobileTopNav.tsx
frontend/src/theme/layout/components/header/Navbar.tsx
```

**Build:** `<RoleGate>` component. For location users: hide Create Campaign button, hide campaign wizard, hide admin sidebar items. Show: Content Studio, campaign cards (browse), analytics (read-only), purchase flow.

**Key principle:** Same UI, role-based visibility. Do NOT build a separate location user UI.

### Task E5: Content Studio access for location users

**Read these first:**
```
frontend/src/pages/creativeAssets/index.tsx         <- Content Studio main page
frontend/src/pages/creativeAssets/configure/        <- configuration (hide for locations)
frontend/src/pages/creativeAssets/aiGenerate/       <- AI generation (hide for locations)
frontend/src/pages/creativeAssets/components/AssetViewSwitcher.tsx
frontend/src/pages/creativeAssets/components/AdCopyGallery.tsx
frontend/src/theme/layout/components/sidebarTailwind/navigation.config.ts <- add CS to location role
```

**Build:** Add Content Studio to location user's sidebar. They can browse + view + download. Hide creation/AI generation features per role.

---

## hurb-5: Task #15 (MVP Tracker Tab), then E2/B2 (Campaign Cards)

### Task #15: DevTracker — MVP Tracker + Roadmap tab

**CRITICAL: Follow existing tab pattern exactly.**

**Step 1 — Understand the tab system:**
```
frontend/src/pages/superadmin/DevTracker/index.tsx  <- TABS array, tab routing, lazy loading pattern
```

**Step 2 — Study an existing tab as pattern:**
```
frontend/src/pages/superadmin/DevTracker/tabs/DevelopersTab.tsx   <- best pattern reference
frontend/src/pages/superadmin/DevTracker/tabs/LeaderboardTab.tsx
frontend/src/pages/superadmin/DevTracker/tabs/TasksTab.tsx       <- closest to what we're building
frontend/src/pages/superadmin/DevTracker/tabs/FeaturesTab.tsx
frontend/src/pages/superadmin/DevTracker/tabs/ChangelogTab.tsx
frontend/src/pages/superadmin/DevTracker/tabs/AlertsTab.tsx
frontend/src/pages/superadmin/DevTracker/tabs/IdeasTab.tsx
frontend/src/pages/superadmin/DevTracker/tabs/MetricsTab.tsx
frontend/src/pages/superadmin/DevTracker/tabs/SystemTab.tsx
frontend/src/pages/superadmin/DevTracker/tabs/ActivityTab.tsx
```

**Step 3 — Reusable components:**
```
frontend/src/pages/superadmin/DevTracker/components/DeveloperStatCard.tsx
frontend/src/pages/superadmin/DevTracker/components/LeaderboardCard.tsx
frontend/src/pages/superadmin/DevTracker/components/ActivityFeedCard.tsx
frontend/src/pages/superadmin/DevTracker/components/ActiveBranchesCard.tsx
frontend/src/pages/superadmin/DevTracker/components/AIStatsCard.tsx
frontend/src/pages/superadmin/DevTracker/components/CurrentWorkCard.tsx
frontend/src/pages/superadmin/DevTracker/components/PerformanceScoresCard.tsx
frontend/src/pages/superadmin/DevTracker/components/ContributionAreaBar.tsx
frontend/src/pages/superadmin/DevTracker/components/TrendIndicator.tsx
frontend/src/pages/superadmin/DevTracker/components/TabErrorBoundary.tsx  <- wrap your tab in this
frontend/src/pages/superadmin/DevTracker/DeveloperProfilePage.tsx          <- profile page pattern
```

**Step 4 — Frontend API layer:**
```
frontend/src/services/superadmin/devTracker.ts      <- ALL API functions + TypeScript types
frontend/src/hooks/queries/useSuperadminQueries.ts  <- React Query hooks (add new ones here)
frontend/src/hooks/queries/keys.ts                  <- query key definitions (add new keys here)
```

**Step 5 — Backend services & controllers:**
```
backend/src/services/leaderboardService.js                            <- scoring engine (velocity data)
backend/src/services/branchTrackingService.js                         <- branch + activity tracking
backend/src/services/developerLinkingService.js                       <- user-developer linking
backend/src/api/controllers/superadmin/developerController.js         <- dev CRUD, stats, workload
backend/src/api/controllers/superadmin/developerProfileController.js  <- commits, PRs, reviews, charts
backend/src/api/controllers/superadmin/leaderboardController.js       <- rankings + insights
backend/src/api/controllers/superadmin/branchTrackingController.js    <- branches, activity feed, deployments
backend/src/api/controllers/superadmin/teamDashboardController.js     <- team overview, velocity trends
backend/src/api/routes/superadmin.js                                  <- all dev-tracker routes (~lines 367-568)
```

**Step 6 — Models (existing, for reference/joins):**
```
backend/src/models/Developer.js                     <- core developer profile
backend/src/models/DeveloperMetricsDaily.js         <- daily aggregated metrics
backend/src/models/DeveloperActivityFeed.js         <- activity feed entries
backend/src/models/DeveloperBranch.js               <- branch tracking
backend/src/models/DeveloperFeatureContribution.js  <- feature area contributions
backend/src/models/DeveloperSkill.js                <- skills
backend/src/models/GithubCommit.js                  <- commits (sha, message, additions, deletions)
backend/src/models/GithubPullRequest.js             <- PRs
backend/src/models/GithubReview.js                  <- code reviews
backend/src/models/EveDeveloperAlert.js             <- alerts
backend/src/models/ProductionDeployment.js          <- deployments
backend/src/models/SentryAnalysis.js                <- Sentry error analysis
backend/src/models/SentryErrorCommit.js             <- error-commit links
backend/src/models/ChangelogDeveloper.js            <- changelog attribution
```

**Step 7 — Migration pattern reference:**
```
backend/src/migrations/20260122000001-add-developer-org-membership.js
backend/src/migrations/20260123000001-create-developer-branch-tracking.js
backend/src/migrations/20260129100000-add-developer-skills.js
```

**Data to seed from:**
```
/mnt/d/blackwave/board/screenshots/MVP_BETA_COMPONENT_MATRIX.csv  <- component matrix (21 major, 100+ sub)
/mnt/d/blackwave/board/BOARD.md                                    <- worktree queues, task status
/mnt/d/blackwave/board/ROADMAP.md                                  <- milestones, timelines
```

**New backend models needed:**
```
MvpComponent:       id, name, category, parent_id, completion_pct, stage, mapped_files (JSON),
                    mapped_endpoints (JSON), assigned_developer_id (FK), mvp_priority, role_access (JSON),
                    acceptance_criteria (TEXT), last_signal_check, eta_days (FLOAT)

ProjectMilestone:   id, name, track (chs/ellianos/beta), target_date, status, completion_pct, description

WorktreeTask:       id, task_number, title, worktree, developer_id (FK), priority, status,
                    depends_on (JSON array of task IDs), started_at, completed_at, track
```

**Build:** New "MVP Tracker" tab. Add to TABS + VALID_TABS arrays in index.tsx. Create `MvpTrackerTab.tsx`. Wrap in `<TabErrorBoundary>`. Sections: Component Tracker, Roadmap View, Worktree Status, Task Queues, Developer Velocity.

### Task E2/B2: Campaign cards for locations (after E1 done)

**Read these first:**
```
frontend/src/components/campaigns/CampaignCard/CampaignCard.tsx
frontend/src/components/campaigns/CampaignCard/CampaignCardSkeleton.tsx
frontend/src/components/campaigns/CampaignCard/CampaignListRow.tsx
frontend/src/components/campaigns/CampaignCard/CampaignCard.stories.tsx    <- storybook examples
frontend/src/pages/campaignsNew/Campaigns/index.tsx                        <- campaign browser
frontend/src/pages/campaignsNew/Campaigns/PreviewCampaignModal.tsx
frontend/src/components/campaigns/CampaignStatusBadge/CampaignStatusBadge.tsx
frontend/src/pages/campaign/components/CampaignDetailsModal.tsx
```

**Purchase flow (card links to this):**
```
frontend/src/pages/campaignsNew/CampaignCheckout/CampaignCheckout.tsx
frontend/src/pages/campaignsNew/CampaignCheckout/PaymentTypeSelector.tsx
frontend/src/pages/campaignsNew/shared/PaymentDetails.tsx
frontend/src/pages/campaignsNew/shared/CompletingPayment.tsx
```

**Backend:**
```
backend/src/api/controllers/ad-ops-orders/purchaseController.js
backend/src/services/campaignPurchaseService.js
backend/src/models/campaign_purchase.js
backend/src/api/routes/campaign.js
```

**Build:** Campaign cards that brand publishes to locations. Location users see these in the campaign browser with "Customize" and "Buy" actions. Extend existing CampaignCard or create CampaignPurchaseCard.

---

## hurb-6: Task E3/B3 (Media Plan Review)

### Task E3/B3: Media plan review before purchase

**Read these first:**
```
frontend/src/pages/mediaTeam/Dashboard/index.tsx
frontend/src/pages/mediaTeam/Dashboard/components/ManageCampaignPlanModal.tsx
frontend/src/pages/mediaTeam/manageCampaigns/index.tsx
frontend/src/pages/campaignsNew/CampaignCheckout/CampaignCheckout.tsx     <- comes after review
frontend/src/pages/campaignsNew/shared/PaymentDetails.tsx
```

**Backend data sources:**
```
backend/src/models/campaign_channel.js              <- channel allocations
backend/src/models/campaign_channel_inputs.js       <- channel input details
backend/src/models/ad_kits_campaign_plan.js         <- campaign plan
backend/src/models/campaign_content_variation.js    <- content variations
backend/src/services/campaignChannelPopulator.js    <- auto-fill from location data
backend/src/models/campaign_organization_location.js <- location-campaign links
```

**Build:** `MediaPlanReview.tsx` — read-only summary between campaign card and checkout. Shows: channel allocation table, flight dates, audience summary, budget. "I agree" checkbox + "Proceed to Payment" button.

---

## hurb-7: Task E4 (Credit Allocation)

### Task E4: Credit allocation from brand to locations

**Backend credits system (already exists):**
```
backend/src/models/CreditTransaction.js             <- transaction records
backend/src/models/CreditBalance.js                 <- balance per entity
backend/src/models/CreditAllocation.js              <- allocation records
backend/src/api/controllers/credits.js              <- credits CRUD
backend/src/api/routes/credits.js                   <- credits routes
backend/src/services/creditBalanceService.js         <- balance calculations
```

**Frontend credits:**
```
frontend/src/pages/credits/PurchaseCredits.tsx       <- purchase page
frontend/src/pages/credits/AllocateCredits.tsx       <- allocation page — CHECK IF THIS ALREADY DOES WHAT WE NEED
frontend/src/pages/campaignsNew/_components/Funding/CreditBalanceCard.tsx  <- balance display
frontend/src/pages/campaignsNew/_components/Funding/index.tsx              <- funding component
frontend/src/theme/layout/components/sidebarTailwind/SidebarCreditBalance.tsx
frontend/src/pages/accountSettings/billingNew/CreditsSummarySection.tsx
```

**Checkout (where credits auto-apply):**
```
frontend/src/pages/campaignsNew/CampaignCheckout/CampaignCheckout.tsx
frontend/src/pages/campaignsNew/CampaignCheckout/PaymentTypeSelector.tsx
backend/src/api/controllers/payment.js
backend/src/api/routes/payment.js
backend/src/api/controllers/cron-job-payments.js
backend/src/api/controllers/cron-helpers/paymentHelpers.js
```

**Square integration:**
```
backend/src/models/square_transaction_summary.js
backend/src/models/payment_method.js
backend/src/api/controllers/paymentmethod.js
backend/src/api/routes/paymentmethod.js
backend/src/services/squareTransactionService.js
backend/src/api/controllers/square-webhooks.js
frontend/src/components/SquarePayment/SquarePaymentForm.tsx
```

**Build:** V1 manual credit allocation. Brand admin allocates credit balance to locations via AllocateCredits page. At checkout, location user sees credit balance and it auto-applies. Remainder paid by card.

---

## hurb-8: Task #2 (Approval State Machine), #4 (Notifications), #14 (E2E Test)

### Task #2: Backend — Approval chain state machine (BLOCKED: needs #1 and #10 merged)

**Existing approval system (read ALL of these):**
```
backend/src/models/ai_approval_item.js              <- model (after #1 adds hierarchical fields)
backend/src/models/company_approval_settings.js     <- company-level config
backend/src/models/content_approval_audit.js        <- audit trail model
backend/src/api/controllers/ai-approvals.js         <- main approval controller
backend/src/api/controllers/ai-approvals-submit.js  <- submission controller
backend/src/api/controllers/campaigns/content-approval.js <- campaign content approval
backend/src/api/routes/ai-approvals.js              <- approval routes
backend/src/api/routes/approvals.js                 <- additional routes
backend/src/services/rbacService.js                 <- roles (after #10 adds approval roles)
backend/src/middleware/approvalGate.js              <- existing gate middleware
```

**Audit trail system (use these for logging state transitions):**
```
backend/src/services/auditLogger.js                 <- audit logging service
backend/src/services/activityLogger.js              <- activity logging
backend/src/services/activityWebSocket.js           <- real-time activity via WebSocket
backend/src/middleware/auditMiddleware.js            <- audit middleware
backend/src/models/audit_log.js                     <- audit log model
backend/src/models/content_approval_audit.js        <- approval-specific audit
backend/src/models/eve_action_audit.js              <- EVE audit pattern
backend/src/models/ad_ops_task_activity.js          <- task activity pattern
```

**Inbox system (approval items may route here):**
```
backend/src/models/inbox_item.js                    <- inbox items
backend/src/models/inbox_thread.js                  <- inbox threads
backend/src/services/inboxService.js                <- inbox service
backend/src/api/controllers/inbox.js                <- inbox controller
```

**Build:** New service `approvalChainService.js`. States: `pending -> location_approved -> brand_approved -> corporate_approved` (or `rejected` at any level). Use `auditLogger.js` and `content_approval_audit` for state transition logging.

### Task #4: Approval notifications (after #2 done)

**Notification system:**
```
backend/src/services/notificationService.js         <- main notification service
backend/src/services/email/sesService.js            <- email via SES (not SendGrid)
backend/src/api/controllers/notification.js         <- notification controller
backend/src/api/routes/notification.js              <- notification routes
backend/src/models/notification.js                  <- notification model
backend/src/models/notification_settings.js         <- user preferences
backend/src/models/notification_read_status.js      <- read tracking
backend/src/models/alert_notification.js            <- alert notifications
```

**Socket.io for real-time:**
```
backend/src/utils/socket.js                         <- Socket.io server setup
frontend/src/helpers/socket.ts                      <- frontend socket helper
```

**Build:** When item advances levels, notify next-level approvers (email via SES + in-app via Socket.io). When rejected, notify submitter + all previous approvers.

### Task #14: E2E approval smoke test (after #1-6 all merged)

**Frontend approval components to test through:**
```
frontend/src/components/inbox/ApprovalPanel.tsx
frontend/src/components/inbox/InboxDetailPanel.tsx
frontend/src/components/inbox/InboxItemRow.tsx
frontend/src/components/inbox/BulkActionsBar.tsx
frontend/src/components/inbox/RejectDialog.tsx
frontend/src/components/campaigns/AssetApproval/AssetApprovalToolbar.tsx
frontend/src/components/campaigns/AssetApproval/AssetApproveButton.tsx
frontend/src/components/dashboard/widgets/core/PendingApprovalsWidget.tsx
frontend/src/services/approvals.ts                  <- frontend approval API
```

---

## hurb-9: Task #11 (Permissions Upgrade), #5 (Delegation/SLA)

### Task #11: Backend — Permissions service upgrade (BLOCKED: needs #1 and #10 merged)

**Read these first:**
```
backend/src/services/rbacService.js                 <- current RBAC logic
backend/src/services/assetPermissionService.js      <- asset-level permissions (pattern reference)
backend/src/middleware/auth/permissionLoader.js      <- how permissions load per request
backend/src/models/user_role.js                     <- user role (after #10 adds scoping)
backend/src/models/role.js                          <- role model (after #10 adds level)
backend/src/models/permission.js                    <- permissions
backend/src/models/userrole_permission.js           <- role-permission links
backend/src/models/user_feature_permission.js       <- feature permissions
backend/src/middleware/approvalGate.js               <- existing gate
backend/src/api/controllers/location-permissions.js  <- location permission patterns
```

**Build:** Extend permissionsService: "Can user X approve at level Y for location/brand Z?" Check role, role level, location_id/brand_id scoping. Super Admin (1) and Platform Admin (13) bypass all.

### Task #5: Approval delegation + SLA/escalation (after #11 done)

**Build on top of:** `approvalChainService.js` (from #2) and permissionsService (from #11).

**New endpoint:** `POST /api/v1/ai-approvals/:id/delegate`

**SLA auto-escalation:** If `sla_deadline` passes, auto-advance. Defaults: 24h location, 48h brand, 72h corporate. Configurable in `company_approval_settings`.

---

## hurb-10: Task #3 (Approval Queues), #6 (Approval Queue UI)

### Task #3: Backend — Level-specific approval queues (BLOCKED: needs #2 and #11 merged)

**Read these first:**
```
backend/src/api/controllers/ai-approvals.js          <- extend with level filters
backend/src/api/routes/ai-approvals.js               <- add query params
backend/src/services/approvalChainService.js         <- from #2
backend/src/services/rbacService.js                  <- for role checks
```

**Build:** Extend `/api/v1/ai-approvals` with `?level=location&location_id=X` and `?level=brand&brand_id=X`. Integrate with permissions service for RBAC filtering.

### Task #6: Frontend — Approval queue UI (after #3 done)

**Read these first:**
```
frontend/src/components/inbox/ApprovalPanel.tsx       <- existing approval UI (may be able to extend)
frontend/src/components/inbox/InboxDetailPanel.tsx    <- detail view pattern
frontend/src/components/inbox/InboxItemRow.tsx        <- list row pattern
frontend/src/components/inbox/BulkActionsBar.tsx      <- bulk actions pattern
frontend/src/components/inbox/RejectDialog.tsx        <- reject with comment
frontend/src/services/approvals.ts                   <- approval API service
frontend/src/components/ui/                          <- shadcn components
frontend/src/pages/superadmin/DevTracker/tabs/TasksTab.tsx <- similar list pattern
```

**Build:** New page at `/approvals`. Columns: item name, type, submitted by, date, approval level, SLA countdown. Actions: approve (optional comment), reject (comment required), delegate, bulk approve.

---

## juhnk (Nick): Task #8 (National Buying UI), #9 (Content Version History)

### Task #8: National buying workflow UI

**Read these first:**
```
frontend/src/pages/campaignsNew/                    <- campaign wizard (13 steps)
frontend/src/pages/campaignsNew/CampaignCheckout/   <- checkout flow
backend/src/models/campaign_organization_location.js <- multi-location campaigns
backend/src/services/campaignChannelPopulator.js     <- auto-fill logic
backend/src/models/location.js                      <- location model
backend/src/models/location_group.js                <- location groups
```

**Build:** Scope selector in campaign wizard: single location / multi-location / national. When "Buy Nationally": apply to all locations, aggregate pricing, single checkout.

### Task #9: Content version history improvements

**Read these first:**
```
backend/src/models/file_version.js                  <- FileVersion model
backend/src/models/file.js                          <- File model
frontend/src/pages/creativeAssets/                   <- Content Studio
frontend/src/pages/creativeAssets/components/        <- CS components
```

**Build:** Endpoints: list versions, diff two versions, restore previous version (creates new version).
