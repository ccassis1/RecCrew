import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

serve(async (req) => {
  const { email } = await req.json()
  const allowedDomains = [
    'delta.com', 'united.com', 'american.com',
    'jetblue.com', 'alaskaair.com', 'southwest.com'
  ]

  const domain = email?.split('@')[1]
  const isValid = domain && allowedDomains.includes(domain)

  return new Response(
    JSON.stringify({ valid: isValid }),
    { status: isValid ? 200 : 403 }
  )
})
