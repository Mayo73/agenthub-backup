import { render, screen } from '@testing-library/react-native';
import React from 'react';
import Avatar from '../src/components/Avatar';
import ProfileCard from '../src/components/ProfileCard';
import { DEMO_PROFILES } from '../src/logic/demoData';

describe('ProfileCard', () => {
  it('zeigt Name, Alter und Kampfsportart', async () => {
    await render(<ProfileCard profile={DEMO_PROFILES[0]} />);

    expect(screen.getByText('Alex, 29')).toBeTruthy();
    expect(screen.getByText('Jiu-Jitsu')).toBeTruthy();
    expect(screen.getByText('Fortgeschritten')).toBeTruthy();
    expect(screen.getByText('4 Jahre Training')).toBeTruthy();
  });

  it('als Testprofil gekennzeichnet', async () => {
    await render(<ProfileCard profile={DEMO_PROFILES[0]} />);

    expect(screen.getByText('Testprofil')).toBeTruthy();
  });

  it('Merkmale', async () => {
    const profileJonas = DEMO_PROFILES[3]; // Jonas
    await render(<ProfileCard profile={profileJonas} />);

    expect(screen.getByText('Ausrüstung: keine')).toBeTruthy();
    expect(screen.getByText('Trainingstage: Mi, Sa')).toBeTruthy();
    expect(screen.getByText('Gewichtsklasse: mittel')).toBeTruthy();
  });
});

describe('Avatar', () => {
  it('Avatar zeigt den Anfangsbuchstaben', async () => {
    await render(<Avatar profile={DEMO_PROFILES[1]} size={48} />);

    expect(screen.getByText('S')).toBeTruthy();
    expect(screen.getByTestId('avatar-p02')).toBeTruthy();
  });
});
