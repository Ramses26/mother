<template>
  <span v-if="value != null && value > 0"
    class="inline-flex flex-col items-center gap-0.5 px-2 py-1 rounded-lg text-xs font-medium"
    :class="badgeClass">
    <span class="font-semibold">{{ icon }} {{ displayValue }}</span>
    <span class="text-[10px] opacity-70 font-normal leading-none">{{ label }}</span>
  </span>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  source: { type: String, required: true },
  value: { type: Number, default: null },
})

const config = {
  imdb:      { icon: '⭐', label: 'IMDb',  class: 'bg-yellow-900/60 text-yellow-300', fmt: v => v.toFixed(1) },
  rt:        { icon: '🍅', label: 'RT',    class: 'bg-red-900/60 text-red-300',       fmt: v => v + '%' },
  metacritic:{ icon: 'MC', label: 'MC',    class: 'bg-green-900/60 text-green-300',   fmt: v => v },
  tmdb:      { icon: '🎬', label: 'TMDB',  class: 'bg-blue-900/60 text-blue-300',     fmt: v => v.toFixed(1) },
  mdblist:   { icon: '📊', label: 'MDB',   class: 'bg-purple-900/60 text-purple-300', fmt: v => v },
  composite: { icon: '⚡', label: 'Score', class: 'bg-violet-900/60 text-violet-300', fmt: v => v.toFixed(1) },
  trakt:     { icon: '🔥', label: 'Trakt', class: 'bg-orange-900/60 text-orange-300', fmt: v => v.toFixed(1) },
}

const cfg = computed(() => config[props.source] || config.composite)
const icon = computed(() => cfg.value.icon)
const label = computed(() => cfg.value.label)
const badgeClass = computed(() => cfg.value.class)
const displayValue = computed(() => props.value != null ? cfg.value.fmt(props.value) : '')
</script>
