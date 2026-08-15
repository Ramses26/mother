// Sync Webhook UI

function showToast(msg, type = 'info') {
  const el = document.getElementById('toast');
  if (!el) return;
  el.textContent = msg;
  el.className = `toast toast-${type}`;
  el.style.display = 'block';
  setTimeout(() => { el.style.display = 'none'; }, 4000);
}

async function apiFetch(url, method = 'GET', body = null) {
  const opts = { method, headers: { 'Content-Type': 'application/json' } };
  if (body) opts.body = JSON.stringify(body);
  const res = await fetch(url, opts);
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
  return data;
}

async function retryJob(id, btn) {
  btn.disabled = true;
  btn.textContent = '…';
  try {
    await apiFetch(`/jobs/${id}/retry`, 'POST');
    showToast('Retry queued ✓', 'success');
    setTimeout(() => location.reload(), 1500);
  } catch (e) {
    showToast(`Error: ${e.message}`, 'error');
    btn.disabled = false;
    btn.textContent = '↺ Retry';
  }
}

async function retryAllFailed(btn) {
  btn.disabled = true;
  btn.textContent = 'Queuing…';
  try {
    const data = await apiFetch('/queue/retry-failed', 'POST');
    if (data.count > 0) {
      showToast(`${data.count} job(s) queued for retry ✓`, 'success');
    } else {
      // 0 is not an error — usually every recent failure already recovered on its own.
      showToast(data.message || 'Nothing to retry.', 'info');
    }
    setTimeout(() => location.reload(), 1800);
  } catch (e) {
    showToast(`Error: ${e.message}`, 'error');
    btn.disabled = false;
    btn.textContent = 'Retry All Failed';
  }
}

async function cancelJob(id, btn) {
  if (!confirm('Cancel this pending sync? The item can be re-queued later via retry or a new webhook.')) return;
  btn.disabled = true;
  btn.textContent = '…';
  try {
    await apiFetch(`/jobs/${id}/cancel`, 'POST');
    showToast('Job cancelled ✓', 'success');
    setTimeout(() => location.reload(), 1200);
  } catch (e) {
    showToast(`Error: ${e.message}`, 'error');
    btn.disabled = false;
    btn.textContent = '✕ Cancel';
  }
}

async function triggerHistoryScan(btn) {
  btn.disabled = true;
  btn.textContent = 'Running…';
  try {
    await apiFetch('/api/history-scan/trigger', 'POST');
    showToast('History scan triggered — check back in ~30s for any newly queued items', 'info');
    setTimeout(() => {
      btn.disabled = false;
      btn.textContent = 'Run Now';
      pollScheduler();
    }, 30000);
  } catch (e) {
    showToast(`Error: ${e.message}`, 'error');
    btn.disabled = false;
    btn.textContent = 'Run Now';
  }
}

async function pollScheduler() {
  try {
    const data = await apiFetch('/api/scheduler');
    const hs = data.history_scanner;
    const nextEl = document.getElementById('hs-next');
    if (nextEl && hs.next_run) {
      nextEl.textContent = hs.next_run.split(' ')[1]; // time part only
    }
  } catch (e) { /* ignore */ }
}

// Poll scheduler info every 60s to keep next-run time fresh
if (document.getElementById('hs-next')) {
  setInterval(pollScheduler, 60000);
}

async function rushJob(id, btn) {
  btn.disabled = true;
  btn.textContent = '⚡…';
  try {
    const data = await apiFetch(`/jobs/${id}/rush`, 'POST');
    showToast(data.message || 'Extra sync slot opened — job should start shortly ⚡', 'info');
    setTimeout(() => location.reload(), 2000);
  } catch (e) {
    showToast(`Error: ${e.message}`, 'error');
    btn.disabled = false;
    btn.textContent = '⚡ Rush';
  }
}

// ── Bulk cancel ──────────────────────────────────────────────────────────────

function toggleSelectAll(master) {
  document.querySelectorAll('.row-check').forEach(cb => { cb.checked = master.checked; });
  updateSelectionUI();
}

function updateSelectionUI() {
  const checked = document.querySelectorAll('.row-check:checked');
  const infoEl = document.getElementById('selection-info');
  const btnEl  = document.getElementById('btn-cancel-selected');
  const master = document.getElementById('select-all');

  if (checked.length > 0) {
    infoEl.textContent = `${checked.length} selected`;
    infoEl.style.display = 'inline';
    btnEl.style.display  = 'inline-block';
  } else {
    infoEl.style.display = 'none';
    btnEl.style.display  = 'none';
  }

  // Sync master checkbox indeterminate state
  const all = document.querySelectorAll('.row-check');
  if (master) {
    master.indeterminate = checked.length > 0 && checked.length < all.length;
    master.checked = all.length > 0 && checked.length === all.length;
  }
}

async function cancelAllMatching(btn) {
  const total  = btn.dataset.total;
  const status = btn.dataset.status;
  const type   = btn.dataset.type;
  const q      = btn.dataset.q;
  if (!confirm(`Cancel ALL ${total} matching job(s)? This cannot be undone.`)) return;
  btn.disabled = true;
  btn.textContent = 'Cancelling…';
  try {
    const data = await apiFetch('/jobs/cancel-matching', 'POST', { status, type, q });
    showToast(`${data.cancelled} job(s) cancelled ✓`, 'success');
    setTimeout(() => location.reload(), 1500);
  } catch (e) {
    showToast(`Error: ${e.message}`, 'error');
    btn.disabled = false;
    btn.textContent = `✕ Cancel All ${total} Matching`;
  }
}

async function cancelSelected(btn) {
  const ids = Array.from(document.querySelectorAll('.row-check:checked')).map(cb => parseInt(cb.value));
  if (!ids.length) return;
  if (!confirm(`Cancel ${ids.length} selected job(s)? They will stop auto-retrying.`)) return;

  btn.disabled = true;
  btn.textContent = 'Cancelling…';
  try {
    const data = await apiFetch('/jobs/bulk-cancel', 'POST', { ids });
    showToast(`${data.cancelled} job(s) cancelled ✓`, 'success');
    setTimeout(() => location.reload(), 1500);
  } catch (e) {
    showToast(`Error: ${e.message}`, 'error');
    btn.disabled = false;
    btn.textContent = '✕ Cancel Selected';
  }
}
