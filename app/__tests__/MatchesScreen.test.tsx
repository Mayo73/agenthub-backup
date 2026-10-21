import { fireEvent, render, screen, waitFor } from '@testing-library/react-native';
import MatchesScreen from '../src/screens/MatchesScreen';
import { demoData } from '../src/logic/demoData';
import type { AppData } from '../src/logic/types';
import { AppDataProvider } from '../src/state/AppDataContext';

function renderWithState(data: AppData, onOpenChat?: any) {
  return render(
    <AppDataProvider initialData={data}>
      <MatchesScreen onOpenChat={onOpenChat} />
    </AppDataProvider>
  );
}

describe('MatchesScreen', () => {
  test('zeigt das Match', async () => {
    const d = demoData();
    const newData: AppData = {
      ...d,
      matches: [...d.matches, { id: 'm1', a: 'p01', b: 'p02', endedBy: '' }],
      messages: [
        ...d.messages,
        { n: 1, matchId: 'm1', from: 'p02', text: 'Hallo Alex' },
      ],
    };

    renderWithState(newData, jest.fn());

    await waitFor(() => {
      expect(screen.getByTestId('match-name-m1')).toHaveTextContent('Sam — MMA');
      expect(screen.getByText('Hallo Alex')).toBeOnTheScreen();
    });
  });

  test('öffnet den Chat', async () => {
    const onOpenChat = jest.fn();
    const d = demoData();
    const newData: AppData = {
      ...d,
      matches: [...d.matches, { id: 'm1', a: 'p01', b: 'p02', endedBy: '' }],
      messages: [
        ...d.messages,
        { n: 1, matchId: 'm1', from: 'p02', text: 'Hallo Alex' },
      ],
    };

    renderWithState(newData, onOpenChat);

    await waitFor(() => {
      expect(screen.getByTestId('match-row-m1')).toBeTruthy();
    });

    fireEvent.press(screen.getByTestId('match-row-m1'));
    expect(onOpenChat).toHaveBeenCalledWith('m1');
  });

  test('Unbeteiligte sehen es nicht', async () => {
    const d = demoData();
    const newData: AppData = {
      ...d,
      activeId: 'p03',
      matches: [...d.matches, { id: 'm1', a: 'p01', b: 'p02', endedBy: '' }],
      messages: [
        ...d.messages,
        { n: 1, matchId: 'm1', from: 'p02', text: 'Hallo Alex' },
      ],
    };

    renderWithState(newData);

    await waitFor(() => {
      expect(screen.getByTestId('matches-empty')).toBeTruthy();
    });
    await expect(screen.findByTestId('match-row-m1')).rejects.toThrow();
  });

  test('beendet', async () => {
    const d = demoData();
    const newData: AppData = {
      ...d,
      matches: [...d.matches, { id: 'm1', a: 'p01', b: 'p02', endedBy: 'p02' }],
      messages: [
        ...d.messages,
        { n: 1, matchId: 'm1', from: 'p02', text: 'Hallo Alex' },
      ],
    };

    renderWithState(newData);

    await waitFor(() => {
      expect(screen.getByTestId('match-row-m1')).toBeTruthy();
      expect(screen.getByText('Beendet')).toBeOnTheScreen();
    });
  });

  test('ohne Matches', async () => {
    const d = demoData();

    renderWithState(d);

    await waitFor(() => {
      expect(screen.getByTestId('matches-empty')).toBeTruthy();
      expect(screen.getByText('Noch keine Matches')).toBeOnTheScreen();
      expect(
        screen.getByText(
          'Bekunde unter Entdecken Interesse. Ein Match entsteht erst, wenn beide Interesse haben.'
        )
      ).toBeOnTheScreen();
    });
  });
});
