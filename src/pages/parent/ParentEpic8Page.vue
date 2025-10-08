<script setup>
// Epic 8 components
import Epic8ExplainerSections from '@/components/parent/Epic8ExplainerSections.vue'
import References from '@/components/parent/References.vue'
</script>

<template>
  <div>
    <!-- Sub-hero bar -->
    <section class="sub-hero">
      <div class="container d-flex align-items-center justify-content-between">
        <router-link to="/parent" class="btn btn-outline-secondary btn-sm">← Back</router-link>
        <h1 class="h5 fw-bold mx-auto text-center">How Meditation Helps: Benefits & Quantitative Effects</h1>
        <div style="width: 84px"></div>
      </div>
    </section>

    <!-- Explainer Sections -->
    <section class="container py-5">
      <Epic8ExplainerSections />
    </section>

    <!-- References -->
    <section class="container pb-5">
      <References />
    </section>

    <footer class="text-center text-muted py-4">
      © {{ new Date().getFullYear() }} SleepBuddy
    </footer>
  </div>
</template>

<style scoped>
.sub-hero {
  padding: 20px 0;
  background: #f9fafb;
  border-bottom: 1px solid #e5e7eb;
}
</style>
