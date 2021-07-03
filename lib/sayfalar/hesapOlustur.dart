import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/servisler/firebaseservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeServisi.dart';

class HesapOlustur extends StatefulWidget {
  const HesapOlustur({Key? key}) : super(key: key);

  @override
  _HesapOlusturState createState() => _HesapOlusturState();
}

class _HesapOlusturState extends State<HesapOlustur> {
  bool yukleniyor = false;
  final _formAnahtari = GlobalKey<FormState>();
  late String kullaniciAdi, email, sifre;
  final _scaffoldAnahtari = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldAnahtari,
      appBar: AppBar(
        title: Text("Hesap Oluştur"),
      ),
      body: ListView(
        children: [
          yukleniyor
              ? LinearProgressIndicator()
              : SizedBox(
                  height: 0,
                ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
                key: _formAnahtari,
                child: Column(
                  children: [
                    TextFormField(
                      validator: (girilenDeger) {
                        if (girilenDeger!.isEmpty) {
                          return "Kullanıcı adı boş bırakılamaz";
                        } else if (girilenDeger.trim().length <= 4 ||
                            girilenDeger.trim().length > 10) {
                          return "Kullanıcı adı çok kısa veya çok uzun";
                        }
                        return null;
                      },
                      onSaved: (girilenDeger) => kullaniciAdi = girilenDeger!,
                      autocorrect: true,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Kullanıcı Adı: ",
                        hintText: "Kullanıcı Adınızı Girin",
                        errorStyle: TextStyle(fontSize: 16),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
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
                      decoration: InputDecoration(
                        labelText: "E-mail: ",
                        hintText: "Mail adresinizi Adınızı Girin",
                        errorStyle: TextStyle(fontSize: 16),
                        prefixIcon: Icon(Icons.mail),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                        obscureText: true,
                        autocorrect: true,
                        decoration: InputDecoration(
                          labelText: "Şifre: ",
                          hintText: "Şifrenizi adresinizi Adınızı Girin",
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
                      height: 50,
                    ),
                    Container(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _kullaniciOlustur,
                        child: Text(
                          "Hesap Oluştur",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              color: Colors.white),
                        ),
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Theme.of(context).primaryColor,
                          onSurface: Colors.red,
                        ),
                      ),
                    ),
                  ],
                )),
          )
        ],
      ),
    );
  }

  void _kullaniciOlustur() async {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    var _formstate = _formAnahtari.currentState!;
    if (_formstate.validate()) {
      _formstate.save();
      setState(() {
        yukleniyor = true;
      });
      try {
        Kullanici kullanici =
            await _yetkilendirmeServisi.mailIleKayit(email, sifre);
        // ignore: unnecessary_null_comparison
        if (kullanici != null) {
          FirestoreServisi().kullaniciOlustur(
              id: kullanici.id, email: email, kullaniciAdi: kullaniciAdi);
        }
        Navigator.pop(context);
      } catch (hata) {
        setState(() {
          yukleniyor = false;
        });
        uyariGoster(hataKodu: hata);
      }
    }
  }

  uyariGoster({hataKodu}) {
    var snackBar = ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Girdiğiniz email geçersizdir"),
        action: SnackBarAction(label: 'Action', onPressed: () {})));
    var snackBar2 = ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Girdiğiniz email kayıtlıdır"),
        action: SnackBarAction(label: 'Action', onPressed: () {})));
    // ignore: unused_local_variable
    String hataMesaji;
    if (hataKodu == "ERROR_INVALID_EMAIL") {
      return snackBar;
    } else if (hataKodu == "ERROR_EMAIL_ALREADY_IN_USE") {
      return snackBar2;
    }
  }
}
