// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:get_it/get_it.dart';
// import 'package:syncfusion_flutter_gauges/gauges.dart';
//
// import '../../domain/usecases/monitor_sound.dart';
// import '../bloc/sound_monitor_cubit.dart';
// import '../bloc/sound_monitor_states.dart';
//
// class SoundMonitorPage extends StatelessWidget {
//   const SoundMonitorPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider<SoundMonitorCubit>(
//       create: (_) => GetIt.instance<SoundMonitorCubit>(),
//       child: BlocConsumer<SoundMonitorCubit, SoundMonitorState>(
//         listener: (context, state) {
//           if (state is SoundMonitorError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.message)),
//             );
//           }
//         },
//         builder: (context, state) {
//           double level = 0.0;
//           List<String> events = [];
//
//           if (state is SoundMonitorRunning) {
//             level = state.dbLevel;
//             events = state.soundEvents;
//           }
//
//           return Scaffold(
//             appBar: AppBar(title: const Text('Sound Monitor')),
//             body: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Expanded(
//                     flex: 3,
//                     child: Center(
//                       child: SfRadialGauge(
//                         axes: [
//                           RadialAxis(
//                             minimum: 0,
//                             maximum: 120,
//                             pointers: [
//                               NeedlePointer(value: level),
//                             ],
//                             annotations: [
//                               GaugeAnnotation(
//                                 widget: Text(
//                                   '${level.toStringAsFixed(1)} dB',
//                                   style: const TextStyle(
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 angle: 90,
//                                 positionFactor: 0.5,
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Expanded(
//                     flex: 2,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Detected Events:',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         if (events.isEmpty)
//                           const Text('No events detected.')
//                         else
//                           Wrap(
//                             spacing: 8,
//                             runSpacing: 4,
//                             children: events.map((e) => Chip(label: Text(e))).toList(),
//                           ),
//                       ],
//                     ),
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       ElevatedButton(
//                         onPressed: () => context
//                             .read<SoundMonitorCubit>()
//                             .startMonitoring(),
//                         child: const Text('Start'),
//                       ),
//                       ElevatedButton(
//                         onPressed: () => context
//                             .read<SoundMonitorCubit>()
//                             .stopMonitoring(),
//                         child: const Text('Stop'),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
