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
  palm.setButtonsCallback(onButtonsEvent);
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

  palm.updateButtons();
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
