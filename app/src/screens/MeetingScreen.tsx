import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  ScrollView,
  KeyboardAvoidingView,
  Pressable,
  Platform,
} from 'react-native';
import {
  emptyDetails,
  missingFields,
  propose,
  meetingOf,
  approve,
  cancel,
  isConfirmed,
  meetingStatus,
  type MeetingDetails,
} from '../logic/meetings';
import { otherId } from '../logic/matching';
import ConfirmDialog from '../components/ConfirmDialog';
import { FORMS, INTENSITIES } from '../logic/demoData';
import { useAppData } from '../state/AppDataContext';
import { colors, sizes } from '../theme';

type Props = {
  matchId: string;
  onBack: () => void;
};

export default function MeetingScreen({ matchId, onBack }: Props) {
  const appData = useAppData();
  const existingMeeting = meetingOf(appData.data, matchId);
  const [values, setValues] = useState<MeetingDetails>(() =>
    existingMeeting
      ? {
          place: existingMeeting.place,
          date: existingMeeting.date,
          time: existingMeeting.time,
          form: existingMeeting.form,
          intensity: existingMeeting.intensity,
          rules: existingMeeting.rules,
        }
      : emptyDetails(),
  );
  const [missingError, setMissingError] = useState('');
  const [showCancelDialog, setShowCancelDialog] = useState(false);

  const me = appData.data.activeId;
  const matchById = appData.data.matches.find(m => m.id === matchId);
  const otherProfileName = matchById ? appData.data.profiles.find(p => p.id === otherId(matchById, me))?.name : undefined;
  const isEnded = !matchById || matchById.endedBy !== '';
  const openMeeting = existingMeeting && existingMeeting.cancelledBy === '' ? existingMeeting : undefined;
  const confirmed = isConfirmed(appData.data, matchId);
  const canApprove = !!openMeeting && !openMeeting.approved.includes(me);

  const handleApprove = () => {
    appData.update(d => approve(d, matchId, me));
  };

  const handleCancel = () => {
    appData.update(d => cancel(d, matchId, me));
    setShowCancelDialog(false);
  };

  const handlePropose = () => {
    const missing = missingFields(values);
    if (missing.length > 0) {
      setMissingError(`Bitte ergänzen: ${missing.join(', ')}`);
    } else {
      appData.update(d => propose(d, matchId, me, values));
      setMissingError('');
    }
  };

  const handleSetForm = (form: string) => {
    setValues(prev => ({ ...prev, form }));
  };

  const handleSetIntensity = (intensity: string) => {
    setValues(prev => ({ ...prev, intensity }));
  };

  const handlePlaceChange = (text: string) => {
    setValues(prev => ({ ...prev, place: text }));
  };

  const handleDateChange = (text: string) => {
    setValues(prev => ({ ...prev, date: text }));
  };

  const handleTimeChange = (text: string) => {
    setValues(prev => ({ ...prev, time: text }));
  };

  const handleRulesChange = (text: string) => {
    setValues(prev => ({ ...prev, rules: text }));
  };

  return (
    <KeyboardAvoidingView style={styles.root} behavior={Platform.OS === 'ios' ? 'padding' : 'height'}>
      <ScrollView keyboardShouldPersistTaps="handled">
        {/* Kopfzeile */}
        <View style={styles.header}>
          <Pressable testID="meet-back" style={styles.backButton} onPress={onBack}>
            <Text style={styles.backText}>‹ Zurück</Text>
          </Pressable>
          <Text style={styles.title}>{`Treffen mit ${otherProfileName ?? 'Unbekannt'}`}</Text>
        </View>

        {/* Stand des Vorschlags (kommt aus den Daten, nicht aus dem Formular) */}
        <View style={styles.statusBox}>
          <Text testID="meet-status" style={[styles.statusText, confirmed && { color: colors.like }]}>
            {meetingStatus(appData.data, matchId, me)}
          </Text>
          {confirmed ? <Text style={styles.voluntaryText}>Die Teilnahme bleibt freiwillig.</Text> : null}
        </View>

        {isEnded ? (
          <Text testID="meet-ended" style={styles.infoText}>Dieses Match wurde beendet.</Text>
        ) : (
          <>
        {/* Zustimmen und Absagen */}
        {canApprove ? (
          <Pressable testID="meet-approve" style={styles.approveButton} onPress={handleApprove}>
            <Text style={styles.proposeButtonText}>Zustimmen</Text>
          </Pressable>
        ) : null}
        {openMeeting ? (
          <Pressable testID="meet-cancel" style={styles.cancelButton} onPress={() => setShowCancelDialog(true)}>
            <Text style={styles.cancelButtonText}>Treffen absagen</Text>
          </Pressable>
        ) : null}

        {/* Ort */}
        <Text style={styles.label}>Ort draußen</Text>
        <TextInput
          testID="meet-place"
          style={[styles.input, styles.fieldContainer]}
          placeholder="z. B. Stadtpark, große Wiese"
          value={values.place}
          onChangeText={handlePlaceChange}
          blurOnSubmit={false}
        />

        {/* Datum */}
        <Text style={styles.label}>Datum</Text>
        <TextInput
          testID="meet-date"
          style={[styles.input, styles.fieldContainer]}
          placeholder="TT.MM.JJJJ"
          value={values.date}
          onChangeText={handleDateChange}
          keyboardType="numbers-and-punctuation"
          blurOnSubmit={false}
        />

        {/* Uhrzeit */}
        <Text style={styles.label}>Uhrzeit</Text>
        <TextInput
          testID="meet-time"
          style={[styles.input, styles.fieldContainer]}
          placeholder="HH:MM"
          value={values.time}
          onChangeText={handleTimeChange}
          blurOnSubmit={false}
        />

        {/* Trainingsform */}
        <Text style={styles.label}>Trainingsform</Text>
        <View style={styles.chipsRow}>
          {FORMS.map((form, i) => (
            <Pressable
              key={form}
              testID={`meet-form-${i}`}
              style={[
                styles.chip,
                values.form === form ? { backgroundColor: colors.accent } : styles.chipDefault,
              ]}
              onPress={() => handleSetForm(form)}
              accessibilityState={{ selected: values.form === form }}>
              <Text style={values.form === form ? styles.chipTextAccent : styles.chipText}>
                {form}
              </Text>
            </Pressable>
          ))}
        </View>

        {/* Intensität */}
        <Text style={styles.label}>Intensität</Text>
        <View style={styles.chipsRow}>
          {INTENSITIES.map((intensity, i) => (
            <Pressable
              key={intensity}
              testID={`meet-intensity-${i}`}
              style={[
                styles.chip,
                values.intensity === intensity ? { backgroundColor: colors.accent } : styles.chipDefault,
              ]}
              onPress={() => handleSetIntensity(intensity)}
              accessibilityState={{ selected: values.intensity === intensity }}>
              <Text style={values.intensity === intensity ? styles.chipTextAccent : styles.chipText}>
                {intensity}
              </Text>
            </Pressable>
          ))}
        </View>

        {/* Regeln */}
        <Text style={styles.label}>Gemeinsame Regeln (freiwillig)</Text>
        <TextInput
          testID="meet-rules"
          style={[styles.input, styles.fieldContainer, styles.multilineInput]}
          placeholder="z. B. nur Technik, kein Vollkontakt"
          value={values.rules}
          onChangeText={handleRulesChange}
          multiline
          numberOfLines={3}
        />

        {/* Fehlerhinweis */}
        {missingError ? (
          <View testID="meet-missing" style={styles.missingContainer}>
            <Text style={styles.missingText}>{missingError}</Text>
          </View>
        ) : null}

        {/* Knopf */}
        <Pressable
          testID="meet-propose"
          style={styles.proposeButton}
          onPress={handlePropose}>
          <Text style={styles.proposeButtonText}>
            {existingMeeting ? 'Änderung vorschlagen' : 'Vorschlag senden'}
          </Text>
        </Pressable>

        {/* Hinweis */}
        <Text style={styles.infoText}>
          Treffen finden draußen statt und sind freiwillig. Absagen ist jederzeit möglich.
        </Text>
          </>
        )}
      </ScrollView>
      <ConfirmDialog
        visible={showCancelDialog}
        title="Treffen absagen?"
        message="Die andere Person sieht die Absage."
        confirmLabel="Absagen"
        onConfirm={handleCancel}
        onCancel={() => setShowCancelDialog(false)}
      />
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: colors.bg,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: sizes.gap,
    paddingTop: sizes.gap,
    paddingBottom: sizes.gap,
  },
  backButton: {
    paddingVertical: sizes.small,
  },
  backText: {
    color: colors.accent2,
    fontSize: sizes.normal,
  },
  title: {
    color: colors.text,
    fontSize: sizes.title,
    fontWeight: '600',
    marginLeft: sizes.gap,
  },
  statusBox: {
    paddingHorizontal: sizes.gap,
    paddingVertical: sizes.small,
    backgroundColor: colors.raised,
    borderRadius: sizes.radius,
  },
  statusText: {
    color: colors.text,
    fontSize: sizes.normal,
    fontWeight: '600',
  },
  voluntaryText: {
    color: colors.muted,
    fontSize: sizes.normal,
    marginTop: sizes.small,
  },
  approveButton: {
    marginTop: sizes.gap,
    backgroundColor: colors.like,
    borderRadius: sizes.radius,
    paddingVertical: sizes.small,
    alignItems: 'center',
  },
  cancelButton: {
    marginTop: sizes.gap,
    borderWidth: 1,
    borderColor: colors.pass,
    borderRadius: sizes.radius,
    paddingVertical: sizes.small,
    alignItems: 'center',
  },
  cancelButtonText: {
    color: colors.pass,
    fontSize: sizes.normal,
    fontWeight: '600',
  },
  label: {
    color: colors.text,
    fontSize: sizes.normal,
    marginTop: sizes.gap * 2,
    marginBottom: sizes.small,
  },
  fieldContainer: {
    backgroundColor: colors.raised,
    minHeight: sizes.button,
    borderRadius: sizes.radius,
    paddingHorizontal: sizes.gap,
    paddingVertical: sizes.small,
  },
  input: {
    color: colors.text,
    fontSize: sizes.normal,
  },
  multilineInput: {
    textAlignVertical: 'top',
    minHeight: 100,
  },
  chipsRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: sizes.gap * 0.5,
  },
  chip: {
    paddingHorizontal: sizes.gap,
    paddingVertical: sizes.small,
    borderRadius: sizes.radius,
    marginRight: sizes.gap,
    marginBottom: sizes.gap * 0.5,
  },
  chipDefault: {
    backgroundColor: colors.raised,
  },
  chipText: {
    color: colors.text,
    fontSize: sizes.normal,
  },
  chipTextAccent: {
    color: colors.text,
    fontSize: sizes.normal,
    fontWeight: '600',
  },
  missingContainer: {
    marginTop: sizes.gap,
    paddingVertical: sizes.small,
    backgroundColor: colors.pass,
    borderRadius: sizes.radius,
    paddingHorizontal: sizes.gap,
  },
  missingText: {
    color: colors.text,
    fontSize: sizes.normal,
  },
  proposeButton: {
    marginTop: sizes.gap * 2,
    backgroundColor: colors.accent,
    borderRadius: sizes.radius,
    paddingVertical: sizes.small,
    alignItems: 'center',
  },
  proposeButtonText: {
    color: colors.text,
    fontSize: sizes.normal,
    fontWeight: '600',
  },
  infoText: {
    color: colors.muted,
    fontSize: sizes.normal,
    textAlign: 'center',
    marginTop: sizes.gap * 2,
    marginBottom: sizes.gap,
  },
});
