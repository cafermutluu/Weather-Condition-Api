import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hava_durumu/search_page.dart';

import 'package:hava_durumu/widgets/daily_weather_card.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String location = "Eskişehir";
  double? temp;
  String key = "65c69a136aafecd2986af84bbfdf771b";
  dynamic locationData;
  String weatherCondition = "Home";
  Position? currentPosition;
  String? weatherIcon;

  List<String> icons = [];
  List<double> tempratures = [];

  List<String> dates = [];

  Future<void> getLocationDataFromApi() async {
    locationData = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$key&units=metric"));
    final locationDataParsed = jsonDecode(locationData.body);

    setState(() {
      temp = locationDataParsed["main"]["temp"];
      location = locationDataParsed["name"];
      weatherCondition = locationDataParsed["weather"][0]["main"];
      weatherIcon = locationDataParsed["weather"][0]["icon"];
    });
  }

  Future<void> getLocationDataFromApiByLatLong() async {
    if (currentPosition != null) {
      locationData = await http.get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?lat=${currentPosition!.latitude}&lon=${currentPosition!.longitude}&appid=$key&units=metric"));
      final locationDataParsed = jsonDecode(locationData.body);

      setState(() {
        temp = locationDataParsed["main"]["temp"];
        location = locationDataParsed["name"];
        weatherCondition = locationDataParsed["weather"][0]["main"];
        weatherIcon = locationDataParsed["weather"][0]["icon"];
      });
    }
  }

  Future<void> getCurrentPosition() async {
    currentPosition = await _determinePosition();
  }

  Future<void> getDailyForecastByCityName() async {
    var forecastData = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?q=$location&appid=$key&units=metric"));
    var forecastDataParsed = jsonDecode(forecastData.body);

    tempratures.clear();
    icons.clear();
    dates.clear();

    setState(() {
      for (int i = 7; i < 40; i = i + 8) {
        tempratures.add(forecastDataParsed["list"][i]["main"]["temp"]);
        icons.add(forecastDataParsed["list"][i]["weather"][0]["icon"]);
        dates.add(forecastDataParsed["list"][i]["dt_txt"]);
      }
    });
  }

  Future<void> getDailyForecastByLatLong() async {
    var forecastData = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?lat=${currentPosition!.latitude}&lon=${currentPosition!.longitude}&appid=$key&units=metric"));
    var forecastDataParsed = jsonDecode(forecastData.body);

    tempratures.clear();
    icons.clear();
    dates.clear();

    setState(() {
      for (int i = 7; i < 40; i = i + 8) {
        tempratures.add(forecastDataParsed["list"][i]["main"]["temp"]);
        icons.add(forecastDataParsed["list"][i]["weather"][0]["icon"]);
        dates.add(forecastDataParsed["list"][i]["dt_txt"]);
      }
    });
  }

  void getInitialData() async {
    await getCurrentPosition();
    await getLocationDataFromApiByLatLong();
    await getDailyForecastByLatLong();
  }

  @override
  void initState() {
    getInitialData();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/$weatherCondition.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: (temp == null ||
              currentPosition == null ||
              icons.isEmpty ||
              tempratures.isEmpty ||
              dates.isEmpty)
          ? Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Weather condition is receiving please wait",
                    style: TextStyle(fontSize: 15),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        getLocationDataFromApiByLatLong();
                        getCurrentPosition();
                      });
                    },
                    icon: const Icon(Icons.refresh_outlined),
                  ),
                  const SizedBox(
                    height: 75,
                    child: LoadingIndicator(
                      indicatorType: Indicator.ballBeat,
                      strokeWidth: 3.0,
                      colors: [
                        Colors.white,
                        Colors.black,
                        Colors.white,
                      ],
                    ),
                  ),
                ],
              )))
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    location,
                    style: const TextStyle(
                        fontSize: 50, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    child: Image.network(
                        "http://openweathermap.org/img/wn/$weatherIcon@2x.png"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            weatherCondition.toString(),
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "$temp °C",
                            style: const TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () async {
                          final selectedCity = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SearchPage()));
                          location = selectedCity;
                          await getLocationDataFromApi();
                          await getDailyForecastByCityName();
                        },
                        icon: const Icon(Icons.location_searching, size: 30),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () async {
                      await getLocationDataFromApiByLatLong();
                      await getDailyForecastByLatLong();
                    },
                    icon: const Icon(Icons.location_on),
                  ),
                  buildWeatherCards(context),
                ],
              ),
            ),
    );
  }

  SizedBox buildWeatherCards(BuildContext context) {
    List<DailyWeatherCard> cards = [];

    for (int i = 0; i < 5; i++) {
      cards.add(DailyWeatherCard(
          temprature: tempratures[i], date: dates[i], icon: icons[i]));
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.80,
      height: MediaQuery.of(context).size.height * 0.40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: cards,
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error(_showMyDialog());
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Not Found'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Please, turn on your Location'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
