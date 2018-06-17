#import "src/CommandDispatcher/Command.h"

// Use to indicate no change in finger extension
extern const float kNoChangeExtensionRate;

class PalmHardware;

class SetPostureCommand: public Command {
  private:
    PalmHardware *palmRef = nullptr;
    float thumbExtensionRate = 0.0; 
    float indexExtensionRate = 0.0;
    float middleExtensionRate = 0.0;
    float ringExtensionRate = 0.0; 
    float pinkyExtensionRate = 0.0;
  
  public:
    SetPostureCommand(PalmHardware *palmRef, float thumbExtensionRate, float indexExtensionRate, float middleExtensionRate, float ringExtensionRate, float pinkyExtensionRate);
    void command();
    SetPostureCommand *clone();
};

