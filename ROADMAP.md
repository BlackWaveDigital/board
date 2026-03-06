# ADBOX Roadmap

> **Last updated:** 2026-03-06 | **Updated by:** Claude Code (board session)
> **Source:** MVP Beta Launch Strategy v2.0 (Digital CTO Office, March 5 2026)

---

## NOW: CHS Hospital Demo (March 23, 2026)

**Goal:** Demonstrate hierarchical approval workflows to CHS (Community Health Systems).

**Build target:** March 7 | **Test window:** March 8-23

| Phase | Tasks | Status |
|-------|-------|--------|
| Phase 1 (parallel) | #1 DB migration, #10 Role models, #12 Demo data, #13 CHS templates, #8 National buying UI | #12 in progress, rest not started |
| Phase 2 (after #1, #10) | #2 Approval state machine, #11 Permissions upgrade | Not started |
| Phase 3 (after #2, #11) | #3 Approval queues, #4 Notifications, #5 Delegation/SLA, #7 Status tracker UI | Not started |
| Phase 4 (after #3) | #6 Approval queue UI | Not started |
| Phase 5 (after #1-6) | #14 E2E smoke test | Not started |

Full task details in BOARD.md.

---

## NEXT: MVP Beta Launch (Target: April-May 2026)

**Goal:** Launch ADBOX to first paying Beta clients. Platform is 78% complete overall.

**Strategy:** Hide unfinished features behind role gates. Beta clients see a polished, limited experience. Admins get full access. Don't build what's not needed.

### User Tiers

| Tier | Roles | Experience |
|------|-------|------------|
| **Beta (Client)** | BETA_CLIENT (17) or BRAND_ADMIN (2) | Browse campaigns, review media plan, purchase, view analytics, Eve Q&A only |
| **Alpha (Admin)** | SUPER_ADMIN (1), PLATFORM_ADMIN (13), AD_OPS_DIRECTOR (7), ACCOUNT_EXEC (9), ACCOUNT_DIR (12) | Full access: create campaigns, Content Studio, Eve tools, connect platforms |
| **Super Admin** | SUPER_ADMIN (1), PLATFORM_ADMIN (13) | Everything + company mgmt, fees, dev tools, feature flags |

### Critical Gaps (Must Build)

| # | Component | Current | Effort | Description |
|---|-----------|---------|--------|-------------|
| B1 | Beta Role Gate | 0% | 2-3 days | BETA_CLIENT role + `<RoleGate>` component, sidebar/route hiding |
| B2 | Campaign Promotional Card | 10% | 2-3 days | Simplified campaign view + purchase CTA for Beta users |
| B3 | Media Plan Review UI | 10% | 2-3 days | Read-only plan summary (channels, budget, dates) before purchase |
| B4 | Eve Beta Q&A Filter | 0% | 2-3 days | BETA_TOOLS array in intentRouting.js, restrict to ~5 tools |
| B5 | Surfing the Black Wave KB | 20% | 1-2 days | Integrate STBW content as Eve knowledge source |

**Total critical gap effort: 9-14 days**

### MVP Ready (Already Working)

| Component | Completion | Beta Access | Notes |
|-----------|-----------|-------------|-------|
| Auth & RBAC | 88% | Login + profile | 16 roles, JWT, MFA, invites |
| Content Studio | 90% | Hidden | 130+ endpoints, IMG.ly editor |
| Campaign Browser | 85% | View only | List + calendar + search |
| Campaign Checkout | 85-90% | Purchase flow | Square, atomic transactions |
| Analytics Dashboard | 75% | Read-only | Nivo charts, Meta sync daily |
| Eve AI (Admin tools) | 75% | Q&A only | 199 modules, 83 tools |
| Payments & Billing | 88% | Add/view cards | Square, fees, refunds |
| Dashboard | 85% | User shell | 5 role-based shells |
| Ad Operations | 80% | Hidden | Orders, channels, tasks |

### MVP Launch Phases

**Phase 1: Beta Infrastructure (5-7 business days)**
- [ ] Add BETA_CLIENT role to rbacService.js
- [ ] Build `<RoleGate>` component + wrap sidebar/routes
- [ ] Build Campaign Promotional Card
- [ ] Build Media Plan Review (read-only)
- [ ] Create BETA_TOOLS array in Eve intentRouting.js
- [ ] Integrate Surfing the Black Wave as Eve knowledge file

**Phase 2: Polish & Testing (5-7 business days)**
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

**Phase 4: Beta Launch**
- [ ] Open to all initial Beta clients
- [ ] Feature flags per client as needed
- [ ] Iterate on feedback

### Non-Negotiable Before Any Beta User

1. End-to-end Square payment testing (sandbox)
2. Beta Role Gate live — no admin features visible to clients
3. Meta analytics sync verified running
4. Eve restricted to Q&A mode for Beta role

### Do NOT Build for MVP

Training Hub (5%), CRM (25%), Calendar (20%), Email Marketing (60%), Video Generation (30%), White Labeling (20%), Collaborative Editing

---

## LATER: Post-MVP

### Ellianos (Franchisee Buying Experience)

> Franchisees need a "Dominos app" experience — frictionless campaign buying.

**What exists:** CampaignPackageConfig, campaignChannelPopulator, MLU multi-location drafts, template_variables. Backend infrastructure largely built.

**What's missing:** Simplified "storefront" fast-path for the 13-step campaign wizard. Needs hands-on UX review of current location user experience.

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
- Location Management for multi-location clients
- Audiences & Journeys builder
- Social Media Management (multi-platform)

---

## Reference

- Full component matrix: `screenshots/MVP_BETA_COMPONENT_MATRIX.csv`
- Full MVP strategy doc: `screenshots/MVP_BETA_LAUNCH_RECOMMENDATIONS.md`
- Monster build plan: `MONSTER_NEXT_LAYER.md`
- CHS approval design: BOARD.md (Design Decisions B1)
