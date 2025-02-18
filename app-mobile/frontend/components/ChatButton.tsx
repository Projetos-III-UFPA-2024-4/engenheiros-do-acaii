import { View, TouchableOpacity, StyleSheet } from "react-native";
import { useState } from "react";
import ChatModal from "./ChatModal";
 // Ícone SVG do Açaízinho

export default function ChatButton() {
  const [isVisible, setIsVisible] = useState(false);

  return (
    <>
      <ChatModal visible={isVisible} onClose={() => setIsVisible(false)} />

      <TouchableOpacity style={styles.fab} onPress={() => setIsVisible(true)}>
      </TouchableOpacity>
    </>
  );
}

const styles = StyleSheet.create({
  fab: {
    position: "absolute",
    bottom: 80,
    right: 20,
    backgroundColor: "#ffffff",
    width: 70,
    height: 70,
    borderRadius: 35,
    justifyContent: "center",
    alignItems: "center",
    shadowColor: "#000",
    shadowOpacity: 0.2,
    shadowRadius: 4,
    elevation: 5,
  },
  iconContainer: {
    justifyContent: "center",
    alignItems: "center",
  },
});
