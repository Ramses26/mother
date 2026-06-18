<template>
  <div class="p-6 max-w-6xl mx-auto">
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold text-white">Sync Status</h1>
      <div class="flex items-center gap-3">
        <span class="text-xs text-slate-500">
          Source of truth: Radarr/Sonarr (Synology) → Unraid
        </span>
        <button @click="refresh" :disabled="loading" class="btn-secondary text-sm">
          {{ loading ? 'Scanning…' : 'Refresh' }}
        </button>
      </div>
    </div>

    <!-- Library tabs -->
    <div class="flex gap-2 mb-6">
      <button v-for="t in ['Movies', 'TV Shows']" :key="t"
        @click="library = t"
        class="px-4 py-1.5 rounded text-sm transition-colors"
        :class="library === t ? 'bg-violet-600 text-white' : 'bg-surface-200 text-slate-400 hover:text-white'">
        {{ t }}
      </button>
    </div>

    <!-- ── MOVIES ─────────────────────────────────────────────────────── -->
    <template v-if="library === 'Movies'">
      <div v-if="movieData?.status === 'scanning' || !movieData" class="text-center py-20">
        <div class="animate-spin h-8 w-8 border-2 border-violet-500/30 border-t-violet-500 rounded-full mx-auto mb-4"></div>
        <div class="text-slate-400 text-sm">Querying Radarr + Unraid Agent…</div>
      </div>
      <div v-else-if="movieData?.status === 'error'" class="text-center py-10 text-red-400">
        {{ movieData.error }}
      </div>
      <template v-else>
        <!-- Summary cards -->
        <div class="grid grid-cols-2 md:grid-cols-5 gap-3 mb-6">
          <div class="rounded-lg p-4 text-center" style="background:#1a1d27; border:1px solid #2d3748;">
            <div class="text-2xl font-bold text-green-400">{{ fmt(movieData.summary.in_sync) }}</div>
            <div class="text-xs text-slate-400 mt-1">In Sync</div>
          </div>
          <div class="rounded-lg p-4 text-center" style="background:#1a1d27; border:1px solid #2d3748;">
            <div class="text-2xl font-bold text-red-400">{{ fmt(movieData.summary.missing_count) }}</div>
            <div class="text-xs text-slate-400 mt-1">Missing from Unraid</div>
          </div>
          <div class="rounded-lg p-4 text-center cursor-pointer hover:border-violet-500/50 transition-colors"
            style="background:#1a1d27; border:1px solid #2d3748;"
            @click="movieTab = 'syn_better'">
            <div class="text-2xl font-bold text-violet-400">{{ fmt(movieData.summary.syn_better_count) }}</div>
            <div class="text-xs text-slate-400 mt-1">Version Mismatch</div>
          </div>
          <div class="rounded-lg p-4 text-center cursor-pointer hover:border-amber-500/50 transition-colors"
            style="background:#1a1d27; border:1px solid #2d3748;"
            @click="movieTab = 'radarr_stale'">
            <div class="text-2xl font-bold text-amber-400">{{ fmt(movieData.summary.radarr_stale_count) }}</div>
            <div class="text-xs text-slate-400 mt-1">Radarr Out of Date</div>
          </div>
          <div class="rounded-lg p-4 text-center" style="background:#1a1d27; border:1px solid #2d3748;">
            <div class="text-2xl font-bold text-slate-500">{{ fmt(movieData.summary.no_file_count) }}</div>
            <div class="text-xs text-slate-400 mt-1">Not Downloaded</div>
          </div>
        </div>

        <div class="text-xs text-slate-600 mb-4">
          Cached {{ movieData.cached_age_s }}s ago · {{ fmt(movieData.summary.total) }} movies in Radarr HD
          <span v-if="movieData.scanning" class="text-amber-400 ml-1">· refreshing…</span>
        </div>

        <!-- Sub-tabs -->
        <div class="flex flex-wrap gap-2 mb-5">
          <button v-for="t in movieTabs" :key="t.key" @click="movieTab = t.key"
            class="px-4 py-1.5 rounded text-sm transition-colors"
            :class="movieTab === t.key ? 'bg-violet-600 text-white' : 'bg-surface-200 text-slate-400 hover:text-white'">
            {{ t.label }}
            <span v-if="t.count" class="ml-1 text-xs opacity-70">({{ fmt(t.count) }})</span>
          </button>
        </div>

        <!-- Missing -->
        <template v-if="movieTab === 'missing'">
          <div v-if="!movieData.missing?.length" class="text-center py-10 text-green-400">
            No missing movies — gap scanner is keeping up!
          </div>
          <div v-else class="space-y-1">
            <div v-for="m in movieData.missing" :key="m.title"
              class="flex items-center justify-between px-4 py-2 rounded"
              style="background:#1a1d27;">
              <span class="text-white text-sm truncate">{{ m.title }}</span>
              <div class="flex items-center gap-4 ml-4 shrink-0">
                <span class="text-xs text-violet-400">{{ m.quality }}</span>
                <span class="text-xs text-slate-500">{{ gb(m.size_bytes) }}</span>
              </div>
            </div>
          </div>
        </template>

        <!-- Version mismatches (Radarr's file ≠ Unraid's file → always sync Radarr's version) -->
        <template v-else-if="movieTab === 'syn_better'">
          <div v-if="!movieData.syn_better?.length" class="text-center py-10 text-green-400">
            All movies matched — nothing to sync.
          </div>
          <div v-else>
            <div class="text-xs text-slate-500 mb-3 p-3 rounded" style="background:#1a1e2e; border:1px solid #2d3748;">
              Radarr's file on Synology differs from what's on Unraid. Radarr is the authority —
              its file replaces the Unraid copy regardless of TRaSH score. This includes
              <strong class="text-slate-300">profile mismatches</strong> (e.g. Unraid has Remux but Radarr's profile says Blu-ray and it downloaded one)
              and <strong class="text-slate-300">container changes</strong> (e.g. m2ts → MKV encode after Upgraderr Tier 1).
              The nightly version reconcile (11:45 PM ET) queues replacements and deletes the old Unraid file.
            </div>
            <div v-for="m in movieData.syn_better" :key="m.title" class="mb-3 rounded-lg overflow-hidden"
              style="background:#1a1d27; border:1px solid #2d3748;">
              <div class="px-4 py-2.5 font-medium text-white text-sm">{{ m.title }}</div>
              <div class="px-4 pb-3 space-y-1">
                <div class="flex items-start gap-2">
                  <span class="text-green-400 text-xs mt-0.5 w-16 shrink-0">Radarr</span>
                  <div>
                    <span class="text-xs text-slate-300 break-all">{{ m.syn_file }}</span>
                    <span class="ml-2 text-xs text-slate-500">{{ gb(m.syn_size_bytes) }}</span>
                    <span class="ml-2 px-1.5 py-0.5 rounded text-xs bg-violet-900/60 text-violet-300">{{ m.syn_quality }}</span>
                    <span class="ml-1 text-xs text-slate-600">score {{ m.syn_score }}</span>
                  </div>
                </div>
                <div class="flex items-start gap-2">
                  <span class="text-red-400 text-xs mt-0.5 w-16 shrink-0">Unraid</span>
                  <div>
                    <span class="text-xs text-slate-400 break-all">{{ m.unraid_file }}</span>
                    <span class="ml-2 text-xs text-slate-500">{{ gb(m.unraid_size_bytes) }}</span>
                    <span class="ml-2 px-1.5 py-0.5 rounded text-xs bg-slate-700 text-slate-400">{{ m.unraid_label }}</span>
                    <span class="ml-1 text-xs text-slate-600">score {{ m.unraid_score }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </template>

        <!-- Radarr tracking old file — Synology folder has a newer/better version -->
        <template v-else-if="movieTab === 'radarr_stale'">
          <div v-if="!movieData.radarr_stale?.length" class="text-center py-10 text-green-400">
            Radarr is tracking the best file in every folder.
          </div>
          <div v-else>
            <div class="text-xs text-amber-500/80 mb-3 p-3 rounded" style="background:#2d1f00; border:1px solid #4a3200;">
              Radarr is referencing an older file while the Synology folder contains a better one
              (e.g. a release-group copy added by batch sync). Trigger a Radarr library rescan
              (<strong>Movies → Library Import</strong> or the <code>rescanMovie</code> API) to let
              Radarr adopt the better file — then both sides stay in sync automatically.
            </div>
            <div v-for="m in movieData.radarr_stale" :key="m.title" class="mb-3 rounded-lg overflow-hidden"
              style="background:#1a1d27; border:1px solid #2d3748;">
              <div class="px-4 py-2.5 font-medium text-white text-sm">{{ m.title }}</div>
              <div class="px-4 pb-3 space-y-1">
                <div class="flex items-start gap-2">
                  <span class="text-amber-400 text-xs mt-0.5 w-20 shrink-0">Radarr has</span>
                  <div>
                    <span class="text-xs text-slate-400 break-all">{{ m.radarr_file }}</span>
                    <span class="ml-2 text-xs text-slate-500">{{ gb(m.radarr_size_bytes) }}</span>
                  </div>
                </div>
                <div class="flex items-start gap-2">
                  <span class="text-green-400 text-xs mt-0.5 w-20 shrink-0">Folder has</span>
                  <div>
                    <span class="text-xs text-slate-300 break-all">{{ m.syn_file }}</span>
                    <span class="ml-2 text-xs text-slate-500">{{ gb(m.syn_size_bytes) }}</span>
                    <span class="ml-2 px-1.5 py-0.5 rounded text-xs bg-amber-900/60 text-amber-300">{{ m.syn_label }}</span>
                    <span class="ml-1 text-xs text-slate-600">score {{ m.syn_score }}</span>
                  </div>
                </div>
                <div class="text-xs text-slate-600 mt-1 italic">{{ m.note }}</div>
              </div>
            </div>
          </div>
        </template>
      </template>
    </template>

    <!-- ── TV SHOWS ───────────────────────────────────────────────────── -->
    <template v-else>
      <div v-if="tvData?.status === 'scanning' || !tvData" class="text-center py-20">
        <div class="animate-spin h-8 w-8 border-2 border-violet-500/30 border-t-violet-500 rounded-full mx-auto mb-4"></div>
        <div class="text-slate-400 text-sm">Scanning Synology NFS + Unraid Agent TV inventory (~60s)…</div>
      </div>
      <div v-else-if="tvData?.status === 'error'" class="text-center py-10 text-red-400">
        {{ tvData.error }}
      </div>
      <template v-else>
        <!-- Summary cards -->
        <div class="grid grid-cols-2 md:grid-cols-4 gap-3 mb-6">
          <div class="rounded-lg p-4 text-center" style="background:#1a1d27; border:1px solid #2d3748;">
            <div class="text-2xl font-bold text-green-400">{{ fmt(tvData.summary.in_sync) }}</div>
            <div class="text-xs text-slate-400 mt-1">Episodes In Sync</div>
          </div>
          <div class="rounded-lg p-4 text-center" style="background:#1a1d27; border:1px solid #2d3748;">
            <div class="text-2xl font-bold text-red-400">{{ fmt(tvData.summary.missing_count) }}</div>
            <div class="text-xs text-slate-400 mt-1">Missing from Unraid</div>
          </div>
          <div class="rounded-lg p-4 text-center cursor-pointer hover:border-violet-500/50 transition-colors"
            style="background:#1a1d27; border:1px solid #2d3748;"
            @click="tvTab = 'syn_better'">
            <div class="text-2xl font-bold text-violet-400">{{ fmt(tvData.summary.syn_better_count) }}</div>
            <div class="text-xs text-slate-400 mt-1">Synology Upgrade</div>
          </div>
          <div class="rounded-lg p-4 text-center cursor-pointer hover:border-amber-500/50 transition-colors"
            style="background:#1a1d27; border:1px solid #2d3748;"
            @click="tvTab = 'unraid_better'">
            <div class="text-2xl font-bold text-amber-400">{{ fmt(tvData.summary.unraid_better_count) }}</div>
            <div class="text-xs text-slate-400 mt-1">Unraid Has Better</div>
          </div>
        </div>

        <div class="text-xs text-slate-600 mb-4">
          Cached {{ tvData.cached_age_s }}s ago ·
          {{ fmt(tvData.summary.syn_total) }} episodes on Synology,
          {{ fmt(tvData.summary.unraid_total) }} on Unraid
          <span v-if="tvData.scanning" class="text-amber-400 ml-1">· refreshing…</span>
        </div>

        <!-- Sub-tabs -->
        <div class="flex flex-wrap gap-2 mb-5">
          <button v-for="t in tvTabs" :key="t.key" @click="tvTab = t.key"
            class="px-4 py-1.5 rounded text-sm transition-colors"
            :class="tvTab === t.key ? 'bg-violet-600 text-white' : 'bg-surface-200 text-slate-400 hover:text-white'">
            {{ t.label }}
            <span v-if="t.count" class="ml-1 text-xs opacity-70">({{ fmt(t.count) }})</span>
          </button>
        </div>

        <!-- Missing episodes -->
        <template v-if="tvTab === 'missing'">
          <div v-if="!tvData.missing_shows?.length" class="text-center py-10 text-green-400">
            No missing episodes!
          </div>
          <div v-else>
            <div v-for="s in tvData.missing_shows" :key="s.show"
              class="mb-2 rounded-lg overflow-hidden"
              style="background:#1a1d27; border:1px solid #2d3748;">
              <div class="flex items-center justify-between px-4 py-2.5 cursor-pointer hover:bg-white/5"
                @click="toggleShow('miss', s.show)">
                <span class="text-white text-sm font-medium">{{ s.show }}</span>
                <div class="flex items-center gap-3">
                  <span class="text-red-400 text-xs">{{ s.count }} episode{{ s.count > 1 ? 's' : '' }}</span>
                  <span class="text-slate-600 text-xs">{{ expandedMiss.has(s.show) ? '▲' : '▼' }}</span>
                </div>
              </div>
              <div v-if="expandedMiss.has(s.show)" class="border-t border-surface-300 px-4 py-2 space-y-1">
                <div v-for="ep in s.episodes" :key="ep.ep"
                  class="flex items-center justify-between text-xs py-1">
                  <span class="text-slate-400 w-20 shrink-0">{{ ep.ep }}</span>
                  <span class="text-slate-300 truncate flex-1 mx-2">{{ ep.file }}</span>
                  <span class="text-slate-500 shrink-0">{{ gb(ep.size_bytes) }}</span>
                </div>
              </div>
            </div>
          </div>
        </template>

        <!-- Synology has upgrade -->
        <template v-else-if="tvTab === 'syn_better'">
          <div v-if="!tvData.syn_better_shows?.length" class="text-center py-10 text-green-400">
            No version mismatches where Synology is better.
          </div>
          <div v-else>
            <div class="text-xs text-slate-500 mb-3">
              These episodes will be queued automatically tonight at 11:15 PM by the TV version reconcile job.
            </div>
            <div v-for="s in tvData.syn_better_shows" :key="s.show"
              class="mb-2 rounded-lg overflow-hidden"
              style="background:#1a1d27; border:1px solid #2d3748;">
              <div class="flex items-center justify-between px-4 py-2.5 cursor-pointer hover:bg-white/5"
                @click="toggleShow('syn', s.show)">
                <span class="text-white text-sm font-medium">{{ s.show }}</span>
                <div class="flex items-center gap-3">
                  <span class="text-violet-400 text-xs">{{ s.count }} episode{{ s.count > 1 ? 's' : '' }}</span>
                  <span class="text-slate-600 text-xs">{{ expandedSyn.has(s.show) ? '▲' : '▼' }}</span>
                </div>
              </div>
              <div v-if="expandedSyn.has(s.show)" class="border-t border-surface-300 px-4 py-2 space-y-2">
                <div v-for="ep in s.episodes" :key="ep.ep" class="py-1 border-b border-surface-300 last:border-0">
                  <div class="text-xs text-slate-400 mb-1">{{ ep.ep }}</div>
                  <div class="flex items-start gap-2 text-xs">
                    <span class="text-green-400 w-16 shrink-0">Synology</span>
                    <span class="text-slate-300 truncate">{{ ep.syn_file }}</span>
                    <span class="text-slate-500 shrink-0 ml-1">{{ gb(ep.syn_size_bytes) }}</span>
                  </div>
                  <div class="flex items-start gap-2 text-xs mt-0.5">
                    <span class="text-red-400 w-16 shrink-0">Unraid</span>
                    <span class="text-slate-400 truncate">{{ ep.unraid_file }}</span>
                    <span class="text-slate-500 shrink-0 ml-1">{{ gb(ep.unraid_size_bytes) }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </template>

        <!-- Unraid has better (TV only — NFS scan doesn't have Sonarr profile context) -->
        <template v-else-if="tvTab === 'unraid_better'">
          <div v-if="!tvData.unraid_better_shows?.length" class="text-center py-10 text-green-400">
            No episodes where Unraid has a better version.
          </div>
          <div v-else>
            <div class="text-xs text-amber-500/80 mb-3 p-3 rounded" style="background:#2d1f00; border:1px solid #4a3200;">
              These episodes score higher on Unraid than on Synology.
              The version reconcile will not touch these (Synology is not strictly better).
              Upgraderr should eventually upgrade Synology to match or exceed these.
            </div>
            <div v-for="s in tvData.unraid_better_shows" :key="s.show"
              class="mb-2 rounded-lg overflow-hidden"
              style="background:#1a1d27; border:1px solid #2d3748;">
              <div class="flex items-center justify-between px-4 py-2.5 cursor-pointer hover:bg-white/5"
                @click="toggleShow('unr', s.show)">
                <span class="text-white text-sm font-medium">{{ s.show }}</span>
                <div class="flex items-center gap-3">
                  <span class="text-amber-400 text-xs">{{ s.count }} episode{{ s.count > 1 ? 's' : '' }}</span>
                  <span class="text-slate-600 text-xs">{{ expandedUnr.has(s.show) ? '▲' : '▼' }}</span>
                </div>
              </div>
              <div v-if="expandedUnr.has(s.show)" class="border-t border-surface-300 px-4 py-2 space-y-2">
                <div v-for="ep in s.episodes" :key="ep.ep" class="py-1 border-b border-surface-300 last:border-0">
                  <div class="text-xs text-slate-400 mb-1">{{ ep.ep }}</div>
                  <div class="flex items-start gap-2 text-xs">
                    <span class="text-slate-400 w-16 shrink-0">Synology</span>
                    <span class="text-slate-400 truncate">{{ ep.syn_file }}</span>
                    <span class="text-slate-500 shrink-0 ml-1">{{ gb(ep.syn_size_bytes) }}</span>
                  </div>
                  <div class="flex items-start gap-2 text-xs mt-0.5">
                    <span class="text-green-400 w-16 shrink-0">Unraid</span>
                    <span class="text-slate-300 truncate">{{ ep.unraid_file }}</span>
                    <span class="text-slate-500 shrink-0 ml-1">{{ gb(ep.unraid_size_bytes) }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </template>
      </template>
    </template>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import axios from 'axios'

const library = ref('Movies')
const movieTab = ref('syn_better')
const tvTab = ref('missing')

const movieData = ref(null)
const tvData = ref(null)
const loading = ref(false)

const expandedMiss = ref(new Set())
const expandedSyn  = ref(new Set())
const expandedUnr  = ref(new Set())

const toggleShow = (type, show) => {
  const map = { miss: expandedMiss, syn: expandedSyn, unr: expandedUnr }
  const s = map[type].value
  if (s.has(show)) s.delete(show)
  else s.add(show)
  map[type].value = new Set(s)
}

const fmt = n => n == null ? '—' : n.toLocaleString()
const gb = b => b ? `${(b / 1_073_741_824).toFixed(1)} GB` : '—'

const movieTabs = computed(() => [
  { key: 'missing',      label: 'Missing from Unraid', count: movieData.value?.summary?.missing_count },
  { key: 'syn_better',   label: 'Version Mismatch',    count: movieData.value?.summary?.syn_better_count },
  { key: 'radarr_stale', label: 'Radarr Out of Date',  count: movieData.value?.summary?.radarr_stale_count },
])

const tvTabs = computed(() => [
  { key: 'missing',      label: 'Missing from Unraid', count: tvData.value?.summary?.missing_count },
  { key: 'syn_better',   label: 'Synology Upgrade',    count: tvData.value?.summary?.syn_better_count },
  { key: 'unraid_better',label: 'Unraid Has Better',   count: tvData.value?.summary?.unraid_better_count },
])

let pollTimer = null

const loadMovies = async (force = false) => {
  try {
    const r = await axios.get('/api/sync-status/movies', { params: force ? { refresh: true } : {} })
    movieData.value = r.data
    if (r.data.status === 'scanning') schedulePoll()
  } catch (e) {
    movieData.value = { status: 'error', error: e.message }
  }
}

const loadTv = async (force = false) => {
  try {
    const r = await axios.get('/api/sync-status/tv', { params: force ? { refresh: true } : {} })
    tvData.value = r.data
    if (r.data.status === 'scanning') schedulePoll()
  } catch (e) {
    tvData.value = { status: 'error', error: e.message }
  }
}

const schedulePoll = () => {
  if (pollTimer) return
  pollTimer = setInterval(async () => {
    await Promise.all([loadMovies(), loadTv()])
    const bothReady = movieData.value?.status === 'ready' && tvData.value?.status === 'ready'
    const bothDone  = !movieData.value?.scanning && !tvData.value?.scanning
    if (bothReady && bothDone) { clearInterval(pollTimer); pollTimer = null; loading.value = false }
  }, 5000)
}

const refresh = async () => {
  loading.value = true
  await Promise.all([loadMovies(true), loadTv(true)])
  schedulePoll()
}

onMounted(async () => {
  await Promise.all([loadMovies(), loadTv()])
  const needPoll = movieData.value?.status === 'scanning' || tvData.value?.status === 'scanning'
  if (needPoll) schedulePoll()
})

onUnmounted(() => { if (pollTimer) { clearInterval(pollTimer); pollTimer = null } })
</script>
