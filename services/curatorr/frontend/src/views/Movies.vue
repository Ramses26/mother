<template>
  <div class="flex h-screen-minus-nav" style="height:calc(100vh - 56px);">
    <!-- Filter Sidebar -->
    <div class="w-72 border-r overflow-y-auto flex-shrink-0" style="background:#1a1d27; border-color:#2d3250;">
      <div class="p-4">
        <h2 class="text-sm font-semibold text-slate-300 uppercase tracking-wider mb-3">Filters</h2>

        <!-- Presets — clicking active preset clears all filters -->
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
        <FilterSlider label="Composite Score" :min="0" :max="10" :step="0.5"
          v-model:from="filters.composite_min" v-model:to="filters.composite_max"
          @change="fetchMovies"/>

        <!-- IMDb -->
        <FilterSlider label="IMDb Rating" :min="0" :max="10" :step="0.5"
          v-model:from="filters.imdb_min" v-model:to="filters.imdb_max"
          @change="fetchMovies"/>

        <!-- RT -->
        <FilterSlider label="Rotten Tomatoes" :min="0" :max="100" :step="5"
          v-model:from="filters.rt_min" v-model:to="filters.rt_max"
          @change="fetchMovies" suffix="%"/>

        <!-- Metacritic -->
        <FilterSlider label="Metacritic" :min="0" :max="100" :step="5"
          v-model:from="filters.metacritic_min" v-model:to="filters.metacritic_max"
          @change="fetchMovies"/>

        <!-- MDBList -->
        <FilterSlider label="MDBList" :min="0" :max="100" :step="5"
          v-model:from="filters.mdblist_min" v-model:to="filters.mdblist_max"
          @change="fetchMovies"/>

        <!-- Watch Status -->
        <div class="mb-3">
          <label class="label">Watch Status</label>
          <div class="space-y-1 text-sm">
            <label class="flex items-center gap-2 cursor-pointer">
              <input type="checkbox" v-model="filters.neither_watched" @change="fetchMovies"
                class="rounded border-slate-600 text-violet-600"/>
              <span class="text-slate-300">Neither watched</span>
            </label>
            <label class="flex items-center gap-2 cursor-pointer">
              <input type="checkbox" v-model="filters.both_watched" @change="fetchMovies"
                class="rounded border-slate-600 text-violet-600"/>
              <span class="text-slate-300">Both watched</span>
            </label>
            <div class="flex gap-2 items-center">
              <span class="text-slate-500 w-10">Ali</span>
              <select v-model="filters.ali_watched" @change="fetchMovies" class="input text-xs py-1 flex-1">
                <option value="">Any</option>
                <option value="true">Watched</option>
                <option value="false">Unwatched</option>
              </select>
            </div>
            <div class="flex gap-2 items-center">
              <span class="text-slate-500 w-10">Chris</span>
              <select v-model="filters.chris_watched" @change="fetchMovies" class="input text-xs py-1 flex-1">
                <option value="">Any</option>
                <option value="true">Watched</option>
                <option value="false">Unwatched</option>
              </select>
            </div>
          </div>
        </div>

        <!-- Resolution -->
        <div class="mb-3">
          <label class="label">Resolution</label>
          <div class="flex flex-wrap gap-1">
            <button v-for="r in resolutions" :key="r"
              @click="toggleRes(r)"
              class="text-xs px-2 py-1 rounded transition-colors"
              :class="filters.resolutions.includes(r) ? 'bg-violet-600 text-white' : 'bg-surface-200 text-slate-400 hover:text-white'">
              {{ r }}
            </button>
          </div>
        </div>

        <!-- File Size -->
        <FilterSlider label="File Size (GB)" :min="0" :max="100" :step="1"
          v-model:from="filters.file_size_min_gb" v-model:to="filters.file_size_max_gb"
          @change="fetchMovies" suffix=" GB"/>

        <!-- Year -->
        <FilterSlider label="Year" :min="1920" :max="2026" :step="1"
          v-model:from="filters.year_min" v-model:to="filters.year_max"
          @change="fetchMovies" :show-value="true"/>

        <!-- Monitored -->
        <div class="mb-3">
          <label class="label">Monitored</label>
          <select v-model="filters.monitored" @change="fetchMovies" class="input text-sm">
            <option value="">All</option>
            <option value="true">Yes</option>
            <option value="false">No</option>
          </select>
        </div>

        <!-- Instance -->
        <div class="mb-3">
          <label class="label">Instance</label>
          <select v-model="filters.instance" @change="fetchMovies" class="input text-sm">
            <option value="">All</option>
            <option value="radarr-hd">Radarr HD</option>
            <option value="radarr-4k">Radarr 4K</option>
          </select>
        </div>

        <button @click="clearFilters" class="w-full btn-secondary text-sm mt-2">Clear Filters</button>
      </div>
    </div>

    <!-- Main content -->
    <div class="flex-1 overflow-y-auto">
      <!-- Toolbar -->
      <div class="sticky top-0 z-20 flex items-center gap-3 px-4 py-2 border-b" style="background:#0f1117; border-color:#2d3250;">
        <span class="text-sm text-slate-400">{{ total.toLocaleString() }} movies</span>
        <div class="flex-1"/>

        <!-- Sort: primary -->
        <select :value="sortBy" @change="sortBy = $event.target.value; fetchMovies()" class="input text-xs py-1 w-28">
          <option v-for="o in movieSortOptions" :key="o.value" :value="o.value">{{ o.label }}</option>
        </select>
        <button @click="toggleSortDir" class="text-slate-400 hover:text-white px-1 text-sm">
          {{ sortDir === 'asc' ? '↑' : '↓' }}
        </button>
        <!-- Sort: secondary -->
        <select :value="sortBy2" @change="sortBy2 = $event.target.value; if (!sortBy2) { sortBy3 = ''; sortDir3 = 'asc' } fetchMovies()" class="input text-xs py-1 w-24">
          <option value="">2nd…</option>
          <option v-for="o in movieSortOptions" :key="o.value" :value="o.value">{{ o.label }}</option>
        </select>
        <button v-if="sortBy2" @click="toggleSortDir2" class="text-slate-400 hover:text-white px-1 text-sm">
          {{ sortDir2 === 'asc' ? '↑' : '↓' }}
        </button>
        <!-- Sort: tertiary (visible only when secondary is set) -->
        <template v-if="sortBy2">
          <select :value="sortBy3" @change="sortBy3 = $event.target.value; fetchMovies()" class="input text-xs py-1 w-24">
            <option value="">3rd…</option>
            <option v-for="o in movieSortOptions" :key="o.value" :value="o.value">{{ o.label }}</option>
          </select>
          <button v-if="sortBy3" @click="toggleSortDir3" class="text-slate-400 hover:text-white px-1 text-sm">
            {{ sortDir3 === 'asc' ? '↑' : '↓' }}
          </button>
        </template>

        <!-- Column visibility (table mode only) -->
        <div v-if="viewMode === 'table'" class="relative">
          <button @click="showColMenu = !showColMenu"
            class="p-1.5 rounded text-slate-400 hover:text-white hover:bg-slate-700 transition-colors"
            title="Column visibility">⚙</button>
          <div v-if="showColMenu" class="absolute right-0 top-full mt-1 z-50 rounded-lg border shadow-xl p-3 w-44"
            style="background:#1a1d27; border-color:#2d3250;">
            <div class="text-xs text-slate-400 font-semibold mb-2 uppercase tracking-wider">Columns</div>
            <label v-for="col in optionalCols" :key="col.key" class="flex items-center gap-2 cursor-pointer py-1">
              <input type="checkbox" v-model="visibleCols[col.key]" @change="saveColPrefs"
                class="rounded border-slate-600 text-violet-600"/>
              <span class="text-sm text-slate-300">{{ col.label }}</span>
            </label>
          </div>
        </div>

        <!-- View toggle -->
        <div class="flex gap-1">
          <button v-for="v in views" :key="v.value" @click="viewMode = v.value"
            class="p-1.5 rounded transition-colors"
            :class="viewMode === v.value ? 'bg-violet-600 text-white' : 'text-slate-400 hover:text-white'">
            <span class="text-sm">{{ v.icon }}</span>
          </button>
        </div>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="flex items-center justify-center py-20">
        <div class="animate-spin h-8 w-8 border-2 border-violet-500/30 border-t-violet-500 rounded-full"></div>
      </div>

      <!-- Poster Grid -->
      <div v-else-if="viewMode === 'poster'" class="grid gap-3 p-4"
        style="grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));">
        <div v-for="m in movies" :key="m.id"
          class="relative rounded-lg overflow-hidden cursor-pointer group transition-transform hover:scale-105"
          :style="{ borderLeft: `3px solid ${purgeColor(m.purge_score)}` }"
          @click="openDetail(m)">
          <!-- Poster -->
          <div class="aspect-[2/3] relative" style="background:#1a1d27;">
            <img v-if="m.poster_url || m.plex_key"
              :src="m.poster_url || `/api/poster?url=/library/metadata/${m.plex_key}/thumb&server=chris`"
              class="w-full h-full object-cover" loading="lazy" @error="e => e.target.style.display='none'"/>
            <div class="absolute inset-0 flex items-center justify-center text-slate-600 text-xs"
              v-if="!m.poster_url && !m.plex_key">No poster</div>
            <!-- Quality badge -->
            <div class="absolute top-1 right-1 px-1.5 py-0.5 rounded text-xs font-medium bg-black/70 text-white">
              {{ m.resolution || '?' }}
            </div>
            <!-- Hover overlay -->
            <div class="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity flex flex-col justify-end"
              style="background:linear-gradient(transparent 30%, rgba(0,0,0,0.9) 100%);">
              <div class="p-2">
                <!-- Watch badges -->
                <div class="flex gap-1 justify-center mb-1">
                  <span class="text-xs px-1 py-0.5 rounded"
                    :class="m.ali_play_count > 0 ? 'bg-green-800 text-green-300' : 'bg-slate-700 text-slate-500'">
                    Ali{{ m.ali_play_count > 0 ? '✓' : '✗' }}
                  </span>
                  <span class="text-xs px-1 py-0.5 rounded"
                    :class="m.chris_play_count > 0 ? 'bg-green-800 text-green-300' : 'bg-slate-700 text-slate-500'">
                    Chris{{ m.chris_play_count > 0 ? '✓' : '✗' }}
                  </span>
                </div>
                <!-- Ratings row -->
                <div v-if="m.imdb_rating || m.rt_critics" class="flex gap-1 justify-center text-xs text-slate-300 mb-1">
                  <span v-if="m.imdb_rating">⭐{{ m.imdb_rating }}</span>
                  <span v-if="m.rt_critics">🍅{{ m.rt_critics }}%</span>
                </div>
              </div>
            </div>
          </div>
          <!-- Title -->
          <div class="p-2 text-xs text-slate-300 truncate" style="background:#1a1d27;">
            {{ m.title }}
          </div>
        </div>
      </div>

      <!-- Table view -->
      <div v-else class="p-4" @click.self="showColMenu = false">
        <table class="w-full text-sm">
          <thead>
            <tr class="text-left text-slate-500 border-b" style="border-color:#2d3250;">
              <th class="py-2 pr-4 font-medium">Title</th>
              <th v-if="visibleCols.year" class="py-2 pr-4 font-medium">Year</th>
              <th class="py-2 pr-4 font-medium">Rating</th>
              <th v-if="visibleCols.imdb" class="py-2 pr-4 font-medium">IMDb</th>
              <th v-if="visibleCols.rt" class="py-2 pr-4 font-medium">RT</th>
              <th v-if="visibleCols.metacritic" class="py-2 pr-4 font-medium">MC</th>
              <th v-if="visibleCols.mdblist" class="py-2 pr-4 font-medium">MDB</th>
              <th v-if="visibleCols.resolution" class="py-2 pr-4 font-medium">Res</th>
              <th v-if="visibleCols.hdr" class="py-2 pr-4 font-medium">HDR</th>
              <th v-if="visibleCols.codec" class="py-2 pr-4 font-medium">Codec</th>
              <th v-if="visibleCols.audio" class="py-2 pr-4 font-medium">Audio</th>
              <th v-if="visibleCols.size" class="py-2 pr-4 font-medium">Size</th>
              <th v-if="visibleCols.watched" class="py-2 pr-4 font-medium">Watched</th>
              <th v-if="visibleCols.both" class="py-2 pr-4 font-medium">Both</th>
              <th v-if="visibleCols.added" class="py-2 pr-4 font-medium">Added</th>
              <th class="py-2 font-medium">Purge</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="m in movies" :key="m.id"
              class="border-b hover:bg-surface-100 cursor-pointer transition-colors"
              style="border-color:#1a1d27;"
              @click="openDetail(m)">
              <td class="py-2 pr-4">
                <div class="text-white font-medium truncate max-w-xs">{{ m.title }}</div>
                <div class="text-xs text-slate-500">{{ m.radarr_instance }}</div>
              </td>
              <td v-if="visibleCols.year" class="py-2 pr-4 text-slate-400">{{ m.year }}</td>
              <td class="py-2 pr-4">
                <span v-if="m.composite_score" class="text-violet-400 font-medium">{{ m.composite_score.toFixed(1) }}</span>
                <span v-else class="text-slate-600">—</span>
              </td>
              <td v-if="visibleCols.imdb" class="py-2 pr-4 text-slate-400 text-xs">{{ m.imdb_rating || '—' }}</td>
              <td v-if="visibleCols.rt" class="py-2 pr-4 text-slate-400 text-xs">{{ m.rt_critics != null ? m.rt_critics + '%' : '—' }}</td>
              <td v-if="visibleCols.metacritic" class="py-2 pr-4 text-slate-400 text-xs">{{ m.metacritic || '—' }}</td>
              <td v-if="visibleCols.mdblist" class="py-2 pr-4 text-slate-400 text-xs">{{ m.mdblist_score || '—' }}</td>
              <td v-if="visibleCols.resolution" class="py-2 pr-4">
                <span class="px-1.5 py-0.5 rounded text-xs font-medium bg-slate-700 text-slate-200">
                  {{ m.resolution || '?' }}
                </span>
              </td>
              <td v-if="visibleCols.hdr" class="py-2 pr-4 text-xs text-purple-400">{{ m.hdr_format || '—' }}</td>
              <td v-if="visibleCols.codec" class="py-2 pr-4 text-xs text-slate-400">{{ m.video_codec || '—' }}</td>
              <td v-if="visibleCols.audio" class="py-2 pr-4 text-xs text-slate-400">
                {{ m.audio_codec ? (m.audio_channels ? `${m.audio_codec} ${m.audio_channels}` : m.audio_codec) : '—' }}
              </td>
              <td v-if="visibleCols.size" class="py-2 pr-4 text-slate-400 text-xs">{{ formatSize(m.file_size_bytes) }}</td>
              <td v-if="visibleCols.watched" class="py-2 pr-4 text-xs">
                <span :class="m.ali_play_count > 0 ? 'text-green-400' : 'text-slate-600'">A</span>
                <span :class="m.chris_play_count > 0 ? 'text-green-400' : 'text-slate-600'"> C</span>
              </td>
              <td v-if="visibleCols.both" class="py-2 pr-4 text-xs">
                <span v-if="m.ali_play_count > 0 && m.chris_play_count > 0" class="text-green-400">✓</span>
                <span v-else-if="m.ali_play_count > 0" class="text-blue-400">Ali</span>
                <span v-else-if="m.chris_play_count > 0" class="text-purple-400">Chris</span>
                <span v-else class="text-slate-600">—</span>
              </td>
              <td v-if="visibleCols.added" class="py-2 pr-4 text-slate-500 text-xs">
                {{ m.radarr_added_at ? new Date(m.radarr_added_at).toLocaleDateString() : '—' }}
              </td>
              <td class="py-2">
                <span class="px-1.5 py-0.5 rounded text-xs font-medium"
                  :class="purgeScoreClass(m.purge_score)">{{ m.purge_score || 0 }}</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      <div class="flex items-center justify-between px-4 py-3 border-t" style="border-color:#2d3250;">
        <button @click="prevPage" :disabled="page === 1" class="btn-secondary text-sm px-3 py-1.5 disabled:opacity-40">
          Previous
        </button>
        <span class="text-slate-400 text-sm">Page {{ page }} of {{ pages }}</span>
        <button @click="nextPage" :disabled="page >= pages" class="btn-secondary text-sm px-3 py-1.5 disabled:opacity-40">
          Next
        </button>
      </div>
    </div>

    <!-- Detail panel -->
    <MediaDetail :item="selectedItem" @close="selectedItem = null"
      @delete="startDelete" @unmonitor="doUnmonitor"/>

    <!-- Delete confirm -->
    <DeleteConfirm :show="!!deleteTarget" :item="deleteTarget"
      @confirm="doDelete" @cancel="deleteTarget = null"/>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onBeforeUnmount } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import axios from 'axios'
import MediaDetail from '../components/MediaDetail.vue'
import DeleteConfirm from '../components/DeleteConfirm.vue'

const route = useRoute()
const router = useRouter()

const movies = ref([])
const total = ref(0)
const page = ref(1)
const pages = ref(1)
const loading = ref(false)
const selectedItem = ref(null)
const deleteTarget = ref(null)
const viewMode = ref('poster')
const sortBy = ref('sort_title')
const sortDir = ref('asc')
const sortBy2 = ref('')
const sortDir2 = ref('asc')
const sortBy3 = ref('')
const sortDir3 = ref('asc')
const activePreset = ref('')
const showColMenu = ref(false)
let fetchTimer = null

const views = [
  { value: 'poster', icon: '⊞' },
  { value: 'table', icon: '☰' },
]

const movieSortOptions = [
  { value: 'sort_title', label: 'Title' },
  { value: 'year', label: 'Year' },
  { value: 'composite_score', label: 'Composite' },
  { value: 'imdb_rating', label: 'IMDb' },
  { value: 'rt_critics', label: 'RT%' },
  { value: 'metacritic', label: 'Metacritic' },
  { value: 'mdblist_score', label: 'MDBList' },
  { value: 'purge_score', label: 'Purge Score' },
  { value: 'file_size_bytes', label: 'File Size' },
  { value: 'plex_added_at', label: 'Date Added' },
  { value: 'ali_play_count', label: 'Ali Plays' },
  { value: 'chris_play_count', label: 'Chris Plays' },
]


const resolutions = ['4K', '1080p', '720p', 'SD']
const presets = [
  { value: 'never_watched', label: 'Never Watched' },
  { value: 'purge_candidates', label: 'Purge Candidates' },
  { value: 'hidden_gems', label: 'Hidden Gems' },
  { value: 'low_rated_unwatched', label: 'Low Rated Unwatched' },
  { value: 'large_files', label: 'Large Files' },
]

const optionalCols = [
  { key: 'year', label: 'Year' },
  { key: 'imdb', label: 'IMDb' },
  { key: 'rt', label: 'RT Critics' },
  { key: 'metacritic', label: 'Metacritic' },
  { key: 'mdblist', label: 'MDBList' },
  { key: 'resolution', label: 'Resolution' },
  { key: 'hdr', label: 'HDR' },
  { key: 'codec', label: 'Codec' },
  { key: 'audio', label: 'Audio' },
  { key: 'size', label: 'File Size' },
  { key: 'watched', label: 'Watched' },
  { key: 'both', label: 'Both' },
  { key: 'added', label: 'Date Added' },
]

const COL_STORAGE_KEY = 'curatorr_movies_cols'
const defaultCols = { year: true, imdb: false, rt: false, metacritic: false, mdblist: false,
  resolution: true, hdr: false, codec: false, audio: false, size: true, watched: true, both: false, added: false }

const visibleCols = reactive({ ...defaultCols })

const loadColPrefs = () => {
  try {
    const saved = JSON.parse(localStorage.getItem(COL_STORAGE_KEY) || '{}')
    Object.assign(visibleCols, defaultCols, saved)
  } catch {}
}

const saveColPrefs = () => {
  localStorage.setItem(COL_STORAGE_KEY, JSON.stringify({ ...visibleCols }))
}

const filters = reactive({
  title: '',
  composite_min: null, composite_max: null,
  imdb_min: null, imdb_max: null,
  rt_min: null, rt_max: null,
  metacritic_min: null, metacritic_max: null,
  mdblist_min: null, mdblist_max: null,
  purge_score_min: null, purge_score_max: null,
  file_size_min_gb: null, file_size_max_gb: null,
  year_min: null, year_max: null,
  monitored: '',
  ali_watched: '', chris_watched: '',
  neither_watched: false, both_watched: false,
  resolutions: [],
  instance: '',
})

const buildParams = () => {
  const p = { page: page.value, per_page: 50, sort_by: sortBy.value, sort_dir: sortDir.value }
  if (sortBy2.value) { p.sort_by2 = sortBy2.value; p.sort_dir2 = sortDir2.value }
  if (sortBy2.value && sortBy3.value) { p.sort_by3 = sortBy3.value; p.sort_dir3 = sortDir3.value }
  if (filters.title) p.title = filters.title
  if (filters.composite_min != null) p.composite_min = filters.composite_min
  if (filters.composite_max != null) p.composite_max = filters.composite_max
  if (filters.imdb_min != null) p.imdb_min = filters.imdb_min
  if (filters.imdb_max != null) p.imdb_max = filters.imdb_max
  if (filters.rt_min != null) p.rt_min = filters.rt_min
  if (filters.rt_max != null) p.rt_max = filters.rt_max
  if (filters.metacritic_min != null) p.metacritic_min = filters.metacritic_min
  if (filters.metacritic_max != null) p.metacritic_max = filters.metacritic_max
  if (filters.mdblist_min != null) p.mdblist_min = filters.mdblist_min
  if (filters.mdblist_max != null) p.mdblist_max = filters.mdblist_max
  if (filters.purge_score_min != null) p.purge_score_min = filters.purge_score_min
  if (filters.purge_score_max != null) p.purge_score_max = filters.purge_score_max
  if (filters.file_size_min_gb != null) p.file_size_min_gb = filters.file_size_min_gb
  if (filters.file_size_max_gb != null) p.file_size_max_gb = filters.file_size_max_gb
  if (filters.year_min != null) p.year_min = filters.year_min
  if (filters.year_max != null) p.year_max = filters.year_max
  if (filters.monitored) p.monitored = filters.monitored
  if (filters.ali_watched) p.ali_watched = filters.ali_watched
  if (filters.chris_watched) p.chris_watched = filters.chris_watched
  if (filters.neither_watched) p.neither_watched = 'true'
  if (filters.both_watched) p.both_watched = 'true'
  if (filters.resolutions.length) p.resolution = filters.resolutions.join(',')
  if (filters.instance) p.instance = filters.instance
  return p
}

const fetchMovies = async () => {
  loading.value = true
  try {
    const res = await axios.get('/api/movies', { params: buildParams() })
    movies.value = res.data.items
    total.value = res.data.total
    pages.value = res.data.pages
  } catch {
    // ignore
  } finally {
    loading.value = false
  }
}

const debouncedFetch = () => {
  clearTimeout(fetchTimer)
  fetchTimer = setTimeout(fetchMovies, 400)
}

const applyPreset = (preset) => {
  // Clicking the active preset toggles it off (clears filters)
  if (activePreset.value === preset) {
    clearFilters()
    return
  }
  clearFilters()
  activePreset.value = preset
  if (preset === 'never_watched') filters.neither_watched = true
  else if (preset === 'purge_candidates') filters.purge_score_min = 70
  else if (preset === 'hidden_gems') { filters.composite_min = 7.5; filters.neither_watched = true }
  else if (preset === 'low_rated_unwatched') { filters.composite_max = 5.0; filters.neither_watched = true }
  else if (preset === 'large_files') { sortBy.value = 'file_size_bytes'; sortDir.value = 'desc' }
  fetchMovies()
}

const clearFilters = () => {
  Object.assign(filters, {
    title: '', composite_min: null, composite_max: null,
    imdb_min: null, imdb_max: null, rt_min: null, rt_max: null,
    metacritic_min: null, metacritic_max: null, mdblist_min: null, mdblist_max: null,
    purge_score_min: null, purge_score_max: null, file_size_min_gb: null, file_size_max_gb: null,
    year_min: null, year_max: null, monitored: '', ali_watched: '', chris_watched: '',
    neither_watched: false, both_watched: false, resolutions: [], instance: '',
  })
  activePreset.value = ''
  sortBy.value = 'sort_title'
  sortDir.value = 'asc'
  sortBy2.value = ''
  sortDir2.value = 'asc'
  sortBy3.value = ''
  sortDir3.value = 'asc'
  page.value = 1
  fetchMovies()
}

const toggleRes = (r) => {
  const idx = filters.resolutions.indexOf(r)
  if (idx >= 0) filters.resolutions.splice(idx, 1)
  else filters.resolutions.push(r)
  fetchMovies()
}

const toggleSortDir = () => {
  sortDir.value = sortDir.value === 'asc' ? 'desc' : 'asc'
  fetchMovies()
}

const toggleSortDir2 = () => {
  sortDir2.value = sortDir2.value === 'asc' ? 'desc' : 'asc'
  fetchMovies()
}

const toggleSortDir3 = () => {
  sortDir3.value = sortDir3.value === 'asc' ? 'desc' : 'asc'
  fetchMovies()
}

const prevPage = () => { if (page.value > 1) { page.value--; fetchMovies() } }
const nextPage = () => { if (page.value < pages.value) { page.value++; fetchMovies() } }

const openDetail = async (m) => {
  try {
    const res = await axios.get(`/api/movies/${m.id}`)
    selectedItem.value = res.data
  } catch {
    selectedItem.value = m
  }
}

const startDelete = (item) => { deleteTarget.value = item }

const doDelete = async () => {
  if (!deleteTarget.value) return
  try {
    await axios.delete(`/api/movies/${deleteTarget.value.id}`, { data: { confirm: true } })
    selectedItem.value = null
    deleteTarget.value = null
    fetchMovies()
  } catch {
    alert('Delete failed')
  }
}

const doUnmonitor = async (item) => {
  try {
    await axios.post(`/api/movies/${item.id}/unmonitor`)
    if (selectedItem.value?.id === item.id) selectedItem.value.monitored = 0
    fetchMovies()
  } catch {
    alert('Unmonitor failed')
  }
}

const purgeColor = (score) => {
  if (!score) return '#22c55e'
  if (score >= 75) return '#ef4444'
  if (score >= 55) return '#f97316'
  if (score >= 30) return '#eab308'
  return '#22c55e'
}

const purgeScoreClass = (score) => {
  if (!score) return 'bg-green-900 text-green-300'
  if (score >= 75) return 'bg-red-900 text-red-300'
  if (score >= 55) return 'bg-orange-900 text-orange-300'
  if (score >= 30) return 'bg-yellow-900 text-yellow-300'
  return 'bg-green-900 text-green-300'
}

const formatSize = (bytes) => {
  if (!bytes) return '—'
  const gb = bytes / 1_073_741_824
  return gb >= 1 ? `${gb.toFixed(1)} GB` : `${(bytes / 1_048_576).toFixed(0)} MB`
}

// Close col menu on outside click
const onDocClick = (e) => {
  if (!e.target.closest('.relative')) showColMenu.value = false
}

onMounted(async () => {
  loadColPrefs()
  const q = route.query
  if (q.composite_min) filters.composite_min = parseFloat(q.composite_min)
  if (q.composite_max) filters.composite_max = parseFloat(q.composite_max)
  if (q.purge_score_min) filters.purge_score_min = parseInt(q.purge_score_min)
  if (q.neither_watched) filters.neither_watched = true
  await fetchMovies()
  // Auto-open detail panel for a specific movie (e.g. from Dashboard purge candidates)
  if (q.open) {
    try {
      const res = await axios.get(`/api/movies/${q.open}`)
      selectedItem.value = res.data
    } catch {}
  }
  document.addEventListener('click', onDocClick)
})

onBeforeUnmount(() => {
  document.removeEventListener('click', onDocClick)
})
</script>

<!-- Inline FilterSlider component -->
<script>
const FilterSlider = {
  template: `
    <div class="mb-3">
      <label class="label">{{ label }}</label>
      <div class="flex gap-2">
        <input type="number" :min="min" :max="max" :step="step" :placeholder="min"
          :value="from" @input="$emit('update:from', $event.target.value ? Number($event.target.value) : null)"
          @change="$emit('change')"
          class="input text-xs py-1 w-1/2" />
        <input type="number" :min="min" :max="max" :step="step" :placeholder="max"
          :value="to" @input="$emit('update:to', $event.target.value ? Number($event.target.value) : null)"
          @change="$emit('change')"
          class="input text-xs py-1 w-1/2" />
      </div>
    </div>
  `,
  props: { label: String, min: Number, max: Number, step: Number, from: Number, to: Number, suffix: String },
  emits: ['update:from', 'update:to', 'change'],
}
export { FilterSlider }
</script>
