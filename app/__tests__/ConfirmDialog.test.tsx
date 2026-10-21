import React from 'react';
import { fireEvent, render, screen } from '@testing-library/react-native';
import ConfirmDialog from '../src/components/ConfirmDialog';

describe('ConfirmDialog', () => {
  test('ja und nein', async () => {
    const onConfirm = jest.fn();
    const onCancel = jest.fn();

    await render(
      <ConfirmDialog
        visible={true}
        title="Test-Titel"
        message="Test-Nachricht"
        confirmLabel="Ja"
        onConfirm={onConfirm}
        onCancel={onCancel}
      />
    );

    expect(screen.getByText('Test-Titel')).toBeTruthy();
    expect(screen.getByText('Ja')).toBeTruthy();

    fireEvent.press(screen.getByTestId('confirm-yes'));
    expect(onConfirm).toHaveBeenCalledTimes(1);

    fireEvent.press(screen.getByTestId('confirm-no'));
    expect(onCancel).toHaveBeenCalledTimes(1);
  });
});
