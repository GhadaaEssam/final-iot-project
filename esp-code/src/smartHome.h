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
// This class controls the whole system manages all the sensors and actuators and their actions
private:
    //connections configurations
    const char* wifissid = "";
    const char* wifipassword = "";

    const char* mqttServer = "";
    const char* mqttUsername =  "";
    const char* mqttPassword = "";

    // initialize pins
    const int flamePin = 27;
    const int temperaturePin = 35;
    const int irPin = 32;
    const int soilPin = 34;
    
    const int servoPin =14;

    const int buzzerPin=33;
    const int LEDpin=13;

    const int SSpin=5;
    const int RSTpin=16;

    // last time the reading of sensors was published
    unsigned long lastMsg = 0;

    //instances of classes
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
    //the sondtructor
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
        //connect to wifi
        wifi.connect();
        wifi.check_connection();
        //connect to mqtt
        mqttClient.setup();
        mqttClient.connect();
        subscribe to topics we need
        mqttClient.subscribe("light");
        mqttClient.subscribe("door/control");
    } 

    void setup(){
        //use devicesetup for all our devices
        smartDevice* smartdevices[] = { &buzzerdevice, &lcd, &led, &flameSensordevice,
                                        &tempSensor,&irSensor,&soilMoistureSensor,&myRFID};
        for (smartDevice* device : smartdevices) {
            device->deviceSetup();
        }}
    void readSensors(){      
        // Read from sensors
        flameSensordevice.sense();
        tempSensor.readTemperature();
        soilMoistureSensor.sense();
        irSensor.sense();

        //managing flames
        if(flameSensordevice.getReading()==LOW) {
            buzzerdevice.startAction();
        }else{
            buzzerdevice.stopAction();
        }}    
    void publishSensors() {
        // Publish readings
        flameSensordevice.publishReading("sensors/flame");
        tempSensor.publishReading("sensors/temperature");
        soilMoistureSensor.publishReading("sensors/soilMoisture"); 

        // publish reading of ir on topic long distance if reading is >1000 and on short distance if <1000
        if (irSensor.getReading()>1000) {  
            irSensor.publishReading("sensor/long_distance");     
         }
        else {
            irSensor.publishReading("sensor/short_distance");  
        }}

    void doorLockSystem(){
        Serial.println("door lock system");
        Serial.println("sensing..");
        irSensor.sense();  // Read the IR sensor

        if (irSensor.getReading() < 1000) {  //starts the RFID recognition when someone is close
            lcd.clear();
            lcd.printMessage(0, 0, " scan card"); //system talks with the user through the lcd
            myRFID.checkRFID();
        }}

    void ledBrightnessControl() {
        // Print the received topic and message for debugging
        Serial.println("Received topic: " + mqttClient.getTopic());
        Serial.println("Received message: " + mqttClient.getMessage());
        if (mqttClient.getTopic() == "light") { //detects if any message sent on topic light from flutter
            String ledread = mqttClient.getMessage();
            if (ledread == "on") {
                led.startAction();         // turm on the lamp
            } else if (ledread == "off") {
                led.stopAction();          // turn off the lamp
    }}}

    void doorControl(){     // Print the received topic and message for debugging
        Serial.println("Received topic: " + mqttClient.getTopic());
        Serial.println("Received message: " + mqttClient.getMessage());
        
        // manage servo depending on the recieved message from flutter
        if(mqttClient.getTopic()=="door/control"){ // detects if any message is sent on the topic door/control
            String action = mqttClient.getMessage();  
            if(action =="OPEN"){
                myRFID.myServo.setAngle(180);    //opens the door
            }else if (action == "CLOSE"){
                myRFID.myServo.setAngle(0);       // closes the door
            }}}

    void loop(){
        if (!mqttClient.isConnected()) {
            mqttClient.connect();  // Reconnect if the connection is lost
        }
        mqttClient.loop(); // Process incoming messages
        unsigned long now = millis(); 

        if (now - lastMsg > 10000) { //publish irsensor, temperature and soilmoisture each 10 secs
            readSensors();
            publishSensors();
            lastMsg = now;        //updates lastMsg
        }
         // Delay to avoid flooding the MQTT broker
        doorLockSystem();
        ledBrightnessControl();
        doorControl();
        delay(1000);
    } 
};
#endif
