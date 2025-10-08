<template>
  <div>
    <!-- Top image and title -->
    <section class="hero-children d-flex align-items-center">
      <div class="container text-center">
        <h1 class="display-5 fw-bold text-white text-shadow">Children</h1>
        <p class="lead text-white-50 text-shadow mb-0">Fun steps before sleep</p>
      </div>
    </section>

    <!-- Back button (top left corner) -->
    <div class="container">
      <div class="pt-3 pb-1">
        <router-link to="/" class="btn btn-outline-secondary btn-sm">Back</router-link>
      </div>
    </div>

    <!-- Three module cards (click to jump) -->
    <section class="container py-4">
      <div class="row g-4 justify-content-center">
        <div class="col-md-4">
          <router-link
            to="/children/sleep-habits"
            class="card card-tile text-decoration-none h-100"
          >
            <div class="card-body text-center">
              <div class="emoji mb-2">🌙</div>
              <h3 class="h5 mb-1 text-dark">Healthy Sleep Habits</h3>
              <p class="text-muted mb-0">Stories & meditation to wind down</p>
            </div>
          </router-link>
        </div>

        <div class="col-md-4">
          <router-link
            to="/children/routine-coach"
            class="card card-tile text-decoration-none h-100"
          >
            <div class="card-body text-center">
              <div class="emoji mb-2">⏰</div>
              <h3 class="h5 mb-1 text-dark">Bedtime Routine Coach</h3>
              <p class="text-muted mb-0">Age-based tips & screen-free timer</p>
            </div>
          </router-link>
        </div>

        <div class="col-md-4">
          <router-link to="/children/move-more" class="card card-tile text-decoration-none h-100">
            <div class="card-body text-center">
              <div class="emoji mb-2">🏞️</div>
              <h3 class="h5 mb-1 text-dark">Move-More Planner</h3>
              <p class="text-muted mb-0">Nearby parks & weekday ideas</p>
            </div>
          </router-link>
        </div>
      </div>
    </section>

    <footer class="text-center text-muted py-4">
      © {{ new Date().getFullYear() }} SleepBuddy
    </footer>
  </div>
</template>
