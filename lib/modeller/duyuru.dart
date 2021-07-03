import 'package:cloud_firestore/cloud_firestore.dart';

class Duyuru {
  final String id;
  final String aktiviteYapanId;
  final String aktiviteTipi;
  final String gonderiId;
  final String gonderiFoto;
  final String? yorum;
  final Timestamp olusturulmaZamani;

  Duyuru(
      {required this.id,
      required this.aktiviteYapanId,
      required this.aktiviteTipi,
      required this.gonderiId,
      required this.gonderiFoto,
      required this.yorum,
      required this.olusturulmaZamani});

  factory Duyuru.dokumandanUret(DocumentSnapshot doc) {
    return Duyuru(
      id: doc.documentID,
      aktiviteYapanId: doc['aktiviteYapanId'],
      aktiviteTipi: doc['aktiviteTipi'],
      gonderiId: doc['gonderiId'],
      gonderiFoto: doc['gonderiFoto'],
      yorum: doc['yoorum'],
      olusturulmaZamani: doc['olusturulmaZamani'],
    );
  }
}
