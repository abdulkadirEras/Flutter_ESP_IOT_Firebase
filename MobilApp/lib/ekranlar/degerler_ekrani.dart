import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import 'package:syncfusion_flutter_core/theme.dart';
class DegerleriAyarlaEkrani extends StatefulWidget {
  final Future<void> Function(String, dynamic) setKontrolVerisi;
  final bool sistemAktif;

  const DegerleriAyarlaEkrani({
    super.key,
    required this.setKontrolVerisi,
    required this.sistemAktif,
  });

  @override
  State<DegerleriAyarlaEkrani> createState() => _DegerleriAyarlaEkraniState();
}

class _DegerleriAyarlaEkraniState extends State<DegerleriAyarlaEkrani> {
  int _setSicaklikDegeri = 0;
  int _setDepo1SicaklikDegeri = 0;
  int _setDepo2SicaklikDegeri = 0;


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(107, 103, 158, 154),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4), // Gölge pozisyonu
                    ),
                  ],
                ),
              child: Center(
                child: Column(
                  
                  children: [ // const kaldırıldı
                    ElevatedButton.icon(
                      onPressed: () => widget.setKontrolVerisi("SistemAktif", !widget.sistemAktif),
                      icon: Icon(
                        widget.sistemAktif ? Icons.power_off : Icons.power_settings_new,
                        color: Colors.white,
                      ),
                      label: Text(
                        widget.sistemAktif ? "Sistemi Kapat" : "Sistemi Aç",
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.sistemAktif ? Colors.red : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(child: Text("Ana Depo Sıcaklık Set",style: TextStyle(fontSize: 16,),)),
                    SfSliderTheme(
                      data: SfSliderThemeData(), // Varsayılan tema verisi
                      child: SfSlider(
                        activeColor: Colors.red,
                        inactiveColor: Colors.orangeAccent  ,
                        
                        min: 0,
                        max: 100,
                        interval: 20,
                        showTicks: true,
                        showLabels: true,
                        enableTooltip: true,
                        tooltipShape: const SfPaddleTooltipShape(),
                        value: _setSicaklikDegeri.toDouble(),
                        onChanged: (dynamic yeniDeger) {
                          setState(() {
                            _setSicaklikDegeri = (yeniDeger as double).round();
                          });
                        },
                        onChangeEnd: (dynamic endValue) {
                          widget.setKontrolVerisi("setSicaklik", (endValue as double).round());
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(107, 175, 168, 244),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4), // Gölge pozisyonu
                    ),
                  ],
                ),
              child: Center(
                child: Column(
                  children: [ // const kaldırıldı    
                    const SizedBox(height: 20),
                    const Center(child: Text("Depo 1 Sıcaklık Set ",style: TextStyle(fontSize: 16,),)),
                    SfSliderTheme(
                      data: SfSliderThemeData(), // Varsayılan tema verisi
                      child: SfSlider(
                        activeColor: const Color.fromARGB(255, 33, 243, 54), // Rengi farklılaştıralım
                        inactiveColor: const Color.fromARGB(255, 138, 223, 146),
                        min: 0,
                        max: 100, 
                        interval: 20,
                        showTicks: true,
                        showLabels: true,
                        enableTooltip: true,
                        tooltipShape: const SfPaddleTooltipShape(),
                        value: _setDepo1SicaklikDegeri.toDouble(),
                        onChanged: (dynamic yeniDeger) {
                          setState(() {
                            _setDepo1SicaklikDegeri = (yeniDeger as double).round();
                          });
                        },
                        onChangeEnd: (dynamic endValue) {
                          widget.setKontrolVerisi("setDepo1Sicaklik", (endValue as double).round());
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(107, 83, 160, 228),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4), // Gölge pozisyonu
                    ),
                  ],
                ),
              child: Center(
                child: Column(
                  children: [ // const kaldırıldı    
                    const SizedBox(height: 20),
                    const Center(child: Text("Depo 2 Sıcaklık Set ",style: TextStyle(fontSize: 16,),)),
                    SfSliderTheme(
                      data: SfSliderThemeData(), // Varsayılan tema verisi
                      child: SfSlider(
                        activeColor: const Color.fromARGB(255, 215, 33, 243), // Rengi farklılaştıralım
                        inactiveColor: const Color.fromARGB(255, 203, 125, 245),
                        min: 0,
                        max: 100, 
                        interval: 20,
                        showTicks: true,
                        showLabels: true,
                        enableTooltip: true,
                        tooltipShape: const SfPaddleTooltipShape(),
                        value: _setDepo2SicaklikDegeri.toDouble(),
                        onChanged: (dynamic yeniDeger) {
                          setState(() {
                            _setDepo2SicaklikDegeri = (yeniDeger as double).round();
                          });
                        },
                        onChangeEnd: (dynamic endValue) {
                          widget.setKontrolVerisi("setDepo2Sicaklik", (endValue as double).round());
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),



          
        ],
      ),
    );
  }
}
