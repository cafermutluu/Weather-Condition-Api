import 'package:flutter/material.dart';

class DailyWeatherCard extends StatelessWidget {
  const DailyWeatherCard({Key? key, required this.temprature, required this.date, required this.icon }) : super(key: key);

  final String icon;
  final double temprature;
  final String date;

  @override
  Widget build(BuildContext context) {

    List<String> weekDays = ["Monday","Tuesday","Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

    String weekDay = weekDays[DateTime.parse(date).weekday-1];

    return Card(
      color: Colors.transparent,
      elevation: 0,
      child: Column(
        children: [
          Image.network("http://openweathermap.org/img/wn/$icon@2x.png"),
          Text("$temprature °C"),
          Text(weekDay),
        ],
      ),
    );
  }
}
