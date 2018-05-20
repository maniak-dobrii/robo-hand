#import "timing.h"

class RelativeTiming final: public Timing {
  private:
    Milliseconds delay;

  public:
    RelativeTiming(Milliseconds delay);
    RelativeTiming *clone();
    Milliseconds when(Milliseconds currentmilliseconds);
};
