---
id: T-0515
title: Bausteine ConfirmDialog und PerspectiveBar
project: sparring
priority: 2
after: T-0510, T-0513, T-0514
---
## Ziel
React-Native-Neustart: Ein Bestätigungsdialog (für Zurücksetzen, Absagen, Beenden, Blockieren) und die deutlich als Demo gekennzeichnete Leiste zum Wechsel der Testperson.

## Dateien
- `app/src/components/ConfirmDialog.tsx` – neu
- `app/src/components/PerspectiveBar.tsx` – neu
- `app/__tests__/ConfirmDialog.test.tsx` – neu
- `app/__tests__/PerspectiveBar.test.tsx` – neu

## Akzeptanzkriterien
Vorher `app/src/theme.ts`, `app/src/components/Avatar.tsx`, `app/src/state/AppDataContext.tsx` und `app/src/logic/perspective.ts` lesen.
- `ConfirmDialog` (default export), Props `{ visible: boolean; title: string; message: string; confirmLabel: string; onConfirm: () => void; onCancel: () => void }`: `Modal` mit `transparent`, `animationType="fade"`, `onRequestClose={onCancel}` (Android-Zurück schließt). Halbdurchsichtiger dunkler Hintergrund, mittig eine Fläche `colors.card` mit Titel, Text und zwei Knöpfen: `testID="confirm-no"` Text „Abbrechen“ → `onCancel`; `testID="confirm-yes"` Text `confirmLabel` (Hintergrund `colors.pass`) → `onConfirm`. Knöpfe mindestens `sizes.button` hoch
- `PerspectiveBar` (default export, ohne Props), nutzt `useAppData()`: Überschrift „Demo: Ansicht als“ in `colors.demo`, darunter waagerechte `ScrollView` mit je einem `Pressable` pro Profil, `testID={`perspective-${p.id}`}`, darin `Avatar` (`size` 40) und Vorname. Die aktive Person (`data.activeId`) bekommt einen Rahmen in `colors.demo` und `accessibilityState={{ selected: true }}`, die anderen `selected: false`. Druck → `update(d => switchPerspective(d, p.id))`

## Tests
- `app/__tests__/ConfirmDialog.test.tsx`: `ja und nein`: mit `jest.fn()` für beide Handler rendern (`visible`), `confirm-yes` drücken → `onConfirm` einmal; `confirm-no` → `onCancel` einmal; Titel und `confirmLabel` als Text sichtbar
- `app/__tests__/PerspectiveBar.test.tsx` (in `AppDataProvider` mit einem Map-Speicher rendern): `acht Personen, Alex aktiv`: 8 Elemente `perspective-p01` … `perspective-p08`, `perspective-p01` hat `props.accessibilityState.selected` wahr; `Wechsel`: `perspective-p03` drücken → dessen `selected` wahr, `perspective-p01` falsch; Text „Demo: Ansicht als“ vorhanden

Review (21.10.2026): gemergt, nachgebessert: ConfirmDialog reicht visible an das Modal weiter.
