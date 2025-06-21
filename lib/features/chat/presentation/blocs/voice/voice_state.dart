import 'package:equatable/equatable.dart';

class VoiceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class VoiceDisabled extends VoiceState {}
class SharingVoice extends VoiceState {}
class DoingSTT extends VoiceState {} //speech to text