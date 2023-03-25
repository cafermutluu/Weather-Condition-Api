import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String selectedCity = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/Cat.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 115.0),
              child: TextField(
                onChanged: (value) {
                  selectedCity = value;
                },
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                    border: InputBorder.none,
                  hintText: "Enter a City Name",
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(
                        width: 3,
                        color: Colors.black45,
                      ),
                    ),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
                onPressed: () async{
                  var response = await http.get(Uri.parse("https://api.openweathermap.org/data/2.5/weather?q=$selectedCity&appid=65c69a136aafecd2986af84bbfdf771b&units=metric"));
                  if(response.statusCode == 200){
                    Navigator.pop(context, selectedCity);
                  }else{
                    _showMyDialog();
                  }
                },
                child: const Text("OK", style: TextStyle(fontSize: 20),))
          ],
        ),
      ),
    );
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
                Text('Please enter a valid city name'),
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
