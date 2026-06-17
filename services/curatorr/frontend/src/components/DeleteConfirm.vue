<template>
  <div v-if="show" class="fixed inset-0 z-50 flex items-center justify-center p-4"
    style="background:rgba(0,0,0,0.7);" @click.self="phase === 'confirm' && $emit('cancel')">
    <div class="w-full max-w-md rounded-xl border p-6" style="background:#1a1d27; border-color:#2d3250;">

      <!-- ── CONFIRM PHASE ── -->
      <template v-if="phase === 'confirm'">
        <h3 class="text-lg font-semibold text-white mb-4">Confirm Delete</h3>

        <div class="flex gap-3 mb-4 p-3 rounded-lg" style="background:#0f1117;">
          <div>
            <div class="font-medium text-white">
              {{ item?.title }} <span class="text-slate-400">({{ item?.year }})</span>
            </div>
            <div v-if="fileSize" class="text-sm text-slate-400 mt-1">Frees {{ fileSize }}</div>
          </div>
        </div>

        <div class="mb-4 p-3 rounded-lg bg-amber-900/20 border border-amber-700/50 text-amber-300 text-sm">
          <div>Ali watched: {{ item?.ali_play_count || 0 }} times</div>
          <div>Chris watched: {{ item?.chris_play_count || 0 }} times</div>
        </div>

        <div v-if="item?.imdb_rating > 7"
          class="mb-4 p-3 rounded-lg bg-yellow-900/20 border border-yellow-700/50 text-yellow-300 text-sm">
          High-rated content: IMDb {{ item.imdb_rating }}/10
        </div>

        <div v-if="requireTyping" class="mb-4">
          <label class="text-sm text-slate-400 block mb-1">Type the title to confirm:</label>
          <input v-model="confirmText" class="input" :placeholder="item?.title" @keydown.enter="confirm"/>
        </div>

        <div class="flex gap-3">
          <button @click="$emit('cancel')" class="flex-1 btn-secondary">Cancel</button>
          <button @click="confirm" :disabled="!canConfirm" class="flex-1 btn-danger">Delete</button>
        </div>
      </template>

      <!-- ── DELETING PHASE ── -->
      <template v-else-if="phase === 'deleting'">
        <h3 class="text-lg font-semibold text-white mb-6">Deleting…</h3>
        <div class="space-y-3">
          <div v-for="step in steps" :key="step.id" class="flex items-center gap-3">
            <!-- Spinner / check / cross -->
            <div class="w-5 h-5 shrink-0 flex items-center justify-center">
              <svg v-if="step.state === 'waiting'" class="animate-spin text-slate-500 w-4 h-4"
                viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                <circle cx="12" cy="12" r="10" stroke-opacity="0.2"/>
                <path d="M12 2 a10 10 0 0 1 10 10" stroke-opacity="1"/>
              </svg>
              <span v-else-if="step.state === 'ok'" class="text-green-400 text-lg leading-none">✓</span>
              <span v-else-if="step.state === 'skip'" class="text-slate-500 text-lg leading-none">–</span>
              <span v-else-if="step.state === 'fail'" class="text-red-400 text-lg leading-none">✗</span>
            </div>
            <div>
              <div class="text-sm" :class="step.state === 'fail' ? 'text-red-300' : step.state === 'skip' ? 'text-slate-500' : 'text-slate-200'">
                {{ step.label }}
              </div>
              <div v-if="step.detail" class="text-xs text-slate-500 mt-0.5">{{ step.detail }}</div>
            </div>
          </div>
        </div>
      </template>

      <!-- ── RESULT PHASE ── -->
      <template v-else-if="phase === 'result'">
        <div class="flex items-center gap-3 mb-5">
          <div class="w-10 h-10 rounded-full flex items-center justify-center text-xl shrink-0"
            :class="overallOk ? 'bg-green-900 text-green-300' : 'bg-red-900 text-red-300'">
            {{ overallOk ? '✓' : '✗' }}
          </div>
          <div>
            <div class="text-white font-semibold">{{ overallOk ? 'Deleted' : 'Partially failed' }}</div>
            <div v-if="freedStr" class="text-sm text-slate-400">{{ freedStr }} freed</div>
          </div>
        </div>

        <!-- Step summary -->
        <div class="space-y-2 mb-5">
          <div v-for="step in steps" :key="step.id" class="flex items-center gap-2 text-sm">
            <span class="w-4 text-center shrink-0"
              :class="step.state === 'ok' ? 'text-green-400' : step.state === 'fail' ? 'text-red-400' : 'text-slate-500'">
              {{ step.state === 'ok' ? '✓' : step.state === 'fail' ? '✗' : '–' }}
            </span>
            <span :class="step.state === 'fail' ? 'text-red-300' : step.state === 'skip' ? 'text-slate-500' : 'text-slate-300'">
              {{ step.label }}
            </span>
            <span v-if="step.detail" class="text-slate-500 text-xs ml-auto">{{ step.detail }}</span>
          </div>
        </div>

        <div v-if="!overallOk" class="mb-4 p-3 rounded-lg bg-red-950/40 border border-red-800/40 text-red-300 text-xs">
          {{ resultMessage }}
        </div>

        <button @click="close" class="w-full btn-secondary text-sm">
          {{ overallOk ? 'Close' : 'Close' }}
        </button>
      </template>

    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import axios from 'axios'

const props = defineProps({
  show: Boolean,
  item: Object,
  requireTyping: { type: Boolean, default: false },
  mediaType: { type: String, default: 'tv' },   // 'tv' | 'movie'
})
const emit = defineEmits(['cancel', 'done'])

const phase = ref('confirm')  // 'confirm' | 'deleting' | 'result'
const confirmText = ref('')
const steps = ref([])
const overallOk = ref(false)
const freedStr = ref('')
const resultMessage = ref('')
let autoCloseTimer = null

// Reset when modal opens/item changes
watch(() => [props.show, props.item], ([s]) => {
  if (s) {
    phase.value = 'confirm'
    confirmText.value = ''
    steps.value = []
    overallOk.value = false
    freedStr.value = ''
    resultMessage.value = ''
    if (autoCloseTimer) clearTimeout(autoCloseTimer)
  }
})

const canConfirm = computed(() => {
  if (!props.requireTyping) return true
  return confirmText.value === props.item?.title
})

const fileSize = computed(() => {
  const b = props.item?.file_size_bytes || props.item?.size_on_disk || 0
  if (!b) return null
  const gb = b / 1_073_741_824
  return gb >= 1 ? `${gb.toFixed(1)} GB` : `${(b / 1_048_576).toFixed(0)} MB`
})

function initSteps() {
  const isTv = props.mediaType === 'tv'
  steps.value = [
    { id: 'arr',    label: isTv ? 'Remove from Sonarr' : 'Remove from Radarr', state: 'waiting', detail: '' },
    { id: 'cross',  label: 'Remove from other instances',                        state: 'waiting', detail: '' },
    { id: 'unraid', label: 'Delete from Unraid',                                 state: 'waiting', detail: '' },
    { id: 'db',     label: 'Remove from Curatorr',                               state: 'waiting', detail: '' },
  ]
}

function setStep(id, state, detail = '') {
  const s = steps.value.find(s => s.id === id)
  if (s) { s.state = state; s.detail = detail }
}

async function confirm() {
  if (!canConfirm.value || !props.item) return
  phase.value = 'deleting'
  initSteps()

  try {
    const url = props.mediaType === 'tv'
      ? `/api/tv/${props.item.id}`
      : `/api/movies/${props.item.id}`

    const res = await axios.delete(url, { data: { confirm: true } })
    const d = res.data

    // Map API response to step states
    const arrOk = !!d.arr_delete_ok
    setStep('arr', arrOk ? 'ok' : 'fail', arrOk ? '' : d.message || 'Sonarr/Radarr returned error')

    const cross = d.cross_instance_results || {}
    const crossEntries = Object.entries(cross)
    if (crossEntries.length === 0) {
      setStep('cross', 'skip', 'No other instances')
    } else {
      const allOk = crossEntries.every(([, ok]) => ok)
      const detail = crossEntries.map(([name, ok]) => `${name}: ${ok ? '✓' : '✗'}`).join('  ')
      setStep('cross', allOk ? 'ok' : 'fail', detail)
    }

    const unraidOk = !!d.unraid_delete_ok
    if (!d.arr_delete_ok && !unraidOk) {
      // Both failed — likely not on Unraid
      setStep('unraid', 'skip', 'Not on Unraid or no path resolved')
    } else {
      const freed = d.freed_bytes ? `${(d.freed_bytes / 1_073_741_824).toFixed(1)} GB freed` : ''
      setStep('unraid', unraidOk ? 'ok' : 'skip', unraidOk ? freed : 'File not on Unraid')
    }

    // DB removal: if arr succeeded, row was removed
    setStep('db', arrOk ? 'ok' : 'fail', arrOk ? '' : 'Row kept — deletion was not confirmed')

    overallOk.value = arrOk
    if (d.freed_bytes && d.freed_bytes > 0) {
      const gb = d.freed_bytes / 1_073_741_824
      freedStr.value = gb >= 1 ? `${gb.toFixed(1)} GB` : `${(d.freed_bytes / 1_048_576).toFixed(0)} MB`
    }
    resultMessage.value = d.message || ''
    phase.value = 'result'

    if (overallOk.value) {
      autoCloseTimer = setTimeout(() => {
        emit('done', { id: props.item.id, freed: d.freed_bytes || 0 })
      }, 2500)
    }

  } catch (err) {
    // HTTP error (network, 500, etc.)
    const msg = err?.response?.data?.detail || err.message || 'Request failed'
    setStep('arr', 'fail', msg)
    setStep('cross', 'skip', '')
    setStep('unraid', 'skip', '')
    setStep('db', 'fail', 'Not removed')
    overallOk.value = false
    resultMessage.value = msg
    phase.value = 'result'
  }
}

function close() {
  if (autoCloseTimer) clearTimeout(autoCloseTimer)
  if (overallOk.value) {
    emit('done', { id: props.item?.id, freed: 0 })
  } else {
    emit('cancel')
  }
}
</script>
