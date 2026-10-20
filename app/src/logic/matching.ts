import type { AppData, Match } from './types';

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
