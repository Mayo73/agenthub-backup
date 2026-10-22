---
id: T-0524
title: Bildschirm Profil – eigenes Demoprofil ansehen und bearbeiten
project: sparring
priority: 2
after: T-0523, T-0510
---
## Ziel
React-Native-Neustart, Meilenstein „Profile“: Die aktive Testperson sieht ihr Profil und bearbeitet es in einem scrollbaren Formular. Änderungen werden geprüft und gespeichert (Abnahmekriterium 2).

## Dateien
- `app/src/screens/ProfileScreen.tsx` – neu
- `app/App.tsx` – Platzhalter „Profil“ ersetzen
- `app/__tests__/ProfileScreen.test.tsx` – neu

## Akzeptanzkriterien
Vorher `app/App.tsx`, `app/src/logic/profileEdit.ts`, `app/src/logic/perspective.ts`, `app/src/logic/demoData.ts`, `app/src/components/ProfileCard.tsx` und `app/src/screens/MeetingScreen.tsx` (Formular-Vorlage) lesen.
- `ProfileScreen` (default export, ohne Props), nutzt `useAppData()`; `ScrollView` mit `keyboardShouldPersistTaps="handled"` in einem `KeyboardAvoidingView` wie im Chat
- Ansicht: Überschrift „Dein Demoprofil“, `ProfileCard` mit `activeProfile(data)`, Knopf `testID="profile-edit"` „Profil bearbeiten“
- Bearbeiten (State `editing`; Entwurf = Kopie des Profils):
  - `TextInput` `testID="edit-name"` (Name), `testID="edit-age"` (Alter, `keyboardType="number-pad"`), `testID="edit-years"` (Trainingsjahre, `number-pad`), `testID="edit-bio"` (Beschreibung, mehrzeilig, `maxLength={200}`). Zahlen aus dem Text mit `Number(text)` übernehmen (leer → `NaN`, das die Prüfung meldet)
  - Chips Kampfsportart `testID={`edit-art-${i}`}` über `ARTS`, Erfahrung `testID={`edit-level-${i}`}` über `LEVELS`, Gewichtsklasse `testID={`edit-weight-${i}`}` über `WEIGHT_CLASSES`, Trainingstage `testID={`edit-day-${tag}`}` über `DAYS` (an/aus mit `toggle` aus `filter.ts` oder eigener Hilfsfunktion); gewählte Chips mit `colors.accent` und `accessibilityState={{ selected }}`
  - `testID="edit-save"` „Speichern“: `validateProfile(entwurf)` nicht leer → `testID="edit-errors"` mit den Meldungen (je eine Zeile); sonst `update(d => updateProfile(d, entwurf.id, änderungen))` und zurück zur Ansicht
  - `testID="edit-cancel"` „Abbrechen“ → Entwurf verwerfen, zurück zur Ansicht
- `App.tsx`: Reiter `profil` → `<ProfileScreen />`

## Tests
`app/__tests__/ProfileScreen.test.tsx` (in `AppDataProvider` mit Map-Speicher):
- `zeigt das aktive Profil`: Text `'Alex, 29'`
- `bearbeiten und speichern`: `profile-edit`, `edit-name` auf `'Alexa'`, `edit-art-1` (MMA), `edit-save` → Text `'Alexa, 29'` und `'MMA'`; gespeicherte Daten (`STORAGE_KEY`) haben `profiles[0].name` `'Alexa'`
- `ungültig`: `profile-edit`, `edit-age` auf `'15'`, `edit-save` → `edit-errors` enthält `'Alter muss zwischen 18 und 99 liegen'`, gespeichertes Alter unverändert (Speicher leer oder 29)
- `abbrechen`: `profile-edit`, Name ändern, `edit-cancel` → weiterhin `'Alex, 29'`
- `nach Neustart erhalten`: speichern wie oben, dann `unmount()` und mit demselben Speicher neu rendern → `await screen.findByText('Alexa, 29')`

Review (21.10.2026): selbst umgesetzt (Agent scheiterte 5x an der async-API von render in den Tests; Bildschirm übernommen, Tests neu geschrieben).
