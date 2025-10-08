<template>
  <div>
    <!-- Big Title + Parent-Child Background -->
    <section class="hero-hero d-flex align-items-center">
      <div class="container text-center">
        <h1 class="display-3 fw-bold text-white text-shadow">SleepBuddy</h1>
        <p class="lead text-white-50 text-shadow">Better bedtime habits for kids & families</p>
      </div>
    </section>

    <!-- Two modules -->
    <section class="container py-5">
      <div class="row g-4 justify-content-center">
        <div class="col-md-5">
          <router-link to="/parent" class="card card-select text-decoration-none h-100">
            <div class="card-body text-center p-5">
              <div class="emoji mb-2">👨‍👩‍👧</div>
              <h2 class="h3 text-dark mb-2">Parent</h2>
              <p class="text-muted mb-0">Guidance, routines & reminders</p>
            </div>
          </router-link>
        </div>
        <div class="col-md-5">
          <router-link to="/children" class="card card-select text-decoration-none h-100">
            <div class="card-body text-center p-5">
              <div class="emoji mb-2">🌙</div>
              <h2 class="h3 text-dark mb-2">Children</h2>
              <p class="text-muted mb-0">Stories, meditation & activities</p>
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
