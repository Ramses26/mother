<template>
  <div class="p-6 max-w-5xl mx-auto">
    <div class="flex items-center justify-between mb-6">
      <div class="flex items-center gap-2">
        <h1 class="text-2xl font-bold text-white">Rules Engine</h1>
        <router-link to="/help#rules" class="text-slate-600 hover:text-slate-300 text-xs px-1 mt-1" title="Help">?</router-link>
      </div>
      <button @click="openCreate" class="btn-primary text-sm">+ New Rule</button>
    </div>

    <!-- Rules list -->
    <div class="space-y-3 mb-6">
      <div v-if="rules.length === 0" class="text-slate-500 text-center py-12">
        No rules yet. Create one to automate media management.
      </div>
      <div v-for="r in rules" :key="r.id" class="card">
        <div class="flex items-center gap-3">
          <!-- Enable toggle -->
          <button @click="toggleRule(r)" class="w-10 h-5 rounded-full transition-colors relative"
            :class="r.enabled ? 'bg-violet-600' : 'bg-slate-600'">
            <div class="absolute top-0.5 w-4 h-4 rounded-full bg-white transition-transform"
              :class="r.enabled ? 'right-0.5' : 'left-0.5'"></div>
          </button>
          <!-- Info -->
          <div class="flex-1">
            <div class="font-medium text-white">{{ r.name }}</div>
            <div class="text-xs text-slate-400 mt-0.5">
              <span class="px-1.5 py-0.5 rounded mr-2" :class="actionClass(r.action)">{{ r.action }}</span>
              <span>{{ r.media_type || 'all' }} ·</span>
              <span> {{ r.schedule }}</span>
              <span v-if="r.last_run"> · Last run {{ fmtDate(r.last_run) }}</span>
              <span v-if="r.last_match_count"> · {{ r.last_match_count }} matches</span>
            </div>
          </div>
          <!-- Actions -->
          <div class="flex gap-2">
            <button @click="previewRule(r)" class="btn-secondary text-xs px-3 py-1.5">Preview</button>
            <button @click="runRule(r)" class="btn-secondary text-xs px-3 py-1.5">Run</button>
            <button @click="openEdit(r)" class="text-slate-400 hover:text-white p-1">✏</button>
            <button @click="deleteRule(r)" class="text-red-400 hover:text-red-300 p-1">✕</button>
          </div>
        </div>

        <!-- Matches preview -->
        <div v-if="r._matches" class="mt-3 border-t pt-3" style="border-color:#2d3250;">
          <div class="text-xs text-slate-400 mb-2">{{ r._matches.count }} matches</div>
          <div class="space-y-1">
            <div v-for="m in r._matches.items.slice(0,10)" :key="m.id"
              class="flex items-center justify-between text-xs p-2 rounded" style="background:#0f1117;">
              <span class="text-slate-300">{{ m.title }} ({{ m.year }})</span>
              <span v-if="m.composite_score" class="text-slate-500">{{ m.composite_score?.toFixed(1) }}</span>
            </div>
          </div>
          <button v-if="r._matches.count > 0" @click="executeRule(r)"
            class="mt-2 btn-danger text-xs px-3 py-1.5">
            Execute on {{ r._matches.count }} items
          </button>
        </div>
      </div>
    </div>

    <!-- Create/Edit modal -->
    <div v-if="showModal" class="fixed inset-0 z-50 flex items-center justify-center p-4"
      style="background:rgba(0,0,0,0.7);" @click.self="showModal = false">
      <div class="w-full max-w-xl rounded-xl border overflow-y-auto max-h-screen" style="background:#1a1d27; border-color:#2d3250;">
        <div class="p-6">
          <h3 class="text-lg font-semibold text-white mb-4">{{ editingRule?.id ? 'Edit' : 'Create' }} Rule</h3>

          <div class="space-y-3">
            <div>
              <label class="label">Name</label>
              <input v-model="form.name" class="input" placeholder="Rule name"/>
            </div>
            <div class="grid grid-cols-2 gap-3">
              <div>
                <label class="label">Media Type</label>
                <select v-model="form.media_type" class="input">
                  <option value="">Both</option>
                  <option value="movie">Movies</option>
                  <option value="tv">TV Shows</option>
                </select>
              </div>
              <div>
                <label class="label">Action</label>
                <select v-model="form.action" class="input">
                  <option value="stage">Stage (review first)</option>
                  <option value="unmonitor">Unmonitor</option>
                  <option value="notify">Notify only</option>
                </select>
              </div>
            </div>
            <div class="grid grid-cols-2 gap-3">
              <div>
                <label class="label">Condition Logic</label>
                <select v-model="form.condition_logic" class="input">
                  <option value="AND">AND (all must match)</option>
                  <option value="OR">OR (any matches)</option>
                </select>
              </div>
              <div>
                <label class="label">Schedule</label>
                <select v-model="form.schedule" class="input">
                  <option value="manual">Manual</option>
                  <option value="daily">Daily</option>
                  <option value="weekly">Weekly</option>
                </select>
              </div>
            </div>

            <!-- Conditions -->
            <div>
              <div class="flex items-center justify-between mb-2">
                <label class="label mb-0">Conditions</label>
                <button @click="addCondition" class="text-violet-400 hover:text-violet-300 text-sm">+ Add</button>
              </div>
              <div v-for="(c, i) in form.conditions" :key="i" class="flex gap-2 mb-2">
                <select v-model="c.field" class="input text-sm flex-1">
                  <option v-for="f in conditionFields" :key="f.value" :value="f.value">{{ f.label }}</option>
                </select>
                <select v-model="c.operator" class="input text-sm w-28">
                  <option v-for="o in operators" :key="o.value" :value="o.value">{{ o.label }}</option>
                </select>
                <input v-model="c.value" class="input text-sm w-24" placeholder="Value"/>
                <button @click="removeCondition(i)" class="text-red-400 hover:text-red-300 px-1">✕</button>
              </div>
              <div v-if="form.conditions.length === 0" class="text-slate-500 text-xs">
                No conditions — add at least one
              </div>
            </div>

            <label class="flex items-center gap-2 cursor-pointer">
              <input type="checkbox" v-model="form.notify_bool"/>
              <span class="text-sm text-slate-300">Send Telegram notification on match</span>
            </label>
          </div>

          <div class="flex gap-3 mt-6">
            <button @click="showModal = false" class="flex-1 btn-secondary">Cancel</button>
            <button @click="saveRule" class="flex-1 btn-primary">Save Rule</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import axios from 'axios'

const rules = ref([])
const showModal = ref(false)
const editingRule = ref(null)

const form = reactive({
  name: '', media_type: '', condition_logic: 'AND',
  conditions: [], action: 'stage', schedule: 'manual', notify_bool: true,
})

const conditionFields = [
  { value: 'composite_score', label: 'Composite Score' },
  { value: 'imdb_rating', label: 'IMDb Rating' },
  { value: 'rt_critics', label: 'RT Critics' },
  { value: 'metacritic', label: 'Metacritic' },
  { value: 'mdblist_score', label: 'MDBList Score' },
  { value: 'purge_score', label: 'Purge Score' },
  { value: 'ali_play_count', label: 'Ali Play Count' },
  { value: 'chris_play_count', label: 'Chris Play Count' },
  { value: 'file_size_gb', label: 'File Size (GB)' },
  { value: 'resolution', label: 'Resolution' },
  { value: 'year', label: 'Year' },
  { value: 'status', label: 'TV Status' },
]

const operators = [
  { value: 'eq', label: '= equals' },
  { value: 'ne', label: '≠ not equals' },
  { value: 'gt', label: '> greater' },
  { value: 'gte', label: '>= greater/equal' },
  { value: 'lt', label: '< less' },
  { value: 'lte', label: '<= less/equal' },
  { value: 'contains', label: 'contains' },
]

const load = async () => {
  try { const res = await axios.get('/api/rules'); rules.value = res.data }
  catch {}
}

const openCreate = () => {
  editingRule.value = null
  Object.assign(form, { name: '', media_type: '', condition_logic: 'AND',
    conditions: [], action: 'stage', schedule: 'manual', notify_bool: true })
  showModal.value = true
}

const openEdit = (r) => {
  editingRule.value = r
  let conditions = []
  try { conditions = JSON.parse(r.conditions || '[]') } catch {}
  Object.assign(form, {
    name: r.name, media_type: r.media_type || '', condition_logic: r.condition_logic,
    conditions, action: r.action, schedule: r.schedule, notify_bool: !!r.notify,
  })
  showModal.value = true
}

const addCondition = () => form.conditions.push({ field: 'composite_score', operator: 'lte', value: '' })
const removeCondition = (i) => form.conditions.splice(i, 1)

const saveRule = async () => {
  const payload = {
    name: form.name, media_type: form.media_type || null,
    condition_logic: form.condition_logic,
    conditions: form.conditions,
    action: form.action, schedule: form.schedule, notify: form.notify_bool ? 1 : 0,
  }
  try {
    if (editingRule.value?.id) {
      await axios.put(`/api/rules/${editingRule.value.id}`, payload)
    } else {
      await axios.post('/api/rules', payload)
    }
    showModal.value = false
    await load()
  } catch { alert('Save failed') }
}

const toggleRule = async (r) => {
  const conditions = (() => { try { return JSON.parse(r.conditions || '[]') } catch { return [] } })()
  await axios.put(`/api/rules/${r.id}`, { ...r, enabled: r.enabled ? 0 : 1, conditions })
  await load()
}

const previewRule = async (r) => {
  try {
    const res = await axios.post(`/api/rules/${r.id}/preview`)
    r._matches = res.data
  } catch {}
}

const runRule = async (r) => {
  try {
    const res = await axios.post(`/api/rules/${r.id}/run`)
    r._matches = res.data
  } catch {}
}

const executeRule = async (r) => {
  if (!confirm(`Execute action '${r.action}' on ${r._matches?.count} items?`)) return
  try {
    await axios.post(`/api/rules/${r.id}/execute`)
    r._matches = null
    await load()
  } catch { alert('Execute failed') }
}

const deleteRule = async (r) => {
  if (!confirm(`Delete rule '${r.name}'?`)) return
  try { await axios.delete(`/api/rules/${r.id}`); await load() }
  catch {}
}

const actionClass = (a) => ({
  stage: 'bg-blue-900 text-blue-300',
  unmonitor: 'bg-yellow-900 text-yellow-300',
  delete: 'bg-red-900 text-red-300',
  notify: 'bg-green-900 text-green-300',
}[a] || 'bg-slate-700 text-slate-300')

const fmtDate = (d) => d ? new Date(d.includes('Z') ? d : d + 'Z').toLocaleDateString() : ''

onMounted(load)
</script>
