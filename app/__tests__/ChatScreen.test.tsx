import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react-native';
import { AppDataProvider } from '../src/state/AppDataContext';
import ChatScreen from '../src/screens/ChatScreen';
import { demoData } from '../src/logic/demoData';
import type { AppData } from '../src/logic/types';

function withMatch(endedBy = '', activeId = 'p01'): AppData {
  const d = demoData();
  return { ...d, activeId, matches: [{ id: 'm1', a: 'p01', b: 'p02', endedBy }] };
}

async function renderChat(data: AppData, onBack = jest.fn(), onOpenMeeting = jest.fn()) {
  await render(
    <AppDataProvider initialData={data}>
      <ChatScreen matchId="m1" onBack={onBack} onOpenMeeting={onOpenMeeting} />
    </AppDataProvider>
  );
}

describe('ChatScreen', () => {
  test('senden', async () => {
    await renderChat(withMatch());
    await fireEvent.changeText(await screen.findByTestId('chat-input'), 'Hallo Sam');
    await fireEvent.press(screen.getByTestId('chat-send'));

    expect(await screen.findByTestId('msg-1')).toHaveTextContent('Hallo Sam');
    expect(screen.getByTestId('chat-input').props.value).toBe('');
  });

  test('leere Nachricht', async () => {
    await renderChat(withMatch());
    await fireEvent.press(await screen.findByTestId('chat-send'));

    expect(screen.queryByTestId('msg-1')).toBeNull();
    expect(screen.getByText('Noch keine Nachrichten. Schreib die erste!')).toBeOnTheScreen();
  });

  test('beendet', async () => {
    await renderChat(withMatch('p02'));

    expect(await screen.findByTestId('chat-ended')).toBeOnTheScreen();
    expect(screen.queryByTestId('chat-input')).toBeNull();
    expect(screen.queryByTestId('chat-meeting')).toBeNull();
  });

  test('Unbeteiligte', async () => {
    await renderChat(withMatch('', 'p03'));

    expect(await screen.findByText('Dieser Chat ist für die aktive Testperson nicht sichtbar.')).toBeOnTheScreen();
    expect(screen.queryByTestId('chat-input')).toBeNull();
  });

  test('Zurück und Treffen', async () => {
    const onBack = jest.fn();
    const onOpenMeeting = jest.fn();
    await renderChat(withMatch(), onBack, onOpenMeeting);

    await fireEvent.press(await screen.findByTestId('chat-back'));
    expect(onBack).toHaveBeenCalledTimes(1);

    await fireEvent.press(screen.getByTestId('chat-meeting'));
    expect(onOpenMeeting).toHaveBeenCalledWith('m1');
  });
});
