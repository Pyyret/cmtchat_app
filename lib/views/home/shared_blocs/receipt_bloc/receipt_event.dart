part of 'receipt_bloc.dart';

abstract class ReceiptEvent extends Equatable {
  const ReceiptEvent();
  factory ReceiptEvent.onSubscribed(WebUser user) => Subscribe(user);
  factory ReceiptEvent.onReceiptSent(Receipt receipt) => ReceiptSent(receipt);

  @override
  List<Object> get props => [];
}

class Subscribe extends ReceiptEvent {
  final WebUser user;
  const Subscribe(this.user);

  @override
  List<Object> get props => [user];
}

class ReceiptSent extends ReceiptEvent {
  final Receipt receipt;
  const ReceiptSent(this.receipt);

  @override
  List<Object> get props => [receipt];
}

class _ReceiptReceived extends ReceiptEvent {
  final Receipt receipt;
  const _ReceiptReceived(this.receipt);

  @override
  List<Object> get props => [receipt];
}