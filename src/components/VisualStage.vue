<template>
  <!-- canvas full screen overlay -->
  <div
    v-show="visible"
    class="vs-full"
    :class="{ 'has-blur': blur }"
    @click="hide"
  >
    <canvas ref="canvasRef" class="vs-canvas"></canvas>
    <button class="vs-close" @click.stop="hide" aria-label="Close">×</button>
  </div>
</template>

<script setup>
/**
 * Fullscreen music visualization component
 */
import { ref, onMounted, onBeforeUnmount, nextTick } from 'vue'

const props = defineProps({
  audioEl: { type: Object, required: true },
  autoShow: { type: Boolean, default: true },
  blur: { type: Boolean, default: true },
  colorMode: { type: String, default: 'rainbow' }
})

const visible = ref(false)
const canvasRef = ref(null)
let ctx = null

let audioNode = null
let audioCtx = null
let source = null
let analyser = null
let dataArray = null
let rafId = 0

// Random Color Cache
let randomHues = null

// Expose to the outside  show/hide
const show = async () => {
  if (visible.value) return
  visible.value = true
  await start()
}
const hide = () => {
  visible.value = false
  stop()
}
defineExpose({ show, hide })

// Event callback: Automatically show and hide based on audio
const onPlay = async () => {
  if (props.autoShow) await show()
  if (audioCtx && audioCtx.state === 'suspended') {
    try { await audioCtx.resume() } catch {}
  }
}
const onPause = () => { if (props.autoShow) hide() }
const onEnded = () => { if (props.autoShow) hide() }

onMounted(() => {
  audioNode = props.audioEl?.value || props.audioEl?.$el || props.audioEl
  if (!audioNode) return

  audioNode.addEventListener('play', onPlay)
  audioNode.addEventListener('pause', onPause)
  audioNode.addEventListener('ended', onEnded)

  window.addEventListener('resize', resizeCanvas, { passive: true })
})

onBeforeUnmount(() => {
  try {
    if (audioNode) {
      audioNode.removeEventListener('play', onPlay)
      audioNode.removeEventListener('pause', onPause)
      audioNode.removeEventListener('ended', onEnded)
    }
    window.removeEventListener('resize', resizeCanvas)
    stop()
    if (source) source.disconnect()
    if (analyser) analyser.disconnect()
    if (audioCtx) audioCtx.close()
  } catch {}
})

// === Visualization Core ===
const setupAnalyser = () => {
  if (!audioNode) return
  if (!audioCtx) audioCtx = new (window.AudioContext || window.webkitAudioContext)()
  if (!source) source = audioCtx.createMediaElementSource(audioNode)
  if (!analyser) {
    analyser = audioCtx.createAnalyser()
    analyser.fftSize = 256 // Frequency band resolution
    dataArray = new Uint8Array(analyser.frequencyBinCount)
    // Connection: source -> analyser -> destination
    source.connect(analyser)
    analyser.connect(audioCtx.destination)
  }
}

const start = async () => {
  setupAnalyser()
  // Wait until the DOM is actually displayed before 
  // measuring the size to avoid the fullscreen initial size being 0
  await nextTick()
  await new Promise(requestAnimationFrame)
  resizeCanvas()
  cancelAnimationFrame(rafId)
  draw(performance.now())
}

const stop = () => {
  cancelAnimationFrame(rafId)
}

// Color Picker
function colorForBar(i, barCount, v, t) {
  // v: 0~1 (energy), t: seconds
  const mode = props.colorMode || 'rainbow'
  if (mode === 'white') {
    const alpha = 0.6 + 0.4 * v
    return `rgba(255,255,255,${alpha.toFixed(3)})`
  }
  if (mode === 'random') {
    if (!randomHues || randomHues.length !== barCount) {
      randomHues = Array.from({ length: barCount }, () => Math.random() * 360)
    }
    const hue = randomHues[i]
    const sat = 72
    const light = 55 + 15 * (v * v) // Brightness fine-tuning with energy
    return `hsl(${hue.toFixed(1)} ${sat}% ${light.toFixed(1)}%)`
  }
  if (mode === 'hslCycle') {
    const base = (t * 40) % 360 // All bars slowly rotate hue together
    const hue = (base + i * (360 / barCount)) % 360
    const sat = 78
    const light = 50 + 20 * v
    return `hsl(${hue.toFixed(1)} ${sat}% ${light.toFixed(1)}%)`
  }
  // Gradient across the entire row, and shift it slightly over time
  const scroll = (t * 20) % 360
  const hue = (i / barCount) * 360 + scroll
  const sat = 80
  const light = 50 + 18 * v
  return `hsl(${hue.toFixed(1)} ${sat}% ${light.toFixed(1)}%)`
}

// rounded rectangle
function roundRect(ctx, x, y, w, h, r) {
  ctx.beginPath()
  ctx.moveTo(x + r, y)
  ctx.arcTo(x + w, y, x + w, y + h, r)
  ctx.arcTo(x + w, y + h, x, y + h, r)
  ctx.arcTo(x, y + h, x, y, r)
  ctx.arcTo(x, y, x + w, y, r)
  ctx.closePath()
}

// The canvas automatically adapts to DPR
const resizeCanvas = () => {
  const canvas = canvasRef.value
  if (!canvas) return
  const dpr = Math.min(window.devicePixelRatio || 1, 2)
  const w = Math.max(1, Math.floor(window.innerWidth * dpr))
  const h = Math.max(1, Math.floor(window.innerHeight * dpr))
  canvas.width = w
  canvas.height = h
  canvas.style.width = '100%'
  canvas.style.height = '100%'
  ctx = canvas.getContext('2d')
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0)
}

// Centered symmetrical spectrum: Based on the center line, it expands symmetrically up and down
const draw = (ts) => {
  const canvas = canvasRef.value
  if (!canvas || !ctx || !analyser || !dataArray) return

  const t = ts / 1000 // ms -> s
  const width = canvas.width
  const height = canvas.height

  // background
  ctx.clearRect(0, 0, width, height)
  const grad = ctx.createLinearGradient(0, 0, width, height)
  grad.addColorStop(0, 'rgba(255,255,255,0.06)')
  grad.addColorStop(1, 'rgba(0,0,0,0.06)')
  ctx.fillStyle = grad
  ctx.fillRect(0, 0, width, height)

  analyser.getByteFrequencyData(dataArray)

  const barCount = 64
  const step = Math.max(1, Math.floor(dataArray.length / barCount))
  const unit = width / barCount
  const barWidth = Math.max(4, unit * 0.66)

  const midY = height / 2
  const maxH = height * 0.7 // Maximum total height ratio
  const radius = Math.min(10, barWidth / 2)

  for (let i = 0; i < barCount; i++) {
    const raw = dataArray[i * step] / 255 // 0~1
    const v = Math.pow(raw, 0.85)
    const totalH = Math.max(6, v * maxH) // Total height
    const x = i * unit + (unit - barWidth) / 2
    const y = midY - totalH / 2 // Center the rectangle

    ctx.fillStyle = colorForBar(i, barCount, v, t)
    roundRect(ctx, x, y, barWidth, totalH, radius)
    ctx.fill()
  }

  rafId = requestAnimationFrame(draw)
}
</script>

<style scoped>
.vs-full {
  position: fixed;
  inset: 0;
  z-index: 10000;
  background: rgba(6, 8, 12, 0.55); /* Translucent curtain */
}
.vs-full.has-blur {
  backdrop-filter: blur(6px);
}

.vs-canvas {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  display: block;
}

.vs-close {
  position: absolute;
  top: 10px;
  right: 12px;
  padding: 2px 10px;
  font-size: 22px;
  line-height: 1;
  border: none;
  border-radius: 10px;
  color: #fff;
  background: rgba(0,0,0,0.35);
  cursor: pointer;
}
</style>
