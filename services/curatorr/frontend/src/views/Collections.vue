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
      <button @click="selected = null" class="btn-secondary text-sm mb-4">← Back</button>
      <h2 class="text-xl font-bold text-white mb-4">{{ selected.name }}</h2>
      <div class="grid gap-3">
        <div v-for="m in selected.movies" :key="m.id"
          class="card flex items-center gap-4">
          <div class="w-12 h-16 rounded overflow-hidden flex-shrink-0" style="background:#2d3250;">
            <span class="text-2xl flex items-center justify-center h-full">🎬</span>
          </div>
          <div class="flex-1">
            <div class="text-white font-medium">{{ m.title }}</div>
            <div class="text-sm text-slate-400">{{ m.year }} · {{ m.resolution }}</div>
          </div>
          <div class="flex gap-2">
            <span v-if="m.composite_score" class="text-violet-400 text-sm font-medium">{{ m.composite_score.toFixed(1) }}</span>
            <span v-if="m.id" class="px-2 py-0.5 rounded text-xs bg-green-900 text-green-300">Owned</span>
            <span v-else class="px-2 py-0.5 rounded text-xs bg-slate-700 text-slate-400">Missing</span>
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

const loadCollections = async () => {
  loading.value = true
  try { const res = await axios.get('/api/collections'); collections.value = res.data }
  catch {} finally { loading.value = false }
}

const loadCollection = async (c) => {
  try { const res = await axios.get(`/api/collections/${c.tmdb_id}`); selected.value = res.data }
  catch { selected.value = { ...c, movies: [] } }
}

onMounted(loadCollections)
</script>
