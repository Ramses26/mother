<template>
  <!-- Backdrop (click to close) -->
  <div v-if="item" class="fixed top-14 inset-x-0 bottom-0 z-30 bg-black/50" @click="$emit('close')"></div>

  <!-- Slide-in panel -->
  <transition name="slide">
    <div v-if="item" class="fixed top-14 right-0 bottom-0 z-40 w-full max-w-xl flex flex-col border-l"
      style="background:#1a1d27; border-color:#2d3250;">
      <!-- Sticky header — always visible, never scrolls away -->
      <div class="flex-shrink-0 flex items-start justify-between px-6 py-4 border-b"
        style="background:#1a1d27; border-color:#2d3250;">
        <div>
          <h2 class="text-xl font-bold text-white">{{ item.title }}</h2>
          <div class="text-slate-400 text-sm mt-1 flex flex-wrap gap-x-2 gap-y-1 items-center">
            <span>{{ item.year }}</span>
            <span v-if="item.runtime_min">· {{ fmtRuntime(item.runtime_min) }}</span>
            <span v-if="item.content_rating" class="px-1.5 py-0.5 rounded text-xs font-medium bg-slate-700 text-slate-300">{{ item.content_rating }}</span>
            <span v-if="item.original_language && item.original_language !== 'English'"
              class="px-1.5 py-0.5 rounded text-xs font-medium bg-blue-900/60 text-blue-300">
              {{ item.original_language }}
            </span>
          </div>
        </div>
        <button @click="$emit('close')"
          class="flex items-center justify-center w-10 h-10 rounded-lg bg-slate-700 hover:bg-slate-600 text-white transition-colors text-2xl leading-none flex-shrink-0 ml-4"
          title="Close">×</button>
      </div>
      <!-- Scrollable content -->
      <div class="flex-1 overflow-y-auto p-6">

        <!-- Poster -->
        <div v-if="posterSrc" class="mb-4 rounded-lg overflow-hidden" style="max-width:160px;">
          <img :src="posterSrc" class="w-full object-cover rounded-lg" loading="lazy"
            @error="posterError = true"/>
        </div>

        <!-- Badges -->
        <div class="flex flex-wrap gap-2 mb-4">
          <span v-if="item.resolution" class="px-2 py-0.5 rounded text-xs font-medium bg-slate-700 text-slate-200">
            {{ item.resolution }}
          </span>
          <span v-if="item.hdr_format" class="px-2 py-0.5 rounded text-xs font-medium bg-purple-900 text-purple-300">
            {{ item.hdr_format }}
          </span>
          <span v-if="item.status || item.tmdb_status" class="px-2 py-0.5 rounded text-xs font-medium"
            :class="statusClass(item.tmdb_status === 'Cancelled' ? 'Cancelled' : item.status)">
            {{ item.tmdb_status === 'Cancelled' ? 'Cancelled' : item.status }}
          </span>
          <span v-if="!item.monitored" class="px-2 py-0.5 rounded text-xs font-medium bg-slate-700 text-slate-400">
            Unmonitored
          </span>
        </div>

        <!-- Ratings -->
        <div class="mb-4">
          <h3 class="text-sm font-medium text-slate-400 mb-2">Ratings</h3>
          <div class="flex flex-wrap gap-2">
            <RatingBadge source="composite" :value="item.composite_score"/>
            <RatingBadge source="imdb" :value="item.imdb_rating"/>
            <RatingBadge source="rt" :value="item.rt_critics"/>
            <RatingBadge source="metacritic" :value="item.metacritic"/>
            <RatingBadge source="tmdb" :value="item.tmdb_rating"/>
            <RatingBadge source="mdblist" :value="item.mdblist_score"/>
            <RatingBadge source="trakt" :value="item.trakt_rating"/>
            <RatingBadge v-if="item.radarr_id" source="letterboxd" :value="item.letterboxd_rating"/>
          </div>
        </div>

        <!-- Purge meter with tooltip -->
        <div class="mb-4 relative group">
          <PurgeMeter :score="item.purge_score || 0"/>
          <!-- Purge tooltip -->
          <div class="absolute left-0 bottom-full mb-2 z-50 hidden group-hover:block w-72
            rounded-lg border p-3 text-xs shadow-xl"
            style="background:#0f1117; border-color:#2d3250;">
            <div class="font-semibold text-white mb-2">Purge Risk Score (0–100)</div>
            <div class="text-slate-400 mb-2">Higher = stronger candidate for removal.</div>
            <div class="space-y-1 text-slate-300">
              <div>• Composite rating below 5.0 → up to +50 pts</div>
              <div>• Never watched by either → +20 pts</div>
              <div>• Watched only once total → +10 pts</div>
              <div>• Low resolution (720p / SD) → +15 pts</div>
              <div>• Cancelled show, both watched → +10 pts</div>
              <div>• High rating (≥8.5) → −20 pts (protected)</div>
            </div>
            <div class="mt-2 flex gap-2 text-xs">
              <span class="text-green-400">Green &lt;30</span>
              <span class="text-yellow-400">Yellow 30–54</span>
              <span class="text-orange-400">Orange 55–74</span>
              <span class="text-red-400">Red 75+</span>
            </div>
          </div>
        </div>

        <!-- Watch Analytics (TV) -->
        <div v-if="item.sonarr_id" class="mb-4">
          <h3 class="text-sm font-medium text-slate-400 mb-2">Watch Analytics</h3>

          <!-- Loading -->
          <div v-if="analyticsLoading" class="text-xs text-slate-500 py-2">Loading analytics…</div>

          <!-- Analytics loaded -->
          <div v-else-if="watchAnalytics" class="space-y-2">
            <!-- Per-person rows -->
            <div v-for="(person, key) in { Ali: watchAnalytics.ali, Chris: watchAnalytics.chris }" :key="key"
              class="p-3 rounded-lg" style="background:#0f1117;">
              <div class="flex items-center justify-between mb-1.5">
                <span class="text-xs text-slate-500">{{ key }}</span>
                <span class="text-xs font-medium px-1.5 py-0.5 rounded" :class="statusClass(person.status)">
                  {{ person.status }}
                </span>
              </div>
              <div class="flex items-center gap-2 mb-1">
                <div class="flex-1 h-2 rounded-full overflow-hidden" style="background:#2d3250;">
                  <div class="h-full rounded-full transition-all"
                    :class="depthBarColor(person.status)"
                    :style="{ width: Math.min(person.depth_pct || 0, 100) + '%' }"></div>
                </div>
                <span class="text-xs text-slate-400 w-10 text-right">{{ (person.depth_pct || 0).toFixed(0) }}%</span>
              </div>
              <div class="flex items-center justify-between text-xs text-slate-500">
                <span>{{ person.plays }} ep{{ person.plays !== 1 ? 's' : '' }} played</span>
                <span v-if="person.last_watched">Last: {{ fmtRelDate(person.last_watched) }}</span>
                <span v-else class="text-slate-600">Never</span>
              </div>
            </div>

            <!-- Combined summary -->
            <div class="p-3 rounded-lg flex items-center justify-between" style="background:#0f1117;">
              <div>
                <div class="text-xs text-slate-500 mb-0.5">Combined</div>
                <div class="text-white text-sm">{{ watchAnalytics.combined.plays }} total plays</div>
                <div class="text-xs text-slate-500">
                  {{ watchAnalytics.total_episodes }} episodes total
                  · {{ (watchAnalytics.combined.depth_pct || 0).toFixed(0) }}% coverage
                </div>
              </div>
              <span class="text-sm font-medium px-2 py-1 rounded" :class="statusClass(watchAnalytics.combined.status)">
                {{ watchAnalytics.combined.status }}
              </span>
            </div>

            <!-- Top watchers (if any beyond Ali/Chris) -->
            <div v-if="watchAnalytics.top_watchers && watchAnalytics.top_watchers.length" class="p-3 rounded-lg" style="background:#0f1117;">
              <div class="text-xs text-slate-500 mb-1.5">All watchers (Plex)</div>
              <div class="flex flex-wrap gap-2">
                <span v-for="w in watchAnalytics.top_watchers.slice(0,6)" :key="w.user"
                  class="text-xs px-2 py-0.5 rounded-full bg-slate-800 text-slate-400">
                  {{ w.user }} <span class="text-slate-600">{{ w.plays }}</span>
                </span>
              </div>
            </div>
          </div>

          <!-- Fallback: no analytics data -->
          <div v-else class="space-y-2">
            <div class="grid grid-cols-2 gap-3 mb-2">
              <div class="p-3 rounded-lg" style="background:#0f1117;">
                <div class="text-xs text-slate-500 mb-1">Ali</div>
                <div class="text-white font-medium">{{ item.ali_play_count || 0 }} plays</div>
                <div v-if="item.ali_last_watched" class="text-xs text-slate-500 mt-0.5">Last: {{ fmtDate(item.ali_last_watched) }}</div>
              </div>
              <div class="p-3 rounded-lg" style="background:#0f1117;">
                <div class="text-xs text-slate-500 mb-1">Chris</div>
                <div class="text-white font-medium">{{ item.chris_play_count || 0 }} plays</div>
                <div v-if="item.chris_last_watched" class="text-xs text-slate-500 mt-0.5">Last: {{ fmtDate(item.chris_last_watched) }}</div>
              </div>
            </div>
          </div>
        </div>

        <!-- Watch Analytics (Movies) -->
        <div v-else class="mb-4">
          <h3 class="text-sm font-medium text-slate-400 mb-2">Watch Analytics</h3>
          <div v-if="analyticsLoading" class="text-xs text-slate-500 py-2">Loading analytics…</div>
          <div v-else-if="watchAnalytics" class="space-y-2">
            <div v-for="(person, key) in { Ali: watchAnalytics.ali, Chris: watchAnalytics.chris }" :key="key"
              class="p-3 rounded-lg" style="background:#0f1117;">
              <div class="flex items-center justify-between mb-1">
                <span class="text-xs text-slate-500">{{ key }}</span>
                <span class="text-xs font-medium px-1.5 py-0.5 rounded" :class="statusClass(person.status)">
                  {{ person.status }}
                </span>
              </div>
              <div class="flex items-center justify-between text-xs text-slate-500">
                <span>{{ person.plays }} play{{ person.plays !== 1 ? 's' : '' }}</span>
                <span v-if="person.last_watched">Last: {{ fmtRelDate(person.last_watched) }}</span>
                <span v-else class="text-slate-600">Never</span>
              </div>
            </div>
            <div class="p-3 rounded-lg flex items-center justify-between" style="background:#0f1117;">
              <div>
                <div class="text-xs text-slate-500 mb-0.5">Combined</div>
                <div class="text-white text-sm">{{ watchAnalytics.combined.plays }} total plays</div>
              </div>
              <span class="text-sm font-medium px-2 py-1 rounded" :class="statusClass(watchAnalytics.combined.status)">
                {{ watchAnalytics.combined.status }}
              </span>
            </div>
            <div v-if="watchAnalytics.top_watchers && watchAnalytics.top_watchers.length" class="p-3 rounded-lg" style="background:#0f1117;">
              <div class="text-xs text-slate-500 mb-1.5">All watchers (Plex)</div>
              <div class="flex flex-wrap gap-2">
                <span v-for="w in watchAnalytics.top_watchers.slice(0,6)" :key="w.user"
                  class="text-xs px-2 py-0.5 rounded-full bg-slate-800 text-slate-400">
                  {{ w.user }} <span class="text-slate-600">{{ w.plays }}</span>
                </span>
              </div>
            </div>
          </div>
          <!-- Fallback when analytics not yet loaded -->
          <div v-else class="grid grid-cols-2 gap-3">
            <div class="p-3 rounded-lg" style="background:#0f1117;">
              <div class="text-xs text-slate-500 mb-1">Ali</div>
              <div class="text-white font-medium">{{ item.ali_play_count || 0 }} plays</div>
              <div v-if="item.ali_last_watched" class="text-xs text-slate-500 mt-0.5">Last: {{ fmtDate(item.ali_last_watched) }}</div>
            </div>
            <div class="p-3 rounded-lg" style="background:#0f1117;">
              <div class="text-xs text-slate-500 mb-1">Chris</div>
              <div class="text-white font-medium">{{ item.chris_play_count || 0 }} plays</div>
              <div v-if="item.chris_last_watched" class="text-xs text-slate-500 mt-0.5">Last: {{ fmtDate(item.chris_last_watched) }}</div>
            </div>
          </div>
        </div>

        <!-- File info -->
        <div class="mb-4">
          <h3 class="text-sm font-medium text-slate-400 mb-2">File Info</h3>
          <div class="space-y-1 text-sm">
            <div v-if="item.video_codec" class="flex justify-between">
              <span class="text-slate-500">Video</span>
              <span class="text-slate-300">{{ item.video_codec }}</span>
            </div>
            <div v-if="item.audio_codec" class="flex justify-between">
              <span class="text-slate-500">Audio</span>
              <span class="text-slate-300">{{ item.audio_codec }} {{ item.audio_channels ? item.audio_channels + 'ch' : '' }}</span>
            </div>
            <div v-if="item.file_size_bytes" class="flex justify-between">
              <span class="text-slate-500">Size</span>
              <span class="text-slate-300">{{ formatSize(item.file_size_bytes) }}</span>
            </div>
            <div v-if="item.trash_score" class="flex justify-between">
              <span class="text-slate-500">TRaSH Score</span>
              <span class="text-slate-300">{{ item.trash_score }}</span>
            </div>
            <div v-if="item.file_path" class="flex justify-between gap-2">
              <span class="text-slate-500">Path</span>
              <span class="text-slate-300 text-xs truncate max-w-xs" :title="item.file_path">{{ item.file_path }}</span>
            </div>
          </div>
        </div>

        <!-- Seasons (TV) -->
        <div v-if="item.seasons && item.seasons.length" class="mb-4">
          <h3 class="text-sm font-medium text-slate-400 mb-2">Seasons</h3>
          <div class="space-y-1">
            <div v-for="s in item.seasons" :key="s.season_number"
              class="flex items-center justify-between text-sm p-2 rounded" style="background:#0f1117;">
              <span class="text-slate-300">Season {{ s.season_number }}</span>
              <span class="text-slate-500">{{ s.episodes_downloaded }}/{{ s.episode_count }}</span>
              <div class="w-20 h-1.5 rounded-full overflow-hidden" style="background:#2d3250;">
                <div class="h-full rounded-full bg-violet-600"
                  :style="{ width: s.episode_count > 0 ? (s.episodes_downloaded / s.episode_count * 100) + '%' : '0%' }"></div>
              </div>
            </div>
          </div>
        </div>

        <!-- Summary -->
        <div v-if="item.summary" class="mb-4 text-sm text-slate-400 leading-relaxed">
          {{ item.summary }}
        </div>

        <!-- Overseerr requests -->
        <div v-if="overseerrRequests.length" class="mb-4 p-3 rounded-lg border border-amber-800/40" style="background:#1a1200;">
          <div class="flex items-center gap-2 mb-2">
            <span class="text-amber-400 text-xs font-semibold">⚠ Requested via Overseerr</span>
          </div>
          <div v-for="req in overseerrRequests" :key="req.id" class="text-xs text-slate-400 mb-1">
            <span class="font-medium text-slate-300">{{ req.requested_by }}</span>
            <span class="text-slate-600"> · {{ req.status_label }}</span>
            <span v-if="req.season_numbers" class="text-slate-600"> · Seasons {{ req.season_numbers }}</span>
            <span class="text-slate-600"> · {{ fmtRelDate(req.requested_at) }}</span>
          </div>
        </div>

        <!-- Actions -->
        <div class="flex gap-3 pt-4 border-t" style="border-color:#2d3250;">
          <button @click="$emit('unmonitor', item)" class="flex-1 btn-secondary text-sm">
            Unmonitor
          </button>
          <button @click="$emit('delete', item)"
            class="flex-1 text-sm font-medium rounded-lg px-4 py-2 transition-colors"
            :class="overseerrRequests.length
              ? 'bg-amber-700 hover:bg-amber-600 text-white'
              : 'btn-danger'">
            {{ overseerrRequests.length ? '⚠ Delete (requested)' : 'Delete' }}
          </button>
        </div>

        <!-- External links -->
        <div class="mt-3 flex flex-wrap gap-2 text-xs">
          <a v-if="item.radarr_id && radarrUrl" :href="radarrUrl" target="_blank"
            class="text-slate-500 hover:text-slate-300 transition-colors">Radarr ↗</a>
          <a v-if="item.sonarr_id && sonarrUrl" :href="sonarrUrl" target="_blank"
            class="text-slate-500 hover:text-slate-300 transition-colors">Sonarr ↗</a>
          <a v-if="plexChrisUrl" :href="plexChrisUrl" target="_blank"
            class="text-slate-500 hover:text-slate-300 transition-colors">Plex (Chris) ↗</a>
          <a v-if="plexAliUrl" :href="plexAliUrl" target="_blank"
            class="text-slate-500 hover:text-slate-300 transition-colors">Plex (Ali) ↗</a>
          <a v-if="item.imdb_id" :href="`https://www.imdb.com/title/${item.imdb_id}`" target="_blank"
            class="text-slate-500 hover:text-slate-300 transition-colors">IMDb ↗</a>
          <a v-if="item.tmdb_id && item.radarr_id" :href="`https://www.themoviedb.org/movie/${item.tmdb_id}`" target="_blank"
            class="text-slate-500 hover:text-slate-300 transition-colors">TMDB ↗</a>
          <a v-if="item.tmdb_id && item.sonarr_id" :href="`https://www.themoviedb.org/tv/${item.tmdb_id}`" target="_blank"
            class="text-slate-500 hover:text-slate-300 transition-colors">TMDB ↗</a>
        </div>
      </div>
    </div>
  </transition>
</template>

<script setup>
import { computed, ref, inject, watch } from 'vue'
import RatingBadge from './RatingBadge.vue'
import PurgeMeter from './PurgeMeter.vue'

const props = defineProps({ item: Object })
defineEmits(['close', 'delete', 'unmonitor'])

const overseerrRequests = ref([])

// Public URLs injected from parent (or loaded globally)
const publicUrls = inject('publicUrls', ref({}))

const posterError = ref(false)
const watchAnalytics = ref(null)
const analyticsLoading = ref(false)

async function loadAnalytics(item) {
  if (!item?.id) { watchAnalytics.value = null; return }
  analyticsLoading.value = true
  try {
    const url = item.sonarr_id
      ? `/api/tv/${item.id}/watch-analytics`
      : `/api/movies/${item.id}/watch-analytics`
    const r = await fetch(url)
    if (r.ok) watchAnalytics.value = await r.json()
    else watchAnalytics.value = null
  } catch { watchAnalytics.value = null }
  finally { analyticsLoading.value = false }
}

async function loadOverseerr(item) {
  overseerrRequests.value = []
  if (!item?.tmdb_id) return
  try {
    const r = await fetch(`/api/overseerr/requests?tmdb_id=${item.tmdb_id}`)
    if (r.ok) overseerrRequests.value = await r.json()
  } catch {}
}

watch(() => props.item, (item) => {
  posterError.value = false
  loadAnalytics(item)
  loadOverseerr(item)
}, { immediate: true })

const bothWatched = computed(() =>
  (props.item?.ali_play_count || 0) > 0 && (props.item?.chris_play_count || 0) > 0
)

const combinedLastWatched = computed(() => {
  const a = props.item?.ali_last_watched
  const c = props.item?.chris_last_watched
  if (!a && !c) return null
  if (!a) return c
  if (!c) return a
  return a > c ? a : c
})

const posterSrc = computed(() => {
  if (posterError.value) return null
  if (!props.item) return null
  // TMDB poster preferred (no Plex dependency)
  if (props.item.poster_url) return props.item.poster_url
  // Fallback: Plex proxy
  if (props.item.plex_key) return `/api/poster?url=/library/metadata/${props.item.plex_key}/thumb&server=chris`
  return null
})

const statusClass = (status) => ({
  // Show status badges
  'Continuing': 'bg-green-900 text-green-300',
  'Ended': 'bg-slate-700 text-slate-300',
  'Cancelled': 'bg-red-900 text-red-300',
  // Watch analytics status badges
  'Never': 'bg-slate-700 text-slate-400',
  'Abandoned': 'bg-orange-900 text-orange-300',
  'Stalled': 'bg-yellow-900 text-yellow-300',
  'Watching': 'bg-blue-900 text-blue-300',
  'Active': 'bg-green-900 text-green-300',
}[status] || 'bg-slate-700 text-slate-300')

const depthBarColor = (status) => ({
  'Never': 'bg-slate-600',
  'Abandoned': 'bg-orange-500',
  'Stalled': 'bg-yellow-500',
  'Watching': 'bg-blue-500',
  'Active': 'bg-green-500',
}[status] || 'bg-violet-500')

const fmtRelDate = (iso) => {
  if (!iso) return ''
  const d = new Date(iso.includes('Z') ? iso : iso + 'Z')
  const days = Math.floor((Date.now() - d) / 86400000)
  if (days === 0) return 'Today'
  if (days < 30) return `${days}d ago`
  if (days < 365) return `${Math.floor(days / 30)}mo ago`
  return `${Math.floor(days / 365)}y ago`
}

const formatSize = (bytes) => {
  const gb = bytes / 1_073_741_824
  return gb >= 1 ? `${gb.toFixed(1)} GB` : `${(bytes / 1_048_576).toFixed(0)} MB`
}

const fmtDate = (d) => d ? new Date(d.includes('Z') ? d : d + 'Z').toLocaleDateString() : ''

const fmtRuntime = (min) => {
  if (!min) return ''
  const h = Math.floor(min / 60)
  const m = min % 60
  return h > 0 ? (m > 0 ? `${h}h ${m}m` : `${h}h`) : `${m}m`
}

const radarrUrl = computed(() => {
  if (!props.item?.radarr_id) return null
  const urls = publicUrls.value || {}
  const base = props.item.radarr_instance === 'radarr-4k'
    ? (urls.radarr_4k || '')
    : (urls.radarr_hd || '')
  if (!base) return null
  return `${base}/movie/${props.item.radarr_id}`
})

const plexChrisUrl = computed(() => {
  const urls = publicUrls.value || {}
  const machineId = urls.plex_chris_machine_id
  const key = props.item?.chris_plex_key || props.item?.plex_key
  if (!machineId || !key) return null
  return `https://app.plex.tv/desktop/#!/server/${machineId}/details?key=%2Flibrary%2Fmetadata%2F${key}`
})

const plexAliUrl = computed(() => {
  const urls = publicUrls.value || {}
  const machineId = urls.plex_ali_machine_id
  const key = props.item?.ali_plex_key || props.item?.plex_key
  if (!machineId || !key) return null
  return `https://app.plex.tv/desktop/#!/server/${machineId}/details?key=%2Flibrary%2Fmetadata%2F${key}`
})

const sonarrUrl = computed(() => {
  if (!props.item?.sonarr_id) return null
  const urls = publicUrls.value || {}
  const base = props.item.sonarr_instance === 'sonarr-4k'
    ? (urls.sonarr_4k || '')
    : (urls.sonarr_hd || '')
  if (!base) return null
  return `${base}/series/${props.item.sonarr_id}`
})
</script>

<style scoped>
.slide-enter-active, .slide-leave-active {
  transition: transform 0.25s ease;
}
.slide-enter-from, .slide-leave-to {
  transform: translateX(100%);
}
</style>
