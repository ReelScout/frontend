// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:frontend/config/dio_config.dart' as _i456;
import 'package:frontend/config/service_module.dart' as _i316;
import 'package:frontend/interceptor/token_interceptor.dart' as _i746;
import 'package:frontend/services/auth_service.dart' as _i269;
import 'package:frontend/services/content_service.dart' as _i53;
import 'package:frontend/services/search_service.dart' as _i1063;
import 'package:frontend/services/token_service.dart' as _i768;
import 'package:frontend/services/user_service.dart' as _i625;
import 'package:frontend/services/watchlist_service.dart' as _i156;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final dioConfig = _$DioConfig();
    final serviceModule = _$ServiceModule();
    gh.singleton<_i558.FlutterSecureStorage>(() => dioConfig.secureStorage);
    gh.singleton<_i768.TokenService>(
      () => dioConfig.tokenService(gh<_i558.FlutterSecureStorage>()),
    );
    gh.singleton<_i746.TokenInterceptor>(
      () => dioConfig.tokenInterceptor(gh<_i768.TokenService>()),
    );
    gh.singleton<_i361.Dio>(() => dioConfig.dio(gh<_i746.TokenInterceptor>()));
    gh.singleton<_i269.AuthService>(
      () => serviceModule.authService(gh<_i361.Dio>()),
    );
    gh.singleton<_i625.UserService>(
      () => serviceModule.userService(gh<_i361.Dio>()),
    );
    gh.singleton<_i53.ContentService>(
      () => serviceModule.contentService(gh<_i361.Dio>()),
    );
    gh.singleton<_i1063.SearchService>(
      () => serviceModule.searchService(gh<_i361.Dio>()),
    );
    gh.singleton<_i156.WatchlistService>(
      () => serviceModule.watchlistService(gh<_i361.Dio>()),
    );
    return this;
  }
}

class _$DioConfig extends _i456.DioConfig {}

class _$ServiceModule extends _i316.ServiceModule {}
