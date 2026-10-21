import React, { useState } from 'react';
import type { AppData, Profile } from '../logic/types';
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
  Pressable,
} from 'react-native';
import ProfileCard from '../components/ProfileCard';
import { useAppData } from '../state/AppDataContext';
import { activeProfile } from '../logic/perspective';
import { validateProfile, updateProfile } from '../logic/profileEdit';
import { toggle } from '../logic/filter';
import { ARTS, LEVELS, WEIGHT_CLASSES, DAYS } from '../logic/demoData';
import { colors, sizes } from '../theme';

export default function ProfileScreen() {
  const { data, update } = useAppData();
  const profile = activeProfile(data);
  const [editing, setEditing] = useState(false);
  const [entwurf, setEntwurf] = useState<Profile>(profile);
  const [fehler, setFehler] = useState<string[]>([]);

  const handleStartEdit = () => {
    setEntwurf({ ...profile });
    setEditing(true);
  };

  const handleNameChange = (text: string) => {
    setEntwurf((prev: Profile) => ({ ...prev, name: text }));
  };

  const handleAgeChange = (text: string) => {
    setEntwurf((prev: Profile) => ({ ...prev, age: Number(text) }));
  };

  const handleYearsChange = (text: string) => {
    setEntwurf((prev: Profile) => ({ ...prev, years: Number(text) }));
  };

  const handleBioChange = (text: string) => {
    setEntwurf((prev: Profile) => ({ ...prev, bio: text }));
  };

  const handleToggleArt = (art: string) => {
    setEntwurf((prev: Profile) => ({ ...prev, art }));
  };

  const handleSave = () => {
    const fehlerliste = validateProfile(entwurf);
    if (fehlerliste.length > 0) {
      setFehler(fehlerliste);
      return;
    }
    setFehler([]);
    update((d: AppData) => updateProfile(d, entwurf.id, entwurf));
    setEditing(false);
  };

  const handleCancel = () => {
    setEditing(false);
  };

  if (!editing) {
    return (
      <ScrollView style={styles.root} contentContainerStyle={styles.viewContainer}>
        <Text style={styles.title}>Dein Demoprofil</Text>
        <ProfileCard profile={profile} />
        <Pressable
          testID="profile-edit"
          style={[styles.button, styles.editButton]}
          onPress={handleStartEdit}>
          <Text style={styles.buttonText}>Profil bearbeiten</Text>
        </Pressable>
      </ScrollView>
    );
  }

  return (
    <KeyboardAvoidingView
      style={styles.root}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <ScrollView keyboardShouldPersistTaps="handled">
        <Text style={styles.title}>Dein Demoprofil bearbeiten</Text>

        {/* Name */}
        <Text style={styles.label}>Name</Text>
        <TextInput
          testID="edit-name"
          style={[styles.input, styles.fieldContainer]}
          value={entwurf.name}
          onChangeText={handleNameChange}
        />

        {/* Alter */}
        <Text style={styles.label}>Alter</Text>
        <TextInput
          testID="edit-age"
          style={[styles.input, styles.fieldContainer]}
          value={Number.isNaN(entwurf.age) ? '' : String(entwurf.age)}
          onChangeText={handleAgeChange}
          keyboardType="number-pad"
        />

        {/* Trainingsjahre */}
        <Text style={styles.label}>Trainingsjahre</Text>
        <TextInput
          testID="edit-years"
          style={[styles.input, styles.fieldContainer]}
          value={Number.isNaN(entwurf.years) ? '' : String(entwurf.years)}
          onChangeText={handleYearsChange}
          keyboardType="number-pad"
        />

        {/* Beschreibung */}
        <Text style={styles.label}>Beschreibung</Text>
        <TextInput
          testID="edit-bio"
          style={[styles.input, styles.fieldContainer, styles.multilineInput]}
          value={entwurf.bio}
          onChangeText={handleBioChange}
          multiline
          numberOfLines={4}
          maxLength={200}
        />

        {/* Kampfsportart */}
        <Text style={styles.label}>Kampfsportart</Text>
        <View style={styles.chipsRow}>
          {ARTS.map((art, i) => (
            <Pressable
              key={art}
              testID={`edit-art-${i}`}
              style={[
                styles.chip,
                entwurf.art === art ? { backgroundColor: colors.accent } : styles.chipDefault,
              ]}
              onPress={() => handleToggleArt(art)}
              accessibilityState={{ selected: entwurf.art === art }}>
              <Text style={entwurf.art === art ? styles.chipTextAccent : styles.chipText}>
                {art}
              </Text>
            </Pressable>
          ))}
        </View>

        {/* Erfahrung */}
        <Text style={styles.label}>Erfahrung</Text>
        <View style={styles.chipsRow}>
          {LEVELS.map((level, i) => (
            <Pressable
              key={level}
              testID={`edit-level-${i}`}
              style={[
                styles.chip,
                entwurf.level === i ? { backgroundColor: colors.accent } : styles.chipDefault,
              ]}
              onPress={() => setEntwurf((prev: Profile) => ({ ...prev, level: i as 0 | 1 | 2 }))}
              accessibilityState={{ selected: entwurf.level === i }}>
              <Text style={entwurf.level === i ? styles.chipTextAccent : styles.chipText}>
                {level}
              </Text>
            </Pressable>
          ))}
        </View>

        {/* Gewichtsklasse */}
        <Text style={styles.label}>Gewichtsklasse</Text>
        <View style={styles.chipsRow}>
          {WEIGHT_CLASSES.map((weight, i) => (
            <Pressable
              key={weight}
              testID={`edit-weight-${i}`}
              style={[
                styles.chip,
                entwurf.weightClass === i ? { backgroundColor: colors.accent } : styles.chipDefault,
              ]}
              onPress={() => setEntwurf((prev: Profile) => ({ ...prev, weightClass: i as 0 | 1 | 2 }))}
              accessibilityState={{ selected: entwurf.weightClass === i }}>
              <Text style={entwurf.weightClass === i ? styles.chipTextAccent : styles.chipText}>
                {weight}
              </Text>
            </Pressable>
          ))}
        </View>

        {/* Trainingstage */}
        <Text style={styles.label}>Trainingstage</Text>
        <View style={styles.chipsRow}>
          {DAYS.map((tag, i) => (
            <Pressable
              key={tag}
              testID={`edit-day-${tag}`}
              style={[
                styles.chip,
                entwurf.days.includes(tag) ? { backgroundColor: colors.accent } : styles.chipDefault,
              ]}
              onPress={() => setEntwurf((prev: Profile) => ({ ...prev, days: toggle(prev.days, tag) }))}
              accessibilityState={{ selected: entwurf.days.includes(tag) }}>
              <Text style={entwurf.days.includes(tag) ? styles.chipTextAccent : styles.chipText}>
                {tag}
              </Text>
            </Pressable>
          ))}
        </View>

        {/* Fehlermeldungen */}
        {fehler.length > 0 ? (
          <View testID="edit-errors" style={styles.errorContainer}>
            {fehler.map((msg, i) => (
              <Text key={i} style={styles.errorText}>{msg}</Text>
            ))}
          </View>
        ) : null}

        {/* Knöpfe */}
        <View style={styles.buttonRow}>
          <Pressable
            testID="edit-save"
            style={[styles.button, styles.saveButton]}
            onPress={handleSave}>
            <Text style={styles.buttonText}>Speichern</Text>
          </Pressable>
          <Pressable
            testID="edit-cancel"
            style={[styles.button, styles.cancelButton]}
            onPress={handleCancel}>
            <Text style={styles.cancelButtonText}>Abbrechen</Text>
          </Pressable>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: colors.bg,
  },
  viewContainer: {
    padding: sizes.gap * 2,
  },
  title: {
    fontSize: sizes.title,
    fontWeight: '600',
    color: colors.text,
    textAlign: 'center',
    marginBottom: sizes.gap * 1.5,
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
    minHeight: 120,
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
    marginRight: sizes.gap * 0.5,
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
  errorContainer: {
    marginTop: sizes.gap,
    paddingVertical: sizes.small,
    backgroundColor: colors.pass,
    borderRadius: sizes.radius,
    paddingHorizontal: sizes.gap,
  },
  errorText: {
    color: colors.text,
    fontSize: sizes.normal,
  },
  buttonRow: {
    flexDirection: 'row',
    gap: sizes.gap * 1.5,
    marginTop: sizes.gap * 2,
    marginBottom: sizes.gap * 3,
  },
  button: {
    borderRadius: sizes.radius,
    paddingVertical: sizes.small,
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: sizes.button,
  },
  editButton: {
    backgroundColor: colors.accent,
    marginTop: sizes.gap * 1.5,
  },
  saveButton: {
    flex: 1,
    backgroundColor: colors.like,
  },
  cancelButton: {
    flex: 1,
    borderWidth: 1,
    borderColor: colors.pass,
  },
  buttonText: {
    color: colors.text,
    fontSize: sizes.normal,
    fontWeight: '600',
  },
  cancelButtonText: {
    color: colors.pass,
    fontSize: sizes.normal,
    fontWeight: '600',
  },
});
