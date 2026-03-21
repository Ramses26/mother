<template>
  <div class="min-h-screen flex items-center justify-center" style="background:#0f1117;">
    <div class="w-full max-w-sm px-6">
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
        <p class="text-slate-400 text-sm">First Run Setup</p>
      </div>

      <div class="rounded-2xl border p-6" style="background:#1a1d27; border-color:#2d3250;">
        <h2 class="text-lg font-semibold text-white mb-2">Set Admin Password</h2>
        <p class="text-slate-400 text-sm mb-6">This is a one-time setup. Choose a strong password.</p>
        <form @submit.prevent="setup">
          <div class="mb-4">
            <label class="label">Password</label>
            <input v-model="password" type="password" class="input" placeholder="Min 8 characters" autofocus />
          </div>
          <div class="mb-4">
            <label class="label">Confirm Password</label>
            <input v-model="confirm" type="password" class="input" placeholder="Repeat password" />
          </div>
          <div v-if="error" class="mb-4 p-3 rounded-lg bg-red-900/30 border border-red-700 text-red-400 text-sm">
            {{ error }}
          </div>
          <button type="submit" :disabled="loading" class="w-full btn-primary py-2.5">
            {{ loading ? 'Setting up...' : 'Set Password & Continue' }}
          </button>
        </form>
      </div>
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
const password = ref('')
const confirm = ref('')
const loading = ref(false)
const error = ref('')

const setup = async () => {
  if (password.value.length < 8) { error.value = 'Password must be at least 8 characters'; return }
  if (password.value !== confirm.value) { error.value = 'Passwords do not match'; return }
  loading.value = true
  error.value = ''
  try {
    await axios.post('/api/setup', { password: password.value })
    authStore.setAuthenticated(true)
    authStore.setSetupRequired(false)
    router.push('/')
  } catch (err) {
    error.value = err.response?.data?.detail || 'Setup failed'
  } finally {
    loading.value = false
  }
}
</script>
