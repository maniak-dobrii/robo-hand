#import "function_command.h"

FunctionCommand::FunctionCommand(FunctionRef functionRef) {
  this->functionRef = functionRef;
}

void FunctionCommand::command() {
  if(this->functionRef != nullptr) {
    this->functionRef();
  }
}

FunctionCommand *FunctionCommand::clone() {
  return new FunctionCommand(this->functionRef);
}

