import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:equatable/equatable.dart';

abstract class LocalVideoStates extends Equatable {
  @override
  List<Object?> get props => [];
}

class LocalVideoInitial extends LocalVideoStates {}
class LocalVideoEnabling extends LocalVideoStates {}
class LocalVideoEnabled extends LocalVideoStates {}
class ASLEnabling extends LocalVideoStates {}
class ASLEnabled extends LocalVideoStates {}
class LocalVideoDisabling extends LocalVideoStates {}
class LocalVideoDisabled extends LocalVideoStates {}