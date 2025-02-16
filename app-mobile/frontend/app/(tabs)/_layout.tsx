import { Tabs } from 'expo-router';
import { FontAwesome5 } from '@expo/vector-icons';
import { View, StyleSheet } from 'react-native';

export default function Layout() {
  return (
    <View style={styles.container}>
      <Tabs
        screenOptions={({ route }) => ({
          tabBarIcon: ({ color, size }) => {
            let iconName;

            if (route.name === 'home') iconName = 'home';
            else if (route.name === 'energy') iconName = 'bolt';
            else if (route.name === 'light') iconName = 'solar-panel';
            else if (route.name === 'alerts') iconName = 'exclamation-triangle';
            else if (route.name === 'settings') iconName = 'cog';

            return <FontAwesome5 name={iconName} size={size} color={color} />;
          },
          tabBarActiveTintColor: '#FFA500',
          tabBarInactiveTintColor: '#DFA200',
          tabBarStyle: { backgroundColor: '#5C2D91', paddingBottom: 5, height: 60 },
          headerShown: false,
          tabBarShowLabel: false,
        })}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF', // Fundo branco para todas as telas
  },
});
