#ifndef RFID_H
#define RFID_H
#include <SPI.h>
#include <MFRC522.h>
#include "Sensor.h"
#include "buzzer.h"
#include "LCD.h"
#include "servoMotor.h"

class RFID : public smartDevice {
private:
    MFRC522 rfid;          // Instance of the RFID class
    buzzer myBuzzer;       // Buzzer instance
    bool flag;             // stores the result of card recognition
    LCD rfidLCD;           // LCD to talk with the user

public:
    servoMotor myServo;    // Servo motor PUBLIC instance

    RFID(int SS_PIN, int RST_PIN, int buzzerPin, int servoPin) 
        : rfid(SS_PIN, RST_PIN), myBuzzer(buzzerPin), rfidLCD(), myServo(servoPin), flag(false) {}

    void deviceSetup() override {
        SPI.begin(); // Initiate SPI bus
        rfid.PCD_Init(); // Init MFRC522 PCD
        myBuzzer.deviceSetup(); // Initialize buzzer
        rfidLCD.deviceSetup(); // Initialize LCD
        myServo.deviceSetup(); // Initialize servo motor
        Serial.println("Approximate your Card to the Reader...."); 
    }

    void checkRFID() {
        if (rfid.PICC_IsNewCardPresent() && rfid.PICC_ReadCardSerial()) {
            String UID = ""; // to store tag id in it
            for (byte i = 0; i < rfid.uid.size; i++) {
                UID.concat(String(rfid.uid.uidByte[i] < 0x10 ? " 0" : " "));
                UID.concat(String(rfid.uid.uidByte[i], HEX));
            }
            Serial.print("UID:"); //print to serial
            Serial.println(UID);
            UID.toUpperCase(); // Convert UID to uppercase

            if (UID.substring(1) == "33 8A 0F 25") { 
                Serial.println("Authorized access");
                rfidLCD.printMessage(0, 0, "Authorized access");
                myServo.setAngle(180);  // Open the door
                flag = true;
            } else {
                rfidLCD.clear();
                rfidLCD.printMessage(0, 0, "Access denied");
                Serial.println("Access denied");
                myBuzzer.doorBuzzDenied();
                myServo.setAngle(0); //close the door
                flag = false;
            }
            rfid.PICC_HaltA();       // Stop encryption on PCD
            rfid.PCD_StopCrypto1();   // Stop communication with the card
        }
        if (flag) {
            // if access succeful
            myBuzzer.doorBuzzSuccess();
            flag = false;
        }
    }

};
#endif
