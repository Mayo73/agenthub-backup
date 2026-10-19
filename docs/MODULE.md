# Module-Anleitung

Ein Modul ist ein eigener Ordner unter `modules/` mit einer `manifest.json`. Der Lader (`ModuleLoader`) liest alle Manifests und meldet sie bei der Registry an.

## Ordner-Aufbau

```
modules/
  modulname/
    manifest.json
```

## Felder des Manifests

| Feld         | Typ      | Bedeutung                                                                 |
|--------------|----------|---------------------------------------------------------------------------|
| `id`         | String   | Eindeutiger Kennzeichen des Moduls (z.B. `"beispiel")                    |
| `name`       | String   | Anzeigename für die Benutzeroberfläche                                    |
| `version`    | String   | Versionsnummer im Format **1.2.3** (SemVer ohne Präfix)                  |
| `engine_api` | Integer  | Benötigte Engine-Schnittstelle, derzeit **1**                             |
| `requires`   | Array    | Listet IDs anderer Module auf, die vorausgesetzt werden                   |
| `optional`   | Boolean  | `false`: Modul lässt sich nicht abschalten; `true`: optional              |
| `capabilities`| Array   | Listet verfügbare Funktionen auf (z.B. `"beispiel.hallo")                |

## Regeln

1. **Version**: Muss exakt der Form `X.Y.Z` folgen, wobei X, Y und Z ganze Zahlen sind.
2. **engine_api**: Derzeit ist nur die Schnittstelle `1` verfügbar. Module mit höherer Versionsnummer werden nicht geladen.
3. **Abhängigkeiten** (`requires`): Gelistet als Array von Modul-IDs. Diese Module müssen aktiv sein, bevor das aktuelle Modul gestartet wird.
4. **Notwendige Module**: Module mit `optional: false` können über `registry.disable()` nicht deaktiviert werden.
5. **Beispielmodul als Vorlage**: Der Ordner `modules/beispiel/manifest.json` zeigt einen minimal gültigen Aufbau und kann kopiert werden.

## Beispiel

```json
{
  "id": "beispiel",
  "name": "Beispielmodul",
  "version": "1.0.0",
  "engine_api": 1,
  "requires": [],
  "optional": true,
  "capabilities": ["beispiel.hallo"]
}
```
