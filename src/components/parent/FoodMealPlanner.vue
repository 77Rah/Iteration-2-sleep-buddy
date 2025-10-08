<script setup>
import { ref, computed, onMounted } from 'vue'
import Papa from 'papaparse'

// ===== CSV path (place in public/data). Update if you renamed the file. =====
const CSV_URL = encodeURI('/data/Children_Foods.csv')

// ===== State =====
const rows = ref([])
const loading = ref(true)
const error = ref('')

const nameCol = ref('')      // Detected food name column
const allNames = ref([])     // Unique food names for datalist

// UI controls
const newFood = ref('')      // Selected food name to add
const items = ref([])        // [{ name, grams }]

// ===== Helpers =====
const normalizeHeader = h => String(h ?? '').trim()
const isNonEmpty = v => v !== null && v !== undefined && String(v).trim() !== ''
const toNum = v => {
  const n = Number(v)
  return Number.isFinite(n) ? n : NaN
}

// Try to detect the food-name column
function detectNameCol(sample) {
  const candidates = ['FoodName', 'Food name', 'Food', 'Name']
  const keys = Object.keys(sample || {})
  for (const k of candidates) if (keys.includes(k)) return k
  // fallback: first non-numeric-looking column
  return keys.find(k => isNaN(toNum(sample[k]))) || keys[0]
}

// Detect numeric nutrient columns (per 100 g) by sampling
function detectNumericColumns(list, excludeKeys) {
  const keys = Object.keys(list[0] || {})
  const numerics = []
  for (const k of keys) {
    if (excludeKeys.has(k)) continue
    const take = list.slice(0, 20)
    const count = take.reduce((acc, r) => acc + (Number.isFinite(toNum(r[k])) ? 1 : 0), 0)
    if (count >= Math.max(3, Math.ceil(take.length / 2))) numerics.push(k)
  }
  return numerics
}

function getRowByName(name) {
  return rows.value.find(r => String(r[nameCol.value]).trim() === String(name).trim()) || null
}

// ===== Load CSV =====
onMounted(async () => {
  try {
    const res = await fetch(CSV_URL, { cache: 'no-store' })
    if (!res.ok) throw new Error(`HTTP ${res.status} – failed to fetch CSV`)
    const text = await res.text()
    const parsed = Papa.parse(text, {
      header: true,
      dynamicTyping: true,
      skipEmptyLines: true,
      delimiter: '',
      transformHeader: normalizeHeader
    })
    if (parsed.errors?.length) throw new Error(`CSV parse error: ${parsed.errors[0].message || 'unknown'}`)
    rows.value = parsed.data
    if (!rows.value.length) throw new Error('CSV loaded but has no rows.')

    // Detect name column and build datalist
    nameCol.value = detectNameCol(rows.value[0])
    const names = Array.from(new Set(rows.value.map(r => String(r[nameCol.value]).trim()).filter(isNonEmpty))).sort()
    allNames.value = names
  } catch (e) {
    error.value = String(e?.message || e)
  } finally {
    loading.value = false
  }
})

// ===== Picker actions =====
function addFood() {
  if (!isNonEmpty(newFood.value)) return
  const name = String(newFood.value).trim()
  if (!allNames.value.includes(name)) return
  const existed = items.value.find(it => it.name === name)
  if (existed) {
    existed.grams = existed.grams + 50
  } else {
    items.value.push({ name, grams: 100 })
  }
  newFood.value = ''
}

function removeFood(index) {
  items.value.splice(index, 1)
}

// ===== Nutrient math =====
const excludeMeta = computed(() => new Set([nameCol.value, 'Vegan (Yes/No)', 'Recommended age range']))
const nutrientCols = computed(() => {
  if (!rows.value.length) return []
  return detectNumericColumns(rows.value, excludeMeta.value)
})

// Common keys (best-effort detection among possible variants)
function findFirstExisting(candidates) {
  return candidates.find(c => nutrientCols.value.includes(c)) || null
}
const K_ENERGY = computed(() => findFirstExisting(['Energy (kcal/day)', 'Energy (kcal/100g)', 'Energy (kcal)']))
const K_PROTEIN = computed(() => findFirstExisting(['Protein (Recommended Dietary Intake) (g/day)', 'Protein (g/100g)', 'Protein (g)']))
const K_SUGARS  = computed(() => findFirstExisting(['Sugars (WHO recommended maximum) (g/day)', 'Sugars (g/100g)', 'Sugars (g)']))

// Totals per nutrient across all items (sum(value_per_100g × grams / 100))
const totals = computed(() => {
  const total = {}
  for (const col of nutrientCols.value) total[col] = 0
  for (const it of items.value) {
    const row = getRowByName(it.name)
    if (!row) continue
    const factor = Number(it.grams) / 100
    for (const col of nutrientCols.value) {
      const v = toNum(row[col])
      if (Number.isFinite(v)) total[col] += v * factor
    }
  }
  return total
})

const statCards = computed(() => {
  const cards = []
  if (K_ENERGY.value) cards.push({ label: 'Energy',  key: K_ENERGY.value,  unit: '', accent: 'energy' })
  if (K_PROTEIN.value) cards.push({ label: 'Protein', key: K_PROTEIN.value, unit: '', accent: 'protein' })
  if (K_SUGARS.value)  cards.push({ label: 'Sugars',  key: K_SUGARS.value,  unit: '', accent: 'sugars' })
  return cards
})

function fmt(x) {
  const n = Number(x)
  if (!Number.isFinite(n)) return '0'
  return Math.abs(n - Math.round(n)) < 1e-9 ? String(Math.round(n)) : n.toFixed(2)
}
</script>

<template>
  <div class="meal">
    <!-- Top panel: left = picker (fixed area), right = current meal (scrollable) -->
    <div class="card panel shadow-soft rounded-4 mb-4">
      <div class="card-body">
        <h3 class="h3 fw-bold mb-2">Meal Planner</h3>
        <p class="text-muted small mb-4">
          Build a meal by selecting foods and setting serving sizes (in grams). Totals update automatically.
        </p>

        <div class="row g-4">
          <!-- Left: picker (stays visible, not pushed by the list) -->
          <div class="col-12 col-lg-5">
            <label class="form-label">Pick a food</label>
            <div class="input-group">
              <input
                class="form-control stylish"
                list="foods"
                v-model.trim="newFood"
                placeholder="Type or choose from the list…"
                :disabled="loading || !!error || !allNames.length"
              />
              <button class="btn btn-primary" type="button" @click="addFood" :disabled="!newFood">Add</button>
            </div>
            <datalist id="foods">
              <option v-for="n in allNames" :key="n" :value="n" />
            </datalist>
          </div>

          <!-- Right: current meal (scrollable container with a fixed max-height) -->
          <div class="col-12 col-lg-7">
            <label class="form-label">Current meal</label>
            <div class="selected-list scroll-area">
              <div
                v-for="(it, idx) in items"
                :key="it.name"
                class="sel-item hover-lift"
              >
                <div class="sel-name">{{ it.name }}</div>
                <div class="sel-controls">
                  <label class="small me-2">grams</label>
                  <input
                    type="number"
                    class="form-control form-control-sm stylish w-90"
                    min="0"
                    step="10"
                    v-model.number="it.grams"
                  />
                  <button class="btn btn-outline-danger btn-sm ms-2" @click="removeFood(idx)">Remove</button>
                </div>
              </div>

              <div v-if="!items.length" class="empty small text-muted">
                No foods selected yet — add an item from the left to get started.
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading / Error -->
    <div v-if="loading" class="loading">Loading…</div>
    <div v-else-if="error" class="alert alert-danger border-0 shadow-soft rounded-4">{{ error }}</div>

    <!-- Highlight cards (show only if there are items and keys exist) -->
    <div v-else-if="items.length" class="row g-3">
      <div v-for="(c, i) in statCards" :key="c.key" class="col-12 col-md-4">
        <div class="card stat rounded-4 h-100 hover-lift" :data-accent="c.accent">
          <div class="card-body">
            <div class="stat-label">{{ c.label }}</div>
            <div class="stat-value">
              {{ fmt(totals[c.key]) }}
              <span class="stat-unit" v-if="c.unit">{{ c.unit }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Totals table (ALWAYS visible after CSV is loaded, even when no items) -->
    <div v-if="!loading && !error" class="card panel shadow-soft rounded-4 mt-4">
      <div class="card-body">
        <div class="d-flex align-items-center justify-content-between mb-3">
          <h4 class="h6 fw-bold mb-0">Meal totals</h4>
          <span class="badge bg-light text-muted border">{{ items.length }} items</span>
        </div>

        <div class="table-wrap">
          <table class="table align-middle table-hover mb-0">
            <thead>
              <tr>
                <th>Nutrient (per 100 g column)</th>
                <th class="text-end">Total</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="!nutrientCols.length">
                <td colspan="2" class="text-muted">No numeric nutrient columns detected in the dataset.</td>
              </tr>
              <tr v-for="col in nutrientCols" :key="col">
                <td class="label-cell">{{ col }}</td>
                <td class="text-end"><span class="value">{{ fmt(totals[col]) }}</span></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* ===== Theme tokens ===== */
:root {
  --sb-line: #e9edf3;
  --sb-shadow: 0 6px 20px rgba(17, 24, 39, 0.08);
  --sb-shadow-hover: 0 10px 28px rgba(17, 24, 39, 0.14);
  --accent-energy: #6366f1; /* indigo */
  --accent-protein: #14b8a6; /* teal   */
  --accent-sugars: #f43f5e; /* rose   */
}
.panel { border: 1px solid var(--sb-line); background: #fff; }
.shadow-soft { box-shadow: var(--sb-shadow); }

/* Inputs */
.form-control.stylish, .form-select.stylish { transition: box-shadow .2s ease, border-color .2s ease; }
.form-control.stylish:focus, .form-select.stylish:focus {
  border-color: #6366f1;
  box-shadow: 0 0 0 0.2rem rgba(99,102,241,0.15);
}

/* Loading */
.loading { color: #6b7280; }

/* Layout: keep picker fixed height by making the list scrollable */
.scroll-area {
  max-height: 260px;  /* adjust as you like */
  overflow: auto;
}

/* Selected items pill list */
.selected-list {
  border: 1px dashed var(--sb-line);
  border-radius: .75rem;
  padding: .75rem;
  min-height: 56px;
  background: #fff;
}
.sel-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  border: 1px solid var(--sb-line);
  border-radius: .75rem;
  padding: .5rem .75rem;
  background: #fff;
  margin-bottom: .5rem;
  transition: transform .18s ease, box-shadow .18s ease, border-color .18s ease;
}
.sel-item:last-child { margin-bottom: 0; }
.sel-item:hover { transform: translateY(-2px); box-shadow: var(--sb-shadow-hover); }
.sel-name { font-weight: 600; margin-right: .75rem; }
.sel-controls { display: flex; align-items: center; }
.w-90 { width: 90px; }
.empty { padding: .25rem .5rem; }

/* Stat cards */
.stat { border: 1px solid var(--sb-line); transition: transform .18s ease, box-shadow .18s ease; }
.stat:hover { transform: translateY(-3px) scale(1.02); box-shadow: var(--sb-shadow-hover); }
.stat .stat-label { font-size: .85rem; color: #64748b; }
.stat .stat-value { font-size: 1.7rem; font-weight: 700; line-height: 1.1; color: #4c37b0;}
.stat .stat-unit { margin-left: .25rem; font-size: .9rem; color: #64748b; font-weight: 500; }
.stat[data-accent="energy"]  { border-left: 4px solid var(--accent-energy);  }
.stat[data-accent="protein"] { border-left: 4px solid var(--accent-protein); }
.stat[data-accent="sugars"]  { border-left: 4px solid var(--accent-sugars); }

/* Totals table */
.table-wrap { border: 1px solid var(--sb-line); border-radius: .75rem; overflow: hidden; }
.table thead th {
  background: #f8fafc;
  position: sticky;
  top: 0;
  z-index: 1;
  user-select: none;
}
.table tbody tr:hover { background: #fafcff; }
.label-cell { font-weight: 600; }
.value { font-variant-numeric: tabular-nums; }
.badge.border { border: 1px solid var(--sb-line) !important; }
</style>
