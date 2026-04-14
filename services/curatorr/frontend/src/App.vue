<template>
  <div id="app-root" class="min-h-screen" style="background:#0f1117; color:#e2e8f0;">
    <template v-if="authStore.isAuthenticated && !authStore.setupRequired">
      <nav class="fixed top-0 left-0 right-0 z-50 border-b border-surface-300" style="background:#1a1d27;">
        <div class="flex items-center h-14 px-6 gap-6">
          <!-- Logo -->
          <router-link to="/" class="flex items-center gap-2 mr-4">
            <svg width="28" height="28" viewBox="0 0 32 32">
              <circle cx="16" cy="16" r="15" fill="#0f1117" stroke="#7c3aed" stroke-width="2"/>
              <circle cx="14" cy="14" r="7" fill="none" stroke="white" stroke-width="2"/>
              <line x1="19" y1="19" x2="25" y2="25" stroke="white" stroke-width="2.5" stroke-linecap="round"/>
              <text x="10" y="17" font-size="7" fill="white" font-family="serif" font-weight="bold">★</text>
            </svg>
            <span class="font-bold text-white text-lg tracking-tight">Curatorr</span>
          </router-link>
          <!-- Nav Links -->
          <router-link v-for="link in navLinks" :key="link.to" :to="link.to"
            class="text-sm font-medium transition-colors hover:text-violet-400"
            :class="isActive(link.to) ? 'text-violet-400' : 'text-slate-400'">
            {{ link.label }}
          </router-link>
          <div class="flex-1"/>
          <!-- Logout -->
          <button @click="logout" class="text-slate-400 hover:text-white text-sm transition-colors">
            Sign out
          </button>
        </div>
      </nav>
      <main class="pt-14">
        <router-view/>
      </main>
    </template>
    <template v-else>
      <router-view/>
    </template>
  </div>
</template>

<script setup>
import { computed, onMounted, ref, provide } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from './stores/auth.js'
import axios from 'axios'

const authStore = useAuthStore()
const route = useRoute()
const router = useRouter()

// Provide public URLs to all child components (used by MediaDetail for deep links)
const publicUrls = ref({})
provide('publicUrls', publicUrls)

const loadPublicUrls = async () => {
  try {
    const res = await axios.get('/api/settings')
    publicUrls.value = res.data.public_urls || {}
  } catch {
    // Non-fatal — deep links just won't show
  }
}

const navLinks = [
  { to: '/', label: 'Dashboard' },
  { to: '/movies', label: 'Movies' },
  { to: '/tv', label: 'TV Shows' },
  { to: '/collections', label: 'Collections' },
  { to: '/duplicates', label: 'Duplicates' },
  { to: '/rules', label: 'Rules' },
  { to: '/logs', label: 'Logs' },
  { to: '/settings', label: 'Settings' },
  { to: '/help', label: 'Help' },
]

const isActive = (path) => {
  if (path === '/') return route.path === '/'
  return route.path.startsWith(path)
}

const logout = async () => {
  await axios.post('/api/logout')
  authStore.setAuthenticated(false)
  router.push('/login')
}

onMounted(async () => {
  try {
    const res = await axios.get('/api/auth/status')
    authStore.setSetupRequired(res.data.setup_required)
    authStore.setAuthenticated(res.data.authenticated)
    if (res.data.setup_required) {
      router.push('/setup')
    } else if (!res.data.authenticated && route.path !== '/login') {
      router.push('/login')
    } else if (res.data.authenticated) {
      loadPublicUrls()
    }
  } catch {
    router.push('/login')
  }
})
</script>
