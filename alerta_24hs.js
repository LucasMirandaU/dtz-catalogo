require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');
const axios = require('axios'); // Para enviar peticiones a la API de WhatsApp

// =========================================================================
// CONFIGURACIÓN DE SUPABASE
// =========================================================================
const supabaseUrl = 'https://homlckofhxahqohpcwrd.supabase.co';
// Usa la ANON KEY o SERVICE ROLE KEY de tu proyecto
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhvbWxja29maHhhaHFvaHBjd3JkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAwNTgzMTgsImV4cCI6MjA5NTYzNDMxOH0.P6m1CfcOMzy-C7RGL2Xq1_UwTiSK93KS-kzyS8qWupU'; 
const supabase = createClient(supabaseUrl, supabaseKey);

// =========================================================================
// CONFIGURACIÓN DE WHATSAPP (Ejemplo con UltraMsg, Meta API o n8n Webhook)
// =========================================================================
// Si usas un webhook de n8n, pon la URL aquí:
const WHATSAPP_WEBHOOK_URL = 'https://tu-n8n.com/webhook/alerta-whatsapp';

async function enviarAlertaWhatsApp(mensaje) {
  try {
    console.log('Enviando alerta a WhatsApp:\n', mensaje);
    
    // EJEMPLO DE ENVÍO A UN WEBHOOK DE N8N O API DIRECTA:
    /*
    await axios.post(WHATSAPP_WEBHOOK_URL, {
      grupo: "Técnicos DTZ",
      mensaje: mensaje
    });
    */
    
    console.log('✅ Alerta enviada con éxito');
  } catch (error) {
    console.error('❌ Error enviando WhatsApp:', error.message);
  }
}

async function verificarReparacionesDormidas() {
  console.log('🔍 Buscando reparaciones sin movimiento por más de 24hs...');
  
  // 1. Buscar todas las reparaciones que NO estén entregadas
  const { data: reparaciones, error } = await supabase
    .from('reparaciones')
    .select('id, cliente, equipo, estado, created_at, sucursal')
    .neq('estado', 'Entregado');

  if (error) {
    console.error('Error obteniendo reparaciones:', error.message);
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

    // Determinar la última fecha de modificación (si no hay log, usamos la de creación)
    let ultimaModificacion = rep.created_at;
    if (auditoria && auditoria.length > 0) {
      ultimaModificacion = auditoria[0].created_at;
    }

    const fechaUltimaMod = new Date(ultimaModificacion);

    // 3. Si pasaron más de 24 horas, la agregamos a la lista de alertas
    if (fechaUltimaMod < limite24hs) {
      const horasInactivo = Math.floor((new Date() - fechaUltimaMod) / (1000 * 60 * 60));
      alertas.push(`• *#${rep.id}* - ${rep.cliente} (${rep.equipo})\n  Estado: ${rep.estado}\n  Inactivo hace: ${horasInactivo}hs\n  Sucursal: ${rep.sucursal}`);
    }
  }

  // 4. Si hay alertas, enviar mensaje
  if (alertas.length > 0) {
    const textoMensaje = `⚠️ *ALERTA DE DEMORA EN TALLER* ⚠️\n\nLas siguientes reparaciones llevan más de 24hs sin cambios de estado y el cliente podría estar esperando:\n\n${alertas.join('\n\n')}\n\nPor favor, actualicen los estados o avisen al cliente.`;
    await enviarAlertaWhatsApp(textoMensaje);
  } else {
    console.log('✅ Todo al día. No hay reparaciones demoradas más de 24hs.');
  }
}

// Ejecutar
verificarReparacionesDormidas();
