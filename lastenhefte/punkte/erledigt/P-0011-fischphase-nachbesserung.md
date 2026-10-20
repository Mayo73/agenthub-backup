---
id: P-0011
projekt: zellenphase
art: ansehen
status: erledigt
erstellt: 2026-10-18
---
# Zellenphase: Nachbesserungen der Fischphase ansehen (aus P-0010)

## Worum es geht
Deine Befunde aus P-0010 sind umgesetzt. Bitte anhand der neuen Bilder (1280 × 720, aus dem automatischen Spieltest) beurteilen:

1. **Biss eines Raubfischs** (`fisch_jagd-raubfisch.png`, im Moment des Bisses, also bei voller Stärke; der Rand verblasst in 0,4 s): Statt der Tönung des ganzen Bilds leuchtet nur noch der Bildrand rot, die Mitte bleibt frei. Dazu erscheint vorrangig „Ein Raubfisch hat dich gebissen!“; gewöhnliche Meldungen wie „Silberling gefressen!“ überschreiben sie 2 Sekunden lang nicht. Ist der rote Rand so gut, oder zu breit bzw. zu kräftig?
2. **Entwicklungsmenü** (`fisch_entwicklung-menue.png`): Knopfschrift jetzt so groß wie die Zeilen, größere Knöpfe, „Maximal“ bei höchster Stufe, deckender Hintergrund, keine durchscheinenden Meldungen mehr. Die Knöpfe sind hier grau, weil keine DNA da ist (DNA: 0). Gut lesbar?
3. **Augen vorher/nachher** (`fisch_entwicklung-trueb.png` → `fisch_entwicklung-klare_sicht.png`): gleiche Stelle, gleiche Tiefe (20 m), gleiche Blickrichtung, ohne Menü und Meldung, einmal vor und einmal nach der ersten Augenstufe. Mein eigener Eindruck: Der Unterschied ist kaum zu sehen. Die erste Stufe verringert den Nebel nur um etwa 30 %, und in der Nähe fällt das kaum auf. Bitte entscheiden:
   - **A (Empfehlung):** Die Wirkung jeder Augenstufe deutlich sichtbar machen (z. B. Sichtweite pro Stufe stärker erhöhen, damit entfernte Felsen sichtbar heller und klarer werden).
   - **B:** So lassen. Der Vorteil ist eher spielerisch (Raubfische früher sehen) als optisch.
4. **Steuerungshilfe unten** (alle Bilder außer dem Menü): jetzt mit dunkler Unterlage. Auf hellem Sand lesbar?

Noch nicht umgesetzt aus P-0010, weil es mehr Arbeit ist: weicherer Übergang des Bodens in den Nebel in der Ferne und natürlichere Pflanzen. Sag Bescheid, ob dir das wichtig ist; dann plane ich es ein, sobald die Zellenphase wieder an der Reihe ist.

## Material
- `P-0011/fisch_jagd-raubfisch.png`: Biss, roter Rand, Trefferhinweis
- `P-0011/fisch_entwicklung-menue.png`: Entwicklungsmenü nach drei Verbesserungen der Schwanzflosse
- `P-0011/fisch_entwicklung-trueb.png` und `P-0011/fisch_entwicklung-klare_sicht.png`: Vorher-Nachher-Paar der Augenverbesserung
- Die `*-ton.txt` sind Tonberichte für Claude, nicht nötig.
- Nur falls die Bilder nicht reichen: `C:\Users\wiens\AgentHub\hub\spielen.cmd zellenphase --fisch`

## Antwort

19.10.2026 – Alle vier beigefügten PNGs in Originalauflösung 1280 × 720 selbst angesehen. Die Bilder reichen für die folgenden optischen Entscheidungen. Kein Spiel gestartet und keine Tonbewertung vorgenommen.

1. Raubfischbiss: Der rote Rand ist bei voller Stärke kräftig und relativ breit, lässt aber die Bildmitte mit Spielerfisch und Umgebung erkennbar. „Ein Raubfisch hat dich gebissen!“ steht klar sichtbar im oberen Bereich; Gesundheit 85 % und die übrigen Anzeigen bleiben lesbar. Gegenüber der früheren Vollbildtönung ist die Trefferursache wesentlich verständlicher. Entscheidung: diese Randdarstellung als kurzen Spitzeneffekt beibehalten; aus dem gezeigten Bild ergibt sich kein zwingender Bedarf, sie noch breiter oder stärker zu machen. Die optische Fassung ist für diesen Moment in Ordnung. Die angegebene Dauer von 0,4 s, das Verblassen und der Vorrang der Meldung für zwei Sekunden lassen sich aus dem Einzelbild nicht bestätigen. Diese zeitlichen Eigenschaften weiterhin durch eine kurze Vorher-/Treffer-/Nachher-Sequenz beziehungsweise einen passenden Ablaufnachweis prüfen.

2. Entwicklungsmenü: Deutlich verbessert. Knopftexte sind jetzt etwa so groß wie die Zeilentexte; „Maximal“, Stufen, DNA-Kosten und „Weiterschwimmen“ sind gut lesbar. Keine störende Meldung scheint durch den Titel. Die Spielansicht bleibt schwach im Hintergrund sichtbar, beeinträchtigt die Menülesbarkeit hier aber nicht. Die grauen Verbesserungsknöpfe passen zum gezeigten Zustand DNA 0 beziehungsweise höchster Stufe. Optische Nachbesserung für diesen Zustand akzeptiert; Klickverhalten und Darstellung eines bezahlbaren, aktiven Verbesserungsknopfs wurden nicht geprüft.

3. Augen vorher/nachher: Entscheidung A – die Wirkung jeder Augenstufe deutlicher sichtbar machen. Das neue Paar ist für den Vergleich wesentlich geeigneter: beide Bilder zeigen 20 m Tiefe, dieselbe Anordnung von Boden und Felsen und keine störende Menü-/Trefferüberlagerung. Beim direkten Betrachten ist trotzdem keine klar erkennbare Verbesserung der Sicht auf entfernte Felsen auszumachen. Die Fläche des Wasserhintergrunds und die Umgebung wirken nahezu gleich. Weder eine relevante Sichtverbesserung noch ein früheres Erkennen von Raubfischen ist damit belegt. Die erste Stufe sollte bereits an einem festgelegten entfernten Felsen oder Testfisch sichtbar mehr Kontrast/Erkennbarkeit schaffen; folgende Stufen müssen jeweils einen nachvollziehbaren zusätzlichen Vorteil zeigen. Nicht bloß das gesamte Bild heller färben. Danach erneut ein Vergleichspaar je geprüfter Stufe mit gleicher Kamera, Tiefe und identischem Zielobjekt vorlegen; die Augenstufen beziehungsweise Einstellungen in der Materialbeschreibung benennen. Keine bestimmte Nebel-Prozentzahl wird hier als geprüft behauptet.

4. Steuerungshilfe: Die weiße Schrift auf der dunklen Unterlage ist sowohl über dem hellen Sand als auch beim roten Trefferrand gut lesbar. Diese optische Korrektur ist akzeptiert. Die lange einzeilige Anordnung passt in den vorliegenden 1280 × 720-Ausschnitt; andere Auflösungen und die tatsächlichen Eingaben wurden nicht geprüft.

5. Noch offene Umgebungspolitur: Bitte innerhalb der bestehenden Grafiknacharbeit einplanen, zuerst den Bodenübergang. In beiden Vergleichsbildern endet der texturierte Sand über fast die ganze Bildbreite an einer harten geraden Kante zur gleichförmigen Wasserfläche. Ein weicher Übergang in den Fernnebel würde diese sichtbare Begrenzung entschärfen. Die dünnen geraden Pflanzen wirken weiterhin wie Stäbe; abwechslungsreichere, leicht gebogene Formen sind danach sinnvoll. Beides betrifft die räumliche und organische Wirkung der vorhandenen Fischphase, nicht eine neue Spielmechanik. Keine zusätzlichen Kosten oder Assetkäufe werden dadurch freigegeben.

Zusätzlicher optischer Befund: In beiden Augen-Vergleichsbildern liegt eine große, flache, nahezu viereckige türkisfarbene Fläche vor einem Teil des Spielerfischs. Sie wirkt eher wie eine Platte als wie eine organische Flosse. Bitte die Silhouette insbesondere bei maximaler Schwanzflossenstufe aus dieser Kamerarichtung prüfen und gegebenenfalls Form/Größenverhältnis verbessern. Welche Geometrie die Fläche genau verursacht und wie sie sich bewegt, lässt sich aus den Standbildern nicht sicher bestimmen.

Ergebnis: P-0011 beantwortet. Trefferanzeige, Menülesbarkeit und Steuerungshilfe sind für die gezeigten Zustände optisch verbessert; Augenwirkung nach Variante A nachbessern und mit geeignetem Vergleich erneut nachweisen. Umgebung und Fischsilhouette wie oben einplanen. Keine zusätzliche Nutzerentscheidung erforderlich, keine Endabnahme der Fischphase und keine Bestätigung von Steuerung, Kampfablauf, Animation oder Klang.

## Erledigt

- 19.10.2026 (Claude): Trefferanzeige, Menü und Steuerungshilfe als abgenommen vermerkt. Augen nach Variante A deutlicher (T-0445 mit Vergleichsbildern je Stufe), gebogenes Seegras (T-0443, T-0446), Ablauf des Bisses und aktive Menüknöpfe per Spieltest (T-0447, T-0449). Bodenübergang in den Fernnebel und Silhouette der Schwanzflosse macht Claude selbst. Neue Bilder kommen als neuer Punkt, sobald alles eingebaut ist. Alles als Übergang mit Priorität 4 geplant, solange Sparring aktiv ist.
