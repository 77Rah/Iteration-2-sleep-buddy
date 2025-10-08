import { createRouter, createWebHistory } from 'vue-router'
import Home from '../pages/Home.vue'
import ParentPage from '../pages/ParentPage.vue'
import ChildrenPage from '../pages/ChildrenPage.vue'

import ChildrenSleepHabits from '../pages/children/ChildrenSleepHabits.vue'
import ChildrenRoutineCoach from '../pages/children/ChildrenRoutineCoach.vue'
import ChildrenMoveMore from '../pages/children/ChildrenMoveMore.vue'

import ParentEpic8Insights from '@/pages/parent/ParentEpic8Insights.vue'
import ParentEpic4Page from '@/pages/parent/ParentEpic4Page.vue'
// Move-More child pages (relative paths to avoid @ alias issues)
import MoveMoreMap from '../pages/children/MoveMoreMap.vue'
import MoveMoreSleepBoost from '../pages/children/MoveMoreSleepBoost.vue'
import MoveMoreDaytime from '../pages/children/MoveMoreDaytime.vue'

const routes = [
  { path: '/', name: 'home', component: Home },
  { path: '/parent', name: 'parent', component: ParentPage },
  { path: '/children', name: 'children', component: ChildrenPage },

  { path: '/parent/epic8', name: 'ParentEpic8', component: ParentEpic8Insights },
  { path: '/parent/epic4', name: 'ParentEpic4', component: ParentEpic4Page },
  { path: '/parent/epic2', name: 'ParentEpic2', component: () => import('@/pages/parent/ParentEpic2.vue') },

  { path: '/children/sleep-habits', name: 'children-sleep-habits', component: ChildrenSleepHabits },
  {
    path: '/children/routine-coach',
    name: 'children-routine-coach',
    component: ChildrenRoutineCoach,
  },

  {
    path: '/children/move-more',
    component: ChildrenMoveMore,
    children: [
      { path: '', redirect: { name: 'children-move-more-map' } }, // default tab
      { path: 'map', name: 'children-move-more-map', component: MoveMoreMap },
      {
        path: 'sleep-boost',
        name: 'children-move-more-sleep-boost',
        component: MoveMoreSleepBoost,
      },
      { path: 'daytime', name: 'children-move-more-daytime', component: MoveMoreDaytime },
    ],
  },
]

export default createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior() {
    return { top: 0 }
  },
})
