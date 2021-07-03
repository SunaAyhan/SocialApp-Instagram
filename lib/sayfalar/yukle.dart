import 'dart:io';

import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/servisler/firebaseservisi.dart';
import 'package:socialapp/servisler/storageServisi.dart';
import 'package:socialapp/servisler/yetkilendirmeServisi.dart';

class Yukle extends StatefulWidget {
  @override
  _YukleState createState() => _YukleState();
}

class _YukleState extends State<Yukle> {
  File? dosya;
  bool yukleniyor = false;
  TextEditingController aciklamaTextKumandasi = TextEditingController();
  TextEditingController konumTextKumandasi = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return dosya == null ? yukleButonu() : gonderiFormu();
  }

  Widget yukleButonu() {
    return IconButton(
        onPressed: () {
          fotografSec();
        },
        icon: Icon(
          Icons.file_upload,
          size: 50,
        ));
  }

  Widget gonderiFormu() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: Text(
          "Gönderi Oluştur",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            setState(() {
              dosya = null;
            });
          },
        ),
        actions: [
          IconButton(
              onPressed: _gonderiOlustur,
              icon: Icon(
                Icons.send,
                color: Colors.black,
              ))
        ],
      ),
      body: ListView(
        children: [
          yukleniyor
              ? LinearProgressIndicator()
              : SizedBox(
                  height: 0,
                ),
          AspectRatio(
            child: Image.file(
              dosya!,
              fit: BoxFit.cover,
            ),
            aspectRatio: 16.0 / 9.0,
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            controller: aciklamaTextKumandasi,
            decoration: InputDecoration(
                hintText: "Açıklama Ekle",
                contentPadding: EdgeInsets.only(left: 15, right: 15)),
          ),
          TextFormField(
            controller: konumTextKumandasi,
            decoration: InputDecoration(
                hintText: "Konum",
                contentPadding: EdgeInsets.only(left: 15, right: 15)),
          ),
        ],
      ),
    );
  }

  void _gonderiOlustur() async {
    if (yukleniyor == false) {
      setState(() {
        yukleniyor = true;
      });
      String? resimUrl = await StorageServisi().gonderiResmiYukle(dosya!);
      String? aktifKullaniciId =
          Provider.of<YetkilendirmeServisi>(context, listen: false)
              .aktifKullaniciId;
      await FirestoreServisi().gonderiOlustur(
        gonderiResimUrl: resimUrl,
        aciklama: aciklamaTextKumandasi.text,
        yayinlayanId: aktifKullaniciId,
        konum: konumTextKumandasi.text,
      );
      setState(() {
        yukleniyor = false;
        aciklamaTextKumandasi.clear();
        konumTextKumandasi.clear();
        dosya = null;
      });
    } else {}
  }

  fotografSec() {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Gönderi Oluştur"),
          children: [
            SimpleDialogOption(
              child: Text("Fotoğraf Çek"),
              onPressed: () {
                fotoCek();
              },
            ),
            SimpleDialogOption(
              child: Text("Galeriden Yükle"),
              onPressed: () {
                galeridenSec();
              },
            ),
            SimpleDialogOption(
              child: Text("İptal"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  Future fotoCek() async {
    Navigator.pop(context);
    var image = await ImagePicker().getImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      dosya = File(image.path);
    });
  }

  Future galeridenSec() async {
    Navigator.pop(context);
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      dosya = File(image.path);
    });
  }
}
