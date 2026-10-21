---
id: T-0507
title: Chat-Logik – Nachrichten zwischen den Testpersonen
project: sparring
priority: 2
---
## Ziel
React-Native-Neustart, Meilenstein „Chat“: Nach einem Match schreiben sich die beiden Testpersonen lokal. In beendeten Matches gibt es keine neuen Nachrichten.

## Dateien
- `app/src/logic/chat.ts` – neu
- `app/__tests__/chat.test.ts` – neu

## Akzeptanzkriterien
Vorher `app/src/logic/types.ts` lesen. Diese Datei importiert **nichts** aus `matching.ts` (sie entsteht parallel), sondern sucht Matches selbst in `data.matches`. Nichts ändert `data` selbst.
- `export const MAX_MESSAGE_LENGTH = 500`
- `export function canWrite(data: AppData, matchId: string, userId: string): boolean` → wahr nur, wenn das Match existiert, `endedBy === ''` ist, `userId` gleich `a` oder `b` ist und keiner der beiden den anderen blockiert hat (`data.blocks` enthält weder `` `${a}>${b}` `` noch `` `${b}>${a}` ``)
- `export function sendMessage(data: AppData, matchId: string, from: string, text: string): AppData` → Text mit `trim()` kürzen; unverändert, wenn er leer oder länger als `MAX_MESSAGE_LENGTH` ist oder `canWrite` falsch. Sonst `{ n, matchId, from, text }` anhängen, `n` = größtes vorhandenes `n` + 1 (1, wenn es noch keine gibt)
- `export function messagesOf(data: AppData, matchId: string): Message[]` → Nachrichten dieses Matches in ihrer Reihenfolge
- `export function lastMessage(data: AppData, matchId: string): Message | undefined`

## Tests
`app/__tests__/chat.test.ts`. Hilfsfunktion im Test: `withMatch()` = `demoData()` mit `matches: [{ id: 'm1', a: 'p01', b: 'p02', endedBy: '' }]`.
- `Nachricht senden`: `sendMessage(withMatch(), 'm1', 'p01', '  Hallo  ')` → eine Nachricht `{ n: 1, matchId: 'm1', from: 'p01', text: 'Hallo' }`
- `beide schreiben abwechselnd`: p01, dann p02 → `messagesOf` hat 2 Nachrichten mit `n` 1 und 2, `lastMessage` ist die von p02
- `Unbeteiligte können nicht schreiben`: `canWrite(d, 'm1', 'p03')` falsch, `sendMessage` von p03 gibt dasselbe Objekt zurück (`toBe`)
- `leerer Text`: `sendMessage(d, 'm1', 'p01', '   ')` gibt dasselbe Objekt zurück
- `zu langer Text`: 501 Zeichen → unverändert, 500 Zeichen → gesendet
- `beendetes Match`: Match mit `endedBy: 'p02'` → `canWrite` falsch, keine neue Nachricht
- `blockiert`: `blocks: ['p02>p01']` → `canWrite(d, 'm1', 'p01')` falsch
- `unbekanntes Match`: `messagesOf(d, 'm9')` leer, `lastMessage` `undefined`

Review (21.10.2026): gemergt, nachgebessert: canWrite sperrt bei einer Blockierung beide Seiten (der Agent hatte die Tests umgedeutet).
