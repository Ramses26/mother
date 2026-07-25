<template>
  <div class="p-6 max-w-6xl mx-auto">
    <div class="flex items-center justify-between mb-4">
      <h1 class="text-2xl font-bold text-white">Sync Status</h1>
      <div class="flex items-center gap-3">
        <button @click="triggerReconcile" :disabled="reconciling" class="btn-secondary text-sm text-violet-300 border-violet-700">
          {{ reconciling ? 'Queuing…' : 'Reconcile Now' }}
        </button>
        <button @click="refresh" :disabled="loading" class="btn-secondary text-sm">
          {{ loading ? 'Scanning…' : 'Refresh' }}
        </button>
      </div>
    </div>

    <!-- ── LIVE SYNC QUEUE PANEL ─────────────────────────────────────── -->
    <div class="rounded-lg mb-5 overflow-hidden" style="background:#0f1117; border:1px solid #1e2535;">
      <!-- Header row -->
      <div class="flex items-center justify-between px-4 py-2.5" style="border-bottom:1px solid #1e2535;">
        <div class="flex items-center gap-3">
          <span class="text-xs font-semibold text-slate-300 uppercase tracking-wider">Live Sync Queue</span>
          <span v-if="queueData?.active?.length" class="flex items-center gap-1.5 text-xs text-emerald-400">
            <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse inline-block"></span>
            {{ queueData.active.length }} active
          </span>
          <span v-else class="text-xs text-slate-600">idle</span>
        </div>
        <div class="flex items-center gap-4 text-xs text-slate-500">
          <span v-if="queueData?.pending_count">
            <span class="text-amber-400 font-medium">{{ queueData.pending_count }}</span> pending
          </span>
          <span v-if="queueData?.stats">
            Today: <span class="text-slate-300">{{ queueData.stats.today_successful }}</span> done ·
            <span class="text-slate-300">{{ queueData.stats.bytes_transferred_human }}</span>
            <span v-if="queueData.stats.today_failed" class="text-red-400 ml-1">· {{ queueData.stats.today_failed }} failed</span>
          </span>
          <span class="text-slate-700">auto-refresh 10s</span>
        </div>
      </div>

      <!-- Active jobs -->
      <div v-if="queueData?.active?.length" class="divide-y divide-slate-800/50">
        <div v-for="job in queueData.active" :key="job.id"
          class="flex items-center gap-3 px-4 py-2.5 text-sm">
          <div class="flex-shrink-0 w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse"></div>
          <span class="text-emerald-300 font-medium w-32 flex-shrink-0 truncate" :title="job.quality">{{ job.quality }}</span>
          <span class="text-slate-400 w-20 flex-shrink-0 text-xs">{{ job.direction }}</span>
          <span class="text-slate-300 flex-1 truncate font-mono text-xs" :title="job.filename">{{ job.filename }}</span>
          <span v-if="job.file_size" class="text-slate-500 text-xs flex-shrink-0">{{ (job.file_size/1073741824).toFixed(1) }} GB</span>
        </div>
      </div>

      <!-- Pending breakdown (when idle or below active) -->
      <div v-if="queueData?.pending_by_type && Object.keys(queueData.pending_by_type).length"
        class="flex flex-wrap gap-x-4 gap-y-1 px-4 py-2.5">
        <span v-for="(cnt, type) in queueData.pending_by_type" :key="type" class="text-xs">
          <span class="text-slate-400">{{ type }}:</span>
          <span class="text-amber-300 ml-1 font-medium">{{ cnt }}</span>
        </span>
      </div>

      <!-- No queue -->
      <div v-if="!queueData?.active?.length && !queueData?.pending_count && queueData"
        class="px-4 py-2.5 text-xs text-slate-600">
        No active or pending sync jobs.
      </div>
      <div v-if="!queueData" class="px-4 py-2.5 text-xs text-slate-600">Loading queue…</div>
    </div>

    <!-- ── PIPELINE PANEL (Upgraderr + Downloads) ──────────────────────── -->
    <div class="rounded-lg mb-5 overflow-hidden" style="background:#0f1117; border:1px solid #1e2535;">
      <div class="flex items-center justify-between px-4 py-2.5" style="border-bottom:1px solid #1e2535;">
        <div class="flex items-center gap-3">
          <span class="text-xs font-semibold text-slate-300 uppercase tracking-wider">Pipeline</span>
          <!-- Upgraderr status -->
          <template v-if="pipelineData?.upgraderr">
            <span v-if="pipelineData.upgraderr.paused"
              class="text-xs px-2 py-0.5 rounded bg-amber-900/40 text-amber-400">Upgraderr paused</span>
            <span v-else class="text-xs px-2 py-0.5 rounded bg-emerald-900/40 text-emerald-400">Upgraderr active</span>
            <span class="text-xs text-slate-500">
              {{ pipelineData.upgraderr.queue_total }} queued ·
              {{ pipelineData.upgraderr.searches_today }} searches today ·
              {{ pipelineData.upgraderr.upgrades_today }} upgraded today
            </span>
          </template>
        </div>
        <div class="flex items-center gap-2">
          <span v-if="pipelineData?.downloads_total" class="text-xs text-slate-500">
            <span class="text-blue-400 font-medium">{{ pipelineData.downloads_total }}</span> downloading
          </span>
          <button @click="triggerSweep" :disabled="sweeping"
            class="text-xs px-2.5 py-1 rounded transition-colors"
            style="background:#1a1d27; border:1px solid #2d3748; color:#94a3b8;"
            :class="sweeping ? 'opacity-50' : 'hover:text-white'">
            {{ sweeping ? 'Triggering…' : 'Sweep Now' }}
          </button>
          <button v-if="pipelineData?.upgraderr?.paused" @click="setPause(false)"
            class="text-xs px-2.5 py-1 rounded transition-colors"
            style="background:#1a1d27; border:1px solid #22543d; color:#68d391;">Resume</button>
          <button v-else @click="setPause(true)"
            class="text-xs px-2.5 py-1 rounded transition-colors"
            style="background:#1a1d27; border:1px solid #744210; color:#f6ad55;">Pause</button>
        </div>
      </div>

      <!-- Tier breakdown (compact) -->
      <div v-if="pipelineData?.upgraderr?.tier_labels"
        class="flex flex-wrap gap-x-4 gap-y-1 px-4 py-2" style="border-bottom:1px solid #1e2535;">
        <span v-for="(t, tier) in pipelineData.upgraderr.tier_labels" :key="tier"
          class="text-xs" :class="t.count > 0 ? 'text-slate-400' : 'text-slate-700'">
          T{{ tier }} <span class="font-medium" :class="t.count > 0 ? 'text-white' : ''">{{ t.count }}</span>
          <span class="text-slate-600 ml-0.5">{{ t.label }}</span>
        </span>
      </div>

      <!-- Active downloads (top 5) -->
      <div v-if="pipelineData?.downloads?.length" class="divide-y divide-slate-800/40">
        <div v-for="dl in pipelineData.downloads.slice(0, 5)" :key="dl.title + dl.instance"
          class="flex items-center gap-3 px-4 py-2.5 text-sm">
          <span class="text-blue-400 text-xs w-20 flex-shrink-0 truncate">{{ dl.instance }}</span>
          <span class="text-slate-500 text-xs w-24 flex-shrink-0">{{ dl.quality }}</span>
          <span class="flex-1 text-slate-300 truncate text-xs" :title="dl.title">{{ dl.title }}</span>
          <div class="flex items-center gap-2 flex-shrink-0">
            <div class="w-20 h-1.5 rounded-full bg-slate-800 overflow-hidden">
              <div class="h-full rounded-full bg-blue-500 transition-all" :style="{width: dl.progress + '%'}"></div>
            </div>
            <span class="text-slate-600 text-xs w-8 text-right">{{ dl.progress }}%</span>
          </div>
        </div>
        <div v-if="pipelineData.downloads.length > 5"
          class="px-4 py-1.5 text-xs text-slate-600 cursor-pointer hover:text-slate-400"
          @click="library = 'Pipeline'">
          +{{ pipelineData.downloads.length - 5 }} more — view Pipeline tab
        </div>
      </div>
      <div v-else-if="pipelineData && !pipelineData.downloads?.length"
        class="px-4 py-2.5 text-xs text-slate-600">No active downloads.</div>
      <div v-if="!pipelineData" class="px-4 py-2.5 text-xs text-slate-600">Loading pipeline…</div>
    </div>

    <!-- Library tabs -->
    <div class="flex gap-2 mb-6">
      <button v-for="t in ['Movies', 'TV Shows', 'TV Parity', 'Queue', 'Pipeline']" :key="t"
        @click="library = t"
        class="px-4 py-1.5 rounded text-sm transition-colors"
        :class="library === t ? 'bg-violet-600 text-white' : 'bg-surface-200 text-slate-400 hover:text-white'">
        {{ t }}<span v-if="t === 'Queue' && queueData?.pending_count" class="ml-1.5 text-xs text-amber-400">({{ queueData.pending_count }})</span>
        <span v-if="t === 'Pipeline' && pipelineData?.downloads_total" class="ml-1.5 text-xs text-blue-400">({{ pipelineData.downloads_total }})</span>
      </button>
    </div>

    <!-- ── MOVIES ─────────────────────────────────────────────────────── -->
    <template v-if="library === 'Movies'">
      <div v-if="movieData?.status === 'scanning' || !movieData" class="text-center py-20">
        <div class="animate-spin h-8 w-8 border-2 border-violet-500/30 border-t-violet-500 rounded-full mx-auto mb-4"></div>
        <div class="text-slate-400 text-sm">Querying Radarr + Unraid Agent…</div>
      </div>
      <div v-else-if="movieData?.status === 'error'" class="text-center py-10 text-red-400">
        {{ movieData.error }}
      </div>
      <template v-else>
        <!-- Summary cards -->
        <div class="grid grid-cols-2 md:grid-cols-5 gap-3 mb-6">
          <div class="rounded-lg p-4 text-center" style="background:#1a1d27; border:1px solid #2d3748;">
            <div class="text-2xl font-bold text-green-400">{{ fmt(movieData.summary.in_sync) }}</div>
            <div class="text-xs text-slate-400 mt-1">In Sync</div>
          </div>
          <div class="rounded-lg p-4 text-center" style="background:#1a1d27; border:1px solid #2d3748;">
            <div class="text-2xl font-bold text-red-400">{{ fmt(movieData.summary.missing_count) }}</div>
            <div class="text-xs text-slate-400 mt-1">Missing from Unraid</div>
          </div>
          <div class="rounded-lg p-4 text-center cursor-pointer hover:border-violet-500/50 transition-colors"
            style="background:#1a1d27; border:1px solid #2d3748;"
            @click="movieTab = 'syn_better'">
            <div class="text-2xl font-bold text-violet-400">{{ fmt(movieData.summary.syn_better_count) }}</div>
            <div class="text-xs text-slate-400 mt-1">Synology Upgrade</div>
          </div>
          <div class="rounded-lg p-4 text-center cursor-pointer hover:border-amber-500/50 transition-colors"
            style="background:#1a1d27; border:1px solid #2d3748;"
            @click="movieTab = 'unraid_better'">
            <div class="text-2xl font-bold text-amber-400">{{ fmt(movieData.summary.unraid_better_count) }}</div>
            <div class="text-xs text-slate-400 mt-1">Unraid Has Better</div>
          </div>
          <div class="rounded-lg p-4 text-center cursor-pointer hover:border-slate-500/50 transition-colors"
            style="background:#1a1d27; border:1px solid #2d3748;"
            @click="movieTab = 'radarr_stale'">
            <div class="text-2xl font-bold text-slate-400">{{ fmt(movieData.summary.radarr_stale_count) }}</div>
            <div class="text-xs text-slate-400 mt-1">Radarr Out of Date</div>
          </div>
        </div>

        <div class="text-xs text-slate-600 mb-4">
          Cached {{ movieData.cached_age_s }}s ago · {{ fmt(movieData.summary.total) }} movies in Radarr HD
          <span v-if="movieData.scanning" class="text-amber-400 ml-1">· refreshing…</span>
        </div>

        <!-- Sub-tabs -->
        <div class="flex flex-wrap gap-2 mb-5">
          <button v-for="t in movieTabs" :key="t.key" @click="movieTab = t.key"
            class="px-4 py-1.5 rounded text-sm transition-colors"
            :class="movieTab === t.key ? 'bg-violet-600 text-white' : 'bg-surface-200 text-slate-400 hover:text-white'">
            {{ t.label }}
            <span v-if="t.count" class="ml-1 text-xs opacity-70">({{ fmt(t.count) }})</span>
          </button>
        </div>

        <!-- Missing -->
        <template v-if="movieTab === 'missing'">
          <div v-if="!movieData.missing?.length" class="text-center py-10 text-green-400">
            No missing movies — gap scanner is keeping up!
          </div>
          <div v-else class="space-y-1">
            <div v-for="m in movieData.missing" :key="m.title"
              class="flex items-center justify-between px-4 py-2 rounded"
              style="background:#1a1d27;">
              <span class="text-white text-sm truncate">{{ m.title }}</span>
              <div class="flex items-center gap-4 ml-4 shrink-0">
                <span class="text-xs text-violet-400">{{ m.quality }}</span>
                <span class="text-xs text-slate-500">{{ gb(m.size_bytes) }}</span>
              </div>
            </div>
          </div>
        </template>

        <!-- Synology scores higher → nightly reconcile will sync to Unraid -->
        <template v-else-if="movieTab === 'syn_better'">
          <div v-if="!movieData.syn_better?.length" class="text-center py-10 text-green-400">
            No movies where Synology has a better copy — Unraid is up to date!
          </div>
          <div v-else>
            <div class="text-xs text-slate-500 mb-3 p-3 rounded" style="background:#1a1e2e; border:1px solid #2d3748;">
              Radarr's file on Synology has a <strong class="text-slate-300">higher TRaSH score</strong> than what's on Unraid.
              The nightly movie version reconcile (11:45 PM ET) will sync Radarr's file to Unraid and remove the old copy.
            </div>
            <div v-for="m in movieData.syn_better" :key="m.title" class="mb-3 rounded-lg overflow-hidden"
              style="background:#1a1d27; border:1px solid #2d3748;">
              <div class="px-4 py-2.5 font-medium text-white text-sm">{{ m.title }}</div>
              <div class="px-4 pb-3 space-y-1">
                <div class="flex items-start gap-2">
                  <span class="text-green-400 text-xs mt-0.5 w-16 shrink-0">Radarr</span>
                  <div>
                    <span class="text-xs text-slate-300 break-all">{{ m.syn_file }}</span>
                    <span class="ml-2 text-xs text-slate-500">{{ gb(m.syn_size_bytes) }}</span>
                    <span class="ml-2 px-1.5 py-0.5 rounded text-xs bg-violet-900/60 text-violet-300">{{ m.syn_quality }}</span>
                    <span class="ml-1 text-xs text-slate-600">score {{ m.syn_score }}</span>
                  </div>
                </div>
                <div class="flex items-start gap-2">
                  <span class="text-red-400 text-xs mt-0.5 w-16 shrink-0">Unraid</span>
                  <div>
                    <span class="text-xs text-slate-400 break-all">{{ m.unraid_file }}</span>
                    <span class="ml-2 text-xs text-slate-500">{{ gb(m.unraid_size_bytes) }}</span>
                    <span class="ml-2 px-1.5 py-0.5 rounded text-xs bg-slate-700 text-slate-400">{{ m.unraid_label }}</span>
                    <span class="ml-1 text-xs text-slate-600">score {{ m.unraid_score }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </template>

        <!-- Unraid scores higher → keep Unraid copy, Upgraderr should upgrade Synology -->
        <template v-else-if="movieTab === 'unraid_better'">
          <div v-if="!movieData.unraid_better?.length" class="text-center py-10 text-green-400">
            No movies where Unraid has a better copy.
          </div>
          <div v-else>
            <div class="text-xs text-amber-500/80 mb-3 p-3 rounded" style="background:#2d1f00; border:1px solid #4a3200;">
              Unraid already has a <strong class="text-amber-300">higher TRaSH score</strong> than what Radarr currently tracks on Synology
              (e.g. Unraid has a Remux from batch sync; Radarr has a Blu-ray encode).
              The version reconcile will <strong class="text-amber-300">not replace</strong> Unraid's better copy.
              Upgraderr will eventually upgrade Synology — then the webhook propagates it and both sides match.
            </div>
            <div v-for="m in movieData.unraid_better" :key="m.title" class="mb-3 rounded-lg overflow-hidden"
              style="background:#1a1d27; border:1px solid #2d3748;">
              <div class="px-4 py-2.5 font-medium text-white text-sm">{{ m.title }}</div>
              <div class="px-4 pb-3 space-y-1">
                <div class="flex items-start gap-2">
                  <span class="text-slate-500 text-xs mt-0.5 w-16 shrink-0">Radarr</span>
                  <div>
                    <span class="text-xs text-slate-400 break-all">{{ m.syn_file }}</span>
                    <span class="ml-2 text-xs text-slate-500">{{ gb(m.syn_size_bytes) }}</span>
                    <span class="ml-2 px-1.5 py-0.5 rounded text-xs bg-slate-800 text-slate-500">{{ m.syn_quality }}</span>
                    <span class="ml-1 text-xs text-slate-600">score {{ m.syn_score }}</span>
                  </div>
                </div>
                <div class="flex items-start gap-2">
                  <span class="text-green-400 text-xs mt-0.5 w-16 shrink-0">Unraid</span>
                  <div>
                    <span class="text-xs text-slate-300 break-all">{{ m.unraid_file }}</span>
                    <span class="ml-2 text-xs text-slate-500">{{ gb(m.unraid_size_bytes) }}</span>
                    <span class="ml-2 px-1.5 py-0.5 rounded text-xs bg-amber-900/60 text-amber-300">{{ m.unraid_label }}</span>
                    <span class="ml-1 text-xs text-slate-600">score {{ m.unraid_score }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </template>

        <!-- Radarr tracking old file — Synology folder has a newer/better version -->
        <template v-else-if="movieTab === 'radarr_stale'">
          <div v-if="!movieData.radarr_stale?.length" class="text-center py-10 text-green-400">
            Radarr is tracking the best file in every folder.
          </div>
          <div v-else>
            <div class="text-xs text-amber-500/80 mb-3 p-3 rounded" style="background:#2d1f00; border:1px solid #4a3200;">
              Radarr is referencing an older file while the Synology folder contains a better one
              (e.g. a release-group copy added by batch sync). Trigger a Radarr library rescan
              (<strong>Movies → Library Import</strong> or the <code>rescanMovie</code> API) to let
              Radarr adopt the better file — then both sides stay in sync automatically.
            </div>
            <div v-for="m in movieData.radarr_stale" :key="m.title" class="mb-3 rounded-lg overflow-hidden"
              style="background:#1a1d27; border:1px solid #2d3748;">
              <div class="px-4 py-2.5 font-medium text-white text-sm">{{ m.title }}</div>
              <div class="px-4 pb-3 space-y-1">
                <div class="flex items-start gap-2">
                  <span class="text-amber-400 text-xs mt-0.5 w-20 shrink-0">Radarr has</span>
                  <div>
                    <span class="text-xs text-slate-400 break-all">{{ m.radarr_file }}</span>
                    <span class="ml-2 text-xs text-slate-500">{{ gb(m.radarr_size_bytes) }}</span>
                  </div>
                </div>
                <div class="flex items-start gap-2">
                  <span class="text-green-400 text-xs mt-0.5 w-20 shrink-0">Folder has</span>
                  <div>
                    <span class="text-xs text-slate-300 break-all">{{ m.syn_file }}</span>
                    <span class="ml-2 text-xs text-slate-500">{{ gb(m.syn_size_bytes) }}</span>
                    <span class="ml-2 px-1.5 py-0.5 rounded text-xs bg-amber-900/60 text-amber-300">{{ m.syn_label }}</span>
                    <span class="ml-1 text-xs text-slate-600">score {{ m.syn_score }}</span>
                  </div>
                </div>
                <div class="text-xs text-slate-600 mt-1 italic">{{ m.note }}</div>
              </div>
            </div>
          </div>
        </template>
      </template>
    </template>

    <!-- ── TV SHOWS ───────────────────────────────────────────────────── -->
    <template v-else-if="library === 'TV Shows'">
      <div v-if="tvData?.status === 'scanning' || !tvData" class="text-center py-20">
        <div class="animate-spin h-8 w-8 border-2 border-violet-500/30 border-t-violet-500 rounded-full mx-auto mb-4"></div>
        <div class="text-slate-400 text-sm">Scanning Synology NFS + Unraid Agent TV inventory (~60s)…</div>
      </div>
      <div v-else-if="tvData?.status === 'error'" class="text-center py-10 text-red-400">
        {{ tvData.error }}
      </div>
      <template v-else>
        <!-- Summary cards -->
        <div class="grid grid-cols-2 md:grid-cols-4 gap-3 mb-6">
          <div class="rounded-lg p-4 text-center" style="background:#1a1d27; border:1px solid #2d3748;">
            <div class="text-2xl font-bold text-green-400">{{ fmt(tvData.summary.in_sync) }}</div>
            <div class="text-xs text-slate-400 mt-1">Episodes In Sync</div>
          </div>
          <div class="rounded-lg p-4 text-center" style="background:#1a1d27; border:1px solid #2d3748;">
            <div class="text-2xl font-bold text-red-400">{{ fmt(tvData.summary.missing_count) }}</div>
            <div class="text-xs text-slate-400 mt-1">Missing from Unraid</div>
          </div>
          <div class="rounded-lg p-4 text-center cursor-pointer hover:border-violet-500/50 transition-colors"
            style="background:#1a1d27; border:1px solid #2d3748;"
            @click="tvTab = 'syn_better'">
            <div class="text-2xl font-bold text-violet-400">{{ fmt(tvData.summary.syn_better_count) }}</div>
            <div class="text-xs text-slate-400 mt-1">Synology Upgrade</div>
          </div>
          <div class="rounded-lg p-4 text-center cursor-pointer hover:border-amber-500/50 transition-colors"
            style="background:#1a1d27; border:1px solid #2d3748;"
            @click="tvTab = 'unraid_better'">
            <div class="text-2xl font-bold text-amber-400">{{ fmt(tvData.summary.unraid_better_count) }}</div>
            <div class="text-xs text-slate-400 mt-1">Unraid Has Better</div>
          </div>
        </div>

        <div class="text-xs text-slate-600 mb-4">
          Cached {{ tvData.cached_age_s }}s ago ·
          {{ fmt(tvData.summary.syn_total) }} episodes on Synology,
          {{ fmt(tvData.summary.unraid_total) }} on Unraid
          <span v-if="tvData.scanning" class="text-amber-400 ml-1">· refreshing…</span>
        </div>

        <!-- Sub-tabs -->
        <div class="flex flex-wrap gap-2 mb-5">
          <button v-for="t in tvTabs" :key="t.key" @click="tvTab = t.key"
            class="px-4 py-1.5 rounded text-sm transition-colors"
            :class="tvTab === t.key ? 'bg-violet-600 text-white' : 'bg-surface-200 text-slate-400 hover:text-white'">
            {{ t.label }}
            <span v-if="t.count" class="ml-1 text-xs opacity-70">({{ fmt(t.count) }})</span>
          </button>
        </div>

        <!-- Missing episodes -->
        <template v-if="tvTab === 'missing'">
          <div v-if="!tvData.missing_shows?.length" class="text-center py-10 text-green-400">
            No missing episodes!
          </div>
          <div v-else>
            <div v-for="s in tvData.missing_shows" :key="s.show"
              class="mb-2 rounded-lg overflow-hidden"
              style="background:#1a1d27; border:1px solid #2d3748;">
              <div class="flex items-center justify-between px-4 py-2.5 cursor-pointer hover:bg-white/5"
                @click="toggleShow('miss', s.show)">
                <span class="text-white text-sm font-medium">{{ s.show }}</span>
                <div class="flex items-center gap-3">
                  <span class="text-red-400 text-xs">{{ s.count }} episode{{ s.count > 1 ? 's' : '' }}</span>
                  <span class="text-slate-600 text-xs">{{ expandedMiss.has(s.show) ? '▲' : '▼' }}</span>
                </div>
              </div>
              <div v-if="expandedMiss.has(s.show)" class="border-t border-surface-300 px-4 py-2 space-y-1">
                <div v-for="ep in s.episodes" :key="ep.ep"
                  class="flex items-center justify-between text-xs py-1">
                  <span class="text-slate-400 w-20 shrink-0">{{ ep.ep }}</span>
                  <span class="text-slate-300 truncate flex-1 mx-2">{{ ep.file }}</span>
                  <span class="text-slate-500 shrink-0">{{ gb(ep.size_bytes) }}</span>
                </div>
              </div>
            </div>
          </div>
        </template>

        <!-- Synology has upgrade -->
        <template v-else-if="tvTab === 'syn_better'">
          <div v-if="!tvData.syn_better_shows?.length" class="text-center py-10 text-green-400">
            No version mismatches where Synology is better.
          </div>
          <div v-else>
            <div class="text-xs text-slate-500 mb-3">
              Synology has a higher TRaSH score for these episodes. Gap scanner will copy Synology's file to Unraid;
              dedup will then remove the lower-quality Unraid copy.
            </div>
            <div v-for="s in tvData.syn_better_shows" :key="s.show"
              class="mb-2 rounded-lg overflow-hidden"
              style="background:#1a1d27; border:1px solid #2d3748;">
              <div class="flex items-center justify-between px-4 py-2.5 cursor-pointer hover:bg-white/5"
                @click="toggleShow('syn', s.show)">
                <span class="text-white text-sm font-medium">{{ s.show }}</span>
                <div class="flex items-center gap-3">
                  <span class="text-violet-400 text-xs">{{ s.count }} episode{{ s.count > 1 ? 's' : '' }}</span>
                  <span class="text-slate-600 text-xs">{{ expandedSyn.has(s.show) ? '▲' : '▼' }}</span>
                </div>
              </div>
              <div v-if="expandedSyn.has(s.show)" class="border-t border-surface-300 px-4 py-2 space-y-2">
                <div v-for="ep in s.episodes" :key="ep.ep" class="py-1 border-b border-surface-300 last:border-0">
                  <div class="text-xs text-slate-400 mb-1">{{ ep.ep }}</div>
                  <div class="flex items-start gap-2 text-xs">
                    <span class="text-green-400 w-16 shrink-0">Synology</span>
                    <span class="text-slate-300 truncate">{{ ep.syn_file }}</span>
                    <span class="text-slate-500 shrink-0 ml-1">{{ gb(ep.syn_size_bytes) }}</span>
                  </div>
                  <div class="flex items-start gap-2 text-xs mt-0.5">
                    <span class="text-red-400 w-16 shrink-0">Unraid</span>
                    <span class="text-slate-400 truncate">{{ ep.unraid_file }}</span>
                    <span class="text-slate-500 shrink-0 ml-1">{{ gb(ep.unraid_size_bytes) }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </template>

        <!-- Unraid has better (TV only — NFS scan doesn't have Sonarr profile context) -->
        <template v-else-if="tvTab === 'unraid_better'">
          <div v-if="!tvData.unraid_better_shows?.length" class="text-center py-10 text-green-400">
            No episodes where Unraid has a better version.
          </div>
          <div v-else>
            <div class="text-xs text-amber-500/80 mb-3 p-3 rounded" style="background:#2d1f00; border:1px solid #4a3200;">
              These episodes score higher on Unraid than on Synology.
              The version reconcile will not touch these (Synology is not strictly better).
              Upgraderr should eventually upgrade Synology to match or exceed these.
            </div>
            <div v-for="s in tvData.unraid_better_shows" :key="s.show"
              class="mb-2 rounded-lg overflow-hidden"
              style="background:#1a1d27; border:1px solid #2d3748;">
              <div class="flex items-center justify-between px-4 py-2.5 cursor-pointer hover:bg-white/5"
                @click="toggleShow('unr', s.show)">
                <span class="text-white text-sm font-medium">{{ s.show }}</span>
                <div class="flex items-center gap-3">
                  <span class="text-amber-400 text-xs">{{ s.count }} episode{{ s.count > 1 ? 's' : '' }}</span>
                  <span class="text-slate-600 text-xs">{{ expandedUnr.has(s.show) ? '▲' : '▼' }}</span>
                </div>
              </div>
              <div v-if="expandedUnr.has(s.show)" class="border-t border-surface-300 px-4 py-2 space-y-2">
                <div v-for="ep in s.episodes" :key="ep.ep" class="py-1 border-b border-surface-300 last:border-0">
                  <div class="text-xs text-slate-400 mb-1">{{ ep.ep }}</div>
                  <div class="flex items-start gap-2 text-xs">
                    <span class="text-slate-400 w-16 shrink-0">Synology</span>
                    <span class="text-slate-400 truncate">{{ ep.syn_file }}</span>
                    <span class="text-slate-500 shrink-0 ml-1">{{ gb(ep.syn_size_bytes) }}</span>
                  </div>
                  <div class="flex items-start gap-2 text-xs mt-0.5">
                    <span class="text-green-400 w-16 shrink-0">Unraid</span>
                    <span class="text-slate-300 truncate">{{ ep.unraid_file }}</span>
                    <span class="text-slate-500 shrink-0 ml-1">{{ gb(ep.unraid_size_bytes) }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </template>
      </template>
    </template>

    <!-- ── TV PARITY ────────────────────────────────────────────────────── -->
    <template v-else-if="library === 'TV Parity'">
      <div v-if="parityData?.status === 'scanning' || !parityData" class="text-center py-20">
        <div class="animate-spin h-8 w-8 border-2 border-violet-500/30 border-t-violet-500 rounded-full mx-auto mb-4"></div>
        <div class="text-slate-400 text-sm">Full Synology NFS walk + Unraid Agent inventory — takes ~2 min…</div>
      </div>
      <div v-else-if="parityData?.status === 'error'" class="text-center py-10 text-red-400">
        {{ parityData.error }}
      </div>
      <template v-else>
        <!-- Summary cards -->
        <div class="grid grid-cols-2 md:grid-cols-4 gap-3 mb-4">
          <div class="rounded-lg p-4 text-center cursor-pointer hover:border-red-500/50 transition-colors"
            style="background:#1a1d27; border:1px solid #2d3748;" @click="parityTab = 'missing'">
            <div class="text-2xl font-bold text-red-400">{{ fmt(parityData.summary.missing_count) }}</div>
            <div class="text-xs text-slate-400 mt-1">Missing from Unraid</div>
            <div class="text-xs text-slate-600 mt-0.5">gap scanner handles</div>
          </div>
          <div class="rounded-lg p-4 text-center cursor-pointer hover:border-blue-500/50 transition-colors"
            style="background:#1a1d27; border:1px solid #2d3748;" @click="parityTab = 'unraid_pass'">
            <div class="text-2xl font-bold text-blue-400">{{ fmt(parityData.summary.unraid_pass_count) }}</div>
            <div class="text-xs text-slate-400 mt-1">Unraid-only</div>
            <div class="text-xs text-slate-600 mt-0.5">{{ gb(parityData.summary.unraid_pass_bytes) }}</div>
          </div>
          <div class="rounded-lg p-4 text-center cursor-pointer hover:border-amber-500/50 transition-colors"
            style="background:#1a1d27; border:1px solid #2d3748;" @click="parityTab = 'unraid_filt'">
            <div class="text-2xl font-bold text-amber-400">{{ fmt(parityData.summary.unraid_filt_count) }}</div>
            <div class="text-xs text-slate-400 mt-1">Unraid-only (retired category)</div>
            <div class="text-xs text-slate-600 mt-0.5">always 0 since 2026-07-25 parity change</div>
          </div>
          <div class="rounded-lg p-4 text-center cursor-pointer hover:border-violet-500/50 transition-colors"
            style="background:#1a1d27; border:1px solid #2d3748;" @click="parityTab = 'mismatch'">
            <div class="text-2xl font-bold text-violet-400">{{ fmt(parityData.summary.mismatch_count) }}</div>
            <div class="text-xs text-slate-400 mt-1">Version Mismatch</div>
            <div class="text-xs text-slate-600 mt-0.5">
              <span class="text-green-500">{{ fmt(parityData.summary.mismatch_syn_better ?? 0) }} Syn→Unraid</span>
              · <span class="text-amber-400">{{ fmt(parityData.summary.mismatch_unraid_better ?? 0) }} Unraid→Syn</span>
            </div>
          </div>
        </div>

        <div class="text-xs text-slate-600 mb-5">
          Cached {{ parityData.cached_age_s }}s ago · Synology {{ fmt(parityData.summary.syn_total) }} eps
          vs Unraid {{ fmt(parityData.summary.unraid_total) }} eps · scan took {{ parityData.elapsed_s }}s
          <span v-if="parityData.scanning" class="text-amber-400 ml-1">· refreshing…</span>
        </div>

        <!-- Sub-tabs -->
        <div class="flex flex-wrap gap-2 mb-5">
          <button v-for="t in parityTabs" :key="t.key" @click="parityTab = t.key"
            class="px-4 py-1.5 rounded text-sm transition-colors"
            :class="parityTab === t.key ? 'bg-violet-600 text-white' : 'bg-surface-200 text-slate-400 hover:text-white'">
            {{ t.label }}
            <span v-if="t.count != null" class="ml-1 text-xs opacity-70">({{ fmt(t.count) }})</span>
          </button>
        </div>

        <!-- Missing from Unraid -->
        <template v-if="parityTab === 'missing'">
          <div class="text-xs text-slate-500 mb-3 p-3 rounded" style="background:#1a1e2e; border:1px solid #2d3748;">
            Episodes present on Synology (passing quality filter) that are absent from Unraid. The TV gap scanner (11 PM ET) queues these automatically — capped at 500 per run.
          </div>
          <div v-if="!parityData.missing_shows?.length" class="text-center py-10 text-green-400">
            No missing episodes — all syncable Synology episodes are on Unraid!
          </div>
          <div v-for="s in parityData.missing_shows" :key="s.show"
            class="mb-2 rounded-lg overflow-hidden" style="background:#1a1d27; border:1px solid #2d3748;">
            <div class="flex items-center justify-between px-4 py-2.5 cursor-pointer hover:bg-white/5"
              @click="toggleParity('miss', s.show)">
              <span class="text-white text-sm font-medium">{{ s.show }}</span>
              <div class="flex items-center gap-3">
                <span class="text-xs text-slate-500">{{ gb(s.total_bytes) }}</span>
                <span class="text-red-400 text-xs">{{ s.count }} ep{{ s.count > 1 ? 's' : '' }}</span>
                <span class="text-slate-600 text-xs">{{ expandedParity.miss.has(s.show) ? '▲' : '▼' }}</span>
              </div>
            </div>
            <div v-if="expandedParity.miss.has(s.show)" class="border-t border-surface-300 px-4 py-2 space-y-1">
              <div v-for="ep in s.episodes" :key="ep.ep"
                class="flex items-center justify-between text-xs py-1">
                <span class="text-slate-400 w-20 shrink-0 font-mono">{{ ep.ep }}</span>
                <span class="text-slate-300 truncate flex-1 mx-2">{{ ep.file }}</span>
                <span class="text-slate-500 shrink-0">{{ gb(ep.size_bytes) }}</span>
              </div>
            </div>
          </div>
        </template>

        <!-- Unraid-only -->
        <template v-else-if="parityTab === 'unraid_pass'">
          <div class="text-xs text-blue-400/80 mb-3 p-3 rounded" style="background:#0d1a2e; border:1px solid #1e3a5f;">
            These episodes are on Unraid but NOT on Synology. Most likely Sonarr imported an
            upgraded version to a different filename on Synology and the old file remains on
            Unraid. The nightly dedup will clean these up once the Synology version propagates.
            (Since the 2026-07-25 absolute-parity change, this bucket covers every quality tier —
            it's no longer split by resolution/codec.)
          </div>
          <div v-if="!parityData.unraid_only_pass?.length" class="text-center py-10 text-green-400">
            No unexpected Unraid-only episodes.
          </div>
          <div v-for="s in parityData.unraid_only_pass" :key="s.show"
            class="mb-2 rounded-lg overflow-hidden" style="background:#1a1d27; border:1px solid #2d3748;">
            <div class="flex items-center justify-between px-4 py-2.5 cursor-pointer hover:bg-white/5"
              @click="toggleParity('pass', s.show)">
              <span class="text-white text-sm font-medium">{{ s.show }}</span>
              <div class="flex items-center gap-3">
                <span class="text-xs text-slate-500">{{ gb(s.total_bytes) }}</span>
                <span class="text-blue-400 text-xs">{{ s.count }} ep{{ s.count > 1 ? 's' : '' }}</span>
                <span class="text-slate-600 text-xs">{{ expandedParity.pass.has(s.show) ? '▲' : '▼' }}</span>
              </div>
            </div>
            <div v-if="expandedParity.pass.has(s.show)" class="border-t border-surface-300 px-4 py-2 space-y-1">
              <div v-for="ep in s.episodes" :key="ep.ep"
                class="flex items-center justify-between text-xs py-1">
                <span class="text-slate-400 w-20 shrink-0 font-mono">{{ ep.ep }}</span>
                <span class="text-slate-300 truncate flex-1 mx-2">{{ ep.file }}</span>
                <span class="text-slate-500 shrink-0">{{ gb(ep.size_bytes) }}</span>
              </div>
            </div>
          </div>
        </template>

        <!-- Retired category -->
        <template v-else-if="parityTab === 'unraid_filt'">
          <div class="text-xs text-amber-400/80 mb-3 p-3 rounded" style="background:#2d1f00; border:1px solid #4a3200;">
            Retired 2026-07-25: this used to split out Unraid-only episodes that were 720p/SD/
            x265-without-HDR, back when that quality tier was excluded from sync entirely. Since
            the absolute-parity policy change, everything is "syncable," so this bucket is
            permanently empty — see the "Unraid-only" tab instead, which now covers this content
            too.
          </div>
          <div class="text-center py-10 text-green-400">
            Retired — see "Unraid-only" for this content.
          </div>
          <div v-for="s in parityData.unraid_only_filt" :key="s.show"
            class="mb-2 rounded-lg overflow-hidden" style="background:#1a1d27; border:1px solid #2d3748;">
            <div class="flex items-center justify-between px-4 py-2.5 cursor-pointer hover:bg-white/5"
              @click="toggleParity('filt', s.show)">
              <span class="text-white text-sm font-medium">{{ s.show }}</span>
              <div class="flex items-center gap-3">
                <span class="text-xs text-slate-500">{{ gb(s.total_bytes) }}</span>
                <span class="text-amber-400 text-xs">{{ s.count }} ep{{ s.count > 1 ? 's' : '' }}</span>
                <span class="text-slate-600 text-xs">{{ expandedParity.filt.has(s.show) ? '▲' : '▼' }}</span>
              </div>
            </div>
            <div v-if="expandedParity.filt.has(s.show)" class="border-t border-surface-300 px-4 py-2 space-y-1">
              <div v-for="ep in s.episodes" :key="ep.ep"
                class="flex items-center justify-between text-xs py-1">
                <span class="text-slate-400 w-20 shrink-0 font-mono">{{ ep.ep }}</span>
                <span class="text-amber-300/70 truncate flex-1 mx-2">{{ ep.file }}</span>
                <span class="text-slate-600 shrink-0 ml-2">{{ ep.filter_reason }}</span>
                <span class="text-slate-500 shrink-0 ml-2">{{ gb(ep.size_bytes) }}</span>
              </div>
            </div>
          </div>
        </template>

        <!-- Version mismatch -->
        <template v-else-if="parityTab === 'mismatch'">
          <div class="text-xs text-slate-500 mb-3 p-3 rounded" style="background:#1a1e2e; border:1px solid #2d3748;">
            Both sides have the episode but with different filenames. The bidirectional TV version reconcile (11:15 PM ET, cap {{ VERSION_SYNC_MAX }}/run)
            scores both files using TRaSH scoring — Synology-better → Syn→Unraid; Unraid-better → Unraid→Syn.
            720p/x265-no-HDR episodes on either side are skipped (Upgraderr upgrades first).
          </div>
          <div v-if="!parityData.mismatch_shows?.length" class="text-center py-10 text-green-400">
            No version mismatches — filenames match on both sides!
          </div>
          <div v-for="s in parityData.mismatch_shows" :key="s.show"
            class="mb-2 rounded-lg overflow-hidden" style="background:#1a1d27; border:1px solid #2d3748;">
            <div class="flex items-center justify-between px-4 py-2.5 cursor-pointer hover:bg-white/5"
              @click="toggleParity('mm', s.show)">
              <span class="text-white text-sm font-medium">{{ s.show }}</span>
              <div class="flex items-center gap-3">
                <span class="text-violet-400 text-xs">{{ s.count }} ep{{ s.count > 1 ? 's' : '' }}</span>
                <span class="text-slate-600 text-xs">{{ expandedParity.mm.has(s.show) ? '▲' : '▼' }}</span>
              </div>
            </div>
            <div v-if="expandedParity.mm.has(s.show)" class="border-t border-surface-300 px-4 py-2 space-y-2">
              <div v-for="ep in s.episodes" :key="ep.ep"
                class="py-1.5 border-b border-surface-300 last:border-0">
                <div class="flex items-center gap-2 mb-1">
                  <span class="font-mono text-xs text-slate-400">{{ ep.ep }}</span>
                  <span v-if="ep.syn_better" class="text-xs px-1.5 py-0.5 rounded bg-green-900/40 text-green-400">Syn better</span>
                  <span v-else class="text-xs px-1.5 py-0.5 rounded bg-amber-900/40 text-amber-400">Unraid better</span>
                </div>
                <div class="flex items-start gap-2 text-xs">
                  <span class="text-green-400 w-16 shrink-0">Synology</span>
                  <span class="text-slate-300 truncate flex-1">{{ ep.syn_file }}</span>
                  <span class="text-slate-500 shrink-0 ml-1">{{ ep.syn_score }}</span>
                </div>
                <div class="flex items-start gap-2 text-xs mt-0.5">
                  <span class="text-amber-400 w-16 shrink-0">Unraid</span>
                  <span class="text-slate-400 truncate flex-1">{{ ep.unraid_file }}</span>
                  <span class="text-slate-500 shrink-0 ml-1">{{ ep.unraid_score }}</span>
                </div>
              </div>
            </div>
          </div>
        </template>
      </template>
    </template>

    <!-- ── QUEUE TAB ──────────────────────────────────────────────────── -->
    <template v-if="library === 'Queue'">
      <div v-if="!queueData" class="text-center py-20 text-slate-500">Loading queue…</div>
      <template v-else>
        <!-- Active jobs -->
        <div v-if="queueData.active?.length" class="mb-6">
          <div class="text-xs font-semibold text-emerald-400 uppercase tracking-wider mb-3">
            Active ({{ queueData.active.length }})
          </div>
          <div class="rounded-lg overflow-hidden" style="background:#1a1d27; border:1px solid #2d3748;">
            <div v-for="job in queueData.active" :key="job.id"
              class="flex items-center gap-3 px-4 py-3 border-b border-slate-800/60 last:border-0">
              <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse flex-shrink-0"></span>
              <span class="text-emerald-300 text-xs font-medium w-36 flex-shrink-0">{{ job.quality }}</span>
              <span class="text-slate-500 text-xs w-28 flex-shrink-0">{{ job.direction }}</span>
              <div class="flex-1 min-w-0">
                <div class="text-white text-sm truncate">{{ job.title }}</div>
                <div class="text-slate-500 text-xs font-mono truncate" :title="job.filename">{{ job.filename }}</div>
              </div>
              <span v-if="job.file_size" class="text-slate-500 text-xs flex-shrink-0">{{ (job.file_size/1073741824).toFixed(1) }} GB</span>
            </div>
          </div>
        </div>

        <!-- Pending breakdown -->
        <div v-if="queueData.pending_count" class="mb-6">
          <div class="text-xs font-semibold text-amber-400 uppercase tracking-wider mb-3">
            Pending ({{ queueData.pending_count }})
          </div>
          <div class="flex flex-wrap gap-3 mb-4">
            <div v-for="(cnt, type) in queueData.pending_by_type" :key="type"
              class="rounded-lg px-4 py-3 text-center" style="background:#1a1d27; border:1px solid #2d3748; min-width:120px;">
              <div class="text-xl font-bold text-amber-300">{{ cnt }}</div>
              <div class="text-xs text-slate-400 mt-1">{{ type }}</div>
              <div class="text-xs text-slate-600 mt-0.5">{{ directionLabel(type) }}</div>
            </div>
          </div>
        </div>

        <!-- Recent jobs (last 30) -->
        <div>
          <div class="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-3">Recent (last 30)</div>
          <div class="rounded-lg overflow-hidden" style="background:#1a1d27; border:1px solid #2d3748;">
            <div v-for="job in queueData.recent" :key="job.id"
              class="flex items-center gap-3 px-4 py-2.5 border-b border-slate-800/40 last:border-0 text-sm">
              <span class="w-2 h-2 rounded-full flex-shrink-0"
                :class="{
                  'bg-emerald-400 animate-pulse': job.status === 'in_progress',
                  'bg-green-600':  job.status === 'success',
                  'bg-red-500':    job.status === 'failed',
                  'bg-amber-500':  job.status === 'pending',
                  'bg-slate-600':  job.status === 'cancelled',
                }"></span>
              <span class="text-xs font-mono w-28 flex-shrink-0"
                :class="{
                  'text-emerald-300': job.status === 'in_progress',
                  'text-green-500':   job.status === 'success',
                  'text-red-400':     job.status === 'failed',
                  'text-amber-400':   job.status === 'pending',
                  'text-slate-600':   job.status === 'cancelled',
                }">{{ job.status }}</span>
              <span class="text-slate-500 text-xs w-36 flex-shrink-0 truncate">{{ job.quality }}</span>
              <div class="flex-1 min-w-0">
                <span class="text-slate-300 truncate">{{ job.title }}</span>
                <span v-if="job.error_message" class="text-red-400 text-xs ml-2">{{ job.error_message }}</span>
              </div>
              <span class="text-slate-600 text-xs flex-shrink-0">{{ job.direction }}</span>
            </div>
          </div>
        </div>
      </template>
    </template>

    <!-- ── PIPELINE TAB ────────────────────────────────────────────────── -->
    <template v-if="library === 'Pipeline'">
      <div v-if="!pipelineData" class="text-center py-20 text-slate-500">Loading pipeline…</div>
      <template v-else>
        <!-- Upgraderr detail -->
        <div class="mb-6">
          <div class="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-3">
            Upgraderr — Quality Upgrade Queue
          </div>
          <div class="grid grid-cols-2 md:grid-cols-4 gap-3 mb-4">
            <div class="rounded-lg p-3 text-center" style="background:#1a1d27; border:1px solid #2d3748;">
              <div class="text-xl font-bold text-white">{{ pipelineData.upgraderr?.queue_total ?? '—' }}</div>
              <div class="text-xs text-slate-400 mt-1">Pending Upgrades</div>
            </div>
            <div class="rounded-lg p-3 text-center" style="background:#1a1d27; border:1px solid #2d3748;">
              <div class="text-xl font-bold text-blue-400">{{ pipelineData.upgraderr?.searches_today ?? '—' }}</div>
              <div class="text-xs text-slate-400 mt-1">Searches Today</div>
            </div>
            <div class="rounded-lg p-3 text-center" style="background:#1a1d27; border:1px solid #2d3748;">
              <div class="text-xl font-bold text-emerald-400">{{ pipelineData.upgraderr?.upgrades_today ?? '—' }}</div>
              <div class="text-xs text-slate-400 mt-1">Upgraded Today</div>
            </div>
            <div class="rounded-lg p-3 text-center" style="background:#1a1d27; border:1px solid #2d3748;">
              <div class="text-xl font-bold" :class="pipelineData.upgraderr?.paused ? 'text-amber-400' : 'text-emerald-400'">
                {{ pipelineData.upgraderr?.paused ? 'Paused' : 'Active' }}
              </div>
              <div class="text-xs text-slate-400 mt-1">Status</div>
            </div>
          </div>
          <!-- Tier breakdown -->
          <div v-if="pipelineData.upgraderr?.tier_labels" class="rounded-lg overflow-hidden" style="background:#1a1d27; border:1px solid #2d3748;">
            <div v-for="(t, tier) in pipelineData.upgraderr.tier_labels" :key="tier"
              class="flex items-center gap-3 px-4 py-2.5 border-b border-slate-800/40 last:border-0">
              <span class="text-xs font-mono text-slate-600 w-5">T{{ tier }}</span>
              <span class="text-sm text-slate-300 flex-1">{{ t.label }}</span>
              <span class="text-sm font-medium" :class="t.count > 0 ? 'text-white' : 'text-slate-700'">{{ t.count }}</span>
            </div>
          </div>
        </div>

        <!-- Download queues -->
        <div>
          <div class="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-3">
            Active Downloads — All *arr Instances ({{ pipelineData.downloads_total }})
          </div>
          <div v-if="!pipelineData.downloads?.length" class="text-slate-600 text-sm py-4">No active downloads.</div>
          <div v-else class="rounded-lg overflow-hidden" style="background:#1a1d27; border:1px solid #2d3748;">
            <div v-for="dl in pipelineData.downloads" :key="dl.title + dl.instance"
              class="flex items-center gap-3 px-4 py-3 border-b border-slate-800/40 last:border-0">
              <span class="text-xs text-blue-400 w-24 flex-shrink-0 truncate">{{ dl.instance }}</span>
              <span class="text-xs text-slate-500 w-28 flex-shrink-0">{{ dl.quality }}</span>
              <div class="flex-1 min-w-0">
                <div class="text-sm text-slate-300 truncate">{{ dl.title }}</div>
                <div class="text-xs text-slate-600">{{ (dl.size_bytes/1073741824).toFixed(1) }} GB total</div>
              </div>
              <div class="flex items-center gap-2 flex-shrink-0">
                <div class="w-24 h-1.5 rounded-full bg-slate-800 overflow-hidden">
                  <div class="h-full rounded-full transition-all"
                    :class="dl.progress >= 100 ? 'bg-emerald-500' : 'bg-blue-500'"
                    :style="{width: dl.progress + '%'}"></div>
                </div>
                <span class="text-xs text-slate-400 w-10 text-right">{{ dl.progress }}%</span>
              </div>
            </div>
          </div>
        </div>
      </template>
    </template>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import axios from 'axios'

const library = ref('Movies')
const movieTab = ref('syn_better')
const tvTab = ref('missing')
const parityTab = ref('missing')

const movieData  = ref(null)
const tvData     = ref(null)
const parityData = ref(null)
const queueData  = ref(null)
const loading    = ref(false)
const reconciling = ref(false)
const sweeping    = ref(false)
const VERSION_SYNC_MAX = 100

const pipelineData = ref(null)

const directionLabel = (type) => {
  const m = {
    'MovieReverseSync': 'Unraid → Syn', 'TVReverseSync': 'Unraid → Syn',
    'MovieVersionSync': 'Syn → Unraid', 'TVVersionSync':  'Syn → Unraid',
    'GapSync': 'Syn → Unraid', 'TVGapSync': 'Syn → Unraid',
  }
  return m[type] || 'Syn → Unraid'
}

const expandedMiss = ref(new Set())
const expandedSyn  = ref(new Set())
const expandedUnr  = ref(new Set())
const expandedParity = ref({ miss: new Set(), pass: new Set(), filt: new Set(), mm: new Set() })

const toggleShow = (type, show) => {
  const map = { miss: expandedMiss, syn: expandedSyn, unr: expandedUnr }
  const s = map[type].value
  if (s.has(show)) s.delete(show)
  else s.add(show)
  map[type].value = new Set(s)
}

const toggleParity = (type, show) => {
  const s = expandedParity.value[type]
  if (s.has(show)) s.delete(show)
  else s.add(show)
  expandedParity.value = { ...expandedParity.value, [type]: new Set(s) }
}

const fmt = n => n == null ? '—' : n.toLocaleString()
const gb = b => b ? `${(b / 1_073_741_824).toFixed(1)} GB` : '—'

const movieTabs = computed(() => [
  { key: 'missing',       label: 'Missing from Unraid',  count: movieData.value?.summary?.missing_count },
  { key: 'syn_better',    label: 'Synology Upgrade',     count: movieData.value?.summary?.syn_better_count },
  { key: 'unraid_better', label: 'Unraid Has Better',    count: movieData.value?.summary?.unraid_better_count },
  { key: 'radarr_stale',  label: 'Radarr Out of Date',   count: movieData.value?.summary?.radarr_stale_count },
])

const tvTabs = computed(() => [
  { key: 'missing',      label: 'Missing from Unraid', count: tvData.value?.summary?.missing_count },
  { key: 'syn_better',   label: 'Synology Upgrade',    count: tvData.value?.summary?.syn_better_count },
  { key: 'unraid_better',label: 'Unraid Has Better',   count: tvData.value?.summary?.unraid_better_count },
])

const parityTabs = computed(() => [
  { key: 'missing',     label: 'Missing from Unraid',    count: parityData.value?.summary?.missing_count },
  { key: 'unraid_pass', label: 'Unraid-only 1080p+',     count: parityData.value?.summary?.unraid_pass_count },
  { key: 'unraid_filt', label: 'Unraid-only 720p/x265',  count: parityData.value?.summary?.unraid_filt_count },
  { key: 'mismatch',    label: 'Version Mismatch',       count: parityData.value?.summary?.mismatch_count },
])

let pollTimer     = null
let queueTimer    = null
let pipelineTimer = null

const loadMovies = async (force = false) => {
  try {
    const r = await axios.get('/api/sync-status/movies', { params: force ? { refresh: true } : {} })
    movieData.value = r.data
    if (r.data.status === 'scanning') schedulePoll()
  } catch (e) {
    movieData.value = { status: 'error', error: e.message }
  }
}

const loadTv = async (force = false) => {
  try {
    const r = await axios.get('/api/sync-status/tv', { params: force ? { refresh: true } : {} })
    tvData.value = r.data
    if (r.data.status === 'scanning') schedulePoll()
  } catch (e) {
    tvData.value = { status: 'error', error: e.message }
  }
}

const loadParity = async (force = false) => {
  try {
    const r = await axios.get('/api/sync-status/tv-parity', { params: force ? { refresh: true } : {} })
    parityData.value = r.data
    if (r.data.status === 'scanning') schedulePoll()
  } catch (e) {
    parityData.value = { status: 'error', error: e.message }
  }
}

const loadQueue = async () => {
  try {
    const r = await axios.get('/api/sync-status/queue')
    queueData.value = r.data
  } catch (e) {
    // silently keep last good data on transient errors
  }
}

const loadPipeline = async () => {
  try {
    const r = await axios.get('/api/pipeline')
    pipelineData.value = r.data
  } catch (e) {
    // silently keep last good data
  }
}

const schedulePoll = () => {
  if (pollTimer) return
  pollTimer = setInterval(async () => {
    await Promise.all([loadMovies(), loadTv(), loadParity()])
    const allReady = [movieData, tvData, parityData].every(d => d.value?.status === 'ready')
    const allDone  = [movieData, tvData, parityData].every(d => !d.value?.scanning)
    if (allReady && allDone) { clearInterval(pollTimer); pollTimer = null; loading.value = false }
  }, 5000)
}

const refresh = async () => {
  loading.value = true
  await Promise.all([loadMovies(true), loadTv(true), loadParity(true), loadQueue(), loadPipeline()])
  schedulePoll()
}

const triggerReconcile = async () => {
  reconciling.value = true
  try {
    const r = await axios.post('/api/sync-status/reconcile?type=all')
    setTimeout(loadQueue, 2000)
    alert(`Reconcile queued: ${r.data.message || 'TV + movies started'}`)
  } catch (e) {
    alert(`Reconcile trigger failed: ${e?.response?.data?.error || e.message}`)
  } finally {
    reconciling.value = false
  }
}

const triggerSweep = async () => {
  sweeping.value = true
  try {
    await axios.post('/api/pipeline/sweep')
    setTimeout(loadPipeline, 3000)
  } catch (e) {
    alert(`Sweep trigger failed: ${e?.response?.data?.error || e.message}`)
  } finally {
    sweeping.value = false
  }
}

const setPause = async (pause) => {
  try {
    await axios.post(pause ? '/api/pipeline/pause' : '/api/pipeline/resume')
    await loadPipeline()
  } catch (e) {
    alert(`Failed: ${e?.response?.data?.error || e.message}`)
  }
}

onMounted(async () => {
  await Promise.all([loadMovies(), loadTv(), loadParity(), loadQueue(), loadPipeline()])
  const needPoll = [movieData, tvData, parityData].some(d => d.value?.status === 'scanning')
  if (needPoll) schedulePoll()
  // queue + pipeline auto-refresh: 10s for queue (active rsyncs), 30s for pipeline (downloads)
  queueTimer    = setInterval(loadQueue,    10000)
  pipelineTimer = setInterval(loadPipeline, 30000)
})

onUnmounted(() => {
  if (pollTimer)     { clearInterval(pollTimer);     pollTimer    = null }
  if (queueTimer)    { clearInterval(queueTimer);    queueTimer   = null }
  if (pipelineTimer) { clearInterval(pipelineTimer); pipelineTimer = null }
})
</script>
