import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'injection.dart';
import 'services/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: 'https://czpuivonujlvxwcnaewe.supabase.co',
    anonKey: 'sb_publishable_VlIvA-FHyEA6LZSTIHdUGw_R12acDHg',
  );
  await initDependencies();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => ProveedorNotificaciones(
            urlServidor: 'wss://thrawn-runtgenographically-cullen.ngrok-free.dev/notificaciones', 
          )..conectar(),
        ),
      ],
      child: const FlashMindApp(),
    ),
  );
}
