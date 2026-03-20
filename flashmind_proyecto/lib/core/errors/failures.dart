import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error de almacenamiento local']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Error de validación']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Elemento no encontrado']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Error desconocido']);
}
