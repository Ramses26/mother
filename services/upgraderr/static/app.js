// Upgraderr — Frontend JS

// ── Stats polling ─────────────────────────────────────────────────────────

function startStatsPoll() {
  if (!document.getElementById('stat-searches')) return;
  setInterval(async () => {
    try {
      const data = await apiFetch('/api/stats');
      setText('stat-searches', data.searches_today);
      setText('stat-upgrades', data.upgrades_today);
      setText('stat-queue',    data.queue_total);
    } catch (e) { /* ignore */ }
  }, 30000);
}

// ── Pause / Resume ────────────────────────────────────────────────────────

async function togglePause(currentlyPaused) {
  const endpoint = currentlyPaused ? '/api/resume' : '/api/pause';
  const result = await apiFetch(endpoint, 'POST');
  if (result) location.reload();
}

// ── Manual sweep ──────────────────────────────────────────────────────────

async function triggerSweep() {
  const btn = document.getElementById('sweepBtn');
  if (btn) { btn.disabled = true; btn.textContent = 'Starting…'; }
  try {
    await apiFetch('/api/sweep', 'POST');
    if (btn) btn.textContent = 'Sweep started ✓';
  } catch (e) {
    if (btn) btn.textContent = 'Error';
  }
  setTimeout(() => { if (btn) { btn.disabled = false; btn.textContent = 'Run Sweep Now'; } }, 3000);
}

// ── Save settings form ────────────────────────────────────────────────────

async function saveSettings() {
  const form = document.querySelector('.container');
  if (!form) return;

  const data = {};

  // Numeric/text inputs by name
  const numericKeys = ['searches_per_hour','downloads_per_day','cooldown_hours',
                       'sweep_minutes','min_score','season_threshold','backup_schedule_hour'];
  numericKeys.forEach(name => {
    const el = document.querySelector(`[name="${name}"]`);
    if (el) data[name] = name === 'display_tz' ? el.value : parseInt(el.value, 10);
  });

  // Timezone select
  const tzEl = document.querySelector('[name="display_tz"]');
  if (tzEl) data['display_tz'] = tzEl.value;

  // Text/password fields saved as-is
  const textKeys = ['tmdb_api_key'];
  textKeys.forEach(name => {
    const el = document.querySelector(`[name="${name}"]`);
    if (el) data[name] = el.value.trim();
  });

  // Tier toggles
  for (let t = 1; t <= 6; t++) {
    const el = document.querySelector(`[name="tier_enabled_${t}"]`);
    if (el) data[`tier_enabled_${t}`] = el.checked;
  }

  // Notification toggles
  document.querySelectorAll('[name^="notify_"]').forEach(el => {
    data[el.name] = el.checked;
  });

  try {
    await apiFetch('/api/settings', 'POST', data);
    showAlert('saveAlert');
  } catch (e) {
    showError('saveError', 'Failed to save: ' + e.message);
  }
}

// ── Password change ───────────────────────────────────────────────────────

async function changePassword() {
  const current = document.getElementById('pw-current')?.value;
  const newPw   = document.getElementById('pw-new')?.value;
  const confirm = document.getElementById('pw-confirm')?.value;
  const result  = document.getElementById('pw-result');

  if (!current || !newPw || !confirm) {
    setResult(result, 'All fields required', 'error'); return;
  }
  try {
    await apiFetch('/api/password', 'POST', { current, new: newPw, confirm });
    setResult(result, '✓ Password changed', 'success');
    document.getElementById('pw-current').value = '';
    document.getElementById('pw-new').value = '';
    document.getElementById('pw-confirm').value = '';
  } catch (e) {
    setResult(result, '✗ ' + (e.message || 'Error'), 'error');
  }
}

// ── Instance management ───────────────────────────────────────────────────

async function saveInstance(name) {
  const url     = document.getElementById(`url-${name}`)?.value?.trim();
  const api_key = document.getElementById(`key-${name}`)?.value?.trim();
  const label   = document.getElementById(`label-${name}`)?.value?.trim();
  const enabled = document.getElementById(`enabled-${name}`)?.checked;

  if (!url || !api_key) { alert('URL and API key required'); return; }
  try {
    await apiFetch(`/api/instances/${name}`, 'PUT', { url, api_key, label, enabled });
    flashRow(`inst-${name}`, 'success');
  } catch (e) {
    flashRow(`inst-${name}`, 'error');
    alert('Save failed: ' + e.message);
  }
}

async function testInstance(name) {
  const btn    = document.getElementById(`test-${name}`);
  const result = document.getElementById(`test-result-${name}`);
  if (btn) btn.textContent = 'Testing…';
  try {
    const data = await apiFetch(`/api/instances/${name}/test`, 'POST');
    setResult(result, (data.ok ? '✓ ' : '✗ ') + data.message, data.ok ? 'success' : 'error');
  } catch (e) {
    setResult(result, '✗ ' + e.message, 'error');
  }
  if (btn) btn.textContent = 'Test Connection';
}

async function addInstance() {
  const name  = document.getElementById('new-name')?.value?.trim();
  const type  = document.getElementById('new-type')?.value;
  const label = document.getElementById('new-label')?.value?.trim();
  const url   = document.getElementById('new-url')?.value?.trim();
  const key   = document.getElementById('new-key')?.value?.trim();
  const res   = document.getElementById('add-result');

  if (!name || !url || !key || !label) {
    setResult(res, 'All fields required', 'error'); return;
  }
  try {
    await apiFetch('/api/instances', 'POST', { name, type, label, url, api_key: key });
    setResult(res, '✓ Instance added — reloading…', 'success');
    setTimeout(() => location.reload(), 1200);
  } catch (e) {
    setResult(res, '✗ ' + e.message, 'error');
  }
}

// ── Upgrade profile toggles ───────────────────────────────────────────────

async function checkUpgradeStatus(name) {
  const el = document.getElementById(`upgrade-status-${name}`);
  setResult(el, 'Checking…', '');
  try {
    const profiles = await apiFetch(`/api/instances/${name}/upgrades`);
    const all  = profiles.map(p => `${p.name}: ${p.upgradeAllowed ? '✓ ON' : '✗ OFF'}`).join(' | ');
    const anyOn = profiles.some(p => p.upgradeAllowed);
    setResult(el, all, anyOn ? 'success' : 'error');
  } catch (e) {
    setResult(el, '✗ ' + e.message, 'error');
  }
}

async function setUpgradesEnabled(name, enabled) {
  const action = enabled ? 'ENABLE' : 'DISABLE';
  if (!confirm(`${action} upgrades on ${name}? This changes the quality profiles in Radarr/Sonarr directly.`)) return;
  const el = document.getElementById(`upgrade-status-${name}`);
  try {
    const data = await apiFetch(`/api/instances/${name}/upgrades`, 'POST', { enabled });
    setResult(el, '✓ ' + data.message, 'success');
  } catch (e) {
    setResult(el, '✗ ' + e.message, 'error');
  }
}

async function resetQueue() {
  const res = document.getElementById('reset-result');
  if (!confirm('Clear all identified items, search history, and daily stats? This cannot be undone.')) return;
  try {
    await apiFetch('/api/reset', 'POST', { what: 'all' });
    setResult(res, '✓ Queue and history cleared', 'success');
  } catch (e) {
    setResult(res, '✗ ' + e.message, 'error');
  }
}

// ── Backup ────────────────────────────────────────────────────────────────

async function createBackupNow() {
  try {
    const data = await apiFetch('/api/backup/now', 'POST');
    alert('Backup saved: ' + data.path);
  } catch (e) {
    alert('Backup failed: ' + e.message);
  }
}

async function restoreBackup() {
  const file = document.getElementById('restoreFile')?.files[0];
  const res  = document.getElementById('restore-result');
  if (!file) { setResult(res, 'Select a .db file first', 'error'); return; }

  if (!confirm('Restore this backup? Current database will be backed up first. Container restart required after restore.')) return;

  const form = new FormData();
  form.append('file', file);
  try {
    const r = await fetch('/api/backup/restore', { method: 'POST', body: form });
    const data = await r.json();
    if (!r.ok) throw new Error(data.error || 'Restore failed');
    setResult(res, '✓ ' + data.message, 'success');
  } catch (e) {
    setResult(res, '✗ ' + e.message, 'error');
  }
}

// ── Manual queue search ───────────────────────────────────────────────────

async function searchNow(itemId) {
  const btn = event.target;
  btn.disabled = true;
  btn.textContent = 'Searching\u2026';
  try {
    await apiFetch(`/api/queue/${itemId}/search`, 'POST');
    btn.textContent = '\u2713 Sent';
    setTimeout(() => { btn.disabled = false; btn.textContent = 'Search'; }, 3000);
  } catch(e) {
    btn.textContent = '\u2717 Error';
    setTimeout(() => { btn.disabled = false; btn.textContent = 'Search'; }, 3000);
  }
}

async function resetCooldown(itemId, btn) {
  const orig = btn.textContent;
  btn.disabled = true;
  try {
    await apiFetch(`/api/queue/${itemId}/reset`, 'POST');
    btn.textContent = '\u2713';
    btn.title = 'Cooldown cleared \u2014 will search on next sweep';
    setTimeout(() => { btn.disabled = false; btn.textContent = orig; }, 3000);
  } catch(e) {
    btn.textContent = '\u2717';
    setTimeout(() => { btn.disabled = false; btn.textContent = orig; }, 3000);
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────

async function apiFetch(url, method = 'GET', body = null) {
  const opts = { method, headers: {} };
  if (body) {
    opts.headers['Content-Type'] = 'application/json';
    opts.body = JSON.stringify(body);
  }
  const r = await fetch(url, opts);
  const data = await r.json();
  if (!r.ok) throw new Error(data.error || `HTTP ${r.status}`);
  return data;
}

function setText(id, val) {
  const el = document.getElementById(id);
  if (el) el.textContent = val;
}

function showAlert(id) {
  const el = document.getElementById(id);
  if (!el) return;
  el.style.display = 'block';
  setTimeout(() => { el.style.display = 'none'; }, 3000);
}

function showError(id, msg) {
  const el = document.getElementById(id);
  if (!el) return;
  el.textContent = msg;
  el.style.display = 'block';
  setTimeout(() => { el.style.display = 'none'; }, 5000);
}

function setResult(el, msg, type) {
  if (!el) return;
  el.textContent = msg;
  el.className = `test-result result-${type === 'success' ? 'triggered' : 'error'}`;
}

function flashRow(id, type) {
  const el = document.getElementById(id);
  if (!el) return;
  el.style.outline = `2px solid ${type === 'success' ? 'var(--success)' : 'var(--danger)'}`;
  setTimeout(() => { el.style.outline = ''; }, 1500);
}

// ── Init ──────────────────────────────────────────────────────────────────

document.addEventListener('DOMContentLoaded', () => {
  startStatsPoll();
});
