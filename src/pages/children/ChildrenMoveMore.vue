<template>
  <div>
    <section class="sub-hero">
      <div class="container d-flex align-items-center justify-content-between">
        <router-link to="/children" class="btn btn-outline-secondary btn-sm">Back</router-link>
        <h1 class="h3 fw-bold mx-auto text-center">Move-More Fun Zone</h1>
        <div style="width:84px"></div>
      </div>
    </section>

    <!-- Selector tiles -->
    <section class="container py-4">
      <div class="row g-3 justify-content-center">
        <div class="col-md-4">
          <router-link to="/children/move-more/map" class="card card-tile text-decoration-none h-100 kid-hover">
            <div class="card-body text-center p-4">
              <div class="emoji mb-2" aria-hidden="true">🛝</div>
              <h2 class="h5 text-dark mb-1">Find a Playground</h2>
              <p class="text-muted mb-0">Search nearby parks in Melbourne</p>
            </div>
          </router-link>
        </div>
        <div class="col-md-4">
          <router-link to="/children/move-more/sleep-boost" class="card card-tile text-decoration-none h-100 kid-hover">
            <div class="card-body text-center p-4">
              <div class="emoji mb-2" aria-hidden="true">🌙✨</div>
              <h2 class="h5 text-dark mb-1">Wind-Down Moves</h2>
              <p class="text-muted mb-0">Gentle stretches & calm games</p>
            </div>
          </router-link>
        </div>
        <div class="col-md-4">
          <router-link to="/children/move-more/daytime" class="card card-tile text-decoration-none h-100 kid-hover">
            <div class="card-body text-center p-4">
              <div class="emoji mb-2" aria-hidden="true">🏃‍♀️🎈</div>
              <h2 class="h5 text-dark mb-1">Daytime Energy</h2>
              <p class="text-muted mb-0">Fun activities to feel sleepy later</p>
            </div>
          </router-link>
        </div>
      </div>
    </section>

    <!-- Child pages render here -->
    <section class="container pb-5">
      <router-view />
    </section>
    <footer class="text-center text-muted py-4">
      © {{ new Date().getFullYear() }} SleepBuddy
    </footer>
  </div>
</template>

<script>
export default {
  name: "ChildrenMoveMore",
};
</script>

<style scoped>
.sub-hero {
  background: linear-gradient(135deg, #a0e9ff 0%, #b8ffd6 100%);
  padding: 12px 0;
}
.card-tile {
  border: 0;
  border-radius: 1rem;
  box-shadow: 0 6px 18px rgba(33, 37, 41, 0.1);
}
.kid-hover:hover {
  transform: translateY(-3px) rotate(-0.5deg);
  transition: transform 140ms ease;
}
.emoji {
  font-size: 2rem;
  line-height: 1;
}
</style>
