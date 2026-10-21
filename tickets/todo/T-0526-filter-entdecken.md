---
id: T-0526
title: Entdecken – Filter nach Kampfsportart und Erfahrung
project: sparring
priority: 3
after: T-0525, T-0511
---
## Ziel
React-Native-Neustart (Soll): Unter Entdecken lassen sich die Testprofile nach Kampfsportart und Erfahrung filtern, mit verständlichem Leerzustand.

## Dateien
- `app/src/screens/DiscoverScreen.tsx` – Filterleiste
- `app/__tests__/DiscoverFilter.test.tsx` – neu

## Akzeptanzkriterien
Vorher `app/src/screens/DiscoverScreen.tsx` und `app/src/logic/filter.ts` lesen.
- State `filter: Filter` (Start `emptyFilter()`) und `open: boolean`; die angezeigte Liste ist `applyFilter(candidates(data, me), filter)`
- neben `discover-me` ein Knopf `testID="filter-open"`: „Filter“, bei aktivem Filter `` `Filter: ${describeFilter(filter)}` ``; Druck klappt das Feld auf und zu
- aufgeklappt: Chips je Kampfsportart (`ARTS`) `testID={`filter-art-${i}`}` und je Erfahrung (`LEVELS`) `testID={`filter-level-${i}`}`, an/aus mit `toggle`, gewählte mit `colors.accent` und `accessibilityState={{ selected }}`; Knopf `testID="filter-clear"` „Filter löschen“ → `emptyFilter()`
- ist die gefilterte Liste leer, die ungefilterte aber nicht: `testID="discover-filter-empty"` mit „Keine Testprofile für diesen Filter“ und Knopf „Filter löschen“ (`testID="filter-clear-empty"`); sonst wie bisher `discover-empty`

## Tests
`app/__tests__/DiscoverFilter.test.tsx` (`DiscoverScreen` in `AppDataProvider`, `onOpenChat={jest.fn()}`):
- `nach Boxen filtern`: `filter-open`, `filter-art-2` (Boxen) → Text `'Mira, 26'`; `filter-open` zeigt `'Filter: Boxen'`
- `kombiniert`: `filter-art-2` und `filter-level-2` → `'Tarek, 38'`
- `leer durch Filter`: `filter-art-6` (Judo) → `discover-filter-empty`; `filter-clear-empty` → `'Sam, 33'`
- `löschen`: Filter setzen, `filter-clear` → `'Sam, 33'`, `filter-open` zeigt `'Filter'`
