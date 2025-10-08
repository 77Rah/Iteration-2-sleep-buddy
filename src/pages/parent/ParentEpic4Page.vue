<template>
  <div class="container py-4 parent-epi4">
    <!-- Header -->
    <div class="d-flex align-items-center justify-content-between mb-3">
      <router-link class="btn btn-outline-primary rounded-pill px-3" :to="{ name: 'parent' }"
        >Back to Parent Home</router-link
      >
      <center>
      <div class="d-flex align-items-center gap-3">
        <span class="logo-pill">🧒🌙</span>
        <div>
          <h1 class="h3 fw-bold mb-1">Parent Dashboard</h1>
          <p class="text-muted mb-0 small">
            Benchmarked to
            <a
              class="link-dark fw-semibold"
              href="https://www.health.gov.au/topics/physical-activity-and-exercise/physical-activity-and-exercise-guidelines-for-all-australians"
              target="_blank"
              rel="noopener"
              >Australian Guidelines</a
            >
          </p>
        </div>
      </div></center>
    </div>

    <!-- Tips -->
    <div class="row g-3 mb-3">
      <div class="col-12">
        <div class="tips card border-0 shadow-sm rounded-4 p-3">
          <div class="d-flex gap-3 flex-wrap">
            <span class="tip-chip"><i>🍎</i> Aim closer to ADG serves/day</span>
            <span class="tip-chip"><i>🏃</i> 60+ mins/day movement (5–17 yrs)</span>
            <span class="tip-chip"><i>📵</i> Keep last hour pre-bed screen-light</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Unified AGE filter cards -->
    <div class="row g-3 mb-4">
      <div v-for="card in ageCards" :key="card.key" class="col-6 col-md-3">
        <button
          class="age-card w-100 rounded-4 shadow-sm"
          :class="{ active: filters.ageUnified === card.key }"
          @click="filters.ageUnified = card.key"
        >
          <div class="age-emoji">{{ card.emoji }}</div>
          <div class="age-label">{{ card.title }}</div>
          <div class="age-sub">Ages {{ card.key }}</div>
        </button>
      </div>
    </div>

    <!-- Main grid -->
    <div class="row g-4">
      <!-- Nutrition -->
      <div class="col-lg-7">
        <div class="card border-0 shadow-sm rounded-4">
          <div class="card-body p-3 p-sm-4">
            <div class="d-flex align-items-center justify-content-between mb-1">
              <h2 class="h5 fw-bold mb-0">Nutrition vs ADG targets</h2>
              <span class="badge rounded-pill bg-light text-dark fw-semibold">
                Viewing: {{ filters.ageUnified }}
              </span>
            </div>

            <div v-if="!loaded.nutrition" class="text-muted small">Loading nutrition data…</div>
            <div v-else-if="nutritionRows.length === 0" class="text-danger small">
              No nutrition rows found for {{ filters.ageUnified }}.
            </div>

            <template v-else>
              <div v-for="row in nutritionRows" :key="row.key" class="nutri-row rounded-4 p-3 mb-3">
                <div class="d-flex align-items-center justify-content-between mb-1">
                  <div class="d-flex align-items-center gap-2">
                    <span class="food-emoji" :aria-label="row.label">{{ foodIcon(row.key) }}</span>
                    <span class="fw-semibold">{{ row.label }}</span>
                  </div>
                  <span class="badge rounded-pill" :class="gapBadgeClass(row.gapToTarget)">
                    Gap {{ formatGap(row.gapToTarget) }}
                  </span>
                </div>

                <div class="small text-muted mb-2">
                  Target: <strong>{{ row.target }} serves/day</strong> · Current:
                  <strong>{{ row.mean }}</strong>
                  <span v-if="row.percentBelow !== null">
                    · Below target: <strong>{{ row.percentBelow }}%</strong>
                  </span>
                </div>

                <div class="progress bg-light-subtle rounded-pill" style="height: 14px">
                  <div class="progress-bar" :style="progressStyle(row.mean, row.target)"></div>
                  <div
                    class="target-tick"
                    :style="{ left: 'calc(100% - 2px)' }"
                    title="Target"
                  ></div>
                </div>
              </div>

              <p class="mt-3 small text-muted">
                ADG = Australian Dietary Guidelines (children). Icons are illustrative only.
              </p>
            </template>
          </div>
        </div>
      </div>

      <!-- Physical Activity -->
      <div class="col-lg-5">
        <div class="card border-0 shadow-sm rounded-4 h-100">
          <div class="card-body p-3 p-sm-4 d-flex flex-column">
            <div class="d-flex align-items-center justify-content-between mb-1">
              <h2 class="h5 fw-bold mb-0">Daily movement (sufficient activity)</h2>
              <span class="badge rounded-pill bg-light text-dark fw-semibold">
                Viewing: {{ filters.ageUnified }}
              </span>
            </div>

            <div v-if="!loaded.activity" class="text-muted small">
              Loading physical activity data…
            </div>
            <div v-else-if="activityRows.length === 0" class="text-danger small">
              No activity rows found for {{ filters.ageUnified }}.
            </div>

            <div v-else class="d-grid gap-3">
              <div v-for="r in activityRows" :key="r.sex + r.ci" class="pa-row rounded-4 p-3">
                <div class="d-flex align-items-center justify-content-between">
                  <div class="d-flex align-items-center gap-2">
                    <span class="sex-emoji">{{ r.sex === 'Boys' ? '🧢' : '🎀' }}</span>
                    <span class="fw-semibold">{{ r.sex }}</span>
                  </div>
                  <span class="badge rounded-pill" :class="percentBadgeClass(r.percent)">
                    {{ r.percent }}% meet guideline
                  </span>
                </div>
                <div class="progress bg-light-subtle rounded-pill mt-2" style="height: 14px">
                  <div class="progress-bar" :style="{ width: r.percent + '%' }"></div>
                </div>
                <div class="small text-muted mt-1">95% CI: {{ r.ci }}</div>
              </div>
            </div>

            <div class="mt-auto small text-muted pt-3">
              Guideline reference: 60+ mins/day of moderate-to-vigorous activity (ages 5–17). For
              ages 2–5: 180 mins/day spread across the day.
            </div>
          </div>
        </div>
      </div>
    </div>

    <InsightNarratives
      v-if="nutritionItemsForNarrative?.length && movementSummaryForNarrative !== null"
      :nutrition-items="nutritionItemsForNarrative"
      :movement-summary="movementSummaryForNarrative"
      :age-label="ageLabelComputed"
    />

    <!-- Guidelines link -->
    <div class="mt-4 text-center">
      <a
        class="btn btn-primary rounded-pill px-4"
        href="https://www.health.gov.au/topics/physical-activity-and-exercise/physical-activity-and-exercise-guidelines-for-all-australians"
        target="_blank"
        rel="noopener"
        >View Australian Guidelines</a
      >
    </div>

    <!-- Find a playground -->
    <div class="mt-5">
      <center><h2 class="h1 fw-bold mb-2">Find a playground near you</h2></center>
      <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
        <!-- Your existing map component -->
        <MoveMoreMap />
      </div>
      <p class="small text-muted mt-2">
        Tip: getting outside for even 20–30 minutes of play can improve sleep readiness at night.
      </p>
    </div>
  </div>
</template>

<script>
import MoveMoreMap from '@/pages/children/MoveMoreMap.vue' // uses your existing component
import InsightNarratives from '@/components/InsightNarratives.vue'

export default {
  name: 'ParentEpic4Page',
  components: { MoveMoreMap, InsightNarratives },

  data() {
    return {
      filters: {
        ageUnified: '4–8', // 2–3, 4–8, 9–13, 14–18
      },
      nutrition: [],
      activity: [],
      loaded: { nutrition: false, activity: false },

      ageCards: [
        { key: '2–3', title: 'Toddlers', emoji: '👶' },
        { key: '4–8', title: 'Early years', emoji: '🧒' },
        { key: '9–13', title: 'Tweens', emoji: '🧑' },
        { key: '14–18', title: 'Teens', emoji: '🧑‍🎓' },
      ],
    }
  },

  computed: {
    /* ----------- Nutrition: persons view for unified age ----------- */
    nutritionRows() {
      // Map unified age -> list of nutrition ages to merge (hyphen form)
      const nutritionAgeKeys = mapUnifiedAgeToNutrition(this.filters.ageUnified)

      // Build a "Persons" row-set per age (prefer Persons rows, else avg Boys+Girls)
      const perAgeSets = nutritionAgeKeys.map((ageKey) =>
        personsSetForNutritionAge(this.nutrition, ageKey),
      )

      // Merge across ages by simple mean (targets & means are close; this keeps UI simple)
      const merged = mergeNutritionSets(perAgeSets)

      const order = ['veg', 'fruit', 'grains', 'meats', 'dairy']
      return order.filter((k) => merged[k]).map((k) => merged[k])
    },

    /* ----------- Physical Activity: unified age directly ----------- */
    activityRows() {
      const ageKey = normAge(this.filters.ageUnified)
      // Prefer Boys & Girls rows if present
      const rowsBG = this.activity.filter(
        (r) =>
          normAge(r.age_group) === ageKey &&
          (normSex(r.sex) === 'boys' || normSex(r.sex) === 'girls'),
      )
      if (rowsBG.length) {
        return rowsBG
          .sort(
            (a, b) =>
              ['boys', 'girls'].indexOf(normSex(a.sex)) - ['boys', 'girls'].indexOf(normSex(b.sex)),
          )
          .map((r) => ({
            sex: normSex(r.sex) === 'boys' ? 'Boys' : 'Girls',
            percent: Number(r.percent_sufficient),
            ci: r.ci,
          }))
      }
      // Fallback to any aggregate rows
      const agg = this.activity.filter((r) => normAge(r.age_group) === ageKey)
      return agg.map((r) => ({
        sex: normSex(r.sex) === 'boys' ? 'Boys' : normSex(r.sex) === 'girls' ? 'Girls' : 'All',
        percent: Number(r.percent_sufficient),
        ci: r.ci,
      }))
    },

    ageLabelComputed() {
      return this.selectedAgeLabel || this.filters?.ageUnified || 'Ages 2–3'
    },

    // Reuse the SAME items you loop over for nutrition bars
    // Expected per item: { key, label, target, current }
    nutritionItemsForNarrative() {
      // Example if you currently render from this.nutritionRows
      // and each row already has key/label/target/current:
      return (this.nutritionRows || []).map((r) => ({
        key: r.key || (r.label?.toLowerCase().includes('veg') ? 'veg' : r.key),
        label: r.label,
        target: Number(r.target),
        current: Number(r.current),
      }))
    },

    // Reuse whatever you already bind to the movement bars
    movementSummaryForNarrative() {
      // Accepts Number | Object | Array (component handles all)
      // Examples you might have:
      // - this.activityRows (array)
      // - this.movementAll (object with percentMeet)
      // - this.activityPercent (number)
      return this.activityRows || this.movementAll || this.activityPercent || null
    },
  },

  methods: {
    foodIcon(key) {
      if (key === 'veg') return '🥦'
      if (key === 'fruit') return '🍎'
      if (key === 'grains') return '🍞'
      if (key === 'meats') return '🍗'
      if (key === 'dairy') return '🥛'
      return '🍽️'
    },
    progressStyle(mean, target) {
      const pct = !target ? 0 : Math.min(100, Math.round((mean / target) * 100))
      return { width: pct + '%', background: pct >= 100 ? 'var(--ok)' : 'var(--warn)' }
    },
    gapBadgeClass(gap) {
      if (gap === null) return 'bg-secondary-subtle text-dark'
      if (gap <= 0) return 'bg-success-subtle text-success-emphasis'
      if (gap <= 0.5) return 'bg-warning-subtle text-warning-emphasis'
      return 'bg-danger-subtle text-danger-emphasis'
    },
    percentBadgeClass(p) {
      if (p >= 60) return 'bg-success-subtle text-success-emphasis'
      if (p >= 30) return 'bg-warning-subtle text-warning-emphasis'
      return 'bg-danger-subtle text-danger-emphasis'
    },
    formatGap(gap) {
      if (gap === null) return '—'
      const sign = gap > 0 ? '+' : ''
      return sign + gap.toFixed(1)
    },
  },

  async mounted() {
    try {
      const [nutrCsv, paCsv] = await Promise.all([
        fetch('/data/aihw_children_nutrition_tidy.csv').then((r) => r.text()),
        fetch('/data/aihw_children_physical_activity_tidy.csv').then((r) => r.text()),
      ])
      this.nutrition = parseCsvRobust(nutrCsv)
      this.activity = parseCsvRobust(paCsv)
    } catch (e) {
      console.error('Failed to load CSVs', e)
    } finally {
      this.loaded.nutrition = true
      this.loaded.activity = true
    }
  },
}

/* ================= Helpers ================= */
// robust numbers
function num(v) {
  if (v == null) return null
  const n = Number(String(v).replace(/[^\d.\-]/g, ''))
  return isNaN(n) ? null : n
}
// normalise ages (unify hyphen/en-dash)
function normAge(v) {
  return String(v || '')
    .replace(/\u2013|\u2014/g, '-')
    .replace(/\s+/g, '')
    .toLowerCase()
}
// normalise sex to boys|girls|all|''
function normSex(v) {
  const s = (v || '').toString().trim().toLowerCase()
  if (!s) return ''
  if (['boys', 'boy', 'male', 'males'].includes(s)) return 'boys'
  if (['girls', 'girl', 'female', 'females'].includes(s)) return 'girls'
  if (['all', 'persons', 'all persons', 'total', 'person'].includes(s)) return 'all'
  return s
}
// canonical food groups
function canonFoodGroup(labelOrKey) {
  const s = (labelOrKey || '').toString().toLowerCase()
  if (['veg', 'fruit', 'grains', 'meats', 'dairy'].includes(s))
    return { key: s, label: KEY_TO_LABEL[s] }
  if (s.includes('vegetable')) return { key: 'veg', label: KEY_TO_LABEL.veg }
  if (s.startsWith('fruit')) return { key: 'fruit', label: KEY_TO_LABEL.fruit }
  if (s.includes('grain')) return { key: 'grains', label: KEY_TO_LABEL.grains }
  if (s.includes('lean meats') || s.includes('meat') || s.includes('altern'))
    return { key: 'meats', label: KEY_TO_LABEL.meats }
  if (s.includes('milk') || s.includes('yoghurt') || s.includes('cheese') || s.includes('dairy'))
    return { key: 'dairy', label: KEY_TO_LABEL.dairy }
  return null
}
const KEY_TO_LABEL = {
  veg: 'Vegetables and legumes/beans',
  fruit: 'Fruit',
  grains: 'Grain (cereal) foods',
  meats: 'Lean meats and alternatives',
  dairy: 'Milk, yoghurt, cheese and alternatives',
}

// Quote-aware CSV parser
function parseCsvRobust(text) {
  const rows = []
  let row = []
  let cell = ''
  let q = false
  const pushCell = () => {
    row.push(cell)
    cell = ''
  }
  const pushRow = () => {
    rows.push(row)
    row = []
  }
  for (let i = 0; i < text.length; i++) {
    const ch = text[i]
    if (ch === '\"') {
      if (q && text[i + 1] === '\"') {
        cell += '\"'
        i++
      } else q = !q
    } else if (ch === ',' && !q) {
      pushCell()
    } else if ((ch === '\n' || ch === '\r') && !q) {
      if (ch === '\r' && text[i + 1] === '\n') i++
      pushCell()
      pushRow()
    } else {
      cell += ch
    }
  }
  if (cell.length || row.length) {
    pushCell()
    pushRow()
  }
  if (!rows.length) return []
  const headers = rows[0].map((h) => (h || '').trim())
  return rows
    .slice(1)
    .filter((r) => r.some((c) => (c || '').trim() !== ''))
    .map((cols) => {
      const o = {}
      headers.forEach((h, i) => (o[h] = (cols[i] ?? '').trim()))
      return o
    })
}

/* ---- Nutrition merging helpers ---- */
// unified UI ages -> nutrition ages (hyphen form)
function mapUnifiedAgeToNutrition(u) {
  const k = normAge(u)
  if (k === '2-3') return ['2-3']
  if (k === '4-8') return ['4-8']
  if (k === '9-13') return ['9-11', '12-13'] // merge these two
  if (k === '14-18') return ['14-18']
  return [k]
}
// get a "Persons" set for a single nutrition age (object keyed by group)
function personsSetForNutritionAge(nutrition, ageKey) {
  const ageNorm = normAge(ageKey)
  const sliceFor = (pred) => {
    const kept = {}
    nutrition.forEach((r) => {
      if (normAge(r.age_group) !== ageNorm) return
      if (!pred(r)) return

      const fg = (r.food_group || '').trim()
      if (!fg || /^\([a-z]\)/i.test(fg) || /^(note|sources?)/i.test(fg) || /^\d/.test(fg)) return

      const mean = num(r.mean_intake),
        target = num(r.target_serves_per_day)
      if (mean === null || target === null) return

      const canon = canonFoodGroup(fg)
      if (!canon) return

      const pbRaw = r.percent_below_target
      const pb = pbRaw == null || pbRaw === '' ? null : num(String(pbRaw).replace('#', ''))

      const obj = {
        key: canon.key,
        label: KEY_TO_LABEL[canon.key],
        target,
        mean,
        percentBelow: pb,
        gapToTarget: target - mean,
      }
      if (!kept[canon.key]) kept[canon.key] = obj
      else if (kept[canon.key].percentBelow === null && obj.percentBelow !== null)
        kept[canon.key] = obj
    })
    return kept
  }

  // Prefer Persons/All; else derive from boys+girls
  let persons = sliceFor((r) =>
    ['', 'persons', 'all persons', 'total', 'all'].includes(normSex(r.sex)),
  )
  if (Object.keys(persons).length) return persons

  const boys = sliceFor((r) => normSex(r.sex) === 'boys')
  const girls = sliceFor((r) => normSex(r.sex) === 'girls')
  const merged = {}
  ;['veg', 'fruit', 'grains', 'meats', 'dairy'].forEach((k) => {
    const b = boys[k],
      g = girls[k]
    if (!b && !g) return
    const t = b?.target ?? g?.target ?? null
    const m = b && g ? Number(((b.mean + g.mean) / 2).toFixed(1)) : (b?.mean ?? g?.mean ?? null)
    const pb =
      b && g && b.percentBelow != null && g.percentBelow != null
        ? Number(((b.percentBelow + g.percentBelow) / 2).toFixed(1))
        : (b?.percentBelow ?? g?.percentBelow ?? null)
    merged[k] = {
      key: k,
      label: KEY_TO_LABEL[k],
      target: t,
      mean: m,
      percentBelow: pb,
      gapToTarget: t != null && m != null ? t - m : null,
    }
  })
  return merged
}

// merge multiple age sets by simple mean (targets, means, %below)
function mergeNutritionSets(sets) {
  if (!sets.length) return {}
  const merged = {}
  const keys = ['veg', 'fruit', 'grains', 'meats', 'dairy']
  keys.forEach((k) => {
    const rows = sets.map((s) => s[k]).filter(Boolean)
    if (!rows.length) return
    const avg = (arr, pick) => {
      const nums = arr.map(pick).filter((v) => v != null)
      if (!nums.length) return null
      const s = nums.reduce((a, b) => a + b, 0) / nums.length
      return Number(s.toFixed(1))
    }
    const t = avg(rows, (r) => r.target)
    const m = avg(rows, (r) => r.mean)
    const pb = avg(rows, (r) => r.percentBelow)
    merged[k] = {
      key: k,
      label: KEY_TO_LABEL[k],
      target: t,
      mean: m,
      percentBelow: pb,
      gapToTarget: t != null && m != null ? t - m : null,
    }
  })
  return merged
}
</script>

<style scoped>
.parent-epi4 {
  --ok: #3ad29f;
  --warn: #ffd867;
  --bad: #ff8a8a;
}
.logo-pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 48px;
  height: 48px;
  border-radius: 999px;
  background: #f1f5ff;
  box-shadow: inset 0 0 0 2px #d9e6ff;
  font-size: 22px;
}
.tips .tip-chip {
  background: #fff5d8;
  color: #6b4f00;
  border: 1px dashed #ffd789;
  border-radius: 999px;
  padding: 6px 12px;
  font-weight: 600;
  display: inline-flex;
  gap: 8px;
  align-items: center;
}

.food-emoji,
.sex-emoji {
  font-size: 20px;
}
.nutri-row {
  background: #f9fbff;
  border: 1px solid #e8f0ff;
}
.pa-row {
  background: #fff8fb;
  border: 1px solid #ffd8ec;
}
.progress {
  position: relative;
}
.target-tick {
  position: absolute;
  top: -3px;
  width: 0;
  height: 20px;
  border-left: 3px solid #333;
  opacity: 0.25;
}

.badge.bg-success-subtle {
  background: #e6fff4 !important;
  border: 1px solid #b6f2d8;
}
.badge.bg-warning-subtle {
  background: #fff8d8 !important;
  border: 1px solid #ffe289;
}
.badge.bg-danger-subtle {
  background: #ffe6e6 !important;
  border: 1px solid #ffc4c4;
}

/* Age cards */
.age-card {
  height: 124px;
  border: 1px solid #eef2ff;
  background: linear-gradient(180deg, #ffffff, #f7faff);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
  transition:
    transform 0.1s ease,
    box-shadow 0.1s ease,
    border-color 0.1s ease;
}
.age-card .age-emoji {
  font-size: 36px;
  line-height: 1;
}
.age-card .age-label {
  font-weight: 700;
}
.age-card .age-sub {
  font-size: 12px;
  color: #6b7280;
}
.age-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.06);
}
.age-card.active {
  border-color: #3b82f6;
  box-shadow: 0 8px 24px rgba(59, 130, 246, 0.18);
}
</style>
