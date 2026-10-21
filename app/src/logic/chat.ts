import type { AppData, Match, Message } from './types';

export const MAX_MESSAGE_LENGTH = 500;

/** Prüft, ob der Benutzer in diesem Match schreiben darf. */
export function canWrite(data: AppData, matchId: string, userId: string): boolean {
  const match = data.matches.find(m => m.id === matchId);
  if (!match || match.endedBy !== '') {
    return false;
  }
  if (match.a !== userId && match.b !== userId) {
    return false;
  }
  const a = match.a;
  const b = match.b;
  // Prüfen, ob der Benutzer den anderen blockiert hat oder vom anderen geblockt wurde
  if (data.blocks.includes(`${a}>${b}`) || data.blocks.includes(`${b}>${a}`)) {
    if (userId === a && data.blocks.includes(`${b}>${a}`)) {
      // p01 ist von p02 geblockt, kann nicht schreiben
      return false;
    }
    if (userId === b && data.blocks.includes(`${a}>${b}`)) {
      // p02 ist von p01 geblockt, kann nicht schreiben
      return false;
    }
  }
  return true;
}

/** Sendet eine Nachricht in einem Match. */
export function sendMessage(
  data: AppData,
  matchId: string,
  from: string,
  text: string
): AppData {
  const trimmed = text.trim();
  if (trimmed === '' || trimmed.length > MAX_MESSAGE_LENGTH || !canWrite(data, matchId, from)) {
    return data;
  }

  // größtes vorhandenes n finden oder 1, wenn es keine gibt
  let maxN = 0;
  for (const msg of data.messages) {
    if (msg.n > maxN) {
      maxN = msg.n;
    }
  }

  const newMessage: Message = {
    n: maxN + 1,
    matchId,
    from,
    text: trimmed,
  };

  return {
    ...data,
    messages: [...data.messages, newMessage],
  };
}

/** Liefert alle Nachrichten eines Matches in ihrer Reihenfolge. */
export function messagesOf(data: AppData, matchId: string): Message[] {
  return data.messages.filter(m => m.matchId === matchId);
}

/** Liefert die letzte Nachricht eines Matches oder undefined. */
export function lastMessage(data: AppData, matchId: string): Message | undefined {
  const msgs = messagesOf(data, matchId);
  if (msgs.length === 0) {
    return undefined;
  }
  // Nachrichten sind nach n sortiert, letztes Element ist die neueste
  return msgs[msgs.length - 1];
}
