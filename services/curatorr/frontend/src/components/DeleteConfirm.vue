<template>
  <div v-if="show" class="fixed inset-0 z-50 flex items-center justify-center p-4"
    style="background:rgba(0,0,0,0.7);" @click.self="$emit('cancel')">
    <div class="w-full max-w-md rounded-xl border p-6" style="background:#1a1d27; border-color:#2d3250;">
      <h3 class="text-lg font-semibold text-white mb-4">Confirm Delete</h3>

      <!-- Item info -->
      <div class="flex gap-3 mb-4 p-3 rounded-lg" style="background:#0f1117;">
        <div>
          <div class="font-medium text-white">{{ item?.title }} <span class="text-slate-400">({{ item?.year }})</span></div>
          <div v-if="item?.file_size_bytes" class="text-sm text-slate-400 mt-1">
            Frees {{ formatSize(item.file_size_bytes) }}
          </div>
        </div>
      </div>

      <!-- Watch warning -->
      <div class="mb-4 p-3 rounded-lg bg-amber-900/20 border border-amber-700/50 text-amber-300 text-sm">
        <div>Ali watched: {{ item?.ali_play_count || 0 }} times</div>
        <div>Chris watched: {{ item?.chris_play_count || 0 }} times</div>
      </div>

      <!-- Rating warning -->
      <div v-if="item?.imdb_rating > 7" class="mb-4 p-3 rounded-lg bg-yellow-900/20 border border-yellow-700/50 text-yellow-300 text-sm">
        High-rated content: IMDb {{ item.imdb_rating }}/10
      </div>

      <!-- Confirm input for TV shows -->
      <div v-if="requireTyping" class="mb-4">
        <label class="text-sm text-slate-400 block mb-1">Type the title to confirm:</label>
        <input v-model="confirmText" class="input" :placeholder="item?.title" />
      </div>

      <div class="flex gap-3">
        <button @click="$emit('cancel')" class="flex-1 btn-secondary">Cancel</button>
        <button @click="confirm" :disabled="!canConfirm" class="flex-1 btn-danger">
          Delete
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  show: Boolean,
  item: Object,
  requireTyping: { type: Boolean, default: false },
})
const emit = defineEmits(['confirm', 'cancel'])

const confirmText = ref('')

const canConfirm = computed(() => {
  if (!props.requireTyping) return true
  return confirmText.value === props.item?.title
})

const confirm = () => {
  if (canConfirm.value) {
    emit('confirm')
    confirmText.value = ''
  }
}

const formatSize = (bytes) => {
  const gb = bytes / 1_073_741_824
  return gb > 1 ? `${gb.toFixed(1)} GB` : `${(bytes / 1_048_576).toFixed(0)} MB`
}
</script>
