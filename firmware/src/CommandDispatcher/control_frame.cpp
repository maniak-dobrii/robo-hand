#import "control_frame.h"
#import "Command.h"
#import "timing.h"


Command *ControlFrame::getCommand() {
  return this->command->clone();
}

Timing *ControlFrame::getTiming() {
  return this->timing->clone();
}
  
ControlFrame::ControlFrame(Command *command, Timing *timing) {
  // hm, how do I assert things here?

  this->command = command;
  this->timing = timing;
}

ControlFrame::~ControlFrame() {
  delete this->command;
  delete this->timing;
}

