---
{"dg-publish":true,"permalink":"/welcome/","tags":["readme"],"dg-note-properties":{"tags":["readme"]}}
---


# Daggerheart-Kampagnen-Vault

> Spieler-Vault für eine laufende Daggerheart-Kampagne. Einstieg über die [[00 - Index/Kampagne MOC\|Kampagne MOC]].

## Struktur
- `00 - Index/` — Maps of Content (zentrale Übersichten)
- `01 - Mein Charakter/` — eigener PC, Backstory, Charakter-Bau
- `02 - Party/` — Mit-Spieler-Charaktere, Gruppen-Dynamik
- `03 - NPCs/` — alle NPCs (flach, gefiltert per Frontmatter)
- `04 - Welt/` — Orte, Fraktionen, Pantheon, Geschichte, Glossar
- `05 - Sessions/` — Session-Protokolle, chronologisch
- `06 - Plotfäden/` — offene und abgeschlossene Mysterien
- `07 - Items/` — magische Gegenstände, Quest-Items
- `08 - Mechaniken/` — Hausregeln, Spickzettel
- `99 - Templates/` — Templater-Vorlagen

## Voraussetzungen (Plugins)
- **Dataview** — wird in allen MOCs / Übersichten verwendet
- **Templater** — wird in allen Templates verwendet (insb. `Session.md`)

In Obsidian aktivieren:
1. Settings → Community plugins → Browse → "Dataview" installieren & aktivieren
2. Settings → Community plugins → Browse → "Templater" installieren & aktivieren
3. Templater-Settings: **Template folder location** auf `99 - Templates` setzen

## Frontmatter-Konventionen
- `type:` immer setzen — `pc` / `npc` / `location` / `faction` / `session` / `plot` / `item` / `lore` / `notes` / `moc` / `index`
- Daggerheart-Spielbegriffe in Werten **englisch** (z. B. `class: Bard`), Beschreibungstext **deutsch**
- `status:` für veränderliche Entitäten (`active` / `inactive` / `dead` / `open` / `resolved` / `unknown`)
- Wikilinks in Frontmatter in Anführungszeichen: `location: "[[Stadt X]]"`

## Verlinkungs-Prinzip
- Sessions verlinken alles, was in ihnen vorkam → Backlinks zeigen automatisch die Auftritts-Geschichte jeder Entität.
- NPCs verlinken Orte und Fraktionen, nicht umgekehrt.
- Plotfäden verlinken Schlüssel-NPCs/-Orte/-Sessions.
- Spekulationen kommen direkt auf die Entitäts-Seite, in einer `> [!note] Vermutung`-Callout-Box.

## Aktueller Stand
- **Eigener Charakter:** [[01 - Mein Charakter/Lord Percival Ashwood\|Lord Percival Ashwood]] (Seraph, Schnee-Adler-Butler aus [[04 - Welt/Orte/Schauplätze/Sternenfall\|Sternenfall]]). Konzept steht; Daggerheart-Mechanik (Stats, Subclass, finale Ancestry-Ausgestaltung) noch zu finalisieren.
- **Setting:** [[04 - Welt/Noryndal\|Noryndal]] / *Das gefrorene Tal* — siehe [[00 - Index/Kampagne MOC\|Kampagne MOC]].
