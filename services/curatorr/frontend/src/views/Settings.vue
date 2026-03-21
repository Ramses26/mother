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

    <!-- Public URLs (deep links) -->
    <div class="card mb-4">
      <h2 class="font-semibold text-white mb-1">Public URLs</h2>
      <p class="text-slate-500 text-xs mb-4">Used to build "Open in Radarr/Sonarr" deep links in the media detail panel.</p>
      <div v-if="settings" class="space-y-3">
        <div v-for="field in urlFields" :key="field.key">
          <label class="label">{{ field.label }}</label>
          <input v-model="urlForm[field.key]" type="url" class="input text-sm" :placeholder="field.placeholder"/>
        </div>
        <div v-if="urlMsg" :class="urlError ? 'text-red-400' : 'text-green-400'" class="text-sm">{{ urlMsg }}</div>
        <button @click="saveUrls" class="btn-primary text-sm">Save URLs</button>
      </div>
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

    <!-- DB Backups -->
    <div class="card mb-4">
      <div class="flex items-center justify-between mb-4">
        <h2 class="font-semibold text-white">Database Backups</h2>
        <button @click="createBackup" :disabled="backupCreating" class="btn-secondary text-xs py-1 px-3">
          {{ backupCreating ? 'Creating...' : '+ Create Backup' }}
        </button>
      </div>
      <div class="text-xs text-slate-500 mb-3 flex items-center gap-3">
        <span>🕐 Auto-backup: <span class="text-slate-400">Daily at 4:30 AM UTC</span></span>
        <span>·</span>
        <span>Keeps last 7 backups</span>
      </div>
      <div v-if="backupMsg" :class="backupError ? 'text-red-400' : 'text-green-400'" class="text-sm mb-3">{{ backupMsg }}</div>
      <div v-if="backups.length === 0" class="text-slate-500 text-sm">No backups yet.</div>
      <div v-else class="space-y-2">
        <div v-for="b in backups" :key="b.filename"
          class="flex items-center justify-between p-2 rounded text-sm" style="background:#0f1117;">
          <div>
            <div class="text-slate-300 font-mono text-xs">{{ b.filename }}</div>
            <div class="text-slate-500 text-xs">{{ fmtSize(b.size_bytes) }} · {{ fmtDate(b.created_at) }}</div>
          </div>
          <a :href="`/api/settings/backups/${b.filename}`" download
            class="text-slate-400 hover:text-white text-xs transition-colors">Download</a>
        </div>
      </div>
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
const urlMsg = ref('')
const urlError = ref(false)
const backups = ref([])
const backupCreating = ref(false)
const backupMsg = ref('')
const backupError = ref(false)

const pwForm = reactive({ current: '', new_: '', confirm: '' })
const urlForm = reactive({ radarr_hd: '', radarr_4k: '', sonarr_hd: '', sonarr_4k: '', overseerr: '' })

const urlFields = [
  { key: 'radarr_hd', label: 'Radarr HD Public URL', placeholder: 'https://radarrhd.example.com' },
  { key: 'radarr_4k', label: 'Radarr 4K Public URL', placeholder: 'https://radarr4k.example.com' },
  { key: 'sonarr_hd', label: 'Sonarr HD Public URL', placeholder: 'https://sonarrhd.example.com' },
  { key: 'sonarr_4k', label: 'Sonarr 4K Public URL', placeholder: 'https://sonarr4k.example.com' },
  { key: 'overseerr', label: 'Overseerr Public URL', placeholder: 'https://request.example.com' },
]

const syncSources = [
  { value: 'all', label: 'Sync Everything' },
  { value: 'radarr', label: 'Radarr' },
  { value: 'sonarr', label: 'Sonarr' },
  { value: 'plex', label: 'Plex' },
  { value: 'tautulli', label: 'Tautulli' },
  { value: 'ratings', label: 'Ratings' },
]

const load = async () => {
  try {
    const res = await axios.get('/api/settings')
    settings.value = res.data
    const urls = res.data.public_urls || {}
    Object.assign(urlForm, {
      radarr_hd: urls.radarr_hd || '',
      radarr_4k: urls.radarr_4k || '',
      sonarr_hd: urls.sonarr_hd || '',
      sonarr_4k: urls.sonarr_4k || '',
      overseerr: urls.overseerr || '',
    })
  } catch {}
  loadBackups()
}

const loadBackups = async () => {
  try { const res = await axios.get('/api/settings/backups'); backups.value = res.data } catch {}
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

const saveUrls = async () => {
  try {
    await axios.patch('/api/settings/connections', { ...urlForm })
    urlMsg.value = 'URLs saved — deep links will update immediately'
    urlError.value = false
    setTimeout(() => { urlMsg.value = '' }, 4000)
  } catch (e) {
    urlMsg.value = e.response?.data?.detail || 'Save failed'
    urlError.value = true
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

const createBackup = async () => {
  backupCreating.value = true
  backupMsg.value = ''
  backupError.value = false
  try {
    const res = await axios.post('/api/settings/backups/create')
    backupMsg.value = `Backup created: ${res.data.filename}`
    await loadBackups()
  } catch (e) {
    backupMsg.value = e.response?.data?.detail || 'Backup failed'
    backupError.value = true
  } finally {
    backupCreating.value = false
    setTimeout(() => { backupMsg.value = '' }, 5000)
  }
}

const confirmReset = async () => {
  if (!confirm('Are you sure? This will delete all synced media data.')) return
  try {
    await axios.post('/api/settings/reset')
    alert('Data reset complete')
  } catch { alert('Reset failed') }
}

const fmtSize = (bytes) => {
  if (!bytes) return '0 B'
  const mb = bytes / 1_048_576
  return mb >= 1 ? `${mb.toFixed(1)} MB` : `${bytes} B`
}

const fmtDate = (d) => d ? new Date(d).toLocaleString() : ''

onMounted(load)
</script>
