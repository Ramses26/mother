<template>
  <div class="min-h-screen flex items-center justify-center" style="background:#0f1117;">
    <div class="w-full max-w-sm px-6">
      <!-- Logo -->
      <div class="text-center mb-8">
        <div class="flex items-center justify-center gap-3 mb-3">
          <svg width="48" height="48" viewBox="0 0 32 32">
            <circle cx="16" cy="16" r="15" fill="#0f1117" stroke="#7c3aed" stroke-width="2"/>
            <circle cx="14" cy="14" r="7" fill="none" stroke="white" stroke-width="2"/>
            <line x1="19" y1="19" x2="25" y2="25" stroke="white" stroke-width="2.5" stroke-linecap="round"/>
            <text x="10" y="17" font-size="7" fill="white" font-family="serif" font-weight="bold">★</text>
          </svg>
          <span class="text-3xl font-bold text-white tracking-tight">Curatorr</span>
        </div>
        <p class="text-slate-400 text-sm">Media Intelligence & Curation</p>
      </div>

      <!-- Form -->
      <div class="rounded-2xl border p-6" style="background:#1a1d27; border-color:#2d3250;">
        <h2 class="text-lg font-semibold text-white mb-6">Sign in</h2>
        <form @submit.prevent="login">
          <div class="mb-4">
            <label class="label">Username</label>
            <input
              v-model="username"
              type="text"
              autocomplete="username"
              class="input"
              placeholder="Enter username"
              :disabled="loading"
              autofocus
            />
          </div>
          <div class="mb-4">
            <label class="label">Password</label>
            <input
              v-model="password"
              type="password"
              autocomplete="current-password"
              class="input"
              placeholder="Enter password"
              :disabled="loading"
            />
          </div>
          <div v-if="error" class="mb-4 p-3 rounded-lg bg-red-900/30 border border-red-700 text-red-400 text-sm">
            {{ error }}
          </div>
          <button type="submit" :disabled="loading"
            class="w-full btn-primary flex items-center justify-center gap-2 py-2.5">
            <span v-if="loading" class="animate-spin h-4 w-4 border-2 border-white/30 border-t-white rounded-full"></span>
            <span>{{ loading ? 'Signing in...' : 'Sign in' }}</span>
          </button>
        </form>
      </div>

      <!-- Rate limit warning -->
      <p class="text-center text-slate-600 text-xs mt-4">
        5 attempts per minute limit
      </p>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'
import { useAuthStore } from '../stores/auth.js'

const router = useRouter()
const authStore = useAuthStore()
const username = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')

const login = async () => {
  if (!username.value || !password.value) return
  loading.value = true
  error.value = ''
  try {
    await axios.post('/api/login', { username: username.value, password: password.value })
    authStore.setAuthenticated(true)
    router.push('/')
  } catch (err) {
    const status = err.response?.status
    if (status === 429) {
      error.value = 'Too many attempts. Please wait a minute.'
    } else if (status === 403) {
      router.push('/setup')
    } else {
      error.value = 'Invalid username or password'
    }
    password.value = ''
  } finally {
    loading.value = false
  }
}
</script>
