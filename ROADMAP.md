# ADBOX Roadmap

> **Last updated:** 2026-03-06 | **Updated by:** Claude Code (board session)
> **Source:** MVP Beta Launch Strategy v2.0 (Digital CTO Office, March 5 2026)

---

## Active Tracks (March 2026)

Three things happening simultaneously. Shared work is marked — most components serve multiple tracks.

---

## TRACK 1: CHS Hospital Demo (March 23, 2026)

**Goal:** Demonstrate hierarchical approval workflows to CHS (Community Health Systems).

**Build target:** March 14 (backend) | **Test window:** March 15-23

| Phase | Tasks | Status |
|-------|-------|--------|
| Phase 1 (parallel) | #1 DB migration, #10 Role models, #12 Demo data, #13 CHS templates, #8 National buying UI | #12 in progress, rest not started |
| Phase 2 (after #1, #10) | #2 Approval state machine, #11 Permissions upgrade | Not started |
| Phase 3 (after #2, #11) | #3 Approval queues, #4 Notifications, #5 Delegation/SLA, #7 Status tracker UI | Not started |
| Phase 4 (after #3) | #6 Approval queue UI | Not started |
| Phase 5 (after #1-6) | #14 E2E smoke test | Not started |

Full task details in BOARD.md.

---

## TRACK 2: Ellianos Onboarding (March 31, 2026)

**Goal:** Ellianos franchisees managing organic social content + purchasing campaigns with corporate matching funds.

### Platform Access Model

**Same UI, role-based visibility.** This pattern applies across ALL features:

| Level | What they see | What they can do |
|-------|--------------|-----------------|
| **Brand / Corporate** | Full platform | Create campaigns, Content Studio, 13-step wizard, analytics config, manage locations, allocate credits |
| **Location / Franchisee** | Curated view | See campaign cards published by brand, customize within guardrails, purchase with credits + payment, view analytics, manage organic social content |

**Key principle:** Location users don't get a separate UI. They get the same UI with creation features hidden (no "Create Campaign" button, no wizard). They see campaign cards that brand published for them with "Customize" and "Buy" actions.

### What Ellianos Needs

| Need | What Exists | Gap | Serves Track |
|------|------------|-----|-------------|
| Content Studio for organic social | 90% complete | Location users need access (currently admin-only visibility) | Ellianos + MVP Beta |
| Campaign cards for locations | Campaign Browser 85%, CampaignPackageConfig exists | **Campaign card component** — brand-published campaigns shown as purchasable cards to locations. Customize + Buy actions. | Ellianos + MVP Beta (= Campaign Promotional Card B2) |
| Simplified purchase flow | Campaign Checkout 85-90%, Square integration | **Media Plan Review** — read-only summary before purchase. Locations skip wizard, go card -> review -> pay. | Ellianos + MVP Beta (= B3) |
| Matching funds / credits | Credits system 70%, CreditTransaction model, hybrid payments | **Credit allocation from brand to location** — brand sets credit balance per location, auto-applies at checkout. V1: manual allocation, no automated matching policy. | Ellianos |
| Meta analytics on dashboard | Meta sync 80%, daily 6AM UTC | **Meta app approval** or test user workaround to connect Ellianos account | Ellianos |
| Multi-location management | Location Management 90% | Ready. Create Ellianos company + locations. | Ellianos |
| Role-based feature hiding | RBAC 85%, 16 roles, dashboard shells | **Role gate for location users** — hide create buttons, wizard, admin tools. Same component as Beta Role Gate (B1). | Ellianos + MVP Beta |

### Ellianos Work Breakdown

| # | Task | Effort | Shared With |
|---|------|--------|-------------|
| E1 | Role gate — hide creation features for location users | 2-3 days | MVP Beta (B1) |
| E2 | Campaign cards — purchasable cards published by brand | 2-3 days | MVP Beta (B2) |
| E3 | Media plan review — read-only before purchase | 2-3 days | MVP Beta (B3) |
| E4 | Credit allocation — brand allocates credits to locations, auto-apply at checkout | 2-3 days | Unique to Ellianos |
| E5 | Content Studio access for location users | 1 day | Ellianos |
| E6 | Meta account connection for Ellianos | 1 day | Ellianos (blocked by Meta approval) |
| E7 | Ellianos company + locations + users setup | 1 day | Ellianos |

**E1, E2, E3 are shared with MVP Beta.** Building them for Ellianos = building them for Beta launch. Three birds, one stone.

### Meta Approval Blocker

Options:
1. **Submit for Meta app review now** — proper path, takes 1-5 business days
2. **Add Ellianos as test user** — immediate but fragile, limited to 2000 API calls/hour
3. **Use Ellianos's own Meta Business token** — if they have developer access

**Recommendation:** Submit for review immediately AND add as test user as fallback. Swap to production token once approved.

---

## TRACK 3: MVP Beta Launch (April-May 2026)

**Goal:** Launch ADBOX to first paying Beta clients. Platform is 78% complete overall.

**Strategy:** Hide unfinished features behind role gates. Beta clients see a polished, limited experience. Admins get full access. Don't build what's not needed.

### User Tiers

| Tier | Roles | Experience |
|------|-------|------------|
| **Beta (Client)** | BETA_CLIENT (17) or BRAND_ADMIN (2) | Browse campaigns, review media plan, purchase, view analytics, Eve Q&A only |
| **Alpha (Admin)** | SUPER_ADMIN (1), PLATFORM_ADMIN (13), AD_OPS_DIRECTOR (7), ACCOUNT_EXEC (9), ACCOUNT_DIR (12) | Full access: create campaigns, Content Studio, Eve tools, connect platforms |
| **Super Admin** | SUPER_ADMIN (1), PLATFORM_ADMIN (13) | Everything + company mgmt, fees, dev tools, feature flags |

### Critical Gaps (Must Build)

| # | Component | Current | Effort | Shared With | Description |
|---|-----------|---------|--------|-------------|-------------|
| B1 | Role Gate | 0% | 2-3 days | Ellianos (E1) | BETA_CLIENT role + `<RoleGate>` component, sidebar/route hiding |
| B2 | Campaign Card | 10% | 2-3 days | Ellianos (E2) | Purchasable campaign view for clients/locations |
| B3 | Media Plan Review | 10% | 2-3 days | Ellianos (E3) | Read-only plan summary before purchase |
| B4 | Eve Beta Q&A Filter | 0% | 2-3 days | — | BETA_TOOLS array in intentRouting.js |
| B5 | Surfing the Black Wave KB | 20% | 1-2 days | — | STBW content as Eve knowledge source |

**B1, B2, B3 are built during Ellianos onboarding.** Only B4 + B5 remain for Beta launch.

### MVP Ready (Already Working)

| Component | Completion | Beta Access | Notes |
|-----------|-----------|-------------|-------|
| Auth & RBAC | 88% | Login + profile | 16 roles, JWT, MFA, invites |
| Content Studio | 90% | Hidden (or location-level for franchisees) | 130+ endpoints, IMG.ly editor |
| Campaign Browser | 85% | View only | List + calendar + search |
| Campaign Checkout | 85-90% | Purchase flow | Square, atomic transactions |
| Analytics Dashboard | 75% | Read-only | Nivo charts, Meta sync daily |
| Eve AI (Admin tools) | 75% | Q&A only | 199 modules, 83 tools |
| Payments & Billing | 88% | Add/view cards | Square, fees, refunds |
| Dashboard | 85% | User shell | 5 role-based shells |
| Ad Operations | 80% | Hidden | Orders, channels, tasks |

### MVP Launch Phases

**Phase 1: Beta Infrastructure (built during Ellianos track)**
- [x] Role Gate (= E1)
- [x] Campaign Card (= E2)
- [x] Media Plan Review (= E3)
- [ ] Eve Beta Q&A Filter (B4)
- [ ] Surfing the Black Wave integration (B5)

**Phase 2: Polish & Testing (5-7 business days, April)**
- [ ] End-to-end payment flow testing (Square sandbox)
- [ ] Analytics read-only mode for Beta
- [ ] Google Ads sync reliability testing
- [ ] Meta sync verification
- [ ] Admin Client Setup workflow
- [ ] Full QA: login -> campaign -> media plan -> purchase -> analytics

**Phase 3: Soft Launch (3-5 business days)**
- [ ] Invite 2-3 Beta clients
- [ ] Monitor: payments, analytics accuracy, Eve Q&A quality
- [ ] Fix critical bugs
- [ ] Gather feedback

**Phase 4: Beta Launch (May)**
- [ ] Open to all initial Beta clients
- [ ] Feature flags per client as needed
- [ ] Iterate on feedback

### Do NOT Build for MVP

Training Hub (5%), CRM (25%), Calendar (20%), Email Marketing (60%), Video Generation (30%), White Labeling (20%), Collaborative Editing

---

## March Timeline

| Week | CHS Demo | Ellianos | MVP Beta |
|------|----------|----------|----------|
| **Mar 7-14** | Phase 1+2: DB migration, role models, approval state machine, permissions | E7: Company + locations setup. E6: Submit Meta app review | — |
| **Mar 14-21** | Phase 3+4: Approval queues, notifications, delegation, UI | E1+E2+E3: Role gate, campaign cards, media plan review (= B1+B2+B3) | Shared work with Ellianos |
| **Mar 21-23** | Phase 5: E2E smoke test, demo prep | E4: Credit allocation. E5: Content Studio location access | — |
| **Mar 24-31** | Demo day (Mar 23), fixes | E6: Meta connection live. QA + onboard franchisees | B4+B5: Eve Q&A filter, STBW knowledge |
| **Apr 1-11** | — | Live, iterate | Phase 2: Polish + testing |
| **Apr 14-18** | — | — | Phase 3: Soft launch (2-3 clients) |
| **May 1** | — | — | Phase 4: Beta launch |

---

## LATER: Post-MVP

### Monster Live Telemetry (MONSTER_NEXT_LAYER.md)

| Phase | What | Status |
|-------|------|--------|
| 1 | Heartbeat agent (worktree/port/Claude detection) | Not started |
| 2 | Live session tracking (DevSession model) | Not started |
| 3 | Test & build telemetry | Not started |
| 4 | PM Claude (automated project management) | Not started |
| 5 | Real-time WebSocket dashboard | Not started |

### MVP Tracker Tab (DevTracker)

Real-time component completion tracking inside DevTracker. See BOARD.md task #15.

### Platform Expansion

- Snapchat/TikTok/LinkedIn analytics (currently 25-70%)
- Audiences & Journeys builder
- Social Media Management (multi-platform)
- White Labeling
- Video Generation

---

## Reference

- Full component matrix: `screenshots/MVP_BETA_COMPONENT_MATRIX.csv`
- Full MVP strategy doc: `screenshots/MVP_BETA_LAUNCH_RECOMMENDATIONS.md`
- Monster build plan: `MONSTER_NEXT_LAYER.md`
- CHS approval design: BOARD.md (Design Decisions B1)
