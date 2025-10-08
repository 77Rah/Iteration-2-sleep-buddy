<template>
  <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
    <div class="card-body p-3 p-md-4">

      <!-- 1) Regions block (all visible, no scrolling) -->
      <section aria-label="Pick your region">
        <h3 class="section-title">Pick your region</h3>
        <div class="regions-grid">
          <button
            v-for="r in regions"
            :key="r.id"
            class="pill"
            :class="{ active: r.id === selectedRegionId }"
            @click="selectRegion(r.id)"
          >
            {{ r.name }}
          </button>
        </div>
      </section>

      <!-- 2) Actions row (separate from regions) -->
      <section class="actions-row" aria-label="Map actions">
        <button class="btn-action" @click="useMyLocation">
          <span class="ico">📍</span><span>Use my location</span>
        </button>
        <button class="btn-action" @click="resetView">
          <span class="ico">🔄</span><span>Reset view</span>
        </button>
      </section>

      <!-- 3) Embedded My Maps -->
      <div class="mt-3 rounded-3 overflow-hidden map-box">
        <iframe
          :src="iframeSrc"
          style="border:0; width:100%; height:460px"
          loading="lazy"
          allowfullscreen
          referrerpolicy="no-referrer-when-downgrade"
          title="Activity map"
        ></iframe>
      </div>

      <!-- 4) Rating legend (static, colourful grid) -->
      <section class="card border-0 rounded-4 shadow-sm mt-3">
        <div class="card-body py-3">
          <h4 class="legend-title">Rating scale for pins</h4>

          <ul class="legend-grid" role="list">
            <!-- Red -->
            <li class="legend-item" style="background:#FFE7E5">
              <svg width="22" height="28" viewBox="0 0 24 24" aria-hidden="true">
                <path fill="#FF5A4E" d="M12 2c-4.42 0-8 3.58-8 8 0 5.52 8 13 8 13s8-7.48 8-13c0-4.42-3.58-8-8-8z"/>
                <circle cx="12" cy="10" r="3" fill="#fff"/>
                <path d="M12 2c-4.42 0-8 3.58-8 8 0 .35.02.69.06 1.03C4.6 6.84 7.93 4 12 4s7.4 2.84 7.94 7.03c.04-.34.06-.68.06-1.03 0-4.42-3.58-8-8-8z" fill="#00000016"/>
              </svg>
              <span class="legend-label">Red = 4.5 – 5.0</span>
            </li>

            <!-- Purple -->
            <li class="legend-item" style="background:#F1E6F6">
              <svg width="22" height="28" viewBox="0 0 24 24" aria-hidden="true">
                <path fill="#8E44AD" d="M12 2c-4.42 0-8 3.58-8 8 0 5.52 8 13 8 13s8-7.48 8-13c0-4.42-3.58-8-8-8z"/><circle cx="12" cy="10" r="3" fill="#fff"/><path d="M12 2c-4.42 0-8 3.58-8 8 0 .35.02.69.06 1.03C4.6 6.84 7.93 4 12 4s7.4 2.84 7.94 7.03c.04-.34.06-.68.06-1.03 0-4.42-3.58-8-8-8z" fill="#00000016"/>
              </svg>
              <span class="legend-label">Purple = 4.0</span>
            </li>

            <!-- Dark Blue -->
            <li class="legend-item" style="background:#E4EEF7">
              <svg width="22" height="28" viewBox="0 0 24 24" aria-hidden="true">
                <path fill="#1F4E79" d="M12 2c-4.42 0-8 3.58-8 8 0 5.52 8 13 8 13s8-7.48 8-13c0-4.42-3.58-8-8-8z"/><circle cx="12" cy="10" r="3" fill="#fff"/><path d="M12 2c-4.42 0-8 3.58-8 8 0 .35.02.69.06 1.03C4.6 6.84 7.93 4 12 4s7.4 2.84 7.94 7.03c.04-.34.06-.68.06-1.03 0-4.42-3.58-8-8-8z" fill="#00000016"/>
              </svg>
              <span class="legend-label">Dark Blue = 3.5</span>
            </li>

            <!-- Light Blue -->
            <li class="legend-item" style="background:#EAF5FD">
              <svg width="22" height="28" viewBox="0 0 24 24" aria-hidden="true">
                <path fill="#5DADE2" d="M12 2c-4.42 0-8 3.58-8 8 0 5.52 8 13 8 13s8-7.48 8-13c0-4.42-3.58-8-8-8z"/><circle cx="12" cy="10" r="3" fill="#fff"/><path d="M12 2c-4.42 0-8 3.58-8 8 0 .35.02.69.06 1.03C4.6 6.84 7.93 4 12 4s7.4 2.84 7.94 7.03c.04-.34.06-.68.06-1.03 0-4.42-3.58-8-8-8z" fill="#00000016"/>
              </svg>
              <span class="legend-label">Light Blue = 2.5 – 3.0</span>
            </li>

            <!-- Pink -->
            <li class="legend-item" style="background:#FFEDF6">
              <svg width="22" height="28" viewBox="0 0 24 24" aria-hidden="true">
                <path fill="#FF77B7" d="M12 2c-4.42 0-8 3.58-8 8 0 5.52 8 13 8 13s8-7.48 8-13c0-4.42-3.58-8-8-8z"/><circle cx="12" cy="10" r="3" fill="#fff"/><path d="M12 2c-4.42 0-8 3.58-8 8 0 .35.02.69.06 1.03C4.6 6.84 7.93 4 12 4s7.4 2.84 7.94 7.03c.04-.34.06-.68.06-1.03 0-4.42-3.58-8-8-8z" fill="#00000016"/>
              </svg>
              <span class="legend-label">Pink = 1.5 – 2.0</span>
            </li>

            <!-- Yellow -->
            <li class="legend-item" style="background:#FFF8DD">
              <svg width="22" height="28" viewBox="0 0 24 24" aria-hidden="true">
                <path fill="#F4D03F" d="M12 2c-4.42 0-8 3.58-8 8 0 5.52 8 13 8 13s8-7.48 8-13c0-4.42-3.58-8-8-8z"/><circle cx="12" cy="10" r="3" fill="#fff"/><path d="M12 2c-4.42 0-8 3.58-8 8 0 .35.02.69.06 1.03C4.6 6.84 7.93 4 12 4s7.4 2.84 7.94 7.03c.04-.34.06-.68.06-1.03 0-4.42-3.58-8-8-8z" fill="#00000016"/>
              </svg>
              <span class="legend-label">Yellow = 0 – 1.0</span>
            </li>

            <!-- Green -->
            <li class="legend-item" style="background:#E7F7ED">
              <svg width="22" height="28" viewBox="0 0 24 24" aria-hidden="true">
                <path fill="#27AE60" d="M12 2c-4.42 0-8 3.58-8 8 0 5.52 8 13 8 13s8-7.48 8-13c0-4.42-3.58-8-8-8z"/><circle cx="12" cy="10" r="3" fill="#fff"/><path d="M12 2c-4.42 0-8 3.58-8 8 0 .35.02.69.06 1.03C4.6 6.84 7.93 4 12 4s7.4 2.84 7.94 7.03c.04-.34.06-.68.06-1.03 0-4.42-3.58-8-8-8z" fill="#00000016"/>
              </svg>
              <span class="legend-label">Green = Not rated yet</span>
            </li>
          </ul>
        </div>
      </section>

      <!-- (Removed the read-only paragraph) -->

    </div>
  </div>
</template>

<script>
export default {
  name: 'MoveMoreMap',
  data() {
    return {
      regions: [
        { id: 'se', name: 'South East',  base: 'https://www.google.com/maps/d/embed?mid=1Ow4v1rGdCRGo9HHiy6yXEflfIPc&ehbc=2E312F', center: { lat: -38.050, lon: 145.100 } },
        { id: 'oe', name: 'Outer East',  base: 'https://www.google.com/maps/d/embed?mid=1GbLgc7HsbsSEPygyreLv0EEb2sk&ehbc=2E312F', center: { lat: -37.840, lon: 145.350 } },
        { id: 'ne', name: 'North East',  base: 'https://www.google.com/maps/d/embed?mid=192jCbskWYW60fh8KwZf3zfhEeuI&ehbc=2E312F', center: { lat: -37.680, lon: 145.180 } },
        { id: 'in', name: 'Inner North', base: 'https://www.google.com/maps/d/embed?mid=1BIH-sPWVvyorHrX5lYt1CyTL6ws&ehbc=2E312F', center: { lat: -37.780, lon: 144.960 } },
        { id: 'on', name: 'Outer North', base: 'https://www.google.com/maps/d/embed?mid=1KTxJX6ixNYVEehTheY-cFdoZObs&ehbc=2E312F', center: { lat: -37.600, lon: 145.000 } },
        { id: 'nw', name: 'North West',  base: 'https://www.google.com/maps/d/embed?mid=1zrrQEa_SpEtgiXQXiBe2eS7vCBs&ehbc=2E312F', center: { lat: -37.700, lon: 144.850 } },
        { id: 'sw', name: 'South West',  base: 'https://www.google.com/maps/d/embed?mid=1k_AKGxGOaRvIdsEaMFC5XQtmung&ehbc=2E312F', center: { lat: -37.950, lon: 144.700 } },
        { id: 'ct', name: 'Central',     base: 'https://www.google.com/maps/d/embed?mid=1i1RfNIadPn1DFd2ADxwioIoFoDQ&ehbc=2E312F', center: { lat: -37.8136, lon: 144.9631 } },
      ],
      selectedRegionId: 'se',
      center: { lat: -38.050, lon: 145.100 },
      zoom: 12
    };
  },
  computed: {
    currentRegion() {
      return this.regions.find(r => r.id === this.selectedRegionId);
    },
    iframeSrc() {
      const params = new URLSearchParams({
        ll: `${this.center.lat},${this.center.lon}`,
        z: String(this.zoom),
      });
      return `${this.currentRegion.base}&${params.toString()}`;
    }
  },
  methods: {
    selectRegion(id) {
      this.selectedRegionId = id;
      const c = this.currentRegion?.center || { lat: -37.8136, lon: 144.9631 };
      this.center = { ...c };
      this.zoom = 12;
    },
    useMyLocation() {
      if (!navigator.geolocation) return alert('Geolocation not supported on this device.');
      navigator.geolocation.getCurrentPosition(
        (pos) => { this.center = { lat: pos.coords.latitude, lon: pos.coords.longitude }; this.zoom = 15; },
        () => alert('Could not access your location. Please allow location permissions.')
      );
    },
    resetView() {
      const c = this.currentRegion?.center || { lat: -37.8136, lon: 144.9631 };
      this.center = { ...c };
      this.zoom = 12;
    }
  },
  mounted() { this.selectRegion(this.selectedRegionId); }
};
</script>

<style scoped>
/* Headings */
.section-title { font-weight: 800; margin-bottom: .5rem; }

/* Regions grid (8 visible, responsive) */
.regions-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(160px, 1fr));
  gap: .6rem;
}
@media (max-width: 992px) { .regions-grid { grid-template-columns: repeat(3, minmax(140px, 1fr)); } }
@media (max-width: 640px) { .regions-grid { grid-template-columns: repeat(2, minmax(130px, 1fr)); } }

/* Region pills */
.pill {
  border: 2px solid #b4d8ff; background: #fff; color: #0b5ed7;
  border-radius: 999px; padding: .55rem .9rem; font-weight: 800;
  text-align: center; transition: transform .12s ease, background .12s, border-color .12s;
}
.pill:hover { transform: translateY(-1px); }
.pill.active { background: #0d6efd; border-color: #0d6efd; color: #fff; }

/* Actions row */
.actions-row { display: flex; justify-content: flex-end; gap: .6rem; margin-top: .75rem; }
.btn-action {
  display: inline-flex; align-items: center; gap: .4rem;
  border: 2px solid #e7eef7; background: #fff; border-radius: 999px;
  padding: .5rem .9rem; font-weight: 700; box-shadow: 0 2px 0 #e4ebf6;
}
.btn-action:hover { transform: translateY(-1px); }
.ico { font-size: 1.05rem; line-height: 1; }

/* Map box */
.map-box { background:#f8fafc; border:1px solid #e9ecef; min-height: 420px; }

/* Legend */
.legend-title { font-weight: 800; margin-bottom: .4rem; }
.legend-grid {
  list-style: none; margin: 0; padding: 0;
  display: grid; gap: .6rem;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
}
.legend-item {
  display: flex; align-items: center; gap: .6rem;
  border-radius: 14px; padding: .55rem .65rem;
  box-shadow: inset 0 0 0 2px #ffffffaa;
}
.legend-label { font-weight: 800; }
</style>
