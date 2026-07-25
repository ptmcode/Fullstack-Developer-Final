/* Shared helpers: auth, API fetch wrapper with auto-refresh, navbar, small utilities */

const API = '/api/v1';

function accessToken() { return localStorage.getItem('accessToken'); }
function refreshToken() { return localStorage.getItem('refreshToken'); }
function currentUser() { try { return JSON.parse(localStorage.getItem('user')); } catch (e) { return null; } }
function hasPerm(p) { const u = currentUser(); return !!(u && u.permissions && u.permissions.includes(p)); }

function saveSession(loginData) {
  localStorage.setItem('accessToken', loginData.accessToken);
  localStorage.setItem('refreshToken', loginData.refreshToken);
  localStorage.setItem('user', JSON.stringify(loginData.user));
}

function clearSession() {
  localStorage.removeItem('accessToken');
  localStorage.removeItem('refreshToken');
  localStorage.removeItem('user');
}

function requireAuth() {
  if (!accessToken()) location.href = 'login.html';
}

async function api(path, options = {}) {
  options.headers = Object.assign({ 'Content-Type': 'application/json' }, options.headers || {});
  if (accessToken()) options.headers['Authorization'] = 'Bearer ' + accessToken();

  let res = await fetch(API + path, options);

  if (res.status === 401 && refreshToken() && !options._retried) {
    if (await tryRefresh()) {
      options._retried = true;
      return api(path, options);
    }
    clearSession();
    location.href = 'login.html';
    return;
  }

  const body = await res.json().catch(() => null);
  if (!res.ok) throw (body || { code: 'E' + res.status, message: 'Request failed (' + res.status + ')' });
  return body;
}

async function tryRefresh() {
  try {
    const res = await fetch(API + '/auth/refresh', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refreshToken: refreshToken() })
    });
    if (!res.ok) return false;
    const body = await res.json();
    localStorage.setItem('accessToken', body.data.accessToken);
    return true;
  } catch (e) {
    return false;
  }
}

async function doLogout() {
  try { await api('/auth/logout', { method: 'POST' }); } catch (e) { /* session cleanup regardless */ }
  clearSession();
  location.href = 'login.html';
}

function esc(s) {
  return String(s == null ? '' : s)
    .replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;').replaceAll("'", '&#39;');
}

function fmtDate(s) {
  if (!s) return '';
  return String(s).replace('T', ' ').substring(0, 16);
}

function toast(message, ok = true) {
  let holder = document.getElementById('toast-holder');
  if (!holder) {
    holder = document.createElement('div');
    holder.id = 'toast-holder';
    holder.className = 'toast-container position-fixed bottom-0 end-0 p-3';
    document.body.appendChild(holder);
  }
  const el = document.createElement('div');
  el.className = 'toast align-items-center text-bg-' + (ok ? 'success' : 'danger') + ' border-0';
  el.innerHTML = '<div class="d-flex"><div class="toast-body">' + esc(message) +
    '</div><button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button></div>';
  holder.appendChild(el);
  new bootstrap.Toast(el, { delay: 3500 }).show();
  el.addEventListener('hidden.bs.toast', () => el.remove());
}

function errorMessage(err) {
  if (err && err.errors && err.errors.length) {
    return err.errors.map(e => e.field + ': ' + e.message).join('; ');
  }
  return (err && err.message) || 'Something went wrong';
}

/* Permission-aware top navbar */
function renderNavbar(active) {
  const u = currentUser() || { username: '?' };
  const links = [
    { href: 'index.html', label: 'Dashboard', perm: 'dashboard.read' },
    { href: 'students.html', label: 'Students', perm: 'student.read' },
    { href: 'teachers.html', label: 'Teachers', perm: 'teacher.read' },
    { href: 'subjects.html', label: 'Subjects', perm: 'subject.read' },
    { href: 'classes.html', label: 'Classes', perm: 'class.read' },
    { href: 'enrollments.html', label: 'Enrollments', perm: 'enrollment.read' },
    { href: 'users.html', label: 'Users', perm: 'user.read' },
    { href: 'audit.html', label: 'Audit Log', perm: 'audit.read' }
  ];
  const items = links.filter(l => hasPerm(l.perm)).map(l =>
    '<li class="nav-item"><a class="nav-link' + (active === l.href ? ' active fw-semibold' : '') +
    '" href="' + l.href + '">' + l.label + '</a></li>').join('');

  document.getElementById('navbar').innerHTML =
    '<nav class="navbar navbar-expand-lg navbar-dark bg-primary mb-4">' +
    '<div class="container-fluid">' +
    '<a class="navbar-brand" href="index.html">🏫 School Management</a>' +
    '<button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#nav"><span class="navbar-toggler-icon"></span></button>' +
    '<div class="collapse navbar-collapse" id="nav">' +
    '<ul class="navbar-nav me-auto">' + items + '</ul>' +
    '<span class="navbar-text me-3 text-white">👤 ' + esc(u.username) + '</span>' +
    '<button class="btn btn-outline-light btn-sm" onclick="doLogout()">Logout</button>' +
    '</div></div></nav>';
}
