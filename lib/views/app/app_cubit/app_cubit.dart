import 'package:cmtchat_app/collections/user_webuser_service_collection.dart';
import 'package:cmtchat_app/viewmodels/app_view_model.dart';
import 'package:cmtchat_app/views/app/app_cubit/app_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class AppCubit extends Cubit<AppState> {
  final AppViewModel _viewModel;

  AppCubit(this._viewModel) : super(AppInitial());

  User get user => _viewModel.user;

  Future<void> loginFromCache() async {
    emit(Loading());
    User? cachedUser = await _viewModel.checkForCachedUser();
    if(cachedUser != null) {
      User connectedUser = await _viewModel.connect(cachedUser);
      final User savedUser = await _viewModel.cacheAndSave(connectedUser);

      emit(UserConnectSuccess(savedUser));
    }
    else { emit(NoUserConnect()); }
  }

  Future<void> newUserLogin(String username) async {
    emit(Loading());
    User connectedUser = await _viewModel.connectNewUser(username);
    final User savedUser = await _viewModel.cacheAndSave(connectedUser);

    emit(UserConnectSuccess(savedUser));
  }
}