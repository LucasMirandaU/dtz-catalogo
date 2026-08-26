const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const configContent = fs.readFileSync('config.js', 'utf8');
const supabaseUrlMatch = configContent.match(/supabaseUrl:\s*'([^']+)'/);
const supabaseKeyMatch = configContent.match(/supabaseAnonKey:\s*'([^']+)'/);

const supabase = createClient(supabaseUrlMatch[1], supabaseKeyMatch[1]);

async function test() {
  // 1. Iniciar sesion
  const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
    email: 'test@dtz.com', // wait, I don't know their email. 
  });
  
  // Actually, I can just query without login and see if it's RLS blocking it
  console.log("Intentando update como anonimo (deberia fallar por RLS):");
  const { data, error } = await supabase.from('pedidos_stock').update({ estado: 'Recibido' }).eq('id', 1);
  console.log(error);
}
test();
