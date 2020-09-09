 #include <WiFi.h>
#include <FirebaseESP32.h>
 #include <Metro.h>
 #include <HTTPClient.h>
int motorPin1  = 12;  // Pin Conected to Ia1
int motorPin2  = 13;  // Pin Conected to Ia2
int senval = 0;
int run = 0;
int ini;
Metro m = Metro(5000);

bool nightMode = true;
bool swingMode = false;
TaskHandle_t Task1;
TaskHandle_t Task2;

const int led1 = 2;
const int led2 = 4;
FirebaseData firebaseData;

#define FIREBASE_HOST "smart-craddle.firebaseio.com" //Do not include https:// in FIREBASE_HOST
#define FIREBASE_AUTH "iACm2PkA2ssFFeSoX1jdQynQXYlgMGbCjZSKtuIc"
#define WIFI_SSID "Gaayathri"
#define WIFI_PASSWORD "Sanyu1234"
 HTTPClient http;
void setup() {
 
 
http.begin("https://fcm.googleapis.com/fcm/send");
http.addHeader("Content-Type", "text/plain");
http.addHeader("Authorization", "key=AAAAoRRWgww:APA91bGohDTS_ff7zJ3qcZXYJ9jUxw5QTJYxioipVtyQaoFjZLRPMlUx2mQLJ27Ws5IhvQ9Spdi0V3S30lTGMLZQYNjzpo_8GKbzypqatolvNkRuh3V_6hMxxAugu-53wl_Y0QlOgWvf");
  Serial.begin(9600);
    pinMode(motorPin1, OUTPUT);
    pinMode(motorPin2, OUTPUT);

  //create a task that will be executed in the Task1code() function, with priority 1 and executed on core 0
  xTaskCreatePinnedToCore(
                    Task1code,   /* Task function. */
                    "Task1",     /* name of task. */
                    10000,       /* Stack size of task */
                    NULL,        /* parameter of the task */
                    2,           /* priority of the task */
                    &Task1,      /* Task handle to keep track of created task */
                    0);          /* pin task to core 0 */                  
  delay(500); 

  //create a task that will be executed in the Task2code() function, with priority 1 and executed on core 1
  xTaskCreatePinnedToCore(
                    Task2code,   /* Task function. */
                    "Task2",     /* name of task. */
                    10000,       /* Stack size of task */
                    NULL,        /* parameter of the task */
                    1,           /* priority of the task */
                    &Task2,      /* Task handle to keep track of created task */
                    1);          /* pin task to core 1 */
    delay(500); 
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.reconnectWiFi(true);

  //Set database read timeout to 1 minute (max 15 minutes)
  //Firebase.setReadTimeout(firebaseData, 1000 * 60);
  //tiny, small, medium, large and unlimited.
  //Size and its write timeout e.g. tiny (1s), small (10s), medium (30s) and large (60s).
  //Firebase.setwriteSizeLimit(firebaseData, "tiny");
  int Code = http.POST("{ \"notification\":{\"body\":\"esp32\",\"title\":\"ON\"} }");
  if(Code==200){
    Serial.println("success");
  }
  ini = analogRead(A0);
}

//Task1code: blinks an LED every 1000 ms
void Task1code( void * pvParameters ){
  Serial.print("Task1 running on core ");
  Serial.println(xPortGetCoreID());

  for(;;){
    if(nightMode==true){
senval = analogRead(A0);
    Serial.println(senval);
    /*if(m.check() == 0){
      if(senval > 291){
        run = 1;
        }
      }*/
    if(senval < ini-5){
      Serial.println("high");
    digitalWrite(motorPin1, HIGH);  
    digitalWrite(motorPin2, LOW);   
    delay(500); 
    digitalWrite(motorPin1, LOW);
    digitalWrite(motorPin2, HIGH);
    delay(500);
    }else{
      Serial.println("low");
      digitalWrite(motorPin1, LOW);
      digitalWrite(motorPin2, LOW);
    }
    }else{
     digitalWrite(motorPin1, HIGH);  
    digitalWrite(motorPin2, LOW);   
    delay(500); 
    digitalWrite(motorPin1, LOW);
    digitalWrite(motorPin2, HIGH);
    delay(500);
    }
    
  } 
}

//Task2code: blinks an LED every 700 ms
void Task2code( void * pvParameters ){
  Serial.print("Task2 running on core ");
  Serial.println(xPortGetCoreID());

  for(;;){
   if( Firebase.getInt(firebaseData,"/nightMode")){
    if(firebaseData.intData() == 1){
  Serial.println("ON");
  nightMode = true;
  swingMode = false;
}else{
  Serial.println("OFF");
  swingMode = true;
  nightMode = false;
}
   }


  }
}

void loop() {
  
}
