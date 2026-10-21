---
id: T-0519
title: Bildschirm Matches – Liste der Matches der aktiven Person
project: sparring
priority: 2
after: T-0518, T-0507
---
## Ziel
React-Native-Neustart, Meilenstein „Chat“: Die aktive Testperson sieht ihre Matches mit der letzten Nachricht und öffnet von dort den Chat. Unbeteiligte sehen fremde Chats nicht (Abnahmekriterium 5).

## Dateien
- `app/src/screens/MatchesScreen.tsx` – neu
- `app/App.tsx` – Platzhalter „Matches“ ersetzen
- `app/__tests__/MatchesScreen.test.tsx` – neu

## Akzeptanzkriterien
Vorher `app/App.tsx`, `app/src/logic/matching.ts`, `app/src/logic/chat.ts`, `app/src/components/Avatar.tsx` lesen.
- `MatchesScreen` (default export), Props `{ onOpenChat: (matchId: string) => void }`, nutzt `useAppData()`
- Überschrift „Deine Matches“ (`sizes.title`)
- `FlatList` über `matchesOf(data, data.activeId)`; je Zeile ein `Pressable` `testID={`match-row-${m.id}`}` (mindestens `sizes.button` hoch) mit `Avatar` (48) der anderen Person, Name und Kampfsportart, darunter der Text der letzten Nachricht (`lastMessage`) oder „Noch keine Nachrichten“ (`colors.muted`, eine Zeile, `numberOfLines={1}`); ist das Match beendet (`!isActive(m)`), rechts eine kleine Plakette „Beendet“ in `colors.pass`. Druck → `onOpenChat(m.id)`
- keine Matches → `testID="matches-empty"` mit Text „Noch keine Matches“ und „Bekunde unter Entdecken Interesse. Ein Match entsteht erst, wenn beide Interesse haben.“
- `App.tsx`: für den Reiter `matches` `<MatchesScreen onOpenChat={id => setNav(push(nav, { screen: 'chat', matchId: id }))} />`

## Tests
`app/__tests__/MatchesScreen.test.tsx` (in `AppDataProvider`; Speicher vorher mit `saveData` füllen und mit `findBy…` warten). Daten: `demoData()` mit Match `{ id: 'm1', a: 'p01', b: 'p02', endedBy: '' }` und Nachricht `{ n: 1, matchId: 'm1', from: 'p02', text: 'Hallo Alex' }`:
- `zeigt das Match`: `match-row-m1` vorhanden, Texte `'Sam'` und `'Hallo Alex'`
- `öffnet den Chat`: `match-row-m1` drücken → `onOpenChat` mit `'m1'`
- `Unbeteiligte sehen es nicht`: dieselben Daten mit `activeId: 'p03'` → `matches-empty`, kein `match-row-m1`
- `beendet`: Match mit `endedBy: 'p02'` → Text `'Beendet'`
- `ohne Matches`: `demoData()` → `matches-empty`

Review (21.10.2026): gemergt, nachgebessert: Beendet-Plakette über isActive(), Typen statt any, ungenutzter Import entfernt, Leertext in colors.muted.
