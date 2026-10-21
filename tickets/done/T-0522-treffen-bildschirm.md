---
id: T-0522
title: Bildschirm Treffen – Vorschlag mit Ort, Datum, Uhrzeit und Trainingsform
project: sparring
priority: 2
after: T-0521, T-0509
---
## Ziel
React-Native-Neustart, Meilenstein „Treffen“: Ein Formular für den Treffvorschlag draußen. Es ist scrollbar und bleibt mit Bildschirmtastatur bedienbar.

## Dateien
- `app/src/screens/MeetingScreen.tsx` – neu
- `app/App.tsx` – Route `treffen` anzeigen
- `app/__tests__/MeetingScreen.test.tsx` – neu

## Akzeptanzkriterien
Vorher `app/App.tsx`, `app/src/logic/meetings.ts`, `app/src/logic/demoData.ts` (`FORMS`, `INTENSITIES`), `app/src/screens/ChatScreen.tsx` (Kopf als Vorlage) lesen.
- `MeetingScreen` (default export), Props `{ matchId: string; onBack: () => void }`, nutzt `useAppData()`; Kopf mit `testID="meet-back"` „‹ Zurück“ → `onBack` und Titel `` `Treffen mit ${other.name}` ``
- Wurzel `KeyboardAvoidingView` (wie im Chat), darin `ScrollView` mit `keyboardShouldPersistTaps="handled"`
- Formularwerte im State, Startwert: Felder des vorhandenen Vorschlags (`meetingOf`) oder `emptyDetails()`
- Felder (Beschriftung darüber, `TextInput` mit Hintergrund `colors.raised`, mindestens `sizes.button` hoch):
  - „Ort draußen“ `testID="meet-place"`, Platzhalter „z. B. Stadtpark, große Wiese“
  - „Datum“ `testID="meet-date"`, Platzhalter „TT.MM.JJJJ“, `keyboardType="numbers-and-punctuation"`
  - „Uhrzeit“ `testID="meet-time"`, Platzhalter „HH:MM“
  - „Trainingsform“: je Eintrag aus `FORMS` ein Chip `testID={`meet-form-${i}`}`; gewählter Chip Hintergrund `colors.accent`, `accessibilityState={{ selected }}`
  - „Intensität“: je Eintrag aus `INTENSITIES` ein Chip `testID={`meet-intensity-${i}`}`, ebenso
  - „Gemeinsame Regeln (freiwillig)“ `testID="meet-rules"`, mehrzeilig, Platzhalter „z. B. nur Technik, kein Vollkontakt“
- Knopf `testID="meet-propose"`: Text „Vorschlag senden“, bei vorhandenem Vorschlag „Änderung vorschlagen“. Druck: `missingFields(werte)` nicht leer → `testID="meet-missing"` mit `` `Bitte ergänzen: ${fehlend.join(', ')}` `` anzeigen; sonst `update(d => propose(d, matchId, me, werte))` und den Hinweis ausblenden
- Hinweis unten in `colors.muted`: „Treffen finden draußen statt und sind freiwillig. Absagen ist jederzeit möglich.“
- `App.tsx`: Route `screen: 'treffen'` → `<MeetingScreen matchId={route.matchId ?? ''} onBack={() => setNav(back(nav).nav)} />`

## Tests
`app/__tests__/MeetingScreen.test.tsx` (in `AppDataProvider`, Speicher mit `demoData()` plus Match `m1` zwischen p01 und p02, aktiv p01):
- `unvollständig`: sofort `meet-propose` drücken → `meet-missing` zeigt `'Bitte ergänzen: Ort, Datum, Uhrzeit'`
- `Vorschlag senden`: Ort, Datum `'24.10.2026'`, Uhrzeit `'10:00'` eingeben, `meet-form-2` drücken, `meet-propose` → gespeicherte Daten haben einen Meeting mit `place`, `form: 'Leichtes Sparring'`, `approved: ['p01']`; der Knopf heißt danach „Änderung vorschlagen“
- `vorhandener Vorschlag wird angezeigt`: Speicher mit fertigem Meeting (Ort „Uferweg“) → `meet-place` hat `props.value` `'Uferweg'`
- `Zurück`: `meet-back` → `onBack` einmal

Review (21.10.2026): von Claude selbst fertiggestellt (Agent scheiterte 5x: setState beim Rendern führte zur Endlosschleife, Tests ohne await render). 144 Tests grün.
