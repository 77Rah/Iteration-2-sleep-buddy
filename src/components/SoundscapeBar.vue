<template>
  <div class="card p-4 mx-auto">
    <div class="d-flex align-items-center justify-content-between mb-3">
      <h3 class="h6 mb-0">Soundscapes</h3>
      <div class="text-muted small">Pick one background sound</div>
    </div>

    <!-- 3×2 grid -->
    <div class="row g-3">
      <div v-for="t in tracks" :key="t.id" class="col-12 col-md-6 col-lg-4">
        <button
          class="tile w-100 text-start"
          :class="{ active: currentId === t.id }"
          @click="toggleTrack(t)"
        >
          <div class="d-flex align-items-center gap-3">
            <div class="emoji">{{ t.emoji }}</div>
            <div class="flex-grow-1">
              <div class="title">{{ t.title }}</div>
              <div class="subtitle">{{ t.subtitle }}</div>
            </div>
            <div class="state ms-auto">
              <span v-if="currentId === t.id && isPlaying">⏸</span>
              <span v-else>▶️</span>
            </div>
          </div>
        </button>
      </div>
    </div>

    <!-- Controls -->
    <div class="d-flex align-items-center gap-3 mt-4 flex-wrap">
      <button class="btn btn-outline-secondary btn-sm" @click="stopAll" :disabled="!currentId">
        Stop
      </button>
      <div class="d-flex align-items-center gap-2">
        <label class="small text-muted">Volume</label>
        <input
          type="range"
          min="0"
          max="1"
          step="0.01"
          v-model.number="volume"
          style="width: 160px"
        />
        <span class="small text-muted">{{ Math.round(volume * 100) }}%</span>
      </div>
      <div class="form-check ms-auto">
        <input class="form-check-input" type="checkbox" id="loop" v-model="loop" />
        <label class="form-check-label small" for="loop">Loop</label>
      </div>
    </div>
  </div>

  <!-- Stage background visualization layer-->
  <VisualStage :audio-el="audio" :auto-show="true" :blur="true" />

</template>

<script setup>
// Single-Audio player with 6 selectable tracks (looping)
import { ref, watch, onBeforeUnmount } from 'vue'
import VisualStage from '@/components/VisualStage.vue'

// Map your files placed under /public/audio/
const tracks = [
  {
    id: 'rain',
    title: 'Rain',
    subtitle: 'steady rainfall',
    file: '/audio/sleepy-rain.mp3',
    emoji: '🌧️',
  },
  {
    id: 'piano',
    title: 'Soft Piano',
    subtitle: 'gentle keys',
    file: '/audio/sleepy-piano.mp3',
    emoji: '🎹',
  },
  {
    id: 'marimba',
    title: 'Marimba Chimes',
    subtitle: 'soft percussive',
    file: '/audio/sleepy-arimba.mp3',
    emoji: '🪘',
  },
  {
    id: 'night',
    title: '9PM Night',
    subtitle: 'calm night air',
    file: '/audio/sleepy-9pm.mp3',
    emoji: '🌙',
  },
  {
    id: 'med',
    title: 'Meditation Pad',
    subtitle: 'warm drone',
    file: '/audio/sleepy-meditation.mp3',
    emoji: '🧘',
  },
  {
    id: 'relax',
    title: 'Deep Relax',
    subtitle: 'slow ambience',
    file: '/audio/sleepy-rerlax.mp3',
    emoji: '😴',
  },
]

const audio = new Audio()
audio.preload = 'auto'

const currentId = ref('')
const isPlaying = ref(false)
const volume = ref(0.5)
const loop = ref(true)

audio.loop = loop.value
audio.volume = volume.value

watch(volume, (v) => {
  audio.volume = v
})
watch(loop, (v) => {
  audio.loop = v
})

function playTrack(t) {
  if (!t) return
  // if switching track
  if (currentId.value !== t.id) {
    currentId.value = t.id
    audio.src = t.file
  }
  audio.loop = loop.value
  audio.volume = volume.value
  audio
    .play()
    .then(() => {
      isPlaying.value = true
    })
    .catch(() => {
      // autoplay may be blocked; user must click again
      isPlaying.value = false
    })
}

function pause() {
  audio.pause()
  isPlaying.value = false
}

function stopAll() {
  audio.pause()
  audio.currentTime = 0
  isPlaying.value = false
  currentId.value = ''
}

function toggleTrack(t) {
  // same track: toggle play/pause
  if (currentId.value === t.id) {
    isPlaying.value ? pause() : playTrack(t)
  } else {
    playTrack(t)
  }
}

// keep UI in sync when user pauses via system controls
audio.addEventListener('pause', () => {
  isPlaying.value = false
})
audio.addEventListener('play', () => {
  isPlaying.value = true
})

onBeforeUnmount(() => {
  audio.pause()
})
</script>

<style scoped>
.tile {
  border: 1px solid #edf1f7;
  border-radius: 14px;
  padding: 14px 16px;
  background: #fff;
  transition:
    transform 0.15s ease,
    box-shadow 0.15s ease,
    border-color 0.15s ease;
}
.tile:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 14px rgba(16, 24, 40, 0.06);
}
.tile.active {
  border-color: #cfe3ff;
  box-shadow: 0 8px 18px rgba(88, 133, 255, 0.12);
  background: linear-gradient(180deg, #f7fbff 0%, #ffffff 60%);
}
.emoji {
  font-size: 28px;
  width: 36px;
  text-align: center;
}
.title {
  font-weight: 600;
  line-height: 1.1;
}
.subtitle {
  font-size: 12px;
  color: #6b7280;
}
.state {
  font-size: 18px;
  opacity: 0.8;
}
</style>
