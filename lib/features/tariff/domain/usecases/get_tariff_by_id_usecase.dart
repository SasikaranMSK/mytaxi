import '../entities/tariff_entity.dart';
import '../repositories/tariff_repository.dart';

/// Use case to get tariff by ID from local database
class GetTariffByIdUseCase {
  final TariffRepository repository;

  GetTariffByIdUseCase(this.repository);

  Future<TariffEntity?> call(int id) async {
    return await repository.getTariffById(id);
  }
}
