import { createClient } from "npm:@supabase/supabase-js@2";
const headers = { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type", "Access-Control-Allow-Methods": "POST, OPTIONS", "Content-Type": "application/json" };
const reply = (status: number, message: string) => new Response(JSON.stringify({message}), {status, headers});
Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", {headers});
  if (req.method !== "POST") return reply(405, "Método não permitido");
  const token = req.headers.get("Authorization")?.replace(/^Bearer\s+/i, "");
  if (!token) return reply(401, "Entre novamente para continuar");
  const admin = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, {auth:{persistSession:false,autoRefreshToken:false}});
  const {data: identity, error: authError} = await admin.auth.getUser(token);
  if (authError || !identity.user) return reply(401, "Sessão inválida");
  const {data: caller, error: profileError} = await admin.from("profiles").select("role,active").eq("id",identity.user.id).single();
  if (profileError || caller?.role !== "administrator" || !caller.active) return reply(403, "Somente o administrador pode cadastrar usuários");
  let body;
  try { body = await req.json(); } catch { return reply(400,"Dados inválidos"); }
  const {name,email,password,role} = body ?? {};
  if (typeof name !== "string" || name.trim().length < 2 || name.trim().length > 120 || typeof email !== "string" || email.length > 254 || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) || typeof password !== "string" || password.length < 8 || password.length > 128 || !["administrator","seller"].includes(role)) return reply(400,"Confira nome, e-mail, perfil e senha de 8 a 128 caracteres");
  const {data, error} = await admin.auth.admin.createUser({email:email.trim().toLowerCase(),password,email_confirm:true});
  if (error || !data.user) return reply(400,"Não foi possível criar a conta. Confira se o e-mail já está cadastrado e se a senha atende aos requisitos");
  const {error: insertError} = await admin.from("profiles").insert({id:data.user.id,full_name:name.trim(),role,active:true});
  if (insertError) {
    const {error: rollbackError} = await admin.auth.admin.deleteUser(data.user.id);
    return reply(500,rollbackError ? "Conta sem perfil. Solicite ao responsável pelo projeto a revisão no Supabase antes de tentar novamente" : "Cadastro não concluído. Tente novamente");
  }
  return reply(201,"Usuário cadastrado com sucesso");
});
