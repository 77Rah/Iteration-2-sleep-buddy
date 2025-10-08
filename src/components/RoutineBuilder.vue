<template>
  <div class="card p-3">
    <!-- Header (no Save; auto-persistence) -->
    <div class="d-flex align-items-center justify-content-between mb-2">
      <h3 class="h6 mb-0">Bedtime Routine Coach</h3>
      <div class="d-flex gap-2">
        <button
          class="btn btn-outline-secondary btn-sm"
          @click="clearRoutine"
          :disabled="routine.length === 0"
        >
          Clear Checklist
        </button>
      </div>
    </div>

    <div class="row g-4">
      <!-- LEFT: User checklist (fixed height 530px; scrollable) -->
      <div class="col-12 col-lg-8">
        <div
          class="card p-3 routine-dropzone pane-left"
          :class="{ 'is-over': overLeft }"
          @dragover.prevent="onLeftDragOver"
          @dragleave="onLeftDragLeave"
          @drop="onLeftDrop"
        >
          <div class="d-flex align-items-center justify-content-between mb-2">
            <div class="fw-semibold">Your Bedtime Checklist</div>
            <small class="text-muted">Drag from the right · Reorder here</small>
          </div>

          <div class="pane-body">
            <p v-if="routine.length === 0" class="text-muted small mb-3">
              Drop items here to build your routine.
            </p>

            <ul class="list-group list-group-flush">
              <li
                v-for="(it, idx) in routine"
                :key="it.uid"
                class="list-group-item d-flex align-items-center routine-item"
                draggable="true"
                @dragstart="onLeftItemDragStart(idx)"
                @dragover.prevent="onLeftItemDragOver(idx)"
                @drop="onLeftItemDrop(idx)"
              >
                <span class="drag-handle me-2" title="Drag to reorder">⋮⋮</span>
                <span class="me-2">{{ it.emoji }}</span>
                <div class="flex-grow-1">
                  <div class="fw-semibold">{{ it.title }}</div>
                  <div v-if="it.note" class="small text-muted">{{ it.note }}</div>
                </div>
                <button class="btn btn-sm btn-outline-secondary me-2" @click="editNote(idx)">
                  Note
                </button>
                <button class="btn btn-sm btn-outline-danger" @click="removeFromRoutine(idx)">
                  Remove
                </button>
              </li>
            </ul>
          </div>
        </div>
      </div>

      <!-- RIGHT: Routine Items (default + custom; fixed height 530px; scrollable) -->
      <div class="col-12 col-lg-4">
        <div class="card p-3 pane-right">
          <div class="fw-semibold mb-1">Routine Items</div>
          <p class="text-muted small">Drag an item to the checklist · Add your own below</p>

          <div class="pane-body">
            <div class="row g-2 mb-3">
              <div class="col-12" v-for="p in allPalette" :key="p.uid || p.id">
                <div
                  class="palette-item d-flex align-items-center"
                  draggable="true"
                  @dragstart="onPaletteDragStart(p)"
                  :title="p.tip || ''"
                >
                  <span class="me-2">{{ p.emoji }}</span>
                  <div class="flex-grow-1">
                    <div class="fw-semibold">
                      {{ p.title }}
                      <small v-if="p.uid" class="text-muted ms-1">(custom)</small>
                    </div>
                    <div v-if="p.tip" class="small text-muted">{{ p.tip }}</div>
                  </div>

                  <!-- Custom item: burger (left) + Add (right) -->
                  <template v-if="p.uid">
                    <button
                      class="btn btn-sm btn-outline-secondary me-1"
                      @click.stop="openMenu(p.uid, $event)"
                      title="More actions"
                    >
                      ☰
                    </button>
                    <button class="btn btn-sm btn-outline-primary" @click="addToRoutine(p)">
                      Add
                    </button>
                  </template>

                  <!-- Default item: Add only -->
                  <template v-else>
                    <button class="btn btn-sm btn-outline-primary" @click="addToRoutine(p)">
                      Add
                    </button>
                  </template>
                </div>
              </div>
            </div>
          </div>

          <hr />
          <!-- Custom input: adds to RIGHT items (not directly to LEFT checklist) -->
          <div class="custom-add">
            <label class="form-label small mb-1">Add your own step:</label>
            <div class="input-group">
              <input
                type="text"
                v-model="customText"
                class="form-control form-control-sm"
                placeholder="e.g. Goodnight call with grandma"
                @keyup.enter="addCustomToPalette"
              />
              <button class="btn btn-sm btn-success" @click="addCustomToPalette">
                Add to Items
              </button>
            </div>
            <div class="form-text small">
              Custom items will appear above. Drag them into the checklist.
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Teleport menu rendered on <body> to avoid overflow/z-index issues -->
    <teleport to="body">
      <div v-if="menu.open" class="sb-menu-backdrop" @click="closeMenu">
        <div class="sb-menu" :style="{ top: menu.y + 'px', left: menu.x + 'px' }" @click.stop>
          <button class="sb-menu-item" @click="onEditMenu(menu.uid)">Edit</button>
          <button class="sb-menu-item text-danger" @click="onRemoveMenu(menu.uid)">Remove</button>
        </div>
      </div>
    </teleport>
  </div>
</template>

<script setup>
// RoutineBuilder – right palette (default + custom). Custom items have burger menu rendered via Teleport (Edit/Remove).
// Left checklist is fixed height (530px) with internal scroll; drag from right to left; reorder on left.
// All data auto-saved to localStorage (no Save button).

import { ref, computed, watch, onMounted } from 'vue'

/* ---------- Default (non-editable) items shown on the right ---------- */
const defaultPalette = [
  { id: 'tooth', title: 'Brush Teeth', tip: '2 minutes, small circles', emoji: '🪥' },
  { id: 'bath', title: 'Bath / Wash', tip: 'Warm, not hot', emoji: '🛁' },
  { id: 'pjs', title: 'Put on Pyjamas', tip: 'Comfy & warm', emoji: '🧸' },
  { id: 'toilet', title: 'Toilet', tip: 'Before reading', emoji: '🚽' },
  { id: 'water', title: 'Small Sip of Water', tip: 'Not too much', emoji: '💧' },
  { id: 'story', title: 'Story Time', tip: '5–10 mins calm story', emoji: '📖' },
  { id: 'med', title: 'Guided Meditation', tip: '3–5 mins breathing', emoji: '🧘' },
  { id: 'lights', title: 'Lights Out', tip: 'Dim → off', emoji: '💡' },
  { id: 'hug', title: 'Cuddle & Goodnight', tip: 'Short and sweet', emoji: '🤗' },
]

/* ---------- Custom items on the right (editable/removable) ---------- */
const customPalette = ref([]) // [{ uid, id:'custom', title, emoji:'⭐' }]
const customText = ref('')

/* ---------- Left checklist (user-built) ---------- */
const routine = ref([]) // [{ uid, id, title, emoji, note? }]

/* ---------- DnD state ---------- */
let dragFromPalette = null
let dragFromLeftIdx = null
let hoverIdx = null
const overLeft = ref(false)

/* ---------- LocalStorage keys ---------- */
const LS_ROUTINE = 'sleepbuddy_routine_v1'
const LS_CUSTOM = 'sleepbuddy_custom_items_v1'

/* ---------- Helpers ---------- */
const uid = () => Math.random().toString(36).slice(2, 9)
const allPalette = computed(() => [...defaultPalette, ...customPalette.value])

/* Add to LEFT checklist */
function addToRoutine(p) {
  routine.value.push({
    uid: uid(),
    id: p.id || 'custom',
    title: p.title,
    emoji: p.emoji || '⭐',
    note: '',
  })
}

/* Add custom item to RIGHT palette */
function addCustomToPalette() {
  const t = customText.value.trim()
  if (!t) return
  customPalette.value.push({
    uid: uid(),
    id: 'custom',
    title: t,
    emoji: '⭐',
  })
  customText.value = ''
}

/* LEFT: remove / note / reorder */
function removeFromRoutine(idx) {
  routine.value.splice(idx, 1)
}
function editNote(idx) {
  const cur = routine.value[idx]
  const note = prompt('Add a short note (optional):', cur.note || '')
  if (note !== null) cur.note = note.trim()
}
function onLeftItemDragStart(idx) {
  dragFromLeftIdx = idx
}
function onLeftItemDragOver(idx) {
  hoverIdx = idx
}
function onLeftItemDrop(idx) {
  if (dragFromLeftIdx === null || dragFromLeftIdx === idx) return
  const moving = routine.value.splice(dragFromLeftIdx, 1)[0]
  routine.value.splice(idx, 0, moving)
  dragFromLeftIdx = null
  hoverIdx = null
}

/* RIGHT→LEFT DnD */
function onPaletteDragStart(p) {
  dragFromPalette = p
}
function onLeftDragOver(e) {
  e.preventDefault()
  overLeft.value = true
}
function onLeftDragLeave() {
  overLeft.value = false
}
function onLeftDrop() {
  overLeft.value = false
  if (dragFromPalette) {
    const newItem = {
      uid: uid(),
      id: dragFromPalette.id || 'custom',
      title: dragFromPalette.title,
      emoji: dragFromPalette.emoji || '⭐',
      note: '',
    }
    if (hoverIdx !== null && hoverIdx >= 0) {
      routine.value.splice(hoverIdx, 0, newItem)
    } else {
      routine.value.push(newItem)
    }
  }
  dragFromPalette = null
  dragFromLeftIdx = null
  hoverIdx = null
}

/* ---------- Teleport burger menu state & actions (for custom items only) ---------- */
const menu = ref({ open: false, uid: null, x: 0, y: 0 })

function openMenu(u, evt) {
  const rect = evt.currentTarget.getBoundingClientRect()
  menu.value = {
    open: true,
    uid: u,
    x: Math.round(rect.left),
    y: Math.round(rect.bottom + 6),
  }
  window.addEventListener('keydown', onEscClose)
}
function closeMenu() {
  menu.value.open = false
  window.removeEventListener('keydown', onEscClose)
}
function onEscClose(e) {
  if (e.key === 'Escape') closeMenu()
}

function onEditMenu(u) {
  const idx = customPalette.value.findIndex((x) => x.uid === u)
  if (idx === -1) return closeMenu()
  const cur = customPalette.value[idx]
  const t = prompt('Edit item:', cur.title)
  if (t && t.trim()) {
    cur.title = t.trim()
    // force reactivity update
    customPalette.value.splice(idx, 1, { ...cur })
  }
  closeMenu()
}
function onRemoveMenu(u) {
  customPalette.value = customPalette.value.filter((x) => x.uid !== u)
  closeMenu()
}

/* ---------- Persistence (auto-save) ---------- */
function loadRoutine() {
  try {
    routine.value = JSON.parse(localStorage.getItem(LS_ROUTINE) || '[]')
  } catch {}
}
function loadCustom() {
  try {
    customPalette.value = JSON.parse(localStorage.getItem(LS_CUSTOM) || '[]')
  } catch {}
}
function saveRoutine() {
  try {
    localStorage.setItem(LS_ROUTINE, JSON.stringify(routine.value))
    window.dispatchEvent(new Event('routine-updated')) //Manually send events
  } catch {}
}
function saveCustom() {
  try {
    localStorage.setItem(LS_CUSTOM, JSON.stringify(customPalette.value))
  } catch {}
}
function clearRoutine() {
  if (!confirm('Clear your current checklist?')) return
  routine.value = []
}

watch(routine, saveRoutine, { deep: true })
watch(customPalette, saveCustom, { deep: true })

onMounted(() => {
  loadRoutine()
  loadCustom()
})
</script>

<style scoped>
/* LEFT fixed height (530px) + internal scroll */
.pane-left .pane-body {
  max-height: 530px;
  overflow: auto;
}

/* RIGHT fixed height (530px) + internal scroll */
.pane-right .pane-body {
  max-height: 530px;
  overflow: auto;
}

/* Drop highlight when dragging into left pane */
.routine-dropzone.is-over {
  outline: 2px dashed #9ec5fe;
  outline-offset: 2px;
}

/* LEFT list item visuals */
.routine-item {
  cursor: grab;
}
.routine-item:active {
  cursor: grabbing;
}
.drag-handle {
  font-size: 18px;
  color: #94a3b8;
  cursor: grab;
}

/* RIGHT palette item card */
.palette-item {
  border: 1px solid #edf1f7;
  border-radius: 12px;
  padding: 10px 12px;
  background: #fff;
  transition:
    transform 0.12s ease,
    box-shadow 0.12s ease,
    border-color 0.12s ease;
  position: relative;
}
.palette-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 14px rgba(16, 24, 40, 0.06);
  border-color: #e2ecff;
}

/* Teleport menu backdrop and panel (always above everything) */
.sb-menu-backdrop {
  position: fixed;
  inset: 0;
  z-index: 9998;
}
.sb-menu {
  position: fixed;
  z-index: 9999;
  min-width: 160px;
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 10px;
  box-shadow: 0 12px 32px rgba(16, 24, 40, 0.18);
  padding: 6px;
}
.sb-menu-item {
  display: block;
  width: 100%;
  text-align: left;
  background: none;
  border: 0;
  padding: 8px 10px;
  border-radius: 8px;
  font-size: 14px;
}
.sb-menu-item:hover {
  background: #f4f6fb;
}
</style>
