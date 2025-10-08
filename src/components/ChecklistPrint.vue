<template>
  <div class="card p-3">
    <div class="d-flex align-items-center justify-content-between mb-2">
      <h3 class="h6 mb-0">Printable Checklist</h3>
      <div class="d-flex gap-2">
        <button class="btn btn-outline-secondary btn-sm" @click="reload">Refresh</button>
        <button class="btn btn-primary btn-sm" :disabled="items.length === 0" @click="printPdf">
          Print as PDF
        </button>
      </div>
    </div>

    <p class="text-muted small mb-3">
      This uses your browser’s Print dialog. Choose “Save as PDF” to export a file.
    </p>

    <div class="preview border rounded p-3">
      <div class="d-flex align-items-center justify-content-between mb-2">
        <div class="fw-semibold">Preview</div>
        <small class="text-muted">{{ today }}</small>
      </div>

      <div v-if="items.length === 0" class="text-muted small">
        No items found. Build your checklist first in “Bedtime Routine Coach”.
      </div>

      <ul v-else class="list-unstyled mb-0">
        <li v-for="it in items" :key="it.uid" class="d-flex align-items-start py-2 border-bottom">
          <span class="me-2">☐</span>
          <div>
            <div class="fw-semibold">{{ it.title }}</div>
            <div v-if="it.note" class="small text-muted">{{ it.note }}</div>
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup>
// ChecklistPrint – auto-refreshes when RoutineBuilder broadcasts "routine-updated".
// Reads localStorage('sleepbuddy_routine_v1') and prints via window.print().

import { ref, onMounted, onUnmounted, computed } from 'vue'

const LS_ROUTINE = 'sleepbuddy_routine_v1'
const items = ref([])

/* Load from localStorage */
function load() {
  try {
    const raw = localStorage.getItem(LS_ROUTINE)
    items.value = raw ? JSON.parse(raw) : []
  } catch {
    items.value = []
  }
}
function reload() {
  load()
}

/* Subscribe to "routine-updated" custom event (dispatched by RoutineBuilder) */
function onRoutineUpdated() {
  load()
}

onMounted(() => {
  load()
  window.addEventListener('routine-updated', onRoutineUpdated)
})
onUnmounted(() => {
  window.removeEventListener('routine-updated', onRoutineUpdated)
})

/* Formatted date */
const today = computed(() => {
  const d = new Date()
  return d.toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' })
})

/* Printable window */
function printPdf() {
  if (items.value.length === 0) {
    alert('Checklist is empty. Please add items first.')
    return
  }
  const html = buildPrintableHtml(items.value)
  const w = window.open('', 'printwin', 'width=900,height=1000')
  if (!w) {
    alert('Popup blocked. Please allow popups to print.')
    return
  }
  w.document.open()
  w.document.write(html)
  w.document.close()
  w.onload = () => {
    w.focus()
    w.print()
    setTimeout(() => {
      try {
        w.close()
      } catch {}
    }, 500)
  }
}

/* Build minimal printable HTML */
function buildPrintableHtml(list) {
  const rows = list
    .map((it) => {
      const note = it.note ? `<div class="note">${escapeHtml(it.note)}</div>` : ''
      return `
      <li class="item">
        <span class="box">☐</span>
        <div class="text">
          <div class="title">${escapeHtml(it.title)}</div>
          ${note}
        </div>
      </li>`
    })
    .join('')

  return `<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>SleepBuddy – Bedtime Checklist</title>
<style>
  * { box-sizing: border-box; }
  body { font: 14px/1.5 -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,"Noto Sans";
         color:#111827; margin:24px; }
  .header { display:flex; align-items:baseline; justify-content:space-between; margin-bottom:16px; }
  .title { font-size:18px; font-weight:700; }
  .date { color:#6b7280; font-size:12px; }
  .list { list-style:none; padding:0; margin:0; border:1px solid #e5e7eb; border-radius:12px; }
  .item { display:flex; gap:10px; padding:10px 12px; border-bottom:1px solid #f1f5f9; }
  .item:last-child { border-bottom:none; }
  .box { font-size:18px; line-height:1.2; color:#64748b; }
  .text .title { font-size:14px; font-weight:600; }
  .note { font-size:12px; color:#6b7280; margin-top:2px; }
  @page { margin: 16mm; }
  @media print { body { margin: 0; } }
</style>
</head>
<body>
  <div class="header">
    <div class="title">SleepBuddy – Bedtime Checklist</div>
    <div class="date">${escapeHtml(today.value)}</div>
  </div>
  <ul class="list">
    ${rows || '<li class="item"><div class="text"><div class="title">No items</div></div></li>'}
  </ul>
</body>
</html>`
}

/* Simple HTML escape */
function escapeHtml(s) {
  return String(s).replace(
    /[&<>"']/g,
    (ch) =>
      ({
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#39;',
      })[ch],
  )
}
</script>

<style scoped>
.preview {
  background: #fff;
}
.preview .item:last-child {
  border-bottom: none;
}
</style>
