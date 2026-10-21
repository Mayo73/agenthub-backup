import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  FlatList,
  Platform,
  KeyboardAvoidingView,
  Pressable,
} from 'react-native';
import Avatar from '../components/Avatar';
import { messagesOf, sendMessage, canWrite, MAX_MESSAGE_LENGTH } from '../logic/chat';
import { otherId, isActive } from '../logic/matching';
import { useAppData } from '../state/AppDataContext';
import { colors, sizes } from '../theme';

type Props = {
  matchId: string;
  onBack: () => void;
  onOpenMeeting: (matchId: string) => void;
};

export default function ChatScreen({ matchId, onBack, onOpenMeeting }: Props) {
  const appData = useAppData();
  const [inputText, setInputText] = useState('');

  const me = appData.data.activeId;
  const matchById = appData.data.matches.find(m => m.id === matchId);
  // Nur die beiden Beteiligten sehen den Chat
  const visible = !!matchById && (matchById.a === me || matchById.b === me);
  const otherProfile = visible ? appData.data.profiles.find(p => p.id === otherId(matchById, me)) : undefined;

  if (!matchById || !otherProfile) {
    return (
      <KeyboardAvoidingView style={styles.root} behavior={Platform.OS === 'ios' ? 'padding' : 'height'}>
        <Text style={styles.rootTitle}>Dieser Chat ist für die aktive Testperson nicht sichtbar.</Text>
        <Pressable testID="chat-back" style={styles.backButton} onPress={onBack}>
          <Text style={styles.backText}>‹ Zurück</Text>
        </Pressable>
      </KeyboardAvoidingView>
    );
  }

  const messages = messagesOf(appData.data, matchId);
  const isEnded = !isActive(matchById);
  const canWriteResult = canWrite(appData.data, matchId, me);

  const handleSend = () => {
    const trimmed = inputText.trim();
    if (trimmed !== '' && canWriteResult) {
      appData.update(d => sendMessage(d, matchId, me, trimmed));
      setInputText('');
    }
  };

  return (
    <KeyboardAvoidingView style={styles.root} behavior={Platform.OS === 'ios' ? 'padding' : 'height'}>
      {/* Kopfzeile */}
      <View style={styles.header}>
        <Pressable testID="chat-back" style={styles.backButton} onPress={onBack}>
          <Text style={styles.backText}>‹ Zurück</Text>
        </Pressable>
        <Avatar profile={otherProfile} size={40} />
        <Text style={styles.otherName}>{otherProfile.name}</Text>
        {isActive(matchById) && (
          <Pressable testID="chat-meeting" style={styles.meetingButton} onPress={() => onOpenMeeting(matchId)}>
            <Text style={styles.meetingText}>Treffen</Text>
          </Pressable>
        )}
      </View>

      {/* Nachrichtenliste */}
      {messages.length === 0 ? (
        <Text style={styles.noMessages}>Noch keine Nachrichten. Schreib die erste!</Text>
      ) : (
        <FlatList
          data={messages}
          keyExtractor={(item) => item.n.toString()}
          renderItem={({ item }) => (
            <View
              testID={`msg-${item.n}`}
              style={[
                styles.messageBubble,
                item.from === me ? styles.myMessage : styles.otherMessage,
              ]}>
              <Text style={styles.messageText}>{item.text}</Text>
            </View>
          )}
        />
      )}

      {/* Eingabebereich oder Beendet-Hinweis */}
      {isEnded ? (
        <View testID="chat-ended" style={styles.endedContainer}>
          <Text style={styles.endedText}>Dieses Match wurde beendet. Neue Nachrichten und Treffen sind nicht möglich.</Text>
        </View>
      ) : canWriteResult ? (
        <View style={styles.inputContainer}>
          <TextInput
            testID="chat-input"
            style={styles.input}
            placeholder="Nachricht schreiben …"
            value={inputText}
            onChangeText={setInputText}
            maxLength={MAX_MESSAGE_LENGTH}
          />
          <Pressable
            testID="chat-send"
            style={[styles.sendButton, inputText.trim() === '' && styles.sendButtonDisabled]}
            onPress={handleSend}
            disabled={inputText.trim() === ''}>
            <Text style={styles.sendButtonText}>Senden</Text>
          </Pressable>
        </View>
      ) : null}
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: colors.bg,
  },
  rootTitle: {
    color: colors.text,
    fontSize: sizes.normal,
    margin: sizes.gap * 2,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: sizes.gap,
    paddingTop: sizes.gap,
    paddingBottom: 0,
  },
  backButton: {
    marginRight: 'auto',
    paddingVertical: sizes.small,
  },
  backText: {
    color: colors.accent2,
    fontSize: sizes.normal,
  },
  otherName: {
    marginLeft: sizes.gap,
    color: colors.text,
    fontSize: sizes.title,
    fontWeight: '600',
  },
  meetingButton: {
    marginLeft: 'auto',
    paddingHorizontal: sizes.gap * 2,
    paddingVertical: sizes.small,
    backgroundColor: colors.accent,
    borderRadius: sizes.radius,
  },
  meetingText: {
    color: colors.text,
    fontSize: sizes.normal,
    fontWeight: '600',
  },
  messageBubble: {
    marginHorizontal: sizes.gap,
    marginVertical: 2,
    paddingVertical: sizes.small,
    paddingHorizontal: sizes.gap * 1.5,
    borderRadius: sizes.radiusCard,
  },
  myMessage: {
    alignSelf: 'flex-end',
    backgroundColor: colors.accent,
  },
  otherMessage: {
    alignSelf: 'flex-start',
    backgroundColor: colors.raised,
  },
  messageText: {
    color: colors.text,
    fontSize: sizes.normal,
  },
  noMessages: {
    color: colors.muted,
    fontSize: sizes.normal,
    textAlign: 'center',
    marginTop: sizes.gap * 3,
  },
  inputContainer: {
    flexDirection: 'row',
    paddingHorizontal: sizes.gap,
    paddingBottom: sizes.gap,
    alignItems: 'flex-end',
  },
  input: {
    flex: 1,
    backgroundColor: colors.raised,
    color: colors.text,
    fontSize: sizes.normal,
    borderRadius: sizes.radius,
    paddingHorizontal: sizes.gap,
    paddingVertical: sizes.small,
    maxHeight: 80,
  },
  sendButton: {
    marginLeft: sizes.gap,
    backgroundColor: colors.accent,
    paddingVertical: sizes.small,
    paddingHorizontal: sizes.gap * 1.5,
    borderRadius: sizes.radius,
  },
  sendButtonDisabled: {
    backgroundColor: colors.muted,
    opacity: 0.5,
  },
  sendButtonText: {
    color: colors.text,
    fontWeight: '600',
    fontSize: sizes.normal,
  },
  endedContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: colors.bg,
  },
  endedText: {
    color: colors.muted,
    fontSize: sizes.normal,
    textAlign: 'center',
    marginHorizontal: sizes.gap * 2,
  },
});
