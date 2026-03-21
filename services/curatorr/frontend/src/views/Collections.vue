<template>
  <div class="p-6 max-w-7xl mx-auto">
    <h1 class="text-2xl font-bold text-white mb-6">Collections</h1>

    <div v-if="loading" class="flex items-center justify-center py-20">
      <div class="animate-spin h-8 w-8 border-2 border-violet-500/30 border-t-violet-500 rounded-full"></div>
    </div>

    <div v-else-if="!selected" class="grid gap-4" style="grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));">
      <div v-for="c in collections" :key="c.tmdb_id"
        class="card cursor-pointer hover:border-violet-600 transition-colors"
        @click="loadCollection(c)">
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

    <!-- Collection detail -->
    <div v-else>
      <button @click="selected = null; missing = null" class="btn-secondary text-sm mb-4">← Back</button>
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
        <button @click="loadMissing" :disabled="loadingMissing" class="btn-secondary text-sm">
          {{ loadingMissing ? 'Checking...' : 'Check Missing' }}
        </button>
      </div>

      <!-- Missing movies section -->
      <div v-if="missing !== null && missing.length > 0" class="mb-6">
        <h3 class="text-lg font-semibold text-white mb-3">Missing from Collection</h3>
        <div class="grid gap-3" style="grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));">
          <div v-for="m in missing" :key="m.tmdb_id"
            class="card p-3 flex flex-col">
            <img v-if="m.poster_url" :src="m.poster_url" class="w-full aspect-[2/3] object-cover rounded-lg mb-2" loading="lazy"/>
            <div class="flex-1">
              <div class="text-white text-sm font-medium">{{ m.title }}</div>
              <div class="text-slate-500 text-xs">{{ m.year }}</div>
              <div v-if="m.vote_average" class="text-violet-400 text-xs">★ {{ m.vote_average.toFixed(1) }}</div>
            </div>
            <button @click="requestMovie(m)" :disabled="m._requesting || m._requested"
              class="mt-2 w-full text-xs py-1.5 rounded transition-colors"
              :class="m._requested ? 'bg-green-800 text-green-300' : m._error ? 'bg-red-800 text-red-300' : 'btn-secondary'">
              {{ m._requested ? 'Requested ✓' : m._requesting ? 'Requesting...' : m._error || 'Request via Overseerr' }}
            </button>
          </div>
        </div>
      </div>

      <div v-else-if="missing !== null && missing.length === 0" class="mb-6 p-4 rounded-lg text-green-400 text-sm" style="background:#0f2310;">
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
import { ref, onMounted } from 'vue'
import axios from 'axios'

const collections = ref([])
const selected = ref(null)
const loading = ref(false)
const loadingMissing = ref(false)
const missing = ref(null)

const loadCollections = async () => {
  loading.value = true
  try { const res = await axios.get('/api/collections'); collections.value = res.data }
  catch {} finally { loading.value = false }
}

const loadCollection = async (c) => {
  try { const res = await axios.get(`/api/collections/${c.tmdb_id}`); selected.value = res.data; missing.value = null }
  catch { selected.value = { ...c, movies: [] } }
}

const loadMissing = async () => {
  if (!selected.value) return
  loadingMissing.value = true
  try {
    const res = await axios.get(`/api/collections/${selected.value.tmdb_id}/missing`)
    missing.value = res.data.missing.map(m => ({ ...m, _requesting: false, _requested: false, _error: null }))
  } catch (e) {
    alert(e.response?.data?.detail || 'Could not check missing movies')
  } finally {
    loadingMissing.value = false
  }
}

const requestMovie = async (movie) => {
  movie._requesting = true
  movie._error = null
  try {
    const res = await axios.post(`/api/collections/${selected.value.tmdb_id}/request/${movie.tmdb_id}`)
    movie._requested = true
  } catch (e) {
    movie._error = e.response?.data?.detail || 'Request failed'
  } finally {
    movie._requesting = false
  }
}

onMounted(loadCollections)
</script>
