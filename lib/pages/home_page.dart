import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppbtest/services/firestore.dart';
import 'package:flutter/material.dart';
import 'package:ppbtest/services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController textController = TextEditingController();

  void openNoteBox([String? docID]) {
    if (docID != null) {
      // Jika edit, isi controller dengan note lama
      firestoreService.notes.doc(docID).get().then((doc) {
        if (doc.exists) {
          textController.text =
              (doc.data() as Map<String, dynamic>)['note'] ?? '';
        }
      });
    } else {
      textController.clear();
    }
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              docID == null ? 'Tambah Catatan' : 'Ubah catatan',
              style: TextStyle(
                color: Colors.cyan.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: 'Create a new note',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyan),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (docID == null) {
                    // add new note
                    await firestoreService.addNote(textController.text);
                    await NotificationService.createNotification(
                      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                      title: 'Catatan Ditambahkan',
                      body: 'Catatan baru berhasil ditambahkan.',
                    );
                  } else {
                    // update existing note
                    await firestoreService.updateNote(
                      docID,
                      textController.text,
                    );
                    await NotificationService.createNotification(
                      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                      title: 'Catatan Diedit',
                      body: 'Catatan berhasil diedit.',
                    );
                  }
                  textController.clear();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(docID == null ? 'Tambah' : 'Ubah'),
              ),
            ],
          ),
    );
  }

  Future<void> deleteNote(String docID) async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text('Konfirmasi'),
            content: const Text('Anda yakin ingin menghapus catatan ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await firestoreService.deleteNote(docID);
                  await NotificationService.createNotification(
                    id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                    title: 'Catatan Dihapus',
                    body: 'Catatan berhasil dihapus.',
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
        title: const Text(
          'Catatan Saya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(
                context,
                'account',
              ); // Navigasi ke halaman profil
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openNoteBox(),
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Terjadi error"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notes found"));
          }

          List noteList = snapshot.data!.docs;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              itemCount: noteList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = noteList[index];
                String docID = document.id;

                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;

                String noteText = data['note'];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    title: Text(noteText),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.cyan),
                          onPressed: () => openNoteBox(docID),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteNote(docID),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
