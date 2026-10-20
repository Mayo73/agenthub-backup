import { demoData } from '../src/logic/demoData';
import type { AppData, Match, Message } from '../src/logic/types';
import {
  MAX_MESSAGE_LENGTH,
  canWrite,
  sendMessage,
  messagesOf,
  lastMessage,
} from '../src/logic/chat';

describe('Chat-Logik', () => {
  const helper = (data: AppData): AppData => ({ ...data });

  const withMatch = (
    blocks: string[] = [],
    endedBy: string = ''
  ): AppData => {
    const base = demoData();
    return {
      ...base,
      matches: [{ id: 'm1', a: 'p01', b: 'p02', endedBy }],
      blocks,
    };
  };

  test('MAX_MESSAGE_LENGTH ist 500', () => {
    expect(MAX_MESSAGE_LENGTH).toBe(500);
  });

  test('Nachricht senden: trim und n=1', () => {
    const d = withMatch();
    const result = sendMessage(d, 'm1', 'p01', '  Hallo  ');
    const msgs = messagesOf(result, 'm1');
    expect(msgs).toHaveLength(1);
    expect(msgs[0]).toEqual({ n: 1, matchId: 'm1', from: 'p01', text: 'Hallo' });
  });

  test('beide schreiben abwechselnd', () => {
    const d = withMatch();
    let state = sendMessage(d, 'm1', 'p01', 'Hallo von p01');
    state = sendMessage(state, 'm1', 'p02', 'Hallo von p02');

    const msgs = messagesOf(state, 'm1');
    expect(msgs).toHaveLength(2);
    expect(msgs[0].n).toBe(1);
    expect(msgs[0].from).toBe('p01');
    expect(msgs[1].n).toBe(2);
    expect(msgs[1].from).toBe('p02');

    const last = lastMessage(state, 'm1');
    expect(last).toEqual({ n: 2, matchId: 'm1', from: 'p02', text: 'Hallo von p02' });
  });

  test('Unbeteiligte können nicht schreiben', () => {
    const d = withMatch();
    const same = sendMessage(d, 'm1', 'p03', 'Test');
    expect(same).toBe(d);
    expect(messagesOf(same, 'm1')).toHaveLength(0);
  });

  test('leerer Text wird ignoriert', () => {
    const d = withMatch();
    const same = sendMessage(d, 'm1', 'p01', '   ');
    expect(same).toBe(d);
    expect(messagesOf(same, 'm1')).toHaveLength(0);
  });

  test('zu langer Text (501 Zeichen) wird ignoriert', () => {
    const d = withMatch();
    const longText = 'a'.repeat(501);
    const same = sendMessage(d, 'm1', 'p01', longText);
    expect(same).toBe(d);
    expect(messagesOf(same, 'm1')).toHaveLength(0);
  });

  test('maximal zulässiger Text (500 Zeichen) wird gesendet', () => {
    const d = withMatch();
    const text = 'a'.repeat(500);
    const result = sendMessage(d, 'm1', 'p01', text);
    const msgs = messagesOf(result, 'm1');
    expect(msgs).toHaveLength(1);
    expect(msgs[0].text).toBe(text);
    expect(msgs[0].text.length).toBe(500);
  });

  test('beendetes Match: canWrite ist falsch', () => {
    const d = withMatch([], 'p02');
    expect(canWrite(d, 'm1', 'p01')).toBe(false);
    expect(canWrite(d, 'm1', 'p02')).toBe(false);
  });

  test('beendetes Match: keine neue Nachricht möglich', () => {
    const d = withMatch([], 'p02');
    const same = sendMessage(d, 'm1', 'p01', 'Testnachricht');
    expect(same).toBe(d);
    expect(messagesOf(same, 'm1')).toHaveLength(0);
  });

  test('blockiert: p02>p01 => p01 kann nicht schreiben', () => {
    const d = withMatch(['p02>p01']);
    expect(canWrite(d, 'm1', 'p01')).toBe(false);
    expect(canWrite(d, 'm1', 'p02')).toBe(true);

    const same = sendMessage(d, 'm1', 'p01', 'Test');
    expect(same).toBe(d);
  });

  test('blockiert: p01>p02 => p02 kann nicht schreiben', () => {
    const d = withMatch(['p01>p02']);
    expect(canWrite(d, 'm1', 'p02')).toBe(false);
    expect(canWrite(d, 'm1', 'p01')).toBe(true);

    const same = sendMessage(d, 'm1', 'p02', 'Test');
    expect(same).toBe(d);
  });

  test('unbekanntes Match: messagesOf leer', () => {
    const d = demoData();
    expect(messagesOf(d, 'm9')).toHaveLength(0);
  });

  test('unbekanntes Match: lastMessage undefined', () => {
    const d = demoData();
    expect(lastMessage(d, 'm9')).toBeUndefined();
  });

  test('Match existiert nicht: canWrite falsch', () => {
    const d = demoData();
    expect(canWrite(d, 'nonexistent', 'p01')).toBe(false);
  });
});
