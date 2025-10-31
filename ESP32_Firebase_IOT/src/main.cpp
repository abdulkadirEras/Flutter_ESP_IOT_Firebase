//Giriş için macro tanımlamalar
#define ENABLE_USER_AUTH
#define ENABLE_DATABASE

//Gerekli Kütüphanelerin tanımlanması
#include <Arduino.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <FirebaseClient.h>



//Ağ ve Kimlik bilgileri
#define WIFI_SSID "REPLACE_WITH_YOUR_SSID"
#define WIFI_PASSWORD "REPLACE_WITH_YOUR_PASSWORD"

#define Web_API_KEY "REPLACE_WITH_YOUR_FIREBASE_PROJECT_API_KEY"
#define DATABASE_URL "REPLACE_WITH_YOUR_FIREBASE_DATABASE_URL"
#define USER_EMAIL "REPLACE_WITH_FIREBASE_PROJECT_EMAIL_USER"
#define USER_PASS "REPLACE_WITH_FIREBASE_PROJECT_USER_PASS"

#define gondermeAraligi 10000 // 10 saniye

// Fonksiyon
void islenenVeri(AsyncResult &aSonuc);

// Kullanıcı Authentication Giriş
UserAuth kullanici_auth(Web_API_KEY, USER_EMAIL, USER_PASS);

// Firebase bileşenleri
FirebaseApp uyg;
WiFiClientSecure ssl_client;
using AsyncClient = AsyncClientClass;
AsyncClient aClient(ssl_client);
RealtimeDatabase Database;

// Timer variables for sending data every 10 seconds
unsigned long sonGondermeZamani = 0;


// Database gönderilecek değişkenler
int intValue = 0;
float floatValue = 0.01;
String stringValue = "";




void setup() 
{
  Serial.begin(115200);

  //Wi-Fi ye bağlan
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Wi-Fi' ye baglaniyor");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  
  //SSL client ayarlamaları
  ssl_client.setInsecure();
  ssl_client.setConnectionTimeout(1000);
  ssl_client.setHandshakeTimeout(5);
  
  // Firebase init edildi
  initializeApp(aClient, uyg, getAuth(kullanici_auth), islenenVeri, "🔐 authTask");
  uyg.getApp<RealtimeDatabase>(Database);
  Database.url(DATABASE_URL);
}

void loop() 
{
  // Kimlik doğrulama ve eşzamansız görevleri koru
  uyg.loop();
  // Kimlik doğrulamanın hazır olup olmadığını kontrol et
  if (uyg.ready())
  { 
    // her 10 sn yede bir veri gönder
    unsigned long currentTime = millis();
    if (currentTime - sonGondermeZamani >= gondermeAraligi)
    {
      
      sonGondermeZamani = currentTime;
      
      // send a string
      stringValue = "value_" + String(currentTime);
      Database.set<String>(aClient, "/test/string", stringValue, islenenVeri, "RTDB_Send_String");
      // send an int
      Database.set<int>(aClient, "/test/int", intValue, islenenVeri, "RTDB_Send_Int");
      intValue++; //increment intValue in every loop

      // send a string
      floatValue = 0.01 + random (0,100);
      Database.set<float>(aClient, "/test/float", floatValue, islenenVeri, "RTDB_Send_Float");
    }
  }
}


void islenenVeri(AsyncResult &aSonuc) 
{
  if (!aSonuc.isResult())
    return;

  if (aSonuc.isEvent())
    Firebase.printf("event task: %s, mesaj: %s, kod: %d\n", aSonuc.uid().c_str(), aSonuc.eventLog().message().c_str(), aSonuc.eventLog().code());

  if (aSonuc.isDebug())
    Firebase.printf("Debug task: %s, mesaj: %s\n", aSonuc.uid().c_str(), aSonuc.debug().c_str());

  if (aSonuc.isError())
    Firebase.printf("Error task: %s, mesaj: %s, kod: %d\n", aSonuc.uid().c_str(), aSonuc.error().message().c_str(), aSonuc.error().code());

  if (aSonuc.available())
    Firebase.printf("task: %s, payload: %s\n", aSonuc.uid().c_str(), aSonuc.c_str());
}