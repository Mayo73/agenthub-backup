import React from 'react';
import { fireEvent, render, screen, waitFor } from '@testing-library/react-native';
import { AppDataProvider } from '../src/state/AppDataContext';
import ChatScreen from '../src/screens/ChatScreen';
import { STORAGE_KEY, type KeyValueStore } from '../src/logic/storage';
import type { AppData } from '../src/logic/types';

function memoryStore(): KeyValueStore {
  let store: Record<string, string> = {};
  return {
    getItem: async (key: string) => store[key] ?? null,
    setItem: async (key: string, value: string) => {
      store[key] = value;
    },
    removeItem: async (key: string) => {
      delete store[key];
    },
  };
}

function createInitialData(matchId: string, activeId: string, endedBy: string): AppData {
  return {
    version: 1,
    activeId,
    profiles: [
      { id: 'p01', name: 'Alex', art: 'Jiu-Jitsu', level: 1, years: 4, age: 29, bio: 'Trainiert regelmäßig draußen und mag ein lockeres Tempo.', color: '#338CD9', weightClass: 1, days: ['Di', 'Do', 'Sa'], equipment: ['Mundschutz', 'Matte'] },
      { id: 'p02', name: 'Sam', art: 'MMA', level: 2, years: 7, age: 33, bio: 'Mag anspruchsvolle Einheiten und verschiedene Techniken.', color: '#D95940', weightClass: 2, days: ['Mo', 'Mi', 'Fr'], equipment: ['Handschuhe', 'Schienbeinschoner', 'Mundschutz'] },
    ],
    likes: [],
    passes: [],
    blocks: [],
    matches: [{ id: matchId, a: 'p01', b: 'p02', endedBy }],
    messages: [],
    meetings: [],
    nextMatchNo: 2,
  };
}

describe('ChatActions', () => {
  test('beenden mit Bestätigung', async () => {
    const store = memoryStore();
    const matchId = 'm1';
    const initialData = createInitialData(matchId, 'p01', '');

    render(
      <AppDataProvider store={store} initialData={initialData}>
        <ChatScreen matchId={matchId} onBack={() => {}} onOpenMeeting={() => {}} />
      </AppDataProvider>
    );

    // chat-end drücken und warten, bis Dialog erscheint
    await waitFor(() => {
      expect(screen.getByTestId('chat-end')).toBeTruthy();
    });
    fireEvent.press(screen.getByTestId('chat-end'));

    // Bestätigen und warten
    await waitFor(() => {
      fireEvent.press(screen.getByTestId('confirm-yes'));
    });

    // chat-ended vorhanden
    await waitFor(() => {
      expect(screen.getByTestId('chat-ended')).toBeTruthy();
    });
    const endedByText = screen.getByTestId('chat-ended-by');
    expect(endedByText).toHaveTextContent('Von dir beendet.');
  });

  test('abbrechen', async () => {
    const store = memoryStore();
    const matchId = 'm1';
    const initialData = createInitialData(matchId, 'p01', '');

    render(
      <AppDataProvider store={store} initialData={initialData}>
        <ChatScreen matchId={matchId} onBack={() => {}} onOpenMeeting={() => {}} />
      </AppDataProvider>
    );

    // chat-end drücken und warten
    await waitFor(() => {
      expect(screen.getByTestId('chat-end')).toBeTruthy();
    });
    fireEvent.press(screen.getByTestId('chat-end'));

    // Abbrechen und warten
    await waitFor(() => {
      fireEvent.press(screen.getByTestId('confirm-no'));
    });

    // weiterhin chat-input, kein chat-ended
    await waitFor(() => {
      expect(screen.getByTestId('chat-input')).toBeTruthy();
    });
    const endedElement = screen.queryByTestId('chat-ended');
    expect(endedElement).toBeNull();
  });

  test('andere Perspektive sieht es', async () => {
    const store = memoryStore();
    const matchId = 'm1';
    const initialData = createInitialData(matchId, 'p02', 'p01');

    render(
      <AppDataProvider store={store} initialData={initialData}>
        <ChatScreen matchId={matchId} onBack={() => {}} onOpenMeeting={() => {}} />
      </AppDataProvider>
    );

    await waitFor(() => {
      const endedByElem = screen.getByTestId('chat-ended-by');
      expect(endedByElem).toBeTruthy();
      expect(endedByElem).toHaveTextContent('Von Alex beendet.');
    });
  });

  test('blockieren', async () => {
    const store = memoryStore();
    const matchId = 'm1';
    const initialData = createInitialData(matchId, 'p01', '');

    render(
      <AppDataProvider store={store} initialData={initialData}>
        <ChatScreen matchId={matchId} onBack={() => {}} onOpenMeeting={() => {}} />
      </AppDataProvider>
    );

    // chat-block drücken und warten
    await waitFor(() => {
      expect(screen.getByTestId('chat-block')).toBeTruthy();
    });
    fireEvent.press(screen.getByTestId('chat-block'));

    // Bestätigen und warten
    await waitFor(() => {
      fireEvent.press(screen.getByTestId('confirm-yes'));
    });

    // chat-ended vorhanden
    await waitFor(() => {
      expect(screen.getByTestId('chat-ended')).toBeTruthy();
    });

    // gespeicherte Daten prüfen
    const json = await store.getItem(STORAGE_KEY);
    expect(json).toBeTruthy();
    const parsed = JSON.parse(json!);
    expect(parsed.blocks).toContain('p01>p02');
  });
});
