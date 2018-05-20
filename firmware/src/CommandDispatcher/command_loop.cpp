#import "command_loop.h"
#import "control_frame.h"
#import "relative_timing.h"
#import "command.h"

CommandDispatcher::CommandDispatcher(int bufferSize) {
  if(bufferSize <= 0) bufferSize = 64;

  this->frameBuffer = new CircularBuffer<ControlFrame>(bufferSize);
}

CommandDispatcher::~CommandDispatcher() {
  delete this->frameBuffer;
  this->frameBuffer = nullptr;

  this->discardNextCommand();
}


void CommandDispatcher::push(unsigned long delayAfterLast, Command *command) {
  if(command == nullptr) return;
  
  RelativeTiming *relativeTiming = new RelativeTiming(delayAfterLast);
  ControlFrame *controlFrame = new ControlFrame(command, relativeTiming);

  this->frameBuffer->push(controlFrame);
}

void CommandDispatcher::removeAll() {
  this->frameBuffer->clear();
  this->discardNextCommand();
}

bool CommandDispatcher::isEmpty() {
  return this->frameBuffer->isEmpty() || this->nextCommand == nullptr;
}

void CommandDispatcher::dispatch(Milliseconds current_milliseconds) {
  // Check if there is dequeued command and fire it if time came
  if(this->nextCommand != nullptr) {
    if(this->nextCommandScheduledTime <= current_milliseconds) {
      this->nextCommand->command();
      this->discardNextCommand();
    }
  }

  // If there is no dequeued command - dequeue and calculate timing
  if(this->nextCommand == nullptr) {
    this->dequeueNextCommand(current_milliseconds);
  }
}


void CommandDispatcher::discardNextCommand() {
  if(this->nextCommand != nullptr) {
    delete this->nextCommand;
    this->nextCommand = nullptr;
  }

  this->nextCommandScheduledTime = 0;
}

void CommandDispatcher::dequeueNextCommand(Milliseconds current_milliseconds) {
  // This method is assumed to be called when there is no command dequeued.
  // In case this method do gets called when there is command dequeued - discard currently dequeued to avoid memory leaks.
  this->discardNextCommand();
  
  ControlFrame *nextFrame = this->frameBuffer->pop();
  
  if(nextFrame != nullptr) {
    this->nextCommand = nextFrame->getCommand(); // `getCommand` returns copy
    
    Timing *timing = nextFrame->getTiming();
    this->nextCommandScheduledTime = timing->when(current_milliseconds);
    delete timing;
  }  
}

