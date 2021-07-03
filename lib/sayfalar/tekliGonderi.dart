import 'package:flutter/material.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/servisler/firebaseservisi.dart';
import 'package:socialapp/widgetlar/gonderiKarti.dart';

class TekliGonderi extends StatefulWidget {
  final String gonderiId;
  final String gonderiSahibiId;

  const TekliGonderi(
      {Key? key, required this.gonderiId, required this.gonderiSahibiId})
      : super(key: key);

  @override
  _TekliGonderiState createState() => _TekliGonderiState();
}

class _TekliGonderiState extends State<TekliGonderi> {
  late Gonderi _gonderi;
  Kullanici? _gonderiSahibi;
  late bool _yukleniyor;

  @override
  void initState() {
    super.initState();
    gonderiGetir();
  }

  gonderiGetir() async {
    Gonderi? gonderi = await FirestoreServisi()
        .tekliGonderiGetir(widget.gonderiId, widget.gonderiSahibiId);

    if (gonderi != null) {
      Kullanici? gonderiSahibi =
          await FirestoreServisi().kullaniciGetir(widget.gonderiSahibiId);
      setState(() {
        _gonderi = gonderi;
        _gonderiSahibi = gonderiSahibi;
        _yukleniyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.shade100,
          title: Text(
            "Gönderi",
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: !_yukleniyor
            ? GonderiKarti(
                gonderi: _gonderi,
                yayinlayan: _gonderiSahibi,
              )
            : Center(child: CircularProgressIndicator()));
  }
}
