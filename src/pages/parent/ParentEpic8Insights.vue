<script setup>
import AlternatingBenefitRow from '@/components/parent/AlternatingBenefitRow.vue'
import SleepGuide from '@/components/parent/SleepGuide.vue'

const benefits = [
  {
    image: '/meditation/benefit-sleep-before.jpg',
    title: 'Benefits of meditation before sleep for children',
    description:
      'Short, age-appropriate meditation helps kids settle, reduces anxiety and supports better sleep and mood.',
    detail: `
      <h4>What it helps</h4>
      <ul>
        <li>Reduces bedtime arousal so kids fall asleep more willingly and sleep more soundly.</li>
        <li>Eases anxiety and low mood; improves overall calm and emotional balance.</li>
        <li>Supports attention and the ability to “pause” before reacting, which carries into the next day.</li>
      </ul>

      <h4>Evidence highlights</h4>
      <ul>
        <li>Clinician guidance notes benefits for <strong>anxiety, depression and insomnia</strong>, with added gains in <strong>mood</strong> and <strong>focus</strong> (Cleveland Clinic, 2022).</li>
        <li>Bedtime meditation activates the body’s relaxation response and makes sleep onset smoother, reducing parent frustration and resistance at lights-out (Harden, 2025).</li>
        <li>Calm, restful states are linked with <strong>alpha</strong> brain activity; simple guided practices help children access that state before bed (Jepsen, 2023).</li>
        <li>Families and programs report calmer evenings, deeper sleep quality and steadier emotions in children (CBHS Health Fund, 2021; HealthyChildren, 2023).</li>
      </ul>

      <h4>How to try (bedtime)</h4>
      <ul>
        <li><strong>2–3 min breathe &amp; settle</strong>: “In for 4, out for 6” through the nose; add a soft hand on belly for younger kids.</li>
        <li><strong>1–3 min body scan</strong>: toes → knees → belly → shoulders → face; whisper cues like “soften… release.”</li>
        <li><strong>1–4 min story/imagery</strong>: brief “safe place” or nature imagery; audio-guided if helpful.</li>
        <li><strong>Age-based time</strong>: Preschool a few minutes/day; Grade-school 3–10 min twice/day; Teens 5–45 min/day as preferred (HealthyChildren, 2023).</li>
      </ul>

      <h4>When to be careful</h4>
      <ul>
        <li>Keep it <strong>short and choice-based</strong>; don’t force stillness or use meditation as punishment.</li>
        <li>Persistent insomnia, nightmares, or daytime impairment → discuss with a pediatric professional.</li>
      </ul>

      <h4>References</h4>
      <ul>
        <li>CBHS Health Fund. (2021, November 29). <i>Why sleep meditation for kids can be a dream come true</i>. https://www.cbhs.com.au/mind-and-body/blog/why-sleep-meditation-for-kids-can-be-a-dream-come-true</li>
        <li>Cleveland Clinic. (2022, March 25). <i>Meditation basics (and benefits) for children</i>. https://health.clevelandclinic.org/meditation-for-kids</li>
        <li>Harden, L. (2025, August 13). <i>Sleep meditation for kids: Promoting peaceful nights and restful sleep</i>. Huckleberry. https://huckleberrycare.com/blog/sleep-meditation-for-kids-promoting-peaceful-nights-and-restful-sleep</li>
        <li>HealthyChildren. (2023, August 16). <i>Just breathe: The importance of meditation breaks for kids</i>. American Academy of Pediatrics. https://www.healthychildren.org/English/healthy-living/emotional-wellness/Pages/Just-Breathe-The-Importance-of-Meditation-Breaks-for-Kids.aspx</li>
        <li>Jepsen, K. (2023, November 15). <i>Kids sleep meditation: How to try it</i>. Parents. https://www.parents.com/toddlers-preschoolers/sleep/issues/why-sleep-meditation-for-kids-works-and-how-to-try-it/</li>
      </ul>
    `
  },
  {
    image: '/meditation/benefit-routine.jpg',
    title: 'Routines: why they work as a positive behaviour strategy',
    description:
      'Predictable wind-down plus micro-meditation builds self-regulation and smoother evenings for families.',
    detail: `
      <h4>What it helps</h4>
      <ul>
        <li>Consistent cues (same time, same steps) lower conflict and help children shift from play to rest.</li>
        <li>Practised daily, short meditations become a <strong>self-soothing tool</strong> kids can use beyond bedtime.</li>
        <li>Better sleep and steadier meals/play rhythms correlate with more positive behaviour during the day.</li>
      </ul>

      <h4>Evidence highlights</h4>
      <ul>
        <li>Mindfulness teaches kids to slow down, notice feelings, and choose behaviours rather than act impulsively (Garey, 2024).</li>
        <li>Families and programs report calmer moods, less stress/anxiety, deeper sleep quality and <strong>heightened empathy</strong> (CBHS Health Fund, 2021).</li>
        <li>Pediatric guidance links routines and adequate sleep with improved day-to-day behaviour (HealthyChildren, 2023).</li>
      </ul>

      <h4>How to try (wind-down stack)</h4>
      <ol>
        <li><strong>Sequence</strong>: tidy → wash → PJs → 3–5 min calm breathing/imagery → story → lights out.</li>
        <li><strong>Screen-free</strong> the last 60 min; use warm light and quiet voice cues.</li>
        <li><strong>Co-regulate</strong>: parent breathes with child; model slow exhale and relaxed shoulders.</li>
        <li><strong>Micro-moments</strong> by day: 3 breaths before tests, tryouts or tricky social moments (HealthyChildren, 2023).</li>
      </ol>

      <h4>When to be careful</h4>
      <ul>
        <li>Adjust the length/format by age; playful movement + breath often works better than “sit still.”</li>
        <li>If evenings remain highly dysregulated after consistent practice, consider behavioural or sleep consultation.</li>
      </ul>

      <h4>References</h4>
      <ul>
        <li>CBHS Health Fund. (2021, November 29). <i>Why sleep meditation for kids can be a dream come true</i>. https://www.cbhs.com.au/mind-and-body/blog/why-sleep-meditation-for-kids-can-be-a-dream-come-true</li>
        <li>Garey, J. (2024, November 22). <i>The power of mindfulness</i>. Child Mind Institute. https://childmind.org/article/the-power-of-mindfulness/</li>
        <li>HealthyChildren. (2023, August 16). <i>Just breathe: The importance of meditation breaks for kids</i>. https://www.healthychildren.org/English/healthy-living/emotional-wellness/Pages/Just-Breathe-The-Importance-of-Meditation-Breaks-for-Kids.aspx</li>
      </ul>
    `
  },
  {
    image: '/meditation/benefit-attention.jpg',
    title: 'Attention & Academic Performance',
    description:
      'Meditation strengthens attention and stress control; schools report gains in attendance, grades and behaviour.',
    detail: `
      <h4>What it helps</h4>
      <ul>
        <li>Improves sustained attention and executive control under stress.</li>
        <li>Offers non-pharmacological support alongside clinical care for attention and hyperactivity concerns.</li>
      </ul>

      <h4>Evidence highlights</h4>
      <ul>
        <li>After <strong>5 days</strong> of training, children showed better attention and stress control than a relaxation control (Tang et al., 2007).</li>
        <li>Mindfulness programs reduced <strong>hyperactive behaviours</strong> and improved concentration in adolescents with ADHD (Zylowska et al., 2013).</li>
        <li>School implementations reported improved <strong>attendance</strong>, <strong>grades</strong> and fewer suspensions (McFadden et al., 2014).</li>
      </ul>

      <h4>How to try (classroom-friendly)</h4>
      <ul>
        <li><strong>60–90-second resets</strong> between subjects: eyes soft, count breath 1–5 in/out.</li>
        <li><strong>Anchor on senses</strong>: “find 3 sounds + 2 colours + 1 texture” to return attention to the present.</li>
        <li><strong>Regularity beats length</strong>: 1–3 min, 2–3 times daily often outperforms occasional long sessions.</li>
      </ul>

      <h4>When to be careful</h4>
      <ul>
        <li>For diagnosed ADHD, treat meditation as an <strong>adjunct</strong> to professional care, not a replacement.</li>
      </ul>

      <h4>References</h4>
      <ul>
        <li>McFadden, C., Sandler, T., & Fieldstadt, E. (2014, December 29). <i>San Francisco schools transformed by the power of meditation</i>. NBC News. https://www.nbcnews.com/nightly-news/san-francisco-schools-transformed-power-meditation-n276301</li>
        <li>Tang, Y.-Y., Ma, Y., Wang, J., Fan, Y., Feng, S., Lu, Q., Yu, Q., … Posner, M. I. (2007). Short-term meditation training improves attention and self-regulation. <i>PNAS, 104</i>(43), 17152–17156. https://doi.org/10.1073/pnas.0707678104</li>
        <li>Walton, A. G. (2016, October 18). <i>Science shows meditation benefits children's brains and behavior</i>. Forbes. https://www.forbes.com/sites/alicegwalton/2016/10/18/the-many-benefits-of-meditation-for-children/</li>
        <li>Zylowska, L., Ackerman, D. L., Yang, M. H., Futrell, J. L., Horton, N. L., Hale, T. S., … Smalley, S. L. (2013). Mindfulness meditation training in adults and adolescents with ADHD: A feasibility study. <i>Journal of Attention Disorders, 17</i>(5), 408–416. https://doi.org/10.1080/15427609.2013.818487</li>
      </ul>
    `
  },
  {
    image: '/meditation/benefit-physical.jpg',
    title: 'Physical Health',
    description:
      'Early research links meditation to lower blood pressure/heart rate and possible relief for common pediatric complaints.',
    detail: `
      <h4>What it helps</h4>
      <ul>
        <li>Cardiovascular markers: reductions in <strong>resting and ambulatory blood pressure</strong> and <strong>heart rate</strong> in youth samples.</li>
        <li>Potential improvements in <strong>headaches</strong>, <strong>gastrointestinal symptoms</strong>, <strong>obesity</strong>, <strong>pain sensitivity</strong> and <strong>immune function</strong>.</li>
      </ul>

      <h4>Evidence highlights</h4>
      <ul>
        <li>Trial evidence for BP/HR reduction with regular practice in youth (Barnes et al., 2004).</li>
        <li>Broader pediatric guidance lists additional symptom domains with promising signals (HealthyChildren, 2023).</li>
      </ul>

      <h4>How to try (gentle body + breath)</h4>
      <ul>
        <li><strong>3–5 min</strong> nasal breathing with longer exhale (e.g., 4–6) before or after light stretching/yoga-inspired movement.</li>
        <li>Encourage <strong>consistency</strong> over intensity; track how the child feels rather than chasing numbers.</li>
      </ul>

      <h4>When to be careful</h4>
      <ul>
        <li>For medical conditions, integrate meditation within a clinician-guided plan; avoid replacing indicated treatments.</li>
        <li>Insurance coverage varies; training is often covered only when delivered by a licensed professional (HealthyChildren, 2023).</li>
      </ul>

      <h4>References</h4>
      <ul>
        <li>Barnes, V. A., Davis, H. C., Murzynowski, J. B., & Treiber, F. A. (2004). Impact of meditation on resting and ambulatory blood pressure and heart rate in youth. <i>Psychosomatic Medicine, 66</i>(6), 909–914. https://doi.org/10.1097/01.psy.0000145902.91749.35</li>
        <li>HealthyChildren. (2023, August 16). <i>Just breathe: The importance of meditation breaks for kids</i>. American Academy of Pediatrics. https://www.healthychildren.org/English/healthy-living/emotional-wellness/Pages/Just-Breathe-The-Importance-of-Meditation-Breaks-for-Kids.aspx</li>
      </ul>
    `
  },
  {
    image: '/meditation/benefit-social.jpg',
    title: 'Social & Emotional Skills',
    description:
      'Mindfulness builds self-awareness and self-regulation; empathy and prosocial choices grow as reactivity drops.',
    detail: `
      <h4>What it helps</h4>
      <ul>
        <li>Kids learn to <strong>notice</strong> thoughts/feelings, name them, and choose responses—rather than reacting on autopilot.</li>
        <li>Improves empathy and prosocial behaviour; families report calmer moods and easier transitions.</li>
      </ul>

      <h4>Evidence highlights</h4>
      <ul>
        <li>Mindfulness training helps children observe inner states, creating space to choose behaviours (Garey, 2024).</li>
        <li>Reports include greater attention span, creativity, calmer emotional tone and <strong>heightened empathy</strong> (CBHS Health Fund, 2021).</li>
        <li>Bedtime meditation improves parent–child connection and reduces conflict around sleep (Harden, 2025).</li>
      </ul>

      <h4>How to try (skills kids remember)</h4>
      <ul>
        <li><strong>STOP tool</strong>: Stop – Take a breath – Observe – Proceed. Practise when calm so it’s available when upset.</li>
        <li><strong>Emotion naming</strong>: “I feel… in my… because…”; pair with 3 slow breaths.</li>
        <li><strong>Gratitude/Kindness minute</strong>: recall one helpful act today; imagine doing one tomorrow.</li>
      </ul>

      <h4>When to be careful</h4>
      <ul>
        <li>Don’t demand eye-closed stillness for young children—use movement + breath games first.</li>
        <li>Escalating aggression, trauma exposure or persistent dysregulation → add professional support.</li>
      </ul>

      <h4>References</h4>
      <ul>
        <li>CBHS Health Fund. (2021, November 29). <i>Why sleep meditation for kids can be a dream come true</i>. https://www.cbhs.com.au/mind-and-body/blog/why-sleep-meditation-for-kids-can-be-a-dream-come-true</li>
        <li>Garey, J. (2024, November 22). <i>The power of mindfulness</i>. Child Mind Institute. https://childmind.org/article/the-power-of-mindfulness/</li>
        <li>Harden, L. (2025, August 13). <i>Sleep meditation for kids: Promoting peaceful nights and restful sleep</i>. Huckleberry. https://huckleberrycare.com/blog/sleep-meditation-for-kids-promoting-peaceful-nights-and-restful-sleep</li>
      </ul>
    `
  }
]


</script>

<template>
  <div>
    <!-- Sub-hero -->
    <section class="sub-hero">
      <div class="container d-flex align-items-center justify-content-between">
        <router-link to="/parent" class="btn btn-outline-secondary btn-sm">← Back</router-link>
        <h1 class="h5 fw-bold mx-auto text-center">Benefits of Meditation for Children</h1>
        <div style="width:84px;"></div>
      </div>
    </section>

    <!-- Alternating rows -->
    <section class="py-5">
      <AlternatingBenefitRow
        v-for="(b, i) in benefits"
        :key="b.title"
        :image="b.image"
        :title="b.title"
        :description="b.description"
        :detail="b.detail"   
        :reverse="i % 2 === 1"
        :outline="i % 2 === 1"
      />
    </section>

    <SleepGuide />

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
