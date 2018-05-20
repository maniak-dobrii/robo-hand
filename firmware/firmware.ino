// MANIAK_dobrii's Robo hand firmware prototype

#include <Servo.h>
#include "command_loop.h"
#include "function_command.h"
// oh, looks like Arduino autoincludes files in the same directory, think I should switch to a real IDE

// Some servos are mounted in a way that clockwise rotation pulls the string, others
// are vice versa. This is used during servos binding in setup, 
// depends on how everything is connected in hardware.
enum kRHBindingDirection {
  kRHBindingDirectionLeft,
  kRHBindingDirectionRight
};

// Indexes into servo arrays (`servo` and `bindings`). 
// Depends on how everything is connected in hardware.
enum kRHFinger {
  kRHFingerThumb = 0,
  kRHFingerIndex = 4,
  kRHFingerMiddle = 3,
  kRHFingerRingFinder = 2,
  kRHFingerPinky = 1
};

// Min and max angles for fingers in degrees
const int kRHAngleOpen = 170; // should be greater than kRHAngleClosed
const int kRHAngleClosed = 0; // should be less than kRHAngleOpen

// Normalized gesture specificators
const float kRHOpen = 1.0;
const float kRHClosed = 0.0;

const int servoCount = 5; // 5 fingers, right?
Servo servo[servoCount]; // servos to be attached
kRHBindingDirection bindings[servoCount]; // binding direction for each servo, see description above

void writeAngleToAllServos(int angle);
void extendFinger(kRHFinger finger, float normalizedExtendRatio);

void fuck();
void koza();
void spiderMan();
void fullOpen();
void fullClose();


CommandDispatcher commandDispatcher(64);




























#include <ESP8266WiFi.h>
#include <WiFiClient.h> 
#include <ESP8266WebServer.h>

/* Set these to your desired credentials. */
const char *ssid = "robo-hand";
const char *password = "robo-hand";

ESP8266WebServer server(80);


void sendControlPage() {
  server.send(200, "text/html", "<a href=\"koza\">koza</a>  |  <a href=\"fuck\">fuck</a>");  
}


void handleRoot() {
  sendControlPage();
}

void handleKoza() {
  sendControlPage();

  koza();
  delay(1000);
  fullOpen();
}

void handleFuck() {
  sendControlPage();

  fuck();
  delay(1000);
  fullOpen();
}

void handleGesture() {

  String value = server.arg("thumb");
  if(value.length() > 0) {
    extendFinger(kRHFingerThumb, value.toFloat());
  }
  
//    kRHFingerThumb = 0,
//  kRHFingerIndex = 4,
//  kRHFingerMiddle = 3,
//  kRHFingerRingFinder = 2,
//  kRHFingerPinky = 1
}



void setup() {
  //setupWiFiAndServer();
  setupPalmHardware();
}

//void loop() {
//  server.handleClient();
//}


void setupWiFiAndServer() {
  delay(1000);
  Serial.begin(115200);
  Serial.println();
  Serial.print("Configuring access point...");
  /* You can remove the password parameter if you want the AP to be open. */
  WiFi.softAP(ssid, password);

  IPAddress myIP = WiFi.softAPIP();
  Serial.print("AP IP address: ");
  Serial.println(myIP);
  server.on("/", handleRoot);
  server.on("/koza", handleKoza);
  server.on("/fuck", handleFuck);
  server.on("/gesture", handleGesture);
  server.begin();
  Serial.println("HTTP server started");  
}











void setupPalmHardware() {
  //
  // servos
  servo[0].attach(D0);
  bindings[0] = kRHBindingDirectionLeft;
  
  servo[1].attach(D5);
  bindings[1] = kRHBindingDirectionRight;
  
  servo[2].attach(D6);
  bindings[2] = kRHBindingDirectionRight;
  
  servo[3].attach(D7);
  bindings[3] = kRHBindingDirectionRight;
  
  servo[4].attach(D8);
  bindings[4] = kRHBindingDirectionLeft;

  //
  // buttons
  pinMode(D1, INPUT_PULLUP);
  pinMode(D2, INPUT_PULLUP);

  //
  // Extend all fingers on start, that helps to avoid bugs
  // and serves as a feedback that hand started. I was thinking to extend that feedback, so
  // that hand won't have any other way to provide feedback rather then constantly move a little bit.
  fullOpen();
}


void loop() 
{
  commandDispatcher.dispatch(millis());
  
  checkButtonAndFuck();
  checkButtonAndKoza();
} 


Milliseconds lastPerformTimestamp = 0;
Milliseconds buttonPerformThresold = 1000;
bool holdingButtonGesture = false;

// Check if button on `D1` is pushed and present "Koza" gesture (sign of the horns).
// Blocking debounce, I'll switch to non-blocking if I continue.
void checkButtonAndKoza() {
  if (digitalRead(D1) == LOW && (millis() > lastPerformTimestamp + buttonPerformThresold)) {
    delay(50); // yepp, it will eat 50ms, but that's fine for our purposes
    if(digitalRead(D1) == HIGH) return;

    commandDispatcher.push(0, new FunctionCommand(koza));
    holdingButtonGesture = true;

    lastPerformTimestamp = millis();
  }

  if(holdingButtonGesture && (digitalRead(D1) == HIGH) && (millis() > lastPerformTimestamp + buttonPerformThresold)) {
    delay(50);
    if(digitalRead(D1) == LOW) return;

    holdingButtonGesture = false;
    commandDispatcher.push(150, new FunctionCommand(fullOpen));

    lastPerformTimestamp = millis();
  }
}

// Check if button on `D2` is pushed and present "Fuck you" gesture.
// Blocking debounce, I'll switch to non-blocking if I continue.
void checkButtonAndFuck() {
  if (digitalRead(D2) == LOW && (millis() > lastPerformTimestamp + buttonPerformThresold)) {
    delay(50); // yepp, it will eat 50ms, but that's fine for our purposes
    if(digitalRead(D2) == HIGH) return;

    commandDispatcher.push(0, new FunctionCommand(fuck));
    holdingButtonGesture = true;

    lastPerformTimestamp = millis();
  }

  if(holdingButtonGesture && (digitalRead(D2) == HIGH) && (millis() > lastPerformTimestamp + buttonPerformThresold)) {
    delay(50);
    if(digitalRead(D2) == LOW) return;

    holdingButtonGesture = false;
    commandDispatcher.push(150, new FunctionCommand(fullOpen));

    lastPerformTimestamp = millis();
  }
}


///////////////////////////
// Helpers
///////////////////////////
void writeAngleToAllServos(int angle)
{
  for(int i=0; i<servoCount; i++)
    {
      writeAngleToServo(i, angle);
    }
}

void writeAngleToServo(int servoPosition, int angle)
{
  if(servoPosition < 0) return;
  if(servoPosition >= servoCount) return;

  if(bindings[servoPosition] == kRHBindingDirectionRight)
  {
    angle = 180 - angle;
  }
  
  angle = limitAngle(angle);

  servo[servoPosition].write(angle);
}

int limitAngle(int angle)
{
  if(angle > kRHAngleOpen) return kRHAngleOpen;
  if(angle < kRHAngleClosed) return kRHAngleClosed;

  return angle;
}

int angleFromNormalized(float normalizedExtendRatio) {
  if(normalizedExtendRatio > 1.0) normalizedExtendRatio = 1.0;
  if(normalizedExtendRatio < 0.0) normalizedExtendRatio = 0.0;

  return kRHAngleClosed + ((double)(kRHAngleOpen - kRHAngleClosed)) * normalizedExtendRatio;
}

void extendFinger(kRHFinger finger, float normalizedExtendRatio) {
  writeAngleToServo(finger, angleFromNormalized(normalizedExtendRatio));
}


///////////////////////////
// Gesture Presets
///////////////////////////
void fuck()
{
  writeAngleToServo(kRHFingerMiddle, kRHAngleOpen);

  writeAngleToServo(kRHFingerThumb, kRHAngleClosed);
  writeAngleToServo(kRHFingerIndex, kRHAngleClosed);
  writeAngleToServo(kRHFingerRingFinder, kRHAngleClosed);
  writeAngleToServo(kRHFingerPinky, kRHAngleClosed);
}

void koza()
{
  writeAngleToServo(kRHFingerMiddle, kRHAngleClosed);

  writeAngleToServo(kRHFingerThumb, kRHAngleClosed);
  writeAngleToServo(kRHFingerIndex, kRHAngleOpen);
  writeAngleToServo(kRHFingerRingFinder, kRHAngleClosed);
  writeAngleToServo(kRHFingerPinky, kRHAngleOpen);  
}

void spiderMan()
{
  writeAngleToServo(kRHFingerMiddle, kRHAngleClosed);

  writeAngleToServo(kRHFingerThumb, kRHAngleOpen);
  writeAngleToServo(kRHFingerIndex, kRHAngleOpen);
  writeAngleToServo(kRHFingerRingFinder, kRHAngleClosed);
  writeAngleToServo(kRHFingerPinky, kRHAngleOpen);  
}

void fullOpen()
{
  writeAngleToServo(kRHFingerMiddle, kRHAngleOpen);

  writeAngleToServo(kRHFingerThumb, kRHAngleOpen);
  writeAngleToServo(kRHFingerIndex, kRHAngleOpen);
  writeAngleToServo(kRHFingerRingFinder, kRHAngleOpen);
  writeAngleToServo(kRHFingerPinky, kRHAngleOpen);   
}

void fullClose()
{
  writeAngleToServo(kRHFingerMiddle, kRHAngleClosed);

  writeAngleToServo(kRHFingerThumb, kRHAngleClosed);
  writeAngleToServo(kRHFingerIndex, kRHAngleClosed);
  writeAngleToServo(kRHFingerRingFinder, kRHAngleClosed);
  writeAngleToServo(kRHFingerPinky, kRHAngleClosed);   
}

