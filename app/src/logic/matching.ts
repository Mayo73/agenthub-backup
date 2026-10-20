import type { AppData, Match, Profile } from './types';

/** Erzeugt einen Schlüssel für Interessen: `"von>an"`. */
export function likeKey(from: string, to: string): string {
  return `${from}>${to}`;
}

/** Prüft, ob x y blockiert hat (oder umgekehrt). */
export function isBlocked(data: AppData, x: string, y: string): boolean {
  const key1 = likeKey(x, y);
  const key2 = likeKey(y, x);
  return data.blocks.includes(key1) || data.blocks.includes(key2);
}

/** Prüft, ob x bereits bei y ge-swipet hat (Like oder Pass). */
export function hasSwiped(data: AppData, from: string, to: string): boolean {
  const key = likeKey(from, to);
  return data.likes.includes(key) || data.passes.includes(key);
}

/** Gibt das Match zwischen x und y zurück, falls existent (auch beendete). */
export function matchBetween(data: AppData, x: string, y: string): Match | undefined {
  return data.matches.find(m =>
    (m.a === x && m.b === y) || (m.a === y && m.b === x)
  );
}

/** Erstellt ein neues Like von from nach to. */
export function like(data: AppData, from: string, to: string): AppData {
  // Sich selbst mag man nicht
  if (from === to) {
    return data;
  }
  // Blockierte ignorieren
  if (isBlocked(data, from, to)) {
    return data;
  }
  // Bereits geswiped = nichts tun
  if (hasSwiped(data, from, to)) {
    return data;
  }

  const key = likeKey(from, to);
  const newLikes = [...data.likes, key];

  // Prüfen auf gegenseitiges Interesse
  const reverseKey = likeKey(to, from);
  const existingMatch = matchBetween(data, from, to);

  if (data.likes.includes(reverseKey) && !existingMatch) {
    // Neues Match erstellen
    const newMatch: Match = {
      id: `m${data.nextMatchNo}`,
      a: to,
      b: from,
      endedBy: '',
    };
    return {
      ...data,
      likes: newLikes,
      matches: [...data.matches, newMatch],
      nextMatchNo: data.nextMatchNo + 1,
    };
  }

  return {
    ...data,
    likes: newLikes,
  };
}

/** Erstellt einen Pass von from nach to. */
export function pass(data: AppData, from: string, to: string): AppData {
  // Sich selbst kann man nicht überspringen
  if (from === to) {
    return data;
  }
  // Bereits geswiped = nichts tun
  if (hasSwiped(data, from, to)) {
    return data;
  }

  const key = likeKey(from, to);
  return {
    ...data,
    passes: [...data.passes, key],
  };
}

/** Gibt alle Matches zurück, an denen userId beteiligt ist (in originaler Reihenfolge). */
export function matchesOf(data: AppData, userId: string): Match[] {
  return data.matches.filter(m => m.a === userId || m.b === userId);
}

/** Gibt die andere Person eines Matches zurück. */
export function otherId(match: Match, userId: string): string {
  if (match.a === userId) {
    return match.b;
  }
  return match.a;
}

/** Prüft, ob ein Match noch aktiv ist. */
export function isActive(match: Match): boolean {
  return match.endedBy === '';
}

/** Gibt alle Kandidaten zurück, die userId noch sieht (außer sich selbst, bewerteten, blockierten und gematchten Profilen). */
export function candidates(data: AppData, userId: string): Profile[] {
  return data.profiles.filter(p => {
    // Sich selbst ausschließen
    if (p.id === userId) {
      return false;
    }
    // Bereits bewertet (Like oder Pass)
    if (hasSwiped(data, userId, p.id)) {
      return false;
    }
    // Blockiert von p → kein Kandidat mehr für userId
    if (isBlocked(data, p.id, userId)) {
      return false;
    }
    // Bereits ein Match existiert (auch beendet)
    if (matchBetween(data, userId, p.id)) {
      return false;
    }
    return true;
  });
}

/** Beendet ein aktiv Match durch die angegebene Person. */
export function endMatch(data: AppData, matchId: string, by: string): AppData {
  const matchIndex = data.matches.findIndex(m => m.id === matchId);
  if (matchIndex === -1) {
    return data;
  }
  const match = data.matches[matchIndex];
  // Nur wenn aktiv und person beendender ist
  if (!isActive(match) || (match.a !== by && match.b !== by)) {
    return data;
  }
  const updatedMatch: Match = { ...match, endedBy: by };
  const newMatches = [...data.matches];
  newMatches[matchIndex] = updatedMatch;
  return { ...data, matches: newMatches };
}

/** Blockiert von person A nach person B und beendet ggf. aktives Match. */
export function block(data: AppData, from: string, to: string): AppData {
  if (from === to) {
    return data;
  }
  const key = likeKey(from, to);
  // Bereits blockiert → nichts tun
  if (data.blocks.includes(key)) {
    return data;
  }
  // Neues Blockieren einfügen
  const newBlocks = [...data.blocks, key];

  // Aktives Match zwischen beiden beenden
  const existingMatch = matchBetween(data, from, to);
  let matches = data.matches;
  if (existingMatch && isActive(existingMatch)) {
    const index = data.matches.findIndex(m => m.id === existingMatch.id);
    if (index !== -1) {
      const updatedMatch: Match = { ...existingMatch, endedBy: from };
      matches = [...data.matches];
      matches[index] = updatedMatch;
    }
  }

  return { ...data, blocks: newBlocks, matches };
}
