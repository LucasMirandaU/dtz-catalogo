const fs = require('fs');
let c = fs.readFileSync('reparaciones.html', 'utf8');

c = c.replace(/let html = '<table[\s\S]*?html \+= /g, 
  "let html = '<table style=\"width:100%;border-collapse:collapse;font-size:0.8rem\">';\n" +
  "    data.forEach(log => {\n" +
  "      const d = new Date(log.created_at).toLocaleString('es-AR', {day:'2-digit',month:'2-digit',year:'numeric',hour:'2-digit',minute:'2-digit'});\n" +
  "      let actionStr = log.action_type || '';\n" +
  "      let action = actionStr.includes('NUEV') ? 'Creación' : (actionStr.includes('ACTUALI') ? 'Actualización' : (actionStr.includes('PAGO') ? 'Pago' : 'Borrado'));\n" +
  "      let color = actionStr.includes('NUEV') ? 'var(--ok)' : (actionStr.includes('ACTUALI') ? 'var(--teal)' : (actionStr.includes('PAGO') ? 'var(--warn)' : 'var(--danger)'));\n" +
  "      let details = escHtml(log.detalle || '');\n\n" +
  "      html += "
);

fs.writeFileSync('reparaciones.html', c);
