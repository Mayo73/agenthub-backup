import React from 'react';
import { ScrollView, Text, View, Pressable, StyleSheet } from 'react-native';
import { useAppData } from '../state/AppDataContext';
import Avatar from './Avatar';
import type { Profile } from '../logic/types';
import { switchPerspective } from '../logic/perspective';
import { colors, sizes } from '../theme';

export default function PerspectiveBar() {
  const { data, update } = useAppData();

  return (
    <View style={styles.container}>
      <Text style={styles.heading}>Demo: Ansicht als</Text>
      <ScrollView horizontal showsHorizontalScrollIndicator={false}>
        {data.profiles.map((profile) => (
          <Pressable
            key={profile.id}
            testID={`perspective-${profile.id}`}
            onPress={() => update((d) => switchPerspective(d, profile.id))}
            style={[
              styles.person,
              data.activeId === profile.id && { borderWidth: 2, borderColor: colors.demo },
            ]}
            accessibilityState={{ selected: data.activeId === profile.id }}>
            <Avatar profile={profile} size={40} />
            <Text style={styles.firstName}>{profile.name.split(' ')[0]}</Text>
          </Pressable>
        ))}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    marginTop: sizes.gap,
    alignItems: 'center',
  },
  heading: {
    fontSize: sizes.normal,
    color: colors.demo,
    fontWeight: '600',
    marginBottom: sizes.gap,
  },
  person: {
    flexDirection: 'column',
    alignItems: 'center',
    marginHorizontal: 4,
    paddingVertical: 8,
  },
  firstName: {
    color: colors.text,
    fontSize: sizes.small,
    marginTop: 4,
  },
});
