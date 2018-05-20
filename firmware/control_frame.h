#ifndef CONTROL_FRAME_H
#define CONTROL_FRAME_H

class Timing;
class Command;

class ControlFrame {
  private:
    Command *command;
    Timing *timing;

  public:
    Command *getCommand(); // returns copy, you must `delete` it
    Timing *getTiming(); // returns copy, you must `delete` it
  
    ControlFrame(Command *command, Timing *timing); // takes ownership on `command` and `timing`
    ~ControlFrame();
};

#endif CONTROL_FRAME_H
