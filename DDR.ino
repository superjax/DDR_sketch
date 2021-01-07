// DDR Mat Driver
// Use a https://www.amazon.com/gp/product/B07FXCTVQP/ref=ppx_yo_dt_b_asin_title_o04_s00?ie=UTF8&psc=1

#include "Keyboard.h"

// Because arduino is stupid, we don't have STL.  (There is really no good reason for this).
template <class T, size_t N>
struct Array 
{
    T data[N];

    static size_t size() { return N; }
    using type = T;

    T & operator[](size_t index) { return data[index]; }
    const T &operator[](size_t index) const { return data[index]; }

    // Iterators
    T *begin() { return &data[0]; }
    const T *begin() const { return &data[0]; }
    T *end() { return &data[N]; }
    const T *end() const { return &data[N]; }
};

static const uint32_t press_time_us = 80000;
static const uint32_t release_time_us = 80000;

struct PinState
{
  const int pin_number;
  int prev_state;
  const char key;
  const size_t change_time;
};

enum 
{
  JAMES = 0,
  KIM = 1,
  ANDERS = 2
};

template <int PAD>
const Array<PinState, 4> make_pins();

template<>
const Array<PinState, 4> make_pins<JAMES>()
{
  Array<PinState, 4> arr = {{
    {2, LOW, 'w', 0},
    {4, LOW, 'a', 0},
    {5, LOW, 's', 0},
    {3, LOW, 'd', 0}
  }};  
  return arr;
}

template<>
const Array<PinState, 4> make_pins<KIM>()
{
  Array<PinState, 4> arr = {{    
    {2, LOW, 'h', 0},
    {4, LOW, 't', 0},
    {5, LOW, 'f', 0},
    {3, LOW, 'h', 0}
  }};  
  return arr;
}

template<>
const Array<PinState, 4> make_pins<ANDERS>()
{
  Array<PinState, 4> arr = {{    
    {2, LOW, 'v', 0},
    {4, LOW, 'b', 0},
    {5, LOW, 'n', 0},
    {3, LOW, 'm', 0}
  }};  
  return arr;
}


static Array<PinState, 4> pins = make_pins<ANDERS>();

void setup() 
{
  // make the pushButton pin an input:
  for (auto pin : pins) {
    pinMode(pin.pin_number, INPUT_PULLUP);
  }
  
  // initialize control over the keyboard:
  Keyboard.begin();
}

enum 
{
  NO_CHANGE = 0,
  BUTTON_PRESSED = 1,
  BUTTON_RELEASED = 2,
};

int read_button(PinState& pin_state) 
{
  const int current_state = digitalRead(pin_state.pin_number);
  const auto now = micros();
  if (current_state != pin_state.prev_state) 
  {
    // Debounce the input
    const auto debounce_time_us = (pin_state.prev_state == LOW) ? press_time_us : release_time_us;
    if (now < pin_state.change_time + debounce_time_us) 
    {
      return NO_CHANGE;
    }
    
    pin_state.prev_state = current_state;
    if (current_state == HIGH) {
      return BUTTON_RELEASED;
    }
    else {
      return BUTTON_PRESSED;    
    }
  }
  return NO_CHANGE;
}

void loop() 
{
  // Update button state
  for (auto& pin : pins) 
  {
    const int change = read_button(pin);
    if (change == BUTTON_RELEASED)
    {
      Keyboard.release(pin.key);
    } 
    else if (change == BUTTON_PRESSED)
    {
      Keyboard.press(pin.key);
    }
  }
}
