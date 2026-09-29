require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');
const { Client, LocalAuth } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');

// =========================================================================
// CONFIGURACIÓN DE SUPABASE
// =========================================================================
const supabaseUrl = 'https://homlckofhxahqohpcwrd.supabase.co';
// ¡ATENCIÓN! La SERVICE ROLE KEY es un secreto que da acceso total a la base de datos.
// NUNCA la pongas directo en este archivo si lo vas a subir a GitHub.
// Tenés que crear un archivo llamado ".env" en esta misma carpeta y poner adentro:
// SUPABASE_SERVICE_KEY=tu_clave_secreta_aqui
const supabaseKey = process.env.SUPABASE_SERVICE_KEY; 
const supabase = createClient(supabaseUrl, supabaseKey);

if (!supabaseKey) {
    console.error('\n❌ ERROR CRÍTICO: No se encontró la SUPABASE_SERVICE_KEY.');
    console.error('Tenés que crear un archivo ".env" en esta carpeta y pegar adentro tu clave secreta de Supabase así:');
    console.error('SUPABASE_SERVICE_KEY=eyJhbGciOi...');
    process.exit(1);
}

// =========================================================================
// CONFIGURACIÓN DEL GRUPO DE WHATSAPP
// =========================================================================
// Poné ACÁ el nombre exacto del grupo de WhatsApp donde están los técnicos.
const NOMBRE_GRUPO = "SÓLO REPARACIONES Y PRESUPUESTOS!";

console.log('⏳ Iniciando cliente de WhatsApp...');
const client = new Client({
    authStrategy: new LocalAuth(),
    puppeteer: { 
      executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
      args: [
        '--no-sandbox', 
        '--disable-setuid-sandbox',
        '--disable-extensions',
        '--disable-gpu',
        '--disable-accelerated-2d-canvas',
        '--no-first-run',
        '--no-zygote',
        '--disable-dev-shm-usage'
      ] 
    },
    webVersionCache: {
      type: 'remote',
      remotePath: 'https://raw.githubusercontent.com/wppconnect-team/wa-version/main/html/2.2412.54.html'
    }
});

// Cuando requiera escanear código QR por primera vez
client.on('qr', (qr) => {
    console.log('\n=========================================================');
    console.log('📱 ESCANEÁ ESTE CÓDIGO QR CON EL WHATSAPP DE LA EMPRESA');
    console.log('=========================================================\n');
    qrcode.generate(qr, { small: true });
});

client.on('ready', async () => {
    console.log('✅ ¡WhatsApp conectado exitosamente!');
    console.log('⏳ Esperando 10 segundos para que WhatsApp Web sincronice los chats...');
    await new Promise(resolve => setTimeout(resolve, 10000));
    await verificarReparacionesDormidas();
});

client.on('auth_failure', msg => {
    console.error('❌ Error de autenticación en WhatsApp:', msg);
});

// Iniciamos la conexión a WhatsApp
client.initialize();

async function verificarReparacionesDormidas() {
  console.log('🔍 Buscando reparaciones sin movimiento por más de 24hs en la base de datos...');
  
  // 1. Buscar todas las reparaciones que NO estén entregadas
  const { data: reparaciones, error } = await supabase
    .from('reparaciones')
    .select('id, cliente, equipo, estado, sucursal')
    .neq('estado', 'Entregado');

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

    let ultimaModificacion = rep.fecha || 0; // Usar fecha de ingreso si no hay log
    if (auditoria && auditoria.length > 0) {
      ultimaModificacion = auditoria[0].created_at;
    }

    const fechaUltimaMod = new Date(ultimaModificacion);

    // 3. Si pasaron más de 24 horas
    if (fechaUltimaMod < limite24hs) {
      const horasInactivo = Math.floor((new Date() - fechaUltimaMod) / (1000 * 60 * 60));
      alertas.push(`• *#${rep.id}* - ${rep.cliente} (${rep.equipo})\n  Estado: ${rep.estado}\n  Inactivo hace: ${horasInactivo}hs\n  Sucursal: ${rep.sucursal}`);
    }
  }

  // 4. Si hay alertas, enviar mensaje
  if (alertas.length > 0) {
    const textoMensaje = `⚠️ *ALERTA DE DEMORA EN TALLER* ⚠️\n\nLas siguientes reparaciones llevan más de 24hs sin cambios de estado y el cliente podría estar esperando:\n\n${alertas.join('\n\n')}\n\nPor favor, actualicen los estados o avisen al cliente.`;
    
    // Buscar el grupo para enviar el mensaje
    console.log('Buscando chats...');
    const chats = await client.getChats();
    const grupo = chats.find(c => c.isGroup && c.name === NOMBRE_GRUPO);

    if (grupo) {
      console.log(`Enviando mensaje al grupo "${NOMBRE_GRUPO}"...`);
      await grupo.sendMessage(textoMensaje);
      console.log('✅ Mensaje de alerta enviado con éxito.');
    } else {
      console.log(`❌ ATENCIÓN: No se encontró un grupo de WhatsApp que se llame EXACTAMENTE "${NOMBRE_GRUPO}".`);
      console.log('Revisá si te agregaron al grupo, si el nombre tiene mayúsculas/tildes y configuralo en el script en la constante NOMBRE_GRUPO.');
      console.log('Por ahora, acá te dejo lo que hubiera enviado:');
      console.log(textoMensaje);
    }
  } else {
    console.log('✅ Todo al día. No hay reparaciones demoradas más de 24hs.');
  }

  // Desconectamos para que el script termine 
  // (es lo mejor para cuando lo ponés en Tareas Programadas, así no queda trabado)
  console.log('Cerrando conexión y finalizando el script. ¡Chau!');
  await client.destroy();
  process.exit(0);
}
