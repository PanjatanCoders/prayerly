# Changelog

All notable changes to Prayerly are documented in this file.

## 2.6.0+14 — 2026-10-02

### Added
- **Islamic Events screen** listing Islamic holidays, including India-specific
  Urs (Sufi saint death-anniversary) observances.
- **Jumu'ah Durood**: tap-to-recite Durood dialog on Fridays, reachable from a
  home-screen banner and a Friday notification, in Urdu script with Roman
  Urdu transliteration (no English translation, matching the original source
  wording).
- **Daily Wazifa**: seven day-of-week recitations with a daily morning
  notification that deep-links into the Dhikr Counter, same Urdu/Roman Urdu
  presentation as Jumu'ah Durood.
- **World Light Map**: the countdown ring on the prayer times hero card is now
  a real day/night world map (NASA Blue Marble), with the sun or moon
  orbiting it to show which side of the globe is currently lit. Tap the ring
  to open a full-size map with live local time, sun intensity / moon
  illumination, day/night progress, current weather, and a pin at your
  location.

### Fixed
- Arabic diacritics (e.g. shadda + kasra combinations) no longer render
  incorrectly — bundled the Amiri font for all Dhikr/Durood Arabic text
  instead of relying on the device's fallback font.
- Dhikr Counter: the tap-to-count circle no longer gets pushed off-screen
  when the dhikr text is long.

### Changed
- Removed the "Asr: Hanafi" pill from the hero card — it duplicated the
  "Asr Hanafi" label already shown in the Prayer Times list below.
- Next-prayer name and countdown moved off the circular timer and onto the
  info card beside it, keeping the ring itself uncluttered.

## 2.5.2+13 — 2026-10-01

### Fixed
- Adhan now plays via each notification channel's own native sound instead
  of a Dart background-isolate trigger, which could silently fail to play
  audio (vibrate-only) or replay the adhan late when the app was reopened.
- Release-only launch crash: resource shrinking was stripping the adhan
  audio files since they were only referenced via a runtime-built string,
  which threw before `runApp()` ran and stranded the app on the splash
  screen.

### Changed
- Sun/moon icon moves along a real arc based on its current angle, and the
  sky disc itself reflects day/night/cloud conditions.
- Hero card shows live temperature and conditions in place of elevation;
  hero height and margins trimmed.
