import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import "widgets/gaugeBarWidget.dart";
import 'ekranlar/veri_ekrani.dart';
import 'ekranlar/degerler_ekrani.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
runApp(const Uygulamam());
}

class Uygulamam extends StatelessWidget {
  const Uygulamam({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IOT Uygulamam',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor:  Colors.blueAccent),
      ),
      home: const MyHomePage(title: 'IOT'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _akimDatabase = 0;
  int _voltajDatabase = 0;
  int _sicaklikDatabase = 0;
  int _depo1Sicaklik = 0;
  int _depo2Sicaklik = 0;
  int _selectedIndex = 0; // Hangi ekranın seçili olduğunu tutar
  bool _sistemAktif = false; // Sistemin açık/kapalı durumunu tutar



  // Firebase dinleyicilerini tutmak için StreamSubscription nesneleri
  late StreamSubscription<DatabaseEvent> _akimSubscription;
  late StreamSubscription<DatabaseEvent> _voltajSubscription;
  late StreamSubscription<DatabaseEvent> _sicaklikSubscription;
  late StreamSubscription<DatabaseEvent> _depo1SicaklikSubscription;
  late StreamSubscription<DatabaseEvent> _depo2SicaklikSubscription;
  late StreamSubscription<DatabaseEvent> _sistemAktifSubscription;

  
  

  // Firebase'e boolean veri yazmak için fonksiyon
  Future<void> _setKontrolVerisi(String key, dynamic value) async {
    try {
      DatabaseReference kontrolRef = FirebaseDatabase.instance.ref("Kontrol/$key");
      await kontrolRef.set(value);
      print("Firebase'e yazıldı: Kontrol/$key -> $value");
      // Kullanıcıya geri bildirim göstermek için
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"$key" durumu güncellendi: $value')),
      );
    } catch (e) {
      print("Firebase'e yazma hatası: $e");
    }
  }

  void _veriOku()
  {
    DatabaseReference akimDatabaseRef = FirebaseDatabase.instance.ref("Olcum/Akim");
    DatabaseReference voltajDatabaseRef = FirebaseDatabase.instance.ref("Olcum/Voltaj");
    DatabaseReference sicaklikDatabaseRef = FirebaseDatabase.instance.ref("Olcum/Sicaklik");
    DatabaseReference depo1SicaklikRef = FirebaseDatabase.instance.ref("Olcum/Depo1Sicaklik");
    DatabaseReference depo2SicaklikRef = FirebaseDatabase.instance.ref("Olcum/Depo2Sicaklik");
    DatabaseReference sistemAktifRef = FirebaseDatabase.instance.ref("Kontrol/SistemAktif");
    
    
    _akimSubscription=akimDatabaseRef.onValue.listen((event) {
      final data = event.snapshot.value;
      print("Akım Gelen Veri: $data");

      if (mounted) { // Widget'ın hala ağaçta olduğundan emin ol
        setState(() {
          _akimDatabase = int.tryParse(data.toString()) ?? 0;
        });
      }

    });


    _voltajSubscription=voltajDatabaseRef.onValue.listen((event) {
      final data = event.snapshot.value;
      print("Voltaj Gelen Veri: $data");
        if (mounted) {
        setState(() {
          _voltajDatabase = int.tryParse(data.toString()) ?? 0;
        });
      }
      
    });
    

    _sicaklikSubscription=sicaklikDatabaseRef.onValue.listen((event) {
      final data = event.snapshot.value;
      print("sıcaklık Gelen Veri: $data");
         if (mounted) {
        setState(() {
          _sicaklikDatabase = int.tryParse(data.toString()) ?? 0;
        });
      }
    
    
    });

    _depo1SicaklikSubscription=depo1SicaklikRef.onValue.listen((event) {
      final data = event.snapshot.value;
      print("sıcaklık Gelen Veri: $data");
         if (mounted) {
        setState(() {
          _depo1Sicaklik = int.tryParse(data.toString()) ?? 0;
        });
      }
    
    
    });

    _depo2SicaklikSubscription = depo2SicaklikRef.onValue.listen((event) {
      final data = event.snapshot.value;
      print("Sistem Aktif Gelen Veri: $data");

      if (mounted) {
        setState(() {
          _depo2Sicaklik = int.tryParse(data.toString()) ?? 0;
        });
      }
    });



  }

   
  @override
  void initState() {
    super.initState();
    // Widget oluşturulduğunda verileri okumaya başla
    _veriOku();
  }

  @override
  void dispose() {
    // Widget yok edildiğinde dinleyicileri iptal et
    _akimSubscription.cancel();
    _voltajSubscription.cancel();
    _sicaklikSubscription.cancel();
    _sistemAktifSubscription.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // Farklı ekranları tutan liste
    final List<Widget> widgetOptions = <Widget>[
      VeriEkrani(
        depo1Sicaklik: _depo1Sicaklik,
        depo2Sicaklik: _depo2Sicaklik,
        akimDatabase: _akimDatabase,
        voltajDatabase: _voltajDatabase,
        sicaklikDatabase: _sicaklikDatabase,
        setKontrolVerisi: _setKontrolVerisi,
      ),
      DegerleriAyarlaEkrani(
        sistemAktif: _sistemAktif,
        setKontrolVerisi: _setKontrolVerisi,
      ), // Yeni oluşturduğumuz diğer ekran
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,//Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text('Menü', style: TextStyle(color: Colors.white, fontSize: 30)),
            ),
            ListTile(
              leading: const Icon(Icons.data_thresholding_outlined),
              title: const Text('Veri Analiz'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context); // Drawer'ı kapat
              },
            ),
            ListTile(
              leading: const Icon(Icons.pending_actions_sharp),
              title: const Text('Sıcaklık Ayarlamaları'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.pop(context); // Drawer'ı kapat
              },
            ),
          ],
        ),
      ),
      body: widgetOptions.elementAt(_selectedIndex),
    );
  }
}
