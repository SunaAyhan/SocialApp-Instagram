import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/duyuru.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/profil.dart';
import 'package:socialapp/sayfalar/tekliGonderi.dart';
import 'package:socialapp/servisler/firebaseservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeServisi.dart';
import 'package:timeago/timeago.dart' as timeago;

class Duyurular extends StatefulWidget {
  const Duyurular({Key? key}) : super(key: key);

  @override
  _DuyurularState createState() => _DuyurularState();
}

class _DuyurularState extends State<Duyurular> {
  late List<Duyuru> _duyurular;
  late String _aktifKullaniciId;
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    duyurulariGetir();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  Future<void> duyurulariGetir() async {
    List<Duyuru> duyurular =
        await FirestoreServisi().duyurulariGetir(_aktifKullaniciId);
    if (mounted) {
      setState(() {
        _duyurular = duyurular;
        _yukleniyor = false;
      });
    }
  }

  duyurulariGoster() {
    if (_yukleniyor == true) {
      return Center(child: CircularProgressIndicator());
    }
    if (_duyurular.isEmpty) {
      return Center(child: Text("Bildiriminiz Yok"));
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: RefreshIndicator(
        onRefresh: duyurulariGetir,
        child: ListView.builder(
          itemBuilder: (context, index) {
            Duyuru duyuru = _duyurular[index];
            return duyuruSatiri(duyuru);
          },
          itemCount: _duyurular.length,
        ),
      ),
    );
  }

  duyuruSatiri(Duyuru duyuru) {
    String mesaj = mesajOlustur(duyuru.aktiviteTipi);
    return FutureBuilder(
      future: FirestoreServisi().kullaniciGetir(duyuru.aktiviteYapanId),
      builder: (BuildContext context, AsyncSnapshot<Kullanici?> snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(height: 0);
        }
        Kullanici? aktiviteYapan = snapshot.data;

        return ListTile(
          leading: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Profil(profilSahibiId: duyuru.aktiviteYapanId)));
            },
            child: CircleAvatar(
              backgroundImage: NetworkImage(aktiviteYapan?.fotoUrl ?? ""),
            ),
          ),
          title: RichText(
            text: TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Profil(
                                  profilSahibiId: duyuru.aktiviteYapanId,
                                )));
                  },
                text: "${aktiviteYapan?.kullaniciAdi}",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                      text: duyuru.yorum == null
                          ? " $mesaj"
                          : " $mesaj ${duyuru.yorum}",
                      style: TextStyle(fontWeight: FontWeight.normal))
                ]),
          ),
          subtitle: Text(
              timeago.format(duyuru.olusturulmaZamani.toDate(), locale: "tr")),
          trailing: gonderiGorsel(
              duyuru.aktiviteTipi, duyuru.gonderiFoto, duyuru.gonderiId),
        );
      },
    );
  }

  gonderiGorsel(String aktiviteTipi, String gonderiFoto, String gonderiId) {
    if (aktiviteTipi == "takip") {
      return null;
    } else if (aktiviteTipi == "begeni" || aktiviteTipi == "yorum") {
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TekliGonderi(
                      gonderiId: gonderiId,
                      gonderiSahibiId: _aktifKullaniciId)));
        },
        child: Image.network(
          gonderiFoto,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: Text(
          "Bildirimler",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: duyurulariGoster(),
    );
  }

  mesajOlustur(String aktiviteTipi) {
    if (aktiviteTipi == "begeni") {
      return "gonderini beğendi";
    } else if (aktiviteTipi == "takip") {
      return "seni takip etti";
    } else if (aktiviteTipi == "yorum") {
      return "gonderine yorum yaptı";
    }

    return null;
  }
}
