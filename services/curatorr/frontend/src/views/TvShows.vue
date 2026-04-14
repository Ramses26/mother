<template>
  <div class="flex h-screen-minus-nav" style="height:calc(100vh - 56px);">
    <!-- Filter Sidebar -->
    <div class="w-72 border-r overflow-y-auto flex-shrink-0" style="background:#1a1d27; border-color:#2d3250;">
      <div class="p-4">
        <h2 class="text-sm font-semibold text-slate-300 uppercase tracking-wider mb-3">Filters</h2>
        <!-- Presets — clicking active preset clears all filters -->
        <div class="grid grid-cols-2 gap-1.5 mb-4">
          <button v-for="p in presets" :key="p.value" @click="applyPreset(p.value)"
            class="text-xs px-2 py-1.5 rounded transition-colors"
            :class="activePreset === p.value ? 'bg-violet-600 text-white' : 'bg-surface-200 text-slate-400 hover:text-white'">
            {{ p.label }}
          </button>
        </div>
        <!-- Search -->
        <div class="mb-3">
          <input v-model="filters.title" class="input text-sm" placeholder="Search title..." @input="debouncedFetch"/>
        </div>
        <!-- Composite Score -->
        <div class="mb-3">
          <label class="label">Composite Score</label>
          <div class="flex gap-2">
            <input type="number" v-model.number="filters.composite_min" min="0" max="10" step="0.5" class="input text-xs py-1" placeholder="Min" @change="fetchShows"/>
            <input type="number" v-model.number="filters.composite_max" min="0" max="10" step="0.5" class="input text-xs py-1" placeholder="Max" @change="fetchShows"/>
          </div>
        </div>
        <!-- IMDb -->
        <div class="mb-3">
          <label class="label">IMDb Rating</label>
          <div class="flex gap-2">
            <input type="number" v-model.number="filters.imdb_min" min="0" max="10" step="0.5" class="input text-xs py-1" placeholder="Min" @change="fetchShows"/>
            <input type="number" v-model.number="filters.imdb_max" min="0" max="10" step="0.5" class="input text-xs py-1" placeholder="Max" @change="fetchShows"/>
          </div>
        </div>
        <!-- Status -->
        <div class="mb-3">
          <label class="label">Status</label>
          <select v-model="filters.status" @change="fetchShows" class="input text-sm">
            <option value="">All</option>
            <option value="Continuing">Continuing</option>
            <option value="Ended">Ended</option>
            <option value="Cancelled">Cancelled</option>
          </select>
        </div>
        <!-- Seasons -->
        <div class="mb-3">
          <label class="label">Seasons</label>
          <div class="flex gap-2">
            <input type="number" v-model.number="filters.seasons_min" min="1" class="input text-xs py-1" placeholder="Min" @change="fetchShows"/>
            <input type="number" v-model.number="filters.seasons_max" min="1" class="input text-xs py-1" placeholder="Max" @change="fetchShows"/>
          </div>
        </div>
        <!-- Watch -->
        <div class="mb-3">
          <label class="label">Watch Status</label>
          <label class="flex items-center gap-2 cursor-pointer text-sm mb-1">
            <input type="checkbox" v-model="filters.neither_watched" @change="fetchShows"/>
            <span class="text-slate-300">Neither watched</span>
          </label>
          <label class="flex items-center gap-2 cursor-pointer text-sm mb-1">
            <input type="checkbox" v-model="filters.both_watched" @change="fetchShows"/>
            <span class="text-slate-300">Both watched</span>
          </label>
          <label class="flex items-center gap-2 cursor-pointer text-sm">
            <input type="checkbox" v-model="filters.cancelled_watched" @change="fetchShows"/>
            <span class="text-slate-300">Cancelled but watched</span>
          </label>
          <label class="flex items-center gap-2 cursor-pointer text-sm mt-1">
            <input type="checkbox" v-model="filters.cancelled_never_watched" @change="fetchShows"/>
            <span class="text-slate-300">Cancelled, never watched</span>
          </label>
        </div>

        <!-- Last Watched -->
        <div class="mb-3">
          <label class="label">Last Watched (either person)</label>
          <div class="flex flex-wrap gap-1 mb-2">
            <button v-for="opt in lastWatchedOpts" :key="opt.days"
              @click="toggleEitherNotWatched(opt.days)"
              class="text-xs px-2 py-1 rounded transition-colors"
              :class="filters.either_not_watched_days === opt.days ? 'bg-violet-600 text-white' : 'bg-surface-200 text-slate-400 hover:text-white'">
              {{ opt.label }}
            </button>
          </div>
          <div class="space-y-1.5">
            <div>
              <label class="text-xs text-slate-500 mb-1 block">Ali not watched in…</label>
              <select v-model.number="filters.ali_not_watched_days" @change="fetchShows" class="input text-xs py-1">
                <option :value="null">Any</option>
                <option v-for="opt in lastWatchedOpts" :key="opt.days" :value="opt.days">{{ opt.label }}</option>
              </select>
            </div>
            <div>
              <label class="text-xs text-slate-500 mb-1 block">Chris not watched in…</label>
              <select v-model.number="filters.chris_not_watched_days" @change="fetchShows" class="input text-xs py-1">
                <option :value="null">Any</option>
                <option v-for="opt in lastWatchedOpts" :key="opt.days" :value="opt.days">{{ opt.label }}</option>
              </select>
            </div>
          </div>
        </div>

        <!-- Abandoned (watched then stopped) -->
        <div class="mb-3">
          <label class="label">Abandoned (started, then stopped)</label>
          <div class="space-y-1.5">
            <div>
              <label class="text-xs text-slate-500 mb-1 block">Ali abandoned after…</label>
              <select v-model.number="filters.ali_abandoned_days" @change="fetchShows" class="input text-xs py-1">
                <option :value="null">Any</option>
                <option v-for="opt in lastWatchedOpts" :key="opt.days" :value="opt.days">{{ opt.label }}</option>
              </select>
            </div>
            <div>
              <label class="text-xs text-slate-500 mb-1 block">Chris abandoned after…</label>
              <select v-model.number="filters.chris_abandoned_days" @change="fetchShows" class="input text-xs py-1">
                <option :value="null">Any</option>
                <option v-for="opt in lastWatchedOpts" :key="opt.days" :value="opt.days">{{ opt.label }}</option>
              </select>
            </div>
            <div>
              <label class="text-xs text-slate-500 mb-1 block">Either abandoned after…</label>
              <select v-model.number="filters.either_abandoned_days" @change="fetchShows" class="input text-xs py-1">
                <option :value="null">Any</option>
                <option v-for="opt in lastWatchedOpts" :key="opt.days" :value="opt.days">{{ opt.label }}</option>
              </select>
            </div>
          </div>
        </div>
        <!-- Purge Score -->
        <div class="mb-3">
          <label class="label">Purge Score</label>
          <div class="flex gap-2">
            <input type="number" v-model.number="filters.purge_score_min" min="0" max="100" class="input text-xs py-1" placeholder="Min" @change="fetchShows"/>
            <input type="number" v-model.number="filters.purge_score_max" min="0" max="100" class="input text-xs py-1" placeholder="Max" @change="fetchShows"/>
          </div>
        </div>

        <!-- Language -->
        <div v-if="availableLanguages.length" class="mb-3">
          <label class="label">Language</label>
          <div class="space-y-1 max-h-36 overflow-y-auto text-sm">
            <label v-for="code in availableLanguages" :key="code" class="flex items-center gap-2 cursor-pointer">
              <input type="checkbox" :value="code"
                :checked="filters.languages.includes(code)"
                @change="toggleFilter('languages', code)"
                class="rounded border-slate-600 text-violet-600"/>
              <span class="text-slate-300">{{ code }}</span>
            </label>
          </div>
        </div>

        <!-- Content Rating -->
        <div v-if="availableContentRatings.length" class="mb-3">
          <label class="label">Content Rating</label>
          <div class="flex flex-wrap gap-1">
            <button v-for="cr in availableContentRatings" :key="cr"
              @click="toggleFilter('content_ratings', cr)"
              class="text-xs px-2 py-1 rounded transition-colors"
              :class="filters.content_ratings.includes(cr) ? 'bg-violet-600 text-white' : 'bg-surface-200 text-slate-400 hover:text-white'">
              {{ cr }}
            </button>
          </div>
        </div>

        <!-- Genre -->
        <div v-if="availableGenres.length" class="mb-3">
          <label class="label">Genre</label>
          <div class="space-y-1 max-h-40 overflow-y-auto text-sm">
            <label v-for="g in (showAllGenres ? availableGenres : availableGenres.slice(0, 10))" :key="g"
              class="flex items-center gap-2 cursor-pointer">
              <input type="checkbox" :value="g"
                :checked="filters.genres.includes(g)"
                @change="toggleFilter('genres', g)"
                class="rounded border-slate-600 text-violet-600"/>
              <span class="text-slate-300">{{ g }}</span>
            </label>
          </div>
          <button v-if="availableGenres.length > 10" @click="showAllGenres = !showAllGenres"
            class="text-xs text-slate-500 hover:text-slate-300 mt-1">
            {{ showAllGenres ? 'Show less' : `+${availableGenres.length - 10} more` }}
          </button>
        </div>

        <!-- Instance -->
        <div class="mb-3">
          <label class="label">Instance</label>
          <select v-model="filters.instance" @change="fetchShows" class="input text-sm">
            <option value="">All</option>
            <option value="sonarr-hd">Sonarr HD</option>
            <option value="sonarr-4k">Sonarr 4K</option>
          </select>
        </div>
        <button @click="clearFilters" class="w-full btn-secondary text-sm mt-2">Clear</button>
        <router-link to="/tv/unwatched-seasons"
          class="w-full mt-2 block text-center text-xs py-1.5 rounded transition-colors bg-surface-200 text-slate-400 hover:text-white">
          Unwatched Seasons View →
        </router-link>
      </div>
    </div>

    <!-- Main content -->
    <div class="flex-1 overflow-y-auto">
      <!-- Toolbar -->
      <div class="sticky top-0 z-20 flex items-center gap-3 px-4 py-2 border-b" style="background:#0f1117; border-color:#2d3250;">
        <span class="text-sm text-slate-400">{{ total.toLocaleString() }} shows</span>
        <router-link to="/help#tv" class="text-slate-600 hover:text-slate-300 text-xs px-1" title="Help">?</router-link>
        <div class="flex-1"/>
        <!-- Sort: primary -->
        <select :value="sortBy" @change="sortBy = $event.target.value; fetchShows()" class="input text-xs py-1 w-28">
          <option v-for="o in sortOptions" :key="o.value" :value="o.value">{{ o.label }}</option>
        </select>
        <button @click="toggleSortDir" class="text-slate-400 hover:text-white px-1 text-sm">
          {{ sortDir === 'asc' ? '↑' : '↓' }}
        </button>
        <!-- Sort: secondary -->
        <select :value="sortBy2" @change="sortBy2 = $event.target.value; if (!sortBy2) { sortBy3 = ''; sortDir3 = 'asc' } fetchShows()" class="input text-xs py-1 w-24">
          <option value="">2nd…</option>
          <option v-for="o in sortOptions" :key="o.value" :value="o.value">{{ o.label }}</option>
        </select>
        <button v-if="sortBy2" @click="toggleSortDir2" class="text-slate-400 hover:text-white px-1 text-sm">
          {{ sortDir2 === 'asc' ? '↑' : '↓' }}
        </button>
        <!-- Sort: tertiary (visible only when secondary is set) -->
        <template v-if="sortBy2">
          <select :value="sortBy3" @change="sortBy3 = $event.target.value; fetchShows()" class="input text-xs py-1 w-24">
            <option value="">3rd…</option>
            <option v-for="o in sortOptions" :key="o.value" :value="o.value">{{ o.label }}</option>
          </select>
          <button v-if="sortBy3" @click="toggleSortDir3" class="text-slate-400 hover:text-white px-1 text-sm">
            {{ sortDir3 === 'asc' ? '↑' : '↓' }}
          </button>
        </template>

        <!-- Column visibility (table mode only) -->
        <div v-if="viewMode === 'table'" class="relative">
          <button @click="showColMenu = !showColMenu"
            class="p-1.5 rounded text-slate-400 hover:text-white hover:bg-slate-700 transition-colors"
            title="Column visibility">⚙</button>
          <div v-if="showColMenu" class="absolute right-0 top-full mt-1 z-50 rounded-lg border shadow-xl p-3 w-44"
            style="background:#1a1d27; border-color:#2d3250;">
            <div class="text-xs text-slate-400 font-semibold mb-2 uppercase tracking-wider">Columns</div>
            <label v-for="col in optionalCols" :key="col.key" class="flex items-center gap-2 cursor-pointer py-1">
              <input type="checkbox" v-model="visibleCols[col.key]" @change="saveColPrefs"
                class="rounded border-slate-600 text-violet-600"/>
              <span class="text-sm text-slate-300">{{ col.label }}</span>
            </label>
          </div>
        </div>

        <!-- View toggle -->
        <div class="flex gap-1">
          <button v-for="v in views" :key="v.value" @click="viewMode = v.value"
            class="p-1.5 rounded transition-colors"
            :class="viewMode === v.value ? 'bg-violet-600 text-white' : 'text-slate-400 hover:text-white'">
            <span class="text-sm">{{ v.icon }}</span>
          </button>
        </div>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="flex items-center justify-center py-20">
        <div class="animate-spin h-8 w-8 border-2 border-violet-500/30 border-t-violet-500 rounded-full"></div>
      </div>

      <!-- Poster Grid -->
      <div v-else-if="viewMode === 'poster'" class="grid gap-3 p-4"
        style="grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));">
        <div v-for="s in shows" :key="s.id"
          class="relative rounded-lg overflow-hidden cursor-pointer group transition-transform hover:scale-105"
          :style="{ borderLeft: `3px solid ${purgeColor(s.purge_score)}`, outline: selectedIds.has(s.id) ? '2px solid #7c3aed' : 'none' }"
          @click="openDetail(s)">
          <!-- Selection checkbox -->
          <div class="absolute top-1 left-1 z-10"
            :class="selectedIds.has(s.id) || selectedIds.size > 0 ? 'opacity-100' : 'opacity-0 group-hover:opacity-100'"
            @click.stop="toggleSelect(s.id)">
            <input type="checkbox" :checked="selectedIds.has(s.id)"
              class="w-4 h-4 rounded border-slate-600 text-violet-600 bg-black/70 cursor-pointer"
              @click.stop @change="toggleSelect(s.id)"/>
          </div>
          <div class="aspect-[2/3] relative" style="background:#1a1d27;">
            <img v-if="s.poster_url || s.plex_key"
              :src="s.poster_url || `/api/poster?url=/library/metadata/${s.plex_key}/thumb&server=chris`"
              class="w-full h-full object-cover" loading="lazy" @error="e => e.target.style.display='none'"/>
            <div class="absolute inset-0 flex items-center justify-center text-slate-600 text-xs"
              v-if="!s.poster_url && !s.plex_key">No poster</div>
            <!-- Status badge -->
            <div class="absolute top-1 right-1 px-1.5 py-0.5 rounded text-xs font-medium"
              :class="statusBadgeClass(s.status)" style="background:rgba(0,0,0,0.7)">
              {{ s.status?.charAt(0) || '?' }}
            </div>
            <!-- Hover overlay -->
            <div class="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity flex flex-col justify-end"
              style="background:linear-gradient(transparent 30%, rgba(0,0,0,0.9) 100%);">
              <div class="p-2">
                <div class="flex gap-1 justify-center mb-1">
                  <span class="text-xs px-1 py-0.5 rounded"
                    :class="s.ali_play_count > 0 ? 'bg-green-800 text-green-300' : 'bg-slate-700 text-slate-500'">
                    Ali{{ s.ali_play_count > 0 ? '✓' : '✗' }}
                  </span>
                  <span class="text-xs px-1 py-0.5 rounded"
                    :class="s.chris_play_count > 0 ? 'bg-green-800 text-green-300' : 'bg-slate-700 text-slate-500'">
                    Chris{{ s.chris_play_count > 0 ? '✓' : '✗' }}
                  </span>
                </div>
                <!-- Completion bar -->
                <div class="w-full h-1 rounded-full overflow-hidden" style="background:#2d3250;">
                  <div class="h-full rounded-full bg-violet-600"
                    :style="{ width: (s.season_completion_pct || 0) + '%' }"></div>
                </div>
              </div>
            </div>
          </div>
          <div class="p-2 text-xs text-slate-300 truncate" style="background:#1a1d27;">
            {{ s.title }}
          </div>
        </div>
      </div>

      <!-- Table -->
      <div v-else class="p-4">
        <table class="w-full text-sm">
          <thead>
            <tr class="text-left text-slate-500 border-b" style="border-color:#2d3250;">
              <th class="py-2 pr-2 w-8">
                <input type="checkbox" :checked="shows.length > 0 && shows.every(s => selectedIds.has(s.id))"
                  @change="toggleSelectAll"
                  class="rounded border-slate-600 text-violet-600"/>
              </th>
              <th class="py-2 pr-4 font-medium">Title</th>
              <th v-if="visibleCols.year" class="py-2 pr-4 font-medium">Year</th>
              <th v-if="visibleCols.network" class="py-2 pr-4 font-medium">Network</th>
              <th class="py-2 pr-4 font-medium">Status</th>
              <th class="py-2 pr-4 font-medium">Rating</th>
              <th v-if="visibleCols.imdb" class="py-2 pr-4 font-medium">IMDb</th>
              <th v-if="visibleCols.rt" class="py-2 pr-4 font-medium">RT</th>
              <th v-if="visibleCols.metacritic" class="py-2 pr-4 font-medium">MC</th>
              <th v-if="visibleCols.mdblist" class="py-2 pr-4 font-medium">MDB</th>
              <th v-if="visibleCols.seasons" class="py-2 pr-4 font-medium">Seasons</th>
              <th v-if="visibleCols.language" class="py-2 pr-4 font-medium">Language</th>
              <th v-if="visibleCols.content_rating" class="py-2 pr-4 font-medium">Rating</th>
              <th v-if="visibleCols.trakt" class="py-2 pr-4 font-medium">Trakt</th>
              <th v-if="visibleCols.ali_last_watched" class="py-2 pr-4 font-medium">Ali Watched</th>
              <th v-if="visibleCols.chris_last_watched" class="py-2 pr-4 font-medium">Chris Watched</th>
              <th v-if="visibleCols.watch_status" class="py-2 pr-4 font-medium">Watch Status</th>
              <th class="py-2 pr-4 font-medium">
                <span class="relative group cursor-help">
                  Done ❓
                  <span class="absolute left-0 top-full mt-1 z-50 hidden group-hover:block w-56
                    rounded border p-2 text-xs shadow-xl"
                    style="background:#0f1117; border-color:#2d3250; white-space:normal;">
                    <strong class="text-white">Completion %</strong><br/>
                    Episodes downloaded ÷ total episodes in the show.<br/>
                    100% = every episode on disk. Does not reflect watch status.
                  </span>
                </span>
              </th>
              <th v-if="visibleCols.watched" class="py-2 pr-4 font-medium">Watched</th>
              <th v-if="visibleCols.both" class="py-2 pr-4 font-medium">Both</th>
              <th class="py-2 font-medium">Purge</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="s in shows" :key="s.id"
              class="border-b hover:bg-surface-100 cursor-pointer transition-colors"
              :class="selectedIds.has(s.id) ? 'bg-violet-900/20' : ''"
              style="border-color:#1a1d27;"
              @click="openDetail(s)">
              <td class="py-2 pr-2" @click.stop>
                <input type="checkbox" :checked="selectedIds.has(s.id)"
                  @change="toggleSelect(s.id)"
                  class="rounded border-slate-600 text-violet-600"/>
              </td>
              <td class="py-2 pr-4">
                <div class="text-white font-medium">{{ s.title }}</div>
                <div v-if="!visibleCols.year && !visibleCols.network" class="text-xs text-slate-500">{{ s.year }}<span v-if="s.network"> · {{ s.network }}</span></div>
              </td>
              <td v-if="visibleCols.year" class="py-2 pr-4 text-slate-400 text-sm">{{ s.year || '—' }}</td>
              <td v-if="visibleCols.network" class="py-2 pr-4 text-slate-400 text-xs">{{ s.network || '—' }}</td>
              <td class="py-2 pr-4">
                <span class="px-1.5 py-0.5 rounded text-xs font-medium" :class="statusClass(s.status)">
                  {{ s.status || '?' }}
                </span>
              </td>
              <td class="py-2 pr-4">
                <span v-if="s.composite_score" class="text-violet-400 font-medium">{{ s.composite_score.toFixed(1) }}</span>
                <span v-else class="text-slate-600">—</span>
              </td>
              <td v-if="visibleCols.imdb" class="py-2 pr-4 text-slate-400 text-xs">{{ s.imdb_rating || '—' }}</td>
              <td v-if="visibleCols.rt" class="py-2 pr-4 text-slate-400 text-xs">{{ s.rt_critics != null ? s.rt_critics + '%' : '—' }}</td>
              <td v-if="visibleCols.metacritic" class="py-2 pr-4 text-slate-400 text-xs">{{ s.metacritic || '—' }}</td>
              <td v-if="visibleCols.mdblist" class="py-2 pr-4 text-slate-400 text-xs">{{ s.mdblist_score || '—' }}</td>
              <td v-if="visibleCols.seasons" class="py-2 pr-4 text-slate-400">{{ s.total_seasons }}</td>
              <td v-if="visibleCols.language" class="py-2 pr-4 text-slate-400 text-xs">{{ s.original_language || '—' }}</td>
              <td v-if="visibleCols.content_rating" class="py-2 pr-4 text-slate-400 text-xs">{{ s.content_rating || '—' }}</td>
              <td v-if="visibleCols.trakt" class="py-2 pr-4 text-slate-400 text-xs">{{ s.trakt_rating ? s.trakt_rating.toFixed(1) : '—' }}</td>
              <td v-if="visibleCols.ali_last_watched" class="py-2 pr-4 text-slate-400 text-xs">{{ fmtDate(s.ali_last_watched) }}</td>
              <td v-if="visibleCols.chris_last_watched" class="py-2 pr-4 text-slate-400 text-xs">{{ fmtDate(s.chris_last_watched) }}</td>
              <td v-if="visibleCols.watch_status" class="py-2 pr-4">
                <span class="text-xs px-1.5 py-0.5 rounded font-medium" :class="computeWatchStatus(s).cls">
                  {{ computeWatchStatus(s).label }}
                </span>
              </td>
              <td class="py-2 pr-4">
                <div class="flex items-center gap-2">
                  <div class="w-16 h-1.5 rounded-full overflow-hidden" style="background:#2d3250;">
                    <div class="h-full rounded-full bg-violet-600"
                      :style="{ width: (s.season_completion_pct || 0) + '%' }"></div>
                  </div>
                  <span class="text-xs text-slate-500">{{ s.season_completion_pct || 0 }}%</span>
                </div>
              </td>
              <td v-if="visibleCols.watched" class="py-2 pr-4 text-xs">
                <span :class="s.ali_play_count > 0 ? 'text-green-400' : 'text-slate-600'">A</span>
                <span :class="s.chris_play_count > 0 ? 'text-green-400' : 'text-slate-600'"> C</span>
              </td>
              <td v-if="visibleCols.both" class="py-2 pr-4 text-xs">
                <span v-if="s.ali_play_count > 0 && s.chris_play_count > 0" class="text-green-400">✓</span>
                <span v-else-if="s.ali_play_count > 0" class="text-blue-400">Ali</span>
                <span v-else-if="s.chris_play_count > 0" class="text-purple-400">Chris</span>
                <span v-else class="text-slate-600">—</span>
              </td>
              <td class="py-2">
                <span class="px-1.5 py-0.5 rounded text-xs font-medium" :class="purgeScoreClass(s.purge_score)">
                  {{ s.purge_score || 0 }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      <div class="flex items-center justify-between px-4 py-3 border-t" style="border-color:#2d3250;">
        <button @click="prevPage" :disabled="page === 1" class="btn-secondary text-sm px-3 py-1.5 disabled:opacity-40">Previous</button>
        <span class="text-slate-400 text-sm">Page {{ page }} of {{ pages }}</span>
        <button @click="nextPage" :disabled="page >= pages" class="btn-secondary text-sm px-3 py-1.5 disabled:opacity-40">Next</button>
      </div>
    </div>

    <!-- Detail panel -->
    <MediaDetail :item="selectedItem" @close="selectedItem = null"
      @delete="startDelete" @unmonitor="doUnmonitor"/>
    <DeleteConfirm :show="!!deleteTarget" :item="deleteTarget" :require-typing="true"
      @confirm="doDelete" @cancel="deleteTarget = null"/>

    <!-- Bulk action bar -->
    <div v-if="selectedIds.size > 0"
      class="fixed bottom-0 left-0 right-0 z-50 flex items-center gap-3 px-6 py-3 border-t shadow-2xl"
      style="background:#1a1d27; border-color:#7c3aed;">
      <span class="text-white font-medium text-sm">{{ selectedIds.size }} selected</span>
      <div class="flex-1"/>
      <button @click="doBulkUnmonitor" class="btn-secondary text-sm px-3 py-1.5">Unmonitor</button>
      <button @click="doBulkMonitor" class="btn-secondary text-sm px-3 py-1.5">Monitor</button>
      <button @click="bulkDeleteConfirm = true" class="btn-danger text-sm px-3 py-1.5">Delete</button>
      <button @click="doExportCSV" class="btn-secondary text-sm px-3 py-1.5">Export CSV</button>
      <button @click="selectedIds = new Set()" class="text-slate-400 hover:text-white text-lg leading-none px-2">✕</button>
    </div>

    <!-- Bulk delete confirmation modal -->
    <div v-if="bulkDeleteConfirm" class="fixed inset-0 z-50 flex items-center justify-center bg-black/60">
      <div class="rounded-xl border p-6 w-full max-w-sm shadow-2xl" style="background:#1a1d27; border-color:#2d3250;">
        <h3 class="text-white font-bold text-lg mb-2">Delete {{ selectedIds.size }} shows?</h3>
        <div class="text-slate-400 text-sm mb-4 space-y-1">
          <div v-for="title in bulkDeleteTitles().slice(0, 8)" :key="title">• {{ title }}</div>
          <div v-if="selectedIds.size > 8" class="text-slate-500">…and {{ selectedIds.size - 8 }} more</div>
        </div>
        <div class="flex gap-3">
          <button @click="bulkDeleteConfirm = false" class="flex-1 btn-secondary text-sm">Cancel</button>
          <button @click="doBulkDelete" class="flex-1 btn-danger text-sm">Delete {{ selectedIds.size }}</button>
        </div>
      </div>
    </div>

    <!-- Toast -->
    <div v-if="toast" class="fixed bottom-16 right-6 z-50 px-4 py-2 rounded-lg text-sm text-white shadow-xl"
      style="background:#7c3aed;">{{ toast }}</div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onBeforeUnmount } from 'vue'
import { useRoute } from 'vue-router'
import axios from 'axios'
import MediaDetail from '../components/MediaDetail.vue'
import DeleteConfirm from '../components/DeleteConfirm.vue'

const route = useRoute()
const shows = ref([])
const total = ref(0)
const page = ref(1)
const pages = ref(1)
const loading = ref(false)
const selectedItem = ref(null)
const deleteTarget = ref(null)
const viewMode = ref('table')
const sortBy = ref('sort_title')
const sortDir = ref('asc')
const sortBy2 = ref('')
const sortDir2 = ref('asc')
const sortBy3 = ref('')
const sortDir3 = ref('asc')
const activePreset = ref('')
const showColMenu = ref(false)
const selectedIds = ref(new Set())
const availableLanguages = ref([])
const availableGenres = ref([])
const availableContentRatings = ref([])
const showAllGenres = ref(false)
const bulkDeleteConfirm = ref(false)
const toast = ref('')
let toastTimer = null
let fetchTimer = null

const views = [
  { value: 'poster', icon: '⊞' },
  { value: 'table', icon: '☰' },
]

const sortOptions = [
  { value: 'sort_title', label: 'Title' },
  { value: 'year', label: 'Year' },
  { value: 'composite_score', label: 'Rating' },
  { value: 'imdb_rating', label: 'IMDb' },
  { value: 'rt_critics', label: 'RT%' },
  { value: 'metacritic', label: 'Metacritic' },
  { value: 'mdblist_score', label: 'MDBList' },
  { value: 'purge_score', label: 'Purge Score' },
  { value: 'season_completion_pct', label: 'Completion%' },
  { value: 'total_seasons', label: 'Seasons' },
  { value: 'total_episodes', label: 'Episodes' },
  { value: 'plex_added_at', label: 'Date Added' },
  { value: 'ali_play_count', label: 'Ali Plays' },
  { value: 'chris_play_count', label: 'Chris Plays' },
  { value: 'ali_last_watched', label: 'Ali Last Watched' },
  { value: 'chris_last_watched', label: 'Chris Last Watched' },
  { value: 'status', label: 'Status' },
  { value: 'network', label: 'Network' },
]

const presets = [
  { value: 'never_watched', label: 'Never Watched' },
  { value: 'continuing_unwatched', label: 'Continuing Unwatched' },
  { value: 'cancelled_watched', label: 'Cancelled + Watched' },
  { value: 'cancelled_never_watched', label: 'Cancelled, Unwatched' },
  { value: 'purge_candidates', label: 'Purge Candidates' },
  { value: 'low_rated_unwatched', label: 'Low Rated' },
]

const optionalCols = [
  { key: 'year', label: 'Year' },
  { key: 'network', label: 'Network' },
  { key: 'imdb', label: 'IMDb' },
  { key: 'rt', label: 'RT Critics' },
  { key: 'metacritic', label: 'Metacritic' },
  { key: 'mdblist', label: 'MDBList' },
  { key: 'seasons', label: 'Seasons' },
  { key: 'watched', label: 'Watched' },
  { key: 'both', label: 'Both' },
  { key: 'language', label: 'Language' },
  { key: 'content_rating', label: 'Content Rating' },
  { key: 'trakt', label: 'Trakt' },
  { key: 'ali_last_watched', label: 'Ali Watched' },
  { key: 'chris_last_watched', label: 'Chris Watched' },
  { key: 'watch_status', label: 'Watch Status' },
]

const COL_STORAGE_KEY = 'curatorr_tv_cols'
const defaultCols = { year: true, network: false, imdb: false, rt: false, metacritic: false, mdblist: false, seasons: true, watched: true, both: false,
  language: false, content_rating: false, trakt: false, ali_last_watched: false, chris_last_watched: false, watch_status: false }
const visibleCols = reactive({ ...defaultCols })

const loadColPrefs = () => {
  try {
    const saved = JSON.parse(localStorage.getItem(COL_STORAGE_KEY) || '{}')
    Object.assign(visibleCols, defaultCols, saved)
  } catch {}
}

const saveColPrefs = () => {
  localStorage.setItem(COL_STORAGE_KEY, JSON.stringify({ ...visibleCols }))
}

const filters = reactive({
  title: '', composite_min: null, composite_max: null,
  imdb_min: null, imdb_max: null, status: '',
  neither_watched: false, both_watched: false,
  cancelled_watched: false, cancelled_never_watched: false, instance: '',
  seasons_min: null, seasons_max: null,
  languages: [], genres: [], content_ratings: [],
  unwatched_only: false,
  purge_score_min: null, purge_score_max: null,
  ali_not_watched_days: null,
  chris_not_watched_days: null,
  either_not_watched_days: null,
  ali_abandoned_days: null,
  chris_abandoned_days: null,
  either_abandoned_days: null,
})

const buildParams = () => {
  const p = { page: page.value, per_page: 100, sort_by: sortBy.value, sort_dir: sortDir.value }
  if (sortBy2.value) { p.sort_by2 = sortBy2.value; p.sort_dir2 = sortDir2.value }
  if (sortBy2.value && sortBy3.value) { p.sort_by3 = sortBy3.value; p.sort_dir3 = sortDir3.value }
  if (filters.title) p.title = filters.title
  if (filters.composite_min != null) p.composite_min = filters.composite_min
  if (filters.composite_max != null) p.composite_max = filters.composite_max
  if (filters.imdb_min != null) p.imdb_min = filters.imdb_min
  if (filters.imdb_max != null) p.imdb_max = filters.imdb_max
  if (filters.status) p.status = filters.status
  if (filters.neither_watched) p.neither_watched = 'true'
  if (filters.both_watched) p.both_watched = 'true'
  if (filters.cancelled_watched) p.cancelled_watched = 'true'
  if (filters.cancelled_never_watched) p.cancelled_never_watched = 'true'
  if (filters.instance) p.instance = filters.instance
  if (filters.seasons_min != null) p.seasons_min = filters.seasons_min
  if (filters.seasons_max != null) p.seasons_max = filters.seasons_max
  if (filters.languages.length) p.language = filters.languages.join(',')
  if (filters.genres.length) p.genre = filters.genres.join(',')
  if (filters.content_ratings.length) p.content_rating = filters.content_ratings.join(',')
  if (filters.unwatched_only) p.unwatched_only = true
  if (filters.ali_not_watched_days) p.ali_not_watched_days = filters.ali_not_watched_days
  if (filters.chris_not_watched_days) p.chris_not_watched_days = filters.chris_not_watched_days
  if (filters.either_not_watched_days) p.either_not_watched_days = filters.either_not_watched_days
  if (filters.ali_abandoned_days) p.ali_abandoned_days = filters.ali_abandoned_days
  if (filters.chris_abandoned_days) p.chris_abandoned_days = filters.chris_abandoned_days
  if (filters.either_abandoned_days) p.either_abandoned_days = filters.either_abandoned_days
  if (filters.purge_score_min != null) p.purge_score_min = filters.purge_score_min
  if (filters.purge_score_max != null) p.purge_score_max = filters.purge_score_max
  return p
}

const fetchShows = async () => {
  loading.value = true
  try {
    const res = await axios.get('/api/tv', { params: buildParams() })
    shows.value = res.data.items
    total.value = res.data.total
    pages.value = res.data.pages
  } catch {} finally { loading.value = false }
}

const debouncedFetch = () => { clearTimeout(fetchTimer); fetchTimer = setTimeout(fetchShows, 400) }

const applyPreset = (preset) => {
  if (activePreset.value === preset) { clearFilters(); return }
  clearFilters()
  activePreset.value = preset
  if (preset === 'never_watched') filters.neither_watched = true
  else if (preset === 'continuing_unwatched') { filters.status = 'Continuing'; filters.unwatched_only = true }
  else if (preset === 'cancelled_watched') filters.cancelled_watched = true
  else if (preset === 'cancelled_never_watched') filters.cancelled_never_watched = true
  else if (preset === 'purge_candidates') { filters.purge_score_min = 20; sortBy.value = 'purge_score'; sortDir.value = 'desc' }
  else if (preset === 'low_rated_unwatched') { filters.composite_max = 5.0; filters.neither_watched = true }
  fetchShows()
}

const clearFilters = () => {
  Object.assign(filters, { title: '', composite_min: null, composite_max: null,
    imdb_min: null, imdb_max: null, status: '', neither_watched: false, both_watched: false,
    cancelled_watched: false, cancelled_never_watched: false, instance: '',
    seasons_min: null, seasons_max: null,
    languages: [], genres: [], content_ratings: [], unwatched_only: false,
    purge_score_min: null, purge_score_max: null,
    ali_not_watched_days: null, chris_not_watched_days: null, either_not_watched_days: null,
    ali_abandoned_days: null, chris_abandoned_days: null, either_abandoned_days: null })
  activePreset.value = ''
  sortBy.value = 'sort_title'
  sortDir.value = 'asc'
  sortBy2.value = ''
  sortDir2.value = 'asc'
  sortBy3.value = ''
  sortDir3.value = 'asc'
  page.value = 1
  fetchShows()
}

const toggleSortDir = () => { sortDir.value = sortDir.value === 'asc' ? 'desc' : 'asc'; fetchShows() }
const toggleSortDir2 = () => { sortDir2.value = sortDir2.value === 'asc' ? 'desc' : 'asc'; fetchShows() }
const toggleSortDir3 = () => { sortDir3.value = sortDir3.value === 'asc' ? 'desc' : 'asc'; fetchShows() }
const prevPage = () => { if (page.value > 1) { page.value--; fetchShows() } }
const nextPage = () => { if (page.value < pages.value) { page.value++; fetchShows() } }

const openDetail = async (s) => {
  try { const res = await axios.get(`/api/tv/${s.id}`); selectedItem.value = res.data }
  catch { selectedItem.value = s }
}

const startDelete = (item) => { deleteTarget.value = item }

const doDelete = async () => {
  if (!deleteTarget.value) return
  try {
    await axios.delete(`/api/tv/${deleteTarget.value.id}`, { data: { confirm: true } })
    selectedItem.value = null; deleteTarget.value = null; fetchShows()
  } catch { alert('Delete failed') }
}

const doUnmonitor = async (item) => {
  try { await axios.post(`/api/tv/${item.id}/unmonitor`); fetchShows() }
  catch { alert('Unmonitor failed') }
}

const statusClass = (s) => ({
  'Continuing': 'bg-green-900 text-green-300',
  'Ended': 'bg-slate-700 text-slate-300',
  'Cancelled': 'bg-red-900 text-red-300',
}[s] || 'bg-slate-700 text-slate-300')

const statusBadgeClass = (s) => ({
  'Continuing': 'text-green-400',
  'Ended': 'text-slate-400',
  'Cancelled': 'text-red-400',
}[s] || 'text-slate-400')

const purgeColor = (score) => {
  if (!score) return '#22c55e'
  if (score >= 75) return '#ef4444'
  if (score >= 55) return '#f97316'
  if (score >= 30) return '#eab308'
  return '#22c55e'
}

const purgeScoreClass = (score) => {
  if (!score) return 'bg-green-900 text-green-300'
  if (score >= 75) return 'bg-red-900 text-red-300'
  if (score >= 55) return 'bg-orange-900 text-orange-300'
  if (score >= 30) return 'bg-yellow-900 text-yellow-300'
  return 'bg-green-900 text-green-300'
}

const toggleSelect = (id) => {
  const s = new Set(selectedIds.value)
  if (s.has(id)) s.delete(id)
  else s.add(id)
  selectedIds.value = s
}

const toggleSelectAll = () => {
  const allIds = shows.value.map(s => s.id)
  const allSelected = allIds.length > 0 && allIds.every(id => selectedIds.value.has(id))
  const s = new Set(selectedIds.value)
  if (allSelected) allIds.forEach(id => s.delete(id))
  else allIds.forEach(id => s.add(id))
  selectedIds.value = s
}

const toggleFilter = (field, value) => {
  const arr = filters[field]
  const idx = arr.indexOf(value)
  if (idx >= 0) arr.splice(idx, 1)
  else arr.push(value)
  fetchShows()
}

const showToast = (msg) => {
  toast.value = msg
  clearTimeout(toastTimer)
  toastTimer = setTimeout(() => { toast.value = '' }, 4000)
}

const doBulkUnmonitor = async () => {
  const ids = [...selectedIds.value]
  try {
    const res = await axios.post('/api/tv/bulk-unmonitor', { ids })
    selectedIds.value = new Set()
    showToast(`${res.data.succeeded.length} unmonitored`)
    fetchShows()
  } catch { showToast('Unmonitor failed') }
}

const doBulkMonitor = async () => {
  const ids = [...selectedIds.value]
  try {
    const res = await axios.post('/api/tv/bulk-monitor', { ids })
    selectedIds.value = new Set()
    showToast(`${res.data.succeeded.length} monitored`)
    fetchShows()
  } catch { showToast('Monitor failed') }
}

const doBulkDelete = async () => {
  const ids = [...selectedIds.value]
  bulkDeleteConfirm.value = false
  try {
    const res = await axios.post('/api/tv/bulk-delete', { ids })
    const succeeded = res.data.succeeded || []
    const failed = res.data.failed || []
    const succeededIds = new Set(succeeded.map(s => s.id))
    shows.value = shows.value.filter(s => !succeededIds.has(s.id))
    selectedIds.value = new Set()
    showToast(failed.length > 0 ? `${succeeded.length} deleted, ${failed.length} failed` : `${succeeded.length} deleted`)
    fetchShows()
  } catch { showToast('Delete failed') }
}

const doExportCSV = () => {
  const ids = [...selectedIds.value].join(',')
  const url = ids ? `/api/tv/export?ids=${ids}` : '/api/tv/export'
  const a = document.createElement('a')
  a.href = url
  a.download = 'curatorr_tv.csv'
  a.click()
}

const lastWatchedOpts = [
  { days: 30, label: '30 days' },
  { days: 60, label: '60 days' },
  { days: 90, label: '90 days' },
  { days: 180, label: '6 months' },
  { days: 365, label: '1 year' },
  { days: 730, label: '2 years' },
]

const toggleEitherNotWatched = (days) => {
  filters.either_not_watched_days = filters.either_not_watched_days === days ? null : days
  fetchShows()
}

const fmtDate = (iso) => {
  if (!iso) return '—'
  const d = new Date(iso)
  const days = Math.floor((Date.now() - d) / 86400000)
  if (days === 0) return 'Today'
  if (days < 30) return `${days}d ago`
  if (days < 365) return `${Math.floor(days / 30)}mo ago`
  return `${Math.floor(days / 365)}y ago`
}

const computeWatchStatus = (s) => {
  const aliPlays = s.ali_play_count || 0
  const chrisPlays = s.chris_play_count || 0
  if (aliPlays === 0 && chrisPlays === 0) return { label: 'Never', cls: 'bg-slate-700 text-slate-400' }
  const lastWatched = s.ali_last_watched && s.chris_last_watched
    ? (s.ali_last_watched > s.chris_last_watched ? s.ali_last_watched : s.chris_last_watched)
    : s.ali_last_watched || s.chris_last_watched
  if (!lastWatched) return { label: 'Played', cls: 'bg-blue-900 text-blue-300' }
  const days = Math.floor((Date.now() - new Date(lastWatched)) / 86400000)
  if (days > 365) return { label: 'Abandoned', cls: 'bg-orange-900 text-orange-300' }
  if (days > 90) return { label: 'Stalled', cls: 'bg-yellow-900 text-yellow-300' }
  return { label: 'Active', cls: 'bg-green-900 text-green-300' }
}

const bulkDeleteTitles = () => {
  const ids = [...selectedIds.value]
  return shows.value.filter(s => ids.includes(s.id)).map(s => s.title)
}

const onDocClick = (e) => {
  if (!e.target.closest('.relative')) showColMenu.value = false
}

onMounted(async () => {
  loadColPrefs()
  // Apply URL query params (e.g. from Dashboard card links)
  const q = route.query
  if (q.status) filters.status = q.status
  if (q.unwatched_only === 'true') { filters.unwatched_only = true; activePreset.value = 'continuing_unwatched' }
  if (q.composite_min != null) filters.composite_min = parseFloat(q.composite_min)
  if (q.composite_max != null) filters.composite_max = parseFloat(q.composite_max)
  await fetchShows()
  document.addEventListener('click', onDocClick)
  try {
    const [langs, genres, ratings] = await Promise.all([
      axios.get('/api/tv/languages'),
      axios.get('/api/tv/genres'),
      axios.get('/api/tv/content-ratings'),
    ])
    availableLanguages.value = (langs.data || []).sort((a, b) => a.localeCompare(b))
    availableGenres.value = genres.data || []
    availableContentRatings.value = ratings.data || []
  } catch {}
})

onBeforeUnmount(() => {
  document.removeEventListener('click', onDocClick)
})
</script>
