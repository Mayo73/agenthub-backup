import React from 'react';
import { Modal, Pressable, StyleSheet, Text, View } from 'react-native';
import type { Profile } from '../logic/types';
import Avatar from './Avatar';
import { colors, sizes } from '../theme';

type Props = {
  visible: boolean;
  me: Profile;
  other: Profile;
  onChat: () => void;
  onClose: () => void;
};

/** Hinweis nach gegenseitigem Interesse mit dem Weg in den Chat. */
export default function MatchOverlay({ visible, me, other, onChat, onClose }: Props) {
  return (
    <Modal transparent={true} animationType="fade" visible={visible} onRequestClose={onClose}>
      <View style={styles.overlay}>
        <View style={styles.panel} testID="match-overlay">
          <Text style={styles.title}>Match!</Text>
          <Text style={styles.message}>{`Du und ${other.name} habt gegenseitig Interesse.`}</Text>
          <View style={styles.avatars}>
            <Avatar profile={me} size={96} />
            <Avatar profile={other} size={96} />
          </View>
          <Pressable onPress={onChat} testID="match-chat" style={styles.buttonChat}>
            <Text style={styles.buttonText}>Nachricht schreiben</Text>
          </Pressable>
          <Pressable onPress={onClose} testID="match-close" style={styles.buttonClose}>
            <Text style={styles.buttonText}>Weiter entdecken</Text>
          </Pressable>
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.85)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  panel: {
    width: '85%',
    alignItems: 'center',
    padding: sizes.gap * 2,
  },
  title: {
    fontSize: sizes.hero,
    fontWeight: '800',
    color: colors.accent,
    marginBottom: sizes.gap,
  },
  message: {
    fontSize: sizes.normal,
    color: colors.text,
    textAlign: 'center',
    marginBottom: sizes.gap * 2,
  },
  avatars: {
    flexDirection: 'row',
    gap: sizes.gap * 2,
    marginBottom: sizes.gap * 3,
  },
  buttonChat: {
    alignSelf: 'stretch',
    height: sizes.button,
    borderRadius: sizes.radius,
    backgroundColor: colors.accent,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: sizes.gap,
  },
  buttonClose: {
    alignSelf: 'stretch',
    height: sizes.button,
    borderRadius: sizes.radius,
    backgroundColor: colors.raised,
    alignItems: 'center',
    justifyContent: 'center',
  },
  buttonText: {
    color: colors.text,
    fontSize: sizes.normal,
    fontWeight: '600',
  },
});
