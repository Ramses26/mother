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

    <!-- Plex Connections -->
    <div class="card mb-4">
      <h2 class="font-semibold text-white mb-4">Plex Connections</h2>
      <div v-if="settings" class="space-y-4">
        <div v-for="inst in plexInstances" :key="inst.key" class="p-3 rounded-lg" style="background:#0f1117;">
          <div class="text-sm font-medium text-slate-300 mb-2">{{ inst.label }}</div>
          <div class="space-y-2">
            <div>
              <label class="label text-xs">URL</label>
              <input v-model="connForm[inst.urlKey]" type="url" class="input text-sm"
                :placeholder="inst.urlPlaceholder"/>
            </div>
            <div>
              <label class="label text-xs">Token</label>
              <div class="flex gap-2">
                <input v-model="connForm[inst.tokenKey]"
                  :type="showSecrets[inst.tokenKey] ? 'text' : 'password'"
                  class="input text-sm flex-1"
                  :placeholder="settings.plex?.[inst.tokenDisplay] || 'Enter token'"/>
                <button type="button" @click="toggleSecret(inst.tokenKey)"
                  class="px-2 text-slate-400 hover:text-white text-xs">
                  {{ showSecrets[inst.tokenKey] ? 'Hide' : 'Show' }}
                </button>
              </div>
            </div>
          </div>
          <div class="flex items-center gap-2 mt-2">
            <button @click="testConnection(inst.source)"
              :disabled="testing[inst.source]"
              class="btn-secondary text-xs py-1 px-3">
              {{ testing[inst.source] ? 'Testing…' : 'Test' }}
            </button>
            <span v-if="testResults[inst.source]"
              :class="testResults[inst.source].ok ? 'text-green-400' : 'text-red-400'"
              class="text-xs">
              {{ testResults[inst.source].ok ? '✓' : '✗' }} {{ testResults[inst.source].message }}
            </span>
          </div>
        </div>
        <div v-if="connMsg.plex" :class="connError.plex ? 'text-red-400' : 'text-green-400'" class="text-sm">{{ connMsg.plex }}</div>
        <button @click="saveConnections('plex')" class="btn-primary text-sm">Save Plex</button>
      </div>
    </div>

    <!-- Tautulli Connections -->
    <div class="card mb-4">
      <h2 class="font-semibold text-white mb-4">Tautulli Connections</h2>
      <div v-if="settings" class="space-y-4">
        <div v-for="inst in tautulliInstances" :key="inst.key" class="p-3 rounded-lg" style="background:#0f1117;">
          <div class="text-sm font-medium text-slate-300 mb-2">{{ inst.label }}</div>
          <div class="space-y-2">
            <div>
              <label class="label text-xs">URL</label>
              <input v-model="connForm[inst.urlKey]" type="url" class="input text-sm"
                :placeholder="inst.urlPlaceholder"/>
            </div>
            <div>
              <label class="label text-xs">API Key</label>
              <div class="flex gap-2">
                <input v-model="connForm[inst.keyKey]"
                  :type="showSecrets[inst.keyKey] ? 'text' : 'password'"
                  class="input text-sm flex-1"
                  :placeholder="settings.tautulli?.[inst.keyDisplay] || 'Enter API key'"/>
                <button type="button" @click="toggleSecret(inst.keyKey)"
                  class="px-2 text-slate-400 hover:text-white text-xs">
                  {{ showSecrets[inst.keyKey] ? 'Hide' : 'Show' }}
                </button>
              </div>
            </div>
          </div>
          <div class="flex items-center gap-2 mt-2">
            <button @click="testConnection(inst.source)"
              :disabled="testing[inst.source]"
              class="btn-secondary text-xs py-1 px-3">
              {{ testing[inst.source] ? 'Testing…' : 'Test' }}
            </button>
            <span v-if="testResults[inst.source]"
              :class="testResults[inst.source].ok ? 'text-green-400' : 'text-red-400'"
              class="text-xs">
              {{ testResults[inst.source].ok ? '✓' : '✗' }} {{ testResults[inst.source].message }}
            </span>
          </div>
        </div>
        <div v-if="connMsg.tautulli" :class="connError.tautulli ? 'text-red-400' : 'text-green-400'" class="text-sm">{{ connMsg.tautulli }}</div>
        <button @click="saveConnections('tautulli')" class="btn-primary text-sm">Save Tautulli</button>
      </div>
    </div>

    <!-- API Keys -->
    <div class="card mb-4">
      <h2 class="font-semibold text-white mb-4">API Keys</h2>
      <div v-if="settings" class="space-y-3">
        <div v-for="field in apiKeyFields" :key="field.key">
          <label class="label">{{ field.label }}</label>
          <div class="flex gap-2">
            <input v-model="connForm[field.key]"
              :type="showSecrets[field.key] ? 'text' : 'password'"
              class="input text-sm flex-1"
              :placeholder="settings.api_keys?.[field.display] || 'Enter key'"/>
            <button type="button" @click="toggleSecret(field.key)"
              class="px-2 text-slate-400 hover:text-white text-xs">
              {{ showSecrets[field.key] ? 'Hide' : 'Show' }}
            </button>
          </div>
        </div>
        <div v-if="connMsg.apikeys" :class="connError.apikeys ? 'text-red-400' : 'text-green-400'" class="text-sm">{{ connMsg.apikeys }}</div>
        <button @click="saveConnections('apikeys')" class="btn-primary text-sm">Save API Keys</button>
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
      <div class="flex items-center justify-between mb-3">
        <h2 class="font-semibold text-white">Database Backups</h2>
        <div class="flex items-center gap-2">
          <button @click="checkIntegrity" :disabled="integrityChecking" class="btn-secondary text-xs py-1 px-3">
            {{ integrityChecking ? 'Checking…' : 'Check Integrity' }}
          </button>
          <button @click="createBackup" :disabled="backupCreating" class="btn-secondary text-xs py-1 px-3">
            {{ backupCreating ? 'Creating...' : '+ Create Backup' }}
          </button>
        </div>
      </div>
      <div v-if="integrityResult" :class="integrityResult.ok ? 'text-green-400' : 'text-red-400'" class="text-sm mb-2">
        {{ integrityResult.ok ? '✓ Database integrity OK' : `✗ Integrity check failed: ${integrityResult.result}` }}
      </div>
      <div class="text-xs text-slate-500 mb-3 flex items-center gap-3">
        <span>🕐 Auto-backup: <span class="text-slate-400">Daily at 4:30 AM UTC</span></span>
        <span>·</span>
        <span>Keeps last 14 backups</span>
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
          <div class="flex items-center gap-3">
            <button @click="restoreBackup(b.filename)"
              class="text-amber-500 hover:text-amber-300 text-xs transition-colors">Restore</button>
            <a :href="`/api/settings/backups/${b.filename}`" download
              class="text-slate-400 hover:text-white text-xs transition-colors">Download</a>
          </div>
        </div>
      </div>
    </div>

    <!-- Restore confirmation modal -->
    <div v-if="restoreTarget" class="fixed inset-0 z-50 flex items-center justify-center bg-black/70">
      <div class="rounded-xl border p-6 max-w-sm w-full mx-4" style="background:#1a1d27; border-color:#2d3250;">
        <h3 class="text-white font-semibold mb-2">Restore Backup?</h3>
        <p class="text-slate-400 text-sm mb-4">
          This will replace <strong class="text-white">all current data</strong> with the backup from:
          <br/><code class="text-amber-400">{{ restoreTarget }}</code>
          <br/>This cannot be undone.
        </p>
        <div class="flex gap-3">
          <button @click="confirmRestore" :disabled="restoring" class="btn-danger text-sm flex-1">
            {{ restoring ? 'Restoring…' : 'Restore' }}
          </button>
          <button @click="restoreTarget = null" class="btn-secondary text-sm flex-1">Cancel</button>
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
const integrityChecking = ref(false)
const integrityResult = ref(null)
const restoreTarget = ref(null)
const restoring = ref(false)

// Connection forms (stores new values typed by user — empty = no change)
const connForm = reactive({
  plex_chris_url: '', plex_ali_url: '',
  plex_chris_token: '', plex_ali_token: '',
  tautulli_chris_url: '', tautulli_ali_url: '',
  tautulli_chris_key: '', tautulli_ali_key: '',
  tmdb_api_key: '', omdb_api_key: '', mdblist_api_key: '',
})
const connMsg = reactive({ plex: '', tautulli: '', apikeys: '' })
const connError = reactive({ plex: false, tautulli: false, apikeys: false })
const showSecrets = reactive({})
const testing = reactive({})
const testResults = reactive({})

const pwForm = reactive({ current: '', new_: '', confirm: '' })
const urlForm = reactive({ radarr_hd: '', radarr_4k: '', sonarr_hd: '', sonarr_4k: '', overseerr: '' })

const urlFields = [
  { key: 'radarr_hd', label: 'Radarr HD Public URL', placeholder: 'https://radarrhd.example.com' },
  { key: 'radarr_4k', label: 'Radarr 4K Public URL', placeholder: 'https://radarr4k.example.com' },
  { key: 'sonarr_hd', label: 'Sonarr HD Public URL', placeholder: 'https://sonarrhd.example.com' },
  { key: 'sonarr_4k', label: 'Sonarr 4K Public URL', placeholder: 'https://sonarr4k.example.com' },
  { key: 'overseerr', label: 'Overseerr Public URL', placeholder: 'https://request.example.com' },
]

const plexInstances = [
  {
    key: 'chris', label: 'Chris (Nostromo)', source: 'plex-chris',
    urlKey: 'plex_chris_url', tokenKey: 'plex_chris_token',
    urlPlaceholder: 'http://10.0.0.250:32400', tokenDisplay: 'chris_token',
  },
  {
    key: 'ali', label: 'Ali', source: 'plex-ali',
    urlKey: 'plex_ali_url', tokenKey: 'plex_ali_token',
    urlPlaceholder: 'http://192.168.1.52:32400', tokenDisplay: 'ali_token',
  },
]

const tautulliInstances = [
  {
    key: 'chris', label: 'Chris', source: 'tautulli-chris',
    urlKey: 'tautulli_chris_url', keyKey: 'tautulli_chris_key',
    urlPlaceholder: 'http://tautulli:8181', keyDisplay: 'chris_key',
  },
  {
    key: 'ali', label: 'Ali', source: 'tautulli-ali',
    urlKey: 'tautulli_ali_url', keyKey: 'tautulli_ali_key',
    urlPlaceholder: 'https://tautulli.example.com', keyDisplay: 'ali_key',
  },
]

const apiKeyFields = [
  { key: 'tmdb_api_key', label: 'TMDB API Key', display: 'tmdb' },
  { key: 'omdb_api_key', label: 'OMDB API Key', display: 'omdb' },
  { key: 'mdblist_api_key', label: 'MDBList API Key', display: 'mdblist' },
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
    // Pre-fill URL fields from current settings (not secrets)
    connForm.plex_chris_url = res.data.plex?.chris_url || ''
    connForm.plex_ali_url = res.data.plex?.ali_url || ''
    connForm.tautulli_chris_url = res.data.tautulli?.chris_url || ''
    connForm.tautulli_ali_url = res.data.tautulli?.ali_url || ''
  } catch {}
  loadBackups()
}

const loadBackups = async () => {
  try { const res = await axios.get('/api/settings/backups'); backups.value = res.data } catch {}
}

const toggleSecret = (key) => { showSecrets[key] = !showSecrets[key] }

const testConnection = async (source) => {
  testing[source] = true
  testResults[source] = null
  try {
    const res = await axios.post('/api/settings/test-connection', { source })
    testResults[source] = res.data
  } catch (e) {
    testResults[source] = { ok: false, message: e.response?.data?.detail || 'Request failed' }
  } finally {
    testing[source] = false
  }
}

const saveConnections = async (group) => {
  connMsg[group] = ''
  connError[group] = false
  let payload = {}

  if (group === 'plex') {
    payload = {
      plex_chris_url: connForm.plex_chris_url,
      plex_ali_url: connForm.plex_ali_url,
    }
    if (connForm.plex_chris_token) payload.plex_chris_token = connForm.plex_chris_token
    if (connForm.plex_ali_token) payload.plex_ali_token = connForm.plex_ali_token
  } else if (group === 'tautulli') {
    payload = {
      tautulli_chris_url: connForm.tautulli_chris_url,
      tautulli_ali_url: connForm.tautulli_ali_url,
    }
    if (connForm.tautulli_chris_key) payload.tautulli_chris_key = connForm.tautulli_chris_key
    if (connForm.tautulli_ali_key) payload.tautulli_ali_key = connForm.tautulli_ali_key
  } else if (group === 'apikeys') {
    if (connForm.tmdb_api_key) payload.tmdb_api_key = connForm.tmdb_api_key
    if (connForm.omdb_api_key) payload.omdb_api_key = connForm.omdb_api_key
    if (connForm.mdblist_api_key) payload.mdblist_api_key = connForm.mdblist_api_key
  }

  try {
    await axios.patch('/api/settings/connections', payload)
    connMsg[group] = 'Saved — takes effect on next sync'
    // Clear secret fields after save
    if (group === 'plex') { connForm.plex_chris_token = ''; connForm.plex_ali_token = '' }
    if (group === 'tautulli') { connForm.tautulli_chris_key = ''; connForm.tautulli_ali_key = '' }
    if (group === 'apikeys') { connForm.tmdb_api_key = ''; connForm.omdb_api_key = ''; connForm.mdblist_api_key = '' }
    await load()
    setTimeout(() => { connMsg[group] = '' }, 4000)
  } catch (e) {
    connMsg[group] = e.response?.data?.detail || 'Save failed'
    connError[group] = true
  }
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

const checkIntegrity = async () => {
  integrityChecking.value = true
  integrityResult.value = null
  try {
    const res = await axios.get('/api/settings/backups/integrity')
    integrityResult.value = res.data
  } catch (e) {
    integrityResult.value = { ok: false, result: e.response?.data?.detail || 'Check failed' }
  } finally {
    integrityChecking.value = false
  }
}

const restoreBackup = (filename) => {
  restoreTarget.value = filename
}

const confirmRestore = async () => {
  if (!restoreTarget.value) return
  restoring.value = true
  try {
    const res = await axios.post(`/api/settings/backups/${restoreTarget.value}/restore`)
    restoreTarget.value = null
    backupMsg.value = res.data.message
    backupError.value = false
  } catch (e) {
    backupMsg.value = e.response?.data?.detail || 'Restore failed'
    backupError.value = true
    restoreTarget.value = null
  } finally {
    restoring.value = false
    setTimeout(() => { backupMsg.value = '' }, 8000)
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
