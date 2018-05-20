// MANIAK_dobrii's Robo hand firmware prototype

#include "CommandDispatcher/command_loop.h"
#include "CommandDispatcher/function_command.h"
#include "PalmHardware.h"


CommandDispatcher commandDispatcher(64);
PalmHardware palm;




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

  palm.koza();
  delay(1000);
  palm.fullOpen();
}

void handleFuck() {
  sendControlPage();

  palm.fuck();
  delay(1000);
  palm.fullOpen();
}

void handleGesture() {

  String value = server.arg("thumb");
  if(value.length() > 0) {
    palm.extendFinger(kRHFingerThumb, value.toFloat());
  }
}



void setup() {
  //setupWiFiAndServer();
  palm.setup();
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







void loop() 
{
  commandDispatcher.dispatch(millis());
  
  checkButtonAndFuck();
  checkButtonAndKoza();
} 


void koza() {
  palm.koza();
}

void fuck() {
  palm.fuck();
}

void fullOpen() {
  palm.fullOpen();
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
