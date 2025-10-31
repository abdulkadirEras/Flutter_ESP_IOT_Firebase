//Giriş için macro tanımlamalar
#define ENABLE_USER_AUTH
#define ENABLE_DATABASE

//Gerekli Kütüphanelerin tanımlanması
#include <Arduino.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <FirebaseClient.h>



//Ağ ve Kimlik bilgileri
#define WIFI_SSID "MERCUSYS"//"REPLACE_WITH_YOUR_SSID"
#define WIFI_PASSWORD "SySeRaSlan938054."//"REPLACE_WITH_YOUR_PASSWORD"

#define Web_API_KEY "AIzaSyBECRKiGiT56X-325BDHjdqOKzIqgHPnM0"//"REPLACE_WITH_YOUR_FIREBASE_PROJECT_API_KEY"//Project Overview den alınan Web API Key
#define DATABASE_URL "https://iotprojesi-191222-default-rtdb.firebaseio.com/"//"REPLACE_WITH_YOUR_FIREBASE_DATABASE_URL" //Realtime Database'den alınan URL
#define USER_EMAIL "aeras@aeras.com"//"REPLACE_WITH_FIREBASE_PROJECT_EMAIL_USER"//Firebase de Authentication da oluşturulan mail ve parola 
#define USER_PASS "asdqwe"//"REPLACE_WITH_FIREBASE_PROJECT_USER_PASS"

#define gondermeAraligi 10000 // 10 saniye

// Fonksiyon
void islenenVeri(AsyncResult &aSonuc);
void firebaseden_verileri_oku(void);
void firebase_verileri_yaz(void);



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
unsigned long simdikiZaman = 0;


// Database gönderilecek değişkenler
typedef struct
{
  uint8_t SistemAktif;
  uint8_t Depo1SetSicaklik;
  uint8_t Depo2SetSicaklik;
  uint8_t SetSicaklik;
}databaseOkumaDegiskenleri;

typedef struct
{
  uint16_t voltajDegeri;
  uint16_t sicaklikDegeri;
  uint16_t akimDegeri;
  uint16_t depo1Sicaklik;
  uint16_t depo2Sicaklik;

}databaseYazmaDegiskenleri;



databaseOkumaDegiskenleri firebaseOkuma;
databaseYazmaDegiskenleri firebaseYazma;
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
     simdikiZaman = millis();
    if (simdikiZaman - sonGondermeZamani >= gondermeAraligi)
    {
      
      sonGondermeZamani = simdikiZaman;
      

      firebase_verileri_yaz();
      firebaseden_verileri_oku();

     
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

void firebaseden_verileri_oku()
{
  
  Serial.println("Database verileri okunuyor...");
  firebaseOkuma.SistemAktif = Database.get(aClient, "/Kontrol/SistemAktif");
  Serial.print("Sistem Aktif: ");
  Serial.println(firebaseOkuma.SistemAktif);


  firebaseOkuma.Depo1SetSicaklik = Database.get(aClient, "/Kontrol/setDepo1Sicaklik");
  Serial.print("Depo 1 Set Sicaklik: ");
  Serial.println(firebaseOkuma.Depo1SetSicaklik);

 
  firebaseOkuma.Depo2SetSicaklik = Database.get(aClient, "/Kontrol/setDepo2Sicaklik");
  Serial.print("Depo 2 Set Sicaklik: ");
  Serial.println(firebaseOkuma.Depo2SetSicaklik);
}

void firebase_verileri_yaz(void)
{
  Serial.println("Database veriler yaziliyor...");
  // Örnek değerler
  firebaseYazma.akimDegeri=(uint16_t)random (0,50);
  Database.set<int>(aClient, "/Olcum/Akim", firebaseYazma.akimDegeri, islenenVeri, "RTDB_Send_Int");

  firebaseYazma.depo1Sicaklik=(uint16_t)random (0,100);
  Database.set<int>(aClient, "/Olcum/Depo1Sicaklik", firebaseYazma.depo1Sicaklik, islenenVeri, "RTDB_Send_Int");
  

  firebaseYazma.depo2Sicaklik=(uint16_t)random (0,100);
  Database.set<int>(aClient, "/Olcum/Depo2Sicaklik", firebaseYazma.depo2Sicaklik, islenenVeri, "RTDB_Send_Int");

  firebaseYazma.sicaklikDegeri=(uint16_t)random (0,100);
  Database.set<int>(aClient, "/Olcum/Sicaklik", firebaseYazma.sicaklikDegeri, islenenVeri, "RTDB_Send_Int");

  firebaseYazma.voltajDegeri=(uint16_t)random (0,500);
  Database.set<int>(aClient, "/Olcum/Voltaj", firebaseYazma.voltajDegeri, islenenVeri, "RTDB_Send_Int");


}