import processing.serial.*;
String MSG = "Connecting...";
String TIMELEFT = "00:00";
float kickx;
float kicky;
float timex;
float timey;
boolean overKick = false;
boolean overTime = false;
boolean overAutoKick = false;
boolean autoKick = true;
float lastAutoKick = millis();

// The serial port:
Serial myPort;
String portName = "";
boolean found = false;

int lastTime = 0;

void setup(){
  size(300,300);
  
  // List all the available serial ports:
  printArray(Serial.list());
  println ("scan open com ports...");
  int lastPort = Serial.list().length -1;
  while (lastPort<0)
  {
    println("No com ports in use. Rescanning...");
    delay(1000);
    lastPort = Serial.list().length -1;
  }
  println("Locating device...");
  println(Serial.list());
  while (!found)
  {
    portName = Serial.list()[lastPort];
    println("Connecting to -> " + portName);
    delay(200);
   if (portName.indexOf("COM")>=0 ){
      try {
        myPort = new Serial(this, portName, 9600);
        myPort.clear();
        myPort.bufferUntil(10);
        myPort.write("HELO");// -- Send  Hello
        int l = 5;
        while (!found && l >0)
        {
          delay(1000);
          String inBuffer = myPort.readStringUntil(10);
          println("Waiting for response from device on " + portName);
          l--;
          if (inBuffer != null) {
            if(inBuffer.indexOf("WATCHDOG")>=0 || inBuffer.indexOf("HELO")>=0)
            {
              MSG = "CONNECTED";
              found = true;
            }
          }
        }
   
        if (!found)
        {
          println("No response from device on " + portName);
          myPort.clear();
          myPort.stop();
          delay(200);
        }
   
      }
      catch (Exception e) {
        println("Exception connecting to " + portName);
        println(e);
      }
   }
 
    lastPort--;
    if (lastPort <0)
      lastPort = Serial.list().length -1;
  }
  
  // Open the port you are using at the rate you want:
  //myPort = new Serial(this, "com14", 9600);
  rectMode(CORNER);
  //Get Timeleft
  myPort.write("TIME");
}
void draw(){
  background(0);
  String inBuffer = myPort.readStringUntil(10);
  
  if (inBuffer != null) {
    print(inBuffer);
    if (inBuffer.indexOf("TimedOut")>=0){
      MSG = "TIMEDOUT";
      TIMELEFT = "00:00";
    }else{
      TIMELEFT = inBuffer;
    }
  }
  textAlign(LEFT);
  fill(255, 0, 0);
  textSize(18);
  text ("LASTMSG: " + MSG, 10,30);
  text ("TIMELEFT: " + TIMELEFT, 10,60);
  
  //Time
  if (mouseX > width/9 && mouseX < width/9 + width/3 && 
      mouseY > 100 && mouseY < height-25) {
      overTime = true;
      strokeWeight(5);
      stroke(255); 
      fill(0,255,0);
    } else {
      strokeWeight(5);
      stroke(153);
      fill(0,255,0);
      overTime = false;
    }
    // Draw the box
    rect(width/9, 100, width/3, height-125);
    fill(0,0,0);
    textAlign(CENTER);
    text("TIME", width*.27, height*.6);
    
  //Kick
  if (mouseX > 5*width/9 && mouseX < 5*width/9 + width/3 && 
      mouseY > 150 && mouseY < height-25) {
      overKick = true;
      strokeWeight(5);
      stroke(255); 
      fill(0,0,255);
    } else {
      strokeWeight(5);
      stroke(153);
      fill(0,0,255);
      overKick = false;
    }
    // Draw the box
    rect(5*width/9, 155, width/3, height-175);
    fill(0,0,0);
    textAlign(CENTER);
    text("KICK", width*.73, height*.75);
    
    //AutoKick
    if (mouseX > 5*width/9 && mouseX < 5*width/9 + width/3 && 
      mouseY > 100 && mouseY < 150) {
      overAutoKick = true;
      strokeWeight(5);
      stroke(255); 
      fill(0,255,255);
    } else {
      strokeWeight(5);
      stroke(153);
      fill(0,255,255);
      overAutoKick = false;
    }
    // Draw the box
    rect(5*width/9, 100, width/3, 50);
    fill(0,0,0);
    textAlign(CENTER);
    if (autoKick){
      text("AUTO-ON", width*.725, height*.44);
    }else{
      text("AUTO-OFF", width*.725, height*.44);
    }
    
    if (millis() - lastTime > 10000){
      myPort.write("TIME");
      lastTime = millis();
    }
    if (millis() - lastAutoKick > 60 * 1000 & autoKick){
      myPort.write("KICK");
      //myPort.write("\n");    
      lastAutoKick = millis();
      MSG = "AUTOKICK";
    }
}

void mouseClicked() {
  if (overKick){
    // Send a capital "A" out the serial port
    myPort.write("KICK");
    //myPort.write("\n");    
    TIMELEFT = "03:00";
    MSG = "KICK";
  }
  if (overTime){
    myPort.write("TIME");
    MSG = "TIME";
  }
  if (overAutoKick){
    if (autoKick){
      autoKick = false;
      MSG = "AUTOKICKOFF";
    }else{
      autoKick = true;
      myPort.write("KICK");
      TIMELEFT = "03:00";
      MSG = "AUTOKICKON";
    }
  }
  
}
