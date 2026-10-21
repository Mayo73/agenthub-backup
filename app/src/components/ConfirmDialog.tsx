import React from 'react';
import { Modal, View, Text, Pressable, StyleSheet } from 'react-native';
import { colors, sizes } from '../theme';

type Props = {
  visible: boolean;
  title: string;
  message: string;
  confirmLabel: string;
  onConfirm: () => void;
  onCancel: () => void;
};

export default function ConfirmDialog({
  visible,
  title,
  message,
  confirmLabel,
  onConfirm,
  onCancel,
}: Props) {
  return (
    <Modal
      transparent={true}
      animationType="fade"
      onRequestClose={onCancel}>
      <View style={styles.overlay}>
        <View style={styles.dialog}>
          <Text style={styles.title}>{title}</Text>
          <Text style={styles.message}>{message}</Text>
          <View style={styles.buttons}>
            <Pressable
              onPress={onCancel}
              testID="confirm-no"
              style={styles.buttonNo}>
              <Text style={styles.buttonTextNo}>Abbrechen</Text>
            </Pressable>
            <Pressable
              onPress={onConfirm}
              testID="confirm-yes"
              style={styles.buttonYes}>
              <Text style={styles.buttonText}>{confirmLabel}</Text>
            </Pressable>
          </View>
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.7)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  dialog: {
    backgroundColor: colors.card,
    borderRadius: sizes.radiusCard,
    padding: sizes.normal,
    width: '80%',
    alignItems: 'center',
  },
  title: {
    fontSize: sizes.title,
    color: colors.text,
    fontWeight: '700',
    marginBottom: sizes.gap,
  },
  message: {
    fontSize: sizes.normal,
    color: colors.text,
    textAlign: 'center',
    marginBottom: sizes.gap,
  },
  buttons: {
    flexDirection: 'row',
    gap: sizes.gap,
    marginTop: sizes.gap,
  },
  buttonNo: {
    flex: 1,
    height: sizes.button,
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: sizes.radius,
    backgroundColor: colors.raised,
  },
  buttonYes: {
    flex: 1,
    height: sizes.button,
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: sizes.radius,
    backgroundColor: colors.pass,
  },
  buttonTextNo: {
    color: colors.text,
    fontSize: sizes.normal,
    fontWeight: '600',
  },
  buttonText: {
    color: colors.text,
    fontSize: sizes.normal,
    fontWeight: '600',
  },
});
