# Sparring – Regeln für Agents

Android-App-Prototyp mit **React Native 0.88 und TypeScript**: Kampfsportpartner finden sich über gegenseitige Swipe-Matches, schreiben sich im Demochat und vereinbaren ein freiwilliges Training draußen. **Alles sind fiktive, lokale Testdaten**: kein Konto, kein Server, kein Netzwerk, keine Standortabfrage. Die Oberfläche ist deutsch.

**Die App liegt komplett im Ordner `app/`.** Alles andere im Hauptordner (`project.godot`, `scripts/`, `scenes/`, `tests/`, `playtests/`, `assets/`, `docs/`) ist die alte Godot-Fassung. Sie bleibt nur als Referenz stehen: nicht ändern, nicht löschen, nicht davon importieren. Man darf dort nachlesen, wie etwas früher gelöst war (z. B. `scripts/meeting_book.gd`).

## Aufbau von `app/`

| Pfad | Inhalt |
|---|---|
| `App.tsx` | `AppShell`: Kopfzeile `DemoBanner`, aktueller Bildschirm, Reiterleiste `TabBar`, Android-Zurück über `back()` aus `src/navigation.ts` |
| `src/logic/` | **Reine Logik ohne React**: `types.ts` (Datenmodell), `demoData.ts` (8 Testprofile, Listen `ARTS`, `LEVELS`, `FORMS` …), weitere Module laut Tickets |
| `src/state/` | React-Kontext mit dem App-Zustand und dem Speichern |
| `src/screens/` | Bildschirme (`DiscoverScreen`, `MatchesScreen`, `ChatScreen`, `MeetingScreen`, `ProfileScreen`) |
| `src/components/` | Bausteine (`DemoBanner`, `TabBar`, `Avatar`, `ProfileCard`, `PerspectiveBar`, `ConfirmDialog` …) |
| `src/navigation.ts` | Reiter (`entdecken`, `matches`, `profil`) und Stapel darübergelegter Bildschirme (`push`, `back`) |
| `src/theme.ts` | Farben `colors` und Größen `sizes` |
| `__tests__/` | Jest-Tests, Dateien `<thema>.test.ts` bzw. `.test.tsx` |
| `android/` | natives Android-Projekt (nur Claude ändert es) |

## Datenmodell (`src/logic/types.ts`)

- Der ganze Zustand ist ein `AppData`-Objekt: aktive Person `activeId`, `profiles`, `likes`/`passes`/`blocks` (Schlüssel `"von>an"`, z. B. `"p01>p02"`), `matches`, `messages`, `meetings`, `nextMatchNo`.
- **Logikfunktionen ändern nie das übergebene Objekt**, sondern geben ein neues `AppData` zurück (`{ ...data, likes: [...data.likes, key] }`). Ist eine Aktion nicht erlaubt (z. B. Nachricht in beendetem Match), geben sie das unveränderte `data` zurück.
- **Perspektivwechsel:** Jede der acht Testpersonen kann die aktive Person sein (`activeId`). So lassen sich beide Seiten eines Matches durchspielen. Das ist eine Demofunktion und wird immer als solche beschriftet (Farbe `colors.demo`).

## Regeln

- TypeScript mit Typen für Parameter und Rückgaben. Einrückung 2 Leerzeichen, einfache Anführungszeichen, Semikolons.
- Nur Funktionskomponenten mit Hooks. Aussehen über `StyleSheet.create` mit Werten aus `src/theme.ts`, keine eigenen Farbcodes.
- Bildschirme rechnen nicht selbst, sondern rufen Funktionen aus `src/logic/` auf.
- Alles, was ein Test drückt oder sucht, bekommt eine `testID` (Namen stehen im Ticket).
- Nur die vorhandenen Pakete verwenden (`react`, `react-native`, `react-native-safe-area-context`, `@react-native-async-storage/async-storage`). Keine neuen Pakete, keine Netzwerkzugriffe (`fetch`), keine Bilder aus dem Internet. `package.json` nicht ändern.
- Für Bestätigungen `ConfirmDialog` (eigenes `Modal`) statt `Alert.alert`, damit Tests ihn bedienen können.
- Zu jeder neuen Logik gehört ein Test. Vorlage:

  ```ts
  import { demoData } from '../src/logic/demoData';
  import { like } from '../src/logic/matching';

  describe('matching', () => {
    test('einseitiges Interesse ergibt kein Match', () => {
      const d = like(demoData(), 'p01', 'p02');
      expect(d.matches).toHaveLength(0);
    });
  });
  ```
- Komponententests mit `@testing-library/react-native` (Vorlage: `__tests__/App.test.tsx`): `await render(<X />)`, `screen.getByTestId(...)`, `screen.getByText(...)`, `await fireEvent.press(...)`, `await fireEvent.changeText(...)`. `render` und `fireEvent` immer mit `await`.
- Speichern in Tests: Der Speicher ist in Jest automatisch eine Attrappe (`jest.setup.js`). Logik, die speichert, bekommt den Speicher als Parameter, damit Tests einen eigenen übergeben können.
- Bestehende Tests nicht löschen, umbenennen, überspringen (`skip`) oder abschwächen.
- Nicht ändern: `verify.cmd`, `verify-ergebnis.js`, `app/package.json`, `app/jest.config.js`, `app/jest.setup.js`, `app/tsconfig.json`.

## Prüfen

`verify.cmd` führt die Typprüfung (`tsc --noEmit`) und alle Jest-Tests aus. Bestanden nur bei `ERGEBNIS: <n> ok, 0 fehlgeschlagen`; ein Typfehler zählt als fehlgeschlagen. Die Pakete liegen unter `AgentHub\envs\sparring\node_modules` (`app\node_modules` ist eine Verknüpfung dorthin).

## Android (nur Claude)

Mindestversion laut React-Native-Vorlage, Architekturen arm64-v8a und x86_64 (`android/gradle.properties`), Release-APK mit dem Debug-Schlüssel signiert, JavaScript in die APK eingebettet (läuft ohne Entwicklungsserver). Bauen: in `app\android` mit `ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk`, JDK 17 und Node im PATH `gradlew.bat assembleRelease` → `app\android\app\build\outputs\apk\release\app-release.apk`. Emulator `Sparring_Pixel` mit `-gpu host` starten.

## Stil

Vorbild sind moderne Swipe-Apps, aber ohne deren Marken, Logos oder Farben: fast schwarzer Hintergrund `colors.bg`, dunkle Flächen `card`/`raised`, große runde Ecken (`sizes.radius`, `sizes.radiusCard`), Akzent violett `accent` mit türkisem `accent2`, Interesse/Zustimmung grün `like`, Überspringen/Absagen rot `pass`, Demo-Hinweise gelb `demo`. Große Profilkarten, runde Aktionsknöpfe (`sizes.roundButton`) mit kleiner Beschriftung darunter, Knöpfe mindestens `sizes.button` hoch.
