# Apna Charge — Starter Design Tokens

A baseline token system to pair with `APP_DESIGN_BRIEF.md`. It takes the app's
existing green identity and expands it into a full, accessible set for light and
dark. Treat it as a starting point: a design AI can refine values, but the
structure (roles, ramps, semantic names) is what keeps a redesign consistent.

Human-readable tables come first; a machine-readable JSON block is at the end.

---

## 1. Color

### Primary (green — brand / energy / "go")

| Token | Hex | Use |
|-------|-----|-----|
| primary/50 | `#E7F4EC` | tinted backgrounds, selected chip fill |
| primary/100 | `#C4E5D0` | subtle fills |
| primary/200 | `#9DD4B2` | borders on tinted surfaces |
| primary/300 | `#6FC090` | disabled-on-color, decorative |
| primary/400 | `#3FA968` | hover/pressed light |
| **primary/500** | **`#138A36`** | **primary brand, buttons, active** |
| primary/600 | `#0F7A2F` | pressed |
| primary/700 | `#0B6626` | text on light, deep accents |
| primary/800 | `#08501D` | headers on light |
| primary/900 | `#063C15` | darkest brand |

### Neutrals (text, surfaces, borders)

| Token | Hex | Use |
|-------|-----|-----|
| neutral/0 | `#FFFFFF` | light surface |
| neutral/50 | `#F7F8F7` | light background |
| neutral/100 | `#EEF0EE` | card background, dividers on white |
| neutral/200 | `#DDE1DD` | borders |
| neutral/300 | `#C2C8C2` | disabled borders |
| neutral/400 | `#9AA29A` | placeholder, meta text |
| neutral/500 | `#6B746B` | secondary text |
| neutral/600 | `#4C544C` | body text (light) |
| neutral/700 | `#34403A` | primary text (light) |
| neutral/800 | `#232A26` | elevated dark surface |
| neutral/900 | `#141815` | darkest text / dark background base |

### Semantic (status — the app's core signal)

| Token | Hex | Meaning |
|-------|-----|---------|
| success/500 | `#1B9E4B` | working / operational |
| success/50 | `#E6F6EC` | working chip fill |
| danger/500 | `#D92D20` | not working / out of service |
| danger/50 | `#FBEAE8` | not-working chip fill |
| warning/500 | `#F59E0B` | caution / mixed reports |
| warning/50 | `#FEF4E6` | caution fill |
| info/500 | `#2563EB` | neutral info, links |
| info/50 | `#E8F0FE` | info fill |

> Reliability uses this scale directly: mostly-working → success, mostly-not →
> danger, mixed/uncertain → warning. Keep these meanings fixed everywhere the
> signal appears (map, list rows, detail sheet).

### Surfaces — light vs dark

| Role | Light | Dark |
|------|-------|------|
| background | `#F7F8F7` | `#0E1512` |
| surface (cards, sheets) | `#FFFFFF` | `#16201B` |
| surface elevated | `#FFFFFF` | `#1E2A23` |
| text primary | `#34403A` | `#EEF2EF` |
| text secondary | `#6B746B` | `#A6B0A9` |
| border | `#DDE1DD` | `#2A352E` |
| primary (on dark) | `#3FA968` | (use primary/400 for contrast) |

A real dark mode matters here — drivers use the app at night. Dark is not just
inverted; it uses the dark green-black surfaces above so the map and UI sit
together.

## 2. Typography

One humanist sans across the app (currently Arimo/Arima; a design AI may
substitute). Roles map to the surfaces named in the brief.

| Role | Size / Line height | Weight |
|------|--------------------|--------|
| display (splash) | 32 / 40 | 700 |
| screen title (app bar) | 22 / 28 | 600 |
| section header | 18 / 24 | 700 |
| station name | 18 / 24 | 600 |
| body | 15 / 22 | 400 |
| label / button | 15 / 20 | 600 |
| meta (distance, time-ago) | 12 / 16 | 500 |
| caption | 11 / 14 | 500 |

## 3. Spacing

A 4-point scale. Use these steps only.

| Token | px |
|-------|----|
| space/1 | 4 |
| space/2 | 8 |
| space/3 | 12 |
| space/4 | 16 |
| space/5 | 20 |
| space/6 | 24 |
| space/8 | 32 |
| space/10 | 40 |
| space/12 | 48 |

Screen edge padding: 16. Card/sheet inner padding: 16. Gap between list rows: 0
with a divider, or 8 without.

## 4. Radius

| Token | px | Use |
|-------|----|-----|
| radius/sm | 8 | chips, inputs, small buttons |
| radius/md | 12 | buttons, cards |
| radius/lg | 16 | bottom sheets (top corners) |
| radius/pill | 999 | status pills, badges, filter chips |

## 5. Elevation

| Token | Use | Shadow |
|-------|-----|--------|
| elevation/card | list rows, cards | y 1, blur 3, black 8% |
| elevation/sheet | bottom sheets, status pill | y -2 / 2, blur 8, black 12–15% |
| elevation/dialog | dialogs | y 4, blur 16, black 20% |

## 6. Component notes

Where tokens meet the components from the brief:

- **Buttons** — primary: primary/500 fill, white label, radius/md; secondary:
  transparent, primary/500 border+label; text: primary/700 label; destructive:
  danger/500. All need pressed, disabled (reduce opacity ~50%), and a loading
  state (spinner replaces the label).
- **Report buttons** — "Working" uses success, "Not working" uses danger;
  selected = filled, unselected = outline in that color.
- **Status / reliability chip** — pill, semantic fill (success/50, danger/50,
  warning/50) with matching text color and an icon.
- **Filter chips** — pill; selected fill primary/50, border primary/200.
- **Map markers** — station: primary/500 pin; selected: enlarged with a ring;
  origin: info/500; destination: danger/500; clusters: primary/600 circle with a
  count.
- **Bottom sheets** — surface, radius/lg top, a neutral/300 drag handle,
  elevation/sheet.
- **Inputs** — surface fill, neutral/200 border, primary/500 focus ring,
  danger/500 error border + message.
- **List rows** (nearby station, favorite, recent report) — leading icon, title
  = station name role, subtitle = meta role, optional trailing value (power kW
  or a reliability chip).

## 7. Accessibility

- Body and label text must meet at least 4.5:1 against their background; large
  text and icons at least 3:1. Verify both light and dark.
- Do not rely on color alone for status — pair every working/not-working signal
  with an icon and/or text.
- Minimum tap target 48×48.

---

## 8. JSON (for design tools)

```json
{
  "color": {
    "primary": {
      "50": "#E7F4EC", "100": "#C4E5D0", "200": "#9DD4B2", "300": "#6FC090",
      "400": "#3FA968", "500": "#138A36", "600": "#0F7A2F", "700": "#0B6626",
      "800": "#08501D", "900": "#063C15"
    },
    "neutral": {
      "0": "#FFFFFF", "50": "#F7F8F7", "100": "#EEF0EE", "200": "#DDE1DD",
      "300": "#C2C8C2", "400": "#9AA29A", "500": "#6B746B", "600": "#4C544C",
      "700": "#34403A", "800": "#232A26", "900": "#141815"
    },
    "success": { "50": "#E6F6EC", "500": "#1B9E4B" },
    "danger":  { "50": "#FBEAE8", "500": "#D92D20" },
    "warning": { "50": "#FEF4E6", "500": "#F59E0B" },
    "info":    { "50": "#E8F0FE", "500": "#2563EB" },
    "light": {
      "background": "#F7F8F7", "surface": "#FFFFFF", "surfaceElevated": "#FFFFFF",
      "textPrimary": "#34403A", "textSecondary": "#6B746B", "border": "#DDE1DD"
    },
    "dark": {
      "background": "#0E1512", "surface": "#16201B", "surfaceElevated": "#1E2A23",
      "textPrimary": "#EEF2EF", "textSecondary": "#A6B0A9", "border": "#2A352E"
    }
  },
  "typography": {
    "display":     { "size": 32, "lineHeight": 40, "weight": 700 },
    "screenTitle": { "size": 22, "lineHeight": 28, "weight": 600 },
    "sectionHeader": { "size": 18, "lineHeight": 24, "weight": 700 },
    "stationName": { "size": 18, "lineHeight": 24, "weight": 600 },
    "body":        { "size": 15, "lineHeight": 22, "weight": 400 },
    "label":       { "size": 15, "lineHeight": 20, "weight": 600 },
    "meta":        { "size": 12, "lineHeight": 16, "weight": 500 },
    "caption":     { "size": 11, "lineHeight": 14, "weight": 500 }
  },
  "spacing": { "1": 4, "2": 8, "3": 12, "4": 16, "5": 20, "6": 24, "8": 32, "10": 40, "12": 48 },
  "radius": { "sm": 8, "md": 12, "lg": 16, "pill": 999 },
  "elevation": {
    "card":   { "y": 1, "blur": 3,  "color": "rgba(0,0,0,0.08)" },
    "sheet":  { "y": 2, "blur": 8,  "color": "rgba(0,0,0,0.14)" },
    "dialog": { "y": 4, "blur": 16, "color": "rgba(0,0,0,0.20)" }
  }
}
```
