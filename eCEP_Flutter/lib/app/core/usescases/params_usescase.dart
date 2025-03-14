abstract class ParamsUseCase<Type, Params> {
  Future<Type> execute(Params params);
}