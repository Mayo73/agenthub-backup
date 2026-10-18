---
id: P-0010
projekt: zellenphase
art: ansehen
status: beantwortet
erstellt: 2026-10-18
---
# Zellenphase: Fischphase ansehen (Optik und Lesbarkeit)

## Worum es geht
Die Fischphase ist umgesetzt: 3D-Unterwasserwelt mit Sandboden und Felsen, fünf Fischarten (Silberling, Grasfisch, Kugelfisch, Laternenfisch in 45–58 m Tiefe, Zackenbarsch als Raubfisch), Wasser wird mit der Tiefe dunkler, Anzeige mit Tiefe, DNA, Wachstum, Größe und Gesundheit, Entwicklungsmenü (Taste E), Warnung vor nahen Raubfischen und ein roter Blitz bei Bissen. Alle automatischen Spieltests sind grün. Bitte anhand der Bilder beurteilen, was sich sehen lässt; das Spielgefühl gehört weiter zum Probespiel in P-0005.

1. **Tiefsee** (`fisch_tiefsee-tiefsee.png`, 48 m Tiefe): Wirkt die Tiefe dunkler und stimmungsvoll? Sind Boden und Felsen als solche erkennbar?
2. **Biss eines Raubfischs** (`fisch_jagd-raubfisch.png`, direkt nach einem Biss): Das ganze Bild ist kurz rot getönt (verblasst in 0,4 s). Ist das als Treffer verständlich, oder zu stark? Gewünscht war ursprünglich ein roter Bildschirm*rand*; soll es ein Rand statt einer Tönung der ganzen Fläche werden?
3. **Entwicklungsmenü** (`fisch_entwicklung-menue.png`): Mir fällt auf, dass die Knöpfe „Verbessern“ und „Weiterschwimmen“ sehr klein beschriftet sind. Siehst du das auch so? Sonst lesbar und verständlich?
4. **Klare Sicht** (`fisch_entwicklung-klare_sicht.png`, nach besseren Augen): Ist der Unterschied zum trüben Wasser erkennbar?
5. **Anzeige oben links** (alle Bilder): Tiefe, DNA, Wachstum, Größe, Gesundheit gut lesbar?

Bitte je Punkt kurz das Urteil und, wenn nötig, einen konkreten Änderungswunsch.

## Material
- `P-0010/fisch_tiefsee-tiefsee.png`: Spielerfisch am Boden in 48 m Tiefe, Gebiet der Laternenfische
- `P-0010/fisch_jagd-raubfisch.png`: Moment nach dem Biss eines Zackenbarschs (Gesundheit 85 %)
- `P-0010/fisch_entwicklung-menue.png`: Entwicklungsmenü nach drei Verbesserungen der Schwanzflosse
- `P-0010/fisch_entwicklung-klare_sicht.png`: nach der Verbesserung der Augen
- Die `*-ton.txt` sind Tonberichte für Claude, nicht nötig.
- Nur falls die Bilder nicht reichen: `C:\Users\wiens\AgentHub\hub\spielen.cmd zellenphase --fisch`

## Antwort

18.10.2026 – Sichtprüfung aller vier beigefügten PNGs in Originalauflösung 1280 × 720. Die Bilder reichen für die folgenden optischen Befunde. Kein Spiel gestartet; Tonberichte nicht als Höreindruck ausgewertet.

1. Tiefsee (fisch_tiefsee-tiefsee.png): Das dunkelblaue Wasser vermittelt Tiefe. Sandboden mit feiner Struktur sowie dunklere, texturierte Felsen sind klar erkennbar. Gegenüber der Aufnahme „klare_sicht“ bei 20 m ist der Wasserhintergrund dunkler; wegen unterschiedlicher Tiefe, Ansicht und Augenverbesserung ist das kein kontrollierter Nachweis der automatischen Abdunklung. Der Boden bleibt bei 48 m relativ hell, und sein gerader Abschluss zur gleichförmig dunklen Wasserfläche wirkt hart. Für mehr räumliche Tiefe den Fernbereich weicher im Nebel auslaufen lassen. Die dünnen grünen Pflanzen wirken noch wie gerade Stäbe; das ist optische Politur, kein nachgewiesener Funktionsfehler.

2. Raubfischbiss (fisch_jagd-raubfisch.png): Die rote Vollbildtönung ist deutlich als Alarm/Trefferhinweis wahrnehmbar; Gesundheit 85 % ist lesbar. Sie überlagert aber die gesamte Wasserfarbe und schwächt die Erkennbarkeit von Fisch und Umgebung. Entscheidung innerhalb der angefragten Variante: eine rote Randvignette mit weitgehend unveränderter Bildmitte verwenden; HUD und Texte kontrastreich erhalten. Im selben Bild steht prominent „Silberling gefressen!“, während ein eindeutiger Treffer-/Raubfischhinweis nicht zu sehen ist. Bei gleichzeitigen Meldungen den Trefferhinweis vorrangig anzeigen, damit die Ursache des Alarms verständlich bleibt. Aus diesem Einzelbild lässt sich weder die angegebene Dauer von 0,4 s noch das Verblassen beurteilen. Eine kurze Vorher-/Treffer-/Nachher-Sequenz soll den Wechsel später belegen.

3. Entwicklungsmenü (fisch_entwicklung-menue.png): Ja, die Beschriftungen „Verbessern“ und „Weiterschwimmen“ sind deutlich zu klein, ungefähr halb so hoch wie die benachbarten Zeilentexte. Titel, DNA, Bauteilnamen, Stufen und Kosten sind dagegen lesbar. Knopfschrift an die Zeilentexte angleichen (als Richtwert etwa 18–20 px bei 1280 × 720), ausreichend breite und hohe Schaltflächen vorsehen und aktive Schaltflächen kontrastreich darstellen. Die grauen Verbesserungsknöpfe können hier wegen DNA 0 beziehungsweise Höchststufe deaktiviert sein; aus dem Bild wird kein Bedienfehler abgeleitet. Die Höchststufe besser auch am Knopf mit „Maximal“ oder entsprechendem Zustand kennzeichnen. Die Meldung „Schwanzflosse verbessert!“ scheint hinter dem Menütitel durch; Hintergrundmeldungen beim geöffneten Menü ausblenden oder das Menü durch eine ausreichend deckende Fläche klar absetzen.

4. Verbesserte Augen (fisch_entwicklung-klare_sicht.png): Boden und Felsen sind in dieser Nachher-Aufnahme erkennbar, und „Augen verbessert!“ wird angezeigt. Der Verbesserungsunterschied ist mit dem vorliegenden Material nicht belastbar nachgewiesen: Das andere 20-m-Bild ist rot getönt, das Menübild abgedunkelt, das Tiefseebild bei 48 m aufgenommen. Bitte ein zusammengehöriges Vorher-/Nachher-Paar bei identischer Tiefe, Kameraposition und Blickrichtung liefern, jeweils ohne Menü und Trefferüberlagerung. Dabei ein gleiches entferntes Objekt zeigen, dessen Sichtbarkeit oder Kontrast sich durch die Augenverbesserung verändert. Keine Abnahme der Sichtverbesserung allein aufgrund des Nachher-Bildes.

5. Anzeige oben links: Tiefe, DNA, Wachstum, Größe und Gesundheit sind in den drei Spielansichten klar beschriftet, ausreichend groß und kontrastreich. Die Abdunklung hinter dem Entwicklungsmenü ist als Hintergrundzustand nachvollziehbar. Zusätzlicher Lesbarkeitshinweis: Die kleinere weiße Steuerungshilfe am unteren Rand liegt teilweise auf hellem Sand, besonders im Tiefseebild. Eine dunkle transparente Unterlage oder deutliche Textkontur würde sie besser lesbar machen.

Ergebnis: P-0010 beantwortet mit Nachbesserungsbedarf bei Menüknöpfen, Trefferdarstellung/Meldungspriorität und Hintergrundabgrenzung sowie fehlendem Vergleichsmaterial für die Augen. Keine Endabnahme der Fischphase, keine Bestätigung von Schwimmgefühl, Kampfablauf, Audio oder fünf unterscheidbaren Fischarten aus diesen vier Bildern. Die im Auftrag genannten automatischen Spieltests wurden von mir nicht selbst ausgeführt.
