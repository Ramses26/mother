<template>
  <div class="p-6 max-w-6xl mx-auto">
    <div class="flex items-center justify-between mb-6">
      <div>
        <h1 class="text-2xl font-bold text-white">Unwatched Seasons</h1>
        <p class="text-sm text-slate-500 mt-1">Shows with episodes on disk that neither person has started</p>
      </div>
      <div class="flex items-center gap-3">
        <select v-model="statusFilter" @change="load" class="input text-sm py-1.5">
          <option value="">All Statuses</option>
          <option value="Continuing">Continuing</option>
          <option value="Ended">Ended</option>
          <option value="Cancelled">Cancelled</option>
        </select>
        <button @click="load" :disabled="loading" class="btn-secondary text-sm">Refresh</button>
      </div>
    </div>

    <div v-if="loading" class="flex items-center justify-center py-20">
      <div class="animate-spin h-8 w-8 border-2 border-violet-500/30 border-t-violet-500 rounded-full"></div>
    </div>

    <div v-else-if="items.length === 0" class="text-center py-20 text-slate-500">
      No unwatched seasons found{{ statusFilter ? ` for ${statusFilter} shows` : '' }}
    </div>

    <div v-else>
      <p class="text-xs text-slate-500 mb-4">{{ total }} shows · {{ totalEpisodes.toLocaleString() }} episodes on disk, never started</p>

      <!-- Summary stats -->
      <div class="grid grid-cols-3 gap-4 mb-6">
        <div class="card text-center">
          <div class="text-2xl font-bold text-violet-400">{{ total }}</div>
          <div class="text-xs text-slate-500 mt-1">Shows Never Started</div>
        </div>
        <div class="card text-center">
          <div class="text-2xl font-bold text-blue-400">{{ totalSeasons }}</div>
          <div class="text-xs text-slate-500 mt-1">Seasons On Disk</div>
        </div>
        <div class="card text-center">
          <div class="text-2xl font-bold text-amber-400">{{ totalEpisodes.toLocaleString() }}</div>
          <div class="text-xs text-slate-500 mt-1">Episodes On Disk</div>
        </div>
      </div>

      <table class="w-full text-sm">
        <thead>
          <tr class="text-left text-slate-500 border-b" style="border-color:#2d3250;">
            <th class="py-2 pr-4 font-medium">Title</th>
            <th class="py-2 pr-4 font-medium">Status</th>
            <th class="py-2 pr-4 font-medium">Instance</th>
            <th class="py-2 pr-4 font-medium">Rating</th>
            <th class="py-2 pr-4 font-medium">Seasons On Disk</th>
            <th class="py-2 pr-4 font-medium">Episodes On Disk</th>
            <th class="py-2 font-medium">Seasons Detail</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="show in items" :key="show.id"
            class="border-b hover:bg-surface-100 transition-colors"
            style="border-color:#1a1d27;">
            <td class="py-2 pr-4">
              <div class="text-white font-medium">{{ show.title }}</div>
              <div class="text-xs text-slate-500">{{ show.year }}</div>
            </td>
            <td class="py-2 pr-4">
              <span class="text-xs px-1.5 py-0.5 rounded" :class="statusClass(show.status)">
                {{ show.status }}
              </span>
            </td>
            <td class="py-2 pr-4 text-slate-400 text-xs">{{ show.sonarr_instance }}</td>
            <td class="py-2 pr-4">
              <span v-if="show.composite_score" class="text-violet-400">{{ show.composite_score.toFixed(1) }}</span>
              <span v-else class="text-slate-600">—</span>
            </td>
            <td class="py-2 pr-4 text-slate-300">{{ show.seasons_on_disk.length }}</td>
            <td class="py-2 pr-4 text-slate-300">{{ show.total_on_disk }}</td>
            <td class="py-2">
              <div class="flex flex-wrap gap-1">
                <span v-for="s in show.seasons_on_disk" :key="s.season_number"
                  class="text-xs px-1.5 py-0.5 rounded bg-slate-700 text-slate-300"
                  :title="`S${s.season_number}: ${s.episodes_downloaded}/${s.episode_count} eps`">
                  S{{ s.season_number }}
                  <span class="text-slate-500">({{ s.episodes_downloaded }})</span>
                </span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'

const items = ref([])
const total = ref(0)
const loading = ref(false)
const statusFilter = ref('')

const totalEpisodes = computed(() => items.value.reduce((s, i) => s + (i.total_on_disk || 0), 0))
const totalSeasons = computed(() => items.value.reduce((s, i) => s + (i.seasons_on_disk?.length || 0), 0))

const load = async () => {
  loading.value = true
  try {
    const params = {}
    if (statusFilter.value) params.status = statusFilter.value
    const res = await axios.get('/api/tv/unwatched-seasons', { params })
    items.value = res.data.items || []
    total.value = res.data.total || 0
  } catch {} finally { loading.value = false }
}

const statusClass = (s) => ({
  'Continuing': 'bg-green-900 text-green-300',
  'Ended': 'bg-slate-700 text-slate-300',
  'Cancelled': 'bg-red-900 text-red-300',
}[s] || 'bg-slate-700 text-slate-300')

onMounted(load)
</script>
