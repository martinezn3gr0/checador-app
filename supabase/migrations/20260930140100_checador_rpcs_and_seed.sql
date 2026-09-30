-- Production RPCs + demo seed for Checador Express.
-- PINs are bcrypt-hashed via pgcrypto; anon only has EXECUTE on these RPCs.

create or replace function public.login_empleado(
  p_empresa_codigo text,
  p_empleado_codigo text,
  p_pin text
) returns json
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_empresa empresas%rowtype;
  v_emp empleados%rowtype;
begin
  select * into v_empresa
  from empresas
  where upper(codigo) = upper(trim(p_empresa_codigo))
    and activa = true
  limit 1;
  if not found then
    return null;
  end if;

  select * into v_emp
  from empleados
  where empresa_id = v_empresa.id
    and upper(codigo) = upper(trim(p_empleado_codigo))
    and activo = true
    and pin_hash = crypt(trim(p_pin), pin_hash)
  limit 1;
  if not found then
    return null;
  end if;

  return json_build_object(
    'empleado', json_build_object(
      'id', v_emp.id,
      'codigo', v_emp.codigo,
      'nombre', v_emp.nombre,
      'departamento', v_emp.departamento
    ),
    'empresa', json_build_object(
      'id', v_empresa.id,
      'codigo', v_empresa.codigo,
      'nombre', v_empresa.nombre
    )
  );
end;
$$;

create or replace function public.login_admin(
  p_empresa_codigo text,
  p_usuario text,
  p_pin text
) returns json
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_empresa empresas%rowtype;
  v_admin administradores%rowtype;
begin
  select * into v_empresa
  from empresas
  where upper(codigo) = upper(trim(p_empresa_codigo))
    and activa = true
  limit 1;
  if not found then
    return null;
  end if;

  select * into v_admin
  from administradores
  where empresa_id = v_empresa.id
    and lower(usuario) = lower(trim(p_usuario))
    and activo = true
    and pin_hash = crypt(trim(p_pin), pin_hash)
  limit 1;
  if not found then
    return null;
  end if;

  return json_build_object(
    'admin', json_build_object(
      'id', v_admin.id,
      'usuario', v_admin.usuario,
      'nombre', v_admin.nombre
    ),
    'empresa', json_build_object(
      'id', v_empresa.id,
      'codigo', v_empresa.codigo,
      'nombre', v_empresa.nombre
    )
  );
end;
$$;

create or replace function public.obra_for_empleado(
  p_empleado_id uuid,
  p_empresa_id uuid
) returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  v_obra obras%rowtype;
begin
  select o.* into v_obra
  from empleado_obras eo
  join obras o on o.id = eo.obra_id
  where eo.empleado_id = p_empleado_id
    and o.activa = true
  limit 1;

  if not found then
    select * into v_obra
    from obras
    where empresa_id = p_empresa_id
      and activa = true
    order by created_at
    limit 1;
  end if;

  if not found then
    return null;
  end if;

  return json_build_object(
    'id', v_obra.id,
    'nombre', v_obra.nombre,
    'lat', v_obra.lat,
    'lng', v_obra.lng,
    'radio_metros', v_obra.radio_metros
  );
end;
$$;

create or replace function public.list_checadas_empleado(
  p_empleado_id uuid,
  p_limit integer default 30
) returns setof json
language sql
security definer
set search_path = public
as $$
  select json_build_object(
    'id', c.id,
    'empleado_id', c.empleado_id,
    'obra_id', c.obra_id,
    'tipo', c.tipo,
    'registrado_at', c.registrado_at,
    'lat', c.lat,
    'lng', c.lng,
    'distancia_metros', c.distancia_metros
  )
  from checadas c
  where c.empleado_id = p_empleado_id
  order by c.registrado_at desc
  limit greatest(coalesce(p_limit, 30), 1);
$$;

create or replace function public.register_checada(
  p_empleado_id uuid,
  p_obra_id uuid,
  p_tipo text,
  p_lat double precision default null,
  p_lng double precision default null,
  p_distancia_metros double precision default null
) returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  v_row checadas%rowtype;
begin
  if p_tipo not in ('entrada', 'salida') then
    raise exception 'tipo invalido';
  end if;

  insert into checadas (empleado_id, obra_id, tipo, lat, lng, distancia_metros)
  values (p_empleado_id, p_obra_id, p_tipo, p_lat, p_lng, p_distancia_metros)
  returning * into v_row;

  return json_build_object(
    'id', v_row.id,
    'empleado_id', v_row.empleado_id,
    'obra_id', v_row.obra_id,
    'tipo', v_row.tipo,
    'registrado_at', v_row.registrado_at,
    'lat', v_row.lat,
    'lng', v_row.lng,
    'distancia_metros', v_row.distancia_metros
  );
end;
$$;

create or replace function public.dashboard_empresa(p_empresa_id uuid)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  v_empleados int;
  v_obras int;
  v_entradas int;
  v_salidas int;
  v_presentes int;
  v_checadas int;
  v_start timestamptz := date_trunc('day', now());
begin
  select count(*) into v_empleados
  from empleados where empresa_id = p_empresa_id and activo;

  select count(*) into v_obras
  from obras where empresa_id = p_empresa_id and activa;

  select
    count(*) filter (where c.tipo = 'entrada'),
    count(*) filter (where c.tipo = 'salida'),
    count(distinct c.empleado_id),
    count(*)
  into v_entradas, v_salidas, v_presentes, v_checadas
  from checadas c
  join empleados e on e.id = c.empleado_id
  where e.empresa_id = p_empresa_id
    and c.registrado_at >= v_start;

  return json_build_object(
    'empleados', v_empleados,
    'obras_activas', v_obras,
    'entradas', coalesce(v_entradas, 0),
    'salidas', coalesce(v_salidas, 0),
    'presentes', coalesce(v_presentes, 0),
    'faltas', greatest(v_empleados - coalesce(v_presentes, 0), 0),
    'checadas_hoy', coalesce(v_checadas, 0)
  );
end;
$$;

create or replace function public.faltas_hoy(p_empresa_id uuid)
returns setof json
language sql
security definer
set search_path = public
as $$
  with presentes as (
    select distinct c.empleado_id
    from checadas c
    join empleados e on e.id = c.empleado_id
    where e.empresa_id = p_empresa_id
      and c.registrado_at >= date_trunc('day', now())
  )
  select json_build_object(
    'id', e.id,
    'codigo', e.codigo,
    'nombre', e.nombre,
    'departamento', e.departamento,
    'empresa_id', e.empresa_id
  )
  from empleados e
  where e.empresa_id = p_empresa_id
    and e.activo
    and e.id not in (select empleado_id from presentes)
  order by e.nombre;
$$;

grant execute on function public.login_empleado(text, text, text) to anon, authenticated;
grant execute on function public.login_admin(text, text, text) to anon, authenticated;
grant execute on function public.obra_for_empleado(uuid, uuid) to anon, authenticated;
grant execute on function public.list_checadas_empleado(uuid, integer) to anon, authenticated;
grant execute on function public.register_checada(uuid, uuid, text, double precision, double precision, double precision) to anon, authenticated;
grant execute on function public.dashboard_empresa(uuid) to anon, authenticated;
grant execute on function public.faltas_hoy(uuid) to anon, authenticated;

-- Demo seed: INST01 / INST001 / admin / PIN 1212
insert into empresas (codigo, nombre)
values ('INST01', 'Instalec J')
on conflict (codigo) do update set nombre = excluded.nombre, activa = true;

insert into empleados (empresa_id, codigo, nombre, departamento, pin_hash)
select id, 'INST001', 'Jorge Cruz', 'encargado', crypt('1212', gen_salt('bf'))
from empresas where codigo = 'INST01'
on conflict (empresa_id, codigo) do update
  set nombre = excluded.nombre,
      departamento = excluded.departamento,
      pin_hash = excluded.pin_hash,
      activo = true;

insert into administradores (empresa_id, usuario, nombre, pin_hash)
select id, 'admin', 'Admin Instalec', crypt('1212', gen_salt('bf'))
from empresas where codigo = 'INST01'
on conflict (empresa_id, usuario) do update
  set nombre = excluded.nombre,
      pin_hash = excluded.pin_hash,
      activo = true;

insert into obras (empresa_id, nombre, lat, lng, radio_metros)
select e.id, 'Casa Central', 19.4326, -99.1332, 250
from empresas e
where e.codigo = 'INST01'
  and not exists (
    select 1 from obras o where o.empresa_id = e.id and o.nombre = 'Casa Central'
  );

insert into empleado_obras (empleado_id, obra_id)
select emp.id, o.id
from empleados emp
join empresas e on e.id = emp.empresa_id
join obras o on o.empresa_id = e.id and o.nombre = 'Casa Central'
where e.codigo = 'INST01' and emp.codigo = 'INST001'
on conflict do nothing;
