# Nucleus Integration — Context for Ops

> **Last updated:** 2026-03-06 | **Contact:** Jonahs Duran (j.duran@nucl.co)

---

## What is Nucleus?

Campaign Nucleus is a political campaign management platform (email, SMS, fundraising, ground ops). They want to add multi-channel marketing (social ads, display, print, video) by integrating ADBOX.

## What's the deal?

- **Crawl phase (SSO integration):** $28,500 fixed price
  - 40% signing ($11,400) → 40% mid-project ($11,400) → 20% go-live ($5,700)
- **Ongoing support:** $2,500-$10,000/month depending on tier
- **Future phases:** Walk ($45-65K), Run ($75-125K)
- **MSA:** In `legal/adbox/`

## Where things stand

- Nucleus has their OAuth/OIDC ready (since Feb 13)
- Ball is in our court — we owe them:
  1. ADBOX logo for their App Store listing
  2. App Store description copy
  3. Integration timeline
- They've been emailing asking about status

## How it works in ADBOX

- **Nucleus** = Organization (parent entity)
- **Each political candidate** = their own Brand/Company under the org
- **Candidate staff/agencies** = Brand Admins with full campaign creation access
- Candidates SSO from Nucleus into their ADBOX brand
- They create campaigns, use Content Studio, Eve AI — full self-service
- Blackwave offers in-house campaign creation services as upsell
- Each candidate is fully isolated (can't see other candidates' data/templates)

## Realistic timeline

| Phase | When | What |
|---|---|---|
| Template isolation fix | Apr 1-7 | Business account data isolation (5-7 days) |
| SSO integration | Apr 7-14 | OAuth/OIDC using existing Vendasta pattern (3-5 days) |
| UX polish | Apr 14-18 | "Return to Nucleus" nav, branding (2-3 days) |
| Testing | Apr 21-25 | E2E testing, political compliance review |
| Go-live | ~Apr 28 | Crawl phase launch |

**Why April:** March is fully committed to CHS Hospital Demo (Mar 23) and Ellianos onboarding (Mar 31). Nucleus work starts April 1.

## Draft response to Jonahs

> Hey Jonahs,
>
> Thanks for following up. Here's where we're at:
>
> We're wrapping up two major deliverables this month (enterprise demo March 23, client onboarding March 31) that are building shared infrastructure Nucleus will benefit from — specifically role-based access, campaign cards, and the simplified purchase flow.
>
> Nucleus integration starts April 1. Our plan:
> - **Apr 1-7:** Template/data isolation (ensuring candidate accounts are fully siloed)
> - **Apr 7-14:** SSO/OIDC integration with your auth system
> - **Apr 14-25:** UX polish, testing, compliance review
> - **~Apr 28:** Crawl phase go-live target
>
> We still owe you the ADBOX logo and App Store description — I'll get those to you this week.
>
> Let me know if you want to sync on any of this.

---

## Reference docs

All in `adbox/testing/docs/integrations/nucleus/`:
- `account-structure-revised.md` — org/brand model
- `gap-analysis.md` — what needs building
- `billing-proposal.md` — pricing breakdown
- `user-flow-diagram.md` — SSO flow
- `critical-privacy-fix-required.md` — template isolation issue
- `pricing-summary.md` — revenue projections
