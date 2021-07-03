import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/servisler/firebaseservisi.dart';
import 'package:socialapp/servisler/storageServisi.dart';
import 'package:socialapp/servisler/yetkilendirmeServisi.dart';

class ProfiliDuzenle extends StatefulWidget {
  final Kullanici? profil;
  const ProfiliDuzenle({Key? key, required this.profil}) : super(key: key);

  @override
  _ProfiliDuzenleState createState() => _ProfiliDuzenleState();
}

class _ProfiliDuzenleState extends State<ProfiliDuzenle> {
  var _formKey = GlobalKey<FormState>();
  String? _kullaniciAdi;
  String? _hakkinda;
  File? _secilmisFoto;
  bool _yukleniyor = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: Text(
          "Profili Düzenle",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
              color: Colors.black,
            ),
            onPressed: _kaydet,
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          _yukleniyor
              ? LinearProgressIndicator()
              : SizedBox(
                  height: 0.0,
                ),
          _profilFoto(),
          _kullaniciBilgileri()
        ],
      ),
    );
  }

  _kaydet() async {
    if (_formKey.currentState?.validate() ?? true) {
      setState(() {
        _yukleniyor = true;
      });

      _formKey.currentState?.save();

      String profilFotoUrl;
      if (_secilmisFoto == null) {
        profilFotoUrl = "";
      } else {
        profilFotoUrl =
            await StorageServisi().gonderiResmiYukle(_secilmisFoto as File);
      }

      String aktifKullaniciId =
          Provider.of<YetkilendirmeServisi>(context, listen: false)
              .aktifKullaniciId;

      FirestoreServisi().kullaniciGuncelle(
          aktifKullaniciId, _kullaniciAdi, profilFotoUrl, _hakkinda);

      setState(() {
        _yukleniyor = false;
      });

      Navigator.pop(context);
    }
  }

  _profilFoto() {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 20),
      child: Center(
        child: InkWell(
          onTap: _galeridenSec,
          child: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: _secilmisFoto == null
                ? NetworkImage(widget.profil?.fotoUrl ??
                    "https://cdn.pixabay.com/photo/2021/06/04/14/14/cat-6309964_960_720.jpg")
                : FileImage(_secilmisFoto as File) as ImageProvider,
            radius: 55,
          ),
        ),
      ),
    );
  }

  Future _galeridenSec() async {
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      _secilmisFoto = File(image.path);
    });
  }

  _kullaniciBilgileri() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            TextFormField(
              initialValue: widget.profil?.kullaniciAdi,
              decoration: InputDecoration(labelText: "Kullanıcı Adı"),
              validator: (girilenDeger) {
                return girilenDeger!.trim().length <= 3
                    ? "Kullanıcı adı en Az 4 karakter olmalı"
                    : null;
              },
              onSaved: (girilenDeger) {
                _kullaniciAdi = girilenDeger;
              },
            ),
            TextFormField(
              initialValue: widget.profil?.hakkinda,
              decoration: InputDecoration(labelText: "Hakkında"),
              validator: (girilenDeger) {
                return girilenDeger!.trim().length <= 3
                    ? "100 karakterden fazla olmamalı"
                    : null;
              },
              onSaved: (girilenDeger) {
                _hakkinda = girilenDeger;
              },
            ),
          ],
        ),
      ),
    );
  }
}
