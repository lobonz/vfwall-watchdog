//For Sparkfun Pro Micro 5.5V
const int BAUD_RATE = 9600;
const long WATCHDOG_TIMEOUT = 180000; // 3 minutes
const int RELAY_PIN = 7;
const int RELAY_PIN2 = 8;

const int RELAY_ON = LOW;//redefined for dual relay which is on when low
const int RELAY_OFF = HIGH;//redefined for dual relay which is on when low

//long next_message = 0;
String a;
unsigned long last_kick = millis();

long minute = 60000; // 60000 milliseconds in a minute
long second =  1000; // 1000 milliseconds in a second

void setup() {
  Serial.begin(BAUD_RATE);
  pinMode(RELAY_PIN, OUTPUT);
  pinMode(RELAY_PIN2, OUTPUT);
  digitalWrite(RELAY_PIN, RELAY_ON);
  digitalWrite(RELAY_PIN2, RELAY_ON);
  Serial.println("WATCHDOG");
  //kick();  
}

void loop() {
  if (Serial.available() > 0) {
    // read the incoming string:
    a = Serial.readStringUntil("\n");// read the incoming data as string
    //Serial.println(a);//reply with incoming data
    if (a == "HELO"){
      Serial.println("HELO");
    }else if (a == "TIME"){
      minsleft();
    }else if (a == "KICK"){
      //Serial.print("KICK = ");
      Serial.println(a);
      kick();
    } 
  }
  //report status
  //if (millis() > next_message){
  //  next_message = next_message + 10000;
  //  minsleft();
  //}
  
  if (((millis() - last_kick) >= WATCHDOG_TIMEOUT) && digitalRead(RELAY_PIN) == RELAY_ON) {
    Serial.println("TimedOut");
    digitalWrite(RELAY_PIN, RELAY_OFF);//LOW TURNS OFF
    digitalWrite(RELAY_PIN2, RELAY_OFF);//LOW TURNS OFF
  }
}

void kick() {
  last_kick = millis();
  digitalWrite(RELAY_PIN, RELAY_ON);//HIGH TURNS ON
  digitalWrite(RELAY_PIN2, RELAY_ON);//HIGH TURNS ON
  //Serial.println("Kick");
  //minsleft();
}

void minsleft(){
  long timeNow = last_kick+WATCHDOG_TIMEOUT - millis();
  int minutes = timeNow / minute ;         //and so on...
  int seconds = (timeNow % minute) / second;
  if ((millis() - last_kick) >= WATCHDOG_TIMEOUT){
    Serial.println("00:00");
  }else{
     // digital clock display of current time
     printDigits(minutes);
     Serial.print(":");
     printDigits(seconds);
     Serial.println();
  }
}

void printDigits(byte digits){
  // utility function for digital clock display: prints colon and leading 0
  if(digits < 10)
   Serial.print('0');
   Serial.print(digits,DEC);   
}
