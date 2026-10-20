---
id: P-0012
projekt: sparring
art: ansehen
status: erledigt
erstellt: 2026-10-20
---
# Sparring: neues Design der Profilkarte ansehen

## Worum es geht
Der Nutzer fand das Aussehen der App am 19.10. „überhaupt nicht gut“ und wünscht sich ein Design wie bei modernen Dating-Apps (ohne deren Marken, Logos oder Farben). Claude hat dafür zuerst den Grundstil und den Bildschirm „Entdecken“ neu gestaltet. Bevor die übrigen Bildschirme (Matches, Chat, Treffen, Profil, Reiterleiste, Match-Bildschirm) im selben Stil umgebaut werden, bitte prüfen, ob die Richtung stimmt.

Neu:
- fast schwarzer Hintergrund, dunkle Flächen mit weichen Schatten, große runde Ecken
- eigene Akzentfarbe Violett mit Türkis (bewusst nicht die Rot-Orange-Töne bekannter Apps)
- die Profilkarte füllt den Bildschirm: großes Porträt, unten ein dunkler Verlauf mit großem Namen und Alter, Chips für Kampfsportart (violett) und Niveau (türkis), darunter Kurzbeschreibung und Merkmale
- selbst gezeichnete, illustrierte Porträts im Verlauf der Profilfarbe statt Kreis mit Initialen; Frisur, Haut- und Haarfarbe unterscheiden sich je Testprofil
- runde Aktionsknöpfe: rotes ✕ (Nein) und grünes ♥ (Ja)
- der gelbe Prototyp-Hinweis und „TESTPROFIL · fiktiv“ bleiben (Lastenheft)

Geplant danach (noch nicht umgesetzt): Stempel „SPARRING“/„NEIN“ beim Wischen, eigener „Match!“-Bildschirm, untere Leiste mit Symbolen statt Textknöpfen, Matches, Chat und Profil im selben Stil.

Bitte beurteilen:
1. Passt die Richtung (Farben, Karte, Knöpfe) zum Wunsch des Nutzers? Ja oder Nein, mit kurzem Grund.
2. Wirken die Porträts hochwertig genug, oder sollen sie anders aussehen (z. B. mehr Details, andere Proportionen)?
3. Was sollte vor dem Umbau der übrigen Bildschirme noch geändert werden?

## Material
- `P-0012/entdecken-vorher.png`: bisheriger Bildschirm „Entdecken“
- `P-0012/entdecken-neu.png`: neuer Bildschirm „Entdecken“ (Testprofil Mira)
- Nur falls die Bilder nicht reichen: `C:\Users\wiens\AgentHub\hub\spielen.cmd sparring`

## Antwort
### Prüfung am 20.10.2026, 08:11 Uhr

Beide beigefügten Screenshots `entdecken-vorher.png` und `entdecken-neu.png` vollständig angesehen (je 450 × 800 Pixel). Bewertet wird nur der sichtbare Bildschirm „Entdecken“ mit Mira, kein Android-Gerätetest, keine Wischbewegung und keine Funktionsabnahme. Die Bilder reichen für diesen Gestaltungsentscheid.

**1. Richtung: Ja.** Die große Porträtkarte, die dunkle Umgebung, Violett/Türkis und die runden Aktionen passen zum beschriebenen Wunsch nach einer modernen Swipe-App. Gegenüber dem Initialenkreis und der großen ungenutzten Fläche vorher gibt es jetzt einen klaren Blickfang. Name, Disziplin, Erfahrung und Beschreibung sind im gezeigten Zustand lesbar. Die größeren Filter sind ebenfalls eine Verbesserung. Prototyp-Hinweis und Kennzeichnung als fiktives Testprofil bleiben sichtbar. Damit kann diese Gestaltungsrichtung weitergeführt werden; das ist keine Bestätigung des persönlichen Geschmacks des Nutzers oder der gesamten App.

**2. Porträts: Noch nicht hochwertig genug für diese Richtung.** Miras Kopf besteht überwiegend aus sehr einfachen, symmetrischen Flächen, Punktaugen und einem einzelnen Mundbogen; Hals und Schultern wirken geometrisch. Der große Bildanteil verstärkt diesen Eindruck. Ein eigener Illustrationsstil ist passend, braucht aber stimmigere erwachsene Proportionen, differenziertere Gesichts- und Haarformen sowie zurückhaltende Schattierung. Nicht bloß zusätzliche Kleinteile auf die gleiche Grundform setzen. Zuerst zwei bis drei deutlich unterschiedliche Testporträts im gleichen Stil prüfen, danach auf alle acht übertragen. Fotorealismus oder bezahlte Bilder sind dafür nicht erforderlich. Die übrigen Porträts wurden nicht gezeigt und werden hier nicht bewertet.

**3. Vor beziehungsweise beim Übertragen auf die übrigen Bildschirme:**

- **Zuerst Porträt und Typografie verfeinern.** Der kräftige schwarze Schatten an „Mira, 26“ wirkt neben den schlichten Chips unnötig schwer. Einen dezenteren Textschatten verwenden; der dunkle Verlauf trägt die Lesbarkeit bereits. Name und Alter klar hervorheben, die restliche Schrift ruhiger halten.
- **Kartenabschluss vereinheitlichen.** Oben ist die Karte sichtbar rund, unten endet sie im Bild nahezu gerade und schwarz. Untere Rundungen und Verlauf so abstimmen, dass die Karte als durchgehend zusammengehörige Fläche erkennbar bleibt und die Merkmale lesbar sind.
- **Aktionen eindeutig benennen.** Kleine sichtbare Beschriftungen „Überspringen“ und „Interesse“ bei den runden Knöpfen ergänzen. Die Symbole können bleiben; die Bedeutung soll beim ersten Aufruf ohne Deutung des Herzens verständlich sein. Rot/Grün sind durch X/Herz bereits zusätzlich unterscheidbar. Tatsächliche Touch-Zielgrößen und Abstände müssen in der Android-Ansicht geprüft werden; aus dem Bild allein leite ich keine dp-Werte ab.
- **Aktiven Reiter klar kennzeichnen.** „Entdecken“ wirkt im Screenshot dunkler und schwächer als „Matches“ und „Profil“, obwohl dieser Bildschirm offen ist. Beim geplanten Umbau eine eindeutige Akzentmarkierung und gut lesbare aktive Beschriftung verwenden. Auch mit Symbolen die kurzen Reiternamen beibehalten.

Empfohlene Reihenfolge: Eine Musterkarte mit diesen Korrekturen plus weiteren Porträts vorlegen, dann den Stil konsistent auf Matches, Chat, Treffen und Profil übertragen. Prototyp- und Testprofil-Kennzeichnungen erhalten. Alles bleibt innerhalb des bestehenden Umfangs mit eigenen oder passend frei lizenzierten Medien; keine zusätzlichen Kosten oder Higgsfield-Nutzung freigegeben. Keine weitere Nutzerentscheidung für diese Nachbesserungen erforderlich.

## Erledigt
- 20.10.2026 (Claude): Richtung beibehalten. Porträts neu gezeichnet, Namensschatten dezenter, Kartenabschluss rund, Beschriftungen „Überspringen“/„Interesse“, aktiver Reiter markiert. Musterkarte mit 4 Porträts zur Prüfung in P-0013. Tickets T-0461 bis T-0465 (Stempel, Match-Bildschirm) eingeplant.
