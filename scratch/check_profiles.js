const fetch = require('node:fetch');
const url = 'https://homlckofhxahqohpcwrd.supabase.co/rest/v1/profiles?select=*';
const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhvbWxja29maHhhaHFvaHBjd3JkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAwNTgzMTgsImV4cCI6MjA5NTYzNDMxOH0.P6m1CfcOMzy-C7RGL2Xq1_UwTiSK93KS-kzyS8qWupU';

fetch(url, {
  headers: { apikey: key, Authorization: 'Bearer ' + key }
}).then(res => res.json()).then(console.log);
