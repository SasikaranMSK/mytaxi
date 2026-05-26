import '../repositories/tariff_repository.dart';
import '../entities/tariff_entity.dart';

/// Use case to get all tariffs from local database
class GetAllTariffsUseCase {
  final TariffRepository repository;

  GetAllTariffsUseCase(this.repository);

  Future<List<TariffEntity>> call() async {
    return await repository.getAllTariffs();
  }
}
