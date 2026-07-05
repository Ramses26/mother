<template>
  <div class="p-6 max-w-6xl mx-auto">
    <div class="flex items-center justify-between mb-6">
      <div class="flex items-center gap-2">
        <h1 class="text-2xl font-bold text-white">Duplicates</h1>
        <router-link to="/help#duplicates" class="text-slate-600 hover:text-slate-300 text-xs px-1 mt-1" title="Help">?</router-link>
      </div>
      <button @click="loadCurrentTab" :disabled="loading" class="btn-secondary text-sm">Refresh</button>
    </div>

    <!-- Tabs -->
    <div class="flex flex-wrap gap-2 mb-6">
      <button v-for="t in tabs" :key="t.key" @click="tab = t.key"
        class="px-4 py-1.5 rounded text-sm transition-colors"
        :class="tab === t.key ? 'bg-violet-600 text-white' : 'bg-surface-200 text-slate-400 hover:text-white'">
        {{ t.label }}
        <span v-if="tabCount(t.key)" class="ml-1 text-xs opacity-70">({{ tabCount(t.key) }})</span>
      </button>
    </div>

    <div v-if="loading" class="flex items-center justify-center py-20">
      <div class="animate-spin h-8 w-8 border-2 border-violet-500/30 border-t-violet-500 rounded-full"></div>
    </div>

    <!-- ── Scan tabs (Synology + Unraid) ────────────────────────────── -->
    <template v-else-if="isScanTab">
      <div v-if="scanError" class="text-center py-10 text-red-400">{{ scanError }}</div>
      <template v-else>
        <!-- Banner -->
        <div class="mb-5 p-3 rounded-lg bg-surface-100 border border-surface-300 text-xs text-slate-400 leading-relaxed">
          <template v-if="currentTab.server === 'synology'">
            Scanning <strong class="text-slate-300">Synology (Chris)</strong> NFS paths directly.
            Deletes remove files from Synology only — run the Unraid scan separately to clean that mirror.
          </template>
          <template v-else>
            Scanning <strong class="text-slate-300">Unraid (Ali)</strong> via the Unraid Agent.
            Deletes remove files from Unraid only — run the Synology scan separately to clean that side.
            <span v-if="scanData?.unraid_agent?.ok === false" class="text-red-400 ml-1">
              · Agent unreachable: {{ scanData?.unraid_agent?.error }}
            </span>
            <span v-else-if="scanData?.unraid_agent?.ok" class="text-green-500 ml-1">· Agent OK</span>
          </template>
          <span v-if="scanning" class="text-amber-400 ml-1">· scanning...</span>
          <span v-else-if="scanData?.cached" class="text-slate-500"> · cached {{ scanData.cached_age_s }}s ago</span>
          <button @click="load(tab, false)" :disabled="scanning" class="ml-2 text-violet-400 hover:text-violet-300 underline disabled:opacity-40">force refresh</button>
        </div>

        <!-- Profile Authority correction failed — "kept" picks below are raw-score only, unverified against Radarr/Sonarr -->
        <div v-if="scanData?.profile_authority?.ok === false"
          class="mb-5 p-3 rounded-lg bg-red-900/20 border border-red-700/50 text-xs text-red-400">
          ⚠️ Profile Authority check against Radarr/Sonarr failed this scan — "Keep" picks below reflect raw TRaSH score
          only and have NOT been verified against what Radarr/Sonarr actually track. Review carefully before bulk-deleting.
          <span class="text-red-300">({{ scanData.profile_authority.error }})</span>
        </div>

        <!-- Agent unavailable notice for Unraid tabs -->
        <div v-if="currentTab.server === 'unraid' && scanData?.unraid_agent?.ok === false"
          class="text-center py-16 text-slate-500">
          <div class="text-4xl mb-4">⚠️</div>
          <div class="text-slate-300 font-semibold mb-2">Unraid Agent Unreachable</div>
          <div class="text-sm">{{ scanData?.unraid_agent?.error }}</div>
          <div class="text-xs mt-2">Check that the agent container is running on Unraid (192.168.1.10:8100)</div>
        </div>

        <template v-else>
          <!-- Global sticky toolbar when files selected -->
          <div v-if="totalSelected > 0"
            class="sticky top-0 z-10 mb-4 p-3 rounded-lg bg-violet-900/80 border border-violet-600 backdrop-blur flex items-center justify-between gap-3">
            <span class="text-white text-sm font-medium">
              {{ totalSelected }} file(s) selected · {{ formatSize(totalSelectedBytes) }} to free
            </span>
            <div class="flex gap-2">
              <button @click="clearAllSelections" class="btn-secondary text-xs py-1">Clear</button>
              <button @click="showBulkConfirm = true" class="btn-danger text-sm px-4">
                Delete {{ totalSelected }} from {{ currentTab.server === 'synology' ? 'Synology' : 'Unraid' }}
              </button>
            </div>
          </div>

          <!-- Folder type sections -->
          <div v-for="ftype in activeFtypes" :key="ftype.key" class="mb-8">
            <template v-if="serverData?.[ftype.key]?.length">
              <div class="flex items-center justify-between mb-3">
                <div class="flex items-center gap-3">
                  <input type="checkbox" class="accent-violet-500 w-4 h-4 cursor-pointer"
                    :checked="isSectionAllSelected(ftype.key)"
                    :indeterminate.prop="isSectionPartialSelected(ftype.key)"
                    @change="toggleSectionAll(ftype.key, $event.target.checked)" />
                  <h3 class="text-sm font-semibold text-slate-200">{{ ftype.label }}</h3>
                  <span class="text-xs text-slate-500">
                    {{ serverData[ftype.key].length }} group(s) ·
                    {{ formatSize(scanData.summary?.[currentTab.server]?.[ftype.key]?.deletable_bytes) }} deletable
                  </span>
                </div>
                <button v-if="sectionSelectedCount(ftype.key) > 0"
                  @click="showBulkConfirm = true" class="btn-danger text-xs py-1 px-3">
                  Delete {{ sectionSelectedCount(ftype.key) }} selected
                </button>
              </div>

              <div class="space-y-3">
                <div v-for="group in serverData[ftype.key]" :key="group.id" class="card">
                  <div class="flex items-start justify-between mb-2">
                    <div>
                      <span class="font-semibold text-white">{{ group.title }}</span>
                      <span v-if="group.episode" class="ml-2 text-violet-400 text-sm font-mono">{{ group.episode }}</span>
                    </div>
                    <span class="text-xs text-slate-500">
                      {{ group.versions.length }} copies · {{ formatSize(group.total_size_bytes) }} total
                    </span>
                  </div>

                  <div class="space-y-2">
                    <div v-for="(v, idx) in group.versions" :key="v.file_path"
                      class="flex items-start gap-3 p-2 rounded-lg border"
                      :class="idx === 0 ? 'border-green-700/50 bg-green-900/10' : 'border-surface-300 bg-surface-100'">

                      <div class="pt-0.5 w-5 flex-shrink-0">
                        <input v-if="idx > 0" type="checkbox" class="accent-violet-500 w-4 h-4 cursor-pointer"
                          :checked="selected.has(v.file_path)"
                          @change="toggleFile(v)" />
                        <span v-else class="text-green-500 text-xs leading-5">✓</span>
                      </div>

                      <div class="flex-1 min-w-0">
                        <div class="text-xs font-mono text-slate-300 truncate" :title="v.file_path">{{ v.filename }}</div>
                        <div class="flex flex-wrap gap-3 mt-1 text-xs text-slate-500">
                          <span :class="v.resolution === '4K' ? 'text-violet-400' : v.resolution === '1080p' ? 'text-blue-400' : ''">
                            {{ v.resolution }}
                          </span>
                          <span v-if="v.source" class="text-amber-400/80">{{ v.source }}</span>
                          <span v-if="v.hdr" class="text-cyan-400/80">{{ v.hdr }}</span>
                          <span v-if="v.video_codec" class="uppercase">{{ v.video_codec }}</span>
                          <span>{{ formatSize(v.file_size_bytes) }}</span>
                          <span class="font-mono" :class="idx === 0 ? 'text-green-400' : 'text-slate-400'">
                            TRaSH {{ v.trash_score }}
                          </span>
                        </div>
                      </div>

                      <div class="flex-shrink-0 self-start pt-0.5 text-right">
                        <span v-if="idx === 0" class="text-green-500 text-xs font-medium">Keep</span>
                        <span v-else class="text-red-400 text-xs">Delete</span>
                        <div v-if="idx === 0" class="text-[10px] mt-0.5"
                          :class="v.kept_reason === 'profile_authority' ? 'text-violet-400' : 'text-slate-500'"
                          :title="v.kept_reason === 'profile_authority'
                            ? 'Radarr/Sonarr tracks this exact file — kept regardless of TRaSH score'
                            : 'Kept because it has the highest TRaSH score'">
                          {{ v.kept_reason === 'profile_authority' ? 'kept: tracked file' : 'kept: highest score' }}
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </template>
            <div v-else-if="serverData" class="text-sm text-slate-600 py-2">
              {{ ftype.label }}: no duplicates found
            </div>
          </div>

          <div v-if="scanData && activeGroupCount === 0 && serverData" class="text-center py-20 text-slate-500">
            No duplicates found
          </div>
        </template>
      </template>
    </template>

    <!-- ── Bulk delete confirmation modal ────────────────────────────── -->
    <div v-if="showBulkConfirm" class="fixed inset-0 bg-black/70 flex items-center justify-center z-50"
      @click.self="showBulkConfirm = false">
      <div class="card max-w-lg w-full mx-4 max-h-[80vh] flex flex-col">
        <h3 class="font-semibold text-white mb-2">
          Delete from {{ currentTab.server === 'synology' ? 'Synology' : 'Unraid' }}?
        </h3>
        <p class="text-slate-400 text-sm mb-1">{{ totalSelected }} file(s) · {{ formatSize(totalSelectedBytes) }}</p>
        <p class="text-xs text-amber-400 mb-3">
          Files will be permanently deleted from
          <strong>{{ currentTab.server === 'synology' ? 'Synology only' : 'Unraid only' }}</strong>.
          The other server is not affected — clean independently.
        </p>
        <div class="overflow-y-auto flex-1 mb-4 space-y-1">
          <div v-for="path in [...selected]" :key="path"
            class="text-xs font-mono text-slate-400 truncate bg-surface-100 px-2 py-1 rounded" :title="path">
            {{ path.split('/').slice(-2).join('/') }}
          </div>
        </div>
        <div class="flex gap-3 justify-end flex-shrink-0">
          <button @click="showBulkConfirm = false" class="btn-secondary text-sm">Cancel</button>
          <button @click="confirmBulkDelete" :disabled="bulkDeleting" class="btn-danger text-sm">
            {{ bulkDeleting ? 'Deleting...' : `Delete ${totalSelected} File(s)` }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import axios from 'axios'

// ── Tab config ─────────────────────────────────────────────────────────────
const tabs = [
  { key: 'syn-movies',    label: 'Synology Movies',  server: 'synology', ftypes: ['hd_movies', '4k_movies'] },
  { key: 'syn-tv',        label: 'Synology TV',       server: 'synology', ftypes: ['hd_tv', '4k_tv'] },
  { key: 'unraid-movies', label: 'Unraid Movies',     server: 'unraid',   ftypes: ['hd_movies', '4k_movies'] },
  { key: 'unraid-tv',     label: 'Unraid TV',         server: 'unraid',   ftypes: ['hd_tv', '4k_tv'] },
]

const ftypeMap = {
  hd_movies:    { key: 'hd_movies',  label: 'HD Movies (1080p & below)' },
  '4k_movies':  { key: '4k_movies',  label: '4K Movies' },
  hd_tv:        { key: 'hd_tv',      label: 'HD TV Shows' },
  '4k_tv':      { key: '4k_tv',      label: '4K TV Shows' },
}

// ── State ──────────────────────────────────────────────────────────────────
const tab = ref('syn-movies')
const loading = ref(false)
const scanning = ref(false)
const scanData = ref(null)
const scanError = ref('')
const selected = ref(new Set())
const showBulkConfirm = ref(false)
const bulkDeleting = ref(false)
let _pollTimer = null

// ── Computed ───────────────────────────────────────────────────────────────
const currentTab = computed(() => tabs.find(t => t.key === tab.value))
const isScanTab = computed(() => !!currentTab.value)
const activeFtypes = computed(() => (currentTab.value?.ftypes ?? []).map(k => ftypeMap[k]))

// Data for the currently active server
const serverData = computed(() => {
  if (!scanData.value) return null
  const srv = currentTab.value?.server
  return srv ? scanData.value[srv] : null
})

const activeGroupCount = computed(() => {
  if (!serverData.value) return 0
  return activeFtypes.value.reduce((n, ft) => n + (serverData.value[ft.key]?.length ?? 0), 0)
})

const tabCount = (key) => {
  if (!scanData.value) return 0
  const t = tabs.find(x => x.key === key)
  if (!t) return 0
  const srv = scanData.value[t.server]
  if (!srv) return 0
  return t.ftypes.reduce((n, fk) => n + (srv[fk]?.length ?? 0), 0)
}

// ── Load ───────────────────────────────────────────────────────────────────
const loadCurrentTab = () => load(tab.value, false)

const _stopPoll = () => { if (_pollTimer) { clearTimeout(_pollTimer); _pollTimer = null } }

const _pollOnce = () => {
  _pollTimer = setTimeout(async () => {
    _pollTimer = null
    try {
      const res = await axios.get('/api/duplicates/scan', { params: { refresh: false } })
      scanData.value = res.data
      if (res.data.scanning) {
        _pollTimer = setTimeout(_pollOnce, 6000)
      } else {
        scanning.value = false
        loading.value = false
      }
    } catch {
      scanning.value = false
      loading.value = false
    }
  }, 6000)
}

const load = async (tabKey, useCache = true) => {
  _stopPoll()
  loading.value = true
  scanning.value = false
  scanError.value = ''
  selected.value = new Set()
  try {
    const res = await axios.get('/api/duplicates/scan', { params: { refresh: !useCache } })
    scanData.value = res.data
    if (res.data.scanning) {
      scanning.value = true
      // Keep loading spinner if we have no real data yet
      if (!res.data.cached) {
        // Show scanning banner but keep spinner until first data arrives
        _pollOnce()
      } else {
        // We have stale data to show — stop spinner, show stale data + scanning badge
        loading.value = false
        _pollOnce()
      }
    } else {
      loading.value = false
    }
  } catch (e) {
    scanError.value = e?.response?.data?.detail || 'Scan failed'
    loading.value = false
    scanning.value = false
  }
}

watch(tab, (t) => load(t, true))
onMounted(() => load('syn-movies', true))
onUnmounted(() => _stopPoll())

// ── Utilities ──────────────────────────────────────────────────────────────
const formatSize = (bytes) => {
  if (!bytes) return '—'
  const gb = bytes / 1_073_741_824
  return gb >= 1 ? `${gb.toFixed(1)} GB` : `${(bytes / 1_048_576).toFixed(0)} MB`
}

// ── Selection helpers ──────────────────────────────────────────────────────
const toggleFile = (v) => {
  const s = new Set(selected.value)
  if (s.has(v.file_path)) s.delete(v.file_path)
  else s.add(v.file_path)
  selected.value = s
}

const sectionCandidates = (ftypeKey) => {
  if (!serverData.value?.[ftypeKey]) return []
  return serverData.value[ftypeKey].flatMap(g => g.versions.slice(1))
}

const sectionSelectedCount = (ftypeKey) =>
  sectionCandidates(ftypeKey).filter(v => selected.value.has(v.file_path)).length

const isSectionAllSelected = (ftypeKey) => {
  const c = sectionCandidates(ftypeKey)
  return c.length > 0 && c.every(v => selected.value.has(v.file_path))
}
const isSectionPartialSelected = (ftypeKey) => {
  const c = sectionCandidates(ftypeKey)
  const n = c.filter(v => selected.value.has(v.file_path)).length
  return n > 0 && n < c.length
}
const toggleSectionAll = (ftypeKey, checked) => {
  const s = new Set(selected.value)
  for (const v of sectionCandidates(ftypeKey)) {
    if (checked) s.add(v.file_path)
    else s.delete(v.file_path)
  }
  selected.value = s
}
const clearAllSelections = () => { selected.value = new Set() }

const totalSelected = computed(() => selected.value.size)

const totalSelectedBytes = computed(() => {
  if (!serverData.value) return 0
  let total = 0
  for (const ft of activeFtypes.value) {
    for (const v of sectionCandidates(ft.key)) {
      if (selected.value.has(v.file_path)) total += v.file_size_bytes || 0
    }
  }
  return total
})

// ── Bulk delete ────────────────────────────────────────────────────────────
const confirmBulkDelete = async () => {
  bulkDeleting.value = true
  try {
    const items = [...selected.value].map(fp => ({ file_path: fp }))
    const isUnraid = currentTab.value?.server === 'unraid'
    const endpoint = isUnraid ? '/api/duplicates/unraid-delete' : '/api/duplicates/bulk-delete'
    const res = await axios.post(endpoint, { items, dry_run: false })
    showBulkConfirm.value = false
    selected.value = new Set()
    await load(tab.value, false)
    if (res.data.failed > 0) {
      alert(`Deleted ${res.data.deleted}, failed ${res.data.failed}. Check logs.`)
    }
  } catch (e) {
    alert(e?.response?.data?.detail || 'Bulk delete failed')
  } finally {
    bulkDeleting.value = false
  }
}
</script>
