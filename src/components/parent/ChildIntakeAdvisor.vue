<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import Papa from 'papaparse'

// CSV location (place file in public/data; update the name if you renamed it)
const CSV_URL = encodeURI('/data/3_12y_by_Age_Weight_Sex___Recommended_Intakes__Sugars___WHO_recommended_max_.csv')

// ---------- State ----------
const rows = ref([])
const loading = ref(true)
const error = ref('')

// Dropdown options & selections
const sexOptions = ['Boys', 'Girls']
const ageOptions = ref([])
const weightOptions = ref([])
const sex = ref('Boys')
const age = ref(null)
const weight = ref(null)

// Helpers
const isNonEmpty = v => v !== null && v !== undefined && String(v).trim() !== ''
const normalizeHeader = h => String(h ?? '').trim()

// ---------- Load & validate CSV ----------
onMounted(async () => {
  console.log('[ChildIntakeAdvisor] fetching:', CSV_URL)
  try {
    const res = await fetch(CSV_URL, { cache: 'no-store' })
    console.log('[ChildIntakeAdvisor] HTTP status:', res.status)
    if (!res.ok) throw new Error(`HTTP ${res.status} – failed to fetch CSV. Make sure the file is in public/data and the path matches.`)

    const text = await res.text()
    const parsed = Papa.parse(text, {
      header: true,
      dynamicTyping: true,
      skipEmptyLines: true,
      delimiter: '',
      transformHeader: normalizeHeader,
    })

    if (parsed.errors?.length) {
      console.error('[PapaParse errors]', parsed.errors)
      throw new Error(`CSV parse error: ${parsed.errors[0].message || 'unknown'}`)
    }

    const data = parsed.data
    if (!Array.isArray(data) || data.length === 0) {
      throw new Error('CSV loaded but has no data rows.')
    }

    const cols = Object.keys(data[0] || {})
    console.log('[ChildIntakeAdvisor] columns:', cols)
    const required = ['Age (years)', 'Sex', 'Weight (kg)']
    const missing = required.filter(c => !cols.includes(c))
    if (missing.length) {
      throw new Error(`CSV is missing required columns: ${missing.join(', ')}`)
    }

    rows.value = data

    // Initialize age options and default selection
    const ages = Array.from(new Set(rows.value.map(r => Number(r['Age (years)']))))
      .filter(Number.isFinite)
      .sort((a,b)=>a-b)

    if (!ages.length) throw new Error('No age values found in CSV.')
    ageOptions.value = ages
    age.value = ages.includes(6) ? 6 : ages[0]
  } catch (e) {
    console.error('[ChildIntakeAdvisor] ERROR:', e)
    error.value = String(e?.message || e)
  } finally {
    loading.value = false
  }
})

// Candidates for the selected age + sex
const candidates = computed(() =>
  rows.value.filter(r =>
    Number(r['Age (years)']) === Number(age.value) &&
    String(r['Sex']).trim() === sex.value
  )
)

// Update weight options whenever age/sex change
watch([age, sex, candidates], () => {
  const weights = Array.from(new Set(candidates.value.map(r => Number(r['Weight (kg)']))))
    .filter(Number.isFinite)
    .sort((a,b)=>a-b)

  weightOptions.value = weights
  if (!weights.length) { weight.value = null; return }
  if (!weights.includes(Number(weight.value))) {
    weight.value = weights[Math.floor(weights.length/2)] // default to median
  }
}, { immediate: true })

// The single matched row for age+sex+weight
const match = computed(() => {
  if (!candidates.value.length || weight.value == null) return null
  return candidates.value.find(r => Number(r['Weight (kg)']) === Number(weight.value)) || null
})

// Highlight cards (only show if value exists)
const statCards = computed(() => {
  if (!match.value) return []
  return [
    { key: 'Energy (kcal/day)', label: 'Energy', unit: 'kcal/day', accent: 'energy' },
    { key: 'Protein (Recommended Dietary Intake) (g/day)', label: 'Protein (RDI)', unit: 'g/day', accent: 'protein' },
    { key: 'Sugars (WHO recommended maximum) (g/day)', label: 'Sugars (WHO max)', unit: 'g/day', accent: 'sugars' },
  ]
  .map(c => ({ ...c, value: match.value[c.key] }))
  .filter(c => isNonEmpty(c.value))
})

// Table rows: use raw CSV labels; show only fields that exist & are non-empty; pin highlights to the top
const tableRows = computed(() => {
  if (!match.value) return []
  const meta = new Set(['Age (years)', 'Sex', 'Weight (kg)'])
  const preferred = [
    'Energy (kcal/day)',
    'Protein (Recommended Dietary Intake) (g/day)',
    'Sugars (WHO recommended maximum) (g/day)',
  ]

  const keys = Object.keys(match.value)
    .filter(k => !meta.has(k) && isNonEmpty(match.value[k]))

  const ordered = [
    ...preferred.filter(k => keys.includes(k)),
    ...keys.filter(k => !preferred.includes(k)).sort((a,b)=>a.localeCompare(b)),
  ]

  return ordered.map(k => ({ label: k, value: match.value[k] }))
})
</script>

<template>
  <div class="cia">
    <!-- Inputs card -->
    <div class="card panel shadow-soft rounded-4 mb-4">
      <div class="card-body">
        <h3 class="h3 fw-bold mb-2">Child Intake Advisor</h3>
        <p class="text-muted small mb-4">
          Select <b>sex</b>, <b>age</b>, and <b>weight</b> to view the daily recommended intakes.
        </p>

        <div class="row g-3">
          <div class="col-12 col-md-4">
            <label class="form-label">Sex</label>
            <select class="form-select stylish" v-model="sex" :disabled="loading" aria-label="Select sex">
              <option v-for="s in sexOptions" :key="s" :value="s">{{ s }}</option>
            </select>
          </div>

          <div class="col-6 col-md-4">
            <label class="form-label">Age (years)</label>
            <select class="form-select stylish" v-model="age" :disabled="loading || !ageOptions.length" aria-label="Select age">
              <option v-for="a in ageOptions" :key="a" :value="a">{{ a }}</option>
            </select>
          </div>

          <div class="col-6 col-md-4">
            <label class="form-label">Weight (kg)</label>
            <select class="form-select stylish" v-model="weight" :disabled="loading || !weightOptions.length" aria-label="Select weight">
              <option v-for="w in weightOptions" :key="w" :value="w">{{ w }}</option>
            </select>
          </div>
        </div>
      </div>
    </div>

    <!-- Status -->
    <div v-if="loading" class="loading">Loading…</div>
    <div v-else-if="error" class="alert alert-danger border-0 shadow-soft rounded-4">
      {{ error }}
    </div>

    <!-- Results -->
    <div v-else>
      <div v-if="!match" class="alert alert-warning border-0 shadow-soft rounded-4">
        No matching row. Check that the selected age & sex exist in the CSV.
      </div>

      <!-- Highlight cards -->
      <div v-else class="row g-3">
        <div
          v-for="(c, i) in statCards"
          :key="i"
          class="col-12 col-md-4"
        >
          <div class="stat card rounded-4 h-100 hover-lift" :data-accent="c.accent">
            <div class="card-body">
              <div class="stat-label">{{ c.label }}</div>
              <div class="stat-value">
                {{ c.value }}
                <span v-if="c.unit" class="stat-unit">{{ c.unit }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Table -->
      <div class="card panel shadow-soft rounded-4 mt-4" v-if="match">
        <div class="card-body">
          <div class="d-flex align-items-center justify-content-between mb-3">
            <h4 class="h6 fw-bold mb-0">Recommended Intakes</h4>
            <span class="badge bg-light text-muted border">Age {{ age }} · {{ sex }} · {{ weight }} kg</span>
          </div>

          <div class="table-wrap">
            <table class="table align-middle mb-0 table-hover">
              <thead>
                <tr>
                  <th>Item</th>
                  <th class="text-end">Amount</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, i) in tableRows" :key="i">
                  <td class="label-cell">{{ r.label }}</td>
                  <td class="text-end">
                    <span class="value">{{ r.value }}</span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* ---------- Theme tokens ---------- */
:root {
  --sb-bg: #ffffff;
  --sb-line: #e9edf3;
  --sb-text-muted: #6b7280;
  --sb-indigo: #6366f1;
  --sb-teal: #14b8a6;
  --sb-rose: #f43f5e;
  --sb-shadow: 0 6px 20px rgba(17, 24, 39, 0.08);
  --sb-shadow-hover: 0 10px 28px rgba(17, 24, 39, 0.14);
}

/* ---------- Panels & inputs ---------- */
.panel {
  background: var(--sb-bg);
  border: 1px solid var(--sb-line);
}
.shadow-soft { box-shadow: var(--sb-shadow); }

.form-select.stylish:focus {
  border-color: var(--sb-indigo);
  box-shadow: 0 0 0 0.2rem rgba(99,102,241,0.15);
  outline: none;
  transition: box-shadow .2s ease, border-color .2s ease;
}

/* ---------- Loading ---------- */
.loading { color: var(--sb-text-muted); }

/* ---------- Stat cards ---------- */
.stat { 
  border: 1px solid var(--sb-line);
  transition: transform .18s ease, box-shadow .18s ease, border-color .18s ease;
}
.stat .stat-label {
  font-size: .85rem;
  color: var(--sb-text-muted);
}
.stat .stat-value {
  font-size: 1.7rem;
  font-weight: 700;
  line-height: 1.1;
  color: #4c37b0;
}
.stat .stat-unit {
  margin-left: .25rem;
  font-size: .9rem;
  color: var(--sb-text-muted);
  font-weight: 500;
}

/* Accent borders per card */
.stat[data-accent="energy"]  { border-left: 4px solid var(--sb-indigo); }
.stat[data-accent="protein"] { border-left: 4px solid var(--sb-teal);   }
.stat[data-accent="sugars"]  { border-left: 4px solid var(--sb-rose);   }

/* Hover lift/scale feedback */
.hover-lift:hover {
  transform: translateY(-3px) scale(1.02);
  box-shadow: var(--sb-shadow-hover);
}

/* ---------- Table ---------- */
.table-wrap {
  border: 1px solid var(--sb-line);
  border-radius: .75rem;
  overflow: hidden;
}
.table thead th {
  background: #f8fafc;
  position: sticky;
  top: 0;
  z-index: 1;
}
.table tbody tr:hover {
  background: #fafcff;
}
.label-cell { font-weight: 600; }
.value { font-variant-numeric: tabular-nums; }

/* ---------- Badges ---------- */
.badge.border {
  border: 1px solid var(--sb-line);
}

/* ---------- Small screens ---------- */
@media (max-width: 576px) {
  .stat .stat-value { font-size: 1.5rem; }
}
</style>
