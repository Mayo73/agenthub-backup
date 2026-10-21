---
id: T-0521
title: Chat – Match beenden und Blockieren mit Bestätigung
project: sparring
priority: 2
after: T-0520, T-0515
---
## Ziel
React-Native-Neustart: Freiwilligkeit. Jede Seite kann ein Match beenden oder die andere Person blockieren; das Ergebnis ist aus beiden Perspektiven sichtbar (Abnahmekriterium 7).

## Dateien
- `app/src/screens/ChatScreen.tsx` – Knöpfe und Dialoge
- `app/__tests__/ChatActions.test.tsx` – neu

## Akzeptanzkriterien
Vorher `app/src/screens/ChatScreen.tsx`, `app/src/components/ConfirmDialog.tsx` und `app/src/logic/matching.ts` lesen.
- Unter dem Kopf (nur bei aktivem Match) eine Reihe mit zwei kleinen Knöpfen: `testID="chat-end"` „Match beenden“ und `testID="chat-block"` „Blockieren“ (Text `colors.pass`)
- „Match beenden“ öffnet `ConfirmDialog` mit Titel „Match beenden?“, Text „Ihr könnt euch danach nicht mehr schreiben und keine Treffen mehr vereinbaren.“, `confirmLabel` „Beenden“; Bestätigen → `update(d => endMatch(d, matchId, me))`, Dialog schließen
- „Blockieren“ öffnet `ConfirmDialog` mit Titel `` `${other.name} blockieren?` ``, Text „Das Match wird beendet und ihr seht euch nicht mehr unter Entdecken.“, `confirmLabel` „Blockieren“; Bestätigen → `update(d => block(d, me, other.id))`
- Abbrechen schließt nur den Dialog
- Der Hinweis `chat-ended` nennt zusätzlich, wer beendet hat: `'Von dir beendet.'` bzw. `` `Von ${Name} beendet.` `` (eigener `Text` mit `testID="chat-ended-by"`)

## Tests
`app/__tests__/ChatActions.test.tsx` (in `AppDataProvider`, Speicher mit `demoData()` plus Match `m1` zwischen p01 und p02, aktiv p01; `ChatScreen` mit `matchId="m1"` und `jest.fn()`):
- `beenden mit Bestätigung`: `chat-end` drücken, dann `confirm-yes` → `chat-ended` vorhanden, `chat-ended-by` zeigt `'Von dir beendet.'`
- `abbrechen`: `chat-end`, dann `confirm-no` → weiterhin `chat-input`, kein `chat-ended`
- `andere Perspektive sieht es`: Speicher mit `endedBy: 'p01'` und `activeId: 'p02'` → `chat-ended-by` zeigt `'Von Alex beendet.'`
- `blockieren`: `chat-block`, dann `confirm-yes` → `chat-ended` vorhanden; gespeicherte Daten (`JSON.parse(await store.getItem(STORAGE_KEY))`) haben `blocks` `['p01>p02']`

Review (21.10.2026): gemergt, nachgebessert: Knopftext war unsichtbar (Text und Fläche in colors.pass), jetzt Rahmen; leerer String im View vermieden.
