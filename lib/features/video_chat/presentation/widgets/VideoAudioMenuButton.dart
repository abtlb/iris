import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:untitled3/features/chat/presentation/blocs/voice/voice_event.dart';
import 'package:untitled3/features/chat/presentation/blocs/voice/voice_state.dart';

import '../../../chat/presentation/blocs/voice/voice_bloc.dart';
import '../bloc/local_bloc/local_bloc.dart';
import '../bloc/local_bloc/local_events.dart';
import '../bloc/local_bloc/local_states.dart';
import '../bloc/remote_bloc/remote_bloc.dart';
import '../enums/VideoAndAudioOptions.dart';

/// Enumerations for the mutually‐exclusive choices.


/// A floating menu button that opens a bottom sheet with
/// two radio‐button groups: one for Video, one for Audio.
/// The user can only pick exactly one of the three video options,
/// and exactly one of the three audio options.
class VideoAudioMenuButton extends StatefulWidget {
  const VideoAudioMenuButton({super.key, required this.sender, required this.receiver});
  final String sender;
  final String receiver;

  @override
  State<VideoAudioMenuButton> createState() => _VideoAudioMenuButtonState();
}

class _VideoAudioMenuButtonState extends State<VideoAudioMenuButton> {
  VideoOption? _selectedVideo = VideoOption.disableVideo;
  AudioOption? _selectedAudio = AudioOption.disableAudio;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOptionsSheet(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.menu,
          size: 28,
          color: Colors.white,
        ),
      ),
    );
  }

  void handleOptions(VideoOption videoOption, AudioOption audioOption) {
    final localBloc = context.read<LocalVideoBloc>();
    final voiceBloc = context.read<VoiceBloc>();

    switch (videoOption) {
      case VideoOption.shareVideo:
        if(localBloc.state is LocalVideoEnabled) {
          break;
        }
        localBloc.add(ShareLocalVideo());
        break;
      case VideoOption.doASL:
        if(localBloc.state is ASLEnabled) {
          break;
        }
        localBloc.add(ShareASL(receiver: widget.receiver, sender: widget.sender));
        break;
      case VideoOption.disableVideo:
        if(localBloc.state is LocalVideoDisabled) {
          break;
        }
        localBloc.add(DisableLocalVideo());
        break;
    }

    switch (audioOption) {
      case AudioOption.shareAudio:
        if(voiceBloc.state is SharingVoice) {
          break;
        }
        voiceBloc.add(ShareVoice());
        break;
      case AudioOption.doSpeechRecognition:
        if(voiceBloc.state is DoingSTT) {
          break;
        }
        voiceBloc.add(DoSTT(receiver: widget.receiver, sender: widget.sender));
        break;
      case AudioOption.disableAudio:
        if(voiceBloc.state is VoiceDisabled) {
          break;
        }
        voiceBloc.add(DisableVoice());
        break;
    }
  }

  void _showOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // for rounded corners + blur
      builder: (context) {
        // We’ll use a StatefulBuilder so the radio‐buttons can update
        // their local state while the sheet is open.
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.75,
              builder: (_, controller) {
                return Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: ListView(
                    controller: controller,
                    children: [
                      // 1) Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // 2) Title
                      const Text(
                        'Video & Audio Options',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 3) Video Section
                      const Text(
                        'Video',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),

                      RadioListTile<VideoOption>(
                        title: const Text('Share Video'),
                        subtitle: const Text('Stream your camera'),
                        value: VideoOption.shareVideo,
                        groupValue: _selectedVideo,
                        activeColor: Colors.blueAccent,
                        onChanged: (VideoOption? value) {
                          setSheetState(() {
                            _selectedVideo = value;
                          });
                        },
                      ),
                      RadioListTile<VideoOption>(
                        title: const Text('Do ASL'),
                        subtitle: const Text(
                            'Enable sign‐language mode (ASL detection)'),
                        value: VideoOption.doASL,
                        groupValue: _selectedVideo,
                        activeColor: Colors.blueAccent,
                        onChanged: (VideoOption? value) {
                          setSheetState(() {
                            _selectedVideo = value;
                          });
                        },
                      ),
                      RadioListTile<VideoOption>(
                        title: const Text('Disable Video'),
                        subtitle: const Text('Turn off your camera'),
                        value: VideoOption.disableVideo,
                        groupValue: _selectedVideo,
                        activeColor: Colors.blueAccent,
                        onChanged: (VideoOption? value) {
                          setSheetState(() {
                            _selectedVideo = value;
                          });
                        },
                      ),

                      const SizedBox(height: 24),
                      // 4) Audio Section
                      const Text(
                        'Audio',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),

                      RadioListTile<AudioOption>(
                        title: const Text('Share Audio'),
                        subtitle: const Text('Broadcast your mic'),
                        value: AudioOption.shareAudio,
                        groupValue: _selectedAudio,
                        activeColor: Colors.blueAccent,
                        onChanged: (AudioOption? value) {
                          setSheetState(() {
                            _selectedAudio = value;
                          });
                        },
                      ),
                      RadioListTile<AudioOption>(
                        title: const Text('Do Speech Recognition'),
                        subtitle:
                        const Text('Enable live speech‐to‐text mode'),
                        value: AudioOption.doSpeechRecognition,
                        groupValue: _selectedAudio,
                        activeColor: Colors.blueAccent,
                        onChanged: (AudioOption? value) {
                          setSheetState(() {
                            _selectedAudio = value;
                          });
                        },
                      ),
                      RadioListTile<AudioOption>(
                        title: const Text('Disable Audio'),
                        subtitle: const Text('Mute your microphone'),
                        value: AudioOption.disableAudio,
                        groupValue: _selectedAudio,
                        activeColor: Colors.blueAccent,
                        onChanged: (AudioOption? value) {
                          setSheetState(() {
                            _selectedAudio = value;
                          });
                        },
                      ),

                      const SizedBox(height: 24),
                      // 5) Done Button
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // You can access _selectedVideo / _selectedAudio
                            // here and call any callbacks or logic you need.
                            // For now, we just close the sheet.
                            Navigator.pop(context);
                            handleOptions(_selectedVideo!, _selectedAudio!);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Done',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
