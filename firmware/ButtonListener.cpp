#import "ButtonListener.h"
#import "arduino.h"

const int kMaxButtons = 2;

const unsigned long kDebouncePeriod = 50;


ButtonListener::ButtonListener(ButtonListenerDelegate *delegate) {
  this->delegate = delegate;
  this->pins = new uint8_t[kMaxButtons];
  this->states = new kButtonListeningState[kMaxButtons];
  this->stateChangeTimes = new unsigned long[kMaxButtons];
}

ButtonListener::~ButtonListener() {
  delete[] this->pins;
  this->pins = nullptr;
  
  delete[] this->states;
  this->states = nullptr;

  delete[] this->stateChangeTimes;
  this->stateChangeTimes = nullptr;
}



void ButtonListener::listenButtonOnPin(uint8_t pin) {
  // check if existing pin is already listened
  for(int i=0; i<this->count; i++) {
    if(this->pins[i] == pin) return;
  }

  // this should be logged
  if(this->count + 1 > kMaxButtons) return;

  this->pins[this->count] = pin;
  this->states[this->count] = kButtonListeningStateUp; // by default they are all UP
  this->stateChangeTimes[this->count] = millis();

  this->count++;
}


void ButtonListener::update() {
  for(int i=0; i<this->count; i++) {
    this->updateState(i);
  }
}

void ButtonListener::updateState(int pinIndex) {
    unsigned long now = millis();

    int digitalState = digitalRead(this->pins[pinIndex]);

    switch(this->states[pinIndex]) {
      case kButtonListeningStateUp: {
        if(digitalState == LOW) {
          this->setState(pinIndex, kButtonListeningStatePossibleDown);
        }

        break;
      }
      
      case kButtonListeningStatePossibleDown: {
        if(now - this->stateChangeTimes[pinIndex] >= kDebouncePeriod) {
          if(digitalState == LOW) {
            this->setState(pinIndex, kButtonListeningStateDown);
          } else {
            this->setState(pinIndex, kButtonListeningStateUp);
          }
        }
        
        break;
      }
      
      case kButtonListeningStateDown: {
        if(digitalState == HIGH) {
          this->setState(pinIndex, kButtonListeningStatePossibleUp);
        }
        
        break;
      }
      
      case kButtonListeningStatePossibleUp: {
        if(now - this->stateChangeTimes[pinIndex] >= kDebouncePeriod) {
          if(digitalState == HIGH) {
            this->setState(pinIndex, kButtonListeningStateUp);
          } else {
            this->setState(pinIndex, kButtonListeningStateDown);
          }
        }
        
        break;
      }
    }
}

void ButtonListener::setState(int pinIndex, kButtonListeningState state) {
  kButtonListeningState oldState = this->states[pinIndex];
  if(oldState == state) return;
  
  this->states[pinIndex] = state;
  this->stateChangeTimes[pinIndex] = millis();

  if(oldState == kButtonListeningStatePossibleUp && state == kButtonListeningStateUp) {
    this->notify(kButtonListenerEventButtonUp, this->pins[pinIndex]);
  }
  
  if(oldState == kButtonListeningStatePossibleDown && state == kButtonListeningStateDown) {
    this->notify(kButtonListenerEventButtonDown, this->pins[pinIndex]);
  }
}


void ButtonListener::notify(kButtonListenerEvent event, uint8_t pin) {
  if(this->delegate != nullptr) {
    this->delegate->onButtonListenerEvent(this, event, pin);
  }
}

