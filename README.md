# Smart Home Security and Monitoring System
## Overview
This project implements a smart home system using IoT technologies. The system consists of an RFID-based door lock, environmental monitoring sensors, and a Flutter app for remote control and monitoring. The system communicates using MQTT and provides real-time updates on home security and plant care.

## Features
- **RFID Door Lock**: Secure door access using RFID tags, integrated with a servo motor and LCD display.
- **Environmental Monitoring**: Sensors such as temperature, flame, line tracking and soil -moisture send real-time data to the app.
- **Fire Detection**: detects if a fire or abnormal temperature is detected.
- **Plant Care**: Monitors soil moisture levels.
- **Remote Access**: Full control and monitoring via a mobile app, using HiveMQ for MQTT messaging.
- **User Authentication**: Secure login and registration using Firebase.
  
## Technologies
- **ESP32**:Used for recieving sensor readings and hardware control.
- **Flutter**: The mobile app framework for user interaction.
- **HiveMQ MQTT Broker**:For messaging between devices and the app.
- **Firebase**:For user authentication in the app.
  
## OOP Design Overview
This project follows an Object-Oriented Programming (OOP) design to promote code reusability, maintainability, and scalability. The system is built around key classes representing different components of the smart home system, with an emphasis on inheritance, encapsulation, and polymorphism.

### Key Components

1. **Interfaces**:
   - **Connection Interface**: Defines methods for establishing, checking, and disconnecting connections. Both the `wifiManager` and `mqttManager` classes implement this interface, ensuring consistent behavior for connection management.
   - **SmartDevice Interface**: Used by all smart devices (e.g., `RFID`, `Sensor`, `LCD`) to ensure that each device implements the `deviceSetup()` method for initialization.

2. **wifiManager & mqttManager**:
   - Both classes manage connections in the system, implementing the `Connection` interface. `wifiManager` handles Wi-Fi connections, while `mqttManager` manages MQTT communication for messaging. Each class encapsulates its specific connection logic.

3. **smartHome Class**:
   - Acts as the central controller, coordinating all smart devices, sensors, and actuators. This class holds instances of the connection managers, sensors, and actuators, and defines methods to read sensor data, control devices, and publish sensor readings via MQTT.

4. **Device and Sensor Classes**:
   - The system includes various device classes like `RFID`, `LCD`, and `Sensor`, each implementing the `smartDevice` interface to standardize setup procedures. These devices inherit common properties and behaviors from the `baseActuator` class or directly from the interface.
   - The `Sensor` class is the base class for sensors like `temperatureSensor` and `flameSensor`. It encapsulates sensor-specific logic and provides methods to read sensor data and publish it via MQTT.

5. **Inheritance and Polymorphism**:
   - The `baseActuator` class provides common functionality for actuators like the `servoMotor` and `buzzer`. These actuators inherit from `baseActuator`, allowing shared behavior like `startAction()` and `stopAction()`.
   - The system allows new devices and sensors to be easily added by inheriting from the `baseActuator` or `Sensor` classes and overriding necessary methods.

### Class Relationships

- **smartHome**: Manages the interactions between all components, including `wifiManager`, `mqttManager`, `RFID`, and various sensors. It ensures the proper setup, loop execution, and interaction between devices.
- **Connection Classes**: Both `wifiManager` and `mqttManager` implement the `Connection` interface, ensuring that connection management for both Wi-Fi and MQTT follows a consistent pattern.
- **Device and Sensor Hierarchy**: Sensors like `temperatureSensor` and `flameSensor` extend the `Sensor` class, inheriting core functionalities while implementing their specific sensor logic.
- **Actuators**: Devices like `servoMotor` and `buzzer` inherit from the `baseActuator`, sharing common actuator behaviors.

By structuring the system this way, it promotes code reuse and provides a scalable architecture where new components can be added with minimal changes to the existing code.

## Folder Structure
- **/esp-code**:Contains the ESP32 firmware code.
- **/flutter-code**:Contains the Flutter mobile app code.
- **/docs**:Contains diagrams and documentation

## Installation
### ESP32 Code:
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/smart-home-project.git
2. Navigate to the esp-code folder:
   ```bash
   cd esp-code
3. Open the project in PlatformIO or your preferred IDE.
4. Connect your ESP32 device and flash the firmware.
### Flutter App:
1. Navigate to the flutter-code folder:
    ```bash
    cd flutter-code
2. Run the following commands to set up the app:
    ```bash
    flutter pub get
    flutter run

## Usage
- The ESP32 handles sensor readings and communicates with the Flutter app via MQTT.
- The app displays real-time sensor data and allows users to control the door lock and monitor home conditions remotely.

