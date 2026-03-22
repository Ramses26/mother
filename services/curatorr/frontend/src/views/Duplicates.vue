<template>
  <div class="p-6 max-w-5xl mx-auto">
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold text-white">Duplicates</h1>
      <button @click="load" :disabled="loading" class="btn-secondary text-sm">Refresh</button>
    </div>

    <!-- Tab toggle -->
    <div class="flex gap-2 mb-6">
      <button @click="tab = 'movies'" class="px-4 py-1.5 rounded text-sm transition-colors"
        :class="tab === 'movies' ? 'bg-violet-600 text-white' : 'bg-surface-200 text-slate-400 hover:text-white'">
        Movies
      </button>
      <button @click="tab = 'tv'" class="px-4 py-1.5 rounded text-sm transition-colors"
        :class="tab === 'tv' ? 'bg-violet-600 text-white' : 'bg-surface-200 text-slate-400 hover:text-white'">
        TV Shows
      </button>
    </div>

    <div v-if="loading" class="flex items-center justify-center py-20">
      <div class="animate-spin h-8 w-8 border-2 border-violet-500/30 border-t-violet-500 rounded-full"></div>
    </div>

    <!-- Movies tab -->
    <template v-else-if="tab === 'movies'">
      <div v-if="duplicates.length === 0" class="text-center py-20 text-slate-500">
        No movie duplicates found
      </div>
      <div v-else class="space-y-4">
        <div v-for="dup in duplicates" :key="dup.tmdb_id" class="card">
          <h3 class="font-semibold text-white mb-3">{{ dup.title }} ({{ dup.year }})</h3>
          <div class="grid gap-3" :style="{ gridTemplateColumns: `repeat(${dup.versions.length}, 1fr)` }">
            <div v-for="v in dup.versions" :key="v.id"
              class="p-3 rounded-lg border"
              :class="v.id === dup.recommended_keep_id
                ? 'border-green-600 bg-green-900/20'
                : 'border-surface-300 bg-surface-100'">
              <div class="text-xs text-slate-400 mb-2">
                <span v-if="v.id === dup.recommended_keep_id" class="text-green-400 font-medium">✓ Keep</span>
                <span v-else class="text-red-400 font-medium">Delete candidate</span>
              </div>
              <div class="space-y-1 text-sm">
                <div class="flex justify-between">
                  <span class="text-slate-500">Resolution</span>
                  <span class="text-slate-200">{{ v.resolution }}</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-slate-500">Codec</span>
                  <span class="text-slate-200">{{ v.video_codec || '?' }}</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-slate-500">Size</span>
                  <span class="text-slate-200">{{ formatSize(v.file_size_bytes) }}</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-slate-500">TRaSH Score</span>
                  <span class="text-slate-200">{{ v.trash_score || '—' }}</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-slate-500">Instance</span>
                  <span class="text-slate-200 text-xs">{{ v.radarr_instance }}</span>
                </div>
              </div>
              <button v-if="v.id !== dup.recommended_keep_id"
                @click="deleteVersion(v)"
                class="mt-3 w-full btn-danger text-xs py-1.5">
                Delete This Copy
              </button>
            </div>
          </div>
        </div>
      </div>
    </template>

    <!-- TV tab -->
    <template v-else>
      <div v-if="tvDuplicates.length === 0" class="text-center py-20 text-slate-500">
        No TV duplicates found
      </div>
      <div v-else class="space-y-4">
        <p class="text-xs text-slate-500 mb-2">Shows present in multiple Sonarr instances. No auto-delete — manage manually in Sonarr.</p>
        <div v-for="dup in tvDuplicates" :key="dup.tmdb_id" class="card">
          <h3 class="font-semibold text-white mb-3">{{ dup.title }} ({{ dup.year }})</h3>
          <div class="grid gap-3" :style="{ gridTemplateColumns: `repeat(${dup.versions.length}, 1fr)` }">
            <div v-for="v in dup.versions" :key="v.id"
              class="p-3 rounded-lg border"
              :class="v.id === dup.recommended_keep_id
                ? 'border-green-600 bg-green-900/20'
                : 'border-surface-300 bg-surface-100'">
              <div class="text-xs mb-2">
                <span v-if="v.id === dup.recommended_keep_id" class="text-green-400 font-medium">✓ Most episodes</span>
                <span v-else class="text-slate-500 font-medium">Other copy</span>
              </div>
              <div class="space-y-1 text-sm">
                <div class="flex justify-between">
                  <span class="text-slate-500">Instance</span>
                  <span class="text-slate-200 text-xs">{{ v.sonarr_instance }}</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-slate-500">Seasons</span>
                  <span class="text-slate-200">{{ v.total_seasons ?? '—' }}</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-slate-500">Episodes</span>
                  <span class="text-slate-200">{{ v.total_episodes ?? '—' }}</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-slate-500">Rating</span>
                  <span class="text-violet-400">{{ v.composite_score?.toFixed(1) || '—' }}</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-slate-500">Monitored</span>
                  <span :class="v.monitored ? 'text-green-400' : 'text-slate-500'">{{ v.monitored ? 'Yes' : 'No' }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </template>

    <DeleteConfirm :show="!!deleteTarget" :item="deleteTarget"
      @confirm="confirmDelete" @cancel="deleteTarget = null"/>
  </div>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue'
import axios from 'axios'
import DeleteConfirm from '../components/DeleteConfirm.vue'

const tab = ref('movies')
const duplicates = ref([])
const tvDuplicates = ref([])
const loading = ref(false)
const deleteTarget = ref(null)

const load = async () => {
  loading.value = true
  try {
    if (tab.value === 'movies') {
      const res = await axios.get('/api/duplicates')
      duplicates.value = res.data
    } else {
      const res = await axios.get('/api/duplicates/tv')
      tvDuplicates.value = res.data
    }
  } catch {} finally { loading.value = false }
}

watch(tab, load)

const formatSize = (bytes) => {
  if (!bytes) return '—'
  const gb = bytes / 1_073_741_824
  return gb >= 1 ? `${gb.toFixed(1)} GB` : `${(bytes / 1_048_576).toFixed(0)} MB`
}

const deleteVersion = (v) => { deleteTarget.value = v }

const confirmDelete = async () => {
  if (!deleteTarget.value) return
  try {
    await axios.delete(`/api/movies/${deleteTarget.value.id}`, { data: { confirm: true } })
    deleteTarget.value = null
    await load()
  } catch { alert('Delete failed') }
}

onMounted(load)
</script>
