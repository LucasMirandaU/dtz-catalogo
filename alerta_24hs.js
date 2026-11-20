require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');
const { spawn } = require('child_process');
const path = require('path');

// =========================================================================
// CONFIGURACIÓN DE SUPABASE
// =========================================================================
const supabaseUrl = 'https://homlckofhxahqohpcwrd.supabase.co';
const supabaseKey = process.env.SUPABASE_SERVICE_KEY; 
const supabase = createClient(supabaseUrl, supabaseKey);

if (!supabaseKey) {
    console.error('\n❌ ERROR CRÍTICO: No se encontró la SUPABASE_SERVICE_KEY.');
    console.error('Tenés que crear un archivo ".env" en esta carpeta y poner adentro:');
    console.error('SUPABASE_SERVICE_KEY=eyJhbGciOi...');
    process.exit(1);
}

// =========================================================================
// CONFIGURACIÓN DEL BOT DE WHATSAPP (MICROSERVICIO)
// =========================================================================
const GRUPO_ID = process.env.WHATSAPP_GRUPO_ID;
const BOT_API_URL = process.env.BOT_API_URL || 'http://localhost:3005/api/enviar';

if (!GRUPO_ID) {
    console.error('\n❌ ERROR CRÍTICO: No tenés configurado el WHATSAPP_GRUPO_ID en tu archivo .env');
    process.exit(1);
}

// Asegurar que el microservicio esté encendido y conectado antes de enviar
async function asegurarBotActivo() {
    const estadoUrl = BOT_API_URL.replace('/api/enviar', '/api/estado');
    console.log('🔍 Verificando estado del microservicio de WhatsApp...');

    for (let intento = 0; intento < 2; intento++) {
        try {
            const res = await fetch(estadoUrl);
            if (res.ok) {
                const data = await res.json();
                if (data.status === 'READY') {
                    console.log(`✅ Microservicio listo y conectado como: ${data.user || 'WhatsApp'}`);
                    return true;
                }
            }
        } catch (e) {
            // El microservicio no está respondiendo
        }

        if (intento === 0) {
            console.log('⚠️ El bot de WhatsApp no está encendido. Iniciándolo automáticamente en segundo plano...');
            const botDir = path.resolve(__dirname, '../bot_whatsapp');
            
            const subprocess = spawn('node', ['index.js'], {
                cwd: botDir,
                detached: true,
                stdio: 'ignore',
                windowsHide: true
            });
            subprocess.unref();

            console.log('⏳ Aguardando a que WhatsApp conecte sesión (puede demorar unos segundos)...');
            for (let espera = 0; espera < 15; espera++) {
                await new Promise(r => setTimeout(r, 2000));
                try {
                    const res = await fetch(estadoUrl);
                    if (res.ok) {
                        const data = await res.json();
                        if (data.status === 'READY') {
                            console.log(`✅ ¡Bot iniciado y conectado exitosamente como ${data.user}!`);
                            return true;
                        }
                    }
                } catch (err) {}
            }
        }
    }

    throw new Error('No se pudo comunicar con el bot de WhatsApp tras intentar iniciarlo automáticamente.');
}

// Función para enviar mensaje a través del microservicio de WhatsApp
async function enviarAlertaPorBot(mensaje) {
    await asegurarBotActivo();
    console.log(`📤 Enviando alerta a través del microservicio (${BOT_API_URL})...`);
    console.log(`📡 Destinatario: ${GRUPO_ID}`);

    const res = await fetch(BOT_API_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            mensaje: mensaje,
            destinatariosOverride: GRUPO_ID
        })
    });

    const data = await res.json();
    if (!res.ok || !data.success) {
        throw new Error(data.error || `HTTP error ${res.status}`);
    }

    console.log(`✅ Alerta enviada con éxito a ${data.enviados} chat(s).`);
}

async function verificarReparacionesDormidas() {
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
          if (parts.length === 3) fechaIngresoStr = `${parts[2]}/${parts[1]}/${parts[0]}`;
      }

      alertas.push({
        sucursal: rep.sucursal || 'Sin Sucursal',
        texto: `* #${rep.id} - ${rep.cliente} (${rep.equipo})\n  Fecha: ${fechaIngresoStr}\n  Estado: ${rep.estado}\n  Inactivo hace: ${horasInactivo}hs\n  Sucursal: ${rep.sucursal || 'Sin Sucursal'}`
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
       listaTexto.push(`🏢 *${sucursal}*:\n` + alertasPorSucursal[sucursal].join('\n\n'));
    }

    const textoMensaje = `⚠️ *ALERTA DE DEMORA EN TALLER* ⚠️\n\nLas siguientes reparaciones llevan más de 24hs sin cambios de estado y el cliente podría estar esperando:\n\n${listaTexto.join('\n\n\n')}\n\nPor favor, actualicen los estados o avisen al cliente.`;
    
    try {
        await enviarAlertaPorBot(textoMensaje);
    } catch (errorEnvio) {
        console.error('❌ Error al enviar el mensaje de alerta:', errorEnvio.message);
        process.exit(1);
    }
  } else {
    console.log('✅ Todo al día. No hay reparaciones demoradas más de 24hs.');
    const textoMensaje = `🎉 *¡TALLER AL DÍA!* 🎉\n\n¡Felicitaciones equipo! No hay ninguna reparación estancada hace más de 24hs. Todo está fluyendo de 10.\n\nEso sí, si están tan aburridos vayan a la calle y rómpanle el teléfono a alguna viejita o a un familiar así tenemos algo para arreglar. ¡A laburar! 📱🔨`;
    
    try {
        await enviarAlertaPorBot(textoMensaje);
    } catch (errorEnvio) {
        console.error('❌ Error al enviar el mensaje de felicitaciones:', errorEnvio.message);
        process.exit(1);
    }
  }

  console.log('🏁 Proceso finalizado correctamente.');
  process.exit(0);
}

// Iniciar verificación
verificarReparacionesDormidas();
