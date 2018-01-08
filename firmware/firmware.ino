// MANIAK_dobrii's Robo hand firmware prototype

#include <Servo.h>

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

// Unconstrained angles, later I'll move to normalized values
const int kRHAngleOpen = 180;
const int kRHAngleClosed = 0;

const int servoCount = 5; // 5 fingers, right?
Servo servo[servoCount]; // servos to be attached
kRHBindingDirection bindings[servoCount]; // binding direction for each servo, see description above

void writeAngleToAllServos(int angle);

void fuck();
void koza();
void spiderMan();
void fullOpen();
void fullClose();


void setup() {
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
  checkButtonAndFuck();
  checkButtonAndKoza();
} 


// Primitive protection against concurrent gestures, a bit overkill here for the current state of the code.
bool performing = false;

// Check if button on `D1` is pushed and present "Koza" gesture (sign of the horns).
// Blocking debounce, I'll switch to non-blocking if I continue.
void checkButtonAndKoza() {
  if (digitalRead(D1) == LOW && performing == false) {
    delay(50);
    if(digitalRead(D1) == HIGH) return;

    performing = true;
    
    koza();
    delay(1000);
    fullOpen();
    delay(1000);

    performing = false;
  }
}

// Check if button on `D2` is pushed and present "Fuck you" gesture.
// Blocking debounce, I'll switch to non-blocking if I continue.
void checkButtonAndFuck() {
  if (digitalRead(D2) == LOW && performing == false) {
    delay(50);
    if(digitalRead(D2) == HIGH) return;

    performing = true;
    
    fuck();
    delay(1000);
    fullOpen();
    delay(1000);

    performing = false;
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
  if(angle > 170) return 170;
  if(angle < 0) return 0;

  return angle;
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

