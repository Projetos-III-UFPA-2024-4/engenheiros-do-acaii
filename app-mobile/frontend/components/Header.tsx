import { View, Text, Image, TouchableOpacity, StyleSheet } from 'react-native';
import { useRouter } from 'expo-router';
import { FontAwesome5 } from '@expo/vector-icons';

interface CustomHeaderProps {
  title: string; // Texto do título
  imageSource: any; // Imagem no cabeçalho (requerida via require ou URI)
}

export default function CustomHeader({ title, imageSource }: CustomHeaderProps) {
  const router = useRouter();

  return (
    <View style={styles.headerContainer}>
      {/* Botão de voltar */}
      <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
        <FontAwesome5 name="arrow-left" size={20} color="gray" />
      </TouchableOpacity>

      {/* Título */}
      <Text style={styles.title}>{title}</Text>

      {/* Imagem à direita */}
      <Image source={imageSource} style={styles.image} resizeMode="contain" />
    </View>
  );
}

const styles = StyleSheet.create({
  headerContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: 16,
  },
  backButton: {
    padding: 20,
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#000',
    textAlign: 'center',
    flex: 1, // Faz o título ocupar espaço e centralizar
  },
  image: {
    width: 150,
    height: 150,
  },
});
