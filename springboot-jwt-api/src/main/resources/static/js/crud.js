/*
 * Generic CRUD page engine.
 *
 * initCrud({
 *   title: 'Students',
 *   api: '/students',            // list/create: API+api, update/delete: API+api+'/{id}'
 *   perm: 'student',             // permission prefix -> student.create / student.update / student.delete
 *   columns: [{ key, label, render? }],
 *   fields:  [{ key, label, type: 'text'|'number'|'date'|'email'|'password'|'select'|'multiselect'|'textarea',
 *               required?, options? [{value,label}], optionsLoader? async fn, help? }],
 *   toForm?:    row => formValues        // map API row to form values
 *   toPayload?: values => requestBody    // map form values to API request body
 * })
 */
function initCrud(cfg) {
  const state = { page: 0, size: 10, search: '', total: 0 };
  const root = document.getElementById('crud');
  const canCreate = hasPerm(cfg.perm + '.create');
  const canUpdate = hasPerm(cfg.perm + '.update');
  const canDelete = hasPerm(cfg.perm + '.delete');

  root.innerHTML =
    '<div class="d-flex justify-content-between align-items-center mb-3">' +
    '<h4 class="mb-0">' + esc(cfg.title) + '</h4>' +
    (canCreate ? '<button class="btn btn-primary" id="crud-add">+ Add</button>' : '') +
    '</div>' +
    '<div class="row mb-3"><div class="col-md-4">' +
    '<input class="form-control" id="crud-search" placeholder="Search...">' +
    '</div></div>' +
    '<div class="table-responsive"><table class="table table-hover align-middle">' +
    '<thead class="table-light"><tr>' +
    cfg.columns.map(c => '<th>' + esc(c.label) + '</th>').join('') +
    ((canUpdate || canDelete) ? '<th style="width:130px">Actions</th>' : '') +
    '</tr></thead><tbody id="crud-body"></tbody></table></div>' +
    '<div class="d-flex justify-content-between align-items-center">' +
    '<small class="text-muted" id="crud-count"></small>' +
    '<nav><ul class="pagination pagination-sm mb-0" id="crud-pages"></ul></nav>' +
    '</div>' +
    modalHtml(cfg);

  const modalEl = document.getElementById('crud-modal');
  const modal = new bootstrap.Modal(modalEl);

  document.getElementById('crud-search').addEventListener('input', debounce(e => {
    state.search = e.target.value;
    state.page = 0;
    load();
  }, 350));

  if (canCreate) document.getElementById('crud-add').onclick = () => openForm(null);
  document.getElementById('crud-save').onclick = save;

  let editingId = null;

  async function load() {
    try {
      const res = await api(cfg.api + '?search=' + encodeURIComponent(state.search) +
        '&page=' + state.page + '&size=' + state.size);
      const data = res.data;
      state.total = data.totalPages;
      document.getElementById('crud-count').textContent = data.totalElements + ' record(s)';
      document.getElementById('crud-body').innerHTML = data.content.map(row => {
        const cells = cfg.columns.map(c =>
          '<td>' + (c.render ? c.render(row) : esc(row[c.key])) + '</td>').join('');
        let actions = '';
        if (canUpdate) actions += '<button class="btn btn-sm btn-outline-primary me-1" data-edit="' + row.id + '">Edit</button>';
        if (canDelete) actions += '<button class="btn btn-sm btn-outline-danger" data-del="' + row.id + '">Del</button>';
        return '<tr>' + cells + ((canUpdate || canDelete) ? '<td>' + actions + '</td>' : '') + '</tr>';
      }).join('') || '<tr><td colspan="99" class="text-center text-muted py-4">No data</td></tr>';

      document.querySelectorAll('[data-edit]').forEach(b => b.onclick = () => edit(b.dataset.edit));
      document.querySelectorAll('[data-del]').forEach(b => b.onclick = () => del(b.dataset.del));
      renderPages();
      window._crudRows = data.content;
    } catch (err) {
      toast(errorMessage(err), false);
    }
  }

  function renderPages() {
    const ul = document.getElementById('crud-pages');
    ul.innerHTML = '';
    for (let i = 0; i < state.total; i++) {
      const li = document.createElement('li');
      li.className = 'page-item' + (i === state.page ? ' active' : '');
      li.innerHTML = '<a class="page-link" href="#">' + (i + 1) + '</a>';
      li.onclick = e => { e.preventDefault(); state.page = i; load(); };
      ul.appendChild(li);
    }
  }

  async function openForm(row) {
    editingId = row ? row.id : null;
    document.getElementById('crud-modal-title').textContent = (row ? 'Edit ' : 'Add ') + cfg.title.replace(/s$/, '');
    for (const f of cfg.fields) {
      if (f.optionsLoader && !f._loaded) {
        f.options = await f.optionsLoader();
        f._loaded = true;
        const sel = document.getElementById('f-' + f.key);
        sel.innerHTML = (f.type === 'select' ? '<option value="">—</option>' : '') +
          f.options.map(o => '<option value="' + esc(o.value) + '">' + esc(o.label) + '</option>').join('');
      }
    }
    const values = row ? (cfg.toForm ? cfg.toForm(row) : row) : {};
    for (const f of cfg.fields) {
      const el = document.getElementById('f-' + f.key);
      if (f.type === 'multiselect') {
        const selected = values[f.key] || [];
        Array.from(el.options).forEach(o => o.selected = selected.includes(o.value));
      } else {
        el.value = values[f.key] == null ? '' : values[f.key];
      }
    }
    modal.show();
  }

  function edit(id) {
    const row = (window._crudRows || []).find(r => String(r.id) === String(id));
    if (row) openForm(row);
  }

  async function del(id) {
    if (!confirm('Delete this record?')) return;
    try {
      await api(cfg.api + '/' + id, { method: 'DELETE' });
      toast('Deleted');
      load();
    } catch (err) {
      toast(errorMessage(err), false);
    }
  }

  async function save() {
    const values = {};
    for (const f of cfg.fields) {
      const el = document.getElementById('f-' + f.key);
      if (f.type === 'multiselect') {
        values[f.key] = Array.from(el.selectedOptions).map(o => o.value);
      } else if (f.type === 'number') {
        values[f.key] = el.value === '' ? null : Number(el.value);
      } else {
        values[f.key] = el.value === '' ? null : el.value;
      }
    }
    const payload = cfg.toPayload ? cfg.toPayload(values, editingId) : values;
    try {
      if (editingId) {
        await api(cfg.api + '/' + editingId, { method: 'PUT', body: JSON.stringify(payload) });
      } else {
        await api(cfg.api, { method: 'POST', body: JSON.stringify(payload) });
      }
      modal.hide();
      toast('Saved');
      load();
    } catch (err) {
      toast(errorMessage(err), false);
    }
  }

  function modalHtml(cfg) {
    const inputs = cfg.fields.map(f => {
      let input;
      if (f.type === 'select' || f.type === 'multiselect') {
        const opts = (f.options || []).map(o => '<option value="' + esc(o.value) + '">' + esc(o.label) + '</option>').join('');
        input = '<select class="form-select" id="f-' + f.key + '"' + (f.type === 'multiselect' ? ' multiple size="4"' : '') + '>' +
          (f.type === 'select' ? '<option value="">—</option>' : '') + opts + '</select>';
      } else if (f.type === 'textarea') {
        input = '<textarea class="form-control" id="f-' + f.key + '" rows="2"></textarea>';
      } else {
        input = '<input class="form-control" id="f-' + f.key + '" type="' + (f.type || 'text') + '">';
      }
      return '<div class="col-md-6 mb-3"><label class="form-label">' + esc(f.label) +
        (f.required ? ' <span class="text-danger">*</span>' : '') + '</label>' + input +
        (f.help ? '<div class="form-text">' + esc(f.help) + '</div>' : '') + '</div>';
    }).join('');

    return '<div class="modal fade" id="crud-modal" tabindex="-1"><div class="modal-dialog modal-lg">' +
      '<div class="modal-content"><div class="modal-header">' +
      '<h5 class="modal-title" id="crud-modal-title"></h5>' +
      '<button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>' +
      '<div class="modal-body"><div class="row">' + inputs + '</div></div>' +
      '<div class="modal-footer"><button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>' +
      '<button class="btn btn-primary" id="crud-save">Save</button></div>' +
      '</div></div></div>';
  }

  function debounce(fn, ms) {
    let t;
    return (...args) => { clearTimeout(t); t = setTimeout(() => fn(...args), ms); };
  }

  load();
}
