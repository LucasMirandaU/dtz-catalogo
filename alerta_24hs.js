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
const GRUPO_ID = process.env.WHATSAPP_GRUPO_ID;

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
      type: 'none'
    }
});

// Cuando requiera escanear código QR por primera vez
client.on('qr', (qr) => {
    console.log('\n=========================================================');
    console.log('📱 ESCANEÁ ESTE CÓDIGO QR CON EL WHATSAPP DE LA EMPRESA');
    console.log('=========================================================\n');
    qrcode.generate(qr, { small: true });
});

// Listener para averiguar el ID del grupo
client.on('message', async msg => {
    if (msg.body === '!vincular') {
        console.log(`\n=========================================================`);
        console.log(`✅ ¡Mensaje '!vincular' recibido exitosamente!`);
        console.log(`El ID secreto de este grupo es:`);
        console.log(`${msg.from}`);
        console.log(`\nPor favor, agregá esta nueva línea en tu archivo .env:`);
        console.log(`WHATSAPP_GRUPO_ID="${msg.from}"`);
        console.log(`=========================================================\n`);
        await msg.reply('✅ ¡Bot vinculado! Ya tengo el ID de este grupo. Ahora ponelo en tu archivo .env y ejecutá el script de nuevo para probar la alerta.');
    }
});

client.on('ready', async () => {
    console.log('✅ ¡WhatsApp conectado exitosamente!');
    
    if (!GRUPO_ID) {
        console.log('\n⚠️ ATENCIÓN: No tenés el WHATSAPP_GRUPO_ID en tu archivo .env');
        console.log('Para averiguar el ID de tu grupo, agarrá tu celular y mandá el mensaje "!vincular" (sin comillas) adentro del grupo de los técnicos.');
        console.log('El bot está escuchando ahora mismo... (esperando tu mensaje)\n');
        return; 
    }

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
    
    console.log(`Enviando mensaje al grupo con ID "${GRUPO_ID}"...`);
    try {
        await client.sendMessage(GRUPO_ID, textoMensaje);
        console.log('✅ Mensaje de alerta enviado con éxito.');
        console.log('⏳ Esperando 5 segundos para asegurar que el mensaje salga de la computadora...');
        await new Promise(resolve => setTimeout(resolve, 5000));
    } catch (errorEnvio) {
        console.log('❌ Error al enviar el mensaje. Asegurate de haber puesto bien el WHATSAPP_GRUPO_ID.');
        console.log(errorEnvio.message);
    }
  } else {
    console.log('✅ Todo al día. No hay reparaciones demoradas más de 24hs.');
  }

  console.log('Cerrando conexión y finalizando el script. ¡Chau!');
  await client.destroy();
  process.exit(0);
}
