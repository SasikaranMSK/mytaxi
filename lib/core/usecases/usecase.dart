import 'package:flutter/cupertino.dart';

abstract class UseCaseF<T, Params> {
  Future<T> call({Params params});
}

abstract class UseCaseFF<T, Params> {
  Future<T> call({Params params, required BuildContext context});
}

abstract class UseCaseFRR<T, Params> {
  Future<T> call({required Params params, required BuildContext context});
}

abstract class UseCaseFR<T, Params> {
  Future<T> call({required Params params});
}

abstract class UseCaseS<T, Params> {
  Stream<T> execute({Params params});
}

abstract class UseCaseSR<T, Params> {
  Stream<T> execute({required Params params});
}

abstract class UseCaseSRR<T, Params> {
  Stream<T> execute({required Params params, required BuildContext context});
}
