import 'package:flutter/foundation.dart';
import 'notification_service.dart';


class ProveedorNotificaciones extends ChangeNotifier {
  late ServidorNotificaciones _servicio;
  bool _conectado = false;
  String _estado = 'Desconectado';
  List<String> _historicoMensajes = [];

  ProveedorNotificaciones({
    String urlServidor = 'wss://thrawn-runtgenographically-cullen.ngrok-free.dev/notificaciones',
  }) {
    _servicio = ServidorNotificaciones(urlServidor: urlServidor);
    _estado = 'Preparado';
    notifyListeners();
  }


  bool get conectado => _conectado;
  String get estado => _estado;
  List<String> get historicoMensajes => _historicoMensajes;
  ServidorNotificaciones get servicio => _servicio;


  Future<void> conectar() async {
    _estado = 'Conectando...';
    notifyListeners();

    try {
      await _servicio.conectar();
      _conectado = _servicio.conectado;
      _estado = _conectado
          ? '✅ Conectado al servidor C#'
          : '❌ No se pudo conectar';
    } catch (e) {
      _conectado = false;
      _estado = '❌ Error: $e';
    }
    notifyListeners();
  }

  void enviarMensaje(String mensaje) {
    if (!_conectado) {
      _estado = '❌ No estás conectado';
      notifyListeners();
      return;
    }

    _servicio.enviarMensaje(mensaje);
    _historicoMensajes.add('📤 Tú: $mensaje');
    _estado = '✅ Mensaje enviado';
    notifyListeners();
  }


  void enviarNotificacion({
    required String tipo,
    required String titulo,
    required String descripcion,
  }) {
    if (!_conectado) {
      _estado = '❌ No estás conectado';
      notifyListeners();
      return;
    }

    _servicio.enviarNotificacion(
      tipo: tipo,
      titulo: titulo,
      descripcion: descripcion,
    );
    _historicoMensajes.add('📨 [$tipo] $titulo: $descripcion');
    _estado = '✅ Notificación enviada';
    notifyListeners();
  }


  Future<void> desconectar() async {
    try {
      await _servicio.desconectar();
      _conectado = false;
      _estado = '🔌 Desconectado';
      notifyListeners();
    } catch (e) {
      _estado = '❌ Error al desconectar: $e';
      notifyListeners();
    }
  }


  void limpiarHistorico() {
    _historicoMensajes.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _servicio.desconectar();
    super.dispose();
  }
}
