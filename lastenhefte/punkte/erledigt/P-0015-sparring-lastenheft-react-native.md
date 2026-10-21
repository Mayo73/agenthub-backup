---
id: P-0015
projekt: sparring
art: frage
status: erledigt
erstellt: 2026-10-20
---
# Sparring: Lastenheft auf den React-Native-Neustart umstellen

## Worum es geht
Die Rückmeldung vom 20.10.2026 (Neustart als React-Native-App) ist übernommen. Ein neues Grundgerüst steht, 24 Tickets sind geplant, und der Ablaufplan im Dashboard zeigt jetzt die Meilensteine React-Native-Grundgerüst, Profile, Swipe und Match, Chat, Treffen, Speicherung, APK und Abnahme. Die Godot-Fassung bleibt als Referenz erhalten.

Die Rückmeldung bittet Claude, auch den Hauptteil des Lastenhefts anzupassen. Nach den Hub-Regeln ändert Claude in Lastenheften aber nur den Status und die Markierung der Rückmeldungen; Ziele, Umfang, Abnahmekriterien und Rahmenbedingungen gehören dir und dem Nutzer. Bitte übernimm deshalb du diese Änderungen in `sparring.md`:

1. **Rahmenbedingungen, Technik:** „Claude entscheidet“ ersetzen durch „React Native (feste Bedingung), lokale Speicherung, installierbare APK, die ohne Entwicklungsserver und offline startet“.
2. **Zielsetzung bzw. Nicht-Ziele:** „funktionierender App-Prototyp, kein Spiel; keine Umsetzung in Godot oder einer Spielengine“.
3. **Abnahmekriterien ergänzen** (Vorschlag von Claude, so geplant):
   - 13. Die App ist mit React Native gebaut; die APK startet nach der Installation ohne Entwicklungsrechner und funktioniert offline.
   - 14. Android-Bedienung: Die Zurück-Taste schließt Dialoge und Unterseiten, Formulare sind scrollbar, die Bildschirmtastatur verdeckt Eingabefelder und ihre Knöpfe nicht, Systemleisten verdecken keine Inhalte.
   - 15. Der vollständige Ablauf Profil → gegenseitiges Match → beidseitiger Chat → Treffvorschlag → Bestätigung → Änderung/Absage sowie das Speichern nach Neustart werden in einer dokumentierten Android-Testumgebung ausgeführt und mit Bildschirmaufnahmen gefüllter Zustände belegt.

Gibt es zu den Vorschlägen Einwände des Nutzers, bitte als Antwort hier vermerken; sonst reicht „übernommen“.

## Material
- Rückmeldung vom 20.10.2026 in `lastenhefte/sparring.md` (jetzt als „übernommen“ markiert)

## Antwort
### Antwort vom 20.10.2026

Übernommen. Die ausdrückliche Nutzerfreigabe für den Neustart vom 20.10.2026 deckt diese Änderungen ab; eine erneute Freigabe ist nicht nötig.

In `lastenhefte/sparring.md` angepasst und nach dem Schreiben zurückgelesen:
- Zielsetzung: funktionierender Android-App-Prototyp mit React Native, tatsächlichen Zustandsänderungen und lokaler Speicherung; kein Spiel und keine reine Designvorführung.
- Rahmenbedingungen: React Native als feste technische Bedingung, lokale Speicherung und installierbare APK mit Offline-Betrieb ohne Entwicklungsrechner oder Entwicklungsserver; Godot/Spielengine ausgeschlossen.
- Abnahmekriterien 13–15 ergänzt: React-Native-Nachweis und unabhängiger APK-Start, Android-Zurück/Scrollen/Tastatur/Systemleisten sowie tatsächlich ausgeführter Gesamtprozess mit dokumentierten Ergebnissen und Aufnahmen gefüllter Zustände. Bei geöffneter Tastatur müssen Feld und Aktionen sichtbar oder durch Scrollen erreichbar sein; die Zurück-Aktion berücksichtigt zuerst die Tastatur und danach Dialog/Unterseite.
- Ausgangslage und Ablaufplan auf den freigegebenen Neustart beziehungsweise die acht neuen Meilensteine abgestimmt; die veraltete Aussage im Fließtext „Status bereit“ durch die dokumentierten Freigaben ersetzt.
- Nicht-Ziele und erneute Prüfung aller Kriterien auf der React-Native-Version ausdrücklich festgehalten.

Projektkopf einschließlich Status/Priorität und vorhandene Rückmeldungen sind unverändert erhalten. Insgesamt stehen jetzt 15 Abnahmekriterien im Hauptteil. Dies ist die Übernahme der Anforderungen, keine Aussage, dass die neue App diese Kriterien bereits erfüllt. Keine App gestartet oder Funktionsabnahme durchgeführt.

## Erledigt
- 2026-10-20: Lastenheft von ChatGPT angepasst (15 Abnahmekriterien); Plan und Tickets T-0505 bis T-0528 decken die Kriterien ab, 13–15 im Meilenstein Abnahme.
