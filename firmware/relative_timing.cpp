#import "relative_timing.h"

RelativeTiming::RelativeTiming(Milliseconds delay) {
  this->delay = delay;
}

RelativeTiming *RelativeTiming::clone() {
  return new RelativeTiming(this->delay);
}

Milliseconds RelativeTiming::when(Milliseconds current_milliseconds) {
  return current_milliseconds + this->delay;
}
