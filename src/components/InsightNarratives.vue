<template>
  <section class="ieh-narratives">
    <!-- Nutrition -->
    <article class="ieh-card">
      <header class="ieh-card__header">
        <div class="ieh-title">
          <span class="ieh-pill ieh-pill--blue">🍽️ Nutrition narrative</span>
          <small class="ieh-muted">Viewing: {{ prettyAge }}</small>
        </div>
      </header>

      <div class="ieh-card__body">
        <p class="ieh-lede">{{ deck.nutrition.headline }}</p>

        <!-- Food-group spotlights -->
        <ul class="ieh-list">
          <li
            v-for="fg in deck.nutrition.foods"
            :key="fg.key"
            class="ieh-spot"
            :data-key="fg.key"
          >
            <div class="ieh-spot__title">
              <span class="ieh-emoji">{{ fg.emoji }}</span>
              <strong>{{ fg.label }}</strong>
            </div>

            <p class="ieh-spot__meta">
              Target <b>{{ fg.target }} serves/day</b> · Current <b>{{ fg.current }}</b>
              <span v-if="fg.gap > 0"> · Gap <b>+{{ fg.gap }}</b></span>
              <span v-else> · On/above target 🎉</span>
            </p>

            <p class="ieh-spot__insight">{{ fg.insight }}</p>

            <div class="ieh-chips">
              <span v-for="(t,i) in fg.tips" :key="i" class="ieh-chip">{{ t }}</span>
            </div>
          </li>
        </ul>

        <div class="ieh-footnote">ADG = Australian Dietary Guidelines (children).</div>
      </div>
    </article>

    <!-- Movement -->
    <article class="ieh-card">
      <header class="ieh-card__header">
        <div class="ieh-title">
          <span class="ieh-pill ieh-pill--green">🏃 Movement narrative</span>
          <small class="ieh-muted">Viewing: {{ prettyAge }}</small>
        </div>
      </header>

      <div class="ieh-card__body">
        <p class="ieh-lede">{{ deck.movement.headline }}</p>

        <ul class="ieh-bullets">
          <li v-for="(b,i) in deck.movement.takeaways" :key="i">{{ b }}</li>
        </ul>

        <div class="ieh-suggestions">
          <div class="ieh-suggestion" v-for="(s,i) in deck.movement.suggestions" :key="i">
            <b>{{ s.title }}</b> {{ s.text }}
          </div>
        </div>

        <div class="ieh-footnote">
          Guideline reference: <b>60+ mins/day</b> of moderate-to-vigorous activity (ages 5–17).
          For ages 2–5: <b>180 mins/day</b> spread across the day.
          <span v-if="deck.movement.note"> {{ deck.movement.note }}</span>
        </div>
      </div>
    </article>
  </section>
</template>

<script>
/*
 * Hard-coded, age-specific narrative matching your current charts.
 * Supports: "Ages 2–3", "Ages 4–8", "Ages 9–13", "Ages 14–18"
 * (any label with numbers and an en dash/hyphen is normalised).
 */
const COPY = {
  '2-3': {
    nutrition: {
      headline:
        'Toddlers are doing well on fruit, but vegetables and core foods like grains and lean proteins are still short. Small, visible snacks and “veg-first” moments work best at this age.',
      foods: [
        {
          key: 'veg', label: 'Vegetables and legumes/beans', emoji: '🥦',
          target: 2.5, current: 1.4, gap: 1.1,
          insight: 'Veg intake is about a serve short each day—common at this age when textures matter.',
          tips: ['Veg first at dinner', 'Grate/blend into sauces', 'Raw sticks while meals cook']
        },
        {
          key: 'fruit', label: 'Fruit', emoji: '🍎',
          target: 1, current: 2, gap: 0,
          insight: 'Fruit is above target—great! Keep whole fruit; avoid juice as a swap for veg.',
          tips: ['Fruit bowl within reach', 'Lunchbox fruit daily']
        },
        {
          key: 'grains', label: 'Grain (cereal) foods', emoji: '🥖',
          target: 4, current: 3.3, gap: 0.7,
          insight: 'Just under target—an extra wholegrain serve will close the gap.',
          tips: ['Wholegrain toast/oats', 'Add crackers with hummus']
        },
        {
          key: 'meats', label: 'Lean meats & alternatives', emoji: '🍗',
          target: 1, current: 0.7, gap: 0.3,
          insight: 'Slight shortfall—beans, eggs or yoghurt at snacks can help.',
          tips: ['Half an egg at lunch', 'Beans in pasta mince', 'Yoghurt after childcare']
        }
      ]
    },
    movement: {
      headline:
        'Around three-quarters of toddlers meet movement guidance (≈72–78%). Keep activity playful and spread through the day.',
      takeaways: [
        'At this age, movement is mostly unstructured play—lots of short bursts add up.',
        'Screens displace active play quickly; keep the last hour before bed screen-light.'
      ],
      suggestions: [
        { title: 'Everyday nudges: ', text: 'push-bike to the park, mini obstacle course at home, 5-minute dance bursts.' },
        { title: 'Make it easy: ', text: 'set out balls, scarves and chalk where kids can see and grab them.' }
      ],
      note: 'Estimates shown as CIs on your chart reflect uncertainty.'
    }
  },

  '4-8': {
    nutrition: {
      headline:
        'Early-primary kids meet fruit and are on track for grains, but vegetables and lean proteins are falling behind.',
      foods: [
        {
          key: 'veg', label: 'Vegetables and legumes/beans', emoji: '🥦',
          target: 4.5, current: 1.7, gap: 2.8,
          insight: 'Veg is the biggest gap—aim for one extra serve at dinner and one at lunch.',
          tips: ['Add salad/veg sticks to lunch', 'Veg in bolognese or fried rice', 'Soup night once a week']
        },
        {
          key: 'fruit', label: 'Fruit', emoji: '🍎',
          target: 1.5, current: 1.8, gap: 0,
          insight: 'Fruit is already above target—great job. Keep whole fruit as the default snack.',
          tips: ['Whole fruit after school', 'Seasonal variety keeps interest']
        },
        {
          key: 'grains', label: 'Grain (cereal) foods', emoji: '🥖',
          target: 4, current: 4.3, gap: 0,
          insight: 'Grains are on track; prefer wholegrain to keep fibre up.',
          tips: ['Wholegrain wraps/rice', 'Swap half-white, half-brown while transitioning']
        },
        {
          key: 'meats', label: 'Lean meats & alternatives', emoji: '🍗',
          target: 1.5, current: 0.9, gap: 0.6,
          insight: 'Protein serves are a little low—easy adds at meals lift iron and satiety.',
          tips: ['Egg on toast breakfast', 'Beans/chicken in wraps', 'Tofu cubes in stir-fry']
        }
      ]
    },
    movement: {
      headline:
        'Only about 4–5 in 10 children aged 4–8 meet the 60-minutes-per-day guideline (≈46% and 40%).',
      takeaways: [
        'Short, regular bursts work—10 minutes before and after school adds ~20 minutes daily.',
        'Active transport (walk/scoot) is a quick win for weekdays.'
      ],
      suggestions: [
        { title: 'Quick wins: ', text: 'set a “family lap” around the block, park further from school, dance timer after homework.' },
        { title: 'Swap time: ', text: 'create a “screens-after-movement” rule—10 minutes of play earns 10 minutes of screen.' }
      ],
      note: ''
    }
  },

  '9-13': {
    nutrition: {
      headline:
        'Tweens have very low vegetable intake and are short on lean proteins; fruit and grains are close but not quite there.',
      foods: [
        {
          key: 'veg', label: 'Vegetables and legumes/beans', emoji: '🥦',
          target: 5.3, current: 1.9, gap: 3.4,
          insight: 'Veg is far below target—bigger portions at dinner + one veg-based lunch will move the needle.',
          tips: ['Add a veg side at dinner', 'Veg-packed wraps/pasta', 'Build-your-own salad night']
        },
        {
          key: 'fruit', label: 'Fruit', emoji: '🍎',
          target: 2, current: 1.8, gap: 0.2,
          insight: 'Just under target—swap one processed snack for fruit.',
          tips: ['Fruit + nuts pack', 'Smoothie with real fruit (no juice)']
        },
        {
          key: 'grains', label: 'Grain (cereal) foods', emoji: '🥖',
          target: 5.5, current: 5.3, gap: 0.2,
          insight: 'Slightly under—aim for wholegrain at breakfast or lunch.',
          tips: ['High-fibre cereal/oats', 'Wholegrain rolls']
        },
        {
          key: 'meats', label: 'Lean meats & alternatives', emoji: '🍗',
          target: 2.5, current: 1.3, gap: 1.2,
          insight: 'Protein serves are low—important for growth and sport recovery.',
          tips: ['Chicken/beans in burritos', 'Eggs on toast', 'Yoghurt + seeds after sport']
        }
      ]
    },
    movement: {
      headline:
        'Movement drops sharply in tweens—only about 1 in 5 meet the guideline (≈18% and 15%).',
      takeaways: [
        'Social play drives activity—team up with friends or siblings.',
        'Mix moderate and vigorous: rides, sprints at the park, ball games.'
      ],
      suggestions: [
        { title: 'Make it social: ', text: 'set up a weekly park game with neighbours; rotate the “game captain”.' },
        { title: 'School-day nudge: ', text: 'walk part-way home or to the bus; 10-minute loop before homework.' }
      ],
      note: ''
    }
  },

  '14-18': {
    nutrition: {
      headline:
        'Teens are below target across most food groups—especially vegetables and grains—while protein is also short.',
      foods: [
        {
          key: 'veg', label: 'Vegetables and legumes/beans', emoji: '🥦',
          target: 5.5, current: 2.2, gap: 3.3,
          insight: 'Veg is the biggest gap; larger dinner portions and veg-based lunches help.',
          tips: ['Salad + main at dinner', 'Veg in toasties/wraps', 'Pre-cut veg in the fridge']
        },
        {
          key: 'fruit', label: 'Fruit', emoji: '🍎',
          target: 2, current: 1.5, gap: 0.5,
          insight: 'Half-serve short—keep fruit visible and portable.',
          tips: ['Banana in the bag', 'Apple after school']
        },
        {
          key: 'grains', label: 'Grain (cereal) foods', emoji: '🥖',
          target: 7, current: 5.7, gap: 1.3,
          insight: 'Grains are under—prefer wholegrain for energy and fibre.',
          tips: ['Wholegrain sandwiches', 'Brown rice with stir-fry']
        },
        {
          key: 'meats', label: 'Lean meats & alternatives', emoji: '🍗',
          target: 2.5, current: 1.7, gap: 0.8,
          insight: 'Protein a little low—key for growth and training.',
          tips: ['Eggs at breakfast', 'Yoghurt + nuts', 'Bean-rich burritos']
        }
      ]
    },
    movement: {
      headline:
        'By the teen years, only about 1 in 6 meet the 60-minute guideline (≈17% and 15%). Build activity into transport, sport and social time.',
      takeaways: [
        'Time pressure and screens are the main barriers—tie movement to existing routines.',
        'Vigorous bouts count more—sport, intervals, hills.'
      ],
      suggestions: [
        { title: 'Pair with habits: ', text: 'move before showers or meals; cycle to friends part-way then walk.' },
        { title: 'Short + hard: ', text: 'two 10-minute intervals (stairs, sprints, skipping) beat zero minutes.' }
      ],
      note: ''
    }
  }
}

export default {
  name: 'InsightNarratives',
  props: {
    ageLabel: { type: String, required: true } // e.g., "Ages 9–13"
  },
  computed: {
    key () {
      // normalise “Ages 4–8” → “4-8”
      const m = String(this.ageLabel).match(/(\d+)\s*[\u2013-]\s*(\d+)/)
      if (!m) return '4-8'
      return `${m[1]}-${m[2]}`
    },
    deck () {
      return COPY[this.key] || COPY['4-8']
    },
    prettyAge () {
      return this.ageLabel.replace('Ages', '').trim()
    }
  }
}
</script>

<style scoped>
/* ========== Layout ========== */
.ieh-narratives {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1rem;
}
@media (min-width: 1024px) {
  .ieh-narratives { grid-template-columns: 1fr 1fr; }
}

/* ========== Card ========== */
.ieh-card {
  background: var(--card-bg, #ffffff);
  border: 1px solid var(--card-brd, #e8ecff);
  border-radius: 16px;
  box-shadow: 0 8px 24px rgba(16,24,40,0.06);
  overflow: hidden;
}
.ieh-card__header {
  padding: .9rem 1rem;
  background: var(--card-header-bg, #f8fbff);
  border-bottom: 1px dashed var(--card-brd, #e8ecff);
}
.ieh-title { display:flex; align-items:center; justify-content:space-between; gap:.75rem; }
.ieh-card__body { padding: 1rem 1.1rem 1.2rem; }

/* ========== Pills & text ========== */
.ieh-pill {
  padding: .25rem .6rem;
  border-radius: 999px;
  font-weight: 600;
  font-size: .85rem;
  border: 1px solid;
  white-space: nowrap;
}
.ieh-pill--blue  { background:#eef5ff; color:#2b55d4; border-color:#d8e6ff; }
.ieh-pill--green { background:#eafcf0; color:#16794b; border-color:#c9f1da; }
.ieh-muted { color: #6b7280; }
.ieh-lede { margin: 0 0 .75rem 0; }

/* ========== Spots (food groups) ========== */
.ieh-list { list-style:none; margin: .5rem 0 0 0; padding: 0; display:grid; gap:.7rem; }
.ieh-spot { background: var(--spot-bg, #f9fbff); border:1px solid var(--spot-brd, #eef2ff); border-radius: 12px; padding:.7rem .75rem; }
.ieh-spot__title { display:flex; align-items:center; gap:.5rem; }
.ieh-emoji { font-size: 1.15rem; }
.ieh-spot__meta { margin:.15rem 0 .35rem 0; color:#475569; font-size:.92rem; }
.ieh-spot__insight { margin:0 0 .4rem 0; }

/* ========== Pretty tag pills (pastel, not black) ========== */
.ieh-chips { display:flex; flex-wrap:wrap; gap:.5rem; }

.ieh-chip{
  --bg:#f6f9ff;  /* defaults; overridden per food group below */
  --bd:#dbe7ff;
  --fg:#2747d7;
  background: var(--bg);
  border: 1px solid var(--bd);
  color: var(--fg);
  border-radius: 999px;
  padding: .32rem .62rem;
  font-size: .85rem;
  font-weight: 600;
  line-height: 1.1;
  display: inline-flex;
  align-items: center;
  gap: .35rem;
  box-shadow: 0 1px 0 rgba(16,24,40,.04);
  transition: background .2s ease, transform .06s ease, box-shadow .2s ease;
  white-space: nowrap;
}
.ieh-chip:hover{ transform: translateY(-1px); box-shadow: 0 3px 12px rgba(16,24,40,.10); }

/* Optional subtle dot */
.ieh-chip::before{ content: "•"; font-size: 1rem; line-height: 0; opacity: .6; }

/* Auto-tint chips by food group */
.ieh-spot[data-key="veg"]   .ieh-chip{ --bg:#eaf8ef; --bd:#c9efda; --fg:#166b45; } /* mint */
.ieh-spot[data-key="fruit"] .ieh-chip{ --bg:#fff0f3; --bd:#ffd6de; --fg:#b4345c; } /* soft pink/red */
.ieh-spot[data-key="grains"] .ieh-chip{ --bg:#fff7e6; --bd:#ffe4b3; --fg:#8a5a00; } /* wheat */
.ieh-spot[data-key="meats"] .ieh-chip{ --bg:#fff3e9; --bd:#ffd8c2; --fg:#9a4d1e; } /* peach */
.ieh-spot[data-key="dairy"] .ieh-chip{ --bg:#eef6ff; --bd:#d8e6ff; --fg:#2b55d4; } /* soft blue */

/* ========== Movement extras ========== */
.ieh-bullets { margin:.5rem 0 .7rem 1rem; }
.ieh-suggestions { display:grid; gap:.5rem; }
.ieh-suggestion { border:1px solid #e7faef; background:#f6fffa; border-radius:12px; padding:.6rem .7rem; }
.ieh-footnote { margin-top:.8rem; font-size:.85rem; color:#6b7280; }

/* ========== Dark mode polish ========== */
@media (prefers-color-scheme: dark){
  :root {
    --card-bg:#0b1220; --card-brd:#1c2743;
    --card-header-bg:#0b1220;
    --spot-bg:#0f172a; --spot-brd:#1c2743;
  }
  .ieh-muted, .ieh-spot__meta, .ieh-footnote { color:#93a3b8; }
  .ieh-chip{
    --bg:#121c34; --bd:#283660; --fg:#cfdbff;
    box-shadow: none;
  }
  .ieh-spot[data-key="veg"]   .ieh-chip{ --bg:#0f2320; --bd:#2b4f46; --fg:#c7f1de; }
  .ieh-spot[data-key="fruit"] .ieh-chip{ --bg:#2b1420; --bd:#4f2438; --fg:#ffd9e2; }
  .ieh-spot[data-key="grains"] .ieh-chip{ --bg:#261d0c; --bd:#4b3b1a; --fg:#ffe6b8; }
  .ieh-spot[data-key="meats"] .ieh-chip{ --bg:#2a1a12; --bd:#513322; --fg:#ffd9c5; }
  .ieh-spot[data-key="dairy"] .ieh-chip{ --bg:#0f1a2f; --bd:#273a6a; --fg:#cfe1ff; }
}
</style>
