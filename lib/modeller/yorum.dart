import 'package:cloud_firestore/cloud_firestore.dart';

class Yorum {
  final String id;
  final String icerik;
  final String yayinlayanId;
  final Timestamp olusturulmaZamani;

  Yorum(
      {required this.id,
      required this.icerik,
      required this.yayinlayanId,
      required this.olusturulmaZamani});

  factory Yorum.dokumandanUret(DocumentSnapshot doc) {
    return Yorum(
        id: doc.documentID,
        icerik: doc['icerik'],
        yayinlayanId: doc['yayinlayanId'],
        olusturulmaZamani: doc['olusturulmaZamani']);
  }
}
