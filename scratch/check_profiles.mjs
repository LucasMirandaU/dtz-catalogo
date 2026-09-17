import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  'https://homlckofhxahqohpcwrd.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhvbWxja29maHhhaHFvaHBjd3JkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAwNTgzMTgsImV4cCI6MjA5NTYzNDMxOH0.P6m1CfcOMzy-C7RGL2Xq1_UwTiSK93KS-kzyS8qWupU'
);

async function check() {
  const { data, error } = await supabase.from('profiles').select('*');
  console.log(data, error);
}

check();
