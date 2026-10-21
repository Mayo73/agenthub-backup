---
id: T-0513
title: App-Zustand als React-Kontext mit automatischem Speichern
project: sparring
priority: 2
after: T-0512
---
## Ziel
React-Native-Neustart, Meilenstein „Speicherung“: Alle Bildschirme lesen und ändern den Zustand über einen gemeinsamen Kontext; jede Änderung wird sofort gespeichert und beim Start geladen.

## Dateien
- `app/src/state/AppDataContext.tsx` – neu
- `app/App.tsx` – Provider einbauen
- `app/__tests__/AppDataContext.test.tsx` – neu

## Akzeptanzkriterien
Vorher `app/src/logic/storage.ts`, `app/App.tsx` und `app/__tests__/App.test.tsx` lesen.
- `export type AppDataValue = { data: AppData; loaded: boolean; update: (fn: (d: AppData) => AppData) => void; reset: () => Promise<void> }`
- `export function AppDataProvider({ children, store }: { children: React.ReactNode; store?: KeyValueStore })`:
  - Startwert sofort `demoData()` (damit die Oberfläche gleich da ist), `loaded` falsch
  - in `useEffect` einmal `loadData(store)` aufrufen, Ergebnis übernehmen, `loaded` wahr
  - `update(fn)`: neuen Zustand mit `fn(aktueller Zustand)` berechnen (aktuellen Zustand über `useRef` halten), setzen und mit `saveData(neu, store)` speichern. Ist das Ergebnis dasselbe Objekt (`===`), nichts tun
  - `reset()`: `resetData(store)` abwarten und das Ergebnis setzen
  - ohne `store` die Standardwerte von `loadData`/`saveData`/`resetData` nutzen (Parameter einfach `undefined` durchreichen)
- `export function useAppData(): AppDataValue` → wirft `new Error('useAppData nur innerhalb von AppDataProvider')` außerhalb des Providers
- `App.tsx`: in `App` innerhalb von `SafeAreaProvider` `<AppDataProvider><AppShell /></AppDataProvider>`; sonst nichts ändern

## Tests
`app/__tests__/AppDataContext.test.tsx`. Hilfen: `memoryStore()` wie in `storage.test.ts`; eine Testkomponente `Probe`, die `data.activeId` in `<Text testID="active">` zeigt und zwei `Pressable` hat: `testID="switch"` ruft `update(d => ({ ...d, activeId: 'p02' }))`, `testID="reset"` ruft `reset()`.
- `startet mit Testdaten`: `await render(<AppDataProvider store={memoryStore()}><Probe /></AppDataProvider>)` → `active` zeigt `p01`
- `Änderung wird gespeichert`: `switch` drücken → `active` zeigt `p02`; `JSON.parse(await store.getItem(STORAGE_KEY)).activeId` ist `'p02'`
- `lädt gespeicherte Daten`: Store vorher mit `saveData({ ...demoData(), activeId: 'p05' }, store)` füllen, rendern, `await screen.findByText('p05')`
- `zurücksetzen`: nach `switch` dann `reset` drücken → `await screen.findByText('p01')`, `store.getItem(STORAGE_KEY)` liefert `null`
- `außerhalb des Providers`: Rendern von `Probe` ohne Provider wirft (`expect(...).rejects.toThrow()` bzw. in `try/catch`; `console.error` mit `jest.spyOn(console, 'error').mockImplementation(() => {})` stummschalten)

Review (21.10.2026): gemergt.
