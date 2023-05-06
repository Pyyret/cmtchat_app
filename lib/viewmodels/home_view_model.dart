import 'package:cmtchat_app/services/local/data/dataservice_contract.dart';
import 'package:cmtchat_app/services/web/user/web_user_service_contract.dart';


class HomeViewModel {
  final IDataService _dataService;
  final IWebUserService _webUserService;

  HomeViewModel(this._dataService, this._webUserService);
}