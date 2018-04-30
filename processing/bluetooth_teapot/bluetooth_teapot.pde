
// correct port:
// "/dev/cu.Hoth-DevB" 


import processing.serial.*;




// serial port object:
Serial arduino;      
final int baudRate   = 9600; 

// global storage var 
String serialStringFromArduino = null;
final char delim = ';';


//teapot
PShape teapot;
float pitch;
float trgt_pitch;
final float change_speed = 0.8;
final float min_change = 0.1;
final int left_tilt_limit = -30;
final int right_tilt_limit = 30;
PImage img;

//cups
PShape cup;


//water droplets
ArrayList<Droplet> droplets = new ArrayList<Droplet>();
final int dropSpeed = 300; //px per second
int dropStartX, dropStartY;

//base at bottom of screen
int baseY, baseHeight;


//utility
int framesInSec = 0;
int sec = 0;
double fps = 60; //

void setup() {
  
  // list all the available serial ports:
  println("Available Serial Ports:"); 
  printArray(Serial.list());
  
  // open whatever port is the one you're using.
  final String portName = Serial.list()[1];
  println("\nOpening Serial Port: " + portName); 
  arduino = new Serial(this, portName, baudRate);
 
 
  // set window size 
  size(1000, 700, OPENGL);
  
  //load objs
  teapot = loadShape("teapot.obj");
  cup = loadShape("cup.obj");
  
  //texture
  img = loadImage("pattern1.png");
  teapot.setTexture(img); 

  //droplet start points
  dropStartX = int((width * 0.3));
  dropStartY = int(height * 0.4);
  
  //base
  baseY = int(height * 0.9);
  baseHeight = int(height * 0.1);

  
}

//respond to key presses
void keyPressed(){
  
  //w key triggers water droplet
   if (key == 'w'){
     
     droplets.add(new Droplet(dropStartX,dropStartY));
   }
}



void draw(){

  
  // output frame rate --------------------------------------------------------
  framesInSec++;
  if (millis() / 1000 > sec){
     sec++;
     fps = framesInSec;
     //println("Fps = " + framesInSec);
     framesInSec = 0;
  }
  

  // setup scene ------------------------------------------------------------
  
  background(245, 238, 184);
  fill(0, 0, 0);
  
  lights();
  

  // read serial ------------------------------------------------------------

  
  serialStringFromArduino = arduino.readStringUntil(delim);
  
  if (serialStringFromArduino != null) {
    
    //for printing only - remove any new lines from end of input string
    String printStr = serialStringFromArduino;
    if( serialStringFromArduino.charAt( serialStringFromArduino.length()-1) == '\n' ){
      printStr = serialStringFromArduino.substring( 0, serialStringFromArduino.length()-1 );
    }
    //print("RX " + printStr + " >> ");
    
    
    //convert string to key and value
    String[] valString = split(serialStringFromArduino, '=');
    if (valString[0].equals("pitch")){
      
      //print(valString[1]);
      
      //remove delimiter from input string
      float val = float(valString[1].substring(0, valString[1].length() - 1));
      //print(val);
    
      if(val > -180 
          && val < 180 
          && !(Float.isNaN(val))){
          
        trgt_pitch = val;
      }
    
      //limit target pitch
      if(trgt_pitch > right_tilt_limit)
        trgt_pitch = right_tilt_limit;
      else if(trgt_pitch < left_tilt_limit)
        trgt_pitch = left_tilt_limit;
    }
    
    //println(" :: Pitch = " + trgt_pitch);
  }
  
  // pitch smoothing function  
  
  if (trgt_pitch != pitch){
    float diff = trgt_pitch - pitch;
    float pitchChange = diff * change_speed;
    
    if (abs(pitchChange) < min_change){
      pitch = trgt_pitch;
    } else {
      pitch += pitchChange;
    }
  }  
    
    
  //render teapot ------------------------------------------------------------
  pushMatrix();
  translate(width/2, height * 0.45);
  translate(-0.5, -0.5, -0.5);
  scale(50);
  rotateY(PI);
  rotateX(PI - (-PI * 0.2));
  rotateZ(radians(pitch));

  shape(teapot, 0, 0);
  popMatrix();
  
  //render droplets ------------------------------------------------------------
  noStroke();
  fill(#a3c3f7);
  for (int i = droplets.size() - 1; i >= 0; i--){
     
    Droplet d = droplets.get(i);
    ellipse(d.x_pos, d.y_pos, 20, 20);
    
    d.y_pos += (dropSpeed / fps);
    
    if (d.y_pos > height)
      droplets.remove(i);
  }
  
  //render 'base' at bottom of screen ------------------------------------------------------------
  fill(#42464c);
  rect(0, baseY, width, baseHeight);
  
  
  pushMatrix();
  fill(#ffffff);
  scale(2);
  translate(width/2, height * 0.8);
  rotateX(PI)

  shape(cup, 0, 0);
  
  
  
  popMatrix();

}



  
