#import "Milliseconds.h"

class Timing {
  public:
    virtual Milliseconds when(Milliseconds current_milliseconds) = 0;
    virtual Timing *clone() = 0;
};

