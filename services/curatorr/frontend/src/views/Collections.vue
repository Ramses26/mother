<template>
  <div class="p-6 max-w-7xl mx-auto">
    <h1 class="text-2xl font-bold text-white mb-6">Collections</h1>

    <div v-if="loading" class="flex items-center justify-center py-20">
      <div class="animate-spin h-8 w-8 border-2 border-violet-500/30 border-t-violet-500 rounded-full"></div>
    </div>

    <div v-else-if="!selected">
      <!-- Filter/sort bar -->
      <div class="flex items-center gap-3 mb-4">
        <button @click="hasMissing = !hasMissing; loadCollections()"
          class="text-xs px-3 py-1.5 rounded transition-colors"
          :class="hasMissing ? 'bg-violet-600 text-white' : 'bg-surface-200 text-slate-400 hover:text-white'">
          Has Missing
        </button>
        <select v-model="sortBy" @change="loadCollections" class="input text-xs py-1 w-36">
          <option value="name">Name</option>
          <option value="completion_pct">Completion</option>
          <option value="owned_count">Owned Count</option>
          <option value="movie_count">Total Movies</option>
        </select>
        <button @click="toggleSortDir" class="text-slate-400 hover:text-white px-1 text-sm">
          {{ sortDir === 'asc' ? '↑' : '↓' }}
        </button>
        <span class="text-xs text-slate-500">{{ collections.length }} collections</span>
      </div>

      <div class="grid gap-4" style="grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));">
        <div v-for="c in collections" :key="c.tmdb_id"
          class="card cursor-pointer hover:border-violet-600 transition-colors"
          @click="openCollection(c)">
          <div v-if="c.poster_url" class="w-full aspect-[2/3] rounded-lg overflow-hidden mb-3">
            <img :src="c.poster_url" class="w-full h-full object-cover"/>
          </div>
          <div v-else class="w-full aspect-square rounded-lg mb-3 flex items-center justify-center text-4xl"
            style="background:#2d3250;">🎬</div>
          <div class="font-medium text-white text-sm">{{ c.name }}</div>
          <div class="text-xs text-slate-400 mt-1">{{ c.owned_count || 0 }}/{{ c.movie_count || '?' }} owned</div>
          <div class="mt-2 w-full h-1.5 rounded-full overflow-hidden" style="background:#2d3250;">
            <div class="h-full rounded-full bg-violet-600"
              :style="{ width: c.movie_count > 0 ? ((c.owned_count || 0) / c.movie_count * 100) + '%' : '0%' }"></div>
          </div>
        </div>
      </div>
    </div>

    <!-- Collection detail -->
    <div v-else>
      <button @click="goBack" class="btn-secondary text-sm mb-4">← Back</button>
      <div class="flex items-center gap-4 mb-6">
        <img v-if="selected.poster_url" :src="selected.poster_url" class="w-20 rounded-lg" loading="lazy"/>
        <div>
          <h2 class="text-xl font-bold text-white">{{ selected.name }}</h2>
          <div class="text-slate-400 text-sm mt-1">
            {{ selected.movies.length }} owned
            <span v-if="missing !== null"> · {{ missing.length }} missing</span>
          </div>
        </div>
        <div class="flex-1"/>
      </div>

      <!-- Missing movies section -->
      <div v-if="loadingMissing" class="mb-4">
        <div class="animate-pulse text-slate-500 text-xs">Checking TMDB for missing movies...</div>
      </div>
      <div v-if="missingError" class="mb-4 text-slate-500 text-xs">{{ missingError }}</div>
      <div v-if="!loadingMissing && missing !== null && missing.length > 0" class="mb-6">
        <h3 class="text-lg font-semibold text-white mb-3">Missing from Collection</h3>
        <div class="grid gap-3" style="grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));">
          <div v-for="m in missing" :key="m.tmdb_id"
            class="card p-3 flex flex-col">
            <img v-if="m.poster_url" :src="m.poster_url" class="w-full aspect-[2/3] object-cover rounded-lg mb-2" loading="lazy"/>
            <div class="flex-1">
              <div class="text-white text-sm font-medium">{{ m.title }}</div>
              <div class="text-slate-500 text-xs">{{ m.year }}</div>
              <div v-if="m.vote_average" class="text-violet-400 text-xs">★ {{ m.vote_average.toFixed(1) }}</div>
              <a v-if="m.tmdb_id" :href="`https://www.themoviedb.org/movie/${m.tmdb_id}`" target="_blank"
                class="text-blue-400 text-xs hover:text-blue-300 transition-colors">TMDB ↗</a>
            </div>
            <button @click="addToRadarr(m)" :disabled="m._adding || m._added"
              class="mt-2 w-full text-xs py-1.5 rounded transition-colors"
              :class="m._added ? 'bg-green-800 text-green-300' : m._addError ? 'bg-red-800 text-red-300' : 'bg-violet-700 hover:bg-violet-600 text-white'">
              {{ m._added ? 'Added ✓' : m._adding ? 'Adding...' : m._addError || '+ Add to Radarr' }}
            </button>
            <button @click="requestMovie(m)" :disabled="m._requesting || m._requested"
              class="mt-1 w-full text-xs py-1.5 rounded transition-colors"
              :class="m._requested ? 'bg-green-800 text-green-300' : m._error ? 'bg-red-800 text-red-300' : 'btn-secondary'">
              {{ m._requested ? 'Overseerr ✓' : m._requesting ? 'Requesting...' : m._error || 'Request via Overseerr' }}
            </button>
          </div>
        </div>
      </div>

      <div v-else-if="!loadingMissing && missing !== null && missing.length === 0" class="mb-6 p-4 rounded-lg text-green-400 text-sm" style="background:#0f2310;">
        Collection complete — all movies are in your library.
      </div>

      <!-- Owned movies -->
      <h3 class="text-lg font-semibold text-white mb-3">In Library</h3>
      <div class="grid gap-3">
        <div v-for="m in selected.movies" :key="m.id"
          class="card flex items-center gap-4">
          <div class="w-12 h-16 rounded overflow-hidden flex-shrink-0" style="background:#2d3250;">
            <img v-if="m.poster_url" :src="m.poster_url" class="w-full h-full object-cover" loading="lazy"/>
            <span v-else class="text-2xl flex items-center justify-center h-full">🎬</span>
          </div>
          <div class="flex-1">
            <div class="text-white font-medium">{{ m.title }}</div>
            <div class="text-sm text-slate-400">{{ m.year }} · {{ m.resolution }}</div>
          </div>
          <div class="flex gap-2 items-center">
            <span v-if="m.composite_score" class="text-violet-400 text-sm font-medium">{{ m.composite_score.toFixed(1) }}</span>
            <span class="px-2 py-0.5 rounded text-xs bg-green-900 text-green-300">Owned</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, nextTick, onMounted } from 'vue'
import axios from 'axios'

const collections = ref([])
const selected = ref(null)
const loading = ref(false)
const loadingMissing = ref(false)
const missing = ref(null)
const missingError = ref('')
const hasMissing = ref(false)
const sortBy = ref('name')
const sortDir = ref('asc')
const savedScrollY = ref(0)

const loadCollections = async () => {
  loading.value = true
  try {
    const res = await axios.get('/api/collections', {
      params: { has_missing: hasMissing.value, sort_by: sortBy.value, sort_dir: sortDir.value }
    })
    collections.value = res.data
  } catch {} finally { loading.value = false }
}

const toggleSortDir = () => {
  sortDir.value = sortDir.value === 'asc' ? 'desc' : 'asc'
  loadCollections()
}

const openCollection = async (c) => {
  savedScrollY.value = window.scrollY
  missing.value = null
  missingError.value = ''
  try { const res = await axios.get(`/api/collections/${c.tmdb_id}`); selected.value = res.data }
  catch { selected.value = { ...c, movies: [] } }
  loadMissing()
}

const goBack = () => {
  selected.value = null
  missing.value = null
  nextTick(() => window.scrollTo(0, savedScrollY.value))
}

const loadMissing = async () => {
  if (!selected.value) return
  loadingMissing.value = true
  missingError.value = ''
  try {
    const res = await axios.get(`/api/collections/${selected.value.tmdb_id}/missing`)
    missing.value = res.data.missing.map(m => ({ ...m, _requesting: false, _requested: false, _error: null, _adding: false, _added: false, _addError: null }))
  } catch (e) {
    const msg = e.response?.data?.detail || ''
    if (e.response?.status === 503 || msg.toLowerCase().includes('tmdb') || msg.toLowerCase().includes('key')) {
      missingError.value = 'Missing check unavailable (TMDB key not set)'
    } else {
      missingError.value = msg || 'Could not check missing movies'
    }
    missing.value = []
  } finally {
    loadingMissing.value = false
  }
}

const requestMovie = async (movie) => {
  movie._requesting = true
  movie._error = null
  try {
    await axios.post(`/api/collections/${selected.value.tmdb_id}/request/${movie.tmdb_id}`)
    movie._requested = true
  } catch (e) {
    movie._error = e.response?.data?.detail || 'Request failed'
  } finally {
    movie._requesting = false
  }
}

const addToRadarr = async (movie) => {
  movie._adding = true
  movie._addError = null
  try {
    await axios.post(`/api/collections/${selected.value.tmdb_id}/add-to-radarr/${movie.tmdb_id}`)
    movie._added = true
  } catch (e) {
    movie._addError = e.response?.data?.detail || 'Add failed'
  } finally {
    movie._adding = false
  }
}

onMounted(loadCollections)
</script>
