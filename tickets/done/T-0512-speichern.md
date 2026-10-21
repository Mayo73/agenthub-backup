---
id: T-0512
title: Speichern und Laden mit AsyncStorage
project: sparring
priority: 2
---
## Ziel
React-Native-Neustart, Meilenstein „Speicherung“: Der ganze App-Zustand bleibt nach einem App-Neustart erhalten; Zurücksetzen stellt die Testdaten wieder her.

## Dateien
- `app/src/logic/storage.ts` – neu
- `app/__tests__/storage.test.ts` – neu

## Akzeptanzkriterien
Vorher `app/src/logic/types.ts` und `app/src/logic/demoData.ts` lesen.
- `import AsyncStorage from '@react-native-async-storage/async-storage';`
- `export const STORAGE_KEY = 'sparring.data.v1'`
- `export type KeyValueStore = { getItem(key: string): Promise<string | null>; setItem(key: string, value: string): Promise<void>; removeItem(key: string): Promise<void> }`
- `export async function loadData(store: KeyValueStore = AsyncStorage): Promise<AppData>` → gespeicherten Text lesen; fehlt er, ist er kein gültiges JSON, ist `version` nicht 1 oder ist `profiles` kein Array mit mindestens einem Eintrag → `demoData()`. Sonst das gelesene Objekt. Fehler beim Lesen (Promise abgelehnt) → `demoData()`
- `export async function saveData(data: AppData, store: KeyValueStore = AsyncStorage): Promise<void>` → `JSON.stringify(data)` unter `STORAGE_KEY`
- `export async function resetData(store: KeyValueStore = AsyncStorage): Promise<AppData>` → `removeItem(STORAGE_KEY)`, dann `demoData()` zurückgeben

## Tests
`app/__tests__/storage.test.ts`. Hilfe im Test: `memoryStore()` liefert ein `KeyValueStore` auf Basis einer `Map<string, string>`.
- `ohne gespeicherte Daten`: `await loadData(memoryStore())` gleicht `demoData()` (`toEqual`)
- `speichern und laden`: Daten mit `activeId: 'p02'` und `likes: ['p02>p01']` speichern, mit demselben Store laden → gleiche Daten
- `kaputte Daten`: Text `'{kaputt'` unter `STORAGE_KEY` → `demoData()`
- `falsche Version`: `JSON.stringify({ version: 2 })` → `demoData()`
- `Lesefehler`: Store, dessen `getItem` ein abgelehntes Promise liefert → `demoData()`
- `zurücksetzen`: speichern, `await resetData(store)` gibt `demoData()` zurück, danach liefert `getItem(STORAGE_KEY)` `null`
- `Standardspeicher`: `await saveData(d)` und `await loadData()` ohne Store-Argument (in Jest eine Attrappe) → gleiche Daten

Review (21.10.2026): Umsetzung des Agents übernommen; gescheitert war sie an der Jest-Einrichtung (AsyncStorage-Attrappe als ES-Modul), jest.config.js von Claude angepasst, 107 Tests grün.
