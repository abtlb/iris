import 'package:equatable/equatable.dart';

class VoiceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ShareVoice extends VoiceEvent {}
class DoSTT extends VoiceEvent {
  final String sender;
  final String receiver;

  DoSTT({required this.sender, required this.receiver});

  @override
  List<Object?> get props => [sender, receiver];
}
class DisableVoice extends VoiceEvent {}