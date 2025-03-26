# README.md para el proyecto dysaeatsflutter (Flutter)

```markdown
# DysaEats - Aplicación Móvil

Aplicación móvil para servicio de entrega de comida desarrollada con Flutter y Dart.

## Descripción

DysaEats es una plataforma completa para servicios de entrega de comida que conecta a clientes, repartidores y restaurantes. Esta aplicación móvil forma parte de un ecosistema que también incluye una aplicación web complementaria.

## Características

- **Autenticación de usuarios**: Inicio de sesión con Google y gestión de cuentas
- **Gestión de pedidos**: Crear, visualizar y dar seguimiento a pedidos
- **Seguimiento GPS en tiempo real**: Localización y seguimiento de repartidores
- **Modo repartidor**: Funcionalidades específicas para repartidores
- **Notificaciones push**: Alertas sobre nuevos pedidos y actualizaciones de estado
- **Integración con mapas**: Visualización de rutas y direcciones
- **Modo offline**: Capacidad para funcionar con conectividad limitada

## Tecnologías utilizadas

- **Flutter 3.22+**: SDK para desarrollo multiplataforma
- **Dart 3.4+**: Lenguaje de programación
- **Firebase**: Plataforma de desarrollo para aplicaciones web y móviles
  - Authentication: Gestión de usuarios
  - Firestore: Base de datos NoSQL
  - Cloud Messaging: Notificaciones push
  - Cloud Functions: Lógica de servidor serverless
- **Google Maps**: Integración de mapas y servicios de ubicación
- **Provider**: Gestión de estado
- **Geolocator**: Servicios de ubicación

## Requisitos previos

- Flutter SDK 3.22.0 o superior
- Dart 3.4.0 o superior
- Android Studio / Xcode (para desarrollo en plataformas específicas)
- Cuenta de Firebase
- Clave API de Google Maps

## Instalación

1. Clona este repositorio:
   ```bash
   git clone https://github.com/tu-usuario/dysaeatsflutter.git
   cd dysaeatsflutter

2. Instala las dependencias:

flutter pub get

3. Configura Firebase:

- Añade el archivo google-services.json a android/app/
- Añade el archivo GoogleService-Info.plist a ios/Runner/
- O utiliza FlutterFire CLI para configurar automáticamente:

dart pub global activate flutterfire_cli
flutterfire configure

4. Ejecuta la aplicación:

flutter run

Estructura del proyecto

lib/
├── main.dart           # Punto de entrada de la aplicación
├── firebase_options.dart # Configuración de Firebase
├── models/            # Modelos de datos
├── providers/         # Proveedores de estado
├── routes/            # Configuración de rutas
├── screens/           # Pantallas de la aplicación
├── services/          # Servicios y APIs
├── theme/             # Configuración de temas
├── utils/             # Utilidades y funciones auxiliares
└── widgets/           # Widgets reutilizables

Compilación para producción

Android

flutter build apk --release
# o
flutter build appbundle --release

iOS

flutter build ios --release

Luego, utiliza Xcode para generar el archivo IPA y subir a App Store Connect.
Configuración de mapas
Para que los mapas funcionen correctamente, necesitas configurar las claves API:

- Android: Añade tu clave API en android/app/src/main/AndroidManifest.xml
- iOS: Añade tu clave API en ios/Runner/AppDelegate.swift

Recursos adicionales

- Documentación de Flutter
- Documentación de Firebase
- Documentación de Google Maps Platform

Aplicación web relacionada
Este proyecto tiene una contraparte web desarrollada con Next.js. Puedes encontrarla en dysaeatsnext.
Licencia
MIT

Estos README son completos y profesionales, proporcionando toda la información necesaria para que cualquier desarrollador entienda tu proyecto, lo configure y lo ejecute. Recuerda reemplazar "tu-usuario" con tu nombre de usuario real de GitHub cuando los utilices.