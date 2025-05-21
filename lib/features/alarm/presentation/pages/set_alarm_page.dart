// import 'package:flutter/material.dart';
//
// class SetAlarmPage extends StatefulWidget {
//   const SetAlarmPage({super.key});
//
//   @override
//   State<SetAlarmPage> createState() => _SetAlarmPageState();
// }
//
// class _SetAlarmPageState extends State<SetAlarmPage> {
//   final List<String> allDays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
//   Set<String> selectedDays = {'Mo', 'Tu', 'We', 'Th', 'Fr'};
//
//   int hour = 6;
//   int minute = 0;
//   bool isAm = true;
//
//   double alarmVolume = 0.7;
//   bool vibrationEnabled = true;
//   String vibrationStrength = 'Medium';
//   bool useFlashlight = false;
//   bool showPopup = true;
//   String alarmNote = '';
//
//   void incrementHour() => setState(() => hour = (hour + 1) % 24);
//   void decrementHour() => setState(() => hour = (hour - 1 + 24) % 24);
//   void incrementMinute() => setState(() => minute = (minute + 1) % 60);
//   void decrementMinute() => setState(() => minute = (minute - 1 + 60) % 60);
//
//   String formatTimeUnit(int unit) => unit.toString().padLeft(2, '0');
//   String displayHour12(int hour) {
//     final h = hour % 12;
//     return (h == 0 ? 12 : h).toString().padLeft(2, '0');
//   }
//
//   int getFinalHour() {
//     final base = hour % 12;
//     return isAm ? base : base + 12;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.indigo,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text('Alarm',
//             style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
//         leading: const BackButton(color: Colors.white),
//         centerTitle: true,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           _buildCard([
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 _TimeAdjustButton(
//                   value: displayHour12(hour),
//                   onIncrement: () => setState(() => hour = (hour + 1) % 24),
//                   onDecrement: () => setState(() => hour = (hour - 1 + 24) % 24),
//                 ),
//                 const SizedBox(width: 10),
//                 const Text(":", style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold)),
//                 const SizedBox(width: 10),
//                 _TimeAdjustButton(
//                   value: formatTimeUnit(minute),
//                   onIncrement: incrementMinute,
//                   onDecrement: decrementMinute,
//                 ),
//                 const SizedBox(width: 10),
//                 Column(
//                   children: [
//                     GestureDetector(
//                       onTap: () => setState(() => isAm = true),
//                       child: Text(
//                         "AM",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: isAm ? Colors.indigo[700] : Colors.grey,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     GestureDetector(
//                       onTap: () => setState(() => isAm = false),
//                       child: Text(
//                         "PM",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: !isAm ? Colors.indigo[700] : Colors.grey,
//                         ),
//                       ),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           ]),
//           const SizedBox(height: 16),
//
//           // Repeat section
//           _buildCard([
//             _sectionHeader(Icons.calendar_today, "Repeat"),
//             const SizedBox(height: 12),
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: allDays.map((d) {
//                 final selected = selectedDays.contains(d);
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       if (selected) {
//                         selectedDays.remove(d);
//                       } else {
//                         selectedDays.add(d);
//                       }
//                     });
//                   },
//                   child: Chip(
//                     label: Text(d),
//                     backgroundColor: selected ? Colors.indigo[700] : Colors.grey[300],
//                     labelStyle: TextStyle(
//                       color: selected ? Colors.white : Colors.black,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 );
//               }).toList(),
//             )
//           ]),
//           const SizedBox(height: 16),
//
//           // Alarm Sound and Volume
//           _buildCard([
//             _sectionHeader(Icons.notifications_none, "Alarm sound"),
//             const SizedBox(height: 8),
//             const Text("Alarm tone: Alarm Ringtone",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//             Slider(
//               value: alarmVolume,
//               onChanged: (value) => setState(() => alarmVolume = value),
//               activeColor: Colors.indigo[900],
//               inactiveColor: Colors.indigo[100],
//             ),
//           ]),
//           const SizedBox(height: 16),
//
//           // Note
//           _buildCard([
//             _sectionHeader(Icons.note_alt_outlined, "Note"),
//             const SizedBox(height: 8),
//             TextField(
//               decoration: const InputDecoration(
//                 hintText: "Add a note for this alarm",
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: (val) => setState(() => alarmNote = val),
//             ),
//           ]),
//           const SizedBox(height: 16),
//
//           // Vibration
//           _buildCard([
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Row(
//                   children: [
//                     Icon(Icons.vibration),
//                     SizedBox(width: 8),
//                     Text("Vibration", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//                 Switch(
//                   value: vibrationEnabled,
//                   onChanged: (val) => setState(() => vibrationEnabled = val),
//                   activeColor: Colors.indigo[700],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             _dropdownField("Strength", vibrationStrength, ["Low", "Medium", "High"],
//                 enabled: vibrationEnabled),
//           ]),
//           const SizedBox(height: 16),
//
//           // Flashlight + Popup
//           _buildCard([
//             SwitchListTile(
//               value: useFlashlight,
//               onChanged: (val) => setState(() => useFlashlight = val),
//               title: const Text("Use flashlight", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               secondary: const Icon(Icons.flashlight_on),
//               activeColor: Colors.indigo[700],
//             ),
//             SwitchListTile(
//               value: showPopup,
//               onChanged: (val) => setState(() => showPopup = val),
//               title: const Text("Show on-screen popup", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               secondary: const Icon(Icons.alarm),
//               activeColor: Colors.indigo[700],
//             ),
//           ]),
//           const SizedBox(height: 90),
//         ],
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: SizedBox(
//         height: 72,
//         width: 72,
//         child: FloatingActionButton(
//           backgroundColor: Colors.indigo[700],
//           child: const Icon(Icons.check, size: 36 , color: Colors.white),
//           onPressed: () {
//             final int finalHour = getFinalHour();
//             final String timeString = '${formatTimeUnit(finalHour)}:${formatTimeUnit(minute)}';
//             final Map<String, dynamic> newAlarm = {
//               "time": timeString,
//               "label": alarmNote,
//               "days": selectedDays.toList(),
//               "active": true,
//             };
//             Navigator.of(context).pop(newAlarm);
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCard(List<Widget> children) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: children,
//       ),
//     );
//   }
//
//   static Widget _sectionHeader(IconData icon, String title) => Row(
//     children: [
//       Icon(icon),
//       const SizedBox(width: 8),
//       Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//     ],
//   );
//
//   static Widget _dropdownField(String label, String value, List<String> items, {bool enabled = true}) {
//     return DropdownButtonFormField<String>(
//       value: value,
//       items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
//       onChanged: enabled ? (_) {} : null,
//       decoration: InputDecoration(
//         labelText: label,
//         border: const OutlineInputBorder(),
//         labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//       ),
//     );
//   }
// }
//
// class _TimeAdjustButton extends StatelessWidget {
//   final String value;
//   final VoidCallback onIncrement;
//   final VoidCallback onDecrement;
//
//   const _TimeAdjustButton({
//     required this.value,
//     required this.onIncrement,
//     required this.onDecrement,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         IconButton(icon: const Icon(Icons.add, color: Colors.indigo), onPressed: onIncrement),
//         Text(value, style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold)),
//         IconButton(icon: const Icon(Icons.remove, color: Colors.indigo), onPressed: onDecrement),
//       ],
//     );
//   }
// }
//

//---My version---
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:untitled3/core/constants/constants.dart';
// import 'package:untitled3/features/alarm/domain/entities/week_day.dart';
// import '../bloc/alarm_form/alarm_form_cubit.dart';
// import '../bloc/alarm_form/alarm_form_state.dart';
//
// class SetAlarmPage extends StatelessWidget {
//   const SetAlarmPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => AlarmFormCubit(),
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.deepPurple,
//           title: const Text('Set Alarm'),
//           centerTitle: true,
//         ),
//         body: BlocBuilder<AlarmFormCubit, AlarmFormState>(
//           builder: (context, state) {
//             final alarm = state.alarm;
//             return Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   // Time Picker
//                   Card(
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     child: ListTile(
//                       title: Text(DateFormat('hh:mm a').format(alarm.time),
//                           style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
//                       trailing: const Icon(Icons.access_time, color: Colors.deepPurple),
//                       onTap: () async {
//                         final t = await showTimePicker(
//                             context: context, initialTime: TimeOfDay.fromDateTime(alarm.time));
//                         if (t != null) context.read<AlarmFormCubit>().updateTime(alarm.time);
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   // Repeat Days using ChoiceChips
//                   Card(
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     child: Padding(
//                       padding: const EdgeInsets.all(12),
//                       child: Wrap(
//                         spacing: 8,
//                         children: WeekDay.values.map((day) {
//                           final selected = alarm.repeatDays.contains(day);
//                           print("Is selected???? $selected");
//                           return ChoiceChip(
//                             label: Text(day.shortName),
//                             selected: selected,
//                             selectedColor: Colors.deepPurple,
//                             onSelected: (_) {
//                               // Copy the existing List<WeekDay>
//                               final newDays = List<WeekDay>.from(alarm.repeatDays);
//                               if (selected) {
//                                 newDays.remove(day);
//                               } else {
//                                 newDays.add(day);
//                               }
//                               // Update with the new List<WeekDay>
//                               context.read<AlarmFormCubit>().updateRepeat(newDays);
//                             },
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   ),
//
//                   const Spacer(),
//                   ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: kPrimarycolor,
//                       padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     ),
//                     icon: const Icon(Icons.check),
//                     label: const Text('Save Alarm', style: TextStyle(fontSize: 18)),
//                     onPressed: state.isValid
//                         ? () => Navigator.of(context).pop(alarm)
//                         : null,
//                   ),
//                   const SizedBox(height: 16),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torch_light/torch_light.dart';
import '../../domain/entities/alarm_entity.dart';
import '../../domain/entities/week_day.dart';
import '../bloc/alarm_form/alarm_form_cubit.dart';
import '../bloc/alarm_form/alarm_form_state.dart';
import '../widgets/pattern_row.dart';

class SetAlarmPage extends StatelessWidget {
  final Alarm? alarm;
  late final TextEditingController labelController;
  SetAlarmPage({super.key, required this.alarm}) {
    labelController = TextEditingController(text: alarm?.label ?? '');
  }

  @override
  Widget build(BuildContext context) {
    // Provide the form cubit (optionally pass an initial Alarm)
    return BlocProvider(
      create: (_) => AlarmFormCubit(initialAlarm: alarm),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: const Text('Set Alarm'),
          centerTitle: true,
        ),
        body: BlocBuilder<AlarmFormCubit, AlarmFormState>(
          builder: (context, state) {
            final alarm = state.alarm;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                // child: Column(
                children: [
                  // ─── Time Picker ─────────────────────────────────────────────
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    color: Colors.deepPurple.shade100,
                    child: ListTile(
                      title: Text(
                        // use intl DateFormat
                        TimeOfDay.fromDateTime(alarm.time)
                            .format(context),
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      trailing:
                      const Icon(Icons.access_time, color: Colors.white),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime:
                          TimeOfDay.fromDateTime(alarm.time),
                        );
                        if (picked != null) {
                          // reconstruct DateTime with picked hour/minute
                          final now = DateTime.now();
                          final newTime = DateTime(
                            now.year,
                            now.month,
                            now.day,
                            picked.hour,
                            picked.minute,
                          );
                          context
                              .read<AlarmFormCubit>()
                              .updateTime(newTime);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ─── Repeat Days ────────────────────────────────────────────
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.deepPurple.shade50, Colors.deepPurple.shade100],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.repeat, color: Colors.deepPurple),
                              const SizedBox(width: 8),
                              Text(
                                'Repeat Days',
                                style: TextStyle(
                                  color: Colors.deepPurple.shade800,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Choice chips
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: WeekDay.values.map((day) {
                              final selected = alarm.repeatDays.contains(day);
                              return ChoiceChip(
                                label: Text(day.shortName),
                                selected: selected,
                                onSelected: (_) {
                                  final newDays = List<WeekDay>.from(alarm.repeatDays);
                                  if (selected) newDays.remove(day);
                                  else newDays.add(day);
                                  context.read<AlarmFormCubit>().updateRepeat(newDays);
                                },
                                backgroundColor: Colors.white,
                                selectedColor: Colors.deepPurple,
                                labelStyle: TextStyle(
                                  color: selected ? Colors.white : Colors.deepPurple,
                                  fontWeight: FontWeight.w500,
                                ),
                                shape: StadiumBorder(
                                  side: BorderSide(
                                    color: selected
                                        ? Colors.deepPurple
                                        : Colors.deepPurple.shade200,
                                    width: 1.5,
                                  ),
                                ),
                                elevation: 2,
                                pressElevation: 4,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        TextField(
                          controller: labelController,
                          maxLength: 50,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.deepPurple.shade50,
                            hintText: state.alarm.label == ""? "Alarm label" : "",
                            counterText: "", // Hides the default counter text
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          style: const TextStyle(fontSize: 16),
                          onChanged: (value) {
                            context.read<AlarmFormCubit>().updateLabel(value);
                          },
                        ),
                      ],
                    ),
                  ),


                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Alarm Pattern',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                NumberSlider(initialValue: state.alarm.pattern, onValueChanged: (value) {
                  context.read<AlarmFormCubit>().updatePattern(value);
                }),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: Icon(
                          state.alarm.isEnabled ? Icons.toggle_on : Icons.toggle_off,
                          size: 80,
                          color: state.alarm.isEnabled ? Colors.deepPurple : Colors.grey,
                        ),
                        onPressed: () => context.read<AlarmFormCubit>().toggleEnabled(),
                      ),
                      // const Spacer(),
                      ]
                  ),


                  // ─── Save Button ────────────────────────────────────────────
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.check),
                    label: const Text('Save Alarm',
                        style: TextStyle(fontSize: 18)),
                    onPressed: state.isValid
                        ? () {
                      Navigator.of(context).pop(alarm);
                    }
                        : null,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              // )
            );
          },
        ),
      ),
    );
  }
}
