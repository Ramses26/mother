<template>
  <!-- Slide-in panel -->
  <transition name="slide">
    <div v-if="item" class="fixed top-0 right-0 bottom-0 z-40 w-full max-w-xl overflow-y-auto border-l"
      style="background:#1a1d27; border-color:#2d3250;">
      <div class="p-6">
        <!-- Header -->
        <div class="flex items-start justify-between mb-4">
          <div>
            <h2 class="text-xl font-bold text-white">{{ item.title }}</h2>
            <div class="text-slate-400 text-sm mt-1">
              {{ item.year }}
              <span v-if="item.runtime_min"> · {{ item.runtime_min }} min</span>
              <span v-if="item.content_rating"> · {{ item.content_rating }}</span>
            </div>
          </div>
          <button @click="$emit('close')" class="text-slate-400 hover:text-white p-1 text-2xl leading-none">×</button>
        </div>

        <!-- Badges -->
        <div class="flex flex-wrap gap-2 mb-4">
          <span v-if="item.resolution" class="px-2 py-0.5 rounded text-xs font-medium bg-slate-700 text-slate-200">
            {{ item.resolution }}
          </span>
          <span v-if="item.hdr_format" class="px-2 py-0.5 rounded text-xs font-medium bg-purple-900 text-purple-300">
            {{ item.hdr_format }}
          </span>
          <span v-if="item.status" class="px-2 py-0.5 rounded text-xs font-medium"
            :class="statusClass(item.status)">
            {{ item.status }}
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
          </div>
        </div>

        <!-- Purge meter -->
        <div class="mb-4">
          <PurgeMeter :score="item.purge_score || 0"/>
        </div>

        <!-- Watch status -->
        <div class="mb-4">
          <h3 class="text-sm font-medium text-slate-400 mb-2">Watch Status</h3>
          <div class="grid grid-cols-2 gap-3">
            <div class="p-3 rounded-lg" style="background:#0f1117;">
              <div class="text-xs text-slate-500 mb-1">Ali</div>
              <div class="text-white font-medium">{{ item.ali_play_count || 0 }} plays</div>
              <div v-if="item.ali_last_watched" class="text-xs text-slate-500 mt-0.5">
                Last: {{ fmtDate(item.ali_last_watched) }}
              </div>
            </div>
            <div class="p-3 rounded-lg" style="background:#0f1117;">
              <div class="text-xs text-slate-500 mb-1">Chris</div>
              <div class="text-white font-medium">{{ item.chris_play_count || 0 }} plays</div>
              <div v-if="item.chris_last_watched" class="text-xs text-slate-500 mt-0.5">
                Last: {{ fmtDate(item.chris_last_watched) }}
              </div>
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

        <!-- Actions -->
        <div class="flex gap-3 pt-4 border-t" style="border-color:#2d3250;">
          <button @click="$emit('unmonitor', item)" class="flex-1 btn-secondary text-sm">
            Unmonitor
          </button>
          <button @click="$emit('delete', item)" class="flex-1 btn-danger text-sm">
            Delete
          </button>
        </div>

        <!-- External links -->
        <div class="mt-3 flex gap-2 text-xs">
          <a v-if="item.radarr_id" :href="radarrUrl" target="_blank"
            class="text-slate-500 hover:text-slate-300 transition-colors">Open in Radarr</a>
          <a v-if="item.sonarr_id" :href="sonarrUrl" target="_blank"
            class="text-slate-500 hover:text-slate-300 transition-colors">Open in Sonarr</a>
          <a v-if="item.imdb_id" :href="`https://www.imdb.com/title/${item.imdb_id}`" target="_blank"
            class="text-slate-500 hover:text-slate-300 transition-colors">IMDb</a>
        </div>
      </div>
    </div>
  </transition>
</template>

<script setup>
import { computed } from 'vue'
import RatingBadge from './RatingBadge.vue'
import PurgeMeter from './PurgeMeter.vue'

const props = defineProps({ item: Object })
defineEmits(['close', 'delete', 'unmonitor'])

const statusClass = (status) => ({
  'Continuing': 'bg-green-900 text-green-300',
  'Ended': 'bg-slate-700 text-slate-300',
  'Cancelled': 'bg-red-900 text-red-300',
}[status] || 'bg-slate-700 text-slate-300')

const formatSize = (bytes) => {
  const gb = bytes / 1_073_741_824
  return gb >= 1 ? `${gb.toFixed(1)} GB` : `${(bytes / 1_048_576).toFixed(0)} MB`
}

const fmtDate = (d) => d ? new Date(d).toLocaleDateString() : ''

const radarrUrl = computed(() => {
  if (!props.item?.radarr_id) return '#'
  const port = props.item.radarr_instance === 'radarr-4k' ? 7879 : 7878
  return `http://localhost:${port}/movie/${props.item.radarr_id}`
})

const sonarrUrl = computed(() => {
  if (!props.item?.sonarr_id) return '#'
  const port = props.item.sonarr_instance === 'sonarr-4k' ? 8990 : 8989
  return `http://localhost:${port}/series/${props.item.sonarr_id}`
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
