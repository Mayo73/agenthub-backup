---
id: T-0527
title: Abnahmetest – Match und Chat über die ganze App
project: sparring
priority: 2
after: T-0526
---
## Ziel
React-Native-Neustart, Meilenstein „Abnahme“: Ein Test bedient die ganze App wie ein Mensch und prüft die Abnahmekriterien 1, 3, 4 und 5.

## Dateien
- `app/__tests__/abnahme-match.test.tsx` – neu (nur diese Datei; App-Code nur ändern, wenn der Test einen echten Fehler zeigt, dann im Bericht erklären)

## Akzeptanzkriterien
Vorher `app/App.tsx` und die Tests in `app/__tests__/` lesen (vor allem `App.test.tsx`, `DiscoverScreen.test.tsx`, `ChatScreen.test.tsx`). Der Test rendert `<App />` (Speicher ist in Jest die Attrappe aus `jest.setup.js`). Vor jedem Test den Speicher leeren: `import AsyncStorage from '@react-native-async-storage/async-storage';` und in `beforeEach` `await AsyncStorage.removeItem(STORAGE_KEY)`.
Navigation nur über die echten Bedienelemente: `tab-entdecken`, `tab-matches`, `tab-profil`, `perspective-<id>`, `btn-like`, `btn-pass`, `match-chat`, `match-close`, `match-row-<id>`, `chat-input`, `chat-send`, `chat-back`.

## Tests
`app/__tests__/abnahme-match.test.tsx`:
- `K1 acht Testprofile`: Reiter Profil → 8 Elemente `perspective-p01` … `perspective-p08`; Text „Prototyp · nur fiktive Testprofile“ sichtbar
- `K3 erst gegenseitiges Interesse ergibt ein Match`: als Alex `btn-like` (bei Sam) → kein `match-overlay`; Reiter Matches → `matches-empty`; Reiter Profil, `perspective-p02`; Reiter Entdecken → `'Alex, 29'`, `btn-like` → `match-overlay`; `match-close`; Reiter Matches → genau ein `match-row-m1`; Reiter Profil, `perspective-p01`; Reiter Matches → `match-row-m1`
- `K4 Jiu-Jitsu und MMA matchen, Knopf wie Wischen`: wie K3 (Alex ist Jiu-Jitsu, Sam MMA); zusätzlich `swipe-card` ist auf Entdecken vorhanden
- `K5 Chat zwischen A und B, Unbeteiligte sehen ihn nicht`: Match wie in K3 herstellen, im Match-Hinweis `match-chat` → `chat-input` `'Hallo Alex'`, `chat-send` → `msg-1`; `chat-back`; Reiter Profil, `perspective-p01`; Reiter Matches → Text `'Hallo Alex'`; `match-row-m1` → `chat-input` `'Hallo Sam'`, `chat-send` → `msg-2`; `chat-back`; Reiter Profil, `perspective-p03`; Reiter Matches → `matches-empty`
