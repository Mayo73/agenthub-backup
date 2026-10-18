---
id: T-0350
title: Anleitung – Perspektivwechsel, Testablauf und Zurücksetzen
project: sparring
priority: 4
---
## Ziel
Meilenstein „Android-APK und Anleitung“: Das Lastenheft verlangt eine kurze deutsche Anleitung für Demoprofilwechsel, kompletten Testablauf und Zurücksetzen. Die Teile ohne APK lassen sich schon jetzt schreiben; der Abschnitt zur Installation folgt mit der APK.

## Dateien
- `docs/ANLEITUNG.md` – neu
- `tests/test_doku.gd` – neu

## Akzeptanzkriterien
- `docs/ANLEITUNG.md` auf Deutsch, Überschrift `# Sparring – Anleitung`, danach diese Abschnitte in dieser Reihenfolge:
  - `## Was ist das?`: lokaler Prototyp mit acht fiktiven Testprofilen; kein Konto, kein Server, keine Standortfreigabe; nichts wird an echte Menschen gesendet.
  - `## Installation`: nur der Satz „Folgt mit der APK.“
  - `## Testperson wechseln`: Die Leiste unter der Kopfzeile („Du bist: …“) wechselt die Testperson. Das ist eine Demofunktion zum Nachspielen beider Seiten, keine Anmeldung.
  - `## Kompletter Testablauf`: nummerierte Liste mit genau diesen Schritten: 1. Als Alex unter „Entdecken“ nach rechts wischen oder „Interesse“ tippen, bis Sam erscheint. 2. Zu Sam wechseln und bei Alex Interesse bekunden – jetzt entsteht das Match. 3. Unter „Matches“ den Chat öffnen und eine Nachricht schreiben. 4. Im Chat „Treffen“ tippen, Ort draußen, Datum, Uhrzeit und Trainingsform eintragen und vorschlagen. 5. Zu Alex wechseln und dem Treffen zustimmen – erst dann ist es bestätigt. 6. Ein Treffen absagen oder das Match beenden geht jederzeit; beides sehen beide Seiten.
  - `## Freiwilligkeit`: Ein bestätigtes Treffen ist keine Verpflichtung; jede Seite kann absagen oder das Match beenden.
  - `## Zurücksetzen`: Im Reiter „Profil“ stellt „Demo zurücksetzen“ nach einer Rückfrage die ursprünglichen Testdaten wieder her (alle Profile, Matches, Nachrichten und Treffen).
- Keine echten Orte, Vereine oder Personen außer allgemeinen Beispielen wie „Stadtpark“.

## Tests
`tests/test_doku.gd`, `extends "res://tests/base_test.gd"`, Text mit `FileAccess.get_file_as_string("res://docs/ANLEITUNG.md")` lesen:
- `test_anleitung_vorhanden`: Text nicht leer, beginnt mit `"# Sparring – Anleitung"`
- `test_abschnitte`: enthält `"## Testperson wechseln"`, `"## Kompletter Testablauf"`, `"## Zurücksetzen"`, `"## Freiwilligkeit"`, `"## Installation"`; `"## Testperson wechseln"` steht vor `"## Kompletter Testablauf"` und dieser vor `"## Zurücksetzen"` (`find()` vergleichen)
- `test_inhalt`: enthält `"Demo zurücksetzen"`, `"Du bist:"`, `"keine Anmeldung"` und `"zustimmen"`
