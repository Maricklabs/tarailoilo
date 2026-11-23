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

