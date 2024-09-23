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

##Usage
- The ESP32 handles sensor readings and communicates with the Flutter app via MQTT.
- The app displays real-time sensor data and allows users to control the door lock and monitor home conditions remotely.

