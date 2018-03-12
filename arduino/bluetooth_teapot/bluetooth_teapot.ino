//setup

//9 v battery to battery input

//bluetooth chip pins:
// 1 (grey) to arduino TX (digital 1)
// 2 (purple) to arduino RX (digital 0)
// 3 (blue) to arduino 3.3V power
// 4 (green) to arduino ground

// accelerometer
// 1 (red) VIN to arduino 5V power
// 2 (black) GND to arduino ground
// 3 (white) SCL to Analog In 5
// 4 (orange) SDA to Analog In 4


#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_LSM303_U.h>
#include <Adafruit_L3GD20_U.h>
#include <Adafruit_9DOF.h>

float pitch = 0.0;
float threshold = 1.0;

/* Assign a unique ID to the sensors */
Adafruit_9DOF                dof   = Adafruit_9DOF();
Adafruit_LSM303_Accel_Unified accel = Adafruit_LSM303_Accel_Unified(30301);
//Adafruit_LSM303_Mag_Unified   mag   = Adafruit_LSM303_Mag_Unified(30302);


/**************************************************************************/
/*!
    @brief  Initialises all the sensors used by this example
*/
/**************************************************************************/
void initSensors()
{
  if(!accel.begin())
  {
    /* There was a problem detecting the LSM303 ... check your connections */
    Serial.println(F("Ooops, no LSM303 detected ... Check your wiring!"));
    while(1);
  }
}

/**************************************************************************/
/*!

*/
/**************************************************************************/
void setup(void)
{
  Serial.begin(9600);
  Serial.println(F("Adafruit 9 DOF Pitch/Roll/Heading Example")); Serial.println("");
  
  /* Initialise the sensors */
  initSensors();
}

/**************************************************************************/
/*!
    @brief  Constantly check the roll/pitch/heading/altitude/temperature
*/
/**************************************************************************/
void loop(void)
{
  sensors_event_t accel_event;
//  sensors_event_t mag_event;
  sensors_vec_t   orientation;

  /* Calculate pitch and roll from the raw accelerometer data */
  accel.getEvent(&accel_event);
  if (dof.accelGetOrientation(&accel_event, &orientation))
  {

    float newPitch = orientation.pitch;
    if (abs(pitch - newPitch) > threshold){

      pitch = newPitch;
      Serial.print("pitch=");
      Serial.print(newPitch);
      Serial.print(";");
    }
    
    
  }

//  Serial.println(20);
//  Serial.println("hello");
  delay(100);
}
