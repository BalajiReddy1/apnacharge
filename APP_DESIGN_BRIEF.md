# Apna Charge — Product & Design Brief

A brief written to hand to an AI design tool. It describes what the app is, who
uses it, every screen, how they connect, and what appears on each. Use it to
redesign the interface and to build a coherent design system. There are no
build or setup instructions here — only the product.

---

## 1. What the app is

Apna Charge helps electric-vehicle drivers find charging stations, decide
whether a station is worth driving to, and get there. It shows real charging
locations on a map with their connectors, power output, access rules and price,
and it lets drivers report whether a charger is actually working right now.

The app is built for India first (prices are shown in rupees, the audience is
Indian EV owners), but the underlying charging data is global.

## 2. The idea behind it, in one line

Most charger apps are a map of dots. The problem drivers actually have is
trust: you drive to a charger and it's broken, occupied, or gone. Apna Charge
answers one question before you leave — **"will this charger work when I get
there?"** — using live community reports on top of the map. Finding a charger
is the surface. Confidence is the point.

Everything in the design should serve that: reduce the anxiety of a low battery
and an uncertain charger.

## 3. Who uses it and where

- **Who:** EV drivers, typically checking the app before or during a trip.
- **Where:** outdoors, often in a car, frequently in bright sunlight, sometimes
  at night, often one-handed and in a hurry with a low battery.
- **What this means for design:** high contrast that survives glare, large tap
  targets, information readable in a two-second glance, a strong dark mode for
  night use, and a calm tone when the user is stressed.

## 4. Vocabulary (the app's domain)

- **Station** — a charging location. Has a name, operator, address, coordinates.
- **Operator / network** — the company running the station (e.g. a charging
  network).
- **Connector** — a physical plug type (CCS, CHAdeMO, Type 2, Tesla, GB/T,
  Type 1). A station has one or more, each with a power rating in kW.
- **Power (kW)** — how fast a connector charges. Higher is faster; this is a
  primary decision factor for drivers.
- **Operational status** — whether the data source marks the station as in
  service.
- **Access** — public or private/restricted.
- **Community report** — a driver's first-hand "working" or "not working" mark,
  optionally with a short note. Aggregated into a reliability percentage.
- **Reliability** — the share of recent reports that say a station works.
- **Favorite** — a station the user saved, stored on their device.

## 5. Features

Grouped by what the user is trying to do.

**Find**
- Map of nearby charging stations, refreshed as the map moves.
- A list of nearby stations sorted by distance, sliding up over the map.
- Location search to jump the map to any place.
- Filters: connector type, minimum power, and hiding out-of-service stations.

**Decide**
- Full station details: connectors and their power, access, price, operator,
  operational status.
- Community reliability: a percentage of recent reports that say it works, the
  number of reports, and how recently.
- A feed of recent reports with the driver's note, status and time.
- Favorites for stations the user cares about.

**Act**
- One tap to open turn-by-turn directions in an external maps app.
- Submit a "working / not working" report, with an optional note.
- Route planner: enter a start and destination, see the route, its distance and
  time, and the chargers along the way.

**Account & trust**
- Sign in with email/password or Google.
- Password reset.
- Settings: legal documents, app version, open-source licenses, sign out, and
  permanent account deletion.

## 6. Screens

Nine primary full screens, plus a set of modal surfaces (sheets, dialogs, a
drawer) that appear over them.

### Primary screens

1. **Splash** — the brand mark while the app decides where to send you. Brief.
   Leads to Home if already signed in, otherwise to Login.

2. **Login** — email and password, a "forgot password" entry, a "continue with
   Google" option, and a link to create an account. Currently uses a curved
   colored header as a brand motif.

3. **Register** — name, email, password, agreement to the Terms and Privacy
   Policy (with links to read them), and the Google option. Password strength is
   enforced.

4. **Home / Map** — the center of the app. A full-screen map with station
   markers. A top bar with search, filters (showing a badge when active), and a
   route-planner entry. A small status pill showing either "finding stations" or
   the count nearby. A "my location" button. A list of stations that pulls up
   from the bottom over the map.

5. **Route planner** — a "from" and "to" field (both open location search;
   "from" defaults to the user's location), a "plan route" action, a summary
   strip (distance, time, number of chargers on the way), and a map showing the
   route line, the endpoints, and chargers along the corridor.

6. **Location search** — a search field and a list of place suggestions;
   choosing one moves the map.

7. **Favorites** — a list of saved stations with operator, distance and
   connector count, quick actions to get directions or remove, and an empty
   state that invites saving one.

8. **Settings** — grouped sections: Account (the signed-in email, sign out),
   Legal (Privacy Policy, Terms), About (app version, open-source licenses), and
   a clearly separated destructive action to delete the account.

9. **Legal document** — a readable rendering of the Privacy Policy or Terms.

### Modal surfaces (appear over a screen)

- **Station details sheet** — the most important surface after the map. Slides
  up when a station is chosen. Contains: name, operator, an operational-status
  chip, address, a summary of connectors, max power, access and price, a
  per-connector breakdown, a favorite toggle, and a "get directions" action.
  Below that, the community section: the reliability line, a note field, "it's
  working" and "not working" buttons, a way to remove your own report, and a
  feed of recent reports.
- **Filter sheet** — connector chips, minimum-power presets, a switch to hide
  out-of-service stations, with reset and apply.
- **Forgot-password sheet** — an email field, a send action, and a neutral
  confirmation.
- **Nearby-stations list sheet** — the draggable list over the map on Home.
- **App drawer** — a branded header and links to Favorites, Settings, About and
  Sign out.
- **Dialogs** — a first-run location-use explanation, an About box, and a
  confirmation before deleting an account.

## 7. Primary flows

**First run / sign in**
Splash → if a session exists, Home → otherwise Login → (or Register) →
after sign-in, Home.

**The core loop (find → decide → act)**
Home map → a marker or the nearby list → Station details sheet → read the
connectors and the community reliability → either get directions, save it, or
submit a report.

**Narrowing down**
Home → open Filters or Search → the map, the count and the list update
together.

**Planning a trip**
Home → Route planner → pick "from" and "to" → plan → read distance, time, and
chargers on the way → open a charger's details if needed.

**Managing the account**
Drawer → Settings → read legal documents, check the version, sign out, or
delete the account.

## 8. What each key surface must communicate

**Home map** — where am I, where are the chargers, how many are near, and which
one should I look at. The nearby list and the map are two views of the same set
and should always agree.

**Station details** — can I charge here (connector and power), is it open to me
(access), what will it cost, and — most important — do other drivers say it
works. The reliability signal should be the emotional center of this surface,
not a footnote.

**Route planner** — will I have somewhere to charge on this trip. The count of
chargers on the way is the reassurance the screen exists to give.

**Reliability, everywhere it appears** — a clear, non-technical read: mostly
working vs. mostly not, how many people said so, how fresh that is.

## 9. Current visual language (the starting point, not a constraint)

The app today leans on a green identity tied to EV/energy, with a Material base.

- **Greens:** a mid green as the primary (`#138A36`), a deep green (`#285238`),
  a bright green (`#04E824`), a vivid accent (`#18FF6D`), and a near-black green
  for text (`#34403A`).
- **Type:** currently a humanist sans (Arimo / Arima).
- **Motifs:** curved, clipped colored headers on the auth screens; green pins on
  the map; rounded cards and sheets.
- **Status colors:** green for working/operational, red for not working,
  amber/orange for caution.

You are invited to keep the energy/trust feeling and improve on the rest:
the green can be refined into a fuller, accessible palette; typography and
spacing can be systematized; the map, markers, sheets and chips can be unified.
A genuine dark mode matters here because of night driving.

## 10. Design-system pieces to define

For a consistent redesign, the system should cover at least:

- **Color:** primary and its tints/shades, a neutral ramp, and semantic colors
  for working / not working / caution / info, all meeting contrast standards in
  light and dark.
- **Typography:** a scale for screen titles, section headers, station names,
  body, labels, and small meta text (distance, time-ago).
- **Spacing and radius:** one spacing scale and a consistent corner radius for
  cards, sheets, chips and buttons.
- **Buttons:** primary, secondary/outline, text, and a destructive variant, each
  with normal, pressed, disabled and loading states.
- **Inputs:** text fields, the note field, chips (filter and choice),
  switches — with focus and error states.
- **Map elements:** the station marker, a selected marker, origin/destination
  markers, the route line, and clusters for dense areas.
- **Cards & list rows:** the nearby-station row, the favorite row, the recent-
  report row.
- **Chips & badges:** connector chips, the filter-active badge, the operational-
  status chip, the reliability indicator.
- **Sheets & dialogs:** the bottom-sheet frame with its drag handle, and dialog
  styling.
- **Iconography:** a consistent set (station, connector, power/bolt, location,
  directions, star/favorite, filter, working/not-working).

## 11. States to design for every data surface

Because the app runs outdoors on real networks, each list or detail needs:

- **Loading** — while stations, details or reports are fetched.
- **Empty** — no stations nearby, no results for the filters, no favorites yet,
  no reports yet.
- **Error / offline** — data couldn't load; the user can retry.
- **Permission denied** — location was refused; the map still needs to be
  usable and the path to re-enable clear.
- **Success confirmation** — a report was submitted, a station saved, a reset
  email sent.

## 12. Tone of voice for interface copy

Plain, calm, direct. Short labels. Speak to a driver who may be stressed and
low on charge. Prefer "Not working" over "Non-operational", "Chargers on the
way" over "En-route charging infrastructure". Never blame the user. When
something fails, say what happened and what they can do next.

## 13. Where "better" can go (direction, not instructions)

- Make community reliability the visual hero of a station, readable instantly.
- Unify the map, sheets, list rows and chips into one system so the app feels
  like one product rather than assembled screens.
- Add a true dark mode for night driving.
- Give the connector-and-power information a clearer, more scannable layout —
  it's the first thing a driver checks.
- Bring the reliability signal onto the map and the list rows, not only the
  detail sheet, so a driver can compare stations at a glance.
- Keep the trip planner's "chargers on the way" count prominent — it's the
  reassurance the feature exists to provide.
