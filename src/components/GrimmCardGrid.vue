<template>
  <div class="card card-tile p-4">
    <!-- 头部 -->
    <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-3">
      <h3 class="h6 mb-0">Grimm’s & Fairy Tales — Explore</h3>
      <div class="text-muted small">
        <template v-if="loaded"> Page {{ page }} · Page size 6 </template>
        <template v-else> Loading… </template>
      </div>
    </div>

    <!-- 固定高度网格框架 -->
    <div class="grid-frame position-relative">
      <!-- 居中加载提示 -->
      <div class="grid-loading" v-if="!loaded">
        <div class="text-muted">It’s loading…</div>
      </div>

      <!-- 始终渲染 6 个槽位 -->
      <div class="row g-4">
        <div v-for="(slot, idx) in slots6" :key="idx" class="col-12 col-md-6 col-lg-4">
          <!-- 有数据：正常卡片 -->
          <a
            v-if="slot"
            :href="bookLink(slot)"
            class="flip-card d-block text-decoration-none"
            target="_blank"
            rel="noopener noreferrer"
          >
            <div class="flip-card-inner">
              <!-- 正面 -->
              <div class="flip-card-face flip-card-front">
                <img
                  v-if="cover(slot)"
                  :src="cover(slot)"
                  class="w-100 rounded-top object-fit-cover"
                  style="height: 160px"
                  alt="cover"
                  loading="lazy"
                  width="480"
                  height="160"
                />
                <div class="p-3">
                  <h4 class="h6 text-dark mb-1 line-clamp-2">{{ slot.title }}</h4>
                  <div class="text-muted small">{{ authorLine(slot) }}</div>
                </div>
              </div>
              <!-- 背面 -->
              <div class="flip-card-face flip-card-back">
                <div class="p-3">
                  <div class="fw-semibold mb-2">{{ slot.title }}</div>
                  <p class="small mb-0 line-clamp-9">{{ summary(slot) }}</p>
                  <div class="text-primary small mt-2">Open to read →</div>
                </div>
              </div>
            </div>
          </a>

          <!-- 无数据：占位卡 -->
          <div v-else class="placeholder-card"></div>
        </div>
      </div>
    </div>

    <!-- 分页控制 -->
    <div class="d-flex align-items-center justify-content-between mt-4" v-if="loaded">
      <button
        class="btn btn-outline-secondary btn-sm"
        :disabled="page === 1 || loading"
        @click="prevPage"
      >
        Prev
      </button>

      <div class="text-muted small">Page {{ page }} · Page size 6</div>

      <button
        class="btn btn-outline-secondary btn-sm"
        :disabled="(!hasNextLocally && !nextUrl) || loading"
        @click="nextPage"
      >
        {{ nextButtonText }}
      </button>
    </div>

    <p v-if="error" class="text-danger small mt-3 mb-0">{{ error }}</p>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

// 初始查询（英文 fairy tales）
const API = 'https://gutendex.com/books/?search=fairy%20tales&languages=en'

const loading = ref(false)
const loaded = ref(false)
const error = ref('')
const books = ref([])
const nextUrl = ref(null)

const page = ref(1)
const pageSize = 6

const startIdx = computed(() => (page.value - 1) * pageSize)
const endIdx = computed(() => page.value * pageSize)

// 当前页的数据
const pageItems = computed(() => books.value.slice(startIdx.value, endIdx.value))

// 固定 6 槽位：有数据放书，无数据用 null 占位
const slots6 = computed(() => {
  const arr = [...pageItems.value]
  while (arr.length < pageSize) arr.push(null)
  return arr
})

const hasNextLocally = computed(() => endIdx.value < books.value.length)
const nextButtonText = computed(() =>
  hasNextLocally.value ? 'Next' : nextUrl.value ? 'Load more' : 'Next',
)

function authorLine(b) {
  if (!Array.isArray(b.authors) || b.authors.length === 0) return 'Unknown author'
  const a = b.authors[0]
  const years = a.birth_year && a.death_year ? ` (${a.birth_year}–${a.death_year})` : ''
  return `${a.name}${years}`
}
function summary(b) {
  return Array.isArray(b.summaries) && b.summaries[0]
    ? b.summaries[0]
    : 'No summary available. Click to open the full book.'
}
function cover(b) {
  return b.formats?.['image/jpeg'] || null
}
// ✅ 优先 .images（text/html），兜底 .htm（text/html; charset=utf-8）
function bookLink(b) {
  const fm = b.formats || {}
  return fm['text/html'] || fm['text/html; charset=utf-8'] || '#'
}

async function fetchUrl(url) {
  const r = await fetch(url)
  if (!r.ok) throw new Error('Status ' + r.status)
  return r.json()
}

async function loadInitial() {
  loading.value = true
  error.value = ''
  try {
    const j = await fetchUrl(API)
    books.value = Array.isArray(j.results) ? j.results : []
    nextUrl.value = j.next || null
    page.value = 1
    loaded.value = true
  } catch (e) {
    console.error(e)
    error.value = 'Failed to load open data from Gutendex. Please refresh.'
  } finally {
    loading.value = false
  }
}

async function loadMore() {
  if (!nextUrl.value) return
  loading.value = true
  try {
    const j = await fetchUrl(nextUrl.value)
    const more = Array.isArray(j.results) ? j.results : []
    books.value = books.value.concat(more)
    nextUrl.value = j.next || null
  } catch (e) {
    console.error(e)
    // 保持现状，用户可重试
  } finally {
    loading.value = false
  }
}

function prevPage() {
  if (page.value > 1) page.value -= 1
}
async function nextPage() {
  if (hasNextLocally.value) {
    page.value += 1
    return
  }
  if (nextUrl.value) {
    await loadMore()
    if (hasNextLocally.value) page.value += 1
  }
}

onMounted(loadInitial)
</script>

<style scoped>
/* 固定两行网格高度：2 * 卡片高度 + 行间距（g-4 ≈ 24px） */
.grid-frame {
  min-height: calc(2 * 280px + 24px);
  position: relative;
}

/* 居中加载提示（覆盖在网格上面） */
.grid-loading {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #fff; /* 或 rgba(255,255,255,.85) 半透明 */
  z-index: 1;
  border-radius: 12px;
}

/* 占位卡（与真实卡片尺寸一致） */
.placeholder-card {
  height: 280px;
  border: 1px dashed #e5e7eb;
  border-radius: 14px;
  background: repeating-linear-gradient(90deg, #f8fafc, #f8fafc 8px, #f1f5f9 8px, #f1f5f9 16px);
}

/* 翻转卡片 & 文字省略 */
.flip-card {
  perspective: 1000px;
}
.flip-card-inner {
  position: relative;
  width: 100%;
  height: 280px;
  border: 1px solid #edf1f7;
  border-radius: 14px;
  overflow: hidden;
  transition: transform 0.2s;
}
.flip-card:hover .flip-card-inner {
  transform: translateY(-3px);
}
.flip-card-face {
  position: absolute;
  inset: 0;
  backface-visibility: hidden;
  background: #fff;
  display: flex;
  flex-direction: column;
}
.flip-card-front {
  z-index: 2;
}
.flip-card-back {
  transform: rotateY(180deg);
  background: #f7fafc;
}
.flip-card:hover .flip-card-front {
  transform: rotateY(180deg);
}
.flip-card:hover .flip-card-back {
  transform: rotateY(0);
}

.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
.line-clamp-9 {
  display: -webkit-box;
  -webkit-line-clamp: 9;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
.object-fit-cover {
  object-fit: cover;
}
</style>
