import 'package:equatable/equatable.dart';

abstract class VideoChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class VideoChatConnectionRequested extends VideoChatEvent {
  final String channelName;

  VideoChatConnectionRequested({required this.channelName});

  @override
  List<Object?> get props => [channelName];
}

class VideoChatDisconnectRequested extends VideoChatEvent {}

