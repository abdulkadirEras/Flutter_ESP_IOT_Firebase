import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../widgets/gaugeBarWidget.dart';

class VeriEkrani extends StatelessWidget {
  final int akimDatabase;
  final int voltajDatabase;
  final int sicaklikDatabase;
  final int depo1Sicaklik;
  final int depo2Sicaklik;
  final Future<void> Function(String, bool) setKontrolVerisi;

  const VeriEkrani({
    super.key,
    required this.akimDatabase,
    required this.voltajDatabase,
    required this.sicaklikDatabase,
    required this.setKontrolVerisi,
    required this.depo1Sicaklik,
    required this.depo2Sicaklik, 
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // İçeriği yukarı hizala
          children: <Widget>[
         
            const SizedBox(height: 2),
            Container(
              color: Colors.indigo.shade50, // Arka plan rengi
              padding:
                  const EdgeInsets.symmetric(vertical: 2.0), // Dikeyde iç boşluk
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                        child: SfRadialGauge(
                      
                      enableLoadingAnimation: true,
                      animationDuration: 1200,
                      //backgroundColor: Colors.white,
                      axes: <RadialAxis>[
                        RadialAxis(
                            axisLineStyle: const AxisLineStyle(thickness: 30),
                            showTicks: false,
                            pointers: <GaugePointer>[
                              NeedlePointer(
                                value: akimDatabase.toDouble(),
                                
                                enableAnimation: true,
                                needleStartWidth: 0,
                                needleEndWidth: 5,
                                needleColor: const Color.fromARGB(255, 210, 8, 8),
                                knobStyle: const KnobStyle(
                                    color: Colors.indigo,
                                    borderColor: Color.fromARGB(255, 236, 5, 5),
                                    knobRadius: 0.06,
                                    borderWidth: 0.04),
                                tailStyle: const TailStyle(
                                    color: Color.fromARGB(255, 198, 6, 6),
                                    width: 5,
                                    length: 0.15),
                              ),
                              RangePointer(
                                  value: akimDatabase.toDouble(), //Dikkat
                                  width: 20,
                                  enableAnimation: true,
                                  enableDragging: true,
                                  color: Colors.indigo,)
                            ],
                            showLabels: true,
                            annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                              horizontalAlignment : GaugeAlignment.near,
                              verticalAlignment: GaugeAlignment.near,

                                widget: Text(
                                  "$akimDatabase A",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 20),
                                      
                                ),
                                angle: 140,
                                positionFactor: 0.2)
                          ],
                            ),
                            
                      ],
                      
                    )),
                    const SizedBox(
                      width: 10,
                      height: 40,
                    ),
                    Flexible(
                      child: AnimatedCircularGauge(
                        guncelDegeri: voltajDatabase.toDouble(),
                        birimSecimi: 1, //2=A, 1=V, 0=C
                        maxDeger: 300.0,
                        konturGenisligi: 25.0, // Kalınlığı belirle
                        widgetBoyutu: 200.0,
                        gaugeRengi: Colors.green,
                        gaugeAltRenk: Colors.greenAccent,
                        yaziStili: const TextStyle(
                            fontSize: 35.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown),
                      ),
                    ),
                  ]),
            ),
            
            Container(
              color: Colors.orange.shade50, // Arka plan rengi
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0), // Dikeyde iç boşluk
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    child: SfRadialGauge(
                      axes: <RadialAxis>[
                      RadialAxis(

                          interval: 10,
                          startAngle: 0,
                          endAngle: 360,
                          showLabels: false,
                          axisLineStyle: const AxisLineStyle(thickness: 20),
                          pointers: <GaugePointer>[
                            RangePointer(
                                value: sicaklikDatabase.toDouble(),
                                width: 20,
                                color: Colors.deepOrange,
                                enableAnimation: true,
                                cornerStyle: CornerStyle.bothCurve)
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                                widget: Text(
                                  "$sicaklikDatabase °C",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 20),
                                ),
                                angle: 180,
                                positionFactor: 0.1)
                          ],
                          )
                    ]),
                  ),
                  const SizedBox(
                    width: 10,
                    height: 40,
                  ),
                  Flexible(
                    child: AnimatedCircularGauge(
                      guncelDegeri:
                          akimDatabase.toDouble() * voltajDatabase.toDouble(),
                      birimSecimi: 3, //3=W
                      maxDeger: 5000.0,
                      konturGenisligi: 20.0, // Kalınlığı belirle
                      widgetBoyutu: 150.0, // Boyutu belirle
                      gaugeRengi: Colors.red, // İlerleme rengini özelleştir
                      gaugeAltRenk: Colors.redAccent,
                      yaziStili:
                          const TextStyle(fontSize: 30.0, color: Colors.brown),
                    ),
                  ),
                ],
              ),
            ),
            
         
            const SizedBox(height: 12),

          Container(
              color: const Color.fromARGB(255, 190, 235, 228), // Arka plan rengi
              padding:
                  const EdgeInsets.symmetric(vertical: 2.0), // Dikeyde iç boşluk
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                        child: SfRadialGauge(
                          title: GaugeTitle(text: "Depo 1 Sıcaklık",backgroundColor: Colors.white,borderColor: Colors.green,borderWidth: 4,alignment: GaugeAlignment.center),
                      backgroundColor: const Color.fromARGB(172, 213, 251, 148),
                      enableLoadingAnimation: true,
                      animationDuration: 200,
                      //backgroundColor: Colors.white,
                      axes: <RadialAxis>[
                        RadialAxis(
                            axisLineStyle: const AxisLineStyle(thickness: 30),
                            showTicks: false,
                            pointers: <GaugePointer>[
                              NeedlePointer(
                                value: depo1Sicaklik.toDouble(),
                                enableAnimation: true,
                                needleStartWidth: 0,
                                needleEndWidth: 5,
                                needleColor: const Color.fromARGB(255, 210, 8, 8),
                                knobStyle: const KnobStyle(
                                    color: Colors.indigo,
                                    borderColor: Color.fromARGB(255, 236, 5, 5),
                                    knobRadius: 0.06,
                                    borderWidth: 0.04),
                                tailStyle: const TailStyle(
                                    color: Color.fromARGB(255, 198, 6, 6),
                                    width: 5,
                                    length: 0.15),
                              ),
                              RangePointer(
                                  value: depo1Sicaklik.toDouble(), //Dikkat
                                  width: 30,
                                  enableAnimation: true,
                                  enableDragging: true,
                                  color: Colors.indigo,)
                            ],
                            showLabels: true,
                            annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                              horizontalAlignment : GaugeAlignment.near,
                              verticalAlignment: GaugeAlignment.near,

                                widget: Text(
                                  "$depo1Sicaklik °C",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 20),
                                      
                                ),
                                angle: 140,
                                positionFactor: 0.2)
                          ],
                            ),
                            
                      ],
                      
                    )),




                    const SizedBox(
                      width: 10,
                      height: 40,
                    ),




                    Flexible(
                        child: SfRadialGauge(
                          title: GaugeTitle(text: "Depo 2 Sıcaklık",backgroundColor: Colors.white,borderColor: const Color.fromARGB(255, 67, 14, 226),borderWidth: 4,alignment: GaugeAlignment.center,),
                      backgroundColor: const Color.fromARGB(172, 250, 183, 145),
                      enableLoadingAnimation: true,
                      animationDuration: 200,
                      //backgroundColor: Colors.white,
                      axes: <RadialAxis>[
                        RadialAxis(
                            axisLineStyle: const AxisLineStyle(thickness: 30),
                            showTicks: false,
                            pointers: <GaugePointer>[
                              NeedlePointer(
                                value: depo2Sicaklik.toDouble(),
                                enableAnimation: true,
                                needleStartWidth: 0,
                                needleEndWidth: 5,
                                needleColor: const Color.fromARGB(255, 210, 8, 8),
                                knobStyle: const KnobStyle(
                                    color: Colors.indigo,
                                    borderColor: Color.fromARGB(255, 236, 5, 5),
                                    knobRadius: 0.06,
                                    borderWidth: 0.04),
                                tailStyle: const TailStyle(
                                    color: Color.fromARGB(255, 198, 6, 6),
                                    width: 5,
                                    length: 0.15),
                              ),
                              RangePointer(
                                  value: depo2Sicaklik.toDouble(), //Dikkat
                                  width: 30,
                                  enableAnimation: true,
                                  enableDragging: true,
                                  color: Colors.lightGreenAccent,)
                            ],
                            showLabels: true,
                            annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                              horizontalAlignment : GaugeAlignment.near,
                              verticalAlignment: GaugeAlignment.near,

                                widget: Text(
                                  "$depo2Sicaklik °C",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 20),
                                      
                                ),
                                angle: 140,
                                positionFactor: 0.2)
                          ],
                            ),
                            
                      ],
                      
                    )),
                  ]),
            ),
            
            
          ],
        ),
      ),
    );
  }
}
