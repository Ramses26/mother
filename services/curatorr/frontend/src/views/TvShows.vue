<template>
  <div class="flex h-screen-minus-nav" style="height:calc(100vh - 56px);">
    <!-- Filter Sidebar -->
    <div class="w-72 border-r overflow-y-auto flex-shrink-0" style="background:#1a1d27; border-color:#2d3250;">
      <div class="p-4">
        <h2 class="text-sm font-semibold text-slate-300 uppercase tracking-wider mb-3">Filters</h2>
        <!-- Presets -->
        <div class="grid grid-cols-2 gap-1.5 mb-4">
          <button v-for="p in presets" :key="p.value" @click="applyPreset(p.value)"
            class="text-xs px-2 py-1.5 rounded transition-colors"
            :class="activePreset === p.value ? 'bg-violet-600 text-white' : 'bg-surface-200 text-slate-400 hover:text-white'">
            {{ p.label }}
          </button>
        </div>
        <!-- Search -->
        <div class="mb-3">
          <input v-model="filters.title" class="input text-sm" placeholder="Search title..." @input="debouncedFetch"/>
        </div>
        <!-- Composite Score -->
        <div class="mb-3">
          <label class="label">Composite Score</label>
          <div class="flex gap-2">
            <input type="number" v-model.number="filters.composite_min" min="0" max="10" step="0.5" class="input text-xs py-1" placeholder="Min" @change="fetchShows"/>
            <input type="number" v-model.number="filters.composite_max" min="0" max="10" step="0.5" class="input text-xs py-1" placeholder="Max" @change="fetchShows"/>
          </div>
        </div>
        <!-- Status -->
        <div class="mb-3">
          <label class="label">Status</label>
          <select v-model="filters.status" @change="fetchShows" class="input text-sm">
            <option value="">All</option>
            <option value="Continuing">Continuing</option>
            <option value="Ended">Ended</option>
            <option value="Cancelled">Cancelled</option>
          </select>
        </div>
        <!-- Watch -->
        <div class="mb-3">
          <label class="label">Watch Status</label>
          <label class="flex items-center gap-2 cursor-pointer text-sm mb-1">
            <input type="checkbox" v-model="filters.neither_watched" @change="fetchShows"/>
            <span class="text-slate-300">Neither watched</span>
          </label>
          <label class="flex items-center gap-2 cursor-pointer text-sm">
            <input type="checkbox" v-model="filters.cancelled_watched" @change="fetchShows"/>
            <span class="text-slate-300">Cancelled but watched</span>
          </label>
        </div>
        <!-- IMDb -->
        <div class="mb-3">
          <label class="label">IMDb Rating</label>
          <div class="flex gap-2">
            <input type="number" v-model.number="filters.imdb_min" min="0" max="10" step="0.5" class="input text-xs py-1" placeholder="Min" @change="fetchShows"/>
            <input type="number" v-model.number="filters.imdb_max" min="0" max="10" step="0.5" class="input text-xs py-1" placeholder="Max" @change="fetchShows"/>
          </div>
        </div>
        <!-- Instance -->
        <div class="mb-3">
          <label class="label">Instance</label>
          <select v-model="filters.instance" @change="fetchShows" class="input text-sm">
            <option value="">All</option>
            <option value="sonarr-hd">Sonarr HD</option>
            <option value="sonarr-4k">Sonarr 4K</option>
          </select>
        </div>
        <button @click="clearFilters" class="w-full btn-secondary text-sm mt-2">Clear</button>
      </div>
    </div>

    <!-- Main content -->
    <div class="flex-1 overflow-y-auto">
      <!-- Toolbar -->
      <div class="sticky top-0 z-20 flex items-center gap-3 px-4 py-2 border-b" style="background:#0f1117; border-color:#2d3250;">
        <span class="text-sm text-slate-400">{{ total.toLocaleString() }} shows</span>
        <div class="flex-1"/>
        <select v-model="sortBy" @change="fetchShows" class="input text-xs py-1 w-36">
          <option value="sort_title">Title</option>
          <option value="year">Year</option>
          <option value="composite_score">Rating</option>
          <option value="purge_score">Purge Score</option>
          <option value="status">Status</option>
          <option value="season_completion_pct">Completion</option>
        </select>
        <button @click="toggleSortDir" class="text-slate-400 hover:text-white px-2">
          {{ sortDir === 'asc' ? '↑' : '↓' }}
        </button>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="flex items-center justify-center py-20">
        <div class="animate-spin h-8 w-8 border-2 border-violet-500/30 border-t-violet-500 rounded-full"></div>
      </div>

      <!-- Table -->
      <div v-else class="p-4">
        <table class="w-full text-sm">
          <thead>
            <tr class="text-left text-slate-500 border-b" style="border-color:#2d3250;">
              <th class="py-2 pr-4 font-medium">Title</th>
              <th class="py-2 pr-4 font-medium">Status</th>
              <th class="py-2 pr-4 font-medium">Rating</th>
              <th class="py-2 pr-4 font-medium">Seasons</th>
              <th class="py-2 pr-4 font-medium">Completion</th>
              <th class="py-2 pr-4 font-medium">Watched</th>
              <th class="py-2 font-medium">Purge</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="s in shows" :key="s.id"
              class="border-b hover:bg-surface-100 cursor-pointer transition-colors"
              style="border-color:#1a1d27;"
              @click="openDetail(s)">
              <td class="py-2 pr-4">
                <div class="text-white font-medium">{{ s.title }}</div>
                <div class="text-xs text-slate-500">{{ s.year }} · {{ s.network }}</div>
              </td>
              <td class="py-2 pr-4">
                <span class="px-1.5 py-0.5 rounded text-xs font-medium" :class="statusClass(s.status)">
                  {{ s.status || '?' }}
                </span>
              </td>
              <td class="py-2 pr-4">
                <span v-if="s.composite_score" class="text-violet-400 font-medium">{{ s.composite_score.toFixed(1) }}</span>
                <span v-else class="text-slate-600">—</span>
              </td>
              <td class="py-2 pr-4 text-slate-400">{{ s.total_seasons }}</td>
              <td class="py-2 pr-4">
                <div class="flex items-center gap-2">
                  <div class="w-16 h-1.5 rounded-full overflow-hidden" style="background:#2d3250;">
                    <div class="h-full rounded-full bg-violet-600"
                      :style="{ width: (s.season_completion_pct || 0) + '%' }"></div>
                  </div>
                  <span class="text-xs text-slate-500">{{ s.season_completion_pct || 0 }}%</span>
                </div>
              </td>
              <td class="py-2 pr-4 text-xs">
                <span :class="s.ali_play_count > 0 ? 'text-green-400' : 'text-slate-600'">A</span>
                <span :class="s.chris_play_count > 0 ? 'text-green-400' : 'text-slate-600'"> C</span>
              </td>
              <td class="py-2">
                <span class="px-1.5 py-0.5 rounded text-xs font-medium" :class="purgeScoreClass(s.purge_score)">
                  {{ s.purge_score || 0 }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      <div class="flex items-center justify-between px-4 py-3 border-t" style="border-color:#2d3250;">
        <button @click="prevPage" :disabled="page === 1" class="btn-secondary text-sm px-3 py-1.5 disabled:opacity-40">Previous</button>
        <span class="text-slate-400 text-sm">Page {{ page }} of {{ pages }}</span>
        <button @click="nextPage" :disabled="page >= pages" class="btn-secondary text-sm px-3 py-1.5 disabled:opacity-40">Next</button>
      </div>
    </div>

    <!-- Detail panel -->
    <MediaDetail :item="selectedItem" @close="selectedItem = null"
      @delete="startDelete" @unmonitor="doUnmonitor"/>
    <DeleteConfirm :show="!!deleteTarget" :item="deleteTarget" :require-typing="true"
      @confirm="doDelete" @cancel="deleteTarget = null"/>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import axios from 'axios'
import MediaDetail from '../components/MediaDetail.vue'
import DeleteConfirm from '../components/DeleteConfirm.vue'

const route = useRoute()
const shows = ref([])
const total = ref(0)
const page = ref(1)
const pages = ref(1)
const loading = ref(false)
const selectedItem = ref(null)
const deleteTarget = ref(null)
const sortBy = ref('sort_title')
const sortDir = ref('asc')
const activePreset = ref('')
let fetchTimer = null

const presets = [
  { value: 'never_watched', label: 'Never Watched' },
  { value: 'cancelled_watched', label: 'Cancelled + Watched' },
  { value: 'purge_candidates', label: 'Purge Candidates' },
  { value: 'low_rated_unwatched', label: 'Low Rated' },
]

const filters = reactive({
  title: '', composite_min: null, composite_max: null,
  imdb_min: null, imdb_max: null, status: '',
  neither_watched: false, cancelled_watched: false, instance: '',
})

const buildParams = () => {
  const p = { page: page.value, per_page: 50, sort_by: sortBy.value, sort_dir: sortDir.value }
  if (filters.title) p.title = filters.title
  if (filters.composite_min != null) p.composite_min = filters.composite_min
  if (filters.composite_max != null) p.composite_max = filters.composite_max
  if (filters.imdb_min != null) p.imdb_min = filters.imdb_min
  if (filters.imdb_max != null) p.imdb_max = filters.imdb_max
  if (filters.status) p.status = filters.status
  if (filters.neither_watched) p.neither_watched = 'true'
  if (filters.cancelled_watched) p.cancelled_watched = 'true'
  if (filters.instance) p.instance = filters.instance
  return p
}

const fetchShows = async () => {
  loading.value = true
  try {
    const res = await axios.get('/api/tv', { params: buildParams() })
    shows.value = res.data.items
    total.value = res.data.total
    pages.value = res.data.pages
  } catch {} finally { loading.value = false }
}

const debouncedFetch = () => { clearTimeout(fetchTimer); fetchTimer = setTimeout(fetchShows, 400) }

const applyPreset = (preset) => {
  clearFilters()
  activePreset.value = preset
  if (preset === 'never_watched') filters.neither_watched = true
  else if (preset === 'cancelled_watched') filters.cancelled_watched = true
  else if (preset === 'low_rated_unwatched') { filters.composite_max = 5.0; filters.neither_watched = true }
  fetchShows()
}

const clearFilters = () => {
  Object.assign(filters, { title: '', composite_min: null, composite_max: null,
    imdb_min: null, imdb_max: null, status: '', neither_watched: false,
    cancelled_watched: false, instance: '' })
  activePreset.value = ''
  fetchShows()
}

const toggleSortDir = () => { sortDir.value = sortDir.value === 'asc' ? 'desc' : 'asc'; fetchShows() }
const prevPage = () => { if (page.value > 1) { page.value--; fetchShows() } }
const nextPage = () => { if (page.value < pages.value) { page.value++; fetchShows() } }

const openDetail = async (s) => {
  try { const res = await axios.get(`/api/tv/${s.id}`); selectedItem.value = res.data }
  catch { selectedItem.value = s }
}

const startDelete = (item) => { deleteTarget.value = item }

const doDelete = async () => {
  if (!deleteTarget.value) return
  try {
    await axios.delete(`/api/tv/${deleteTarget.value.id}`, { data: { confirm: true } })
    selectedItem.value = null; deleteTarget.value = null; fetchShows()
  } catch { alert('Delete failed') }
}

const doUnmonitor = async (item) => {
  try { await axios.post(`/api/tv/${item.id}/unmonitor`); fetchShows() }
  catch { alert('Unmonitor failed') }
}

const statusClass = (s) => ({
  'Continuing': 'bg-green-900 text-green-300',
  'Ended': 'bg-slate-700 text-slate-300',
  'Cancelled': 'bg-red-900 text-red-300',
}[s] || 'bg-slate-700 text-slate-300')

const purgeScoreClass = (score) => {
  if (!score) return 'bg-green-900 text-green-300'
  if (score >= 75) return 'bg-red-900 text-red-300'
  if (score >= 55) return 'bg-orange-900 text-orange-300'
  if (score >= 30) return 'bg-yellow-900 text-yellow-300'
  return 'bg-green-900 text-green-300'
}

onMounted(fetchShows)
</script>
