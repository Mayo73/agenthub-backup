import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react-native';
import { AppDataProvider } from '../src/state/AppDataContext';
import MeetingScreen from '../src/screens/MeetingScreen';
import ChatScreen from '../src/screens/ChatScreen';
import { demoData } from '../src/logic/demoData';
import type { KeyValueStore } from '../src/logic/storage';
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

function withMeeting(activeId: string, approved: string[] = ['p01']): AppData {
  const d = demoData();
  return {
    ...d,
    activeId,
    matches: [{ id: 'm1', a: 'p01', b: 'p02', endedBy: '' }],
    meetings: [{
      matchId: 'm1',
      place: 'Uferweg',
      date: '24.10.2026',
      time: '10:00',
      form: 'Drills',
      intensity: 'locker',
      rules: '',
      proposedBy: 'p01',
      approved,
      cancelledBy: '',
    }],
  };
}

async function renderMeeting(data: AppData) {
  await render(
    <AppDataProvider store={memoryStore()} initialData={data}>
      <MeetingScreen matchId="m1" onBack={jest.fn()} />
    </AppDataProvider>
  );
}

describe('MeetingFlow', () => {
  test('wartet auf die andere Person', async () => {
    await renderMeeting(withMeeting('p01'));

    expect(await screen.findByTestId('meet-status')).toHaveTextContent('Wartet auf Zustimmung von Sam');
    expect(screen.queryByTestId('meet-approve')).toBeNull();
  });

  test('zustimmen bestätigt', async () => {
    await renderMeeting(withMeeting('p02'));
    expect(await screen.findByTestId('meet-status')).toHaveTextContent('Wartet auf deine Zustimmung');

    await fireEvent.press(screen.getByTestId('meet-approve'));

    expect(await screen.findByTestId('meet-status')).toHaveTextContent('Bestätigt von beiden');
    expect(screen.getByText('Die Teilnahme bleibt freiwillig.')).toBeTruthy();
  });

  test('Änderung verlangt neue Zustimmung', async () => {
    await renderMeeting(withMeeting('p02', ['p01', 'p02']));
    await fireEvent.changeText(await screen.findByTestId('meet-time'), '11:00');
    await fireEvent.press(screen.getByTestId('meet-propose'));

    expect(await screen.findByTestId('meet-status')).toHaveTextContent('Wartet auf Zustimmung von Alex');
  });

  test('absagen', async () => {
    await renderMeeting(withMeeting('p01'));
    await fireEvent.press(await screen.findByTestId('meet-cancel'));
    await fireEvent.press(screen.getByTestId('confirm-yes'));

    expect(await screen.findByTestId('meet-status')).toHaveTextContent('Von dir abgesagt');
    expect(screen.queryByTestId('meet-cancel')).toBeNull();
  });

  test('Status im Chat', async () => {
    await render(
      <AppDataProvider store={memoryStore()} initialData={withMeeting('p02')}>
        <ChatScreen matchId="m1" onBack={jest.fn()} onOpenMeeting={jest.fn()} />
      </AppDataProvider>
    );

    expect(await screen.findByTestId('chat-meeting-status')).toHaveTextContent('Wartet auf deine Zustimmung');
  });
});
