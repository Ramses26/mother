<template>
  <div>
    <div class="flex items-center justify-between mb-1">
      <span class="text-xs text-slate-400">Purge Risk</span>
      <span class="text-xs font-bold" :class="labelClass">{{ score }}/100</span>
    </div>
    <div class="w-full h-2 rounded-full overflow-hidden" style="background:#2d3250;">
      <div class="h-full rounded-full transition-all"
        :style="{ width: score + '%', background: barColor }"></div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({ score: { type: Number, default: 0 } })

const barColor = computed(() => {
  if (props.score >= 75) return '#ef4444'
  if (props.score >= 55) return '#f97316'
  if (props.score >= 30) return '#eab308'
  return '#22c55e'
})

const labelClass = computed(() => {
  if (props.score >= 75) return 'text-red-400'
  if (props.score >= 55) return 'text-orange-400'
  if (props.score >= 30) return 'text-yellow-400'
  return 'text-green-400'
})
</script>
