-- Adds optional notes to community reports and a public "recent reports" feed.
--
-- Notes let drivers add context ("connector 2 is broken", "fast and free") that
-- other drivers can read — the community/reliability layer that a plain charger
-- finder can't offer. Notes are shared content; reporter identity is never
-- exposed (the feed function returns no user_id).
--
-- Apply after 20260723000000_station_reports.sql.

alter table public.station_reports
  add column if not exists note text
    check (note is null or char_length(note) <= 280);

-- Public feed of recent notes for a station (no PII). Newest first, last 30
-- days, capped. SECURITY DEFINER so it can read across users while the base
-- table stays locked down by RLS.
create or replace function public.get_station_recent_reports(
  p_station_id text,
  p_limit int default 5
)
returns table (
  status      text,
  note        text,
  reported_at timestamptz
)
language sql
security definer
set search_path = public
as $$
  select status, note, updated_at
  from public.station_reports
  where station_id = p_station_id
    and note is not null
    and char_length(trim(note)) > 0
    and updated_at > now() - interval '30 days'
  order by updated_at desc
  limit greatest(1, least(p_limit, 20));
$$;

revoke execute on function public.get_station_recent_reports(text, int)
  from public;
grant execute on function public.get_station_recent_reports(text, int)
  to authenticated;
