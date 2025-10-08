<script setup>
// Fairy tales grid
import GrimmCardGrid from '@/components/GrimmCardGrid.vue'
import SoundscapeBar from '@/components/SoundscapeBar.vue'
</script>

<template>
  <div>
    <!-- Sub-hero bar -->
    <section class="sub-hero">
      <div class="container d-flex align-items-center justify-content-between">
        <router-link to="/children" class="btn btn-outline-secondary btn-sm">← Back</router-link>
        <h1 class="h5 fw-bold mx-auto text-center">Healthy Sleep Habits</h1>
        <div style="width: 84px"></div>
      </div>
    </section>

    <!-- US1: Fairy tales (open data cards) -->
    <section class="container py-5">
      <h2 class="h5 mb-3">Bedtime Stories</h2>
      <GrimmCardGrid />
    </section>

    <!-- US2: Guided meditation widget -->
    <section class="container pb-5">
      <h2 class="h5 mb-3">Guided Meditation</h2>
      <SoundscapeBar />
    </section>
  </div>
  <footer class="text-center text-muted py-4">© {{ new Date().getFullYear() }} SleepBuddy</footer>
</template>

<style scoped>
.sub-hero {
  padding: 20px 0;
  background: #f9fafb;
  border-bottom: 1px solid #e5e7eb;
}
</style>
