-- Community reliability layer: crowd-sourced "is this charger working?" reports.
--
-- Each authenticated user holds at most ONE current report per station
-- (unique station_id + user_id), which they can change or retract. Individual
-- rows are private to their author (RLS); the public only ever sees aggregate
-- counts, exposed through a SECURITY DEFINER function.
--
-- Apply this in the Supabase dashboard: SQL Editor > paste > Run,
-- or via the Supabase CLI (`supabase db push`).

create table if not exists public.station_reports (
  id          uuid primary key default gen_random_uuid(),
  station_id  text not null,
  user_id     uuid not null default auth.uid()
                references auth.users (id) on delete cascade,
  status      text not null check (status in ('working', 'not_working')),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (station_id, user_id)
);

create index if not exists station_reports_station_idx
  on public.station_reports (station_id);

-- Keep updated_at fresh whenever a user changes their vote.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists station_reports_set_updated_at on public.station_reports;
create trigger station_reports_set_updated_at
  before update on public.station_reports
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Row Level Security: users may only touch their OWN report.
-- ---------------------------------------------------------------------------
alter table public.station_reports enable row level security;

drop policy if exists "read own report" on public.station_reports;
create policy "read own report"
  on public.station_reports for select
  to authenticated
  using (user_id = auth.uid());

drop policy if exists "insert own report" on public.station_reports;
create policy "insert own report"
  on public.station_reports for insert
  to authenticated
  with check (user_id = auth.uid());

drop policy if exists "update own report" on public.station_reports;
create policy "update own report"
  on public.station_reports for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

drop policy if exists "delete own report" on public.station_reports;
create policy "delete own report"
  on public.station_reports for delete
  to authenticated
  using (user_id = auth.uid());

-- ---------------------------------------------------------------------------
-- Public aggregate: counts only, no per-user rows leak out. Reliability is
-- based on reports from the last 7 days so a station's status stays current.
-- ---------------------------------------------------------------------------
create or replace function public.get_station_status_summary(p_station_id text)
returns table (
  working_count     bigint,
  not_working_count bigint,
  last_reported     timestamptz
)
language sql
security definer
set search_path = public
as $$
  select
    count(*) filter (
      where status = 'working'
        and updated_at > now() - interval '7 days'
    ) as working_count,
    count(*) filter (
      where status = 'not_working'
        and updated_at > now() - interval '7 days'
    ) as not_working_count,
    max(updated_at) as last_reported
  from public.station_reports
  where station_id = p_station_id;
$$;

-- Only signed-in users may read aggregates.
revoke execute on function public.get_station_status_summary(text) from public;
grant execute on function public.get_station_status_summary(text) to authenticated;
