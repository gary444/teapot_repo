
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
PImage teapot_tx;

//cups
PShape cup;
int cup_x_pos;
int cup_speed;
int since_last_cup;
int random_wait;
int min_cup_wait;
ArrayList<Cup> cups = new ArrayList<Cup>();


//PImage cup_tx_1;
//PImage cup_tx_2;

//water droplets
ArrayList<Droplet> droplets = new ArrayList<Droplet>();
final int dropSpeed = 400; //px per second
int dropStartX, dropStartY;

int targetX,targetY,targetW,targetH;


//font
PFont mainFont;

//colours
int WATER_COLOR = 0xffa3c3f7;
int WHITE = 0xffffffff;

  

//game variables
int score;
int targetScore;
boolean cups_on;
final int GAME_TIME = 10;
int gameStart = 0;
int gameState; //0 - READY // 1 - PLAYING // 2 - ENDED

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
  fullScreen(OPENGL);
  
  //game setup
  score = 0;
  targetScore = 10;
  cups_on = true;
  
  //load font
  textFont(createFont("DS-Digital-Italic", 100));
  
  //load objs
  teapot = loadShape("teapot.obj");
  cup = loadShape("mug.obj");
  
  //textures
  teapot_tx = loadImage("pattern1.png");
  teapot.setTexture(teapot_tx); 
  
  //droplet start points
  dropStartX = int((width * 0.38));
  dropStartY = int(height * 0.4);
  
  targetX = int(width * 0.46);
  targetW = int(width * 0.03);
  targetY = int(height * 0.68);
  targetH = int(height * 0.09);
  
  //cup
  cup_x_pos = 0;
  cup_speed = 10;
  since_last_cup = 0;
  random_wait = 0;
  min_cup_wait = 100;
  
  gameState = 0;//ready
  
}

//respond to key presses
void keyPressed(){
  
  if (gameState == 0){
    //start game
    gameStart = millis();
    gameState = 1;
    score = 0;
  }
  else {
    //w key triggers water droplet
   if (key == 'w'){
     
     droplets.add(new Droplet(dropStartX,dropStartY));
   }
   //c key adds a cup
   else if (key == 'c'){
     addCup();
   }
   else if (key == 's'){
     cups_on = !cups_on;
   }
  }
  
}

void addCup(){
  cups.add(new Cup(0, height * 0.92));
}

void draw(){
  
  //check if game is finished
  if (gameState == 1){
    if((millis() - gameStart) / 1000 > GAME_TIME){
      gameState = 2;
    }
  }
      

  
  // output frame rate --------------------------------------------------------
  //framesInSec++;
  //if (millis() / 1000 > sec){
  //   sec++;
  //   fps = framesInSec;
  //   //println("Fps = " + framesInSec);
  //   framesInSec = 0;
  //}
  

  // setup scene ------------------------------------------------------------
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
    
    
  //render scene box---------------------------------------------------------
  fill(#ccdfff);
  pushMatrix();
  translate(width/2, height*0.4);
  stroke(255);
  box(1200,800, 2000);
  popMatrix();
    
  //render teapot ------------------------------------------------------------
  pushMatrix();
  translate(width/2, height * 0.47);
  translate(-0.5, -0.5, -0.5);
  scale(50);
  rotateY(PI);
  rotateX(PI - (-PI * 0.16));
  rotateZ(radians(pitch));

  shape(teapot, 0, 0);
  popMatrix();
  
  //render droplets ------------------------------------------------------------
  noStroke();
  
  for (int i = droplets.size() - 1; i >= 0; i--){
     
    Droplet d = droplets.get(i);
    
    pushMatrix();
    translate(d.x_pos, d.y_pos, 110);
    fill(WATER_COLOR);
    sphere(10);
    popMatrix();
    
    d.y_pos += (dropSpeed / fps);
    
    if (d.y_pos > height)
      droplets.remove(i);
  }
  
  //render 'base' at bottom of screen ------------------------------------------------------------
  fill(#42464c);
  pushMatrix();
  translate(width/2, height * 0.83);

  //noFill();
  stroke(255);

  box(1200,100, 400);
  popMatrix();
  
  
  //render cups ------------------------------------------------------------
  
  for (int i = cups.size() - 1; i >= 0; i--){
  
    Cup this_cup = cups.get(i);
    
    pushMatrix();
    
    //get colour
    int fill_col;
    if (this_cup.getHit())
      fill_col = WATER_COLOR;
    else 
      fill_col = WHITE;
    
    scale(0.8);
    translate(this_cup.getX(), this_cup.getY(), 140);
    
    //check for target hits
    if (this_cup.getX() > targetX && this_cup.getX() < (targetX + targetW)){
      //check water droplets
      for (int j = droplets.size() - 1; j >= 0; j--){
        Droplet d = droplets.get(j);
        if(d.y_pos > targetY && d.y_pos < (targetY + targetH)){
          //found hit
          score++;
          this_cup.setHit(true);
          droplets.remove(j);
        }
      }
    }
    cup.setFill(fill_col);
      
    
    rotateX(PI);
    rotateY(PI * 1.5);
    rotateZ(PI * -0.02);
    shape(cup, 0, 0);
    
    popMatrix();
    
    //update cup position //<>//
    this_cup.updateXPos(cup_speed);
    
    //delete if necessary
    if(this_cup.getX() > width * 1.5)
      cups.remove(i);
  }
  
  //add cup if necessary - and if playing
  if (cups_on && gameState == 1){
    if(since_last_cup > (min_cup_wait + random_wait)){
      
      addCup();
      since_last_cup = 0;
      random_wait = int(random(0,100));
       
    }
    else {
      since_last_cup++;
    }
  }
  
  
  

  
  //render intro screen/ timer / end screen
  if (gameState == 0){
    
    //ready state
    pushMatrix();
    translate(0,0,400);
    fill(0xff000000);
    stroke(0xffff0000);
    rect(width * 0.375,height * 0.375,width * 0.25,height * 0.25);//x,y,w,h
  
    
    fill(0xffff0000);
    textSize(height / 20);
    String introText = "Press any key\n  to continue";
    text(introText, width * 0.405, height * 0.48);//str,x,y,
    
    popMatrix();
    
    
  }
  else if (gameState == 1){
    
    //playing state
    
    //render score display
    fill(0xff000000);
    rect(width * 0.8, 0, width * 0.2, height * 0.2);
    String scoreString = str(score);
    fill(0xffff0000);
    textSize(height / 8);
    text(score, width * 0.85, height * 0.15);
    
    //timer
    fill(0xff000000);
    rect(width * 0.1, 0, width * 0.2, height * 0.2);
    //calc time since start:
    int timerSeconds =  (millis() - gameStart) / 1000;
    int timeRemaining = GAME_TIME - timerSeconds;
    String tm = nf(max(0,(timeRemaining / 60)), 2);
    String ts = nf(max(0,(timeRemaining % 60)), 2);
    String out_s = tm + ":" + ts;
    
    fill(0xffff0000);
    text(out_s, width * 0.12, height * 0.15);
    
  }
  else if (gameState == 2) {
    
    //ready state
    pushMatrix();
    translate(0,0,400);
    fill(0xff000000);
    stroke(0xffff0000);
    rect(width * 0.375,height * 0.375,width * 0.25,height * 0.25);//x,y,w,h
  
    
    fill(0xffff0000);
    textSize(height / 20);
    String endText = "game over\n  you scored: " + score;
    text(endText, width * 0.405, height * 0.48);//str,x,y,
    
    popMatrix();
  }

}



  
