#ifndef SMARTHOME_H
#define SMARTHOME_H

#include "wifiManager.h"
#include "mqttManager.h"
#include "servoMotor.h"
#include "buzzer.h"
#include "LCD.h"
#include "Sensor.h"
#include "flameSensor.h"
#include "temperatureSensor.h"
#include "RFID.h"


class smartHome{
private:
    const char* wifissid = "";
    const char* wifipassword = "";

    const char* mqttServer = "";
    const char* mqttUsername =  "";
    const char* mqttPassword = "";

    const int flamePin = 27;
    const int temperaturePin = 35;
    const int irPin = 32;
    const int soilPin = 34;
    
    const int servoPin =14;

    const int buzzerPin=33;
    const int LEDpin=13;

    const int SSpin=5;
    const int RSTpin=16;

    unsigned long lastMsg = 0;

    wifiManager wifi;
    mqttManager mqttClient;
    buzzer buzzerdevice;
    LCD lcd;
    baseActuator led;
    flameSensor flameSensordevice;
    temperatureSensor tempSensor;
    Sensor irSensor;
    Sensor soilMoistureSensor;
    RFID myRFID;


public:
    smartHome() 
        : wifi(wifissid, wifipassword), 
          mqttClient(mqttServer, mqttUsername, mqttPassword),
          buzzerdevice(buzzerPin),  // Example pin for buzzer
          lcd(),  // Example parameters for LCD
          led(LEDpin),  // Example pin for LED
          flameSensordevice(flamePin,&mqttClient),
          tempSensor(temperaturePin,&mqttClient),
          irSensor(irPin,&mqttClient),
          soilMoistureSensor(soilPin,&mqttClient),
          myRFID(SSpin,RSTpin,buzzerPin,servoPin)
    {}

    void establishConnections(){
        
        wifi.connect();
        wifi.check_connection();

        mqttClient.setup();
        mqttClient.connect();

        mqttClient.subscribe("light");
        mqttClient.subscribe("door/control");

    } 

    void setup(){
        smartDevice* smartdevices[] = { &servo, &buzzerdevice, &lcd, &led, &flameSensordevice,
                                        &tempSensor,&irSensor,&soilMoistureSensor,&myRFID};

        for (smartDevice* device : smartdevices) {
            device->deviceSetup();
        }
    }

    void publishSensors() {
        // Publish readings
        flameSensordevice.publishReading("sensors/flame");
        tempSensor.publishReading("sensors/temperature");
        soilMoistureSensor.publishReading("sensors/soilMoisture"); 
        if (irSensor.getReading()>1000) {
            irSensor.publishReading("sensor/long_distance");     
         }
        else {
            irSensor.publishReading("sensor/short_distance");  
        }
    }

void readSensors(){        // Read sensors
        flameSensordevice.sense();
        tempSensor.readTemperature();
        soilMoistureSensor.sense();
        irSensor.sense();

        if(flameSensordevice.getReading()==LOW) {
            buzzerdevice.startAction();
        }else{
            buzzerdevice.stopAction();
        }

        flameSensordevice.printtoSerial("flame");
        tempSensor.printtoSerial("temperature");
        soilMoistureSensor.printtoSerial("soil moisture");
        irSensor.printtoSerial("ir reading");
}

    void doorLockSystem(){
        Serial.println("door lock system");
        Serial.println("sensing..");
        irSensor.sense();  // Read the IR sensor

        if (irSensor.getReading() < 1000) {  // Assuming the IR sensor returns a positive value when someone is close
           // Display "Welcome" on the LCD
            lcd.clear();
            lcd.printMessage(0, 0, " scan card"); // Additional message on the second line
            myRFID.checkRFID();
        }
    }

    void ledBrightnessControl() {
        // Print the received topic and message for debugging
        Serial.println("Received topic: " + mqttClient.getTopic());
        Serial.println("Received message: " + mqttClient.getMessage());

        if (mqttClient.getTopic() == "light") {
            String ledread = mqttClient.getMessage();
            if (ledread == "on") {
                led.startAction();
            } else if (ledread == "off") {
                led.stopAction();
            }
        }}


    void doorControl(){
        // Print the received topic and message for debugging
        Serial.println("Received topic: " + mqttClient.getTopic());
        Serial.println("Received message: " + mqttClient.getMessage());

        if(mqttClient.getTopic()=="door/control"){
            String action = mqttClient.getMessage();
            if(action =="OPEN"){
                myRFID.myServo.setAngle(180);
            }else if (action == "CLOSE"){
                myRFID.myServo.setAngle(0);
            }
        }
}

    void loop(){
        if (!mqttClient.isConnected()) {
            mqttClient.connect();  // Reconnect if the connection is lost
        }
        mqttClient.loop(); // Process incoming messages
        unsigned long now = millis(); 

        if (now - lastMsg > 10000) { //publish irsensor, temperature and soilmoisture
            readSensors();
            publishSensors();
            lastMsg = now;
        }
         // Delay to avoid flooding the MQTT broker
        doorLockSystem();
        ledBrightnessControl();
        doorControl();
        delay(1000);
    } 

};



#endif
