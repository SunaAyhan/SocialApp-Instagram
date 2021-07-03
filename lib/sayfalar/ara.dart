import 'package:flutter/material.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/profil.dart';
import 'package:socialapp/servisler/firebaseservisi.dart';

class Ara extends StatefulWidget {
  const Ara({Key? key}) : super(key: key);

  @override
  _AraState createState() => _AraState();
}

class _AraState extends State<Ara> {
  TextEditingController _aramaController = TextEditingController();
  Future<List<Kullanici>>? _aramaSonucu;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarOlustur(),
      body: _aramaSonucu != null ? sonuclariGetir() : aramaYok(),
    );
  }

  AppBar _appBarOlustur() {
    return AppBar(
      titleSpacing: 0,
      backgroundColor: Colors.grey.shade100,
      title: TextFormField(
        onFieldSubmitted: (girilenDeger) {
          setState(() {
            _aramaSonucu = FirestoreServisi().kullaniciAra(girilenDeger);
          });
        },
        controller: _aramaController,
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.search,
              size: 30,
            ),
            suffix: IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.black,
              ),
              onPressed: () {
                _aramaController.clear();
                setState(() {
                  _aramaSonucu = null;
                });
              },
            ),
            border: InputBorder.none,
            fillColor: Colors.white,
            filled: true,
            contentPadding: EdgeInsets.only(bottom: 4),
            hintText: "Kullanıcı Ara..."),
      ),
    );
  }

  aramaYok() {
    return Center(child: Text("Kullanıcı Ara: "));
  }

  sonuclariGetir() {
    return FutureBuilder<List<Kullanici>>(
      future: _aramaSonucu,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data.length == 0) {
          return Center(child: Text("Bu arama için sonuç bulunamadı"));
        }
        return ListView.builder(
          itemBuilder: (context, index) {
            Kullanici kullanici = snapshot.data[index];
            return kullaniciSatiri(kullanici);
          },
          itemCount: snapshot.data.length,
        );
      },
    );
  }

  kullaniciSatiri(Kullanici kullanici) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (contex) => Profil(
                      profilSahibiId: kullanici.id,
                    )));
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(kullanici.fotoUrl),
        ),
        title: Text(
          kullanici.kullaniciAdi,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
