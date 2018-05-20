#import "Command.h"

typedef void (*FunctionRef)();

class FunctionCommand: public Command {
  private:
    FunctionRef functionRef = nullptr;
  
  public:
    FunctionCommand(FunctionRef functionRef);
    void command();
    FunctionCommand *clone();
};

