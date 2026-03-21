import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  { path: '/login', component: () => import('../views/Login.vue') },
  { path: '/setup', component: () => import('../views/Setup.vue') },
  { path: '/', component: () => import('../views/Dashboard.vue') },
  { path: '/movies', component: () => import('../views/Movies.vue') },
  { path: '/tv', component: () => import('../views/TvShows.vue') },
  { path: '/collections', component: () => import('../views/Collections.vue') },
  { path: '/duplicates', component: () => import('../views/Duplicates.vue') },
  { path: '/rules', component: () => import('../views/Rules.vue') },
  { path: '/settings', component: () => import('../views/Settings.vue') },
  { path: '/:pathMatch(.*)*', redirect: '/' },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
