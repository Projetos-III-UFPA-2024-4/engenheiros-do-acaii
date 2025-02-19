import { View, Text, TouchableOpacity, StyleSheet } from "react-native";
import { FontAwesome5 } from "@expo/vector-icons";

interface AlertCardProps {
  title: string;
  description: string;
  action1Text: string;
  action2Text: string;
  onPressAction1: () => void;
  onPressAction2: () => void;
}

export default function AlertCard({
  title,
  description,
  action1Text,
  action2Text,
  onPressAction1,
  onPressAction2,
}: AlertCardProps) {
  return (
    <View style={styles.cardContainer}>
      <View style={styles.iconContainer}>
        <FontAwesome5 name="exclamation-triangle" size={30} color="#DFA200" />
      </View>
      <View style={styles.textContainer}>
        <Text style={styles.title}>{title}</Text>
        <Text style={styles.description}>{description}</Text>
        <View style={styles.actionsContainer}>
          <TouchableOpacity onPress={onPressAction1}>
            <Text style={styles.action1}>{action1Text}</Text>
          </TouchableOpacity>
          <TouchableOpacity onPress={onPressAction2}>
            <Text style={styles.action2}>{action2Text}</Text>
          </TouchableOpacity>
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  cardContainer: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "#FFFFFF",
    borderRadius: 10,
    padding: 16,
    shadowColor: "#000",
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
    marginVertical: 10,
    alignSelf: "stretch", // 🔥 Garante que o card não expanda para ocupar toda a tela
  },
  iconContainer: {
    marginRight: 10,
  },
  textContainer: {
    flex: 1,
  },
  title: {
    fontSize: 16,
    fontWeight: "bold",
    color: "#000",
  },
  description: {
    fontSize: 14,
    color: "#444",
    marginTop: 4,
  },
  actionsContainer: {
    flexDirection: "row",
    justifyContent: "space-between",
    marginTop: 10,
  },
  action1: {
    color: "#6A0DAD", // Roxo
    fontWeight: "bold",
    fontSize: 14,
  },
  action2: {
    color: "#D32F2F", // Vermelho
    fontWeight: "bold",
    fontSize: 14,
  },
});
