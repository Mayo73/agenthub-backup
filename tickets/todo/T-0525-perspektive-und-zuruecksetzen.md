---
id: T-0525
title: Profil – Demo-Perspektivwechsel und Testdaten zurücksetzen
project: sparring
priority: 2
after: T-0524, T-0515
---
## Ziel
React-Native-Neustart: Im Profil lässt sich die aktive Testperson wechseln (klar als Demo gekennzeichnet), und eine deutlich beschriftete Funktion stellt nach Bestätigung die Testdaten wieder her (Abnahmekriterium 9).

## Dateien
- `app/src/screens/ProfileScreen.tsx` – Leiste und Zurücksetzen
- `app/__tests__/ProfileReset.test.tsx` – neu

## Akzeptanzkriterien
Vorher `app/src/screens/ProfileScreen.tsx`, `app/src/components/PerspectiveBar.tsx`, `app/src/components/ConfirmDialog.tsx` und `app/src/state/AppDataContext.tsx` lesen.
- Ganz oben in der Ansicht (nicht im Bearbeiten-Modus): `PerspectiveBar`, darunter klein in `colors.muted`: „Der Wechsel ist nur eine Demofunktion zum Ausprobieren beider Seiten, keine Anmeldung.“ Wechselt die Person, beendet sich ein offener Bearbeiten-Modus
- Ganz unten ein Abschnitt „Demo“ mit Knopf `testID="reset-data"` „Testdaten zurücksetzen“ (Rahmen `colors.pass`) → `ConfirmDialog` mit Titel „Testdaten zurücksetzen?“, Text „Alle Profiländerungen, Interessen, Matches, Nachrichten und Treffen werden gelöscht. Danach gilt wieder der Ausgangszustand mit Alex als aktiver Person.“, `confirmLabel` „Zurücksetzen“ → `reset()` abwarten, Dialog schließen

## Tests
`app/__tests__/ProfileReset.test.tsx` (in `AppDataProvider` mit Map-Speicher):
- `Perspektive wechseln`: `perspective-p02` drücken → Text `'Sam, 33'`
- `zurücksetzen mit Bestätigung`: `perspective-p02`, dann `reset-data`, `confirm-yes` → `await screen.findByText('Alex, 29')`; `store.getItem(STORAGE_KEY)` liefert `null`
- `abbrechen`: `perspective-p02`, `reset-data`, `confirm-no` → weiterhin `'Sam, 33'`
- `Hinweis`: Text „Der Wechsel ist nur eine Demofunktion zum Ausprobieren beider Seiten, keine Anmeldung.“ vorhanden
