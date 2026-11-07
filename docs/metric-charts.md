# Metric Charts — Spec

Chart types, states, data rules, and color tokens for the HLTH health-tracking
metric charts. Pairs with the **HLTH Chart Guide Book (Board 10)** and the Figma
frames on page **"Chart Component Details"** of file `0ralXMN2vyjMRdePWh4Iks`.

Build the prototype against this document; the Figma frames are the visual
contract. **Dark mode only** for this pass. Default-state data uses realistic,
source-grounded values (persona: a 32-year-old trained recreational runner for
HR/HRV; clinically plausible values elsewhere).

Core principle (from the guide book): **a chart is chosen by the shape of the
data, not by the name of the metric.**

---

## 1. Plot library (what's built)

| Plot | Draws | Metrics |
|---|---|---|
| **Range bar** | one vertical bar per bucket, min→max | Heart rate (day), SpO₂ overnight |
| **Zone line** | continuous line, colored by HR zone | Heart rate (workout) |
| **Trend + baseline band** | line over a shaded personal-normal band | HRV, Respiratory rate |
| **Trend (zero-centred)** | line over a ±band around a zero line | Skin temperature |
| **Ring** | arc vs target/denominator, value in center | Readiness, Steps, Calories, Exercise, + all scores |
| **Dot** | unconnected points, optional threshold | SpO₂ spot check, Weight, Body fat |
| **Dumbbell** | two paired markers + connector per reading | Blood pressure |
| **Hypnogram** | stepped blocks across named stage lanes | Sleep |
| **Zone bar** | bars over a Low/Normal/High banded background | Stress |

Rules that never bend (guide book §7–8):
- Never connect points that were not continuously sampled (Dot ≠ line).
- A min–max range never collapses to a single line.
- Composition (sleep stages) is always stacked/laned, never a line.
- Ring only when a denominator/target exists.
- Hue carries metric identity; status (green/amber/red) is a layer on top.
- Stroke semantics: **solid** = continuously sampled · **dotted** = gap/inferred
  · **dots only** = discrete readings.

---

## 2. Colour tokens (Board-09 families, modernized)

One colour per metric, grouped by body system. Dark mode only.

```css
:root {
  /* surfaces */
  --chart-bg:#0B0E14; --chart-card:#151A23; --chart-plot:#1C2230; --chart-hairline:#262D3A;
  /* text */
  --chart-text-1:#F2F5F9; --chart-text-2:#8A94A6; --chart-text-3:#5A6475;

  /* Circulatory — pink → red */
  --hr:#FF5A72;          /* heart rate            */
  --hrv:#FF4D8D;         /* heart-rate variability */
  --bp:#E63950;          /* blood pressure        */

  /* Respiratory — cyan → teal */
  --spo2:#22D3EE;        /* blood oxygen          */
  --resp:#2DD4BF;        /* respiratory rate      */

  /* Recovery — indigo */
  --sleep:#7C6CFF;       /* sleep                 */
  --readiness:#8B7CFF;   /* readiness             */
  /* sleep stage tints (dark→light): Deep #5B4FD6 · Light #7C6CFF · REM #9B8DFF · Awake #C4BBFF */

  /* Load — orange → amber */
  --stress:#FF922B;      /* stress (identity)     */
  --temp:#FFB020;        /* skin temperature      */

  /* Effort — lime (brand) */
  --activity:#A3E635;    /* steps, calories, exercise */

  /* Body — neutral */
  --body:#9AA4B2;        /* weight, body fat      */

  /* Status layer (threshold lines, out-of-range marks, score bands) */
  --status-optimal:#34C77B; --status-elevated:#FFB020; --status-critical:#FF5A5A;

  /* Workout HR zones — cool→hot, do not remap */
  --zone-1:#3BC9DB; --zone-2:#51CF66; --zone-3:#FCC419; --zone-4:#FF922B; --zone-5:#FA5252;
}
```

Consistency rules: numbers use tabular figures; en-dash for numeric ranges
(`45–182`); a metric never changes its hue to signal concern (status is layered);
band/area fills use the metric hue at 8–16% opacity.

---

## 3. Metric → plot → colour map

| Metric | Group | Day / session plot | Colour | Notes |
|---|---|---|---|---|
| Heart rate | A | Range bar | `--hr` | resting baseline line; workout spike |
| Heart rate (workout) | C | Zone line | `--hr` id, zone ramp | zone key in header |
| HRV | F | Trend + baseline band | `--hrv` | dips below band flagged `--status-critical` |
| Blood pressure | E | Dumbbell | `--bp` | systolic/diastolic paired, never a range |
| SpO₂ overnight | A | Range bar | `--spo2` | axis clamp 88–100, min-90 threshold |
| SpO₂ spot check | E | Dot + threshold | `--spo2` | threshold at 95% |
| Respiratory rate | F | Trend + baseline band | `--resp` | axis window around baseline |
| Sleep | B | Hypnogram | `--sleep` tints | lanes Awake/REM/Light/Deep |
| Readiness | D | Ring | `--readiness` | 0–100 |
| Stress | C | Zone bar | `--stress` id; bands status | Low/Normal/High bands |
| Skin temperature | F | Trend, zero-centred | `--temp` | ±2 °C, zero line always visible |
| Steps | D | Ring | `--activity` | % of goal |
| Calories | D | Ring | `--activity` | active energy vs goal |
| Exercise time | D | Ring | `--activity` | minutes vs goal |
| Weight | E | Dot | `--body` | auto-window, min span 5 kg |
| Body fat | E | Dot | `--body` | auto-window, min span 5 % |
| **Daily Score** | D | Ring | status-colored arc | 0–100 composite |
| **Health Score** | D | Ring | status-colored arc | 0–100 composite |
| **Brand Metrics score** | D | Ring | status-colored arc | 0–100 composite (product-health index) |

Axis bounds per metric follow guide-book §10 (HR 30–220 clamp, SpO₂ 88–100 clamp,
skin temp −2…+2 zero-centred, HRV/weight/body-fat auto-window with a min span).

---

## 4. Scores (Daily / Health / Brand Metrics)

All three are **0–100 composite scores → Ring (Group D)**. The ring arc is
colored by status band: ≥75 `--status-optimal` (green), 60–74 `--status-elevated`
(amber), <60 `--status-critical` (red). The score sits in the ring center; a
one-line verdict sits below. "Brand Metrics score" is treated as a composite
product-health index (0–100) — confirm its exact inputs before build.

---

## 4b. Daily Goals (activity composite)

A composite summary of the three Effort metrics (Move / Exercise / Stand) read as
one set — **distinct** from the single Steps/Calories/Exercise rings (the
drill-down detail) and from the 0–100 Daily Score (a composite index). It does
not re-plot one metric, so it sits alongside "one metric, one plot" rather than
breaking it. Two shapes are kept:

- **Rings** — concentric 3-ring (Apple-style), legend + values beside. Compact;
  for tiles and smaller surfaces.
- **Gauge** — semicircle 3-arc (Huawei-style), 3-column legend below. The hero
  summary at the top of the Health screen.

Colour: the three arcs use a **lime sub-palette** — Move `#A3E635`, Exercise
`#76B900`, Stand `#D4F27E` — the one sanctioned exception to "activity = a single
lime", so three stacked arcs stay distinguishable; legend dots reinforce. (If
legibility without the legend ever matters more than brand purity, switch to a
distinct-hue trio: lime / amber / cyan.)

States: **Default** (arcs filled + legend) · **Empty** (track-only + "No activity
yet") · **Partial** (partial fills + "Watch syncing…") · **Under calculation**
(faint arcs + "Personalizing your goals · Day 3 of 7" — goals adapt over the
first 7 days).

---

## 5. States (every chart ships all four)

| State | Trigger | Visual rule |
|---|---|---|
| **Default** | Realistic data present | Full chart + primary stat + reference/baseline lines. |
| **Empty** | No data at all | Muted glyph + headline + one-line "how to populate". Stat `––`. Never invent data. |
| **Partial** | Gaps in measurement | Render what exists; **show the gap, never interpolate.** |
| **Under calculation** | First-run; a baseline/score/goal needs N days | Progress "Day/Night X of 7" + headline + sub; teaser data faint behind a scrim. |

Per-plot adaptation of Partial and Under-calculation:

- **Range bar** — Partial: omit missing buckets (faint dashed guides). Under-calc: faint bars + "learning your range".
- **Zone line** — Partial: break the line across a signal dropout ("no signal"). Under-calc: faint zoned line + "calibrating your zones".
- **Trend + band** — Partial: dotted connectors across missing nights. Under-calc: faint line + "baseline forming".
- **Ring** — Partial: ring at partial value + "based on partial data". Under-calc: faint ring + progress + "personalizing your goal"/"calculating your score".
- **Dot** — Partial: fewer than 3 points → "not enough readings" (never connect them). Under-calc: faint points + "trend forming".
- **Dumbbell** — Partial: a reading missing one half → single marker, no connector. Under-calc: faint dumbbells + "learning your baseline".
- **Hypnogram** — Partial: a "Not worn" dashed gap. Under-calc: faint hypnogram + "learning your sleep pattern".
- **Zone bar** — Partial: omit missing hours. Under-calc: faint bars + "calibrating your stress baseline".

**7-day convention:** first-run baselines/scores need **7 consecutive days**
(Whoop ~4 for a first score / ~30 full; Suunto 14/60d; Garmin ~3 weeks — 7 is a
defensible MVP threshold). Never show a fabricated score before the baseline
exists. The progress affordance fills captured days ("Day 3 of 7").

---

## 6. Implementation notes

- Dark only; tokens in §2 are the single source of truth.
- Card: 380×310, radius 20, surface `--chart-card`, 1px `rgba(255,255,255,.05)`
  stroke. Header = metric colour dot + name + range/context. Plot inset
  `--chart-plot`, radius 14.
- Uniform card height keeps the grid scannable; plot height varies by type
  (150 for bar/line/dot/dumbbell/hypnogram/zone-bar; ~212 for rings).
- Accessibility: never rely on colour alone — zone line is reinforced by the
  header key + y-axis; below-baseline HRV is red **and** below the band; stress
  bars sit in a labelled band background.

---

## 7. Figma frames

Page **"Chart Component Details"** (`0ralXMN2vyjMRdePWh4Iks`). 19 metric rows ×
4 state columns, dark cards. Grid: columns at x = **4186 / 4602 / 5018 / 5434**
(Default / Empty / Partial / Under calculation); rows stacked from y ≈ 4954 at a
363 px pitch; row labels at x = 4016.

Representative Default-state node IDs:
`HR range 546:376` · `HR zones 548:365` · `HRV 549:365` · `Blood pressure 567:377`
· `SpO₂ overnight 566:377` · `SpO₂ spot 564:377` · `Respiratory 565:377` ·
`Sleep 568:377` · `Readiness 562:377` · `Stress 569:377` · `Skin temp 565:500` ·
`Steps 562:441` · `Calories 562:503` · `Exercise 562:565` · `Weight 564:480` ·
`Body fat 564:583` · `Daily Score 563:377` · `Health Score 563:441` ·
`Brand Metrics 563:505`.

**Daily Goals composite** (two shapes × 4 states), below the grid at y ≈ 12000
(rings row) and y ≈ 12363 (gauge row): rings Default `577:377`, gauge Default
`577:490`.
