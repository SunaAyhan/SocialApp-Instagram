import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/modeller/yorum.dart';
import 'package:socialapp/servisler/firebaseservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeServisi.dart';
import 'package:timeago/timeago.dart' as timeago;

class Yorumlar extends StatefulWidget {
  final Gonderi gonderi;

  const Yorumlar({Key? key, required this.gonderi}) : super(key: key);

  @override
  _YorumlarState createState() => _YorumlarState();
}

class _YorumlarState extends State<Yorumlar> {
  TextEditingController _yorumKontrolcusu = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: Text(
          "Yorumlar",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: <Widget>[_yorumlariGoster(), _yorumEkle()],
      ),
    );
  }

  _yorumlariGoster() {
    return Expanded(
        child: StreamBuilder<QuerySnapshot>(
      stream: FirestoreServisi().yorumlariGetir(widget.gonderi.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: snapshot.data!.documents.length,
          itemBuilder: (BuildContext context, int index) {
            Yorum yorum = Yorum.dokumandanUret(snapshot.data!.documents[index]);
            return _yorumSatiri(yorum);
          },
        );
      },
    ));
  }

  _yorumSatiri(Yorum yorum) {
    return FutureBuilder<Kullanici?>(
        future: FirestoreServisi().kullaniciGetir(yorum.yayinlayanId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(height: 0);
          }
          Kullanici? yayinlayan = snapshot.data;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(yayinlayan!.fotoUrl),
            ),
            title: RichText(
                text: TextSpan(
                    text: yayinlayan.kullaniciAdi + " ",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    children: [
                  TextSpan(
                      text: yorum.icerik,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.black))
                ])),
            subtitle: Text(
                timeago.format(yorum.olusturulmaZamani.toDate(), locale: "tr")),
          );
        });
  }

  _yorumEkle() {
    return ListTile(
      title: TextFormField(
        controller: _yorumKontrolcusu,
        decoration: InputDecoration(hintText: "yorumunuzu buraya yazın"),
      ),
      trailing: IconButton(
        icon: Icon(Icons.send),
        onPressed: _yorumGonder,
      ),
    );
  }

  void _yorumGonder() {
    String aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;

    FirestoreServisi()
        .yorumEkle(aktifKullaniciId, widget.gonderi, _yorumKontrolcusu.text);
    _yorumKontrolcusu.clear();
  }
}
