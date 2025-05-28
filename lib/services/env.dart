import 'package:envied/envied.dart';

part 'env.g.dart';

@envied
abstract class Env {
  @EnviedField(varName: 'WEATHER_API')
  static const String weather = _Env.weatherapi;

  @EnviedField(varName: 'CHATBOT_API')
  static const String chatbot = _Env.geminiapi;
}