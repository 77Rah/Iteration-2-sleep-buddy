<template>
  <div>
    <!-- Top image and title -->
    <section class="hero-parent d-flex align-items-center">
      <div class="container text-center">
        <h1 class="display-5 fw-bold text-white text-shadow">Parents</h1>
        <p class="lead text-white-50 text-shadow mb-0">Tools to support healthy sleep</p>
      </div>
    </section>

    <!-- Back button (top left corner) -->
    <div class="container">
      <div class="pt-3 pb-1">
        <router-link to="/" class="btn btn-outline-secondary btn-sm">Back</router-link>
      </div>
    </div>

    <!-- Three module cards (epic 8, 2, 4) -->
    <section class="container py-4">
      <div class="row g-4 justify-content-center">
        <div class="col-md-4">
          <router-link
            to="/parent/epic8"
            class="card card-tile text-decoration-none h-100"
          >
            <div class="card-body text-center">
              <div class="emoji mb-2">🛏️</div>
              <h3 class="h5 mb-1 text-dark">Children Meditation suggestion</h3>
              <p class="text-muted mb-0">How Meditation Improves Children’s Sleep</p>
            </div>
          </router-link>
        </div>

        <div class="col-md-4">
          <router-link
            to="/parent/epic2"
            class="card card-tile text-decoration-none h-100"
          >
            <div class="card-body text-center">
              <div class="emoji mb-2">📱</div>
              <h3 class="h5 mb-1 text-dark">Meal Nutrition Planner</h3>
              <p class="text-muted mb-0">Track daily nutrients by building a custom child meal.</p>
            </div>
          </router-link>
        </div>

        <div class="col-md-4">
          <router-link
            to="/parent/epic4"
            class="card card-tile text-decoration-none h-100"
          >
            <div class="card-body text-center">
              <div class="emoji mb-2">📊</div>
              <h3 class="h5 mb-1 text-dark">DashboardS</h3>
              <p class="text-muted mb-0">Show trend and finding a playground </p>
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
