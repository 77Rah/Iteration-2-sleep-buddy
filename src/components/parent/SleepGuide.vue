<template>
  <section class="sleep-guide container">
    <!-- Header -->
    <div class="header">
      <h2 class="title">Do’s and Don’ts Before Sleep</h2>
      <p class="subtitle">Some simple strategies.</p>


    </div>

    <!-- Two columns -->
    <div class="row gy-4 align-items-stretch">
      <!-- Do's (left) -->
      <div class="col-lg-6">
        <div class="card h-100">
          <div class="img-wrap">
            <img src="/meditation/sleep-dos.jpg" alt="Do’s before sleep" />
            <span class="badge badge-do">Do’s</span>
          </div>
          <div class="card-body">
            <ul class="list">
              <li><b>Keep a consistent routine:</b> Same bedtime and wake time daily to regulate body clocks.</li>
              <li><b>Introduce calming activities:</b> Warm bath, gentle music, storytelling, or breathing exercises.</li>
              <li><b>Dim lights and quieten the home:</b> Turn off screens 60 minutes before bed; reduce noise.</li>
              <li><b>Encourage daytime activity:</b> Natural light and physical play improve night sleep quality.</li>
              <li><b>Offer an appropriate evening meal:</b> Balanced dinner at a regular time (not too late/heavy).</li>
            </ul>
          </div>
        </div>
      </div>

      <!-- Don'ts (right) -->
      <div class="col-lg-6">
        <div class="card h-100">
          <div class="img-wrap">
            <img src="/meditation/sleep-donts.jpg" alt="Don’ts before sleep" />
            <span class="badge badge-dont">Don’ts</span>
          </div>
          <div class="card-body">
            <ul class="list">
              <li><b>Avoid screens at bedtime:</b> TV, tablets, phones delay sleep onset (stimulation/blue light).</li>
              <li><b>Limit caffeine and sugar:</b> Chocolate, cola, tea, energy drinks in PM can disturb sleep.</li>
              <li><b>Do not overstimulate:</b> Skip scary programs, loud games, or high-energy play near bedtime.</li>
              <li><b>Avoid long/late naps:</b> They can make it harder to fall asleep at night.</li>
              <li><b>Discourage clock-watching:</b> Visible clocks can increase anxiety if falling asleep is hard.</li>
            </ul>
          </div>
        </div>
      </div>
    </div>

    <!-- Actions -->
    <div class="actions text-center">
      <button class="btn btn-ref" @click="open = true">Reference</button>
    </div>

    <!-- Reference Modal -->
    <ModalView v-if="open" @close="open = false">
      <h4>References</h4>
      <ul class="references">
        <li>
          Raising Children Network (Australia). (2023).
          <i>Better sleep: tips for children and teenagers</i>.
          <a href="https://raisingchildren.net.au/toddlers/sleep/better-sleep-settling/sleep-better-tips" target="_blank" rel="noopener">raisingchildren.net.au</a>
        </li>
        <li>
          Mindell, J. A., &amp; Williamson, A. A. (2018).
          Benefits of a bedtime routine in young children: Sleep, development, and beyond.
          <i>Sleep Medicine Reviews, 40</i>, 93–108.
          <a href="https://doi.org/10.1016/j.smrv.2017.10.007" target="_blank" rel="noopener">https://doi.org/10.1016/j.smrv.2017.10.007</a>
        </li>
        <li>
          Owens, J. (2020). Sleep in children: The role of parents.
          <i>Pediatric Clinics of North America, 67</i>(3), 593–608.
          <a href="https://doi.org/10.1016/j.pcl.2020.02.005" target="_blank" rel="noopener">https://doi.org/10.1016/j.pcl.2020.02.005</a>
        </li>
      </ul>
    </ModalView>
  </section>
</template>

<script setup>
import { ref } from 'vue'
import ModalView from '@/components/ModalView.vue' 

const open = ref(false) // controls Reference modal
</script>

<style scoped>
/* Section frame */
.sleep-guide {
  padding: 2rem 0;
}

/* Header */
.header {
  text-align: center;
  margin-bottom: 5rem;
}
.title {
  font-weight: 800;
  color: #1f2937;
  margin-bottom: .25rem;
}
.subtitle {
  color: #6b7280;
  font-size: .95rem;
}

/* Card */
.card {
  border: 1px solid #eef2f7;
  border-radius: 18px;
  background: #fff;
  overflow: hidden;
  box-shadow: 0 8px 26px rgba(17, 24, 39, 0.06);
  transition: transform .18s ease, box-shadow .18s ease;
}
.card:hover {
  transform: translateY(-3px);
  box-shadow: 0 12px 32px rgba(17, 24, 39, 0.1);
}

/* Image */
.img-wrap {
  position: relative;
  background: #f3f4f6;
  overflow: hidden;
}
.img-wrap img {
  width: 100%;
  height: 260px;
  object-fit: cover;
  display: block;
  transform: scale(1.02);
  transition: transform .5s ease;
}
.card:hover .img-wrap img {
  transform: scale(1.06);
}

/* Badges */
.badge {
  position: absolute;
  left: 14px;
  bottom: 14px;
  padding: 6px 10px;
  font-size: .8rem;
  font-weight: 700;
  border-radius: 999px;
  color: #fff;
  text-transform: uppercase;
  letter-spacing: .4px;
  box-shadow: 0 6px 16px rgba(0,0,0,.18);
}
.badge-do   { background: #10b981; } /* green */
.badge-dont { background: #ef4444; } /* red */

/* Body */
.card-body {
  padding: 1rem 1.1rem 1.25rem;
}
.list {
  margin: 0 0 .25rem 1.15rem;
}
.list li {
  color: #374151;
  line-height: 1.6;
  margin-bottom: .5rem;
}

/* Actions */
.actions { margin-top: 12px; }
.btn-ref {
  background: #111827;
  color: #fff;
  border: 0;
  border-radius: 12px;
  padding: 10px 16px;
  font-weight: 700;
  box-shadow: 0 8px 18px rgba(17,24,39,.18);
  transition: transform .16s ease, box-shadow .16s ease, filter .16s ease;
}
.btn-ref:hover {
  transform: translateY(-2px);
  filter: brightness(.98);
}
.btn-ref:active {
  transform: translateY(0);
}

/* Responsive tweaks */
@media (max-width: 992px) {
  .img-wrap img { height: 220px; }
}
</style>
