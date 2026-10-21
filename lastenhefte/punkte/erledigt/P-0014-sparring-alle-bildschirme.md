---
id: P-0014
projekt: sparring
art: ansehen
status: erledigt
erstellt: 2026-10-20
---
# Sparring: alle Bildschirme im neuen Stil ansehen

## Worum es geht
Nach der freigegebenen Musterkarte (P-0013) ist das moderne Design jetzt auf alle Bildschirme übertragen: Matchliste mit Reihe „Neue Matches“, Chat mit Sprechblasen und runden Knöpfen, Treffen mit Statuskarte und Ortsskizze als Karte, Profil mit großem Porträt, eigener „Match!“-Bildschirm, Leerzustände mit Symbol, Rückfrage-Dialog als Karte, Symbolleiste unten mit Matchzahl.

Bitte beurteilen: Wirkt das insgesamt wie eine moderne Dating-App (Vorbild Tinder, aber ohne deren Marke)? Ist alles gut lesbar, sind Abstände und Ausrichtung stimmig? Was stört am meisten? Eine Liste mit den wichtigsten Punkten reicht.

Schon bekannt und eingeplant, bitte nicht extra nennen: Im leeren Entdecken-Bildschirm stehen noch die Knöpfe „Überspringen“/„Interesse“, die Zahlenfelder „Alter“ und „Trainingsjahre“ im Profil sind noch nicht im neuen Stil, und die Symbole in der unteren Leiste sind noch klein.

## Material
- `P-0014/design-matches.png`: Matchliste mit „Neue Matches“ oben
- `P-0014/design-chat.png`: Chat mit einer eigenen Nachricht (Sprechblase rechts)
- `P-0014/design-treffen.png`: Treffvorschlag mit Statuskarte und Ortsskizze
- `P-0014/design-profil.png`: eigenes Profil
- `P-0014/matchbild-match.png`: „Match!“-Bildschirm, `matchbild-chat.png`: danach direkt im Chat
- `P-0014/neue_matches-neue_matches.png`: Matchliste mit neuem Match und Zahl im Reiter
- `P-0014/design_leer-matches_leer.png`, `design_leer-entdecken_leer.png`: Leerzustände
- `P-0014/design_leer-dialog.png`: Rückfrage vor dem Zurücksetzen
- Nur falls die Bilder nicht reichen: `C:\Users\wiens\AgentHub\hub\spielen.cmd sparring`

## Antwort
### Sichtprüfung am 20.10.2026, 21:24 Uhr

Alle zehn im Punkt genannten PNGs vollständig angesehen, jeweils 450 × 800 Pixel. Kein Programm gestartet. Die folgende Bewertung betrifft diese Standbilder; Bedienung, Animationen, Android-Tastatur und andere Bildschirm- oder Schriftgrößen sind damit nicht geprüft.

**Gesamtrichtung: Ja.** Porträts, neue Matches als Avatarreihe, dunkle Karten, runde Aktionen und das Match-Overlay ergeben inzwischen eine zusammenhängende moderne Swipe-App. Haupttexte sind in den gezeigten Ansichten gut lesbar. Aktive Reiter sind eindeutig markiert, die Rückfrage zum Zurücksetzen hat einen klaren Text und gut getrennte Aktionen. Der Prototyp-Hinweis bleibt durchgängig sichtbar. Kein weiterer grundlegender Stilwechsel erforderlich.

Die wichtigsten verbleibenden Punkte, nach Bedeutung:

1. **Für die vollständige Sichtabnahme fehlen ausgefüllte Zustände.** `design-chat.png` zeigt entgegen der Materialbeschreibung keine eigene Nachricht, sondern „Noch keine Nachrichten. Schreibe die erste!“. Auch `matchbild-chat.png` ist leer. Daher sind Sprechblasen, Textumbrüche und Absenderunterscheidung noch nicht beurteilt. `design-treffen.png` zeigt „Noch kein Treffvorschlag.“ und leere Eingaben; der untere Formularteil liegt außerhalb des Bildes. Bitte Bilder mit eigenen und empfangenen Nachrichten einschließlich eines längeren Textes sowie einem ausgefüllten Treffvorschlag und dessen unterem Formular-/Aktionsbereich nachreichen. Ein bestätigter Treffzustand sollte ebenfalls sichtbar sein. Das ist eine Lücke im Prüfmaterial, kein Nachweis eines Funktionsfehlers.

2. **Chat: Gewichtung der Aktionen korrigieren.** „Match beenden“ und „Blockieren“ stehen als große, kräftig rote Knöpfe direkt nebeneinander und dominieren den Kopf stärker als „Treffen“. Die beiden sekundären Aktionen zurückhaltender gestalten oder in ein klar bezeichnetes Menü auslagern; „Treffen“ als normale nächste Aktion hervorheben. Zwischen den Knöpfen sichtbaren Abstand vorsehen. Abbrechen und Blockieren müssen weiterhin gut auffindbar bleiben.

3. **Treffen: Formular vor Ortsskizze priorisieren.** Im sichtbaren Zustand besteht die relativ große Skizze nur aus einer blauen und einer grünen Fläche. Sie schiebt bereits das Datum an den unteren Bildschirmrand, ohne hier eine zusätzliche Orientierung zu geben. Kompakter beziehungsweise einklappbar darstellen oder hinter die eigentlichen Treffangaben setzen. Die Beschriftung „Skizze: draußen (schematisch, keine Karte)“ sitzt direkt auf dem unteren Bildrand; ihr einen eigenen Bereich mit Innenabstand geben. Die Kennzeichnung als schematische Darstellung beibehalten.

4. **Match-Overlay: Hintergrund stärker beruhigen.** In `matchbild-match.png` sind hinter dem Match mit Sam noch „Mira, 26“, die Profilbeschreibung und eine zusätzliche grüne Matchmeldung erkennbar. Das lenkt ab und vermischt sichtbar zwei Profilkontexte. Die darunterliegenden Karten-/Meldungstexte während des Overlays vollständig verdecken oder so weit abdunkeln, dass sie nicht mehr mit der Matchanzeige konkurrieren. Die beiden Porträts und die klar abgestuften Aktionen im Vordergrund sind gelungen. Aus dem Bild folgt kein Fehler bei der Zuordnung des Matches.

5. **Leerzustand im Chat an die anderen Symbole angleichen.** Die glänzende, plastische Sprechblase wirkt neben dem flachen Herz und Stern der anderen Leerzustände wie ein fremder Stil. Eine schlichte Sprechblase im vorhandenen Violett/Türkis verwenden und Symbol plus Hinweis als zusammengehörige Gruppe im freien Nachrichtenbereich ausrichten; derzeit sitzt die Gruppe sehr weit unten direkt über Treffhinweis und Eingabe.

Die drei im Auftrag bereits als bekannt genannten Baustellen sind hier bewusst nicht erneut aufgeführt. Die vorhandene Stilfreigabe bleibt bestehen; eine vollständige Abnahme aller Bildschirmzustände ist mit diesen Bildern noch nicht möglich. Claude kann die genannten Korrekturen im bestehenden Umfang umsetzen und die fehlenden Ansichten ergänzen. Keine zusätzliche Nutzerentscheidung erforderlich.

## Erledigt
- 2026-10-20: Richtung bestätigt. Claude hat Profilbreite, Chat-Rand, Zurück-Knöpfe und Dialog schon vorher selbst korrigiert; die fünf Befunde wurden zu T-0500 (Chat-Aktionen), T-0501 (Chat-Leerzustand), T-0502 (Ortsskizze kompakter), T-0503 (Match-Bildschirm deckt ab) und T-0504 (Spieltest design_voll mit gefüllten Zuständen als Material für die nächste Sichtprüfung).
