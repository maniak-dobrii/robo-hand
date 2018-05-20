// MANIAK_dobrii's Robo hand firmware prototype

#include "PalmHardware.h"
#include <Servo.h>

// Some servos are mounted in a way that clockwise rotation pulls the string, others
// are vice versa. This is used during servos binding in setup, 
// depends on how everything is connected in hardware.
enum kRHBindingDirection {
  kRHBindingDirectionLeft,
  kRHBindingDirectionRight
};

// Min and max angles for fingers in degrees
const int kRHAngleOpen = 170; // should be greater than kRHAngleClosed
const int kRHAngleClosed = 0; // should be less than kRHAngleOpen

const int servoCount = 5; // 5 fingers, right?
Servo servo[servoCount]; // servos to be attached
kRHBindingDirection bindings[servoCount]; // binding direction for each servo, see description above

void PalmHardware::setup() {
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
  this->fullOpen();
}

PalmHardware::~PalmHardware() {
  for(int i=0; i<servoCount; i++) {
    servo[i].detach();
  }
}


///////////////////////////
// Helpers
///////////////////////////
void PalmHardware::writeAngleToServo(int servoPosition, int angle)
{
  if(servoPosition < 0) return;
  if(servoPosition >= servoCount) return;

  if(bindings[servoPosition] == kRHBindingDirectionRight)
  {
    angle = 180 - angle;
  }
  
  angle = this->limitAngle(angle);

  servo[servoPosition].write(angle);
}

int PalmHardware::limitAngle(int angle)
{
  if(angle > kRHAngleOpen) return kRHAngleOpen;
  if(angle < kRHAngleClosed) return kRHAngleClosed;

  return angle;
}

int PalmHardware::angleFromNormalized(float normalizedExtendRatio) {
  if(normalizedExtendRatio > 1.0) normalizedExtendRatio = 1.0;
  if(normalizedExtendRatio < 0.0) normalizedExtendRatio = 0.0;

  return kRHAngleClosed + ((double)(kRHAngleOpen - kRHAngleClosed)) * normalizedExtendRatio;
}

void PalmHardware::extendFinger(kRHFinger finger, float normalizedExtendRatio) {
  this->writeAngleToServo(finger, angleFromNormalized(normalizedExtendRatio));
}


///////////////////////////
// Gesture Presets
///////////////////////////
void PalmHardware::fuck() {
  this->writeAngleToServo(kRHFingerMiddle, kRHAngleOpen);

  this->writeAngleToServo(kRHFingerThumb, kRHAngleClosed);
  this->writeAngleToServo(kRHFingerIndex, kRHAngleClosed);
  this->writeAngleToServo(kRHFingerRingFinder, kRHAngleClosed);
  this->writeAngleToServo(kRHFingerPinky, kRHAngleClosed);
}

void PalmHardware::koza() {
  this->writeAngleToServo(kRHFingerMiddle, kRHAngleClosed);

  this->writeAngleToServo(kRHFingerThumb, kRHAngleClosed);
  this->writeAngleToServo(kRHFingerIndex, kRHAngleOpen);
  this->writeAngleToServo(kRHFingerRingFinder, kRHAngleClosed);
  this->writeAngleToServo(kRHFingerPinky, kRHAngleOpen);  
}

void PalmHardware::spiderMan() {
  this->writeAngleToServo(kRHFingerMiddle, kRHAngleClosed);

  this->writeAngleToServo(kRHFingerThumb, kRHAngleOpen);
  this->writeAngleToServo(kRHFingerIndex, kRHAngleOpen);
  this->writeAngleToServo(kRHFingerRingFinder, kRHAngleClosed);
  this->writeAngleToServo(kRHFingerPinky, kRHAngleOpen);  
}

void PalmHardware::fullOpen() {
  this->writeAngleToServo(kRHFingerMiddle, kRHAngleOpen);

  this->writeAngleToServo(kRHFingerThumb, kRHAngleOpen);
  this->writeAngleToServo(kRHFingerIndex, kRHAngleOpen);
  this->writeAngleToServo(kRHFingerRingFinder, kRHAngleOpen);
  this->writeAngleToServo(kRHFingerPinky, kRHAngleOpen);   
}

void PalmHardware::fullClose() {
  this->writeAngleToServo(kRHFingerMiddle, kRHAngleClosed);

  this->writeAngleToServo(kRHFingerThumb, kRHAngleClosed);
  this->writeAngleToServo(kRHFingerIndex, kRHAngleClosed);
  this->writeAngleToServo(kRHFingerRingFinder, kRHAngleClosed);
  this->writeAngleToServo(kRHFingerPinky, kRHAngleClosed);   
}

