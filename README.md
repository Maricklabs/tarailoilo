# TARAILO — Iloilo Offline Travel Companion

An offline-first mobile app for visitors to Iloilo City and province. It helps tourists find landmarks, speak basic Hiligaynon, identify local food and places with the camera, plan trips, and stay informed about events and road closures, even with weak or costly mobile data.

> **Status:** Planning / early development. Interviews and stakeholder suggestions are still pending, so some features may change.

---

## Table of Contents

- [Design Principles](#design-principles)
- [Features](#features)
- [Build Order (Rollout Plan)](#build-order-rollout-plan)
- [Datasets](#datasets)
- [Admin and Security Rules](#admin-and-security-rules)
- [Data Sources and Licensing](#data-sources-and-licensing)
- [Open Items](#open-items)

---

## Design Principles

- **Offline-first.** Core content works with no connection.
- **Sync when online.** Once connected, the app updates its data and uploads locally stored items (for example, route recordings).
- **Save for later.** Users can save the content they want so it remains available offline.
- **Mobile app only.**
- **Honest information.** Allergen info is always labeled as declared by the restaurant, with a date. It is never presented as "safe to eat."

---

## Features

### 1. Offline Content and Location
- Geofenced landmark information, triggered within 50 to 100 m zones
- "Places you passed" log, fully offline
- Offline route recording; the route is drawn on an online map once the user reconnects
- Offline map tiles for Iloilo City and province

### 2. Hiligaynon Phrasebook
- Handwritten phrases for ordering food, allergies, directions, bargaining, and emergencies
- Pronunciation guides
- Real-speaker audio recordings
- **"Show to the other person" mode:** displays a phrase full-screen so a visitor can show it to a local

### 3. Food and Place Dictionary + Camera Recognition
- Dictionary entries for local dishes and landmarks (meaning, history, origin)
- Points users to shops that serve a scanned dish
- Allergen labels marked "declared by the restaurant" and dated
- Lightweight on-device recognition model, assisted by GPS and compass
  - **Phase 1:** landmarks
  - **Later:** 20 to 30 local dishes, with a user confirmation step before results are shown

### 4. Trip Recommendations
- Top-picked places by season
- Related places based on what the user has visited or is interested in
- Reviews pulled online through the Google Places API (online-only)
- Suggestions for a fuller experience beyond the top picks

### 5. Events
- Current and upcoming events in Iloilo
- Notifications about possible road or area closures
- Festival support (Dinagyang): schedules, routes, tribes, viewing areas

### 6. Chatbot
- Users who ask how the app works are referred to the chatbot
- Gives quick, short answers drawn from curated entries
- Chat limits apply

### 7. Account
- Stores user info such as favorited places
- Counts as a feature (to confirm with the adviser)

---

## Build Order (Rollout Plan)

This is a build order, not a feature list.

| Layer | Scope |
|-------|-------|
| 1 | Offline content, phrasebook, and dictionary |
| 2 | Camera recognition |
| 3 | Restaurant partnerships |
| 4 | Festival mode, ahead of next January |

---

## Datasets

### 1. Offline Content and Location
| Dataset | Notes |
|---------|-------|
| Landmark master list | Name, category, description, history, photos, opening hours, entry fees. Verified by the Tourism Office. |
| Geofence data | Lat/long per landmark, radius (50 to 100 m), and polygons for large sites (churches, plazas, the Esplanade). Collected via GPS field visits and cross-checked with OpenStreetMap. |
| Offline map tiles | Iloilo City and province, as MBTiles or vector tiles (OpenStreetMap). |
| Road network and POIs | OpenStreetMap or PSA/NAMRIA boundary data. |
| User-generated | Places-passed log and timestamped GPS route recordings, stored on the device and synced later. |

### 2. Hiligaynon Phrasebook
- Phrase corpus by category, in English and Hiligaynon (Filipino optional), reviewed by native speakers or a language authority (for example UP Visayas or WVSU faculty)
- Pronunciation guide per phrase (respelling or IPA)
- One audio file per phrase from real speakers, with a consistent recording setup and signed consent/release forms
- Metadata: phrase ID, category, politeness level, emergency flag

### 3. Food and Place Dictionary + Camera Recognition
- **Dish records:** name, meaning, origin and history, recipe, typical ingredients (for example La Paz batchoy, pancit molo, KBL, Pinaupong Manok)
- **Restaurant and shop directory:** name, address, coordinates, hours, contact, dishes served
- **Allergen declarations (separate, dated table):** restaurant ID, dish ID, declared allergens, declaration date, source
- **Landmark training images:** a few hundred per class minimum, across angles, lighting, weather, and crowds, with GPS and compass heading metadata
- **Dish training images (later):** 20 to 30 classes, a few hundred photos each, plus "other / not a dish" negatives, collected with restaurant permission
- **Splits:** train, validation, and test, with test photos from different times or locations
- **Optional base model:** pretrained (for example MobileNet on ImageNet) for transfer learning

### 4. Trip Recommendation
- Place catalog with categories, tags, and seasonality
- Reviews and ratings from the Google Places API (online-only; check terms on caching and storage)
- Seasonal top-picks table (month or season, ranked places, reason), built with the Tourism Office and DOT Region VI arrival statistics if available
- Relatedness data (nearby, same category, same theme); start with a rule-based or content-based approach using tags and distance

### 5. Events
- Event calendar: title, description, dates and times, venue, coordinates, organizer, source link
- Dinagyang specifics: parade schedules, routes (geometry), tribes and performance schedules, viewing areas
- Road and area closures: affected roads (geometry), time windows, official advisories, updated manually by admins from official LGU or traffic office sources
- Transport guidance: alternative routes, jeepney and terminal changes, parking areas
- Notification data: topic or area subscriptions and an event-to-geofence mapping

### 6. Chatbot
- App-help knowledge base: roughly 50 to 150 curated Q&A pairs covering every feature
- Intent and utterance examples (English and Filipino/Hiligaynon) if using an intent classifier
- Fallback and escalation content for out-of-scope questions

---

## Admin and Security Rules

- Two roles: **Admin** and **User**
- Sign-in or account creation is limited to **5 attempts per IP address**
- Chat usage limits apply
- Closure and event data is maintained through a manual admin update process

---

## Data Sources and Licensing

- OpenStreetMap: check license and attribution requirements
- Google Places API: review terms of service; caching and storage are restricted
- Tourism Office, DOT Region VI, Dinagyang Foundation, and LGU/traffic office: content verification and official advisories
- Speaker consent forms and restaurant permissions are required before collecting audio and photos

---


## Developer Guide (Flutter skeleton)

### Run the app
1. Install Flutter (stable, Dart 3.13+). On Windows, turn on **Developer Mode** (plugins need symlinks).
2. `flutter pub get`
3. Copy `.env.example` to `.env` and fill in the Supabase URL + anon key (optional; without it the app runs with cloud features off).
4. `flutter run --dart-define-from-file=.env` (or pick a config in `.vscode/launch.json`).
5. `flutter analyze` and `flutter test` must pass before opening a PR.

Never commit `.env`. Gemini, Contentful and Apify keys live only in Supabase secrets.

### Navigation map
Entry: `/splash` (S1) → `/onboarding` (S2, first run) → `/login` (S3) → tabs. The redirect logic lives in `lib/app/router.dart` (`_redirect`).

| Tab | Root | Child routes |
|---|---|---|
| Home | `/home` S4 | `/home/recommendations` S5, `/home/saved` S7, `/home/profile` S8 |
| Dining | `/dining` S9 | `/dining/dish/:id` S10, `/dining/restaurant/:id` S11 |
| Map | `/map` S14 | `/map/landmark/:id` S15, `/map/places-passed` S16, `/map/route/:id` S17 |
| Language | `/language` S18 | `/language/phrase/:id` S19, `/language/phrase/:id/show` (show mode) |
| Events | `/events` S20 | `/events/:id` S21 |

Full screen (any tab): `/chat` S6 (Ask Guide button), `/scan?mode=dish|landmark` S12, `/scan/result` S13.
Admin (role-guarded): `/admin` A1, `/admin/content` A2, `/admin/events` A3, `/admin/restaurants` A4, `/admin/users` A5.
In debug builds, Profile has a **"Dev: act as admin"** switch so you can open the admin screens before roles exist.

Always navigate with the helpers in `lib/app/routes.dart`, e.g. `context.push(AppRoutes.dish(id))`.

### Folder structure
```
lib/
  main.dart              entry point (Supabase init, SharedPreferences, ProviderScope)
  app/                   app.dart, router.dart, routes.dart, theme.dart, providers.dart
  core/                  env, constants, errors, utils (haversine)
  data/local|remote|sync drift DB, Supabase services, sync + outbox
  models/                shared data classes
  features/<feature>/    screens/ widgets/ controllers/
  widgets/               app_shell, connectivity_banner, state_views, feature_placeholder
assets/                  images, seed json, faq (bundled FAQ for the offline chatbot)
supabase/                migrations/, functions/
contentful/              exported content model
```

### How to build your feature
1. Branch from `main` into your `<SURNAME>-features` branch.
2. Work only inside `lib/features/<your feature>/` where possible. Replace the `FeaturePlaceholder` in your screen with the real UI.
3. Every screen that loads data uses `LoadingView` / `EmptyView` / `ErrorView` or `AsyncValueView` from `lib/widgets/state_views.dart`.
4. Changes to shared files (`lib/app/`, `lib/widgets/`, `pubspec.yaml`) should be small and called out in your PR.
5. Comment each significant class/function, and log AI-generated code in the AI Usage Log.

> Theme note: `lib/app/theme.dart` uses placeholder tokens until the Figma colors and typography are applied.
