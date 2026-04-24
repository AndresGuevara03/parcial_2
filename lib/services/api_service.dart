import 'dart:io';

import 'package:dio/dio.dart';

import '../config/env_config.dart';
import '../models/establecimiento_model.dart';

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  late final Dio _accidentesDio = Dio(
    BaseOptions(
      baseUrl: EnvConfig.accidentesUrl,
      connectTimeout: Duration(seconds: EnvConfig.accidentesConnectTimeout),
      receiveTimeout: Duration(seconds: EnvConfig.accidentesReceiveTimeout),
    ),
  );

  late final Dio _parkingDio =
      Dio(
          BaseOptions(
            baseUrl: EnvConfig.parkingBaseUrl,
            connectTimeout: Duration(seconds: EnvConfig.parkingConnectTimeout),
            receiveTimeout: Duration(seconds: EnvConfig.parkingReceiveTimeout),
            headers: <String, dynamic>{
              HttpHeaders.acceptHeader: 'application/json',
            },
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              try {
                final isLogin = options.path.contains('/login');
                final isReadOnlyGet = options.method.toUpperCase() == 'GET';
                if (!isLogin && !isReadOnlyGet) {
                  try {
                    final token = await _ensureToken();
                    options.headers[HttpHeaders.authorizationHeader] =
                        'Bearer $token';
                  } catch (_) {
                    // El backend permite algunas operaciones sin JWT.
                    // Si el login falla, dejamos continuar la petición.
                  }
                }
                handler.next(options);
              } on DioException catch (e) {
                handler.reject(e);
              } catch (e) {
                handler.reject(
                  DioException(
                    requestOptions: options,
                    error: e,
                    type: DioExceptionType.unknown,
                    message: 'Error preparando autenticacion JWT.',
                  ),
                );
              }
            },
            onError: (error, handler) {
              if (error.response?.statusCode == 401) {
                _token = null;
              }
              handler.next(error);
            },
          ),
        );

  String? _token;

  Future<String> login() async {
    final response = await _parkingDio.post<dynamic>(
      '/login',
      data: <String, dynamic>{
        'email': EnvConfig.email,
        'password': EnvConfig.password,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final token =
          data['token'] ??
          data['access_token'] ??
          (data['data'] is Map<String, dynamic>
              ? (data['data'] as Map<String, dynamic>)['token']
              : null);
      final tokenString = token?.toString();
      if (tokenString != null && tokenString.isNotEmpty) {
        _token = tokenString;
        return tokenString;
      }
    }

    throw Exception('No fue posible obtener el token JWT.');
  }

  Future<int> fetchAccidentesCount() async {
    final response = await _accidentesDio.get<dynamic>(
      '',
      queryParameters: <String, dynamic>{r'$select': 'count(*) as total'},
    );

    final list = _extractList(response.data);
    if (list.isEmpty) {
      return 0;
    }

    final first = list.first;
    if (first is Map<String, dynamic>) {
      return int.tryParse((first['total'] ?? '0').toString()) ?? 0;
    }
    return 0;
  }

  Future<List<Map<String, dynamic>>> fetchAccidentes({
    int limit = 100000,
  }) async {
    final response = await _accidentesDio.get<dynamic>(
      '',
      queryParameters: <String, dynamic>{r'$limit': limit},
    );

    final list = _extractList(response.data);
    return list
        .whereType<Map<String, dynamic>>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  Future<List<Establecimiento>> fetchEstablecimientos() async {
    final response = await _parkingDio.get<dynamic>('/establecimientos');
    final list = _extractList(response.data);
    return list
        .whereType<Map<String, dynamic>>()
        .map(Establecimiento.fromJson)
        .toList(growable: false);
  }

  Future<Establecimiento> fetchEstablecimiento(int id) async {
    final response = await _parkingDio.get<dynamic>('/establecimientos/$id');
    final map = _extractMap(response.data);
    return Establecimiento.fromJson(map);
  }

  Future<void> createEstablecimiento(FormData data) async {
    await _parkingDio.post<dynamic>('/establecimientos', data: data);
  }

  Future<void> updateEstablecimiento(int id, FormData data) async {
    // El usuario especificó usar POST a /establecimiento-update/{id}
    await _parkingDio.post<dynamic>('/establecimiento-update/$id', data: data);
  }

  Future<void> deleteEstablecimiento(int id) async {
    await _parkingDio.delete<dynamic>('/establecimientos/$id');
  }

  Future<String> _ensureToken() async {
    if (_token != null && _token!.isNotEmpty) {
      return _token!;
    }
    return login();
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) {
      return data;
    }
    if (data is Map<String, dynamic>) {
      final nestedData = data['data'];
      if (nestedData is List) {
        return nestedData;
      }
      final establecimientos = data['establecimientos'];
      if (establecimientos is List) {
        return establecimientos;
      }
    }
    return <dynamic>[];
  }

  Map<String, dynamic> _extractMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['data'] is Map<String, dynamic>) {
        return data['data'] as Map<String, dynamic>;
      }
      return data;
    }
    throw Exception('Respuesta inesperada del servidor.');
  }
}
