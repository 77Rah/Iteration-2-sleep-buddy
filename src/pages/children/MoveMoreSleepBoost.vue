<template>
  <div class="winddown">
    <!-- Header: progress & routine controls -->
    <div class="header card border-0 rounded-4 shadow-sm">
      <div class="card-body d-flex flex-wrap align-items-center gap-3">
        <div class="ring-wrap" aria-label="Tonight's progress">
          <svg viewBox="0 0 120 120" class="ring">
            <circle cx="60" cy="60" r="50" class="ring-bg"/>
            <circle cx="60" cy="60" r="50" class="ring-fg"
                    :stroke-dasharray="circumference" :stroke-dashoffset="dashOffset"/>
            <text x="60" y="64" text-anchor="middle" class="ring-text">{{ completed }}/{{ goal }}</text>
          </svg>
          <div class="ring-caption">Tonight’s goal</div>
        </div>

        <div class="flex-grow-1">
          <h2 class="h5 mb-1">Wind-Down Moves</h2>
          <p class="text-muted mb-0">Gentle activities to help the body slow down for sleep.</p>

          <div class="mt-2 d-flex flex-wrap gap-2">
            <button class="btn btn-primary btn-sm" @click="makeRoutine">🎲 Pick 3 for me</button>
            <button class="btn btn-outline-secondary btn-sm" @click="resetNight">Reset tonight</button>

            <!-- Big Calm Points counter -->
            <div class="calm-points ms-auto align-self-center" :class="{ bump: bumpStar }" title="Calm points earned tonight">
              <div class="star-coin" aria-hidden="true">
                <svg viewBox="0 0 100 100">
                  <defs>
                    <radialGradient id="gold" cx="50%" cy="40%" r="60%">
                      <stop offset="0%" stop-color="#fff4c2"/>
                      <stop offset="100%" stop-color="#facc15"/>
                    </radialGradient>
                  </defs>
                  <circle cx="50" cy="50" r="46" fill="url(#gold)" stroke="#eab308" stroke-width="3"/>
                  <path d="M50 18l9.5 19.4 21.4 3.1-15.5 15.1 3.6 21.2L50 67.5 31 77.8l3.6-21.2L19 40.5l21.4-3.1z"
                        fill="#fde047" stroke="#f59e0b" stroke-width="2"/>
                </svg>
              </div>
              <div class="cp-info">
                <div class="cp-label">Calm Points</div>
                <div class="cp-count">{{ points }}</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Routine strip -->
    <div v-if="routineIds.length" class="routine card border-0 rounded-4 shadow-sm mt-3">
      <div class="card-body d-flex align-items-center gap-2 flex-wrap">
        <strong class="me-1">Tonight’s routine:</strong>
        <template v-for="(id, i) in routineIds" :key="id">
          <button class="chip" :class="{done: byId(id).done, active: activeId === id}" @click="scrollToCard(id)">
            {{ byId(id).title }} <span v-if="byId(id).done">✔</span>
          </button>
          <span v-if="i < routineIds.length - 1" class="sep">›</span>
        </template>
        <button class="btn btn-success btn-sm ms-auto" @click="startRoutine">Start</button>
      </div>
    </div>

    <!-- Cards grid (thumbnails kept small & simple) -->
    <div class="row g-3 mt-3">
      <div class="col-md-4" v-for="a in activities" :key="a.id" :id="'card-'+a.id">
        <div class="card h-100 rounded-4 border-0 card-activity">
          <div class="card-body d-flex flex-column">
            <div class="img-wrap mb-2" aria-hidden="true">
              <img class="guide-img" :src="imgSrc(a.img)" :alt="a.title" />
            </div>
            <h3 class="h6 mb-1">{{ a.title }}</h3>
            <ul class="small text-muted mb-3 ps-3">
              <li v-for="(s, i) in a.steps" :key="i">{{ s }}</li>
            </ul>

            <div class="mt-auto d-flex gap-2 align-items-center">
              <button class="btn btn-success btn-sm" @click="startTimer(a)">▶ Start {{ a.mins }}m</button>
              <button class="btn btn-outline-secondary btn-sm" @click="markDone(a)" :disabled="a.done">
                {{ a.done ? "Done ✔" : "Mark done" }}
              </button>
              <span class="badge bg-light text-dark ms-auto">{{ a.mins }} min</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- FOCUS PANEL (XL portrait PNG + big timer) -->
    <div v-if="activeTimer" class="focus-overlay" role="dialog" aria-modal="true">
      <div class="focus-card rounded-4 shadow-lg">
        <button class="focus-close" @click="cancelTimer" aria-label="Close">✕</button>

        <div class="focus-grid">
          <!-- Much larger portrait area -->
          <div class="focus-illustration">
            <img class="focus-img" :src="imgSrc(activeTimer.img)" :alt="activeTimer.title" />
          </div>

          <div class="focus-body">
            <h3 class="h5 mb-2">{{ activeTimer.title }}</h3>
            <ol class="steps"><li v-for="(s, i) in activeTimer.steps" :key="i">{{ s }}</li></ol>

            <div class="focus-controls">
              <div class="timer-ring">
                <svg viewBox="0 0 100 100" class="t-ring">
                  <circle cx="50" cy="50" r="44" class="t-ring-bg"/>
                  <circle cx="50" cy="50" r="44" class="t-ring-fg"
                          :stroke-dasharray="tCircumference" :stroke-dashoffset="tDashOffset"/>
                  <text x="50" y="56" text-anchor="middle" class="t-ring-text">{{ displayTime }}</text>
                </svg>
              </div>

              <div class="btn-stack">
                <button class="btn btn-outline-dark" @click="pauseResume">{{ paused ? 'Resume' : 'Pause' }}</button>
                <button class="btn btn-success" @click="finishActivity(activeTimer)">Done</button>
                <button v-if="nextInRoutine" class="btn btn-primary" @click="goNext()">Next › {{ byId(nextInRoutine).title }}</button>
              </div>
            </div>
          </div>
        </div>

        <small class="muted mt-2 d-block text-center">Follow the picture while the timer counts down.</small>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "MoveMoreSleepBoost",
  data() {
    return {
      activities: [
        { id: 1, img: 'balloon',   title: "Balloon Breaths",   mins: 2, steps: ["Hands on belly. Breathe in for 4 like inflating a balloon.","Hold for 2. Breathe out for 4. Repeat slowly."], done: false },
        { id: 2, img: 'turtle',    title: "Slow Turtle Walk",   mins: 3, steps: ["Walk very slowly from wall to wall.","Quiet feet. Count 10 turtle steps."], done: false },
        { id: 3, img: 'catcow',    title: "Cat–Cow Stretch",    mins: 2, steps: ["Hands & knees. Arch up like a cat.","Look up, drop belly like a cow. Move slowly."], done: false },
        { id: 4, img: 'teddy',     title: "Teddy Squeeze",      mins: 3, steps: ["Lie down. Hug a teddy or pillow.","Count 20 calm breaths together."], done: false },
        { id: 5, img: 'starfish',  title: "Starfish Breathing", mins: 2, steps: ["Spread fingers like a starfish.","Trace each finger: in up, out down."], done: false },
        { id: 6, img: 'wallpush',  title: "Wall Push",          mins: 2, steps: ["Hands on the wall, feet back a little.","Push slowly for 10, relax for 10."], done: false },
        { id: 7, img: 'cloudcount',title: "Cloud Count",        mins: 2, steps: ["Lie comfy. Imagine fluffy clouds.","Count slowly from 1 to 20."], done: false }
      ],
      goal: 3,
      points: 0,
      activeTimer: null,
      remaining: 0,
      tick: null,
      paused: false,
      routineIds: [],
      activeId: null,
      imageBase: '/winddown/',  // served from /public/winddown
      imageExt: '.png',
      bumpStar: false           // for Calm Points pulse
    };
  },
  computed: {
    completed() { return this.activities.filter(a => a.done).length; },
    circumference() { return 2 * Math.PI * 50; },
    dashOffset() { const pct = Math.min(this.completed / this.goal, 1); return this.circumference * (1 - pct); },
    tCircumference() { return 2 * Math.PI * 44; },
    tDashOffset() {
      if (!this.activeTimer) return this.tCircumference;
      const pct = Math.max(0, this.remaining) / (this.activeTimer.mins * 60);
      return this.tCircumference * pct;
    },
    displayTime() {
      const s = Math.max(0, this.remaining);
      const m = Math.floor(s / 60).toString();
      const ss = (s % 60).toString().padStart(2, '0');
      return `${m}:${ss}`;
    },
    nextInRoutine() {
      if (!this.activeTimer) return null;
      const idx = this.routineIds.indexOf(this.activeTimer.id);
      return this.routineIds[idx + 1] || null;
    }
  },
  watch: {
    points(n, o) {
      if (n > o) {
        this.bumpStar = true;
        clearTimeout(this._bp);
        this._bp = setTimeout(() => (this.bumpStar = false), 450);
      }
    }
  },
  methods: {
    byId(id) { return this.activities.find(a => a.id === id); },

    imgSrc(key) { return `${this.imageBase}${key}${this.imageExt}`; },

    // Timer/gameplay
    startTimer(a) { this.cancelTimer(); this.activeTimer = a; this.activeId = a.id; this.remaining = a.mins * 60; this.paused = false; this.tick = setInterval(this._tickFn, 1000); },
    _tickFn() { if (this.paused) return; this.remaining -= 1; if (this.remaining <= 0) this.finishActivity(this.activeTimer); },
    pauseResume() { this.paused = !this.paused; },
    cancelTimer() { if (this.tick) clearInterval(this.tick); this.tick = null; this.activeTimer = null; this.remaining = 0; this.paused = false; },

    markDone(a) { if (a.done) return; a.done = true; this.points += 1; this.saveNight(); },
    finishActivity(a) { this.markDone(a); if (this.nextInRoutine) { const next = this.byId(this.nextInRoutine); this.startTimer(next); } else { this.cancelTimer(); } },
    goNext() { if (!this.nextInRoutine) return; const next = this.byId(this.nextInRoutine); this.startTimer(next); this.scrollToCard(next.id); },

    makeRoutine() { const shuffled = [...this.activities].sort(() => Math.random() - 0.5); this.routineIds = shuffled.slice(0, 3).map(a => a.id); this.activeId = null; },
    startRoutine() { if (!this.routineIds.length) return; const first = this.byId(this.routineIds[0]); this.startTimer(first); this.scrollToCard(first.id); },
    scrollToCard(id) { const el = document.getElementById('card-' + id); if (el) el.scrollIntoView({ behavior: 'smooth', block: 'center' }); },

    resetNight() { this.activities.forEach(a => (a.done = false)); this.points = 0; this.cancelTimer(); this.routineIds = []; this.activeId = null; localStorage.removeItem('sleepboost-night'); },
    saveNight() { const data = { date: new Date().toISOString().slice(0, 10), doneIds: this.activities.filter(a => a.done).map(a => a.id), points: this.points }; localStorage.setItem('sleepboost-night', JSON.stringify(data)); },
    loadNight() { const raw = localStorage.getItem('sleepboost-night'); if (!raw) return; try { const d = JSON.parse(raw); const today = new Date().toISOString().slice(0, 10); if (d.date !== today) return; this.points = d.points || 0; (d.doneIds || []).forEach(id => { const a = this.byId(id); if (a) a.done = true; }); } catch {} }
  },
  mounted() { this.loadNight(); },
  beforeUnmount() { this.cancelTimer(); }
};
</script>

<style scoped>
.winddown { --soft-1:#f3f9ff; --soft-2:#fffdf7; }

/* Activity cards (keep thumbnails small like before) */
.card-activity { background: var(--soft-2); }
.img-wrap {
  height: 120px;
  display:grid; place-items:center;
  background:#fff;
  border-radius: 16px;
  overflow: hidden;
}
.guide-img { width: 100%; max-width: 240px; height: 120px; object-fit: contain; }

/* Header ring */
.ring-wrap { width: 120px; text-align: center; }
.ring { width: 120px; height: 120px; }
.ring-bg { fill: none; stroke: #e9ecef; stroke-width: 10; }
.ring-fg { fill: none; stroke:#0d6efd; stroke-linecap: round; stroke-width: 10; transform: rotate(-90deg); transform-box: fill-box; transform-origin: 50% 50%; transition: stroke-dashoffset .4s ease; }
.ring-text { font-size: 20px; font-weight: 800; fill:#212529; }
.ring-caption { font-size: .8rem; color:#6c757d; margin-top:.25rem; }

/* Calm Points counter */
.calm-points{
  display:flex; align-items:center; gap:.6rem;
  padding:.5rem .75rem; border-radius:16px;
  background:#ffffff; border:1px solid #e6eef7;
  box-shadow:0 2px 0 #e6eef7;
}
.calm-points.bump{ animation: cpBump .45s ease; }
@keyframes cpBump{ 0%{transform:scale(1)} 40%{transform:scale(1.06)} 100%{transform:scale(1)} }

.star-coin{ width:58px; height:58px; flex:0 0 auto; }
.star-coin svg{ width:58px; height:58px; display:block; }

.cp-info{ display:flex; flex-direction:column; line-height:1; }
.cp-label{ font-weight:800; color:#6b7280; }
.cp-count{
  margin-top:.15rem;
  font-size:1.8rem; font-weight:900; color:#b45309;
  background:#fff1a6; border:2px solid #f59e0b; border-radius:12px;
  padding:.05rem .5rem; box-shadow:0 2px 0 #f59e0b33;
}

/* Routine chips */
.chip { background:#eef6ff; border:2px solid #cfe5ff; border-radius:999px; padding:.35rem .7rem; font-weight:700; color:#0b5ed7; }
.chip.active { background:#0d6efd; border-color:#0d6efd; color:#fff; }
.chip.done { background:#d1f7e9; border-color:#8ce0c3; color:#138a5e; }
.sep { color:#adb5bd; }

/* Focus overlay */
.focus-overlay { position: fixed; inset: 0; background: rgba(9,20,40,.35); display: grid; place-items: center; padding: 16px; z-index: 30; }
.focus-card { background: #ffffff; width: min(1080px, 96vw); padding: 18px 18px 12px; position: relative; }
.focus-close { position: absolute; top: 8px; right: 10px; border:0; background:#fff; width: 36px; height: 36px; border-radius: 999px; box-shadow: 0 2px 6px rgba(0,0,0,.12); }

.focus-grid { display: grid; gap: 18px; grid-template-columns: 1.2fr 1fr; }
@media (max-width: 900px) { .focus-grid { grid-template-columns: 1fr; } }

/* XL portrait area in overlay (bigger for tall images) */
.focus-illustration {
  background: #f8fbff; border: 1px solid #e6eef8; border-radius: 16px;
  display: grid; place-items: center; min-height: 480px;
}
.focus-img { width: 100%; max-width: 720px; height: 460px; object-fit: contain; }
@media (max-width: 900px){
  .focus-illustration{ min-height: 380px; }
  .focus-img{ height: 360px; max-width: 560px; }
}

.focus-body .steps { margin: 0 0 12px 1rem; }
.focus-controls { display: grid; grid-template-columns: auto 1fr; gap: 16px; align-items: center; }
.btn-stack { display: grid; gap: 8px; grid-auto-rows: minmax(38px, auto); }
.muted { color:#6c757d; }

/* Big timer ring */
.timer-ring { width: 160px; height: 160px; }
.t-ring { width: 160px; height: 160px; }
.t-ring-bg { fill: none; stroke: #e9ecef; stroke-width: 10; }
.t-ring-fg { fill: none; stroke:#2b8a3e; stroke-linecap: round; stroke-width: 10; transform: rotate(-90deg); transform-box: fill-box; transform-origin: 50% 50%; transition: stroke-dashoffset .6s linear; }
.t-ring-text { font-size: 24px; font-weight: 800; fill:#2b8a3e; }
</style>
