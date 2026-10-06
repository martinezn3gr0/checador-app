-- Checador Express: multi-company attendance schema
create extension if not exists pgcrypto;

create table if not exists public.empresas (
  id uuid primary key default gen_random_uuid(),
  codigo text not null unique,
  nombre text not null,
  activa boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.empleados (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  codigo text not null,
  nombre text not null,
  departamento text not null default '',
  pin_hash text not null,
  activo boolean not null default true,
  created_at timestamptz not null default now(),
  unique (empresa_id, codigo)
);

create table if not exists public.administradores (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  usuario text not null,
  nombre text not null,
  pin_hash text not null,
  activo boolean not null default true,
  created_at timestamptz not null default now(),
  unique (empresa_id, usuario)
);

create table if not exists public.obras (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  nombre text not null,
  lat double precision,
  lng double precision,
  radio_metros integer not null default 150,
  activa boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.empleado_obras (
  empleado_id uuid not null references public.empleados(id) on delete cascade,
  obra_id uuid not null references public.obras(id) on delete cascade,
  primary key (empleado_id, obra_id)
);

create table if not exists public.checadas (
  id uuid primary key default gen_random_uuid(),
  empleado_id uuid not null references public.empleados(id) on delete cascade,
  obra_id uuid references public.obras(id) on delete set null,
  tipo text not null check (tipo in ('entrada', 'salida')),
  registrado_at timestamptz not null default now(),
  fecha date generated always as ((registrado_at at time zone 'UTC')::date) stored,
  lat double precision,
  lng double precision,
  distancia_metros double precision,
  notas text
);

create index if not exists checadas_empleado_at_idx on public.checadas (empleado_id, registrado_at desc);
create index if not exists checadas_fecha_idx on public.checadas (fecha);

alter table public.empresas enable row level security;
alter table public.empleados enable row level security;
alter table public.administradores enable row level security;
alter table public.obras enable row level security;
alter table public.empleado_obras enable row level security;
alter table public.checadas enable row level security;

revoke all on public.empresas from anon, authenticated;
revoke all on public.empleados from anon, authenticated;
revoke all on public.administradores from anon, authenticated;
revoke all on public.obras from anon, authenticated;
revoke all on public.empleado_obras from anon, authenticated;
revoke all on public.checadas from anon, authenticated;
grant usage on schema public to anon, authenticated;
