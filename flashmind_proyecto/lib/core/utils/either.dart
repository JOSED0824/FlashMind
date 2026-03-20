sealed class Either<L, R> {
  const Either();
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);
}

extension EitherExtension<L, R> on Either<L, R> {
  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;

  L get left => (this as Left<L, R>).value;
  R get right => (this as Right<L, R>).value;

  T fold<T>(T Function(L) onLeft, T Function(R) onRight) {
    return switch (this) {
      Left<L, R>(value: final v) => onLeft(v),
      Right<L, R>(value: final v) => onRight(v),
    };
  }
}
