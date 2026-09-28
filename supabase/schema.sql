-- ============================================================
-- ESQUEMA COMPLETO DE BASE DE DATOS SUPABASE — LA GARCÍA ZAPATERÍA
-- ============================================================

-- 1. TABLA: users (Usuarios con Nivel Administrativo: Admin / RH)
create table if not exists public.users (
  id text primary key,
  name text not null,
  email text not null unique,
  role text not null check (role in ('admin', 'rh')),
  branch_id text,
  branch_name text,
  is_active boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- 2. TABLA: branches (Sucursales de La García Zapatería)
create table if not exists public.branches (
  id text primary key,
  name text not null,
  code text not null unique,
  address text,
  city text,
  manager_name text,
  phone text,
  is_active boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- 3. TABLA: collaborators (Asesores y Vendedores en Piso)
create table if not exists public.collaborators (
  id text primary key,
  code text not null,
  full_name text not null,
  branch_id text not null,
  branch_name text,
  position text default 'Asesor de Calzado',
  is_active boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- 4. TABLA: stages (Etapas de Metodología Doble G & Embudo)
create table if not exists public.stages (
  id text primary key,
  category text not null check (category in ('dobleG', 'embudo')),
  title text not null,
  description text,
  order_index integer not null default 0,
  is_key_conversion boolean default false,
  target_seconds integer,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- 5. TABLA: visits (Auditorías y Sesiones de Supervisión RH en Piso)
create table if not exists public.visits (
  id text primary key,
  folio text not null,
  branch_id text not null,
  branch_name text,
  auditor_id text,
  auditor_name text,
  branch_manager_name text,
  start_time timestamp with time zone not null,
  end_time timestamp with time zone,
  is_completed boolean default false,
  general_notes text default '',
  groups jsonb default '[]'::jsonb,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- Habilitar Row Level Security (RLS)
alter table public.users enable row level security;
alter table public.branches enable row level security;
alter table public.collaborators enable row level security;
alter table public.stages enable row level security;
alter table public.visits enable row level security;

-- Políticas de Acceso Público / Anon para lectura y escritura desde la App
create policy "Allow all read on users" on public.users for select using (true);
create policy "Allow all write on users" on public.users for all using (true);

create policy "Allow all read on branches" on public.branches for select using (true);
create policy "Allow all write on branches" on public.branches for all using (true);

create policy "Allow all read on collaborators" on public.collaborators for select using (true);
create policy "Allow all write on collaborators" on public.collaborators for all using (true);

create policy "Allow all read on stages" on public.stages for select using (true);
create policy "Allow all write on stages" on public.stages for all using (true);

create policy "Allow all read on visits" on public.visits for select using (true);
create policy "Allow all write on visits" on public.visits for all using (true);

-- ============================================================
-- DATOS INICIALES (SEED DATA)
-- ============================================================

-- Usuarios
insert into public.users (id, name, email, role, branch_name) values
  ('user_admin_01', 'Lic. Fernando García', 'admin@lagarcia.com', 'admin', 'Dirección General'),
  ('user_rh_01', 'Mtra. Carolina Ruiz', 'rh@lagarcia.com', 'rh', 'Auditoría Corporativa')
on conflict (id) do nothing;

-- Sucursales
insert into public.branches (id, name, code, address, city, manager_name, phone) values
  ('branch_pino_suarez', 'Sucursal Centro Histórico', 'SUC-01', 'José Ma. Pino Suárez 614-A, Col. Centro', 'Villahermosa, Tabasco', 'Ing. Carlos Ramón Castillo', '993 312 4589'),
  ('branch_altabrisa', 'Sucursal Plaza Altabrisa', 'SUC-02', 'Periférico Carlos Pellicer Cámara 129, Local 42', 'Villahermosa, Tabasco', 'Lic. Mariana Valdez', '993 351 9022'),
  ('branch_cardenas', 'Sucursal Cárdenas Centro', 'SUC-03', 'Av. Juárez 302, Zona Comercial', 'H. Cárdenas, Tabasco', 'Lic. Gabriel Méndez', '937 372 1105'),
  ('branch_galerias', 'Sucursal Galerías Tabasco 2000', 'SUC-04', 'Paseo Tabasco 1405, Plaza Galerías', 'Villahermosa, Tabasco', 'Lic. Patricia Domínguez', '993 316 7744')
on conflict (id) do nothing;

-- Colaboradores
insert into public.collaborators (id, code, full_name, branch_id, branch_name, position) values
  ('collab_01', 'V1', 'Carlos Mendoza', 'branch_pino_suarez', 'Sucursal Centro Histórico', 'Asesor Especialista Damas'),
  ('collab_02', 'V2', 'Sofía Hernández', 'branch_pino_suarez', 'Sucursal Centro Histórico', 'Asesora Línea Deportiva & Confort'),
  ('collab_03', 'V3', 'Roberto Garza', 'branch_pino_suarez', 'Sucursal Centro Histórico', 'Asesor Caballeros & Vestir'),
  ('collab_04', 'V4', 'Elena Morales', 'branch_pino_suarez', 'Sucursal Centro Histórico', 'Asesora Escolar & Infantil'),
  ('collab_05', 'V1', 'Daniel Ortega', 'branch_altabrisa', 'Sucursal Plaza Altabrisa', 'Asesor Calzado General')
on conflict (id) do nothing;

-- Etapas Doble G & Embudo
insert into public.stages (id, category, title, description, order_index, is_key_conversion, target_seconds) values
  ('stage_10s_reconocimiento', 'dobleG', '10s Reconocimiento', 'Contacto visual, sonrisa y saludo de bienvenida antes de 10 segundos.', 1, false, 10),
  ('stage_atencion', 'embudo', 'Atención', 'Disposición activa y postura receptiva hacia el cliente.', 2, false, null),
  ('stage_conecta', 'dobleG', 'Conecta', 'Indagación amable del estilo, ocasión de uso y número de calzado.', 3, false, null),
  ('stage_prueba_calzado', 'embudo', 'Prueba de Calzado', 'Llevar los pares a tiempo, ofrecer calzador y verificar confort.', 4, false, null),
  ('stage_2da_opcion', 'dobleG', '2ª Opción', 'Presentar una alternativa de calzado o producto complementario.', 5, false, null),
  ('stage_compra', 'embudo', 'Compra', 'Concreción de la venta y acompañamiento entusiasta a punto de cobro.', 6, true, null),
  ('stage_experiencia_wow', 'dobleG', 'Experiencia WOW', 'Despedida memorable, entrega de bolsa y sincero agradecimiento.', 7, false, null)
on conflict (id) do nothing;
