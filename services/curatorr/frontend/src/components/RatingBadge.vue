<template>
  <span v-if="value != null && value > 0"
    class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-medium"
    :class="badgeClass">
    <span>{{ icon }}</span>
    <span>{{ displayValue }}</span>
  </span>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  source: { type: String, required: true },
  value: { type: Number, default: null },
})

const config = {
  imdb:      { icon: '⭐', class: 'bg-yellow-900/60 text-yellow-300', fmt: v => v.toFixed(1) },
  rt:        { icon: '🍅', class: 'bg-red-900/60 text-red-300', fmt: v => v + '%' },
  metacritic:{ icon: 'MC', class: 'bg-green-900/60 text-green-300', fmt: v => v },
  tmdb:      { icon: '🎬', class: 'bg-blue-900/60 text-blue-300', fmt: v => v.toFixed(1) },
  mdblist:   { icon: '📊', class: 'bg-purple-900/60 text-purple-300', fmt: v => v },
  composite: { icon: '⚡', class: 'bg-violet-900/60 text-violet-300', fmt: v => v.toFixed(1) },
  trakt:     { icon: '🔥', class: 'bg-orange-900/60 text-orange-300', fmt: v => v.toFixed(1) },
}

const cfg = computed(() => config[props.source] || config.composite)
const icon = computed(() => cfg.value.icon)
const badgeClass = computed(() => cfg.value.class)
const displayValue = computed(() => props.value != null ? cfg.value.fmt(props.value) : '')
</script>
