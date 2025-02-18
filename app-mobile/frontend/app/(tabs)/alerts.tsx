import { View, Text, Alert, StyleSheet } from "react-native";
import AlertCard from "@/components/Alert";
import CustomHeader from "@/components/Header";

export default function AlertsScreen() {
  return (
    <View style={styles.container}>
      <CustomHeader 
        title="Notificações"
        imageSource={require('@/assets/images/logo.svg')} // Substitua pelo caminho correto da imagem
      />

      {/* Aqui o AlertCard está estilizado para ocupar apenas o espaço necessário */}
      <AlertCard
        title="Baixa produção solar"
        description="A produção está 20% abaixo do esperado."
        action1Text="Falar com Açaízinho"
        action2Text="Avisar serviço técnico"
        onPressAction1={() => Alert.alert("Contato com Açaízinho")}
        onPressAction2={() => Alert.alert("Aviso ao serviço técnico")}
      />

      <Text style={styles.otherContent}>Outro conteúdo da página...</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
    backgroundColor: "#F8F8F8",
  },
  pageTitle: {
    fontSize: 22,
    fontWeight: "bold",
    marginBottom: 15,
  },
  otherContent: {
    marginTop: 20,
    fontSize: 16,
  },
});
