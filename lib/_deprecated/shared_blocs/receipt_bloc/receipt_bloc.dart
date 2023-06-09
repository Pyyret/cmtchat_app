import 'dart:async';

import 'package:cmtchat_app/services/web/receipt/receipt_service_api.dart';
import 'package:cmtchat_app/models/web/receipt.dart';
import 'package:cmtchat_app/models/web/web_user.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'receipt_event.dart';
part 'receipt_state.dart';

class ReceiptBloc extends Bloc<ReceiptEvent, ReceiptState> {
  final IReceiptService _receiptService;
  StreamSubscription? _subscription;

  ReceiptBloc(this._receiptService) : super(ReceiptState.initial());

  @override
  Stream<ReceiptState> mapEventToState(ReceiptEvent event) async* {

    if(event is Subscribe) {
      await _subscription?.cancel();
      _subscription = _receiptService
          .receiptStream(activeUser: event.user)
          .listen((receipt) => add(_ReceiptReceived(receipt)));
    }

    if(event is _ReceiptReceived) {
      yield ReceiptState.received(event.receipt);
    }

    if(event is ReceiptSent) {
      await _receiptService.send(event.receipt);
      yield ReceiptState.sent(event.receipt);
    }

    if(event is ReceiptListSent) {
      await _receiptService.sendList(event.receiptList);
      yield ReceiptState.listSent(event.receiptList);
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _receiptService.dispose();
    return super.close();
  }
}