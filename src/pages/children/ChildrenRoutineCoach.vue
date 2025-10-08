<script setup>
// US6 component
import RoutineBuilder from '@/components/RoutineBuilder.vue'
import ChecklistPrint from '@/components/ChecklistPrint.vue'
</script>

<template>
  <div>
    <!-- Sub-hero bar -->
    <section class="sub-hero">
      <div class="container d-flex align-items-center justify-content-between">
        <router-link to="/children" class="btn btn-outline-secondary btn-sm">← Back</router-link>
        <h1 class="h5 fw-bold mx-auto text-center">Bedtime Routine Coach</h1>
        <div style="width: 84px"></div>
      </div>
    </section>

    <!-- US6.1: Routine Builder -->
    <section class="container py-5">
      <h2 class="h5 mb-3">Routine Builder</h2>
      <RoutineBuilder />
    </section>

    <section class="container py-5">
      <h2 class="h5 mb-3">Printable Checklist</h2>
      <ChecklistPrint />
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
