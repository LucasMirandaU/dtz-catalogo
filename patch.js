const fs = require('fs');
const content = fs.readFileSync('alerta_24hs.js', 'utf8');

const newFunction = `async function verificarReparacionesDormidas() {
  console.log('🔍 Buscando reparaciones sin movimiento por más de 24hs en la base de datos...');
  
  // 1. Buscar todas las reparaciones que NO estén en estados finales
  const { data: reparaciones, error } = await supabase
    .from('reparaciones')
    .select('id, cliente, equipo, estado, sucursal, fecha, fecha_ingreso')
    .neq('estado', 'Entregado')
    .neq('estado', 'Cancelado')
    .neq('estado', 'Sin Reparación / Rechazado');

  if (error) {
    console.error('Error obteniendo reparaciones:', error.message);
    process.exit(1);
    return;
  }

  const limite24hs = new Date(Date.now() - 24 * 60 * 60 * 1000); // 24 horas atrás
  const alertas = [];

  for (const rep of reparaciones) {
    // 2. Buscar el último movimiento en audit_log para esta reparación
    const { data: auditoria, error: errAud } = await supabase
      .from('audit_log')
      .select('created_at')
      .eq('entity_code', rep.id.toString())
      .order('created_at', { ascending: false })
      .limit(1);

    if (errAud) continue;

    let ultimaModificacion = rep.fecha || rep.fecha_ingreso || 0; // Usar fecha de ingreso si no hay log
    if (auditoria && auditoria.length > 0) {
      ultimaModificacion = auditoria[0].created_at;
    }

    const fechaUltimaMod = new Date(ultimaModificacion);

    // 3. Si pasaron más de 24 horas
    if (fechaUltimaMod < limite24hs) {
      const horasInactivo = Math.floor((new Date() - fechaUltimaMod) / (1000 * 60 * 60));
      
      let fechaIngresoStr = rep.fecha_ingreso || rep.fecha || 'Sin fecha';
      if (fechaIngresoStr.includes('-')) {
          const parts = fechaIngresoStr.split('T')[0].split('-');
          if (parts.length === 3) fechaIngresoStr = \`\${parts[2]}/\${parts[1]}/\${parts[0]}\`;
      }

      alertas.push({
        sucursal: rep.sucursal || 'Sin Sucursal',
        texto: \`* #\${rep.id} - \${rep.cliente} (\${rep.equipo})\\n  Fecha: \${fechaIngresoStr}\\n  Estado: \${rep.estado}\\n  Inactivo hace: \${horasInactivo}hs\\n  Sucursal: \${rep.sucursal || 'Sin Sucursal'}\`
      });
    }
  }

  // 4. Si hay alertas, agrupar por sucursal y enviar mensaje
  if (alertas.length > 0) {
    const alertasPorSucursal = {};
    for (const alerta of alertas) {
       if (!alertasPorSucursal[alerta.sucursal]) alertasPorSucursal[alerta.sucursal] = [];
       alertasPorSucursal[alerta.sucursal].push(alerta.texto);
    }

    let listaTexto = [];
    for (const sucursal of Object.keys(alertasPorSucursal).sort()) {
       listaTexto.push(\`🏢 *\${sucursal}*:\\n\` + alertasPorSucursal[sucursal].join('\\n\\n'));
    }

    const textoMensaje = \`⚠️ *ALERTA DE DEMORA EN TALLER* ⚠️\\n\\nLas siguientes reparaciones llevan más de 24hs sin cambios de estado y el cliente podría estar esperando:\\n\\n\${listaTexto.join('\\n\\n\\n')}\\n\\nPor favor, actualicen los estados o avisen al cliente.\`;
    
    console.log(\`Enviando mensaje al grupo con ID "\${GRUPO_ID}"...\`);
    try {
        await client.sendMessage(GRUPO_ID, textoMensaje);
        console.log('✅ Mensaje de alerta enviado con éxito.');
        console.log('⏳ Esperando 15 segundos para asegurar que el mensaje salga de la computadora...');
        await new Promise(resolve => setTimeout(resolve, 15000));
    } catch (errorEnvio) {
        console.log('❌ Error al enviar el mensaje. Asegurate de haber puesto bien el WHATSAPP_GRUPO_ID.');
        console.log(errorEnvio.message);
    }
  } else {
    console.log('✅ Todo al día. No hay reparaciones demoradas más de 24hs.');
    const textoMensaje = \`🎉 *¡TALLER AL DÍA!* 🎉\\n\\n¡Felicitaciones equipo! No hay ninguna reparación estancada hace más de 24hs. Todo está fluyendo de 10.\\n\\nEso sí, si están tan aburridos vayan a la calle y rómpanle el teléfono a alguna viejita o a un familiar así tenemos algo para arreglar. ¡A laburar! 📱🔨\`;
    console.log(\`Enviando felicitaciones al grupo con ID "\${GRUPO_ID}"...\`);
    try {
        await client.sendMessage(GRUPO_ID, textoMensaje);
        console.log('✅ Mensaje de felicitaciones enviado con éxito.');
        console.log('⏳ Esperando 15 segundos para asegurar que el mensaje salga de la computadora...');
        await new Promise(resolve => setTimeout(resolve, 15000));
    } catch (errorEnvio) {
        console.log('❌ Error al enviar el mensaje de felicitaciones.');
        console.log(errorEnvio.message);
    }
  }

  console.log('Cerrando conexión y finalizando el script. ¡Chau!');
  await client.destroy();
  process.exit(0);
}`;

const splitPoint = 'async function verificarReparacionesDormidas() {';
const head = content.split(splitPoint)[0];
fs.writeFileSync('alerta_24hs.js', head + newFunction);
