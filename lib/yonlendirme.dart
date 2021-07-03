import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:provider/provider.dart';
// ignore: unused_import
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/anasayfa.dart';
import 'package:socialapp/sayfalar/girisSayfasi.dart';
import 'package:socialapp/servisler/yetkilendirmeServisi.dart';

class Yonlendirme extends StatelessWidget {
  const Yonlendirme({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    return StreamBuilder(
        stream: _yetkilendirmeServisi.durumTakipcisi,
        builder: (BuildContext context, AsyncSnapshot<Kullanici> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            // ignore: unused_local_variable
            Kullanici? aktifKullanici = snapshot.data;
            _yetkilendirmeServisi.aktifKullaniciId = aktifKullanici!.id;
            return Anasayfa();
          }
          return GirisSayfasi();
        });
  }
}
