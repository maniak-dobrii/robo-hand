#ifndef COMMAND_H
#define COMMAND_H

class Command {
  public:
    virtual void command() = 0;
    virtual Command *clone() = 0;
};

#endif
