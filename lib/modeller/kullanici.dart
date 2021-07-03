// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_auth/firebase_auth.dart';
// ignore: unused_import
import 'package:flutter/material.dart';

class Kullanici {
  final String id;
  final String kullaniciAdi;
  final String fotoUrl;
  final String email;
  final String hakkinda;

  Kullanici(
      {required this.id,
      required this.kullaniciAdi,
      required this.fotoUrl,
      required this.email,
      this.hakkinda = "a"});

  factory Kullanici.firebasedenUret(FirebaseUser kullanici) {
    return Kullanici(
      id: kullanici.uid,
      kullaniciAdi: kullanici.displayName,
      fotoUrl: kullanici.photoUrl,
      email: kullanici.email,
    );
  }

  factory Kullanici.dokumandanUret(DocumentSnapshot doc) {
    return Kullanici(
      id: doc.documentID,
      kullaniciAdi: doc['kullaniciAdi'],
      email: doc['email'],
      fotoUrl: doc['fotoUrl'],
      hakkinda: doc['hakkinda'],
    );
  }
}
