-- PRODE TSUBASA + SUPABASE
-- Ejecutar completo en SQL Editor.
-- Como tus tablas están vacías, este script las recrea con el formato correcto para el HTML.

drop table if exists bonus cascade;
drop table if exists pronosticos cascade;
drop table if exists resultados cascade;
drop table if exists partidos cascade;
drop table if exists usuarios cascade;

create table usuarios (
  id uuid primary key references auth.users(id) on delete cascade,
  nombre text not null,
  email text unique not null,
  avatar text default 'hyuga',
  equipo text,
  rol text default 'jugador',
  fecha_alta timestamp with time zone default now()
);

create table partidos (
  id text primary key,
  grupo text,
  fase text default 'grupos',
  fecha date,
  hora text,
  equipo_local text not null,
  equipo_visitante text not null,
  ciudad text
);

create table pronosticos (
  id bigint generated always as identity primary key,
  usuario_id uuid references usuarios(id) on delete cascade,
  partido_id text not null,
  goles_local integer not null,
  goles_visitante integer not null,
  fase text default 'grupos',
  puntos integer default 0,
  fecha_carga timestamp with time zone default now(),
  unique(usuario_id, partido_id)
);

create table resultados (
  id bigint generated always as identity primary key,
  partido_id text unique not null,
  goles_local_real integer not null,
  goles_visitante_real integer not null,
  fase text default 'grupos',
  fecha_carga timestamp with time zone default now()
);

create table bonus (
  id bigint generated always as identity primary key,
  usuario_id uuid references usuarios(id) on delete cascade unique,
  campeon text,
  subcampeon text,
  goleador text,
  mejor_jugador text,
  fecha_carga timestamp with time zone default now()
);

alter table usuarios enable row level security;
alter table partidos enable row level security;
alter table pronosticos enable row level security;
alter table resultados enable row level security;
alter table bonus enable row level security;

-- USUARIOS
create policy "usuarios_select_all" on usuarios
for select to authenticated
using (true);

create policy "usuarios_insert_own" on usuarios
for insert to authenticated
with check (auth.uid() = id);

create policy "usuarios_update_own" on usuarios
for update to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

-- PARTIDOS / RESULTADOS visibles para todos los logueados
create policy "partidos_select_all" on partidos
for select to authenticated
using (true);

create policy "resultados_select_all" on resultados
for select to authenticated
using (true);

-- Por ahora, cualquier usuario logueado puede cargar resultados.
-- Después lo cerramos solo a admin cuando la app esté estable.
create policy "resultados_write_authenticated" on resultados
for all to authenticated
using (true)
with check (true);

-- PRONOSTICOS
create policy "pronosticos_select_all" on pronosticos
for select to authenticated
using (true);

create policy "pronosticos_insert_own" on pronosticos
for insert to authenticated
with check (auth.uid() = usuario_id);

create policy "pronosticos_update_own" on pronosticos
for update to authenticated
using (auth.uid() = usuario_id)
with check (auth.uid() = usuario_id);

-- BONUS
create policy "bonus_select_all" on bonus
for select to authenticated
using (true);

create policy "bonus_insert_own" on bonus
for insert to authenticated
with check (auth.uid() = usuario_id);

create policy "bonus_update_own" on bonus
for update to authenticated
using (auth.uid() = usuario_id)
with check (auth.uid() = usuario_id);
