#ifndef CIRCULAR_BUFFER_H
#define CIRCULAR_BUFFER_H

template <class T>
class CircularBuffer {
  public:
    CircularBuffer(int bufferSize) {
      if(bufferSize <= 0) bufferSize = 64;
    
      this->size = bufferSize;
      this->startIndex = 0;
      this->pushIndex = 0;
      this->frames = new T *[bufferSize](); // important to have all nullptrs
    }
    
    ~CircularBuffer() {
      // Delete all frames (if any)
      T *item = this->pop();
      while(item != nullptr) {
        delete item;
        item = this->pop();
      }

      // delete array
      delete[] this->frames;
    }


    // Adds to the end of the buffer, FIFO
    // If too much frames pushed, last stored frame is replaced with pushed.
    void push(T *controlFrame) {
      if(controlFrame == nullptr) return;

      int pushIndex = this->pushIndex;
      
      // overflow - replace last item (deallocate currently stored)
      if((this->isEmpty() == false) && (pushIndex == this->startIndex)) {        
        int endIndex = this->indexBefore(pushIndex);
  
        delete frames[endIndex];
        frames[endIndex] = nullptr;

        pushIndex = endIndex;
 
        // log this, frame buffer got exhausted
        // if this happens often try increasing buffer size
      }

      this->frames[pushIndex] = controlFrame;
      this->pushIndex = this->indexAfter(pushIndex);
    }
    
    // Removes first frame and returns it (calling side is responsible for deallocation, i.e. call `delete`)
    T *pop() {
      if(this->isEmpty()) return nullptr;

      T *firstFrame = this->firstFrame();

      this->frames[this->startIndex] = nullptr;
      this->startIndex = this->indexAfter(this->startIndex);

      return firstFrame;
    }
    
    // Returns `true` if empty
    bool isEmpty() {
      return this->firstFrame() == nullptr;
    }

    // Removes and deallocates all frames
    void clear() {
      for(int i=0; i<this->size; i++) {
        T *frame = this->frames[i];
        if(frame != nullptr) {
          delete frame;
          this->frames[i] = nullptr;
        }
      }

      this->startIndex = 0;
      this->pushIndex = 0;
    }
    
    
  private:
    int size = 0;
    int startIndex = 0;
    int pushIndex = 0;
    T **frames = nullptr; // cyclic buffer of size `size`

    // Returns first frame (don't deallocate given object, for optimization it does not return a copy!)
    // Returns nullptr if empty
    T *firstFrame() {
      return this->frames[this->startIndex];
    }

    // returns valid index before given `index` in a cyclic array of size `this->size`
    // guarantied to return index in [0, this->size-1]
    int indexAfter(int index) {
      index = this->normalizedIndex(index);
      
      if(index + 1 >= this->size) {
        return 0;
      } else {
        return index + 1;
      }
    }

    // returns valid index after given `index` in a cyclic array of size `this->size`
    // guarantied to return index in [0, this->size-1]
    int indexBefore(int index)  {
      index = this->normalizedIndex(index);
      
      if(index == 0) {
        return this->size - 1;
      } else {
        return index - 1;
      }
    }

    // returns valid index for given `index` in a cyclic array of size `this->size`
    // guarantied to return index in [0, this->size-1]
    int normalizedIndex(int index) {
      index = index % this->size;
      if(index < 0) {
        index = this->size + index;
      }
    
      return index;
    }
};

#endif
