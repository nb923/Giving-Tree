import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;
import 'dart:html' as html;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Giving Tree',
      builder: (context, child) {
        final width = MediaQuery.of(context).size.width;
        // If running on web and the screen width is large, constrain to phone size.
        if (kIsWeb && width > 600) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400),
              child: child,
            ),
          );
        }
        return child!;
      },
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green,
          elevation: 4,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double donationCount = 0;

  void _downloadSampleReceipt() async {
    if (kIsWeb) {
      final ByteData bytes = await rootBundle.load('sample-receipt.png');
      final blob = html.Blob([bytes.buffer.asUint8List()]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchorElement = html.AnchorElement(href: url)
        ..download = 'sample_receipt.jpg'
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.nature, size: 30, color: Colors.white),
            SizedBox(width: 10),
            Text('Giving Tree'),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.nature, size: 100, color: Colors.green),
              SizedBox(height: 10),
              Text(
                'Giving Tree',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.green.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Total Donations: \$${donationCount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.green.shade900,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: TextStyle(fontSize: 18),
          ),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UploadReceiptScreen()),
            );
            if (result != null && result is double) {
              setState(() {
                donationCount += result;
              });
            }
          },
          child: Text('Upload Receipt'),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _downloadSampleReceipt,
        label: Text(
          'Click here to download sample receipt',
          style: TextStyle(color: Colors.white),
        ),
        icon: Icon(Icons.download),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class UploadReceiptScreen extends StatefulWidget {
  @override
  _UploadReceiptScreenState createState() => _UploadReceiptScreenState();
}

class _UploadReceiptScreenState extends State<UploadReceiptScreen> {
  XFile? _image;
  bool _processing = false;
  final ImagePicker _picker = ImagePicker();
  String? _resultText;
  final double receiptTotal = 154.06;
  final double roundedUpAmount = 0.94;
  final double totalAmount = 155.00;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
        _processing = true;
        _resultText = null;
      });
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        _processing = false;
        _resultText =
            'Receipt total: \$${receiptTotal.toStringAsFixed(2)}\nRounded up donation: \$${roundedUpAmount.toStringAsFixed(2)}\n';
      });
      await Future.delayed(Duration(seconds: 2));
      Navigator.pop(context, roundedUpAmount);
    }
  }

  Widget _displayImage() {
    if (_image == null) return Container();
    if (kIsWeb) {
      return FutureBuilder<Uint8List>(
        future: _image!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Image.memory(snapshot.data!, height: 300);
          } else {
            return CircularProgressIndicator();
          }
        },
      );
    } else {
      return Image.file(File(_image!.path), height: 300);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.nature, size: 30, color: Colors.white),
            SizedBox(width: 10),
            Text('Upload Receipt'),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.nature, size: 80, color: Colors.green),
              SizedBox(height: 10),
              _displayImage(),
              SizedBox(height: 20),
              if (_processing)
                Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text("Processing receipt...",
                        style: TextStyle(color: Colors.green)),
                  ],
                )
              else if (_resultText != null)
                Text(
                  _resultText!,
                  style: TextStyle(fontSize: 18, color: Colors.green.shade900),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: TextStyle(fontSize: 18),
          ),
          onPressed: _pickImage,
          child: Text('Pick Image'),
        ),
      ),
    );
  }
}
