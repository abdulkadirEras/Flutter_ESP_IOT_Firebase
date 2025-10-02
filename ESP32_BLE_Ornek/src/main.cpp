#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <Wire.h>


//BLE Sunucu Adı
#define bleSunucuAdi "ESP32_Sunucu"

//Adafruit_BME280 bme; // I2C

float temp;
float tempF;
float hum;

// State machine değişkenleri
unsigned long sonZaman = 0;
unsigned long zamanlayiciSuresi = 30000;

bool cihazBagliMi = false;

uint16_t rastgeleSayi;
uint16_t rastgeleSayi2;

// UUIDs üretmek için bu siteyi kullanabilirsiniz:
// https://www.uuidgenerator.net/
#define SERVICE_UUID "91bad492-b950-4226-aa2b-4ede9fa42f59"

// rastgele sayı 1 için Characteristic ve Descriptor tanımları
BLECharacteristic rastgeleSayi1Characteristics("cba1d466-344c-4be3-ab3f-189f80dd7518", BLECharacteristic::PROPERTY_NOTIFY);
BLEDescriptor rastgeleSayi1Descriptor(BLEUUID((uint16_t)0x2902));


// rastgele sayı 2 için Characteristic ve Descriptor tanımları
BLECharacteristic bmeHumidityCharacteristics("ca73b3ba-39f6-4ab3-91ae-186dc9577d99", BLECharacteristic::PROPERTY_NOTIFY);
BLEDescriptor bmeHumidityDescriptor(BLEUUID((uint16_t)0x2903));

//bağlantı kontrolleri için callback sınıfı oluşturulması
class sunucuCallBacklerim: public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    cihazBagliMi = true;
  };
  void onDisconnect(BLEServer* pServer) {
    cihazBagliMi = false;
  }
};



void setup() 
{
  // Uart haberleşmesini başlat
  Serial.begin(115200);


  // BLE Cihazını başlat
  BLEDevice::init(bleSunucuAdi);

  // BLE Sunucunu oluştur ve callback'leri ayarla
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new sunucuCallBacklerim());

  // BLE servisini oluştur
  BLEService *rastgeleSayiService = pServer->createService(SERVICE_UUID);

  // rastgele sayı 1 için BLE Characteristics ve BLE Descriptor eklenmesi
  rastgeleSayiService->addCharacteristic(&rastgeleSayi1Characteristics);
  rastgeleSayi1Characteristics.setValue("BME temperature Celsius");
  rastgeleSayi1Characteristics.addDescriptor(&rastgeleSayi1Descriptor);


  // rastgele sayı 2 için BLE Characteristics ve BLE Descriptor eklenmesi
  rastgeleSayiService->addCharacteristic(&bmeHumidityCharacteristics);
  bmeHumidityDescriptor.setValue("BME humidity");
  bmeHumidityCharacteristics.addDescriptor(new BLE2902());
  
  // Service başlat
  rastgeleSayiService->start();

  // yayınlamayı başlat
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pServer->getAdvertising()->start();
  Serial.println("Istemci baglantisi bekleniyor...");
}

void loop() 
{
   rastgeleSayi = random(1, 1000 + 1);
   rastgeleSayi2 = random(1, 1000 + 1);

  if (cihazBagliMi) 
  {
    if ((millis() - sonZaman) > zamanlayiciSuresi) 
    {
 
      static char rastgeleSayiChar[6];
      dtostrf(rastgeleSayi, 6, 2, rastgeleSayiChar);
      //rastgele sayi 1 Characteristic değerini ayarla ve istemciye bildir
      rastgeleSayi1Characteristics.setValue(rastgeleSayiChar);
      rastgeleSayi1Characteristics.notify();
      Serial.print("rastgele sayi 1: ");
      Serial.println(rastgeleSayi);
     
      
      static char rastgeleSayiChar2[6];
      dtostrf(rastgeleSayi2, 6, 2, rastgeleSayiChar2);
      //rastgele sayi 2 Characteristic değerini ayarla ve istemciye bildir
      bmeHumidityCharacteristics.setValue(rastgeleSayiChar2);
      bmeHumidityCharacteristics.notify();   
      Serial.print(" rastgele sayi 2: ");
      Serial.println(rastgeleSayi2);
      
      sonZaman = millis();
    }
  }
}


