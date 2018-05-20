// MANIAK_dobrii's Robo hand firmware prototype

#import "ButtonListener.h"
// ook, I don't know how to hide this dependency from the header easy enough, only the hard ways, so I leave it here

/*
 * Make sure you create only one instance of `PalmHardware`, as it uses global
 * resources. If you do - behavior is undefined.
 */

 #ifndef PALM_HARDWARE_H
 #define PALM_HARDWARE_H

// Indexes into servo arrays (`servo` and `bindings`). 
// Depends on how everything is connected in hardware.
enum kRHFinger {
  kRHFingerThumb = 0,
  kRHFingerIndex = 4,
  kRHFingerMiddle = 3,
  kRHFingerRingFinder = 2,
  kRHFingerPinky = 1
};

enum kRHButton {
  kRHButtonFuck,
  kRHButtonKoza
};

enum kRHButtonEvent {
  kRHButtonEventDown,
  kRHButtonEventUp
};

typedef void(*RHButtonsCallback)(kRHButton, kRHButtonEvent);

// Normalized gesture specificators
const float kRHOpen = 1.0;
const float kRHClosed = 0.0;


class PalmHardware: ButtonListenerDelegate {
  public:
    PalmHardware();
    ~PalmHardware();
    void setup(); // must be called once before anything else
    void extendFinger(kRHFinger finger, float normalizedExtendRatio);

    void updateButtons(); // must be called in loop regulary
    void setButtonsCallback(RHButtonsCallback callback);
    void onButtonListenerEvent(ButtonListener *buttonListener, kButtonListenerEvent event, uint8_t pin);

    ///////////////////////////
    // Gesture Presets
    ///////////////////////////
    void fuck();
    void koza();
    void spiderMan();
    void fullOpen();
    void fullClose();

  private:
    ButtonListener *buttonsListener;
    RHButtonsCallback buttonsCallback;
  
    void writeAngleToServo(int servoPosition, int angle);
    int limitAngle(int angle);
    int angleFromNormalized(float normalizedExtendRatio);
    void notifyButtonEvent(kRHButton button, kRHButtonEvent event);
    bool buttonEventForButtonListenerEvent(kButtonListenerEvent event, kRHButtonEvent *output);
    bool buttonForPin(uint8_t pin, kRHButton *output);
};

#endif

