// ignore: import_of_legacy_library_into_null_safe

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialapp/modeller/duyuru.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/servisler/storageServisi.dart';

class FirestoreServisi {
  final Firestore _firestore = Firestore.instance;
  final DateTime zaman = DateTime.now();

  Future<void> kullaniciOlustur({id, email, kullaniciAdi, fotoUrl = ""}) async {
    await _firestore.collection("kullanicilar").document(id).setData({
      "kullaniciAdi": kullaniciAdi,
      "email": email,
      "fotoUrl": fotoUrl,
      "hakkinda": "",
      "olusturulmaZamani": zaman
    });
  }

  // ignore: unused_element
  Future<Kullanici?> kullaniciGetir(id) async {
    DocumentSnapshot doc =
        await _firestore.collection("kullanicilar").document(id).get();
    if (doc.exists) {
      Kullanici kullanici = Kullanici.dokumandanUret(doc);
      return kullanici;
    }
    return null;
  }

  void takipEt({String? aktifKullaniciId, String? profilSahibiId}) {
    _firestore
        .collection("takipciler")
        .document(profilSahibiId)
        .collection("kullanicininTakipcileri")
        .document(aktifKullaniciId)
        .setData({});

    _firestore
        .collection("takipEdilenler")
        .document(aktifKullaniciId)
        .collection("kullanicininTakipleri")
        .document(profilSahibiId)
        .setData({});
    duyuruEkle(
        aktiviteTipi: "takip",
        aktiviteYapanId: aktifKullaniciId,
        profilSahibiId: profilSahibiId);
  }

  void takiptenCik({String? aktifKullaniciId, String? profilSahibiId}) {
    _firestore
        .collection("takipciler")
        .document(profilSahibiId)
        .collection("kullanicininTakipcileri")
        .document(aktifKullaniciId)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    _firestore
        .collection("takipEdilenler")
        .document(aktifKullaniciId)
        .collection("kullanicininTakipleri")
        .document(profilSahibiId)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Future<bool> takipKontrol(
      {String? aktifKullaniciId, String? profilSahibiId}) async {
    DocumentSnapshot doc = await _firestore
        .collection("takipEdilenler")
        .document(aktifKullaniciId)
        .collection("kullanicininTakipleri")
        .document(profilSahibiId)
        .get();

    if (doc.exists) {
      return true;
    }
    return false;
  }

  // ignore: non_constant_identifier_names
  Future<int> takipciSayisi(KullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("takipciler")
        .document(KullaniciId)
        .collection("kullanicininTakipcileri")
        .getDocuments();
    return snapshot.documents.length;
  }

  void duyuruEkle(
      {String? aktiviteYapanId,
      String? profilSahibiId,
      String? aktiviteTipi,
      String? yorum,
      Gonderi? gonderi}) {
    if (aktiviteYapanId == profilSahibiId) {
      return;
    }
    _firestore
        .collection("duyurular")
        .document(profilSahibiId)
        .collection("kullaniciDuyurulari")
        .add({
      "aktiviteYapanId": aktiviteYapanId,
      "aktiviteTipi": aktiviteTipi,
      "gonderiId": gonderi?.id,
      "gonderiFoto": gonderi?.gonderiResmiUrl,
      "yorum": yorum,
      "olusturulmaZamani": zaman
    });
  }

  Future<List<Duyuru>> duyurulariGetir(String profilSahibiId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("duyurular")
        .document(profilSahibiId)
        .collection("kullaniciDuyurulari")
        .orderBy("olusturulmaZamani", descending: true)
        .limit(20)
        .getDocuments();
    List<Duyuru> duyurular = [];
    snapshot.documents.forEach((DocumentSnapshot doc) {
      Duyuru duyuru = Duyuru.dokumandanUret(doc);
      duyurular.add(duyuru);
    });
    return duyurular;
  }

  void kullaniciGuncelle(String? kullaniciId, String? kullaniciAdi,
      String? fotoUrl, String? hakkinda) {
    _firestore.collection("kullanicilar").document(kullaniciId).updateData({
      "kullaniciAdi": kullaniciAdi,
      "hakkinda": hakkinda,
      "fotoUrl": fotoUrl
    });
  }

  Future<List<Kullanici>> kullaniciAra(String kelime) async {
    QuerySnapshot snapshot = await _firestore
        .collection("kullanicilar")
        .where("kullaniciAdi", isGreaterThanOrEqualTo: kelime)
        .getDocuments();
    List<Kullanici> kullanicilar =
        snapshot.documents.map((doc) => Kullanici.dokumandanUret(doc)).toList();
    return kullanicilar;
  }

  // ignore: non_constant_identifier_names
  Future<int> takipEdilenSayisi(KullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("takipEdilenler")
        .document(KullaniciId)
        .collection("kullanicininTakipleri")
        .getDocuments();
    return snapshot.documents.length;
  }

  Future<void> gonderiOlustur(
      {gonderiResimUrl, aciklama, yayinlayanId, konum}) async {
    await _firestore
        .collection("gonderiler")
        .document(yayinlayanId)
        .collection("kullaniciGonderileri")
        .add({
      "gonderiResmiUrl": gonderiResimUrl,
      "aciklama": aciklama,
      "begeniSayisi": 0,
      "konum": konum,
      "yayinlayanId": yayinlayanId,
      "olusturulmaZamani": zaman
    });
  }

  gonderileriGetir(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("gonderiler")
        .document(kullaniciId)
        .collection("kullaniciGonderileri")
        .orderBy("olusturulmaZamani", descending: true)
        .getDocuments();

    List<Gonderi> gonderiler =
        snapshot.documents.map((doc) => Gonderi.dokumandanUret(doc)).toList();
    return gonderiler;
  }

  akisGonderileriniGetir(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("akislar")
        .document(kullaniciId)
        .collection("kullaniciAkisGonderileri")
        .orderBy("olusturulmaZamani", descending: true)
        .getDocuments();

    List<Gonderi> gonderiler =
        snapshot.documents.map((doc) => Gonderi.dokumandanUret(doc)).toList();
    return gonderiler;
  }

  Future<void> gonderiSil({String? aktifKullaniciId, Gonderi? gonderi}) async {
    _firestore
        .collection("gonderiler")
        .document(aktifKullaniciId)
        .collection("kullaniciGonderileri")
        .document(gonderi?.id)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    QuerySnapshot yorumlarSnapshot = await _firestore
        .collection("yorumlar")
        .document(gonderi?.id)
        .collection("gonderiYorumlari")
        .getDocuments();
    yorumlarSnapshot.documents.forEach((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    QuerySnapshot duyurularSnapshot = await _firestore
        .collection("duyurular")
        .document(gonderi?.yayinlayanId)
        .collection("kullaniciDuyurulari")
        .where("gonderiId", isEqualTo: gonderi?.id)
        .getDocuments();
    duyurularSnapshot.documents.forEach((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    StorageServisi().gonderiResmiSil(gonderi?.gonderiResmiUrl ?? "");
  }

  Future<Gonderi> tekliGonderiGetir(
      String gonderiId, String gonderiSahibiId) async {
    DocumentSnapshot doc = await _firestore
        .collection("gonderiler")
        .document(gonderiSahibiId)
        .collection("kullaniciGonderileri")
        .document(gonderiId)
        .get();
    Gonderi gonderi = Gonderi.dokumandanUret(doc);
    return gonderi;
  }

  Future<void> gonderiBegen(Gonderi gonderi, String aktifKullaniciId) async {
    DocumentReference docRef = _firestore
        .collection("gonderiler")
        .document(gonderi.yayinlayanId)
        .collection("kullaniciGonderileri")
        .document(gonderi.id);
    DocumentSnapshot doc = await docRef.get();
    if (doc.exists) {
      Gonderi gonderi = Gonderi.dokumandanUret(doc);
      int yeniBegeniSayisi = gonderi.begeniSayisi + 1;

      docRef.updateData({"begeniSayisi": yeniBegeniSayisi});

      _firestore
          .collection("begeniler")
          .document(gonderi.id)
          .collection("gonderiBegenileri")
          .document(aktifKullaniciId)
          .setData({});
      duyuruEkle(
          aktiviteTipi: "begeni",
          aktiviteYapanId: aktifKullaniciId,
          gonderi: gonderi,
          profilSahibiId: gonderi.yayinlayanId);
    }
  }

  Future<void> gonderiBegeniKaldir(
      Gonderi gonderi, String aktifKullaniciId) async {
    DocumentReference docRef = _firestore
        .collection("gonderiler")
        .document(gonderi.yayinlayanId)
        .collection("kullaniciGonderileri")
        .document(gonderi.id);

    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      Gonderi gonderi = Gonderi.dokumandanUret(doc);
      int yeniBegeniSayisi = gonderi.begeniSayisi - 1;

      docRef.updateData({"begeniSayisi": yeniBegeniSayisi});

      DocumentSnapshot docBegeni = await _firestore
          .collection("begeniler")
          .document(gonderi.id)
          .collection("gonderiBegenileri")
          .document(aktifKullaniciId)
          .get();
      if (docBegeni.exists) {
        docBegeni.reference.delete();
      }
    }
  }

  Future<bool> begeniVarMi(Gonderi gonderi, String aktifKullaniciId) async {
    DocumentSnapshot docBegeni = await _firestore
        .collection("begeniler")
        .document(gonderi.id)
        .collection("gonderiBegenileri")
        .document(aktifKullaniciId)
        .get();

    if (docBegeni.exists) {
      return true;
    }
    return false;
  }

  Stream<QuerySnapshot> yorumlariGetir(String gonderiId) {
    return _firestore
        .collection("yorumlar")
        .document(gonderiId)
        .collection("gonderiYorumlari")
        .orderBy("olusturulmaZamani", descending: true)
        .snapshots();
  }

  void yorumEkle(String? aktifKullaniciId, Gonderi gonderi, String icerik) {
    _firestore
        .collection("yorumlar")
        .document(gonderi.id)
        .collection("gonderiYorumlari")
        .add({
      "icerik": icerik,
      "yayinlayanId": aktifKullaniciId,
      "olusturulmaZamani": zaman,
    });
    duyuruEkle(
        aktiviteTipi: "yorum",
        aktiviteYapanId: aktifKullaniciId,
        gonderi: gonderi,
        profilSahibiId: gonderi.yayinlayanId,
        yorum: icerik);
  }
}
