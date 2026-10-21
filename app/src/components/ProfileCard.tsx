import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import type { Profile } from '../logic/types';
import { LEVELS, WEIGHT_CLASSES } from '../logic/demoData';
import { colors, sizes } from '../theme';
import Avatar from './Avatar';

type Props = {
  profile: Profile;
};

/** Große Profilkarte im Stil moderner Swipe-Apps. */
export default function ProfileCard({ profile }: Props) {
  return (
    <View style={styles.container} testID="profile-card">
      {/* Plakette "Testprofil" rechts oben */}
      <View style={[styles.badge, { backgroundColor: colors.demo }]} accessibilityLabel="Testprofil">
        <Text style={[styles.badgeText, { color: colors.bg }]}>Testprofil</Text>
      </View>

      {/* Avatar mittig, size 160 */}
      <View style={styles.avatarContainer}>
        <Avatar profile={profile} size={160} />
      </View>

      {/* Name und Alter */}
      <Text style={styles.name}>{`${profile.name}, ${profile.age}`}</Text>

      {/* Chips: Kampfsportart, Level, Training */}
      <View style={styles.chipsContainer}>
        <View style={[styles.chip, { backgroundColor: colors.raised }]}>
          <Text style={[styles.chipText, { color: colors.accent2 }]}>{profile.art}</Text>
        </View>
        <View style={[styles.chip, { backgroundColor: colors.raised }]}>
          <Text style={styles.chipText}>{LEVELS[profile.level]}</Text>
        </View>
        <View style={[styles.chip, { backgroundColor: colors.raised }]}>
          <Text style={styles.chipText}>{`${profile.years} Jahre Training`}</Text>
        </View>
      </View>

      {/* Bio */}
      <Text style={styles.bio}>{profile.bio}</Text>

      {/* Drei Zeilen Details */}
      <Text style={styles.detail}>Gewichtsklasse: {WEIGHT_CLASSES[profile.weightClass]}</Text>
      <Text style={styles.detail}>Trainingstage: {profile.days.length > 0 ? profile.days.join(', ') : 'offen'}</Text>
      <Text style={styles.detail}>Ausrüstung: {profile.equipment.length > 0 ? profile.equipment.join(', ') : 'keine'}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: colors.card,
    borderRadius: sizes.radiusCard,
    padding: sizes.gap * 1.5,
    position: 'relative',
  },
  badge: {
    position: 'absolute',
    top: sizes.gap,
    right: sizes.gap,
    paddingHorizontal: sizes.small + 4,
    paddingVertical: 4,
    borderRadius: sizes.radius / 2,
  },
  badgeText: {
    color: colors.bg,
    fontSize: sizes.normal,
    fontWeight: 600,
  },
  avatarContainer: {
    alignItems: 'center',
    marginVertical: sizes.gap * 1.5,
  },
  name: {
    fontSize: sizes.hero,
    fontWeight: 700,
    color: colors.text,
    textAlign: 'center',
    marginBottom: sizes.gap,
  },
  chipsContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginBottom: sizes.gap,
  },
  chip: {
    paddingHorizontal: sizes.small + 6,
    paddingVertical: 4,
    marginRight: sizes.gap / 2,
    borderRadius: sizes.radius / 2,
  },
  chipText: {
    fontSize: sizes.normal,
    fontWeight: 500,
  },
  bio: {
    fontSize: sizes.normal,
    color: colors.muted,
    textAlign: 'center',
    marginBottom: sizes.gap * 1.5,
  },
  detail: {
    fontSize: sizes.small,
    color: colors.muted,
    textAlign: 'center',
  },
});
