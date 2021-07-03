import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/hesapOlustur.dart';
import 'package:socialapp/sayfalar/sifremiunuttum.dart';
import 'package:socialapp/servisler/firebaseservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeServisi.dart';

class GirisSayfasi extends StatefulWidget {
  const GirisSayfasi({Key? key}) : super(key: key);

  @override
  _GirisSayfasiState createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi> {
  final _formAnahtari = GlobalKey<FormState>();
  final _scaffoldAnahtari = GlobalKey<ScaffoldState>();
  late String email, sifre;
  bool yukleniyor = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldAnahtari,
      body: Stack(
        children: [
          _sayfaElemanlari(),
          _yuklemeAnimasyonlari(),
        ],
      ),
    );
  }

  Widget _yuklemeAnimasyonlari() {
    if (yukleniyor == true) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Center();
    }
  }

  Widget _sayfaElemanlari() {
    return Form(
      key: _formAnahtari,
      child: ListView(
        padding: EdgeInsets.only(left: 30, right: 30, top: 50),
        children: [
          FlutterLogo(
            size: 90,
          ),
          SizedBox(height: 80),
          TextFormField(
            validator: (girilenDeger) {
              if (girilenDeger!.isEmpty) {
                return "E-mail alanı boş bırakılamaz";
              } else if (!girilenDeger.contains("@")) {
                return "Girilen değer e-mail formatında olmalıdır";
              }
              return null;
            },
            onSaved: (girilenDeger) => email = girilenDeger!,
            autocorrect: true,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "E-mail",
              errorStyle: TextStyle(fontSize: 16),
              prefixIcon: Icon(Icons.mail),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          TextFormField(
              obscureText: true,
              autocorrect: true,
              decoration: InputDecoration(
                hintText: "Şifre",
                errorStyle: TextStyle(fontSize: 16),
                prefixIcon: Icon(Icons.lock),
              ),
              validator: (girilenDeger) {
                if (girilenDeger!.isEmpty) {
                  return "Şifre alanı boş bırakılamaz";
                } else if (girilenDeger.trim().length <= 4) {
                  return "Şifre 4 karakterden az olamaz";
                }
                return null;
              },
              onSaved: (girilenDeger) => sifre = girilenDeger!),
          SizedBox(
            height: 40,
          ),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => HesapOlustur()));
                  },
                  child: Text(
                    "Hesap Oluştur",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Theme.of(context).primaryColor,
                    onSurface: Colors.red,
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextButton(
                  onPressed: _girisYap,
                  child: Text(
                    "Giriş Yap",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Theme.of(context).primaryColorDark,
                    onSurface: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Center(child: Text("veya")),
          SizedBox(
            height: 20,
          ),
          Center(
              child: InkWell(
            onTap: _googleIleGiris,
            child: Text(
              "Google ile Giriş Yap",
              style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700),
            ),
          )),
          SizedBox(
            height: 20,
          ),
          Center(
              child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SifremiUnuttum()));
                  },
                  child: Text("Şifremi Unuttum")))
        ],
      ),
    );
  }

  void _girisYap() async {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    if (_formAnahtari.currentState!.validate()) {
      _formAnahtari.currentState!.save();

      setState(() {
        yukleniyor = true;
      });
    } else {
      yukleniyor = false;
    }
    try {
      await _yetkilendirmeServisi.mailIleGiris(email, sifre);
      Navigator.pop(context);
    } catch (hata) {
      setState(() {
        yukleniyor = false;
      });
      uyariGoster(hataKodu: hata);
    }
  }

  void _googleIleGiris() async {
    var _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    setState(() {
      yukleniyor = true;
    });
    try {
      Kullanici? kullanici = await _yetkilendirmeServisi.googleIleGiris();
      // ignore: unnecessary_null_comparison
      if (kullanici != null) {
        Kullanici? firestoreKullanici =
            await FirestoreServisi().kullaniciGetir(kullanici.id);
        // ignore: unnecessary_null_comparison
        if (firestoreKullanici == null) {
          FirestoreServisi().kullaniciOlustur(
              id: kullanici.id,
              email: kullanici.email,
              kullaniciAdi: kullanici.kullaniciAdi,
              fotoUrl: kullanici.fotoUrl);
        }
      }
      Navigator.pop(context);
    } catch (hata) {
      setState(() {
        yukleniyor = false;
      });
      uyariGoster(hataKodu: hata);
    }
  }

  uyariGoster({hataKodu}) {
    var snackBar = ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Girdiğiniz şifre yanlış"),
        action: SnackBarAction(label: 'Action', onPressed: () {})));
    var snackBar2 = ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Böyle bir kullanıcı yok"),
        action: SnackBarAction(label: 'Action', onPressed: () {})));
    var snackBar3 = ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Geçersiz e-posta adresi"),
        action: SnackBarAction(label: 'Action', onPressed: () {})));
    var snackBar4 = ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Çok fazla istek yapıldı"),
        action: SnackBarAction(label: 'Action', onPressed: () {})));
    // ignore: unused_local_variable
    String hataMesaji;
    if (hataKodu == "ERROR_WRONG_PASSWORD") {
      return snackBar;
    } else if (hataKodu == "ERROR_USER_NOT_FOUND") {
      return snackBar2;
    } else if (hataKodu == "ERROR_INVALID_EMAIL") {
      return snackBar3;
    } else if (hataKodu == "ERROR_TOO_MANY_REQUESTS") {
      return snackBar4;
    }
  }
}
