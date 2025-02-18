import { View, Text } from 'react-native';
import CustomHeader from '@/components/Header';

export default function SettingsScreen() {
  return (
    <View style={{ }}>
      <CustomHeader 
        title="Configurações"
        imageSource={require('@/assets/images/logo.svg')} // Substitua pelo caminho correto da imagem
      />
    </View>
  );
}
