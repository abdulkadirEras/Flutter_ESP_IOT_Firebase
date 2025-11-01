

import 'package:flutter/material.dart';
import 'dart:math' as math;


class GaugePainter extends CustomPainter {
  final double progress; // 0.0 ile 1.0 arasındaki güncel ilerleme
  final Color baseColor;
  final Color progressColor;
  final double strokeWidth;
  final double startAngle;

  GaugePainter({
    required this.progress,
    required this.baseColor,
    required this.progressColor,
    required this.strokeWidth,
    this.startAngle = math.pi * 0.75, // Başlangıç açısı (135 derece)
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Yarıçapı hesaplarken stroke kalınlığını dahil ediyoruz
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;
    // Toplam çizim açısı (270 derece)
    final totalAngle = math.pi * 1.5;

    // A. Arka Plan Arkı (Circle Track)
    final trackPaint = Paint()
      ..color = baseColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalAngle,
      false,
      trackPaint,
    );

    // B. İlerleme Arkı (Progress Arc)
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressAngle = totalAngle * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressAngle,
      false,
      progressPaint,
    );
    
    // C. İlerleme Ucundaki Nokta (Opsiyonel)
    if (progressAngle > 0) {
      final dotRadius = strokeWidth / 4;
      final endAngle = startAngle + progressAngle;
      final dotX = center.dx + radius * math.cos(endAngle);
      final dotY = center.dy + radius * math.sin(endAngle);

      final dotPaint = Paint()..color = progressColor;
      canvas.drawCircle(Offset(dotX, dotY), dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) {
    // Yalnızca ilerleme değeri değişirse yeniden çizim yap
    return oldDelegate.progress != progress;
  }
}

class AnimatedCircularGauge extends StatefulWidget {
  final double guncelDegeri; // Güncel değer (Örn: 22)
  final double maxDeger; // Maksimum değer (Örn: 40)
  final Color gaugeRengi;
  final Color gaugeAltRenk;
  final TextStyle yaziStili;
  final double konturGenisligi;
  final double widgetBoyutu; // Widget'ın genel boyutu
  final int birimSecimi;


  const AnimatedCircularGauge({
    super.key,
    required this.guncelDegeri,
    this.maxDeger = 100.0,
    this.gaugeRengi = const Color(0xFF6C3483),
    this.gaugeAltRenk = const Color.fromARGB(255, 10, 154, 238),
    this.yaziStili = const TextStyle(
      color: Colors.black,
      fontSize: 48,
      fontWeight: FontWeight.bold,
    ),
    this.konturGenisligi = 20.0,
    this.widgetBoyutu = 200.0,
    this.birimSecimi=0,
  });

  @override
  State<AnimatedCircularGauge> createState() => _AnimatedCircularGaugeState();
}

class _AnimatedCircularGaugeState extends State<AnimatedCircularGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    
    // Animasyonu ilk değeri ile başlat
    _updateAnimation(widget.guncelDegeri);
  }

  // Widget parametreleri değiştiğinde animasyonu güncelle
  @override
  void didUpdateWidget(covariant AnimatedCircularGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.guncelDegeri != widget.guncelDegeri) {
      _oldValue = oldWidget.guncelDegeri;
      _updateAnimation(widget.guncelDegeri);
    }
  }

  void _updateAnimation(double newValue) {
    // Animasyonun başlayacağı ve biteceği değerleri (0.0 - 1.0 arası oran) hesapla
    final beginProgress = _oldValue / widget.maxDeger;
    final endProgress = newValue / widget.maxDeger;

    _animation = Tween<double>(begin: beginProgress, end: endProgress).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic, // Yumuşak geçiş eğrisi
      ),
    );

    _controller
      ..reset() // Animasyonu sıfırla
      ..forward(); // Animasyonu başlat
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ortadaki beyaz dairenin boyutu
    final innerCircleSize = widget.widgetBoyutu - widget.konturGenisligi * 2;

    return SizedBox(
      width: widget.widgetBoyutu,
      height: widget.widgetBoyutu,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Animasyon sırasında güncel değeri hesapla (0.0 - 1.0 arası)
          final animatedProgress = _animation.value;
          
          // Metin olarak gösterilecek değeri hesapla (progress'ten sıcaklığa çevir)
          final animatedTemp = (animatedProgress * widget.maxDeger).round();
          String birim="";
          if(widget.birimSecimi==0){
            birim="°C";
          }
          
          else if(widget.birimSecimi==1){
            birim="V";
          }
          
          else if(widget.birimSecimi==2){
            birim="A";
          }
          else if(widget.birimSecimi==3){
            birim="W";
          }
          

          return Stack(
            alignment: Alignment.center,
            children: [
              // 1. İlerleme Göstergesi (CustomPaint)
              CustomPaint(
                size: Size(widget.widgetBoyutu, widget.widgetBoyutu),
                painter: GaugePainter(
                  progress: animatedProgress,
                  baseColor: widget.gaugeAltRenk,
                  progressColor: widget.gaugeRengi,
                  strokeWidth: widget.konturGenisligi,
                ),
              ),

              // 2. Ortadaki Beyaz Daire
              Container(
                width: innerCircleSize,
                height: innerCircleSize,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),

              // 3. Metin
              Text(
                '$animatedTemp$birim',
                style: widget.yaziStili,
              ),
            ],
          );
        },
      ),
    );
  }
}



class TemperatureGaugePainter extends CustomPainter {
  final double value; // 0.0 ile 1.0 arasında ilerleme değeri
  final Color baseColor;
  final Color progressColor;
  final double strokeWidth;

  TemperatureGaugePainter({
    required this.value,
    required this.baseColor,
    required this.progressColor,
    this.strokeWidth = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Merkezi ve yarıçapı hesapla
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth;

    // A. Arka Plan Arkı (Circle Track) Çizimi
    final trackPaint = Paint()
      ..color = baseColor.withOpacity(0.5) // Soluk Mor (resimdeki gibi)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // Yuvarlak uç

    // Tam daireye yakın bir yay çiz (Başlangıç ve bitiş açısı ayarlanabilir)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75, // Başlangıç açısı (yaklaşık 135 derece)
      math.pi * 1.5,  // Toplam açı (270 derece)
      false,
      trackPaint,
    );

    // B. İlerleme Arkı (Progress Arc) Çizimi
    final progressPaint = Paint()
      ..color = progressColor // Koyu Mor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // İlerleme miktarını hesapla
    final progressAngle = math.pi * 1.5 * value; // Toplam açının 'value' kadarı

    // İlerleme arkını çiz
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75, // Başlangıç açısı aynı olmalı
      progressAngle,
      false,
      progressPaint,
    );

    // C. İlerleme Ucundaki Noktayı Çizme (Opsiyonel)
    if (progressAngle > 0) {
      final dotRadius = strokeWidth / 4;
      // Yay üzerindeki son noktanın koordinatlarını hesapla (Trigonometri)
      final endAngle = math.pi * 0.75 + progressAngle;
      final dotX = center.dx + radius * math.cos(endAngle);
      final dotY = center.dy + radius * math.sin(endAngle);

      final dotPaint = Paint()..color = progressColor;
      canvas.drawCircle(Offset(dotX, dotY), dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant TemperatureGaugePainter oldDelegate) {
    // Yalnızca değer değiştiyse yeniden çiz
    return oldDelegate.value != value;
  }
}