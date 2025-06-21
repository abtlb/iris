import 'package:equatable/equatable.dart';

abstract class LocalVideoEvents extends Equatable {
  @override
  List<Object?> get props => [];
}

class ShareLocalVideo extends LocalVideoEvents {}
class ShareASL extends LocalVideoEvents {
  final String sender;
  final String receiver;

  ShareASL({required this.sender, required this.receiver});

  @override
  List<Object?> get props => [sender, receiver];
}
class DisableLocalVideo extends LocalVideoEvents {}