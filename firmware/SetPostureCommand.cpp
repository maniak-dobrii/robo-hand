#import "SetPostureCommand.h"
#import "PalmHardware.h"

const float kNoChangeExtensionRate = -1.0;

SetPostureCommand::SetPostureCommand(PalmHardware *palmRef, float thumbExtensionRate, float indexExtensionRate, float middleExtensionRate, float ringExtensionRate, float pinkyExtensionRate) {
  // assert palmRef here
  this->palmRef = palmRef;
  
  this->thumbExtensionRate = thumbExtensionRate; 
  this->indexExtensionRate = indexExtensionRate;
  this->middleExtensionRate = middleExtensionRate;
  this->ringExtensionRate = ringExtensionRate; 
  this->pinkyExtensionRate = pinkyExtensionRate;
}

void SetPostureCommand::command() {
  if(this->palmRef == nullptr) return;
    
  if(this->thumbExtensionRate != kNoChangeExtensionRate) {
    this->palmRef->extendFinger(kRHFingerThumb, this->thumbExtensionRate);
  }

  if(this->indexExtensionRate != kNoChangeExtensionRate) {
    this->palmRef->extendFinger(kRHFingerIndex, this->indexExtensionRate);
  }

  if(this->middleExtensionRate != kNoChangeExtensionRate) {
    this->palmRef->extendFinger(kRHFingerMiddle, this->middleExtensionRate);
  }

  if(this->ringExtensionRate != kNoChangeExtensionRate) {
    this->palmRef->extendFinger(kRHFingerRingFinder, this->ringExtensionRate);
  }

  if(this->pinkyExtensionRate != kNoChangeExtensionRate) {
    this->palmRef->extendFinger(kRHFingerPinky, this->pinkyExtensionRate);
  }
}

SetPostureCommand *SetPostureCommand::clone() {
  return new SetPostureCommand(this->palmRef, this->thumbExtensionRate, this->indexExtensionRate, this->middleExtensionRate, this->ringExtensionRate, this->pinkyExtensionRate);
}

