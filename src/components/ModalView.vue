<template>
  <!-- Backdrop (clicking outside closes modal) -->
  <div class="modal-backdrop" @click.self="$emit('close')">
    <div class="modal-panel relative">
      <!-- Close button -->
      <button class="modal-close" @click="$emit('close')">✕</button>

      <!-- Modal content -->
      <div class="modal-body">
        <!-- Slot: content is passed from parent component -->
        <slot></slot>
      </div>
    </div>
  </div>
</template>

<script setup>
// This component is purely presentational.
// Emits "close" event when backdrop or close button is clicked.
</script>

<style scoped>
/* Backdrop overlay */
.modal-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(15, 23, 42, 0.55); /* semi-transparent dark bg */
  backdrop-filter: blur(6px);          /* blur effect */
  z-index: 999; /* ensure it's above all */
}

/* Modal container */
.modal-panel {
  background: #ffffff;
  border-radius: 14px;
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.25);
  animation: slideUp 0.3s ease;
  max-width: 720px;
  width: 90%;
  max-height: 80vh;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  position: relative;
}

/* Modal body (scrollable area) */
.modal-body {
  flex: 1;
  overflow-y: auto;
  padding: 1.5rem 2rem;
  line-height: 1.65;
}

/* Title style (applied to h4 in slot/v-html) */
.modal-body :deep(h4) {
  margin: 1rem 0 0.5rem;
  font-size: 1.15rem;
  font-weight: 700;
  color: #4338ca;
  border-left: 4px solid #6366f1;
  padding-left: 0.5rem;
}

/* Paragraphs and list items */
.modal-body :deep(p),
.modal-body :deep(li) {
  color: #374151;
  font-size: 0.95rem;
}

/* List spacing */
.modal-body :deep(ul),
.modal-body :deep(ol) {
  margin: 0.5rem 0 1rem 1.25rem;
}
.modal-body :deep(li) {
  margin-bottom: 0.35rem;
}

/* References block */
.modal-body :deep(.references) {
  font-size: 0.85rem;
  color: #6b7280;
  background: #f9fafb;
  padding: 0.75rem;
  border-radius: 8px;
  margin-top: 1rem;
}

/* Custom scrollbar */
.modal-body::-webkit-scrollbar {
  width: 6px;
}
.modal-body::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 4px;
}
.modal-body::-webkit-scrollbar-track {
  background: transparent;
}

/* Close button */
.modal-close {
  position: absolute;
  top: 0.75rem;
  right: 0.75rem;
  z-index: 2;
  background: transparent;
  border: none;
  font-size: 1.25rem;
  color: #6b7280;
  cursor: pointer;
  transition: color 0.2s;
}
.modal-close:hover {
  color: #ef4444;
}

/* Slide-up animation */
@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(40px) scale(0.96);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}
</style>
