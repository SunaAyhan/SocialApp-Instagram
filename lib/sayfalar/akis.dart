import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/servisler/firebaseservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeServisi.dart';
import 'package:socialapp/widgetlar/gonderiKarti.dart';
import 'package:socialapp/widgetlar/silinmeyenFutureBuilder.dart';

class Akis extends StatefulWidget {
  const Akis({Key? key}) : super(key: key);

  @override
  _AkisState createState() => _AkisState();
}

class _AkisState extends State<Akis> {
  List<Gonderi> _gonderiler = [];
  _akisGonderileriniGetir() async {
    String aktifKullaniciId = Provider.of<YetkilendirmeServisi>(
      context,
      listen: false,
    ).aktifKullaniciId;
    List<Gonderi> gonderiler =
        await FirestoreServisi().akisGonderileriniGetir(aktifKullaniciId);
    if (mounted) {
      setState(() {
        _gonderiler = gonderiler;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _akisGonderileriniGetir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Best Social App"),
        centerTitle: true,
      ),
      body: ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: _gonderiler.length,
        itemBuilder: (context, index) {
          Gonderi gonderi = _gonderiler[index];
          return SilinmeyenFutureBuilder(
            builder: (context, snapshot) {
              Kullanici? gonderiSahibi = snapshot.data;
              return GonderiKarti(gonderi: gonderi, yayinlayan: gonderiSahibi);
            },
            future: FirestoreServisi().kullaniciGetir(gonderi.yayinlayanId),
          );
        },
      ),
    );
  }
}
