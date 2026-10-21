---
id: T-0514
title: Bausteine Avatar und ProfileCard
project: sparring
priority: 2
---
## Ziel
React-Native-Neustart, Meilenstein „Profile“: Eine große Profilkarte im Stil moderner Swipe-Apps, eindeutig als Testprofil gekennzeichnet.

## Dateien
- `app/src/components/Avatar.tsx` – neu
- `app/src/components/ProfileCard.tsx` – neu
- `app/__tests__/ProfileCard.test.tsx` – neu

## Akzeptanzkriterien
Vorher `app/src/theme.ts`, `app/src/logic/types.ts`, `app/src/logic/demoData.ts` und `app/src/components/TabBar.tsx` (Stil-Vorlage) lesen.
- `Avatar({ profile, size }: { profile: Profile; size: number })` (default export): runde `View` (`width`/`height` = `size`, `borderRadius` = `size / 2`, Hintergrund `profile.color`) mit dem ersten Buchstaben von `profile.name` mittig, weiß (`colors.text`), fett, Schriftgröße `Math.round(size * 0.42)`; `testID={`avatar-${profile.id}`}`
- `ProfileCard({ profile }: { profile: Profile })` (default export), `testID="profile-card"`: Fläche `colors.card`, `borderRadius: sizes.radiusCard`, Innenabstand `sizes.gap * 1.5`. Inhalt von oben:
  - Plakette „Testprofil“ (Hintergrund `colors.demo`, Text `colors.bg`, klein, rechts oben)
  - `Avatar` mit `size` 160, mittig
  - Name und Alter als `` `${profile.name}, ${profile.age}` `` (Größe `sizes.hero`, fett)
  - Reihe kleiner Chips (Hintergrund `colors.raised`, runde Ecken): Kampfsportart (Text `colors.accent2`), `LEVELS[profile.level]`, `` `${profile.years} Jahre Training` ``
  - `profile.bio` (`colors.muted`)
  - drei Zeilen: `` `Gewichtsklasse: ${WEIGHT_CLASSES[profile.weightClass]}` ``, `` `Trainingstage: ${profile.days.join(', ')}` `` (bei leerer Liste `'Trainingstage: offen'`), `` `Ausrüstung: ${profile.equipment.join(', ')}` `` (bei leerer Liste `'Ausrüstung: keine'`)

## Tests
`app/__tests__/ProfileCard.test.tsx`:
- `zeigt Name, Alter und Kampfsportart`: `await render(<ProfileCard profile={DEMO_PROFILES[0]} />)` → Texte `'Alex, 29'`, `'Jiu-Jitsu'`, `'Fortgeschritten'`, `'4 Jahre Training'`
- `als Testprofil gekennzeichnet`: Text `'Testprofil'`
- `Merkmale`: für `DEMO_PROFILES[3]` (Jonas) die Texte `'Ausrüstung: keine'`, `'Trainingstage: Mi, Sa'`, `'Gewichtsklasse: mittel'`
- `Avatar zeigt den Anfangsbuchstaben`: `await render(<Avatar profile={DEMO_PROFILES[1]} size={48} />)` → Text `'S'`, `testID` `'avatar-p02'` vorhanden

Review (21.10.2026): gemergt, nachgebessert: Anfangsbuchstabe im Avatar mittig.
