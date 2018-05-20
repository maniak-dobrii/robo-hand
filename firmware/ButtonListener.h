#include <stdint.h>

#ifndef BUTTON_LISTENER_H
#define BUTTON_LISTENER_H

enum kButtonListenerEvent {
  kButtonListenerEventButtonDown,
  kButtonListenerEventButtonUp
};

enum kButtonListeningState {
  kButtonListeningStateUp,
  kButtonListeningStatePossibleDown,
  kButtonListeningStateDown,
  kButtonListeningStatePossibleUp
};


class ButtonListener;

class ButtonListenerDelegate {
  public:
    virtual void onButtonListenerEvent(ButtonListener *buttonListener, kButtonListenerEvent event, uint8_t pin);
};

class ButtonListener {
  public:
    ButtonListener(ButtonListenerDelegate *delegate);
    ~ButtonListener();
    void listenButtonOnPin(uint8_t pin);
    void update();


  private:
    ButtonListenerDelegate *delegate;
    int count = 0;
    uint8_t *pins;
    kButtonListeningState *states;
    unsigned long *stateChangeTimes;

    void updateState(int pinIndex);
    void setState(int pinIndex, kButtonListeningState state);
    void notify(kButtonListenerEvent event, uint8_t pin);
};

#endif

