import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/profil.dart';
import 'package:socialapp/sayfalar/yorumlar.dart';
import 'package:socialapp/servisler/firebaseservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeServisi.dart';

class GonderiKarti extends StatefulWidget {
  final Gonderi gonderi;
  final Kullanici? yayinlayan;
  const GonderiKarti(
      {Key? key, required this.gonderi, required this.yayinlayan})
      : super(key: key);

  @override
  _GonderiKartiState createState() => _GonderiKartiState();
}

class _GonderiKartiState extends State<GonderiKarti> {
  int _begeniSayisi = 0;
  bool _begendin = false;
  late String _aktifKullaniciId;
  @override
  void initState() {
    super.initState();
    _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    _begeniSayisi = widget.gonderi.begeniSayisi;
    begeniVarMi();
  }

  begeniVarMi() async {
    bool begeniVarMi =
        await FirestoreServisi().begeniVarMi(widget.gonderi, _aktifKullaniciId);
    if (begeniVarMi) {
      if (mounted) {
        setState(() {
          _begendin = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          children: [_gonderiBasligi(), _gonderiResmi(), _gonderiAlt()],
        ));
  }

  gonderiSecenekleri() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Seçenekler"),
          children: [
            SimpleDialogOption(
              child: Text("Gonderiyi Sil"),
              onPressed: () {
                FirestoreServisi().gonderiSil(
                    aktifKullaniciId: _aktifKullaniciId,
                    gonderi: widget.gonderi);
                Navigator.pop(context);
              },
            ),
            SimpleDialogOption(
              child: Text(
                "Vazgeç",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  Widget _gonderiBasligi() {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Profil(profilSahibiId: widget.gonderi.yayinlayanId)));
          },
          child: CircleAvatar(
              backgroundColor: Colors.blue,
              backgroundImage: widget.yayinlayan?.fotoUrl.isNotEmpty ?? true
                  ? NetworkImage(widget.yayinlayan?.fotoUrl ??
                      "https://cdn.pixabay.com/photo/2021/06/04/14/14/cat-6309964_960_720.jpg")
                  : AssetImage("assets/images/hayalet.png") as ImageProvider),
        ),
      ),
      title: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Profil(profilSahibiId: widget.gonderi.yayinlayanId)));
        },
        child: Text(
          widget.yayinlayan?.kullaniciAdi ?? "suna",
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
      trailing: _aktifKullaniciId == widget.gonderi.yayinlayanId
          ? IconButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.black,
              ),
              onPressed: () => gonderiSecenekleri(),
            )
          : null,
      contentPadding: EdgeInsets.all(0),
    );
  }

  Widget _gonderiResmi() {
    return GestureDetector(
      onDoubleTap: _begeniDegistir,
      child: Image.network(
        widget.gonderi.gonderiResmiUrl,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _gonderiAlt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          IconButton(
              onPressed: _begeniDegistir,
              icon: !_begendin
                  ? Icon(
                      Icons.favorite_border,
                      size: 35,
                    )
                  : Icon(
                      Icons.favorite,
                      size: 35,
                      color: Colors.red,
                    )),
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Yorumlar(
                              gonderi: widget.gonderi,
                            )));
              },
              icon: Icon(
                Icons.comment,
                size: 35,
              ))
        ]),
        Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              "$_begeniSayisi beğeni",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            )),
        SizedBox(
          height: 2,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: RichText(
              text: TextSpan(
                  text: widget.yayinlayan?.kullaniciAdi,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  children: [
                TextSpan(
                    text: widget.gonderi.aciklama,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.black))
              ])),
        ),
      ],
    );
  }

  void _begeniDegistir() {
    if (_begendin) {
      setState(() {
        _begendin = false;
        _begeniSayisi = _begeniSayisi - 1;
      });
      FirestoreServisi().gonderiBegeniKaldir(widget.gonderi, _aktifKullaniciId);
    } else {
      setState(() {
        _begendin = true;
        _begeniSayisi = _begeniSayisi + 1;
      });
      FirestoreServisi().gonderiBegen(widget.gonderi, _aktifKullaniciId);
    }
  }
}
