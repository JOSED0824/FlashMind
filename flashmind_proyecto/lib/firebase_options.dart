// ⚠️  PLACEHOLDER — Este archivo debe ser generado por FlutterFire CLI.
//
// Pasos para configurar Firebase:
//   1. Instala FlutterFire CLI:       dart pub global activate flutterfire_cli
//   2. Configura tu proyecto:         flutterfire configure --project=TU_FIREBASE_PROJECT_ID
//   3. El CLI sobreescribirá este archivo con la configuración real.
//
// Mientras tanto, las credenciales abajo son valores de ejemplo y el app
// lanzará un error en tiempo de ejecución si intentas usarlas.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está configurado para ${defaultTargetPlatform.name}. '
          'Ejecuta: flutterfire configure',
        );
    }
  }

  // ── Reemplaza estos valores ejecutando: flutterfire configure ──────────

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDqrCqx6XLhF0LRMqvCKn42eICqOQdpYkY',
    appId: '1:259868031727:web:256865859d3990daf3391a',
    messagingSenderId: '259868031727',
    projectId: 'flashmind-46b39',
    authDomain: 'flashmind-46b39.firebaseapp.com',
    storageBucket: 'flashmind-46b39.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBEEppirMhLg_GhrNcA1dO38vLtMLYezhU',
    appId: '1:259868031727:android:88ce4af5f2e5b2dcf3391a',
    messagingSenderId: '259868031727',
    projectId: 'flashmind-46b39',
    storageBucket: 'flashmind-46b39.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'PLACEHOLDER_API_KEY',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'PLACEHOLDER_PROJECT_ID',
    storageBucket: 'PLACEHOLDER_PROJECT_ID.appspot.com',
    iosClientId: 'PLACEHOLDER_IOS_CLIENT_ID',
    iosBundleId: 'com.example.flashmindProyecto',
  );
}