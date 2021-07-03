import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/servisler/yetkilendirmeServisi.dart';

class SifremiUnuttum extends StatefulWidget {
  const SifremiUnuttum({Key? key}) : super(key: key);

  @override
  _SifremiUnuttumState createState() => _SifremiUnuttumState();
}

class _SifremiUnuttumState extends State<SifremiUnuttum> {
  bool yukleniyor = false;
  final _formAnahtari = GlobalKey<FormState>();
  late String email;
  final _scaffoldAnahtari = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldAnahtari,
      appBar: AppBar(
        title: Text("Şifremi Sıfırla"),
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
                      height: 50,
                    ),
                    Container(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _sifreyiSifirla,
                        child: Text(
                          "Şifremi Sıfırla",
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

  void _sifreyiSifirla() async {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    var _formstate = _formAnahtari.currentState!;
    if (_formstate.validate()) {
      _formstate.save();
      setState(() {
        yukleniyor = true;
      });
      try {
        await YetkilendirmeServisi().sifremiSifirla(email);
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

    // ignore: unused_local_variable
    String hataMesaji;
    if (hataKodu == "ERROR_INVALID_EMAIL") {
      return snackBar;
    }
  }
}
