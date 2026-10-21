import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react-native';
import { AppDataProvider } from '../src/state/AppDataContext';
import MeetingScreen from '../src/screens/MeetingScreen';
import { demoData } from '../src/logic/demoData';
import { STORAGE_KEY, type KeyValueStore } from '../src/logic/storage';
import type { AppData } from '../src/logic/types';

function memoryStore(): KeyValueStore {
  const items: Record<string, string> = {};
  return {
    getItem: async (key: string) => items[key] ?? null,
    setItem: async (key: string, value: string) => {
      items[key] = value;
    },
    removeItem: async (key: string) => {
      delete items[key];
    },
  };
}

function withMatch(): AppData {
  const d = demoData();
  return { ...d, activeId: 'p01', matches: [{ id: 'm1', a: 'p01', b: 'p02', endedBy: '' }], meetings: [] };
}

async function renderMeeting(data: AppData, store = memoryStore(), onBack = jest.fn()) {
  await render(
    <AppDataProvider store={store} initialData={data}>
      <MeetingScreen matchId="m1" onBack={onBack} />
    </AppDataProvider>
  );
}

describe('MeetingScreen', () => {
  test('unvollständig', async () => {
    await renderMeeting(withMatch());
    await fireEvent.press(await screen.findByTestId('meet-propose'));

    expect(await screen.findByTestId('meet-missing')).toHaveTextContent('Bitte ergänzen: Ort, Datum, Uhrzeit');
  });

  test('Vorschlag senden', async () => {
    const store = memoryStore();
    await renderMeeting(withMatch(), store);
    await fireEvent.changeText(await screen.findByTestId('meet-place'), 'Stadtpark');
    await fireEvent.changeText(screen.getByTestId('meet-date'), '24.10.2026');
    await fireEvent.changeText(screen.getByTestId('meet-time'), '10:00');
    await fireEvent.press(screen.getByTestId('meet-form-2'));
    await fireEvent.press(screen.getByTestId('meet-propose'));

    expect(await screen.findByText('Änderung vorschlagen')).toBeTruthy();
    expect(screen.queryByTestId('meet-missing')).toBeNull();
    const saved = JSON.parse((await store.getItem(STORAGE_KEY)) ?? '{}');
    expect(saved.meetings).toHaveLength(1);
    expect(saved.meetings[0].place).toBe('Stadtpark');
    expect(saved.meetings[0].form).toBe('Leichtes Sparring');
    expect(saved.meetings[0].approved).toEqual(['p01']);
  });

  test('vorhandener Vorschlag wird angezeigt', async () => {
    const d = withMatch();
    d.meetings = [{
      matchId: 'm1',
      place: 'Uferweg',
      date: '24.10.2026',
      time: '10:00',
      form: 'Leichtes Sparring',
      intensity: 'locker',
      rules: '',
      proposedBy: 'p02',
      approved: ['p02'],
      cancelledBy: '',
    }];
    await renderMeeting(d);

    expect((await screen.findByTestId('meet-place')).props.value).toBe('Uferweg');
    expect(screen.getByText('Änderung vorschlagen')).toBeTruthy();
  });

  test('Zurück', async () => {
    const onBack = jest.fn();
    await renderMeeting(withMatch(), memoryStore(), onBack);
    await fireEvent.press(await screen.findByTestId('meet-back'));

    expect(onBack).toHaveBeenCalledTimes(1);
  });
});
