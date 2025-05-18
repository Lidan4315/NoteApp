import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  //get collection
  final CollectionReference notes = FirebaseFirestore.instance.collection(
    'notes',
  );

  //create

  Future<void> addNote(String note) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return notes.add({
      'note': note,
      'timestamp': Timestamp.now(),
      'uid': uid, // simpan UID user
    });
  }

  //read
  Stream<QuerySnapshot> getNotes() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return notes
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  //update
  Future<void> updateNote(String docID, String newNote) {
    return notes.doc(docID).update({
      'note': newNote,
      'timestamp': Timestamp.now(),
    });
  }

  //delete

  Future<void> deleteNote(String docID) {
    return notes.doc(docID).delete();
  }
}
