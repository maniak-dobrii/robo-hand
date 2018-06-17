/*
 * MANIAK_dobrii's Robo hand firmware.
 * 
 * Currently you need to connect to Wi-Fi hotspot, html-based control is available on 192.168.4.1, will switch to (maybe) JSON API later.
 * Hardware buttons control is as well available, you can press/release, press/hold/release.
 */

#include "src/CommandDispatcher/command_loop.h"
#include "src/CommandDispatcher/function_command.h"
#include "PalmHardware.h"
#include "SetPostureCommand.h"

#include <ESP8266WiFi.h>
#include <WiFiClient.h> 
#include <ESP8266WebServer.h>


CommandDispatcher commandDispatcher(64); // 64 - max number of waiting commands
PalmHardware palm;

// Wi-Fi hotspot configuration
const char *ssid = "robo-hand";
const char *password = "robo-hand";

ESP8266WebServer server(80);


//
// Basic palm operations
//
void koza();
void fuck();
void fullOpen();

//
// ServerCommands
//
void sendControlPage();
void handleRoot();
void handleKoza();
void handleFuck();
void handleSetPosture();
void handleDeviceInfo();



void setup() {
  palm.setup();
  palm.setButtonsCallback(onButtonsEvent);

  setupWiFiAndServer();
}

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
  //
  // HTML API
  server.on("/", handleRoot);
  server.on("/koza", handleKoza);
  server.on("/fuck", handleFuck);
  //
  // JSON API
  server.on("/setPosture", handleSetPosture);
  server.on("/deviceInfo", handleDeviceInfo);
  server.begin();
  Serial.println("HTTP server started");  
}

void loop() 
{
  commandDispatcher.dispatch(millis());
  palm.updateButtons();
  server.handleClient();
} 


//
// Button events processing
//
Milliseconds lastPerformTimestamp = 0;
Milliseconds gesturePerformThresold = 1000;

void onButtonsEvent(kRHButton button, kRHButtonEvent event) {
  /*
   * I wanted better UX when you can have two things:
   *  1. Fast button press => palm perfoms gesture and expands back
   *  2. Press and hold => palm holds gesture and keeps it until you release the button
   *  
   *  That's why here on button Up fullOpen is immediately scheduled, while
   *  on button Down gesture is only scheduled if time thresold passed.
   */
  
  Milliseconds timeFromLastPerform = millis() - lastPerformTimestamp;
  
  if(event == kRHButtonEventUp) {
    Milliseconds afterDelay = (timeFromLastPerform > 500) ? 0 : 500;
    commandDispatcher.push(afterDelay, new FunctionCommand(fullOpen));
  } else {
    if(timeFromLastPerform > gesturePerformThresold) {
      Command *command = nullptr;

      switch(button) {
        case kRHButtonKoza: {
          command = new FunctionCommand(koza);
          break;
        }

        case kRHButtonFuck: {
          command = new FunctionCommand(fuck);
          break;
        }
      }

      commandDispatcher.push(0, command);
      lastPerformTimestamp = millis();
    }
  }
}


//
// Functions that could be passed into FunctionCommand.
//
void koza() {
  palm.koza();
}

void fuck() {
  palm.fuck();
}

void fullOpen() {
  palm.fullOpen();
}


//
// Server called functions
//
void sendControlPage() {
  server.send(200, "text/html", "<a href=\"koza\">koza</a>  |  <a href=\"fuck\">fuck</a>");  
}

void handleRoot() {
  sendControlPage();
}

void handleKoza() {
  commandDispatcher.push(0, new FunctionCommand(koza));
  commandDispatcher.push(500, new FunctionCommand(fullOpen));
  
  sendControlPage();
}

void handleFuck() {
  commandDispatcher.push(0, new FunctionCommand(fuck));
  commandDispatcher.push(500, new FunctionCommand(fullOpen));
  
  sendControlPage();
}

void handleSetPosture() {
  String argString;
  
  unsigned long after = 0;
  argString = server.arg("afterMilliseconds");
  if(argString.length() > 0) {
    after = strtoul(argString.c_str(), NULL, 10);
  }


  float thumbExtensionRate = kNoChangeExtensionRate;
  argString = server.arg("thumb");
  if(argString.length() > 0) {
    thumbExtensionRate = argString.toFloat();
  }

  
  float indexExtensionRate = kNoChangeExtensionRate;
  argString = server.arg("index");
  if(argString.length() > 0) {
    indexExtensionRate = argString.toFloat();
  }

  float middleExtensionRate = kNoChangeExtensionRate;
  argString = server.arg("middle");
  if(argString.length() > 0) {
    middleExtensionRate = argString.toFloat();
  }

  float ringExtensionRate = kNoChangeExtensionRate;
  argString = server.arg("ring");
  if(argString.length() > 0) {
    ringExtensionRate = argString.toFloat();
  }

  float pinkyExtensionRate = kNoChangeExtensionRate;
  argString = server.arg("pinky");
  if(argString.length() > 0) {
    pinkyExtensionRate = argString.toFloat();
  }

  SetPostureCommand *setPostureCommand = new SetPostureCommand(&palm, thumbExtensionRate, indexExtensionRate, middleExtensionRate, ringExtensionRate, pinkyExtensionRate);
  commandDispatcher.push(after, setPostureCommand);

  server.send(200, "application/json", "\"OK\""); 
}

void handleDeviceInfo() {
  server.send(200, "application/json", "{\"name\": \"MANIAK_dobrii's robo-hand mk1\", \"apiVersion\": \"0.0.1\"}"); 
}

