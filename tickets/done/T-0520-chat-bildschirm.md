---
id: T-0520
title: Bildschirm Chat – Nachrichten lesen und schreiben
project: sparring
priority: 2
after: T-0519
---
## Ziel
React-Native-Neustart, Meilenstein „Chat“: Die beiden Testpersonen eines Matches schreiben sich. Die Bildschirmtastatur verdeckt das Eingabefeld nicht.

## Dateien
- `app/src/screens/ChatScreen.tsx` – neu
- `app/App.tsx` – Route `chat` anzeigen
- `app/__tests__/ChatScreen.test.tsx` – neu

## Akzeptanzkriterien
Vorher `app/App.tsx`, `app/src/logic/chat.ts`, `app/src/logic/matching.ts`, `app/src/components/Avatar.tsx` lesen.
- `ChatScreen` (default export), Props `{ matchId: string; onBack: () => void; onOpenMeeting: (matchId: string) => void }`, nutzt `useAppData()`; `me = data.activeId`, Match aus `data.matches`, `other` = Profil von `otherId(match, me)`. Gibt es das Match nicht oder ist `me` nicht beteiligt: nur Text „Dieser Chat ist für die aktive Testperson nicht sichtbar.“ und der Zurück-Knopf
- Kopf: Knopf `testID="chat-back"` „‹ Zurück“ → `onBack`; `Avatar` (40) und Name von `other`; rechts Knopf `testID="chat-meeting"` „Treffen“ → `onOpenMeeting(matchId)` (nur bei aktivem Match)
- `FlatList` der Nachrichten (`messagesOf`), je Nachricht `testID={`msg-${m.n}`}`: eigene rechts (Hintergrund `colors.accent`), fremde links (`colors.raised`), runde Ecken, Text `colors.text`. Keine Nachrichten → Text „Noch keine Nachrichten. Schreib die erste!“
- unten, nur wenn `canWrite(data, matchId, me)`: `TextInput` `testID="chat-input"`, Platzhalter „Nachricht schreiben …“, `maxLength={MAX_MESSAGE_LENGTH}`, und Knopf `testID="chat-send"` „Senden“ (gesperrt bei leerem Text) → `update(d => sendMessage(d, matchId, me, text))`, dann Eingabe leeren
- ist das Match beendet: statt der Eingabe `testID="chat-ended"` mit Text „Dieses Match wurde beendet. Neue Nachrichten und Treffen sind nicht möglich.“
- Wurzel: `KeyboardAvoidingView` mit `behavior={Platform.OS === 'ios' ? 'padding' : 'height'}` und `style={{ flex: 1 }}`
- `App.tsx`: ist `current(nav)` eine Route mit `screen: 'chat'`, `<ChatScreen matchId={route.matchId ?? ''} onBack={() => setNav(back(nav).nav)} onOpenMeeting={id => setNav(push(nav, { screen: 'treffen', matchId: id }))} />` statt des Platzhalters

## Tests
`app/__tests__/ChatScreen.test.tsx` (in `AppDataProvider`, Speicher mit `saveData` vorbereiten: `demoData()` mit Match `m1` zwischen p01 und p02; mit `findBy…` warten):
- `senden`: `chat-input` mit `'Hallo Sam'` füllen (`fireEvent.changeText`), `chat-send` drücken → `msg-1` mit Text `'Hallo Sam'`, Eingabe wieder leer (`props.value` `''`)
- `leere Nachricht`: ohne Text `chat-send` drücken → kein `msg-1`
- `beendet`: Match mit `endedBy: 'p02'` → `chat-ended` vorhanden, kein `chat-input`, kein `chat-meeting`
- `Unbeteiligte`: `activeId: 'p03'` → Text „Dieser Chat ist für die aktive Testperson nicht sichtbar.“
- `Zurück und Treffen`: `chat-back` → `onBack` einmal; `chat-meeting` → `onOpenMeeting` mit `'m1'`

Review (21.10.2026): selbst fertiggestellt. Der letzte Versuch des Agents war fast fertig, aber der Test rief fireEvent ohne await auf (RNTL 14 ist asynchron), deshalb kam der Druck auf Senden nie an. Tests auf await umgestellt, die drei gleichen Nicht-sichtbar-Zweige zusammengelegt, Pressable statt TouchableOpacity. 5 Tests, verify grün (136).
