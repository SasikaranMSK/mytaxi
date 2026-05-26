import '../entities/tariff_entity.dart';
import '../repositories/tariff_repository.dart';

/// Use case to get active tariffs from local database
class GetActiveTariffsUseCase {
  final TariffRepository repository;

  GetActiveTariffsUseCase(this.repository);

  Future<List<TariffEntity>> call() async {
    return await repository.getActiveTariffs();
  }
}
