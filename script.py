import re

with open('reparaciones.html', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add CSS
css = '''
    /* Historial de Notas */
    .notas-list { display:flex; flex-direction:column; gap:8px; margin-bottom:10px; }
    .notas-list:empty { display:none; }
    .nota-item { background:var(--surface); border:1px solid var(--border2); padding:8px 12px; border-radius:6px; display:flex; justify-content:space-between; align-items:flex-start; gap:10px; font-size:0.9rem; }
    .nota-text { flex:1; line-height:1.4; }
    .nota-meta { font-size:0.75rem; color:var(--muted); margin-top:4px; font-family:monospace; }
    .nota-delete { background:none; border:none; color:#ef4444; cursor:pointer; padding:4px; font-size:1rem; opacity:0.7; }
    .nota-delete:hover { opacity:1; }
    .nota-input-group { display:flex; gap:8px; }
    .nota-input-group input { flex:1; padding:8px; border-radius:6px; border:1px solid var(--border); background:var(--surface); color:var(--text); }
    .nota-input-group button { padding:8px 16px; border-radius:6px; background:var(--teal); color:#fff; border:none; cursor:pointer; font-weight:bold; }
'''
content = content.replace('/* Formulario Taller */', css + '\n    /* Formulario Taller */')

# 2. Replace Textareas
fallas_html = '''<div class="historial-notas">
            <div id="list_fallas" class="notas-list"></div>
            <div class="nota-input-group">
              <input type="text" id="input_falla" placeholder="Agregar nueva nota de falla..." onkeypress="if(event.key==='Enter') { event.preventDefault(); addNota('fallas'); }">
              <button type="button" onclick="addNota('fallas')">Agregar</button>
            </div>
          </div>'''
content = re.sub(r'<textarea id="f_fallas".*?</textarea>', fallas_html, content, flags=re.DOTALL)

trabajo_html = '''<div class="historial-notas">
            <div id="list_trabajo" class="notas-list"></div>
            <div class="nota-input-group">
              <input type="text" id="input_trabajo" placeholder="Agregar detalle de trabajo..." onkeypress="if(event.key==='Enter') { event.preventDefault(); addNota('trabajo'); }">
              <button type="button" onclick="addNota('trabajo')">Agregar</button>
            </div>
          </div>'''
content = re.sub(r'<textarea id="f_trabajo".*?</textarea>', trabajo_html, content, flags=re.DOTALL)

# 3. Add JS state and functions
js_logic = '''
  let currentFallas = [];
  let currentTrabajos = [];

  function parseNotas(val) {
    if (!val) return [];
    try {
      const parsed = JSON.parse(val);
      if (Array.isArray(parsed)) return parsed;
    } catch(e) {}
    // Backward compat
    if (String(val).trim() === '') return [];
    return [{ texto: String(val).trim(), fecha: new Date().toISOString() }];
  }

  function formatNotasPDF(arr) {
    if (!arr || arr.length === 0) return '-';
    return arr.map(x => x.texto).join('. ').replace(/\\.\\./g, '.');
  }

  function renderNotasUI(type) {
    const arr = type === 'fallas' ? currentFallas : currentTrabajos;
    const container = document.getElementById('list_' + type);
    container.innerHTML = arr.map((n, i) => {
      const d = new Date(n.fecha);
      const fechaStr = d.toLocaleDateString('es-AR', {day:'2-digit', month:'2-digit'}) + ' ' + d.toLocaleTimeString('es-AR', {hour:'2-digit', minute:'2-digit'});
      return <div class="nota-item">
        <div class="nota-text">
          <div></div>
          <div class="nota-meta"></div>
        </div>
        <button type="button" class="nota-delete" onclick="deleteNota('', )" title="Eliminar nota">🗑️</button>
      </div>;
    }).join('');
  }

  function addNota(type) {
    const input = document.getElementById('input_' + type);
    const txt = input.value.trim();
    if (!txt) return;
    const arr = type === 'fallas' ? currentFallas : currentTrabajos;
    arr.push({ texto: txt, fecha: new Date().toISOString() });
    input.value = '';
    renderNotasUI(type);
  }

  window.deleteNota = function(type, index) {
    if (!confirm('¿Estás seguro de eliminar este comentario?')) return;
    const arr = type === 'fallas' ? currentFallas : currentTrabajos;
    arr.splice(index, 1);
    renderNotasUI(type);
  };
'''
content = content.replace('let currentPayments = [];', 'let currentPayments = [];\n' + js_logic)

# 4. Modify autofill in tarifario
content = content.replace('''const txtFallas = document.getElementById('f_fallas');
      const nota = [] ;
      if (!txtFallas.value.trim()) {
        txtFallas.value = nota;
      } else {
        txtFallas.value = txtFallas.value + '\\n' + nota;
      }''', '''const nota = [] ;
      currentFallas.push({ texto: nota, fecha: new Date().toISOString() });
      renderNotasUI('fallas');''')

# 5. Modify clearDraft
content = content.replace("document.getElementById('f_fallas').value = '';", "currentFallas = []; renderNotasUI('fallas');")
content = content.replace("document.getElementById('f_trabajo').value = '';", "currentTrabajos = []; renderNotasUI('trabajo');")

# 6. Modify editRepair
content = content.replace("document.getElementById('f_fallas').value = r.fallas || '';", "currentFallas = parseNotas(r.fallas); renderNotasUI('fallas');")
content = content.replace("document.getElementById('f_trabajo').value = r.trabajo_realizado || '';", "currentTrabajos = parseNotas(r.trabajo_realizado); renderNotasUI('trabajo');")

# 7. Modify getRepairFormData
content = content.replace("fallas: document.getElementById('f_fallas').value.trim() || null,", "fallas: currentFallas.length ? JSON.stringify(currentFallas) : null,")
content = content.replace("trabajo_realizado: document.getElementById('f_trabajo').value.trim() || null,", "trabajo_realizado: currentTrabajos.length ? JSON.stringify(currentTrabajos) : null,")

# 8. Modify printPDF (replace the textContent assignments)
content = content.replace("document.getElementById('p_fallas').textContent = document.getElementById('f_fallas').value || '-';", "document.getElementById('p_fallas').textContent = formatNotasPDF(currentFallas);")
content = content.replace("document.getElementById('p_trabajo').textContent = document.getElementById('f_trabajo').value || '-';", "document.getElementById('p_trabajo').textContent = formatNotasPDF(currentTrabajos);")

with open('reparaciones.html', 'w', encoding='utf-8') as f:
    f.write(content)

print("Done")
