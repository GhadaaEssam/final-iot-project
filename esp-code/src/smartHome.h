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
    const int LEDpin=0;

    const int SSpin=5;
    const int RSTpin=16;

    unsigned long lastMsg = 0;

    wifiManager wifi;
    mqttManager mqttClient;
    servoMotor servo;
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
          servo(servoPin),
          buzzerdevice(buzzerPin),  
          lcd(),  
          led(LEDpin),  
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
        mqttClient.subscribe("led/brightness");
        mqttClient.subscribe("door/control");

    } 

    void setup(){
        smartDevice* smartdevices[] = { &buzzerdevice, &lcd, &led, &flameSensordevice,
                                        &tempSensor,&irSensor,&soilMoistureSensor,&myRFID};

        for (smartDevice* device : smartdevices) {
            device->deviceSetup();
        }
        servo.deviceSetup();
    }

    void publishSensors() {
        // Publish readings of sensors 
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

    void readSensors(){     
        // method Read sensors and print reading to the serial
        flameSensordevice.sense();
        tempSensor.readTemperature();
        soilMoistureSensor.sense();
        irSensor.sense();

        // manage the flame sensor reading
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
        // a method to manage the door lock using RFID
        Serial.println("door lock system");
        Serial.println("sensing..");
        irSensor.sense();  // Read the IR sensor

        if (irSensor.getReading() < 1000) {  // checking if someone is close
           // Display "scan card" on the LCD
            lcd.clear();
            lcd.printMessage(0, 0, " scan card"); // Additional message on the second line
            myRFID.checkRFID();//starts the RFID module
        }
    }


    void ledBrightnessControl(){
        if(mqttClient.getTopic()=="light"){
            
            String ledread = mqttClient.getMessage();
            // if switch is ON from flutter
            if(ledread=="on"){
                led.startAction(); 
            }
            // if switch is off from flutter
            else if (ledread=="off")
            {
                led.stopAction();
            }
        }
    }


  void loop(){
        if (!mqttClient.isConnected()) {
        mqttClient.connect();  // Reconnect if the connection is lost
        }
        mqttClient.loop(); // Process incoming messages
        unsigned long now = millis(); 

        if (now - lastMsg >= 5000) { //read and publish irsensor, temperature and soilmoisture
            readSensors();
            publishSensors();
            lastMsg = now;
        }
         // Delay to avoid flooding the MQTT broker
        doorLockSystem();
        ledBrightnessControl();
        delay(1000);   
      } 


};



#endif
