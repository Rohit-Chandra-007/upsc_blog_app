abstract interface class Failure {
  final String message;

  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure([super.message = 'Server Failure']);
}
/// [CacheFailure] is a class that extends [Failure] class
/// and takes a [message] as a parameter and passes it to the
/// super class.

class CacheFailure extends Failure {
  CacheFailure(super.message);
}


class NetworkFailure extends Failure {
  NetworkFailure([super.message = 'Network Failure']);
}

class UnknownFailure extends Failure {
  UnknownFailure([super.message = 'Unknown Failure']);
}
