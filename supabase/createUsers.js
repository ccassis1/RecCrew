// createUsers.js
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  'https://tgbuijnthcfejixufhrt.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRnYnVpam50aGNmZWppeHVmaHJ0Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0MzY5NDI5MCwiZXhwIjoyMDU5MjcwMjkwfQ.4xVyR0E0nXONi4nHLimsbV72gIKgZSQLUTOk76m_Z2I' // 🔐 Secure — don't expose in frontend
);

const usersToCreate = [
  { email: 'jane@delta.com', password: 'Pass1234!' },
  { email: 'mark@united.com', password: 'FlyHigh456!' },
];

async function createUsers() {
  for (const user of usersToCreate) {
    const { data, error } = await supabase.auth.admin.createUser({
      email: user.email,
      password: user.password,
      email_confirm: true,
    });

    if (error) {
      console.error(`Failed to create ${user.email}:`, error.message);
    } else {
      console.log(`✅ Created: ${user.email} (ID: ${data.user?.id})`);
    }
  }
}

createUsers();
