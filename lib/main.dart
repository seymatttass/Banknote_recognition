import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_tts/flutter_tts.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banknot Tespiti',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
      home: LoginPage(
        onThemeChange: () {
          setState(() {
            _isDarkMode = !_isDarkMode;
          });
        },
        isDarkMode: _isDarkMode,
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  final VoidCallback onThemeChange;
  final bool isDarkMode;

  LoginPage({required this.onThemeChange, required this.isDarkMode});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _announceCards();
  }

  Future<void> _announceCards() async {
    List<String> cardDescriptions = [
      'Banknot Tespiti butonuna tıkladınız, geri gitmek için sol üste tıklayınız.',
      'Madeni Para Tespiti butonuna tıkladınız, geri gitmek için sol üste tıklayınız.',
      'Sahte para tespiti butonuna tıkladınız, geri gitmek için sol üste tıklayınız.',
      'Gıda Etiketleri butonuna tıkladınız, geri gitmek için sol üste tıklayınız.'
    ];

    for (String description in cardDescriptions) {
      await _flutterTts.setLanguage("tr-TR");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(1.5);
      await _flutterTts.speak(description);
      await Future.delayed(Duration(seconds: 2));
    }
  }

  Future<void> _announceCard(String description) async {
    await _flutterTts.setLanguage("tr-TR");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(1.5);
    await _flutterTts.speak(description);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Engelsiz Finans',
          style: TextStyle(color: Colors.white), // Başlık metni beyaz yapıldı
        ),
        backgroundColor: Colors.orangeAccent,
      ),
      backgroundColor: widget.isDarkMode ? Colors.black : Colors.orange[50],
      body: GridView.builder(
        padding: EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.0,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () async {
              switch (index) {
                case 0:
                  await _announceCard('Banknot Tespiti butonuna tıkladınız, geri gitmek için sol üste tıklayınız. Banknot tespiti yapmak için ekranın orta üst kısmına tıklayıp kameradan resim çekebilirsiniz.');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ImageCapturePage()),
                  );
                  break;
                case 1:
                  await _announceCard('Madeni Para Tespiti butonuna tıkladınız, geri gitmek için sol üste tıklayınız.');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OtherPage1()),
                  );
                  break;
                case 2:
                  await _announceCard('Sahte para tespiti butonuna tıkladınız, geri gitmek için sol üste tıklayınız.');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OtherPage2()),
                  );
                  break;
                case 3:
                  await _announceCard('Gıda Etiketleri butonuna tıkladınız, geri gitmek için sol üste tıklayınız.');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OtherPage3()),
                  );
                  break;
              }
            },
            child: Card(
              elevation: 5,
              child: Container(
                color: Colors.orange[200], // Açık turuncu renk
                child: Center(
                  child: Text(
                    _getCardText(index),
                    style: TextStyle(color: Colors.white, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onThemeChange,
        child: Icon(widget.isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
        backgroundColor: Colors.orangeAccent,
      ),
    );
  }

  String _getCardText(int index) {
    switch (index) {
      case 0:
        return 'Banknot Tespiti';
      case 1:
        return 'Madeni Para Tespiti';
      case 2:
        return 'Sahte Para Tespiti';
      case 3:
        return 'Gıda Etiketleri';
      default:
        return '';
    }
  }
}

class ImageCapturePage extends StatefulWidget {
  @override
  _ImageCapturePageState createState() => _ImageCapturePageState();
}

class _ImageCapturePageState extends State<ImageCapturePage> {
  dynamic _image;
  final picker = ImagePicker();
  String _prediction = '';
  double _confidence = 0.0;
  late FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
  }

  Future<void> getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        if (kIsWeb) {
          _image = pickedFile;
        } else {
          _image = io.File(pickedFile.path);
        }
        _prediction = '';
      } else {
        print('No image selected.');
      }
    });

    if (_image != null) {
      await classifyImage(_image);
    }
  }

  Future<void> classifyImage(dynamic image) async {
    await uploadImage(image);
  }

  Future<void> uploadImage(dynamic image) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.10:5000/predict'),
    );

    if (kIsWeb) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          await image.readAsBytes(),
          filename: 'image.jpg',
        ),
      );
    } else {
      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );
    }

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decodedData = json.decode(responseData);
        setState(() {
          _prediction = decodedData['prediction'];
          _confidence = decodedData['confidence'];
        });
        _speakPrediction();
      } else {
        print('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error in uploadImage: $e');
    }
  }

  void _speakPrediction() async {
    if (_prediction.isNotEmpty) {
      String textToSpeak = 'Tahmin: $_prediction, Güven: ${(_confidence * 100).toStringAsFixed(2)}%';
      await _flutterTts.setLanguage("tr-TR");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(1.5);

      var result = await _flutterTts.speak(textToSpeak);

      if (result == 1) {
        print("Tahmin sonucu başarıyla seslendirildi.");
      } else {
        print("Tahmin sonucu seslendirilemedi, kod: $result");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Banknot Tespiti'),
        backgroundColor: Colors.orangeAccent,
      ),
      backgroundColor: Colors.orange[50],
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_image == null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Resim seçilmedi.',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                )
              else if (kIsWeb)
                Card(
                  elevation: 5,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(_image.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )
              else
                Card(
                  elevation: 5,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(_image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => getImage(ImageSource.camera),
                icon: Icon(Icons.camera),
                label: Text('Kameradan Çek'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => getImage(ImageSource.gallery),
                icon: Icon(Icons.image),
                label: Text('Galeriden Seç'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                ),
              ),
              SizedBox(height: 20),
              if (_prediction.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Tahmin: $_prediction\nGüven: ${(_confidence * 100).toStringAsFixed(2)}%',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class OtherPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Madeni Para Tespiti'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Center(
        child: Text('Madeni Para Tespiti İçeriği'),
      ),
    );
  }
}

class OtherPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sahte Para Tespiti'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Center(
        child: Text('Sahte Para Tespiti İçeriği'),
      ),
    );
  }
}

class OtherPage3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gıda Etiketleri'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Center(
        child: Text('Gıda Etiketleri İçeriği'),
      ),
    );
  }
}
