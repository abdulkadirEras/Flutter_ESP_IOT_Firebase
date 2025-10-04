#include <Arduino.h>
#include "driver/rtc_io.h"

#define BUTTON_PIN_BITMASK(GPIO) (1ULL << GPIO)  // 2 ^ GPIO_NUMBER in hex
#define KULLANILACAK_WAKEUP         1              // 1 = EXT0 , 0 = EXT1 , 2 = zamanlayıcı, 3 = Touchpad (Uyandrıma yöntemi seçimi)
#define WAKEUP_GPIO              GPIO_NUM_33     //  RTC IO 'nun tanımlı pinleri
#define ZAMANLAYICI_WAKEUP       5000000        // 5 saniye
RTC_DATA_ATTR int bootCount = 0;


void uykudan_uyanma_nedenini_yazdir();
void uyandirma_kaynaklarini_yapilandir();

void setup() 
{
  Serial.begin(115200);
  

  //önyükleme numarasını artırın ve her yeniden başlatmayı yazdırın
  ++bootCount;
  Serial.println("Onyukleme sayisi: " + String(bootCount));

  
  uykudan_uyanma_nedenini_yazdir();

  uyandirma_kaynaklarini_yapilandir();
  
  Serial.println("Simdi derin uyku moduna geciyor...");
  esp_deep_sleep_start();//Derin uyku moduna geç
  Serial.println("Bu cumle asla basilmayacak");
}

void loop() 
{
  //Buna çağrılmayacak
}


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

void uyandirma_kaynaklarini_yapilandir()
{
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
#if KULLANILACAK_WAKEUP==1
  esp_sleep_enable_ext0_wakeup(WAKEUP_GPIO, 1);  //1 = High, 0 = Low
  /*
   Derin uyku sırasında uyandırma pinlerini aktif olmayan seviyeye bağlamak için RTCIO üzerinden çekme/çıkışları yapılandırın.
   EXT0, RTC IO Pullup/Downs ile aynı güç alanında (RTC_PERIPH) bulunur.
   EXT1'in aksine, bu güç alanını açıkça tutmaya gerek yok.
  */
  rtc_gpio_pullup_dis(WAKEUP_GPIO);
  rtc_gpio_pulldown_en(WAKEUP_GPIO);

#elif KULLANILACAK_WAKEUP==2
  // Timer ile uyandırmayı etkinleştir
  esp_sleep_enable_timer_wakeup(ZAMANLAYICI_WAKEUP); //  mikro saniye cinsinden

#elif KULLANILACAK_WAKEUP==3
  // Touch pad ile uyandırmayı etkinleştir
  touchSleepWakeUpEnable()
#else // EXT1 WAKEUP
  
  esp_sleep_enable_ext1_wakeup_io(BUTTON_PIN_BITMASK(WAKEUP_GPIO), ESP_EXT1_WAKEUP_ANY_HIGH);
  /*
    Harici çekme/çıkışlar yoksa, uyandırma pinlerini RTC IO üzerinden dahili çekme/çıkışlarla aktif olmayan seviyeye bağlayın
    Deepsleep sırasında. Ancak RTC IO, RTC_PERIPH güç alanına dayanır. Bu güç alanını vasiyetnamede tutmak
    Biraz güç gelişimini artırın. Ancak, RTC_PERIPH etki alanını kapatırsak veya bazı yongalar RTC_PERIPH yoksa
    Domain, uyku sırasında pimlerin çekilmesini ve aşağı çekilmesini korumak için bekletme özelliğini kullanacağız.
  */
  rtc_gpio_pulldown_en(WAKEUP_GPIO);  // GPIO33, HIGH'da uyanmak için GND'ye bağlamıştır
  rtc_gpio_pullup_dis(WAKEUP_GPIO);   // HIGH'da uyanmasına izin vermek için pull_up'u devre dışı bırakın
  #endif
}