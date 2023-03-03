import 'package:newfeautre/repository.dart';
import 'package:get_it/get_it.dart';


final locator = GetIt.instance;

void initGetIt() {
  locator.registerLazySingleton<Repository>(() => Repository());
}