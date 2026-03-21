<template>
  <div class="p-6 max-w-2xl mx-auto">
    <h1 class="text-2xl font-bold text-white mb-6">Settings</h1>

    <!-- Security -->
    <div class="card mb-4">
      <h2 class="font-semibold text-white mb-4">Security</h2>
      <form @submit.prevent="changePassword" class="space-y-3">
        <div>
          <label class="label">Current Password</label>
          <input v-model="pwForm.current" type="password" class="input"/>
        </div>
        <div>
          <label class="label">New Password</label>
          <input v-model="pwForm.new_" type="password" class="input"/>
        </div>
        <div>
          <label class="label">Confirm New Password</label>
          <input v-model="pwForm.confirm" type="password" class="input"/>
        </div>
        <div v-if="pwMsg" :class="pwError ? 'text-red-400' : 'text-green-400'" class="text-sm">{{ pwMsg }}</div>
        <button type="submit" class="btn-primary text-sm">Update Password</button>
      </form>
    </div>

    <!-- API Keys -->
    <div class="card mb-4">
      <h2 class="font-semibold text-white mb-4">API Keys (masked)</h2>
      <div v-if="settings" class="space-y-2 text-sm">
        <div v-for="(val, key) in settings.api_keys" :key="key" class="flex justify-between">
          <span class="text-slate-400 capitalize">{{ key }}</span>
          <code class="text-slate-300 font-mono">{{ val || 'Not configured' }}</code>
        </div>
      </div>
    </div>

    <!-- Connections -->
    <div class="card mb-4">
      <h2 class="font-semibold text-white mb-4">Connections</h2>
      <div v-if="settings" class="space-y-2 text-sm">
        <div class="flex justify-between">
          <span class="text-slate-400">Chris Plex</span>
          <span class="text-slate-300">{{ settings.plex?.chris_url }}</span>
        </div>
        <div class="flex justify-between">
          <span class="text-slate-400">Ali Plex</span>
          <span class="text-slate-300">{{ settings.plex?.ali_url || 'Not configured' }}</span>
        </div>
        <div class="flex justify-between">
          <span class="text-slate-400">Telegram Chat</span>
          <span class="text-slate-300">{{ settings.telegram_chat_id || 'Not configured' }}</span>
        </div>
      </div>
    </div>

    <!-- Sync -->
    <div class="card mb-4">
      <h2 class="font-semibold text-white mb-4">Manual Sync</h2>
      <div class="grid grid-cols-2 gap-2">
        <button v-for="s in syncSources" :key="s.value"
          @click="triggerSync(s.value)" :disabled="syncing === s.value"
          class="btn-secondary text-sm py-2">
          {{ syncing === s.value ? 'Syncing...' : s.label }}
        </button>
      </div>
      <div v-if="syncMsg" class="mt-3 text-sm text-green-400">{{ syncMsg }}</div>
    </div>

    <!-- Danger Zone -->
    <div class="card border-red-800/50">
      <h2 class="font-semibold text-red-400 mb-4">Danger Zone</h2>
      <p class="text-slate-400 text-sm mb-4">Reset all synced media data. This will clear all movies, TV shows, watch history, and ratings. Auth and rules are preserved.</p>
      <button @click="confirmReset" class="btn-danger text-sm">Reset All Data</button>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import axios from 'axios'

const settings = ref(null)
const syncing = ref('')
const syncMsg = ref('')
const pwMsg = ref('')
const pwError = ref(false)

const pwForm = reactive({ current: '', new_: '', confirm: '' })

const syncSources = [
  { value: 'all', label: 'Sync Everything' },
  { value: 'radarr', label: 'Radarr' },
  { value: 'sonarr', label: 'Sonarr' },
  { value: 'plex', label: 'Plex' },
  { value: 'tautulli', label: 'Tautulli' },
  { value: 'ratings', label: 'Ratings' },
]

const load = async () => {
  try { const res = await axios.get('/api/settings'); settings.value = res.data } catch {}
}

const changePassword = async () => {
  if (pwForm.new_ !== pwForm.confirm) { pwMsg.value = 'Passwords do not match'; pwError.value = true; return }
  try {
    await axios.post('/api/settings/change-password', {
      current_password: pwForm.current, new_password: pwForm.new_,
    })
    pwMsg.value = 'Password updated successfully'
    pwError.value = false
    pwForm.current = ''; pwForm.new_ = ''; pwForm.confirm = ''
  } catch (e) {
    pwMsg.value = e.response?.data?.detail || 'Password change failed'
    pwError.value = true
  }
}

const triggerSync = async (source) => {
  syncing.value = source
  syncMsg.value = ''
  try {
    await axios.post('/api/sync/trigger', { source })
    syncMsg.value = `${source} sync triggered`
  } catch {} finally {
    setTimeout(() => { syncing.value = ''; syncMsg.value = '' }, 5000)
  }
}

const confirmReset = async () => {
  if (!confirm('Are you sure? This will delete all synced media data.')) return
  try {
    await axios.post('/api/settings/reset')
    alert('Data reset complete')
  } catch { alert('Reset failed') }
}

onMounted(load)
</script>
