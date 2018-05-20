// MANIAK_dobrii's Robo hand firmware prototype

/*
 * Make sure you create only one instance of `PalmHardware`, as it uses global
 * resources. If you do - behavior is undefined.
 */

// Indexes into servo arrays (`servo` and `bindings`). 
// Depends on how everything is connected in hardware.
enum kRHFinger {
  kRHFingerThumb = 0,
  kRHFingerIndex = 4,
  kRHFingerMiddle = 3,
  kRHFingerRingFinder = 2,
  kRHFingerPinky = 1
};

// Normalized gesture specificators
const float kRHOpen = 1.0;
const float kRHClosed = 0.0;


class PalmHardware {
  public:
    ~PalmHardware();
    void setup(); // must be called once before anything else
    void extendFinger(kRHFinger finger, float normalizedExtendRatio);

    ///////////////////////////
    // Gesture Presets
    ///////////////////////////
    void fuck();
    void koza();
    void spiderMan();
    void fullOpen();
    void fullClose();

  private:
    void writeAngleToServo(int servoPosition, int angle);
    int limitAngle(int angle);
    int angleFromNormalized(float normalizedExtendRatio);
};

