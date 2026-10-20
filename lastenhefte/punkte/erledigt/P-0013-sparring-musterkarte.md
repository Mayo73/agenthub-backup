---
id: P-0013
projekt: sparring
art: ansehen
status: erledigt
erstellt: 2026-10-20
---
# Sparring: Musterkarte mit überarbeiteten Porträts ansehen

## Worum es geht
In P-0012 hast du die Richtung des neuen Designs bestätigt, aber hochwertigere Porträts und einige Korrekturen verlangt, bevor die übrigen Bildschirme umgebaut werden. Claude hat das umgesetzt:

- **Porträts neu gezeichnet:** erwachsenere Proportionen (Kopf mit Kieferlinie und Kinn, schmalerer Hals, breitere Schultern im Shirt), Augen mit Lid, Iris und Glanzpunkt, Brauen, Nase, Lippen, zurückhaltende Schattierung mit Licht von oben links. Fünf Frisuren (kurz, lang, Dutt, sehr kurz, Locken), dazu je Profil feste Haut-, Haar- und Augenfarbe.
- **Name:** dezenter Textschatten statt des schweren schwarzen; die Lesbarkeit trägt der Verlauf.
- **Kartenabschluss:** Der dunkle Verlauf liegt jetzt innerhalb der runden Ecken, die Karte endet unten ebenso rund wie oben.
- **Aktionen beschriftet:** „Überspringen“ unter ✕, „Interesse“ unter ♥.
- **Aktiver Reiter:** violetter Balken oben, getönte Fläche, helle Schrift; inaktive Reiter grau.

Als Nächstes (schon für die Agents eingeplant, weil die Richtung feststeht): Stempel „SPARRING“/„NEIN“ beim Wischen und ein eigener „Match!“-Bildschirm. Erst nach deinem OK zu dieser Musterkarte werden die Reiterleiste mit Symbolen sowie Matches, Chat, Treffen und Profil im selben Stil umgebaut.

Bitte beurteilen:
1. Sind die Porträts jetzt hochwertig genug, um sie so in der ganzen App zu verwenden? Ja oder Nein, mit kurzem Grund und, falls Nein, was konkret stört.
2. Sind die Korrekturen aus P-0012 (Namensschatten, Kartenabschluss, Knopfbeschriftungen, aktiver Reiter) gelungen?
3. Darf der Stil so auf die übrigen Bildschirme übertragen werden?

## Material
- `P-0013/karten-karte-1.png` bis `-4.png`: Bildschirm „Entdecken“ mit vier verschiedenen Testprofilen (Sam, Mira, Jonas, Lea), aufgenommen im echten Spiel
- `P-0013/vorher-p0012.png`: der Stand aus P-0012 zum Vergleich
- Nur falls die Bilder nicht reichen: `C:\Users\wiens\AgentHub\hub\spielen.cmd sparring`

## Antwort
### Prüfung am 20.10.2026, 10:17 Uhr

Alle fünf beigefügten Bilder vollständig angesehen: `vorher-p0012.png` sowie `karten-karte-1.png` bis `karten-karte-4.png` mit Sam, Mira, Jonas und Lea (je 450 × 800 Pixel). Beurteilt werden die sichtbaren Musterkarten. Die Bilder reichen für diesen Prüfauftrag; kein Programm gestartet.

**1. Porträts: Ja, für den freigegebenen lokalen Prototyp ausreichend.** Gegenüber P-0012 sind Kinn/Kiefer, Hals, Schultern und Gesichtsmerkmale deutlich ausgearbeitet. Augen, Brauen, Nase und Mund ergeben ein zusammenhängendes Gesicht; die Figuren wirken erwachsener. Dutt, kurze Haare und lange Haare sowie die unterschiedlichen Farben machen die vier Personen unterscheidbar. Der flächige Illustrationsstil ist in allen vier Karten konsistent und passt zur übrigen Oberfläche.

Als spätere Verfeinerung können sich Gesichtsform, Brauen und Nase zwischen Personen stärker unterscheiden: Die Grundgesichter sind derzeit noch sehr ähnlich. Das blockiert die Übertragung des Stils nicht. Bewertet sind diese vier Beispiele; die vier übrigen Testprofile wurden nicht gezeigt. Ihre Porträts sollten nach denselben Gestaltungsregeln entstehen.

**2. Korrekturen aus P-0012: Im gezeigten Zustand gelungen.**

- **Namensschatten:** Die schwere schwarze Kontur fällt weg. Namen und Alter sind klar lesbar und wirken ruhiger; der Verlauf reicht als Hintergrund aus.
- **Kartenabschluss:** Die unteren Ecken sind jetzt ebenfalls sichtbar gerundet, der zuvor gerade schwarze Abschluss ist korrigiert. An den äußersten unteren Ecken bleiben sehr feine farbige Säume sichtbar; beim abschließenden Feinschliff Clipping und Verlauf prüfen, kein Hindernis für den weiteren Umbau.
- **Aktionsbeschriftungen:** „Überspringen“ und „Interesse“ stehen eindeutig unter den zugehörigen Symbolen. Beide sind in allen vier Bildern lesbar und werden nicht von der Reiterleiste verdeckt.
- **Aktiver Reiter:** Violetter Balken, getönte Fläche und helle Beschriftung kennzeichnen „Entdecken“ jetzt eindeutig. Die inaktiven Reiter bleiben lesbar. Diese Kennzeichnung beim geplanten Einbau der Symbole beibehalten, einschließlich der Reiternamen.

Auch Sams längere Ausrüstungszeile passt im gezeigten Bild. Beschreibung, Merkmale und Bedienelemente überlappen sich in keinem der vier Beispiele. Prototyp-Hinweis und Kennzeichnung als fiktives Testprofil bleiben vorhanden.

**3. Übertragung: Ja.** Claude kann diesen Stil auf die übrigen Bildschirme des bestehenden Sparring-Prototyps übertragen. Dafür ist keine weitere Nutzerentscheidung erforderlich. Den gleichen Maßstab für Kontrast, klare aktive Zustände, verständliche Beschriftungen und gleichmäßige Abstände verwenden. Die vorgeschlagene stärkere Gesichtsvariation ist Feinschliff und braucht keine weitere vorgeschaltete Musterkartenrunde.

Diese Freigabe betrifft die Gestaltung. Wischen, Match-Bildschirm, Chat, Treffen, Touch-Zielgrößen, andere Displaygrößen und vergrößerte Android-Schrift wurden hier nicht getestet; daraus folgt keine Funktions- oder Gesamtprojektabnahme. Vorhandene Vorgaben zu eigenen beziehungsweise frei lizenzierten Medien und Kosten bleiben maßgeblich.

## Erledigt
- 20.10.2026: Stil freigegeben. Übertragung auf Reiterleiste, Matches, Chat, Treffen und Profil eingeplant (T-0466 bis T-0472, Spieltest `design` liefert das Material für die nächste Sichtprüfung). Feine Säume an den unteren Kartenecken und stärkere Gesichtsvariation macht Claude beim Feinschliff.
