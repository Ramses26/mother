<template>
  <div class="p-6 max-w-7xl mx-auto">
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold text-white">Activity Log</h1>
      <button @click="load" class="btn-secondary text-sm">Refresh</button>
    </div>

    <!-- Filters -->
    <div class="flex gap-3 mb-4 flex-wrap">
      <select v-model="filterType" @change="load" class="input text-sm py-1 w-36">
        <option value="">All Types</option>
        <option value="sync">Sync</option>
        <option value="ratings">Ratings</option>
        <option value="deletion">Deletion</option>
        <option value="rule">Rules</option>
        <option value="backup">Backup</option>
        <option value="error">Error</option>
      </select>
      <select v-model="filterLevel" @change="load" class="input text-sm py-1 w-32">
        <option value="">All Levels</option>
        <option value="info">Info</option>
        <option value="warning">Warning</option>
        <option value="error">Error</option>
      </select>
      <input v-model="filterSource" @input="debouncedLoad" class="input text-sm py-1 w-40" placeholder="Source..."/>
    </div>

    <div v-if="loading" class="flex items-center justify-center py-20">
      <div class="animate-spin h-8 w-8 border-2 border-violet-500/30 border-t-violet-500 rounded-full"></div>
    </div>

    <div v-else-if="!items.length" class="text-center py-20 text-slate-500">
      <div class="text-4xl mb-3">📋</div>
      <div>No log entries yet.</div>
      <div class="text-sm mt-2">Events will appear here as sync, ratings refresh, and deletion actions run.</div>
    </div>

    <div v-else>
      <table class="w-full text-sm">
        <thead>
          <tr class="text-left text-slate-500 border-b" style="border-color:#2d3250;">
            <th class="py-2 pr-4 font-medium w-36">Time</th>
            <th class="py-2 pr-4 font-medium w-24">Type</th>
            <th class="py-2 pr-4 font-medium w-28">Source</th>
            <th class="py-2 pr-4 font-medium">Message</th>
            <th class="py-2 font-medium w-20">Level</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in items" :key="row.id"
            class="border-b transition-colors"
            :class="row.level === 'error' ? 'bg-red-950/20' : 'hover:bg-surface-100'"
            style="border-color:#1a1d27;">
            <td class="py-2 pr-4 text-slate-500 text-xs font-mono whitespace-nowrap">
              {{ fmtDate(row.created_at) }}
            </td>
            <td class="py-2 pr-4">
              <span class="px-1.5 py-0.5 rounded text-xs font-medium"
                :class="typeClass(row.event_type)">{{ row.event_type }}</span>
            </td>
            <td class="py-2 pr-4 text-slate-400 text-xs">{{ row.source || '—' }}</td>
            <td class="py-2 pr-4 text-slate-300 text-xs">{{ row.message }}</td>
            <td class="py-2">
              <span class="text-xs" :class="levelClass(row.level)">{{ row.level }}</span>
            </td>
          </tr>
        </tbody>
      </table>

      <!-- Pagination -->
      <div class="flex items-center justify-between mt-4">
        <button @click="prevPage" :disabled="page === 1" class="btn-secondary text-sm px-3 py-1.5 disabled:opacity-40">Previous</button>
        <span class="text-slate-400 text-sm">Page {{ page }} of {{ pages }} ({{ total.toLocaleString() }} entries)</span>
        <button @click="nextPage" :disabled="page >= pages" class="btn-secondary text-sm px-3 py-1.5 disabled:opacity-40">Next</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'

const items = ref([])
const total = ref(0)
const page = ref(1)
const pages = ref(1)
const loading = ref(false)
const filterType = ref('')
const filterLevel = ref('')
const filterSource = ref('')
let debTimer = null

const load = async () => {
  loading.value = true
  try {
    const params = { page: page.value, per_page: 50 }
    if (filterType.value) params.type = filterType.value
    if (filterLevel.value) params.level = filterLevel.value
    if (filterSource.value) params.source = filterSource.value
    const res = await axios.get('/api/logs', { params })
    items.value = res.data.items
    total.value = res.data.total
    pages.value = res.data.pages
  } catch {} finally { loading.value = false }
}

const debouncedLoad = () => { clearTimeout(debTimer); debTimer = setTimeout(load, 400) }
const prevPage = () => { if (page.value > 1) { page.value--; load() } }
const nextPage = () => { if (page.value < pages.value) { page.value++; load() } }

const fmtDate = (d) => {
  if (!d) return '—'
  const dt = new Date(d)
  return dt.toLocaleDateString() + ' ' + dt.toLocaleTimeString()
}

const typeClass = (t) => ({
  sync: 'bg-blue-900 text-blue-300',
  ratings: 'bg-purple-900 text-purple-300',
  deletion: 'bg-red-900 text-red-300',
  rule: 'bg-yellow-900 text-yellow-300',
  backup: 'bg-green-900 text-green-300',
  error: 'bg-red-900 text-red-300',
}[t] || 'bg-slate-700 text-slate-300')

const levelClass = (l) => ({
  info: 'text-slate-400',
  warning: 'text-yellow-400',
  error: 'text-red-400',
}[l] || 'text-slate-400')

onMounted(load)
</script>
