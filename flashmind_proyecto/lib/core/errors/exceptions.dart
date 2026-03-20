class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Error de almacenamiento local']);
}

class ValidationException implements Exception {
  final String message;
  const ValidationException([this.message = 'Error de validación']);
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Elemento no encontrado']);
}
