# Scoring Model

How an athlete's assessment scores roll up into an `overall_score`, get labeled with a `level_band` + `sub_level` (stripe) for display, and where the current data model has open product questions.

## Data flow at a glance

```
  formal assessments  (per-skill scores authored by coaches)
          │
          ▼
  weighted_skill_averages(athlete_id, level_id)   ← per-skill weighted mean
          │
          ▼
  assessment_summaries.overall_score              ← avg of per-skill averages
          │
          ▼
  derive_band_stripe(overall_score, sport_id)     ← read-time band+stripe
          │
          ▼
  UI: AppLevelCoin(band, sub_level)               ← "Silver II" etc.
```

Nothing is stored past `overall_score` — the band label is derived on read, so a thresholds change is immediately reflected everywhere on the next query.

## Key tables + functions

**`assessments`** — raw per-assessment row. `assessment_type` is `'formal'` or `'quick'`. Only `'formal'` counts toward scoring; quick feedback is qualitative and excluded from summary math.

**`assessment_scores`** — per-skill scores within an assessment. Composite (assessment_id, skill_id) is the natural key.

**`weighted_skill_averages(athlete_id, level_classification_id)`** — Postgres function. For a given athlete + level, returns per-skill weighted averages across all their submitted formal assessments at that level. Weighting factors in the coach's `weighted_role` (head coach vs skills coach vs offseason coach, etc.).

**`assessment_summaries`** — one row per `(athlete, level_classification)`. Rolling aggregate — every new formal assessment triggers `recompute_assessment_summary(athlete_id, level_id)` which recalculates `overall_score`, `per_skill_averages`, and `assessment_count`. History across levels is preserved as multiple rows (one per level the athlete has been assessed at).

**`level_band_thresholds`** — one row per `(band, sport_id)`. Defines each band's `[min_score, max_score]` numeric range plus `sub_level_count` (how many stripes the band divides into). Hockey today:
- Beginner: 0 – 4, 1 stripe
- Bronze: 4 – 6, 3 stripes
- Silver: 6 – 7.5, 3 stripes
- Gold: 7.5 – 9, 3 stripes
- Elite: 9 – 10, 3 stripes

**`derive_band_stripe(overall_score numeric, sport_id uuid)`** — Postgres helper that returns the matching `(band, sub_level)` for a given score. Divides each band's range into `sub_level_count` equal zones. STABLE + SECURITY DEFINER. Returns zero rows when `overall_score` is NULL (unassessed) — callers use `LEFT JOIN LATERAL` so the outer row is preserved.

## Sub-level (stripe) derivation

For each band with `sub_level_count = N`, divide `[min_score, max_score]` into N equal zones:

```
sub_level = LEAST(
  CEIL(((overall_score - band.min_score) / (band.max_score - band.min_score)) * N)::int,
  N
)
```

The `LEAST` clamp handles boundary cases (a score exactly at `max_score` would compute `N+1` without it).

Concrete hockey zones:
- Beginner (0-4, N=1): all scores → sub_level 1
- Bronze (4-6, N=3): 4.00-4.67 = I, 4.67-5.33 = II, 5.33-6.00 = III
- Silver (6-7.5, N=3): 6.00-6.50 = I, 6.50-7.00 = II, 7.00-7.50 = III
- Gold (7.5-9, N=3): 7.50-8.00 = I, 8.00-8.50 = II, 8.50-9.00 = III
- Elite (9-10, N=3): 9.00-9.33 = I, 9.33-9.67 = II, 9.67-10.00 = III

## Per-level grouping semantic

`assessment_summaries` groups by `(athlete, level_classification)` — not by team, and not one row per assessment. That means:

- If an athlete plays on **3 different AAA teams** in their career, all AAA formal assessments (across all 3 teams) roll into ONE AAA summary row. Coach A on Team 1 and Coach B on Team 2 both see the same AAA `overall_score` for the athlete.
- If the athlete also played at AA, that's a **separate** summary row. My Feedback surfaces this as distinct "chapters" per level.
- Team traceability lives on the raw `assessments` table (`team_id`, `coach_id`, `submitted_at`, `weighted_role`). Anyone wanting team-scoped analysis drills into raw data.
- **Rebuildable**: summaries are a projection. Delete + re-run `recompute_assessment_summary` for all `(athlete, level)` pairs and they regenerate from raw assessments.

**Design tradeoff:** per-level captures level-relative skill (a 7.0 at U10 A means something different from a 7.0 at U13 AAA). All-time-average would lose that context. See Open Questions below.

## Multi-sport readiness

- `level_band_thresholds.sport_id` — bands + ranges are per-sport. Adding a new sport = new threshold rows, no code change.
- `derive_band_stripe` takes `sport_id` as an argument — data-driven, no hardcoded values.
- Mobile-side `AppScoreBar`'s band gradient IS currently hardcoded to hockey stops (see the widget's FIXME + [[chore-app-score-bar-band-gradient-sport-dynamic]] follow-up). When we add sport #2, that gradient needs to become dynamic (accept a list of stops per sport, or read from a `get-sport-config` endpoint).

## Endpoint conventions

Any endpoint that surfaces an athlete's ranking (`get-team-roster`, future `get-athlete-detail-for-coach`, future athlete-side ranking display, coach dashboards) should call `derive_band_stripe` via `LEFT JOIN LATERAL` and return the band + sub_level as structured fields. Do not hardcode band ranges in edge functions or client code — always resolve via the helper so a thresholds change propagates automatically.

## Open questions (client confirmation needed)

These are product calls we haven't fully validated with the client. Assumptions listed reflect what we're building on; flag if wrong.

1. **Ranking scope: per-level vs all-time?** Current design is per-level (coach on U13 AAA team sees each roster player's U13 AAA ranking; players who've never played AAA show unranked). Client's initial phrasing leaned "overall across all formal assessments" but scale-mixing across levels makes that harder to interpret. Real hockey dev models (USA Hockey, Hockey Canada) use per-level, so we're going with that until told otherwise.

2. **Time-decay weighting.** Currently a 2-year-old AAA assessment weighs equally with a fresh one. Fine forever, or should recent assessments count more?

3. **Ranking visibility scope.** Is the coach-facing roster ranking the same number the athlete sees on their own passport/DVLP page? Or is one internal (coach view) and one public-ish (athlete view)? Affects whether we might diverge derivations later.

4. **Cross-team blending inside a level.** A AAA athlete who played on 3 teams has one AAA summary blending all assessments. If a coach wants "just my team's assessments of this player," that's a team-scoped view we don't have today (raw data supports it; no rolled-up projection).

5. **Minimum assessment count threshold before showing a band.** Should a player with only 1 formal assessment show a Silver II badge on the roster, or "-" until they have N assessments? Guards against misleading confidence in tiny sample sizes.

## Related follow-ups

- **`chore/codegen-shared-schemas`** ([[Path A]]) — canonicalize duplicated types across endpoints (e.g., `Position` in get-team-roster vs get-profile). Removes the need for mappers between mutation returns and cached list types.
- **`Make AppScoreBar band gradient sport-dynamic`** (task #70) — mobile-side counterpart to backend's multi-sport readiness.
