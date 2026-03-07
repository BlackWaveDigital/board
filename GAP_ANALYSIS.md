# ADBOX Gap Analysis — Money-Making Loop

> **Date:** 2026-03-06 | **Method:** Deep codebase trace of 3 critical flows
> **Codebase:** /home/blackwave/adbox/testing

---

## The Loop: Brand Creates → Location Buys → Platforms Run → Analytics Prove ROI

### FLOW 1: Campaign Creation → Card Visibility

| What | Status | Detail |
|------|--------|--------|
| 12-step wizard creates campaign | WORKS | CampaignOrganization model, is_draft=1 |
| CampaignCard component renders | WORKS | frontend/src/components/campaigns/CampaignCard/ |
| Location filtering via junction table | WORKS | CampaignOrganizationLocation links campaign → location |
| Location users only see published + active | WORKS | is_draft=0, active/continuous, assigned to their location |

**GAPS:**

| # | Gap | Severity | Detail |
|---|-----|----------|--------|
| G1 | No explicit "Publish to Locations" action | HIGH | Publishing = flipping is_draft from 1→0 during update. No dedicated button, no confirmation, no "who can see this" selector. Brand admin has no clear UX for making a campaign available to locations. |
| G2 | No CampaignPromoCard for location users | HIGH | CampaignCard exists but it's the admin view. Location users need simplified cards with Customize + Buy actions (E2 task on hurb-2 building this now). |
| G3 | Customization does NOT trigger approval | CRITICAL | Location can customize a campaign but nothing sends it back to brand for review. CampaignUser stores the copy but has no approval fields. The approval system (ContentApprovalAudit) exists for org-level campaigns but is disconnected from location customizations. |
| G4 | Status confusion: is_draft vs status | MEDIUM | is_draft (integer 0/1) AND status (enum draft/processing/active/paused/completed) both control lifecycle. No single source of truth. |
| G5 | enable_for_organization field half-built | LOW | Exists in model, no UI, unclear purpose vs is_draft. |

---

### FLOW 2: Purchase → Ad Ops → Platform Execution

| What | Status | Detail |
|------|--------|--------|
| Checkout UI | WORKS | CampaignCheckout.tsx, validates everything |
| Square card payment | WORKS | Real SDK, sandbox + production, not stubbed |
| Atomic transaction (payment gate) | WORKS | Cannot create AdOpsOrder without transaction_id |
| TransactionHistory + CampaignPurchase records | WORKS | Full tracking with fees |
| AdOpsOrder + channel tasks created | WORKS | Per-channel tasks auto-generated |
| Google Ads auto-execution | WORKS | Async, non-blocking, fallback tasks on failure |
| Meta Ads auto-execution | WORKS | Same pattern as Google |
| Credit payment (100%) | WORKS | Atomically deducts, creates CreditTransaction |
| Mixed payment (credits + card) | WORKS | Credit first, card for remainder |
| Fee calculation (tiered + agency markup) | WORKS | feeCalculationService.js, per-company |

**GAPS:**

| # | Gap | Severity | Detail |
|---|-----|----------|--------|
| G6 | Credit balance reservation not called during checkout | HIGH | reserveCredits() exists but purchaseCampaign() doesn't call it. Race condition if two purchases happen simultaneously with overlapping credit amounts. Row-level lock provides SOME safety but balance UI shows wrong "available" during processing. |
| G7 | MediaPlanReview not wired to purchase flow | HIGH | hurb-6 built the component but it's a standalone page. Not inserted as a step between campaign card → checkout. Location user can go straight to payment without reviewing the media plan. |
| G8 | No CSV/email delivery for external vendors | MEDIUM | Google and Meta have API execution. Everything else (DOOH, programmatic, print) creates tasks but has no automated delivery mechanism. Manual ad ops only. |
| G9 | No retry on failed API execution | MEDIUM | Google/Meta execution runs once. On failure, creates fallback task for manual intervention. No retry queue or exponential backoff. |
| G10 | verification_status stays 'pending' forever | MEDIUM | AdOpsOrder has verification_status but no webhook handler updates it when platforms confirm. |
| G11 | Refund not atomic for mixed payments | LOW | Card refund (Square) and credit refund (creditBalanceService) are separate operations. No single "cancel purchase" function. |

---

### FLOW 3: Analytics Attribution → Dashboard

| What | Status | Detail |
|------|--------|--------|
| Meta sync daily 6AM UTC | WORKS | Campaign + ad set + ad level, v22.0 API |
| Google sync daily 7AM UTC | WORKS | Campaign + ad group + keyword level, checkpoint resumable |
| Per-campaign analytics stored | WORKS | external_campaign_id links to CampaignOrganization |
| Role-based dashboard filtering | WORKS | Location users get scoped data via location_id filter |
| GA4 sync | PARTIAL | Syncs to separate tables, doesn't feed main dashboard |

**GAPS:**

| # | Gap | Severity | Detail |
|---|-----|----------|--------|
| G12 | Location attribution depends on ad set naming | HIGH | If ad sets aren't named "Location - Campaign", location-level analytics fails silently. No error, no warning, just missing data. Fragile naming convention, not explicit ID linking. |
| G13 | Location users see NULL location_id records | MEDIUM | Analytics filter includes [Op.or] with location_id=null. Location users see account-level aggregate data they shouldn't. Data leak. |
| G14 | TikTok/Snapchat/LinkedIn analytics not synced | MEDIUM | Connections exist, OAuth works, but no analytics sync jobs built. Data stays on platforms, never reaches ADBOX. |
| G15 | GA4 data siloed | MEDIUM | ga4_sessions and ga4_conversions tables exist but don't feed into analytics_daily_metrics. Separate world from main dashboard. |
| G16 | No retry on Meta sync failures | LOW | Google has withRetry() + exponential backoff. Meta just logs and exits on failure. |
| G17 | Campaign mapping relies on fuzzy name matching | LOW | analytics_campaign_mappings uses normalized names for matching. Stale mappings break. Should use explicit ID linking. |

---

## PRIORITY RANKING — What to fix first

### Must Fix for Ellianos (March 31)

| # | Gap | Why | Effort |
|---|-----|-----|--------|
| G3 | Customization → approval flow | Core Ellianos workflow: location customizes, brand reviews | 2-3 days |
| G2 | Campaign promo cards for locations | hurb-2 building now (E2) | In progress |
| G7 | MediaPlanReview wired to purchase flow | hurb-6 built component, needs integration into checkout route | 1 day |
| G1 | Explicit "Publish to Locations" action | Brand admin needs a clear way to make campaigns available | 1 day |
| G6 | Credit balance reservation | Ellianos uses credits, race condition is real | 0.5 day |

### Must Fix for MVP Beta (April)

| # | Gap | Why | Effort |
|---|-----|-----|--------|
| G12 | Location attribution → explicit ID linking | Beta clients need to see their campaign performance accurately | 2-3 days |
| G13 | Fix NULL location_id leak in analytics | Beta clients shouldn't see other people's data | 0.5 day |
| G4 | Single status source of truth | Confusing for any developer touching campaigns | 1 day |

### Fix for Nucleus (April-May)

| # | Gap | Why | Effort |
|---|-----|-----|--------|
| G3 | Customization → approval (same as Ellianos) | Nucleus candidates customize, agency reviews | Already built for Ellianos |

### Nice to Have (Post-Beta)

| # | Gap | Effort |
|---|-----|--------|
| G8 | CSV/email vendor delivery | 1-2 weeks |
| G9 | API execution retry queue | 2-3 days |
| G14 | TikTok/Snap/LinkedIn sync | 1 week each |
| G15 | GA4 integration into main dashboard | 2-3 days |
| G10 | Webhook verification status | 1-2 days |

---

## Files Referenced

**Campaign Creation:**
- backend/src/models/campaign_organization.js
- backend/src/api/controllers/campaigns/organization-campaign.js
- backend/src/api/controllers/campaigns/user-campaign.js
- backend/src/api/controllers/campaigns/content-approval.js
- frontend/src/components/campaigns/CampaignCard/CampaignCard.tsx
- frontend/src/components/campaigns/CampaignCreationModal/constants.ts

**Purchase Flow:**
- frontend/src/pages/campaignsNew/CampaignCheckout/CampaignCheckout.tsx
- backend/src/services/campaignPurchaseService.js
- backend/src/services/creditBalanceService.js
- backend/src/utils/square-client.js
- backend/src/models/ad_ops_order.js

**Analytics:**
- backend/src/services/meta/metaAnalyticsSyncJob.js
- backend/src/services/meta/metaAnalyticsService.js
- backend/src/services/google/googleAnalyticsSyncJob.js
- backend/src/services/google/googleAnalyticsService.js
- backend/src/services/analyticsImportService.js
- backend/src/api/controllers/analytics.js
