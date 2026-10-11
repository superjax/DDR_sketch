// DDR Mat Driver
// Use a https://www.amazon.com/gp/product/B07FXCTVQP/ref=ppx_yo_dt_b_asin_title_o04_s00?ie=UTF8&psc=1
// Requires the ArduinoJoystickLibrary (Matthew Heironimus) - install via
// Library Manager, search "Joystick". Needs a native-USB-HID board
// (Leonardo/Micro/Due class).

#include "Joystick.h"

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
  const uint8_t button;
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
    {2, LOW, 0, 0},
    {4, LOW, 1, 0},
    {5, LOW, 2, 0},
    {3, LOW, 3, 0}
  }};
  return arr;
}

template<>
const Array<PinState, 4> make_pins<KIM>()
{
  Array<PinState, 4> arr = {{
    {2, LOW, 0, 0},
    {4, LOW, 1, 0},
    {5, LOW, 2, 0},
    {3, LOW, 3, 0}
  }};
  return arr;
}

template<>
const Array<PinState, 4> make_pins<ANDERS>()
{
  Array<PinState, 4> arr = {{
    {2, LOW, 0, 0},
    {4, LOW, 1, 0},
    {5, LOW, 2, 0},
    {3, LOW, 3, 0}
  }};
  return arr;
}


static Array<PinState, 4> pins = make_pins<ANDERS>();

// 4 buttons, no hat switch, no analog axes - just the pad's 4 switches.
Joystick_ Joystick(
  JOYSTICK_DEFAULT_REPORT_ID,
  JOYSTICK_TYPE_GAMEPAD,
  4,     // button count
  0,     // hat switch count
  false, false, false,  // X, Y, Z axis
  false, false, false,  // Rx, Ry, Rz
  false, false,         // rudder, throttle
  false, false, false); // accelerator, brake, steering

void setup()
{
  // make the pushButton pin an input:
  for (auto pin : pins) {
    pinMode(pin.pin_number, INPUT_PULLUP);
  }

  // initialize control over the joystick:
  Joystick.begin();
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
      Joystick.releaseButton(pin.button);
    }
    else if (change == BUTTON_PRESSED)
    {
      Joystick.pressButton(pin.button);
    }
  }
}
