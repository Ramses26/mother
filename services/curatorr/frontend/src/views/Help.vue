<template>
  <div class="flex" style="height:calc(100vh - 56px);">
    <!-- Sticky TOC sidebar -->
    <div class="w-52 flex-shrink-0 border-r overflow-y-auto" style="background:#1a1d27; border-color:#2d3250;">
      <div class="p-4">
        <div class="text-xs text-slate-400 uppercase tracking-wider font-semibold mb-3">Contents</div>
        <nav class="space-y-1">
          <a v-for="s in sections" :key="s.id" :href="'#' + s.id"
            class="block text-sm px-2 py-1.5 rounded transition-colors hover:text-white hover:bg-surface-200"
            :class="activeSection === s.id ? 'text-violet-400 bg-surface-100' : 'text-slate-400'">
            {{ s.title }}
          </a>
        </nav>
      </div>
    </div>

    <!-- Scrollable content -->
    <div class="flex-1 overflow-y-auto" ref="scrollEl" @scroll="onScroll">
      <div class="max-w-3xl mx-auto p-8">
        <h1 class="text-3xl font-bold text-white mb-2">Curatorr Guide</h1>
        <p class="text-slate-400 mb-8">Your media intelligence dashboard for managing, scoring, and curating your library.</p>

        <!-- Overview -->
        <section id="overview" class="mb-10">
          <h2 class="text-xl font-bold text-white mb-3 border-b pb-2" style="border-color:#2d3250;">Overview</h2>
          <p class="text-slate-300 mb-3">Curatorr connects to your Radarr/Sonarr instances, Plex, and Tautulli to give you a unified view of your entire media library. It scores everything, tracks watch history, and helps you decide what to keep or delete.</p>
          <div class="grid grid-cols-2 gap-3">
            <div class="card-sm">
              <div class="text-violet-400 font-semibold mb-1">Library syncs</div>
              <div class="text-slate-400 text-sm">Every 6 hours from Radarr, Sonarr, Plex, and Tautulli. Manual sync via Dashboard → Sync Now.</div>
            </div>
            <div class="card-sm">
              <div class="text-violet-400 font-semibold mb-1">Scoring</div>
              <div class="text-slate-400 text-sm">Composite score = IMDb 35% + RT Critics 25% + MDBList 20% + Metacritic 15% + TMDB 5%. Purge score 0–100 flags deletion candidates.</div>
            </div>
          </div>
        </section>

        <!-- Movies -->
        <section id="movies" class="mb-10">
          <h2 class="text-xl font-bold text-white mb-3 border-b pb-2" style="border-color:#2d3250;">Movies</h2>
          <div class="space-y-3 text-slate-300">
            <p><strong class="text-white">Filters</strong> — use the left sidebar to filter by rating, resolution, file size, year, genre, language, watch status, and content rating. All filters stack (AND logic).</p>
            <p><strong class="text-white">Presets</strong> — quick-filter buttons at the top of the sidebar: Never Watched, Low Rated + Unwatched, Purge Candidates (purge score ≥ 70), Low Score (composite &lt; 5).</p>
            <p><strong class="text-white">Columns</strong> — click the ⚙ gear icon to toggle optional columns: IMDb, RT, Metacritic, MDBList, Trakt, Letterboxd, file size, audio, HDR, and more.</p>
            <p><strong class="text-white">Bulk actions</strong> — select rows with checkboxes, then use the action bar at the bottom: Unmonitor, Monitor, Delete, Export CSV.</p>
            <p><strong class="text-white">Delete workflow</strong> — deleting a movie calls the Radarr API to remove it and also removes the file from the Unraid NFS path. You must type the title to confirm deletion. This is irreversible.</p>
            <p><strong class="text-white">Poster view</strong> — toggle between table and poster grid with the icons in the toolbar. Hover a poster to see watch status.</p>
          </div>
        </section>

        <!-- TV Shows -->
        <section id="tv" class="mb-10">
          <h2 class="text-xl font-bold text-white mb-3 border-b pb-2" style="border-color:#2d3250;">TV Shows</h2>
          <div class="space-y-3 text-slate-300">
            <p><strong class="text-white">Presets</strong> — the preset chips in the sidebar include:</p>
            <ul class="list-disc list-inside ml-4 space-y-1 text-sm">
              <li><strong class="text-white">Never Watched</strong> — shows where neither Ali nor Chris has played any episode</li>
              <li><strong class="text-white">Continuing Unwatched</strong> — shows still airing that neither person has watched (backlog candidates)</li>
              <li><strong class="text-white">Cancelled + Watched</strong> — safe to keep as-is or delete after watching</li>
              <li><strong class="text-white">Cancelled, Unwatched</strong> — cancelled shows nobody has started</li>
              <li><strong class="text-white">Purge Candidates</strong> — purge score ≥ 70</li>
              <li><strong class="text-white">Low Rated</strong> — composite score &lt; 5, never watched</li>
            </ul>
            <p><strong class="text-white">Last Watched columns</strong> — enable "Ali Watched" and "Chris Watched" via the ⚙ gear menu to see when each person last watched the show.</p>
            <p><strong class="text-white">Instance filter</strong> — filter by Sonarr HD or Sonarr 4K instance to see which library a show lives in.</p>
            <p><strong class="text-white">Completion %</strong> — episodes downloaded ÷ total episodes. 100% = full show on disk. Does not reflect watch status.</p>
          </div>
        </section>

        <!-- Collections -->
        <section id="collections" class="mb-10">
          <h2 class="text-xl font-bold text-white mb-3 border-b pb-2" style="border-color:#2d3250;">Collections</h2>
          <div class="space-y-3 text-slate-300">
            <p>Collections are TMDB franchise groups (e.g., the Marvel Cinematic Universe, the Bourne series). Curatorr tracks which movies in each collection you own.</p>
            <p><strong class="text-white">Has Missing filter</strong> — shows only collections where at least one movie is not in your library.</p>
            <p><strong class="text-white">Completion bar</strong> — owned movies ÷ total movies in the collection.</p>
            <p><strong class="text-white">Add to Radarr</strong> — for missing movies, click "Add to Radarr" to send them to your monitored Radarr instance for searching.</p>
          </div>
        </section>

        <!-- Duplicates -->
        <section id="duplicates" class="mb-10">
          <h2 class="text-xl font-bold text-white mb-3 border-b pb-2" style="border-color:#2d3250;">Duplicates</h2>
          <div class="space-y-3 text-slate-300">
            <p>Curatorr detects movies stored in multiple quality versions (e.g., both 1080p Remux and 720p WEB-DL).</p>
            <p><strong class="text-white">Movies tab</strong> — groups duplicate movies by TMDB ID. The "best" version is highlighted; others are candidates for deletion.</p>
            <p><strong class="text-white">TV Shows tab</strong> — detects shows that appear in both the HD and 4K Sonarr instances. Useful when you've upgraded a show to 4K but the old HD copy still exists.</p>
            <p>Deleting a duplicate follows the same workflow as the Movies page: Radarr API + disk removal.</p>
          </div>
        </section>

        <!-- Rules Engine -->
        <section id="rules" class="mb-10">
          <h2 class="text-xl font-bold text-white mb-3 border-b pb-2" style="border-color:#2d3250;">Rules Engine</h2>
          <div class="space-y-3 text-slate-300">
            <p>Rules automate library maintenance. Each rule has conditions, a schedule, and an action.</p>
            <div class="grid grid-cols-2 gap-3">
              <div class="card-sm">
                <div class="text-violet-400 font-semibold mb-1">Conditions</div>
                <div class="text-slate-400 text-sm">Filter by composite score, purge score, IMDb, play count, resolution, genre, status, year, and more. Combine with AND/OR logic.</div>
              </div>
              <div class="card-sm">
                <div class="text-violet-400 font-semibold mb-1">Actions</div>
                <div class="text-slate-400 text-sm">Stage (flag for review), Unmonitor (stop searching), Notify (Telegram), or Delete (removes from arr + disk). Irreversible actions require confirmation.</div>
              </div>
              <div class="card-sm">
                <div class="text-violet-400 font-semibold mb-1">Schedule</div>
                <div class="text-slate-400 text-sm">Daily (04:00), Weekly (Sunday 04:00), or Manual. Runs automatically in the background.</div>
              </div>
              <div class="card-sm">
                <div class="text-violet-400 font-semibold mb-1">Manual run</div>
                <div class="text-slate-400 text-sm">Click "Run Now" on any rule to trigger it immediately. Results appear in the rule's match list.</div>
              </div>
            </div>
          </div>
        </section>

        <!-- Dashboard -->
        <section id="dashboard" class="mb-10">
          <h2 class="text-xl font-bold text-white mb-3 border-b pb-2" style="border-color:#2d3250;">Dashboard</h2>
          <div class="space-y-3 text-slate-300">
            <p><strong class="text-white">Stats cards</strong> — top row shows total movies, TV shows, items below 5.0 composite, movie storage, and continuing unwatched count. Click "Continuing Unwatched" to jump to those shows.</p>
            <p><strong class="text-white">Rating histogram</strong> — distribution of composite scores across your library. Click a bar to filter Movies or TV by that score range.</p>
            <p><strong class="text-white">Resolution donuts</strong> — breakdown of 4K vs 1080p vs 720p for movies, and 4K vs HD for TV shows (approximated by Sonarr instance).</p>
            <p><strong class="text-white">Codec bars</strong> — video codec (HEVC, H.264, etc.), audio codec (DTS-HD, TrueHD, etc.), and audio channel distribution for movies.</p>
            <p><strong class="text-white">Stale content table</strong> — movies with purge score ≥ 50, sorted by purge score. Toggle Ali / Chris / Combined to see plays per person. Click a row to open the movie.</p>
            <p><strong class="text-white">Purge score</strong> — 0–100 composite score of how "safe" it is to delete something. Higher = more likely a deletion candidate. Factors: low composite score, zero plays, low resolution, not monitored.</p>
          </div>
        </section>

        <!-- Settings -->
        <section id="settings" class="mb-10">
          <h2 class="text-xl font-bold text-white mb-3 border-b pb-2" style="border-color:#2d3250;">Settings</h2>
          <div class="space-y-3 text-slate-300">
            <p>Configure Radarr, Sonarr, Plex, Tautulli, and OMDB/MDBList/TMDB connections. All API keys are stored in the database and never exposed in logs.</p>
            <p><strong class="text-white">Test Connection</strong> — verifies each connection is reachable before saving.</p>
            <p><strong class="text-white">Manual sync triggers</strong> — the Dashboard "Sync Now" button triggers a full library sync from all configured sources. Individual sources can also be triggered from Settings.</p>
            <p><strong class="text-white">Backup</strong> — Curatorr's SQLite database is backed up daily at 04:30. Backups are kept for 7 days at <code class="text-violet-300">/data/backups/</code>.</p>
          </div>
        </section>

        <!-- Scoring -->
        <section id="scoring" class="mb-10">
          <h2 class="text-xl font-bold text-white mb-3 border-b pb-2" style="border-color:#2d3250;">Scoring</h2>
          <div class="space-y-4 text-slate-300">
            <div>
              <div class="text-white font-semibold mb-2">Composite Score (0–10)</div>
              <div class="font-mono text-sm text-violet-300 bg-surface-100 p-3 rounded mb-2">
                score = IMDb×0.35 + RT/10×0.25 + MDB/10×0.20 + MC/10×0.15 + TMDB/2×0.05
              </div>
              <p class="text-sm">Sources are normalized to 0–10 before weighting. Missing sources are excluded and weights redistributed proportionally.</p>
            </div>
            <div>
              <div class="text-white font-semibold mb-2">Purge Score (0–100)</div>
              <p class="text-sm mb-2">A heuristic 0–100 score indicating how safe it is to delete an item. Higher = stronger deletion candidate. Factors:</p>
              <ul class="list-disc list-inside ml-4 text-sm space-y-1">
                <li>Low composite score (≤ 4.0 → +30 pts)</li>
                <li>Never watched by either person (+25 pts)</li>
                <li>Low resolution (720p +10, SD +20)</li>
                <li>Not monitored in Radarr/Sonarr (+10 pts)</li>
                <li>Very old addition with no watches (+5 pts)</li>
              </ul>
            </div>
          </div>
        </section>

        <div class="text-slate-600 text-xs text-center pb-8">Curatorr — built for Mother</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'

const scrollEl = ref(null)
const activeSection = ref('overview')

const sections = [
  { id: 'overview', title: 'Overview' },
  { id: 'movies', title: 'Movies' },
  { id: 'tv', title: 'TV Shows' },
  { id: 'collections', title: 'Collections' },
  { id: 'duplicates', title: 'Duplicates' },
  { id: 'rules', title: 'Rules Engine' },
  { id: 'dashboard', title: 'Dashboard' },
  { id: 'settings', title: 'Settings' },
  { id: 'scoring', title: 'Scoring' },
]

const onScroll = () => {
  const el = scrollEl.value
  if (!el) return
  const scrollTop = el.scrollTop + 80
  for (const s of [...sections].reverse()) {
    const target = document.getElementById(s.id)
    if (target && target.offsetTop <= scrollTop) {
      activeSection.value = s.id
      return
    }
  }
}

onMounted(() => {
  // Scroll to hash if present
  const hash = window.location.hash?.slice(1)
  if (hash) {
    setTimeout(() => {
      const el = document.getElementById(hash)
      if (el && scrollEl.value) {
        scrollEl.value.scrollTop = el.offsetTop - 16
        activeSection.value = hash
      }
    }, 50)
  }
})
</script>
