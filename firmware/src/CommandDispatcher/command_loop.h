#ifndef COMMAND_LOOP_H
#define COMMAND_LOOP_H

#import "circular_buffer.h"
#import "Milliseconds.h"

class ControlFrame;
class Command;

class CommandDispatcher {
  public:
    CommandDispatcher(int bufferSize);
    ~CommandDispatcher();

    void push(Milliseconds delayAfterLast, Command *command);
    void removeAll();
    bool isEmpty();

    // call in a loop with a desired frequency
    // it will dequeue 
    void dispatch(Milliseconds current_milliseconds);


  private:
    CircularBuffer<ControlFrame> *frameBuffer = nullptr;

    //
    // next scheduled operation 
    Command *nextCommand = nullptr;
    Milliseconds nextCommandScheduledTime = 0;

    void dequeueNextCommand(Milliseconds current_milliseconds);
    void discardNextCommand();
};

#endif // COMMAND_LOOP_H
