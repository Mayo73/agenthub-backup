import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { colors, sizes } from '../theme';

/** Vorläufiger Bildschirm, bis der echte gebaut ist. */
export default function Placeholder({ title }: { title: string }) {
  return (
    <View style={styles.box}>
      <Text style={styles.title}>{title}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  box: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  title: { color: colors.text, fontSize: sizes.title },
});
