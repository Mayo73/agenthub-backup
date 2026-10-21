import type { Filter, Level, Profile } from './types';
import { LEVELS } from './demoData';

export type { Filter };

/** Leerer Filter mit leeren Listen für arts und levels. */
export function emptyFilter(): Filter {
  return { arts: [], levels: [] };
}

/** Filtert Profile nach Kampfsportart und Erfahrungsstufe.
 * - Leere `arts` zeigt alle Kampfsportarten
 * - Leere `levels` zeigt alle Erfahrungsstufen
 * - Sonst nur Profile, deren `art` in `f.arts` und `level` in `f.levels` steht
 * - Reihenfolge der Profile bleibt erhalten
 */
export function applyFilter(profiles: Profile[], f: Filter): Profile[] {
  if (f.arts.length === 0 && f.levels.length === 0) {
    return profiles;
  }

  const artsSet = new Set(f.arts);
  const levelsSet = new Set(f.levels);

  return profiles.filter((p) => {
    const artMatch = f.arts.length === 0 || artsSet.has(p.art);
    const levelMatch = f.levels.length === 0 || levelsSet.has(p.level);
    return artMatch && levelMatch;
  });
}

/** Prüft, ob der Filter aktiv ist (mindestens eine Liste nicht leer). */
export function isFilterActive(f: Filter): boolean {
  return f.arts.length > 0 || f.levels.length > 0;
}

/** Toggle: neue Liste ohne `value`, wenn enthalten, sonst mit `value` am Ende.
 * Die Eingabeliste bleibt unverändert.
 */
export function toggle<T>(list: T[], value: T): T[] {
  if (list.includes(value)) {
    return list.filter((v) => v !== value);
  }
  return [...list, value];
}

/** Beschreibt den Filter als lesbare Zeichenkette.
 * - `''` wenn nicht aktiv
 * - Kampfsportarten mit `, ` verbunden
 * - Erfahrungsstufen als Wörter aus `LEVELS` mit `, ` verbunden
 * - Beide Teile (wenn vorhanden) mit ` · ` getrennt
 */
export function describeFilter(f: Filter): string {
  if (!isFilterActive(f)) {
    return '';
  }

  const parts: string[] = [];

  if (f.arts.length > 0) {
    parts.push(f.arts.join(', '));
  }

  if (f.levels.length > 0) {
    const levelNames = f.levels.map((lvl) => LEVELS[lvl]);
    parts.push(levelNames.join(', '));
  }

  return parts.join(' · ');
}
