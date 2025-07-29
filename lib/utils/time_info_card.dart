// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:marquee/marquee.dart';
//
// class InfoCard extends StatefulWidget {
//   final String currentLocation;
//   final String Function() getIslamicDate;
//   final double? latitude;
//   final double? longitude;
//
//   const InfoCard({
//     Key? key,
//     required this.currentLocation,
//     required this.getIslamicDate,
//     this.latitude,
//     this.longitude,
//   }) : super(key: key);
//
//   @override
//   _InfoCardState createState() => _InfoCardState();
// }
//
// class _InfoCardState extends State<InfoCard> {
//   String _altitude = "Loading...";
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchLocationDetails();
//   }
//
//   Future<void> _fetchLocationDetails() async {
//     // Calculate GMT offset from device timezone
//     final now = DateTime.now();
//     final offset = now.timeZoneOffset;
//
//     if (widget.latitude != null && widget.longitude != null) {
//       try {
//         final LocationSettings locationSettings = LocationSettings(
//           accuracy: LocationAccuracy.high,
//           distanceFilter: 100,
//         );
//         Position position = await Geolocator.getCurrentPosition(
//           locationSettings: locationSettings
//         );
//
//         double altitudeFeet = position.altitude * 3.28084; // meters to feet
//
//         setState(() {
//           _altitude = "Height: ${altitudeFeet.toStringAsFixed(0)} feet";
//         });
//       } catch (e) {
//         setState(() {
//           _altitude = "Height: N/A";
//         });
//       }
//     } else {
//       setState(() {
//         _altitude = "Height: N/A";
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       // height: 150,
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.grey[900],
//
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.calendar_today, color: Colors.green, size: 14),
//               const SizedBox(width: 8),
//               Text(
//                 widget.getIslamicDate(),
//                 style: const TextStyle(color: Colors.white, fontSize: 14),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               const Icon(Icons.today, color: Colors.orange, size: 14),
//               const SizedBox(width: 8),
//               Text(
//                 DateFormat('EEE dd MMM yyyy').format(DateTime.now()),
//                 style: const TextStyle(color: Colors.white, fontSize: 14),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               const Icon(Icons.location_on, color: Colors.blueGrey, size: 14),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: SizedBox(
//                   height: 20, // set a fixed height for smooth scrolling
//                   child: Marquee(
//                     text: widget.currentLocation,
//                     style: const TextStyle(color: Colors.white, fontSize: 14),
//                     scrollAxis: Axis.horizontal,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     blankSpace: 40.0,
//                     velocity: 30.0,
//                     pauseAfterRound: Duration(seconds: 1),
//                     startPadding: 10.0,
//                     accelerationDuration: Duration(seconds: 1),
//                     accelerationCurve: Curves.linear,
//                     decelerationDuration: Duration(milliseconds: 500),
//                     decelerationCurve: Curves.easeOut,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               const Icon(FontAwesomeIcons.mountainSun, color: Colors.blue, size: 14),
//               const SizedBox(width: 8),
//               Text(
//                 "$_altitude",
//                 style: const TextStyle(color: Colors.grey, fontSize: 12),
//               ),
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }
