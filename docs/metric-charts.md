# Metric Charts — Spec

Chart types, states, data rules, and color tokens for the health-tracking metric
charts. Pairs with the Figma frames in **Rough-Kishan → page "Chart Component
Details" → section "Metric Charts · States · Modern (dark)"**. Build the
prototype against this document; the Figma frames are the visual contract.

Scope of this pass: **Heart Rate** (two charts) and **HRV** (one chart), **dark
mode only**. Persona for all sample data: a 32-year-old well-trained recreational
runner (see [Reference data](#reference-data)).

---

## 1. Chart types — one system, mapped by context

The two heart-rate charts are **not alternatives**; they answer different
questions and both ship. Pick the chart by the surface's context, not by the
metric name.

| Chart | Question it answers | Use for | Sampling needed |
|---|---|---|---|
| **Range bar** (min–max per bucket) | "What was my range over this day / week / month?" | Resting/ambient HR overview, long-horizon trends | sparse is fine |
| **Zone line** (continuous, colored by HR zone) | "How did my heart behave during *this one effort*?" | A single workout / run / live session | dense (~1 Hz) |
| **Baseline band** (daily value + personal normal band) | "Is today above or below my normal?" | HRV, recovery/readiness scores | 1 value/day |

### Chart-per-metric (extend the kit with these primitives)

| Primitive | Metrics |
|---|---|
| Range bars | Resting HR overview, SpO₂, Respiratory rate, Skin-temp range |
| Zone line | Workout HR, Live HR, Running pace |
| Baseline band (+ dips) | **HRV**, VO₂max trend, Recovery, Readiness |
| Plain column (daily total) | Steps, Active minutes, Calories, Sleep duration |
| Stacked segment (hypnogram) | Sleep stages, Zone time |
| Line + target band | Glucose/CGM, Weight, Blood pressure |

**Do not reuse an HR chart for HRV.** HRV is not sampled all day (no "range per
hour") and has no universal zones, so neither the range-bar nor the zone-line
fits. HRV uses the baseline-band pattern.

---

## 2. Color tokens (standardized across all three charts)

Dark-mode only. Modern, non-Apple palette. Heart-rate keeps a warm/coral identity
for instant recognition; HRV is a distinct violet; workout zones keep the
standard cool→hot cognitive mapping.

```css
:root {
  /* surfaces */
  --chart-bg:        #0B0E14; /* app background            */
  --chart-card:      #151A23; /* metric card               */
  --chart-plot:      #1C2230; /* inset plot area           */
  --chart-hairline:  #262D3A; /* gridlines, 1px strokes    */

  /* text */
  --chart-text-1:    #F2F5F9; /* primary / numbers         */
  --chart-text-2:    #8A94A6; /* secondary                 */
  --chart-text-3:    #5A6475; /* axis labels, tertiary     */

  /* Heart Rate identity (range bars + resting) */
  --hr:              #FF5A72;

  /* HRV identity + states */
  --hrv:             #8B7CFF;
  --hrv-band:        rgba(139,124,255,0.14); /* baseline band fill */
  --below-baseline:  #FF6B6B; /* HRV value under normal band       */
  --good:            #51CF66; /* positive delta vs baseline        */

  /* Workout HR zones — cool→hot, do not remap */
  --zone-1: #3BC9DB; /* recovery   */
  --zone-2: #51CF66; /* endurance  */
  --zone-3: #FCC419; /* tempo      */
  --zone-4: #FF922B; /* threshold  */
  --zone-5: #FA5252; /* max        */
}
```

Rules that keep the charts consistent:

- **HR is always `--hr`** on range-bar and resting surfaces; never reuse a zone
  color for ambient HR.
- **Zone colors are reserved for workout zones.** Do not use `--zone-5` red for a
  generic HR value (it reads as "max effort").
- **HRV is always `--hrv` violet**; below-band points flip to `--below-baseline`.
- Numbers use **tabular figures**. Use en-dash for numeric ranges (`45–182`),
  never a hyphen or em-dash.
- Contrast: body/label text ≥ 4.5:1, large numbers ≥ 3:1 against the card.

---

## 3. HR zone model

Five zones by `%HRmax`. Sample persona `HRmax ≈ 188` (220 − age; a field test is
more accurate and should override per-user).

| Zone | Name | % HRmax | BPM @ 188 | Color |
|---|---|---|---|---|
| Z1 | Recovery  | 50–60% | 94–113  | `--zone-1` |
| Z2 | Endurance | 60–70% | 113–132 | `--zone-2` |
| Z3 | Tempo     | 70–80% | 132–150 | `--zone-3` |
| Z4 | Threshold | 80–90% | 150–169 | `--zone-4` |
| Z5 | Max       | 90–100%| 169–188 | `--zone-5` |

The zone line is colored per segment by the zone of each sample; a small
5-swatch key in the card header teaches the mapping.

---

## 4. HRV baseline band

- Plot **one value per day** (morning RMSSD, ms).
- Shade a **personal baseline band** behind the line: sample `61–83 ms`
  (baseline midpoint `71`, ≈ ±1 SD). In production this is a rolling 30–60 day
  personal range, **not** an age-population chart.
- Dashed **baseline midline** at the band midpoint, labeled.
- Points **below the band** are flagged `--below-baseline` (strain / low
  recovery); points inside/above stay `--hrv`.
- The latest point is emphasized with a larger dot + value callout.

---

## 5. States (every chart ships all four)

| State | Trigger | Visual rule |
|---|---|---|
| **Default** | Realistic data present | Full chart, primary stat, baseline/reference lines. |
| **Empty** | No data at all | Muted metric glyph + headline + one-line "how to populate". Stat shows `––`. No invented data. |
| **Partial** | Gaps in measurement | Render what exists; **show the gap, never interpolate across it.** |
| **Under calculation** | First-run; a baseline/score needs N days | Progress affordance "Day X of 7" + headline + sub; teaser data faint behind a scrim. |

### Partial-data rules (do not bridge gaps)

- **Range bar:** omit the missing buckets (leave empty slots / faint dashed
  guides). Sample gap: 2–5 PM.
- **Zone line:** break the line across the dropout; show a dashed "no signal"
  stub, do not connect across it. Sample gap: ~1.5 min optical dropout.
- **HRV:** draw a dotted connector between known points for missing days; keep
  real points solid. Sample gap: 3 missing nights.

### Under-calculation ("7-day baseline")

Use a **7 consecutive days** threshold for first-run baseline/score states.
(Industry reference: Whoop ~4 days for a first score and ~30 for a full
baseline; Suunto 14 measurements / 60 days; Garmin ~3 weeks. 7 is a defensible
MVP threshold.) **Never show a fabricated score before the baseline exists.**

Progress affordance: a 7-segment indicator with the captured days filled
("Day 3 of 7") gives first-run users a sense of momentum.

### Microcopy (used in the frames)

| Chart | Empty | Under calculation (headline / sub) |
|---|---|---|
| HR range | "No heart-rate data" / "Wear your watch to see your daily range." | "Building your resting baseline" / "Keep wearing your watch. We compare against your personal normal." |
| HR zones | "No workout recorded" / "Start a workout to see your heart-rate zones." | "Calibrating your zones" / "We personalize your HR zones from your first 7 days of workouts." |
| HRV | "No HRV data" / "HRV is measured while you sleep. Wear your band overnight." | "Calculating your baseline" / "We need 7 nights of data to show your HRV score. Keep your band on overnight." |

All under-calculation states carry the footer: **"Day 3 of 7"** (dynamic).

---

## 6. Reference data

Sample data for a 32yo trained runner, grounded in published ranges
(DC Rainmaker, Whoop, Oura, Fleet Feet, peer-reviewed resting-HR/HRV norms).

- **Resting HR:** 49 BPM (overnight low ~45–47)
- **Max HR:** ~188 BPM
- **HRV (RMSSD):** baseline ~71 ms, normal band 61–83 ms, ±10–15 ms daily swings

**HR range-bar (24 hourly `[low, high]`):** day range **45–182 BPM**, workout
spike at the 6 PM bucket.

```
[49,58],[47,55],[46,54],[45,53],[46,55],[48,60],[52,68],[58,82],[60,88],
[62,79],[60,76],[61,84],[64,95],[66,92],[63,80],[62,78],[60,77],[64,90],
[72,182],[68,120],[60,78],[56,72],[52,66],[50,60]
```

**HRV (14-day morning RMSSD, ms):** baseline 71; dips below band on day 6 and
day 12.

```
72,75,68,78,71,58,63,74,80,76,69,55,66,79
```

The zone-line uses a 45-minute tempo run sampled every ~30 s (warmup 108→150,
tempo block 165–178 with surges to 184, cooldown to ~116); avg ~158, peak 184.
The full 90-point series is encoded in the Figma frame.

---

## 7. Implementation notes

- **Dark only** for this pass; design tokens above are the single source of truth.
- Uniform plot height across all cards keeps the grid scannable.
- Don't stand charts in for content with decoration — these charts *are* the
  content; render real data, real axes, real states.
- Keep numerals tabular and right-weighted; theme axis text from `--chart-text-3`.
- Accessibility: never rely on color alone — zone line is reinforced by the
  header key and y-axis; below-baseline HRV points are both red **and** below
  the shaded band.

---

## 8. Figma frames

Page **"Chart Component Details"**, section **"Metric Charts · States · Modern
(dark)"**, laid out as a 3×4 grid (rows = charts, columns = states):

| Row | Default | Empty | Partial | Under calc |
|---|---|---|---|---|
| HR range bars | `546:376` | `546:435` | `546:460` | `546:517` |
| HR workout zones | `548:365` | `548:408` | `548:428` | `548:470` |
| HRV baseline band | `549:365` | `549:406` | `549:422` | `549:461` |
