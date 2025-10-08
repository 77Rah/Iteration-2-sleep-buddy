<template>
  <div class="benefit-row container">
    <div class="row align-items-center gy-4" :class="{ 'flex-row-reverse': reverse }">
      <!-- Image -->
      <div class="col-lg-6">
        <div class="img-wrap" :class="{ outlined: outline }">
          <img :src="image" :alt="title" />
        </div>
      </div>

      <!-- Text column -->
      <div class="col-lg-6 text-col">
        <h3 class="title">{{ title }}</h3>
        <p class="desc">{{ description }}</p>
        <button class="btn btn-readmore" @click="open = true">Read More</button>
      </div>
    </div>

    <!-- ModalView (opens when button clicked) -->
    <ModalView v-if="open" @close="open = false">
      <h4 class="h5 mb-3">{{ title }}</h4>
      <!-- Render detail content passed from parent -->
      <div v-html="detail"></div>
    </ModalView>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import ModalView from '@/components/ModalView.vue'

// Props for each benefit row
defineProps({
  image: { type: String, required: true },
  title: { type: String, required: true },
  description: { type: String, required: true },
  detail: { type: String, required: true },
  reverse: { type: Boolean, default: false }, // flip image/text order
  outline: { type: Boolean, default: false }  // optional image border
})

const open = ref(false) // controls modal visibility
</script>

<style scoped>
.benefit-row { margin-bottom: 72px; }

/* Image container */
.img-wrap {
  border-radius: 20px;
  overflow: hidden;
  background: #f1f5f9;
  box-shadow: 0 8px 24px rgba(0,0,0,.08);
  transition: transform 0.25s ease, box-shadow 0.25s ease;
}
.img-wrap:hover {
  transform: translateY(-4px);
  box-shadow: 0 14px 36px rgba(0,0,0,.12);
}
.img-wrap img {
  width: 100%;
  height: 340px;
  object-fit: cover;
  display: block;
}
.img-wrap.outlined { border: 4px solid #4f86ff; }

/* Text column */
.text-col { display: flex; flex-direction: column; justify-content: center; }
.title {
  color: #4c37b0;
  font-weight: 800;
  margin-bottom: .5rem;
}
.desc { 
  color: #475569; 
  line-height: 1.65;
  margin-bottom: 1rem;
}

/* Read More button */
.btn-readmore {
  background: #5b43ea;
  color: #fff;
  border: 0;
  border-radius: 14px;
  padding: 10px 20px;
  font-weight: 700;
  box-shadow: 0 6px 14px rgba(91,67,234,.25);
  transition: all .2s ease;
}
.btn-readmore:hover { 
  filter: brightness(.95); 
  transform: translateY(-2px);
}
.btn-readmore:active {
  transform: translateY(0);
  box-shadow: 0 3px 8px rgba(91,67,234,.3);
}

/* Responsive (small screens) */
@media (max-width: 992px) {
  .img-wrap img { height: 240px; }
  .benefit-row { margin-bottom: 56px; }
}
</style>
