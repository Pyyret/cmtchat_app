import 'dart:async';

import 'package:cmtchat_app/collections/app_collection.dart';
import 'package:cmtchat_app/collections/chat_message_collection.dart';
import 'package:cmtchat_app/collections/isar_db_collection.dart';
import 'package:cmtchat_app/collections/user_webuser_service_collection.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

/// Repository Status Enum ///
enum RepoStatus { noUser, ready, loading, failure }

class Repository {

  bool _loggedIn = false;
  final _loggedInStreamController = StreamController<bool>();

  /// DataProvider APIs ///
  // Local
  final LocalDbApi _localDb;

  // WebDependant
  final WebUserServiceApi _webUserService;
  final WebMessageServiceApi _webMessageService;
  final IReceiptService _receiptService;


  /// Constructor
  Repository({
    required LocalDbApi dataService,
    required WebUserServiceApi webUserService,
    required WebMessageServiceApi webMessageService,
    required IReceiptService receiptService
  })
      : _localDb = dataService,
        _webUserService = webUserService,
        _webMessageService = webMessageService,
        _receiptService = receiptService


  /// AppCubit listener
  // This listens for changes in the AppCubit to take appropriate actions
  // on user or app changes.
  {
    BlocListener<AppCubit, AppState>(
        listener: (context, appState) {
          if (appState.userLoggedIn && _repoStatus == RepoStatus.noUser) {
            initializeRepo(appState.appUser!);
          }
        });
  }


  /// Repository variables ///
  // RepoStatus is enum declared at top of this class with (one of) the
  /// RepoStatus values: { noUser, ready, loading, failure }
  RepoStatus _repoStatus = RepoStatus.noUser;
  late User _appUser;


  /// Getters ///

  LocalDbApi get localDb => _localDb;

  WebUserServiceApi get webUserService => _webUserService;


  Stream<bool> get loggedIn async* {
    //await Future<void>.delayed(const Duration(seconds: 1));
    //yield RepoStatus.unauthenticated;
    yield* _loggedInStreamController.stream;
  }


  /// Methods ///
  // Called by AppCubit when a user has logged in
  initializeRepo(User appUser) {
    _appUser = appUser;
    _loggedIn = true;
    _loggedInStreamController.add(_loggedIn);
  }


  // Get a stream of all chats that involve _appUser, from localDb, with updated
  // chat variables (lastUpdate, latest content & unread). Sorted by lastUpdate.
  Future<Stream<List<Chat>>> get getAllChatsStream => _localDb.allChatsStream();

  Future<List<WebUser>> activeUsers() async {
    final activeUserList = await _webUserService.online();
    activeUserList.removeWhere((user) => user.webUserId == _appUser.webUserId);
    return activeUserList;
  }

}