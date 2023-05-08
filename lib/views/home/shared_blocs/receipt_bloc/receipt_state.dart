part of 'receipt_bloc.dart';

abstract class ReceiptState extends Equatable {
  const ReceiptState();
  factory ReceiptState.initial() => ReceiptInitial();
  factory ReceiptState.sent(Receipt receipt) => ReceiptSentSuccess(receipt);
  factory ReceiptState.listSent(List<Receipt> receiptList) => ReceiptListSentSuccess(receiptList);
  factory ReceiptState.received(Receipt receipt) => ReceiptReceivedSuccess(receipt);

  @override
  List<Object> get props => [];
}

class ReceiptInitial extends ReceiptState {}

class ReceiptSentSuccess extends ReceiptState {
  final Receipt receipt;
  const ReceiptSentSuccess(this.receipt);

  @override
  List<Object> get props => [receipt];
}

class ReceiptListSentSuccess extends ReceiptState {
  final List<Receipt> receiptList;
  const ReceiptListSentSuccess(this.receiptList);

  @override
  List<Object> get props => [receiptList];
}

class ReceiptReceivedSuccess extends ReceiptState {
  final Receipt receipt;
  const ReceiptReceivedSuccess(this.receipt);

  @override
  List<Object> get props => [receipt];
}
