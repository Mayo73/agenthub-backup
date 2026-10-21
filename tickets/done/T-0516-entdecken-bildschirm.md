---
id: T-0516
title: Bildschirm Entdecken mit Knöpfen für Interesse und Überspringen
project: sparring
priority: 2
after: T-0506, T-0513, T-0514
---
## Ziel
React-Native-Neustart, Meilenstein „Swipe und Match“: Die aktive Testperson sieht die übrigen Profile einzeln und bekundet per Knopf Interesse oder überspringt.

## Dateien
- `app/src/screens/DiscoverScreen.tsx` – neu
- `app/App.tsx` – Platzhalter „Entdecken“ ersetzen
- `app/__tests__/DiscoverScreen.test.tsx` – neu

## Akzeptanzkriterien
Vorher `app/App.tsx`, `app/src/state/AppDataContext.tsx`, `app/src/logic/matching.ts`, `app/src/components/ProfileCard.tsx` und `app/src/theme.ts` lesen.
- `DiscoverScreen` (default export, vorerst ohne Props), nutzt `useAppData()`; `me = data.activeId`, `list = candidates(data, me)`, `top = list[0]`
- oben eine Zeile `` `Du bist: ${Name der aktiven Person} (Demo)` `` in `colors.demo`, klein, `testID="discover-me"`
- gibt es `top`: `ProfileCard` mit `top`, darunter zwei runde Knöpfe (`sizes.roundButton`, `borderRadius` halb so groß) mit kleiner Beschriftung darunter:
  - `testID="btn-pass"`, Zeichen `✕` in `colors.pass`, Beschriftung „Überspringen“ → `handlePass()` = `update(d => pass(d, me, top.id))`
  - `testID="btn-like"`, Zeichen `♥` in `colors.like`, Beschriftung „Interesse“ → `handleLike()` = `update(d => like(d, me, top.id))`
  - `accessibilityLabel` „Überspringen“ bzw. „Interesse“
- gibt es keinen: `View` mit `testID="discover-empty"`, Text „Keine weiteren Testprofile“ und darunter „Wechsle im Profil die Demo-Perspektive, um die andere Seite eines Matches zu sehen.“
- `App.tsx`: für den Reiter `entdecken` `<DiscoverScreen />` statt `<Placeholder title="Entdecken" />`

## Tests
`app/__tests__/DiscoverScreen.test.tsx`, gerendert in `AppDataProvider` mit einem Map-Speicher:
- `zeigt das erste Profil`: Text `'Sam, 33'`, `discover-me` enthält `'Du bist: Alex (Demo)'`
- `Überspringen zeigt das nächste`: `btn-pass` drücken → Text `'Mira, 26'`
- `Interesse zeigt das nächste`: `btn-like` drücken → Text `'Mira, 26'`
- `alle bewertet`: 7-mal `btn-pass` → `discover-empty` vorhanden

Review (21.10.2026): gemergt, nachgebessert: Knöpfe nebeneinander und rund.
