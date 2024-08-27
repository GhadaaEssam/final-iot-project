import 'package:flutter/material.dart';
import 'mqtt_manager.dart'; // Import your MQTT manager

class DoorPage extends StatefulWidget {
  @override
  _DoorPageState createState() => _DoorPageState();
}

class _DoorPageState extends State<DoorPage> {
  //controller for the topic input field
  final topicController = TextEditingController();

  //list to store received messages
  final List<String> _messages = [];
  final List<ChartData> _chartData = [];

  final MQTTClientWrapper mqttClientWrapper = MQTTClientWrapper();

  //variable to track the current subscribed topic
  String? _currentTopic;

  //variable to store the current reading received from MQTT
  double _currentReading = 0.0;

  //boolean to track the switch/button state
  bool _isOn = false;

  @override
  void initState() {
    super.initState();
    mqttClientWrapper.prepareMqttClient();
    
    mqttClientWrapper.onMessageReceived = (message) {
      setState(() {
        _messages.add(message);

        try {
          _currentReading = double.parse(message);
          _chartData.add(ChartData(DateTime.now(), _currentReading));

          //maintain a maximum of 20 data points
          if (_chartData.length > 20) {
            _chartData.removeAt(0);
          }
        } catch (e) {
          //handle any errors
          print('Error parsing message to double: $e');
        }
      });
      print('Message received: $message');
    };
  }

  //subscribe to the specified topic
  void _subscribeToTopic(String topic) {
    topic = "door/control"; //topic for door control

    //only subscribe if the topic is valid and different from the current one
    if (topic.isNotEmpty && topic != _currentTopic) {
      mqttClientWrapper.subscribeToTopic(topic);
      _currentTopic = topic;
    }
  }

  //function to toggle the switch and publish corresponding MQTT messages
  void _toggleSwitch(bool value) {
    setState(() {
      _isOn = value; 

      //publish message based on switch state (OPEN or CLOSE)
      final message = _isOn ? 'OPEN' : 'CLOSE';
      mqttClientWrapper.publishMessage("door/control", message);
      print('Switch is ${_isOn ? "On" : "Off"} - Published: $message');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 6, 5, 49), 
              Color(0xFFdbc6b0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center, 
            children: [
              Positioned(
                top: 0,
                child: Image.asset(
                  _isOn ? 'assets/opend.png' : 'assets/closed.png', //different images based on door state
                  width: 100, 
                  height: 500, 
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 300.0),
                  child: Transform.scale(
                    scale: 1.5,
                    child: Switch(
                      value: _isOn, 
                      onChanged: _toggleSwitch, 
                      activeColor: Color.fromARGB(255, 155, 139, 122), 
                      inactiveThumbColor: Color.fromARGB(255, 6, 5, 49),
                      inactiveTrackColor: Color(0xFF4d6489),
                      activeTrackColor: Color(0xFFdbc6b0), 
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder for ChartData class
class ChartData {
  final DateTime time;
  final double value;

  ChartData(this.time, this.value);
}
