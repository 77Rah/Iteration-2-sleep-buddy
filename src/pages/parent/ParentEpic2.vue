<script setup>
import ChildIntakeAdvisor from '@/components/parent/ChildIntakeAdvisor.vue';
import FoodMealPlanner from '@/components/parent/FoodMealPlanner.vue';
</script>

<template>
  <div>
    <!-- Sub-hero bar -->
    <section class="sub-hero">
      <div class="container d-flex align-items-center justify-content-between">
        <router-link to="/parent" class="btn btn-outline-secondary btn-sm">← Back</router-link>
        <h1 class="h5 fw-bold mx-auto text-center">Nutritional intake recommendations for children</h1>
        <div style="width: 84px"></div>
      </div>
    </section>

    <!-- ChildIntakeAdvisor -->
    <section class="container py-5">
        <ChildIntakeAdvisor />
    </section>

    <!-- Session B -->
    <section class="container pb-5">
        <FoodMealPlanner />
    </section>

    <!-- Footer -->
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
