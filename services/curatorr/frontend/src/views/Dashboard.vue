<template>
  <div class="p-6 max-w-7xl mx-auto">
    <!-- Stats row -->
    <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
      <div v-for="card in statsCards" :key="card.label" class="card">
        <div class="text-slate-400 text-xs uppercase tracking-wider mb-1">{{ card.label }}</div>
        <div class="text-2xl font-bold text-white">{{ card.value }}</div>
        <div v-if="card.sub" class="text-slate-500 text-xs mt-1">{{ card.sub }}</div>
      </div>
    </div>

    <!-- Rating histogram + Purge candidates row -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
      <!-- Histogram -->
      <div class="card lg:col-span-2">
        <div class="flex items-center justify-between mb-4">
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
      </div>

      <!-- Top Purge Candidates -->
      <div class="card">
        <h3 class="font-semibold text-white mb-3">Top Purge Candidates</h3>
        <div v-if="stats && stats.top_purge_candidates.length > 0" class="space-y-2">
          <div v-for="item in stats.top_purge_candidates" :key="item.id"
            class="flex items-center justify-between p-2 rounded-lg hover:bg-surface-200 transition-colors cursor-pointer"
            @click="$router.push('/movies?purge_score_min=70')">
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
        <div v-if="stats && stats.sync_status.length > 0" class="space-y-2">
          <div v-for="row in stats.sync_status" :key="row.source" class="text-xs">
            <div class="flex items-center justify-between mb-0.5">
              <span class="text-slate-300 font-medium">{{ row.source }}</span>
              <span :class="row.status === 'ok' ? 'text-green-400' : 'text-red-400'">
                {{ row.status || '?' }}
              </span>
            </div>
            <div class="text-slate-500">
              {{ row.last_sync ? new Date(row.last_sync).toLocaleString() : 'Never' }}
              <span v-if="row.item_count"> · {{ row.item_count }} items</span>
            </div>
          </div>
        </div>
        <div v-else class="text-slate-500 text-sm text-center py-4">
          No sync data yet
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
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'

const router = useRouter()
const stats = ref(null)
const histTab = ref('movies')
const syncing = ref(false)

const statsCards = computed(() => {
  if (!stats.value) return [
    { label: 'Movies', value: '—' },
    { label: 'TV Shows', value: '—' },
    { label: 'Never Watched', value: '—' },
    { label: 'Storage', value: '—' },
  ]
  const s = stats.value
  const gb = s.storage.total_bytes / 1_073_741_824
  const unit = gb > 1000 ? `${(gb / 1024).toFixed(1)} TB` : `${gb.toFixed(0)} GB`
  return [
    { label: 'Movies', value: s.movies.total.toLocaleString(), sub: `${s.movies.never_watched} never watched` },
    { label: 'TV Shows', value: s.tv_shows.total.toLocaleString(), sub: `${s.tv_shows.never_watched} never watched` },
    { label: 'Below 5.0', value: (s.movies.below_5 + s.tv_shows.below_5).toLocaleString() },
    { label: 'Storage', value: unit },
  ]
})

const currentHist = computed(() => {
  if (!stats.value) return []
  return histTab.value === 'movies'
    ? stats.value.rating_histogram.movies
    : stats.value.rating_histogram.tv
})

const maxCount = computed(() => {
  if (!currentHist.value.length) return 1
  return Math.max(...currentHist.value.map(b => b.count), 1)
})

const barHeight = (count) => Math.max(4, Math.round((count / maxCount.value) * 90))

const barColor = (bucket) => {
  const [low] = bucket.split('-').map(Number)
  if (low >= 8) return '#22c55e'
  if (low >= 6) return '#84cc16'
  if (low >= 4) return '#eab308'
  if (low >= 2) return '#f97316'
  return '#ef4444'
}

const purgeScoreClass = (score) => {
  if (score >= 75) return 'bg-red-900 text-red-300'
  if (score >= 55) return 'bg-orange-900 text-orange-300'
  if (score >= 30) return 'bg-yellow-900 text-yellow-300'
  return 'bg-green-900 text-green-300'
}

const filterByBucket = (bucket) => {
  const [low, high] = bucket.bucket.split('-').map(Number)
  const type = histTab.value === 'movies' ? '/movies' : '/tv'
  router.push(`${type}?composite_min=${low}&composite_max=${high}`)
}

const triggerSync = async () => {
  syncing.value = true
  try {
    await axios.post('/api/sync/trigger', { source: 'all' })
    setTimeout(loadStats, 3000)
  } catch {
    // ignore
  } finally {
    setTimeout(() => { syncing.value = false }, 5000)
  }
}

const loadStats = async () => {
  try {
    const res = await axios.get('/api/stats')
    stats.value = res.data
  } catch {
    // ignore
  }
}

onMounted(loadStats)
</script>
