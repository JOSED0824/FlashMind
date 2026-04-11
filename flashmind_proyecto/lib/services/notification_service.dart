import 'dart:async';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ServidorNotificaciones {
  IOWebSocketChannel? _canal;
  final String _urlServidor;
  bool _conectado = false;
  Timer? _pingTimer;
  
  final FlutterLocalNotificationsPlugin _localNotis = FlutterLocalNotificationsPlugin();

  ServidorNotificaciones({
    String urlServidor = 'wss://thrawn-runtgenographically-cullen.ngrok-free.dev/notificaciones',
  }) : _urlServidor = urlServidor {
    _inicializarNotificacionesLocales();
  }

  void _inicializarNotificacionesLocales() {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);
    _localNotis.initialize(settings: settings);
  }


  Future<void> _mostrarNotificacionAndroid(String titulo, String cuerpo) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'canal_flashmind',
      'Notificaciones Globales', 
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    
    await _localNotis.show(
      id: DateTime.now().millisecond, 
      title: titulo,
      body: cuerpo,
      notificationDetails: details,
    );
  }

  bool get conectado => _conectado;


  Future<void> conectar() async {
    try {
      _localNotis.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

      _canal = IOWebSocketChannel.connect(
        Uri.parse(_urlServidor),
        headers: {
          'ngrok-skip-browser-warning': 'true', 
          'Origin': 'http://localhost:8888',     
        }
      );
      

      await _canal!.ready;
      
      _conectado = true;
      print('✅ Conectado al servidor Ngrok Globalmente');


      _canal!.stream.listen(
        _procesarMensaje,
        onError: _manejarError,
        onDone: _manejarCierre,
      );

      _iniciarPingPong();

    } catch (e) {
      _conectado = false;
      print('❌ Error al conectar al WebSocket: $e');
    }
  }


  void _iniciarPingPong() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_conectado && _canal != null) {
        _canal!.sink.add('ping');
      }
    });
  }


  void enviarMensaje(String mensaje) {
    if (!_conectado || _canal == null) {
      print('❌ No estás conectado al servidor');
      return;
    }
    _canal!.sink.add(mensaje);
    print('📤 Mensaje enviado: $mensaje');
  }

  void enviarNotificacion({
    required String tipo,
    required String titulo,
    required String descripcion,
  }) {
    final notificacion = jsonEncode({
      'tipo': tipo,
      'titulo': titulo,
      'descripcion': descripcion,
      'timestamp': DateTime.now().toIso8601String(),
    });

    enviarMensaje(notificacion);
  }

  void _procesarMensaje(dynamic mensaje) {
    if (mensaje.toString().toLowerCase() == 'pong') return;
    try {
      final Map<String, dynamic> jsonDecode = json.decode(mensaje);
      _mostrarNotificacionAndroid(
        jsonDecode['titulo'] ?? 'Nueva Notificación',
        jsonDecode['descripcion'] ?? 'Tienes un nuevo mensaje',
      );
      
    } catch (e) {
      _mostrarNotificacionAndroid('Nueva alerta C#', mensaje.toString());
    }
  }


  void _manejarError(error) {
    _conectado = false;
    print('❌ Error Global: $error');
  }

  void _manejarCierre() {
    _conectado = false;
    _pingTimer?.cancel();
    print('🔌 Desconectado del servidor Ngrok');
  }

  Future<void> desconectar() async {
    try {
      _pingTimer?.cancel();
      await _canal?.sink.close();
      _conectado = false;
      print('🛑 Conexión cerrada');
    } catch (e) {
      print('❌ Error al desconectar: $e');
    }
  }
}

