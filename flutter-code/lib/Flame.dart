import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'mqtt_manager.dart'; // Import your MQTT manager

class FirePage extends StatefulWidget {
  @override
  _FirePageState createState() => _FirePageState();
}

class _FirePageState extends State<FirePage> {
  //controller for the topic input field
  final topicController = TextEditingController();

  final List<String> _messages = [];

  final List<ChartData> _chartData = [];

  //MQTT client manager instance
  final MQTTClientWrapper mqttClientWrapper = MQTTClientWrapper();

  //variable to track the current subscribed topic
  String? _currentTopic;

  //variable to store the current reading received from MQTT, and 1 refers to no fire 
  double _currentReading = 1.0;

  @override
  void initState() {
    super.initState();
    mqttClientWrapper.prepareMqttClient();
        mqttClientWrapper.onMessageReceived = (message) {
      setState(() {
        _messages.add(message);

        // Attempt to parse the message as a double and update the chart data
        try {
          _currentReading = double.parse(message);
          _chartData.add(ChartData(DateTime.now(), _currentReading));

          //maintain a maximum of 20 data points
          if (_chartData.length > 20) {
            _chartData.removeAt(0);
          }
        } catch (e) {
          //handle errors
          print('Error parsing message to double: $e');
        }
      });
      print('Message received: $message');
    };
  }

  //subscribe to topic
  void _subscribeToTopic(String topic) {
    topic = "sensors/flame";

    //only subscribe if the topic is valid and different from the current one
    if (topic.isNotEmpty && topic != _currentTopic) {
      mqttClientWrapper.subscribeToTopic(topic);
      _currentTopic = topic;
    }
  }

  @override
  Widget build(BuildContext context) {
    //background based on the current reading
    final gradientColors = _currentReading == 1
        ? [
            Color.fromARGB(255, 6, 5, 49),
            Color(0xFFdbc6b0), 
          ]
        : [
            Colors.black,
            Colors.red,
            Colors.orange,
            Colors.yellow, 
          ];

    //button color based on the current reading
    final buttonGradientColors = _currentReading == 0
        ? [
            Colors.red, 
            Colors.orange, 
          ]
        : [
            Color(0xFFdbc6b0), 
            Color(0xFF78809d), 
          ];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors, // Apply background gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[

                SizedBox(height: 272),

                //display the animation based on the reading
                if (_currentReading == 0)
                  Lottie.asset('assets/fire2.json', width: 500, height: 200), //fire animation for alert
                if (_currentReading == 1)
                  Lottie.asset('assets/true.json', width: 500, height: 200), //safe state animation

                SizedBox(height: 20), 
                //display gradient button
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: buttonGradientColors, //based on the reading
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30), //rounded button corners
                  ),
                  child: TextButton(
                    onPressed: () {
                      final topic = topicController.text;
                      _subscribeToTopic(topic); //subscribe to topic on button press
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      backgroundColor: Colors.transparent, 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: Size(300, 50),
                    ),
                    child: Text(
                      'Show home state', 
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, 
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20), //spacer

                //display the current reading
                Text(
                  'Current Reading: $_currentReading',
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white, 
                  ),
                ),
                SizedBox(height: 20), //spacer

              ],
            ),
          ),
          // Positioned home icon at the top right
          Positioned(
            top: 30,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.popAndPushNamed(context, '/home'); // Navigate back to home
              },
              child: Icon(
                Icons.home, // Home icon
                size: 25, // Icon size
                color: Colors.white, // Icon color
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Class representing chart data (time vs. value)
class ChartData {
  ChartData(this.time, this.value);
  final DateTime time;
  final double value;
}
