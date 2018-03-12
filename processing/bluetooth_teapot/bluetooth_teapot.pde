
// correct port:
// "/dev/cu.Hoth-DevB" 

PShape s;
import processing.serial.*;

// serial port object:
Serial arduino;      
final int baudRate   = 9600; 
final char delimiter = '\n';

// global storage var 
String serialStringFromArduino = null;
final char delim = ';';
float pitch;

void setup() {
  
  // list all the available serial ports:
  println("Available Serial Ports:"); 
  printArray(Serial.list());
  
  // open whatever port is the one you're using.
  final String portName = Serial.list()[1];
  println("\nOpening Serial Port: " + portName); 
  // create instance (https://processing.org/reference/libraries/serial/Serial.html): 
  arduino = new Serial(this, portName, baudRate);
  arduino.bufferUntil(delimiter);
 
 
  size(800, 800, OPENGL);
  
  s = loadShape("teapot.obj");
  
}

void draw(){

  // setup scene ------------------------------------------------------------
  
  background(245, 238, 184);
  fill(0, 0, 0);
  
  lights();
  
  pushMatrix();
  
  translate(width/2, height * 0.66);
  translate(-0.5, -0.5, -0.5);
  scale(80);
  
  // read serial ------------------------------------------------------------

  
  serialStringFromArduino = arduino.readStringUntil(delim);
  
  if (serialStringFromArduino != null) {
    
    //for printing only - remove any new lines from end of input string
    //String printStr = serialStringFromArduino;
    //if( serialStringFromArduino.charAt( serialStringFromArduino.length()-1) == '\n' ){
    //  printStr = serialStringFromArduino.substring( 0, serialStringFromArduino.length()-1 );
    //}
    //print("RX " + printStr + " >> ");
    
    
    //convert to value
    String[] valString = split(serialStringFromArduino, '=');
    if (valString[0].equals("pitch")){
      
      //print(valString[1]);
      
      float val = float(valString[1].substring(0, valString[1].length() - 1));
      //print(val);
    
      if(val > -180 
          && val < 180 
          && !(Float.isNaN(val))){
          
        pitch = val;
      }
    
      if(pitch > 30)
        pitch = 30;
      else if(pitch < -30)
        pitch = -30;
    }
    
    
    
    //println(" :: Pitch = " + pitch);
    
    
  
    
  }
  
  // render teapot ------------------------------------------------------------

  rotateY(PI);
  rotateX(PI - (-PI * 0.2));
  rotateZ(radians(pitch));
  
  shape(s, 0, 0);
  popMatrix();

}



  