import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static const String _accidentesUrl = 'ACCIDENTES_API_URL';
  static const String _parkingBaseUrl = 'PARKING_API_BASE_URL';
  static const String _email = 'AUTH_EMAIL';
  static const String _password = 'AUTH_PASSWORD';
  static const String _accidentesConnectTimeout = 'ACCIDENTES_CONNECT_TIMEOUT';
  static const String _accidentesReceiveTimeout = 'ACCIDENTES_RECEIVE_TIMEOUT';
  static const String _parkingConnectTimeout = 'PARKING_CONNECT_TIMEOUT';
  static const String _parkingReceiveTimeout = 'PARKING_RECEIVE_TIMEOUT';

  static String get accidentesUrl => dotenv.get(_accidentesUrl);

  static String get parkingBaseUrl => dotenv.get(_parkingBaseUrl);

  static String get email => dotenv.get(_email);

  static String get password => dotenv.get(_password);

  static int get accidentesConnectTimeout =>
      int.parse(dotenv.get(_accidentesConnectTimeout));

  static int get accidentesReceiveTimeout =>
      int.parse(dotenv.get(_accidentesReceiveTimeout));

  static int get parkingConnectTimeout =>
      int.parse(dotenv.get(_parkingConnectTimeout));

  static int get parkingReceiveTimeout =>
      int.parse(dotenv.get(_parkingReceiveTimeout));
}
