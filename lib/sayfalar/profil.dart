import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/profiliduzenle.dart';
import 'package:socialapp/servisler/firebaseservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeServisi.dart';
import 'package:socialapp/widgetlar/gonderiKarti.dart';
import 'package:socialapp/globals.dart' as globals;

class Profil extends StatefulWidget {
  final String profilSahibiId;
  const Profil({Key? key, required this.profilSahibiId}) : super(key: key);

  @override
  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  int _gonderiSayisi = 0;
  int _takipci = 0;
  int _takipEdilen = 0;
  List<Gonderi> _gonderiler = [];

  String? _aktifKullaniciId;
  Kullanici? _profilSahibi;
  bool _takipEdildi = false;
  dynamic _takipciSayisiGetir() async {
    int takipciSayisi =
        await FirestoreServisi().takipciSayisi(widget.profilSahibiId);
    if (mounted) {
      setState(() {
        _takipci = takipciSayisi;
      });
    }
  }

  dynamic _takipEdilenSayisiGetir() async {
    int takipEdilenSayisi =
        await FirestoreServisi().takipEdilenSayisi(widget.profilSahibiId);
    if (mounted) {
      setState(() {
        _takipEdilen = takipEdilenSayisi;
      });
    }
  }

  dynamic _gonderileriGetir() async {
    List<Gonderi> gonderiler =
        await FirestoreServisi().gonderileriGetir(widget.profilSahibiId);
    if (mounted) {
      setState(() {
        _gonderiler = gonderiler;
        _gonderiSayisi = gonderiler.length;
      });
    }
  }

  _takipKontrol() async {
    bool takiVarMi = await FirestoreServisi().takipKontrol(
        profilSahibiId: widget.profilSahibiId,
        aktifKullaniciId: _aktifKullaniciId);
    setState(() {
      _takipEdildi = takiVarMi;
    });
  }

  @override
  void initState() {
    super.initState();
    _takipciSayisiGetir();
    _takipEdilenSayisiGetir();
    _gonderileriGetir();

    _aktifKullaniciId = Provider.of<YetkilendirmeServisi>(
      context,
      listen: false,
    ).aktifKullaniciId;
    _takipKontrol();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "Profil",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey.shade100,
        actions: [
          widget.profilSahibiId == _aktifKullaniciId
              ? IconButton(
                  onPressed: _cikisYap,
                  icon: Icon(Icons.exit_to_app),
                  color: Colors.black,
                )
              : SizedBox(
                  height: 0,
                )
        ],
      ),
      body: FutureBuilder<Kullanici?>(
          future: FirestoreServisi().kullaniciGetir(widget.profilSahibiId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            _profilSahibi = snapshot.data;

            return ListView(
              children: <Widget>[
                _profilDetaylari(snapshot.data),
                _gonderileriGoster(snapshot.data),
              ],
            );
          }),
    );
  }

  Widget _gonderileriGoster(Kullanici? profilData) {
    if (globals.isListe == true) {
      return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemBuilder: (context, index) {
          return GonderiKarti(
            gonderi: _gonderiler[index],
            yayinlayan: profilData,
          );
        },
        itemCount: _gonderiler.length,
      );
    } else {
      List<GridTile> fayanslar = [];
      _gonderiler.forEach((gonderi) {
        fayanslar.add(_fayansOlustur(gonderi));
      });
      return GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 1,
        physics: NeverScrollableScrollPhysics(),
        children: fayanslar,
      );
    }
  }

  GridTile _fayansOlustur(Gonderi gonderi) {
    return GridTile(
        child: Image.network(
      gonderi.gonderiResmiUrl,
      fit: BoxFit.cover,
    ));
  }

// ignore: unused_element
  Widget _profilDetaylari(Kullanici? profilData) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: profilData?.fotoUrl.isNotEmpty ?? true
                    ? NetworkImage(profilData?.fotoUrl ??
                        "https://cdn.pixabay.com/photo/2021/06/04/14/14/cat-6309964_960_720.jpg")
                    : AssetImage("assets/images/hayalet.png") as ImageProvider,
                backgroundColor: Colors.grey.shade300,
                radius: 50,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _sosyalSayac("Gönderiler", _gonderiSayisi),
                    _sosyalSayac("Takipçi", _takipci),
                    _sosyalSayac("Takip Edilen", _takipEdilen),
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            profilData?.kullaniciAdi ?? "zdfb",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            profilData?.hakkinda ?? "asdfgh",
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
          SizedBox(
            height: 5,
          ),
          widget.profilSahibiId == _aktifKullaniciId
              ? _profiliduzenleButon()
              : _takipButonu(),
          Center(child: _gorunumButonlari()),
        ],
      ),
    );
  }

  Widget _takipButonu() {
    return _takipEdildi ? _takiptenCikButonu() : _takipEtButonu();
  }

  Widget _takipEtButonu() {
    return Container(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          FirestoreServisi().takipEt(
              profilSahibiId: widget.profilSahibiId,
              aktifKullaniciId: _aktifKullaniciId);
          setState(() {
            _takipEdildi = true;
            _takipci = _takipci + 1;
          });
        },
        child: Text(
          "Takip Et",
          style: TextStyle(color: Colors.white),
        ),
        style: TextButton.styleFrom(
          primary: Colors.white,
          backgroundColor: Colors.blue,
          onSurface: Colors.grey,
        ),
      ),
    );
  }

  Widget _takiptenCikButonu() {
    return Container(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        child: TextButton(
          onPressed: () {
            FirestoreServisi().takiptenCik(
                profilSahibiId: widget.profilSahibiId,
                aktifKullaniciId: _aktifKullaniciId);
            setState(() {
              _takipEdildi = false;
              _takipci = _takipci - 1;
            });
          },
          child: Text(
            "Takipten Çık",
            style: TextStyle(color: Colors.black),
          ),
          style: TextButton.styleFrom(
            primary: Colors.white,
            backgroundColor: Colors.white,
            onSurface: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _profiliduzenleButon() {
    return Container(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfiliDuzenle(
                        profil: _profilSahibi,
                      )));
        },
        child: Text(
          "Profili Düzenle",
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _gorunumButonlari() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
        ),
        IconButton(
          onPressed: () {
            globals.isListe = false;
          },
          icon: Icon(Icons.photo),
          iconSize: 30,
        ),
        SizedBox(
          width: 40,
        ),
        IconButton(
          onPressed: () {
            globals.isListe = true;
          },
          icon: Icon(Icons.list),
          iconSize: 30,
        ),
      ],
    );
  }

  Widget _sosyalSayac(String baslik, int sayi) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          sayi.toString(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          baslik,
          style: TextStyle(fontSize: 15),
        ),
      ],
    );
  }

  void _cikisYap() {
    Provider.of<YetkilendirmeServisi>(context, listen: false).cikisYap();
  }
}
