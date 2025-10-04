#include <Arduino.h>
#include "driver/rtc_io.h"

#define BUTTON_PIN_BITMASK(GPIO) (1ULL << GPIO)  // 2 ^ GPIO_NUMBER in hex
#define USE_EXT0_WAKEUP          1               // 1 = EXT0 wakeup, 0 = EXT1 wakeup
#define WAKEUP_GPIO              GPIO_NUM_33     // Only RTC IO are allowed - ESP32 Pin example
RTC_DATA_ATTR int bootCount = 0;



void uykudan_uyanma_nedenini_yazdir() 
{
  esp_sleep_wakeup_cause_t wakeup_reason;

  wakeup_reason = esp_sleep_get_wakeup_cause();

  switch (wakeup_reason) 
  {
    case ESP_SLEEP_WAKEUP_EXT0:     Serial.println("RTC_IO harici sinyal ile uyandi."); break;
    case ESP_SLEEP_WAKEUP_EXT1:     Serial.println("RTC_CNTL harici sinyal ile uyandi."); break;
    case ESP_SLEEP_WAKEUP_TIMER:    Serial.println("Timer ile uyandi."); break;
    case ESP_SLEEP_WAKEUP_TOUCHPAD: Serial.println("touchpad ile uyandi."); break;
    case ESP_SLEEP_WAKEUP_ULP:      Serial.println("ULP program ile uyandi"); break;
    default:                        Serial.printf("Uyanma derin uykudan kaynaklanmadi: %d\n", wakeup_reason); break;
  }
}

void setup() 
{
  Serial.begin(115200);
  

  //önyükleme numarasını artırın ve her yeniden başlatmayı yazdırın
  ++bootCount;
  Serial.println("Onyukleme sayisi: " + String(bootCount));

  
  uykudan_uyanma_nedenini_yazdir();

  /*
    Önce uyanma kaynağını yapılandırırız
    ESP32'mizi harici bir tetikleyiciye uyandırdık.
    ESP32, Ext0 ve Ext1 için iki tür vardır.
    Ext0, uyandırmak için RTC_IO kullanır, böylece RTC çevre birimleri gerektirir
    EXT1 RTC denetleyicisini kullanırken açık olmak için ihtiyaç duymaz
    Çevreseller açılacak.
    Dahili pullups/pulldowns kullanmanın da gerektirdiğini unutmayın.
    RTC çevre birimleri açılacak.
  */
#if USE_EXT0_WAKEUP
  esp_sleep_enable_ext0_wakeup(WAKEUP_GPIO, 1);  //1 = High, 0 = Low
  /*
   Derin uyku sırasında uyandırma pinlerini aktif olmayan seviyeye bağlamak için RTCIO üzerinden çekme/çıkışları yapılandırın.
   EXT0, RTC IO Pullup/Downs ile aynı güç alanında (RTC_PERIPH) bulunur.
   EXT1'in aksine, bu güç alanını açıkça tutmaya gerek yok.
  */
  rtc_gpio_pullup_dis(WAKEUP_GPIO);
  rtc_gpio_pulldown_en(WAKEUP_GPIO);

#else  // EXT1 WAKEUP
  //If you were to use ext1, you would use it like
  esp_sleep_enable_ext1_wakeup_io(BUTTON_PIN_BITMASK(WAKEUP_GPIO), ESP_EXT1_WAKEUP_ANY_HIGH);
  /*
    If there are no external pull-up/downs, tie wakeup pins to inactive level with internal pull-up/downs via RTC IO
         during deepsleep. However, RTC IO relies on the RTC_PERIPH power domain. Keeping this power domain on will
         increase some power comsumption. However, if we turn off the RTC_PERIPH domain or if certain chips lack the RTC_PERIPH
         domain, we will use the HOLD feature to maintain the pull-up and pull-down on the pins during sleep.
  */
  rtc_gpio_pulldown_en(WAKEUP_GPIO);  // GPIO33 is tie to GND in order to wake up in HIGH
  rtc_gpio_pullup_dis(WAKEUP_GPIO);   // Disable PULL_UP in order to allow it to wakeup on HIGH
#endif
  //Go to sleep now
  Serial.println("Simdi derin uyku moduna geciyor...");
  esp_deep_sleep_start();
  Serial.println("Bu cumle asla basilmayacak");
}

void loop() 
{
  //Buna çağrılmayacak
}
