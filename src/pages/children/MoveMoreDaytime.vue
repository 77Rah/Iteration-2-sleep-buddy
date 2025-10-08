<template>
  <div class="dayenergy">
    <!-- Header: progress & routine controls -->
    <div class="header card border-0 rounded-4 shadow-sm">
      <div class="card-body d-flex flex-wrap align-items-center gap-3">
        <!-- Progress ring -->
        <div class="ring-wrap" aria-label="Today's progress">
          <svg viewBox="0 0 120 120" class="ring">
            <circle cx="60" cy="60" r="50" class="ring-bg"/>
            <circle cx="60" cy="60" r="50" class="ring-fg"
                    :stroke-dasharray="circumference" :stroke-dashoffset="dashOffset"/>
            <text x="60" y="64" text-anchor="middle" class="ring-text">{{ completed }}/{{ goal }}</text>
          </svg>
          <div class="ring-caption">Today’s goal</div>
        </div>

        <!-- Title + buttons -->
        <div class="flex-grow-1">
          <h2 class="h5 mb-1">Daytime Energy Quests</h2>
          <p class="text-muted mb-0">Fun movement bursts to use up energy and sleep better tonight.</p>

          <div class="mt-2 d-flex flex-wrap gap-2">
            <button class="btn btn-primary btn-sm" @click="makeRoutine">🎲 Pick 4 for me</button>
            <button class="btn btn-outline-secondary btn-sm" @click="resetToday">Reset today</button>
          </div>
        </div>

        <!-- ⚡ Energy Points -->
        <div class="energy ms-auto align-self-center" :class="{ bump: bumpBolt }" title="Energy points earned today">
          <div class="bolt-coin" aria-hidden="true">
            <svg viewBox="0 0 100 100">
              <defs>
                <radialGradient id="sun" cx="50%" cy="40%" r="60%">
                  <stop offset="0%" stop-color="#fff3b0"/><stop offset="100%" stop-color="#fde047"/>
                </radialGradient>
              </defs>
              <circle cx="50" cy="50" r="46" fill="url(#sun)" stroke="#f59e0b" stroke-width="3"/>
              <path d="M56 12 28 56h18l-2 32 30-48H56z" fill="#fb923c" stroke="#ea580c" stroke-width="2"/>
            </svg>
          </div>
          <div class="e-info">
            <div class="e-label">Energy Points</div>
            <div class="e-count">{{ points }}</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Routine strip -->
    <div v-if="routineIds.length" class="routine card border-0 rounded-4 shadow-sm mt-3">
      <div class="card-body d-flex align-items-center gap-2 flex-wrap">
        <strong class="me-1">Today’s routine:</strong>
        <template v-for="(id, i) in routineIds" :key="id">
          <button class="chip" :class="{done: byId(id).done, active: activeId === id}" @click="scrollToCard(id)">
            {{ byId(id).title }} <span v-if="byId(id).done">✔</span>
          </button>
          <span v-if="i < routineIds.length - 1" class="sep">›</span>
        </template>
        <button class="btn btn-success btn-sm ms-auto" @click="startRoutine">Start</button>
      </div>
    </div>

    <!-- Cards grid -->
    <div class="row g-3 mt-3">
      <div class="col-md-4" v-for="a in activities" :key="a.id" :id="'card-'+a.id">
        <div class="card h-100 rounded-4 border-0 card-activity">
          <div class="card-body d-flex flex-column">
            <!-- REVERTED: small, non-clickable image area -->
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

    <!-- FOCUS PANEL (XL PNG + big timer) -->
    <div v-if="activeTimer" class="focus-overlay" role="dialog" aria-modal="true">
      <div class="focus-card rounded-4 shadow-lg">
        <button class="focus-close" @click="cancelTimer" aria-label="Close">✕</button>

        <div class="focus-grid">
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
                <button v-if="nextInRoutine" class="btn btn-warning text-dark" @click="goNext()">Next › {{ byId(nextInRoutine).title }}</button>
              </div>
            </div>
          </div>
        </div>

        <small class="muted mt-2 d-block text-center">Move with the picture while the timer counts down.</small>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "MoveMoreDaytime",
  data() {
    return {
      activities: [
        // Use PNGs in /public/winddown/<key>.png
        { id: 1,  img: 'rocket-jumps',      title: "Rocket Jumps",        mins: 3, steps: ["Reach high like a rocket.","Jump up, land soft with bent knees.","Count 10 rockets, rest, repeat."], done: false },
        { id: 2,  img: 'animal-parade',     title: "Animal Parade",       mins: 3, steps: ["Walk like a bear (hands + feet).","Then waddle like a penguin.","Finish with 10 tiny mouse steps!"], done: false },
        { id: 3,  img: 'crab-crawl',        title: "Crab Crawl Challenge",mins: 3, steps: ["Sit, hands behind, lift hips.","Walk forward & backward.","Try a circle around the room."], done: false },
        { id: 4,  img: 'superhero-lunges',  title: "Superhero Lunges",    mins: 3, steps: ["Big step forward, bend knees.","Switch legs with a hero pose.","Add a gentle twist each time."], done: false },
        { id: 5,  img: 'rainbow-skips',     title: "Rainbow Skips",       mins: 3, steps: ["Skip in a big rainbow arc.","Arms paint the sky!","Skip back the other way."], done: false },
        { id: 6,  img: 'balloon-keepup',    title: "Balloon Keep-Up",     mins: 3, steps: ["Tap a balloon so it won’t fall.","Add claps between taps!","Count your longest streak."], done: false },
        { id: 7,  img: 'zigzag-dash',       title: "Zigzag Dash",         mins: 3, steps: ["Line up 4 pillows/cones.","Weave zigzag to the end.","Dash back with a smile!"], done: false },
        { id: 8,  img: 'freeze-dance',      title: "Freeze Dance",        mins: 3, steps: ["Play a short song.","Dance! When music stops—freeze!","Start again with a new move."], done: false },
        { id: 9,  img: 'balance-ninja',     title: "Balance Ninja",       mins: 2, steps: ["Heel-to-toe along a line.","Arms wide, quiet steps.","Can you go backwards?"], done: false },
        { id:10,  img: 'animal-hops',       title: "Bunny & Frog Hops",   mins: 3, steps: ["Small bunny hops forward.","Big frog jumps with hands down.","Hop back like a kangaroo."], done: false },
        { id:11,  img: 'mountain-climbers', title: "Mini Mountain Climbers", mins: 2, steps: ["Plank hands under shoulders.","Drive one knee then the other.","10 slow, 10 medium, 10 fast!"], done: false },
        { id:12,  img: 'sun-salute',        title: "Sun-Salute Flow",     mins: 3, steps: ["Reach up high to the sun.","Fold, step back, gentle cobra.","Step in, stand tall & shine."], done: false }
      ],
      goal: 4,
      points: 0,
      activeTimer: null,
      remaining: 0,
      tick: null,
      paused: false,
      routineIds: [],
      activeId: null,
      imageBase: '/winddown/',
      imageExt: '.png',
      bumpBolt: false
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
        this.bumpBolt = true;
        clearTimeout(this._eb);
        this._eb = setTimeout(() => (this.bumpBolt = false), 450);
      }
    }
  },
  methods: {
    byId(id) { return this.activities.find(a => a.id === id); },

    // PNG image helper
    imgSrc(key) { return `${this.imageBase}${key}${this.imageExt}`; },

    // Timer/gameplay
    startTimer(a) {
      this.cancelTimer();
      this.activeTimer = a;
      this.activeId = a.id;
      this.remaining = a.mins * 60;
      this.paused = false;
      this.tick = setInterval(this._tickFn, 1000);
    },
    _tickFn() {
      if (this.paused) return;
      this.remaining -= 1;
      if (this.remaining <= 0) this.finishActivity(this.activeTimer);
    },
    pauseResume() { this.paused = !this.paused; },
    cancelTimer() {
      if (this.tick) clearInterval(this.tick);
      this.tick = null; this.activeTimer = null; this.remaining = 0; this.paused = false;
    },

    markDone(a) {
      if (a.done) return;
      a.done = true;
      this.points += 1;
      this.saveToday();
    },
    finishActivity(a) {
      this.markDone(a);
      if (this.nextInRoutine) {
        const next = this.byId(this.nextInRoutine);
        this.startTimer(next);
      } else {
        this.cancelTimer();
      }
    },
    goNext() {
      if (!this.nextInRoutine) return;
      const next = this.byId(this.nextInRoutine);
      this.startTimer(next);
      this.scrollToCard(next.id);
    },

    // Routine helpers
    makeRoutine() {
      const shuffled = [...this.activities].sort(() => Math.random() - 0.5);
      this.routineIds = shuffled.slice(0, 4).map(a => a.id);
      this.activeId = null;
    },
    startRoutine() {
      if (!this.routineIds.length) return;
      const first = this.byId(this.routineIds[0]);
      this.startTimer(first);
      this.scrollToCard(first.id);
    },
    scrollToCard(id) {
      const el = document.getElementById('card-' + id);
      if (el) el.scrollIntoView({ behavior: 'smooth', block: 'center' });
    },

    // Persistence (per day)
    resetToday() {
      this.activities.forEach(a => (a.done = false));
      this.points = 0; this.cancelTimer(); this.routineIds = []; this.activeId = null;
      localStorage.removeItem('dayenergy');
    },
    saveToday() {
      const data = {
        date: new Date().toISOString().slice(0, 10),
        doneIds: this.activities.filter(a => a.done).map(a => a.id),
        points: this.points
      };
      localStorage.setItem('dayenergy', JSON.stringify(data));
    },
    loadToday() {
      const raw = localStorage.getItem('dayenergy'); if (!raw) return;
      try {
        const d = JSON.parse(raw);
        const today = new Date().toISOString().slice(0, 10);
        if (d.date !== today) return;
        this.points = d.points || 0;
        (d.doneIds || []).forEach(id => { const a = this.byId(id); if (a) a.done = true; });
      } catch {}
    }
  },
  mounted() { this.loadToday(); },
  beforeUnmount() { this.cancelTimer(); }
};
</script>

<style scoped>
.dayenergy { --soft-1:#fffaf0; --soft-2:#fffdf7; }

/* Progress ring */
.ring-wrap { width: 120px; text-align: center; }
.ring { width: 120px; height: 120px; }
.ring-bg { fill: none; stroke: #e9ecef; stroke-width: 10; }
.ring-fg { fill: none; stroke:#f59e0b; stroke-linecap: round; stroke-width: 10; transform: rotate(-90deg); transform-box: fill-box; transform-origin: 50% 50%; transition: stroke-dashoffset .4s ease; }
.ring-text { font-size: 20px; font-weight: 800; fill:#1f2937; }
.ring-caption { font-size: .8rem; color:#6b7280; margin-top:.25rem; }

/* Energy Points */
.energy{
  display:flex; align-items:center; gap:.6rem;
  padding:.5rem .75rem; border-radius:16px;
  background:#ffffff; border:1px solid #ffe9c2;
  box-shadow:0 2px 0 #ffe9c2;
}
.energy.bump{ animation: eBump .45s ease; }
@keyframes eBump{ 0%{transform:scale(1)} 40%{transform:scale(1.06)} 100%{transform:scale(1)} }

.bolt-coin{ width:58px; height:58px; flex:0 0 auto; }
.bolt-coin svg{ width:58px; height:58px; display:block; }

.e-info{ display:flex; flex-direction:column; line-height:1; }
.e-label{ font-weight:800; color:#9a6b2e; }
.e-count{
  margin-top:.15rem;
  font-size:1.8rem; font-weight:900; color:#b45309;
  background:#fff1a6; border:2px solid #f59e0b; border-radius:12px;
  padding:.05rem .5rem; box-shadow:0 2px 0 #f59e0b33;
}

/* Activity cards (REVERTED) */
.card-activity { background: var(--soft-2); }
.img-wrap {
  height: 120px;
  display:grid; place-items:center;
  background:#fff;
  border-radius: 16px;
  overflow: hidden;
}
.guide-img { width: 100%; max-width: 240px; height: 120px; object-fit: contain; }

/* Routine chips */
.chip { background:#fff6e5; border:2px solid #ffe1b2; border-radius:999px; padding:.35rem .7rem; font-weight:700; color:#a85a00; }
.chip.active { background:#f59e0b; border-color:#f59e0b; color:#fff; }
.chip.done { background:#d1f7e9; border-color:#8ce0c3; color:#138a5e; }
.sep { color:#adb5bd; }

/* Focus overlay */
.focus-overlay { position: fixed; inset: 0; background: rgba(9,20,40,.35); display: grid; place-items: center; padding: 16px; z-index: 30; }
.focus-card { background: #ffffff; width: min(1080px, 96vw); padding: 18px 18px 12px; position: relative; }
.focus-close { position: absolute; top: 8px; right: 10px; border:0; background:#fff; width: 36px; height: 36px; border-radius: 999px; box-shadow: 0 2px 6px rgba(0,0,0,.12); }
.focus-grid { display: grid; gap: 18px; grid-template-columns: 1.2fr 1fr; }
@media (max-width: 900px) { .focus-grid { grid-template-columns: 1fr; } }
.focus-illustration {
  background: #fffaf0; border: 1px solid #ffe1b2; border-radius: 16px;
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
.t-ring-fg { fill: none; stroke:#16a34a; stroke-linecap: round; stroke-width: 10; transform: rotate(-90deg); transform-box: fill-box; transform-origin: 50% 50%; transition: stroke-dashoffset .6s linear; }
.t-ring-text { font-size: 24px; font-weight: 800; fill:#166534; }
</style>
