import React from 'react';
import { Text, View } from 'react-native';
import type { Profile } from '../logic/types';
import { colors } from '../theme';

type Props = {
  profile: Profile;
  size: number;
};

/** Avatar als runde View mit erstem Buchstaben des Namens. */
export default function Avatar({ profile, size }: Props) {
  const firstChar = profile.name.charAt(0);
  const fontSize = Math.round(size * 0.42);

  return (
    <View
      style={{ width: size, height: size, borderRadius: size / 2, backgroundColor: profile.color }}
      testID={`avatar-${profile.id}`}>
      <Text style={{ color: colors.text, fontWeight: 700, fontSize }}>{firstChar}</Text>
    </View>
  );
}
