import { Modal, View, Text, TextInput, TouchableOpacity, StyleSheet, FlatList } from "react-native";
import { FontAwesome5 } from "@expo/vector-icons";
import { useState } from "react";

interface ChatModalProps {
  visible: boolean;
  onClose: () => void;
}

export default function ChatModal({ visible, onClose }: ChatModalProps) {
  const [messages, setMessages] = useState([
    { id: "1", text: "Olá! Como posso te ajudar?", sender: "bot" },
  ]);
  const [input, setInput] = useState("");

  const handleSendMessage = () => {
    if (input.trim() === "") return;
    
    const userMessage = { id: Date.now().toString(), text: input, sender: "user" };
    setMessages([...messages, userMessage]);
    
    setTimeout(() => {
      setMessages((prev) => [
        ...prev,
        { id: Date.now().toString(), text: "Desculpe, ainda estou aprendendo!", sender: "bot" }
      ]);
    }, 1000);

    setInput("");
  };

  return (
    <Modal animationType="slide" transparent={true} visible={visible}>
      <View style={styles.overlay}>
        <View style={styles.modal}>
          <View style={styles.header}>
            <Text style={styles.title}>Açaízinho - Assistente</Text>
            <TouchableOpacity onPress={onClose}>
              <FontAwesome5 name="times" size={20} color="black" />
            </TouchableOpacity>
          </View>

          <FlatList
            data={messages}
            keyExtractor={(item) => item.id}
            renderItem={({ item }) => (
              <View style={[styles.message, item.sender === "user" ? styles.userMessage : styles.botMessage]}>
                <Text style={styles.messageText}>{item.text}</Text>
              </View>
            )}
          />

          <View style={styles.inputContainer}>
            <TextInput
              style={styles.input}
              placeholder="Digite sua dúvida..."
              value={input}
              onChangeText={setInput}
            />
            <TouchableOpacity style={styles.sendButton} onPress={handleSendMessage}>
              <FontAwesome5 name="paper-plane" size={20} color="white" />
            </TouchableOpacity>
          </View>
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: "rgba(0,0,0,0.5)",
    justifyContent: "center",
    alignItems: "center",
  },
  modal: {
    width: "90%",
    backgroundColor: "#FFF",
    borderRadius: 10,
    padding: 15,
  },
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    borderBottomWidth: 1,
    borderBottomColor: "#E0E0E0",
    paddingBottom: 10,
    marginBottom: 10,
  },
  title: {
    fontSize: 18,
    fontWeight: "bold",
  },
  message: {
    padding: 10,
    borderRadius: 8,
    marginVertical: 5,
    maxWidth: "80%",
  },
  botMessage: {
    backgroundColor: "#6A0DAD",
    alignSelf: "flex-start",
  },
  userMessage: {
    backgroundColor: "#6A0DAD",
    alignSelf: "flex-end",
  },
  messageText: {
    color: "#ffff",
  },
  inputContainer: {
    flexDirection: "row",
    borderTopWidth: 1,
    borderTopColor: "#E0E0E0",
    paddingVertical: 5,
    paddingHorizontal: 10,
  },
  input: {
    flex: 1,
    height: 40,
    backgroundColor: "#fff",
    borderRadius: 8,
    paddingHorizontal: 10,
  },
  sendButton: {
    backgroundColor: "#6A0DAD",
    padding: 10,
    borderRadius: 8,
    marginLeft: 10,
  },
});
