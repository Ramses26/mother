<template>
  <div class="p-6 max-w-7xl mx-auto">
    <!-- Stats row -->
    <div class="grid grid-cols-2 lg:grid-cols-5 gap-4 mb-6">
      <div v-for="card in statsCards" :key="card.label" class="card"
        :style="card.link ? 'cursor:pointer' : ''"
        @click="card.link ? $router.push(card.link) : null">
        <div class="text-slate-400 text-xs uppercase tracking-wider mb-1">{{ card.label }}</div>
        <div class="text-2xl font-bold" :class="card.valueClass || 'text-white'">{{ card.value }}</div>
        <div v-if="card.sub" class="text-slate-500 text-xs mt-1">{{ card.sub }}</div>
      </div>
    </div>

    <!-- Rating histogram + Purge candidates row -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
      <!-- Histogram -->
      <div class="card lg:col-span-2">
        <div class="flex items-center justify-between mb-3">
          <h3 class="font-semibold text-white">Rating Distribution</h3>
          <div class="flex gap-2">
            <button @click="histTab='movies'" class="text-xs px-3 py-1 rounded-full transition-colors"
              :class="histTab==='movies' ? 'bg-violet-600 text-white' : 'bg-surface-200 text-slate-400 hover:text-white'">
              Movies
            </button>
            <button @click="histTab='tv'" class="text-xs px-3 py-1 rounded-full transition-colors"
              :class="histTab==='tv' ? 'bg-violet-600 text-white' : 'bg-surface-200 text-slate-400 hover:text-white'">
              TV
            </button>
          </div>
        </div>
        <div v-if="stats" class="flex items-end gap-1 h-28">
          <div v-for="bucket in currentHist" :key="bucket.bucket"
            class="flex-1 flex flex-col items-center gap-1 cursor-pointer group"
            @click="filterByBucket(bucket)">
            <div class="w-full rounded-t transition-all group-hover:opacity-80"
              :style="{ height: barHeight(bucket.count) + 'px', background: barColor(bucket.bucket) }"></div>
            <div class="text-xs text-slate-500 group-hover:text-slate-300 transition-colors" style="font-size:10px;">
              {{ bucket.bucket }}
            </div>
          </div>
        </div>
        <div v-else class="h-28 flex items-center justify-center text-slate-500 text-sm">Loading...</div>
        <!-- Source toggle pills -->
        <div class="mt-3 flex items-center gap-2 flex-wrap">
          <span class="text-xs text-slate-500">Source:</span>
          <button v-for="src in histSources" :key="src.value"
            @click="histSource = src.value"
            class="text-xs px-2 py-0.5 rounded-full transition-colors"
            :class="histSource === src.value ? 'bg-violet-600 text-white' : 'bg-surface-200 text-slate-400 hover:text-white'">
            {{ src.label }}
          </button>
          <span class="text-slate-600 text-xs ml-1" title="Composite = weighted avg: IMDb 35%, RT 25%, MDBList 20%, Metacritic 15%, TMDB 5%">ⓘ</span>
        </div>
      </div>

      <!-- Top Purge Candidates -->
      <div class="card">
        <h3 class="font-semibold text-white mb-3">Top Purge Candidates</h3>
        <div v-if="stats && stats.top_purge_candidates.length > 0" class="space-y-2">
          <div v-for="item in stats.top_purge_candidates" :key="item.id"
            class="flex items-center justify-between p-2 rounded-lg hover:bg-surface-200 transition-colors cursor-pointer"
            @click="$router.push('/movies?open=' + item.id)">
            <div class="flex-1 min-w-0">
              <div class="text-sm text-white truncate">{{ item.title }}</div>
              <div class="text-xs text-slate-500">{{ item.year }} · {{ item.resolution }}</div>
            </div>
            <div class="ml-2 px-2 py-0.5 rounded text-xs font-bold"
              :class="purgeScoreClass(item.purge_score)">
              {{ item.purge_score }}
            </div>
          </div>
        </div>
        <div v-else class="text-slate-500 text-sm text-center py-4">
          {{ stats ? 'No purge candidates' : 'Loading...' }}
        </div>
      </div>
    </div>

    <!-- Resolution Donuts + Codec Bars -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
      <!-- Resolution Donuts -->
      <div class="card">
        <h3 class="font-semibold text-white mb-4">Resolution Distribution</h3>
        <div class="flex gap-8 justify-around">
          <!-- Movies donut -->
          <div class="flex flex-col items-center gap-3">
            <div class="text-xs text-slate-400 uppercase tracking-wider">Movies</div>
            <div class="relative">
              <svg width="120" height="120" viewBox="0 0 120 120">
                <circle cx="60" cy="60" r="50" fill="none" stroke="#1e293b" stroke-width="16"/>
                <circle v-for="(sl, i) in movieResSlices" :key="i"
                  cx="60" cy="60" r="50" fill="none"
                  :stroke="sl.color" stroke-width="16"
                  :stroke-dasharray="`${sl.dash} ${CIRC - sl.dash}`"
                  :stroke-dashoffset="-sl.offset"
                  transform="rotate(-90 60 60)"/>
              </svg>
              <div class="absolute inset-0 flex items-center justify-center text-xs text-slate-400">
                {{ stats?.movies?.total?.toLocaleString() || '—' }}
              </div>
            </div>
            <div class="space-y-1">
              <div v-for="sl in movieResSlices" :key="sl.label" class="flex items-center gap-1.5 text-xs">
                <div class="w-2.5 h-2.5 rounded-sm flex-shrink-0" :style="{background: sl.color}"></div>
                <span class="text-slate-300">{{ sl.label }}</span>
                <span class="text-slate-500 ml-auto pl-2">{{ sl.count }}</span>
              </div>
            </div>
          </div>
          <!-- TV donut -->
          <div class="flex flex-col items-center gap-3">
            <div class="text-xs text-slate-400 uppercase tracking-wider">TV Shows</div>
            <div class="relative">
              <svg width="120" height="120" viewBox="0 0 120 120">
                <circle cx="60" cy="60" r="50" fill="none" stroke="#1e293b" stroke-width="16"/>
                <circle v-for="(sl, i) in tvResSlices" :key="i"
                  cx="60" cy="60" r="50" fill="none"
                  :stroke="sl.color" stroke-width="16"
                  :stroke-dasharray="`${sl.dash} ${CIRC - sl.dash}`"
                  :stroke-dashoffset="-sl.offset"
                  transform="rotate(-90 60 60)"/>
              </svg>
              <div class="absolute inset-0 flex items-center justify-center text-xs text-slate-400">
                {{ stats?.tv_shows?.total?.toLocaleString() || '—' }}
              </div>
            </div>
            <div class="space-y-1">
              <div v-for="sl in tvResSlices" :key="sl.label" class="flex items-center gap-1.5 text-xs">
                <div class="w-2.5 h-2.5 rounded-sm flex-shrink-0" :style="{background: sl.color}"></div>
                <span class="text-slate-300">{{ sl.label }}</span>
                <span class="text-slate-500 ml-auto pl-2">{{ sl.count }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Codec Bars -->
      <div class="card">
        <h3 class="font-semibold text-white mb-4">Codec Distribution <span class="text-xs font-normal text-slate-500">(movies)</span></h3>
        <div class="space-y-4">
          <!-- Video codec -->
          <div>
            <div class="text-xs text-slate-400 uppercase tracking-wider mb-2">Video</div>
            <div v-for="item in stats?.codec_dist?.video || []" :key="item.video_codec" class="flex items-center gap-2 mb-1">
              <span class="w-14 text-xs text-right text-slate-500 truncate">{{ item.video_codec }}</span>
              <div class="flex-1 rounded h-2.5" style="background:#1e293b">
                <div class="h-2.5 rounded" style="background:#7c3aed"
                  :style="{width: pct(item.count, maxVideoCount) + '%'}"></div>
              </div>
              <span class="w-10 text-xs text-slate-500 text-right">{{ item.count.toLocaleString() }}</span>
            </div>
          </div>
          <!-- Audio codec -->
          <div>
            <div class="text-xs text-slate-400 uppercase tracking-wider mb-2">Audio</div>
            <div v-for="item in stats?.codec_dist?.audio || []" :key="item.audio_codec" class="flex items-center gap-2 mb-1">
              <span class="w-14 text-xs text-right text-slate-500 truncate">{{ item.audio_codec }}</span>
              <div class="flex-1 rounded h-2.5" style="background:#1e293b">
                <div class="h-2.5 rounded" style="background:#2563eb"
                  :style="{width: pct(item.count, maxAudioCount) + '%'}"></div>
              </div>
              <span class="w-10 text-xs text-slate-500 text-right">{{ item.count.toLocaleString() }}</span>
            </div>
          </div>
          <!-- Channels -->
          <div>
            <div class="text-xs text-slate-400 uppercase tracking-wider mb-2">Channels</div>
            <div v-for="item in stats?.codec_dist?.channels || []" :key="item.audio_channels" class="flex items-center gap-2 mb-1">
              <span class="w-14 text-xs text-right text-slate-500">{{ item.audio_channels }}</span>
              <div class="flex-1 rounded h-2.5" style="background:#1e293b">
                <div class="h-2.5 rounded" style="background:#059669"
                  :style="{width: pct(item.count, maxChannelCount) + '%'}"></div>
              </div>
              <span class="w-10 text-xs text-slate-500 text-right">{{ item.count.toLocaleString() }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Stale Content Table -->
    <div class="card mb-6">
      <div class="flex items-center justify-between mb-4">
        <h3 class="font-semibold text-white">
          Stale Content
          <span class="text-xs font-normal text-slate-500 ml-1">(purge score ≥ 50)</span>
        </h3>
        <div class="flex items-center gap-3">
          <div class="flex gap-1">
            <button v-for="u in ['Combined','Ali','Chris']" :key="u"
              @click="watchUser = u.toLowerCase(); stalePage = 1; loadStale()"
              class="text-xs px-2 py-1 rounded transition-colors"
              :class="watchUser === u.toLowerCase() ? 'bg-violet-600 text-white' : 'bg-surface-200 text-slate-400 hover:text-white'">
              {{ u }}
            </button>
          </div>
          <span class="text-xs text-slate-500">{{ staleTotal.toLocaleString() }} total</span>
        </div>
      </div>
      <div v-if="staleItems.length > 0" class="overflow-x-auto">
        <table class="w-full text-xs">
          <thead>
            <tr class="text-slate-500 border-b" style="border-color:#2d3250;">
              <th class="text-left py-1.5 pr-4 font-medium">Title</th>
              <th class="text-left py-1.5 pr-4 font-medium">Year</th>
              <th class="text-left py-1.5 pr-4 font-medium">Res</th>
              <th class="text-left py-1.5 pr-4 font-medium">Score</th>
              <th class="text-left py-1.5 pr-4 font-medium">Purge</th>
              <th class="text-left py-1.5 pr-4 font-medium">Plays</th>
              <th class="text-left py-1.5 font-medium">Size</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in staleItems" :key="item.id"
              class="border-b hover:bg-surface-100 cursor-pointer transition-colors"
              style="border-color:#1a1d27;"
              @click="$router.push('/movies?open=' + item.id)">
              <td class="py-1.5 pr-4 text-white">{{ item.title }}</td>
              <td class="py-1.5 pr-4 text-slate-400">{{ item.year }}</td>
              <td class="py-1.5 pr-4 text-slate-400">{{ item.resolution || '—' }}</td>
              <td class="py-1.5 pr-4 text-violet-400">{{ item.composite_score?.toFixed(1) || '—' }}</td>
              <td class="py-1.5 pr-4">
                <span class="px-1.5 py-0.5 rounded font-bold" :class="purgeScoreClass(item.purge_score)">
                  {{ item.purge_score }}
                </span>
              </td>
              <td class="py-1.5 pr-4 text-slate-400">{{ item.play_count }}</td>
              <td class="py-1.5 text-slate-400">{{ fmtSize(item.file_size_bytes) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div v-else class="text-slate-500 text-sm text-center py-4">No stale content found</div>
      <!-- Pagination -->
      <div v-if="staleTotal > 25" class="flex items-center justify-between mt-3">
        <button @click="stalePage--; loadStale()" :disabled="stalePage === 1"
          class="btn-secondary text-xs px-2 py-1 disabled:opacity-40">Previous</button>
        <span class="text-slate-500 text-xs">Page {{ stalePage }} of {{ Math.ceil(staleTotal / 25) }}</span>
        <button @click="stalePage++; loadStale()" :disabled="stalePage >= Math.ceil(staleTotal / 25)"
          class="btn-secondary text-xs px-2 py-1 disabled:opacity-40">Next</button>
      </div>
    </div>

    <!-- Recent additions + Sync status row -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Recent additions -->
      <div class="card lg:col-span-2">
        <h3 class="font-semibold text-white mb-3">Recent Additions</h3>
        <div v-if="stats && stats.recent_additions.length > 0" class="space-y-2">
          <div v-for="item in stats.recent_additions" :key="item.id + item.media_type"
            class="flex items-center gap-3 p-2 rounded-lg hover:bg-surface-200 transition-colors">
            <div class="w-8 h-8 rounded flex items-center justify-center text-xs font-bold"
              :class="item.media_type === 'movie' ? 'bg-violet-900 text-violet-300' : 'bg-blue-900 text-blue-300'">
              {{ item.media_type === 'movie' ? '🎬' : '📺' }}
            </div>
            <div class="flex-1 min-w-0">
              <div class="text-sm text-white truncate">{{ item.title }}</div>
              <div class="text-xs text-slate-500">{{ item.year }} · {{ item.resolution || 'TV' }}</div>
            </div>
            <div v-if="item.composite_score" class="text-xs text-violet-400 font-medium">
              {{ item.composite_score.toFixed(1) }}
            </div>
          </div>
        </div>
        <div v-else class="text-slate-500 text-sm text-center py-4">
          {{ stats ? 'No recent additions' : 'Loading...' }}
        </div>
      </div>

      <!-- Sync status -->
      <div class="card">
        <h3 class="font-semibold text-white mb-3">Sync Status</h3>
        <div class="space-y-2">
          <div v-for="source in allSyncSources" :key="source.key" class="text-xs">
            <div class="flex items-center justify-between mb-0.5">
              <span class="text-slate-300 font-medium">{{ source.label }}</span>
              <span class="flex items-center gap-1">
                <!-- Spinning indicator while syncing -->
                <span v-if="isSyncing && !hasSyncCompleted(source)" class="inline-block w-3 h-3">
                  <svg class="animate-spin" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
                    <circle cx="12" cy="12" r="10" stroke-opacity="0.25"/>
                    <path d="M12 2 a10 10 0 0 1 10 10" stroke-opacity="1"/>
                  </svg>
                </span>
                <span v-else-if="isSyncing && hasSyncCompleted(source)" class="text-green-400">✓</span>
                <span :class="syncStatusColor(source.status)">
                  {{ syncStatusLabel(source.status) }}
                </span>
              </span>
            </div>
            <div class="text-slate-500">
              <template v-if="source.status === 'not_configured'">Not configured</template>
              <template v-else-if="source.status === 'error'">
                <span class="text-red-400/70">{{ (source.error_msg || 'Error').slice(0, 60) }}</span>
              </template>
              <template v-else>
                {{ source.last_sync ? new Date(source.last_sync).toLocaleString() : 'Never synced' }}
                <span v-if="source.item_count"> · {{ source.item_count.toLocaleString() }} items</span>
              </template>
            </div>
          </div>
        </div>
        <button @click="triggerSync" :disabled="syncing"
          class="mt-3 w-full btn-secondary text-sm py-1.5">
          {{ syncing ? 'Syncing...' : 'Sync Now' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'

const router = useRouter()
const stats = ref(null)
const histTab = ref('movies')
const histSource = ref('composite')
const syncing = ref(false)
const isSyncing = ref(false)
const syncStartTime = ref(null)
const syncStatuses = ref({})
let pollTimer = null

// Stale content
const watchUser = ref('combined')
const staleItems = ref([])
const staleTotal = ref(0)
const stalePage = ref(1)

const CIRC = 314.16  // 2 * π * 50
const RES_COLORS = { '4K': '#8b5cf6', '1080p': '#3b82f6', '720p': '#eab308', 'SD': '#6b7280', 'Unknown': '#374151' }

const movieResSlices = computed(() => {
  const dist = stats.value?.resolution_dist || {}
  const total = Object.values(dist).reduce((a, b) => a + b, 0) || 1
  let offset = 0
  return Object.entries(dist).map(([res, count]) => {
    const dash = (count / total) * CIRC
    const sl = { label: res, count, dash, offset, color: RES_COLORS[res] || '#94a3b8' }
    offset += dash
    return sl
  })
})

const tvResSlices = computed(() => {
  const dist = stats.value?.tv_instance_dist || {}
  const labelMap = { 'sonarr-4k': '~4K', 'sonarr-hd': '~HD' }
  const colorMap = { 'sonarr-4k': '#8b5cf6', 'sonarr-hd': '#3b82f6' }
  const total = Object.values(dist).reduce((a, b) => a + b, 0) || 1
  let offset = 0
  return Object.entries(dist).map(([inst, count]) => {
    const label = labelMap[inst] || inst
    const dash = (count / total) * CIRC
    const sl = { label, count, dash, offset, color: colorMap[inst] || '#94a3b8' }
    offset += dash
    return sl
  })
})

const maxVideoCount = computed(() => {
  const items = stats.value?.codec_dist?.video || []
  return Math.max(...items.map(i => i.count), 1)
})
const maxAudioCount = computed(() => {
  const items = stats.value?.codec_dist?.audio || []
  return Math.max(...items.map(i => i.count), 1)
})
const maxChannelCount = computed(() => {
  const items = stats.value?.codec_dist?.channels || []
  return Math.max(...items.map(i => i.count), 1)
})

const pct = (val, max) => Math.round((val / max) * 100)

const fmtSize = (bytes) => {
  if (!bytes) return '—'
  const gb = bytes / 1_073_741_824
  return gb > 1 ? `${gb.toFixed(1)} GB` : `${(bytes / 1_048_576).toFixed(0)} MB`
}

const loadStale = async () => {
  try {
    const res = await axios.get('/api/stats/stale', { params: { user: watchUser.value, page: stalePage.value } })
    staleItems.value = res.data.items
    staleTotal.value = res.data.total
  } catch {}
}

const histSources = [
  { value: 'composite', label: 'Composite' },
  { value: 'imdb', label: 'IMDb' },
  { value: 'rt', label: 'RT Critics' },
  { value: 'metacritic', label: 'Metacritic' },
  { value: 'mdblist', label: 'MDBList' },
]

const statsCards = computed(() => {
  if (!stats.value) return [
    { label: 'Movies', value: '—' },
    { label: 'TV Shows', value: '—' },
    { label: 'Never Watched', value: '—' },
    { label: 'Storage', value: '—' },
    { label: 'Continuing Unwatched', value: '—' },
  ]
  const s = stats.value
  const gb = s.storage.total_bytes / 1_073_741_824
  const unit = gb > 1000 ? `${(gb / 1024).toFixed(1)} TB` : `${gb.toFixed(0)} GB`
  return [
    { label: 'Movies', value: s.movies.total.toLocaleString(), sub: `${s.movies.never_watched} never watched` },
    { label: 'TV Shows', value: s.tv_shows.total.toLocaleString(), sub: `${s.tv_shows.never_watched} never watched` },
    { label: 'Below 5.0', value: (s.movies.below_5 + s.tv_shows.below_5).toLocaleString() },
    { label: 'Movie Storage', value: unit, sub: 'TV not tracked' },
    {
      label: 'Continuing Unwatched', value: (s.continuing_unwatched || 0).toLocaleString(),
      sub: 'Still airing, never watched', valueClass: 'text-yellow-400',
      link: '/tv?unwatched_only=true&status=Continuing',
    },
  ]
})

const currentHist = computed(() => {
  if (!stats.value?.rating_histogram) return []
  const tabHist = stats.value.rating_histogram[histTab.value]
  if (!tabHist) return []
  // Use per-source histogram if available, fall back to composite
  return tabHist[histSource.value] || tabHist.composite || tabHist
})

const maxCount = computed(() => {
  if (!currentHist.value.length) return 1
  return Math.max(...currentHist.value.map(b => b.count), 1)
})

const barHeight = (count) => Math.max(4, Math.round((count / maxCount.value) * 90))

const barColor = (bucket) => {
  const parts = bucket.split('-').map(Number)
  const [low, high] = parts
  // Normalize to 0-10 scale (handle 0-100 sources like RT/Metacritic/MDB)
  const maxVal = (high > 10) ? 100 : 10
  const pct = low / maxVal
  if (pct >= 0.8) return '#22c55e'
  if (pct >= 0.6) return '#84cc16'
  if (pct >= 0.4) return '#eab308'
  if (pct >= 0.2) return '#f97316'
  return '#ef4444'
}

const syncStatusColor = (status) => {
  if (status === 'ok') return 'text-green-400'
  if (status === 'error') return 'text-red-400'
  if (status === 'syncing') return 'text-blue-400'
  if (status === 'not_configured') return 'text-slate-600'
  return 'text-slate-500'
}

const syncStatusLabel = (status) => {
  if (status === 'ok') return '✓ ok'
  if (status === 'error') return '✗ error'
  if (status === 'syncing') return '⟳ syncing'
  if (status === 'not_configured') return '— n/a'
  return status || '—'
}

const purgeScoreClass = (score) => {
  if (score >= 75) return 'bg-red-900 text-red-300'
  if (score >= 55) return 'bg-orange-900 text-orange-300'
  if (score >= 30) return 'bg-yellow-900 text-yellow-300'
  return 'bg-green-900 text-green-300'
}

const SYNC_SOURCES = [
  { key: 'radarr-hd', label: 'Radarr HD' },
  { key: 'radarr-4k', label: 'Radarr 4K' },
  { key: 'sonarr-hd', label: 'Sonarr HD' },
  { key: 'sonarr-4k', label: 'Sonarr 4K' },
  { key: 'plex-chris', label: 'Plex (Chris)' },
  { key: 'plex-ali', label: 'Plex (Ali)' },
  { key: 'tautulli-chris', label: 'Tautulli (Chris)' },
  { key: 'tautulli-ali', label: 'Tautulli (Ali)' },
]

const allSyncSources = computed(() => {
  const map = {}
  if (stats.value) {
    for (const row of stats.value.sync_status) {
      map[row.source] = row
    }
  }
  return SYNC_SOURCES.map(s => ({ ...s, ...(map[s.key] || {}) }))
})

const hasSyncCompleted = (source) => {
  if (!syncStartTime.value) return false
  const ts = syncStatuses.value[source.key]
  if (!ts) return false
  return new Date(ts) > syncStartTime.value
}

const filterByBucket = (bucket) => {
  // Only composite histogram can filter (UI uses composite_min/max)
  if (histSource.value !== 'composite') return
  const [low, high] = bucket.bucket.split('-').map(Number)
  const type = histTab.value === 'movies' ? '/movies' : '/tv'
  router.push(`${type}?composite_min=${low}&composite_max=${high}`)
}

const pollSyncStatus = async () => {
  try {
    const res = await axios.get('/api/sync/status')
    const map = {}
    for (const row of res.data) {
      map[row.source] = row.last_sync
    }
    syncStatuses.value = map
  } catch {}
}

const triggerSync = async () => {
  syncing.value = true
  isSyncing.value = true
  syncStartTime.value = new Date()
  syncStatuses.value = {}

  try {
    await axios.post('/api/sync/trigger', { source: 'all' })
  } catch {
    // ignore
  }

  // Poll every 3s for up to 120s
  let elapsed = 0
  pollTimer = setInterval(async () => {
    elapsed += 3
    await pollSyncStatus()
    await loadStats()
    await loadStale()
    if (elapsed >= 120) {
      clearInterval(pollTimer)
      syncing.value = false
      setTimeout(() => { isSyncing.value = false }, 5000)
    }
  }, 3000)
}

const loadStats = async () => {
  try {
    const res = await axios.get('/api/stats')
    stats.value = res.data
  } catch {
    // ignore
  }
}

onMounted(async () => {
  await loadStats()
  await loadStale()
})
onBeforeUnmount(() => { if (pollTimer) clearInterval(pollTimer) })
</script>
