import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// See https://firebase.flutter.dev/docs/firestore/usage/
import 'package:doleances/Task.dart';

// Provider
class Doleances with ChangeNotifier {
  bool connected = false;
  String message='';
  User? user;
  List<String> whatStringList = ['Rien'];
  List<String> whereStringList= ['Ici'];
  List<Task> tasks = [];

  // Connect with code then
  Future<void> connect(String code) async {
    try {
      await Firebase.initializeApp();
      // 3 registered profiles, 3 codes, not in clear, this is opensource !
      // Hash would be overkill just to choose between profiles.
      if (code.contains('test')) { // Code isn't verified here, all you know is code contains test
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: 'test@doléances.fr', password: code *2);
      } else if (code.contains('s')) { // Code isn't verified here, all you know is code contains s
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: 'client@doléances.fr', password: code);
      } else if (code.contains('St')) {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: 'gestion@doléances.fr', password: code);
      }
      user = FirebaseAuth.instance.currentUser;
      message = 'Connecté : ${user!.email}.';
      connected = true;

      // Fetch items for Dropdown
      await fetchChoices();

      // Fetch doleances for Liste
      await fetchDoleances();

    } on FirebaseAuthException catch (e) {
      message = 'Erreur ${(e as dynamic).message}';
      notifyListeners();
    }
  }

  // Disconnect current user
  void signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      message = 'Déconnecté';
      connected = false;
    } on FirebaseAuthException catch (e) {
      message = 'Erreur ${(e as dynamic).message}';
    }
    notifyListeners();
  }

  // Fetch and sets 'what' 'where'
  Future<void> fetchChoices() async {
    try {
      FirebaseFirestore store = FirebaseFirestore.instance;
      CollectionReference<Map<String, dynamic>> configuration = store.collection("configuration");
      // QuerySnapshot<Map<String, dynamic>> snapshot = await configuration.get();
      // QueryDocumentSnapshot<Object?> doc = snapshot.docs[0]; // only the first doc
      DocumentSnapshot<Map<String, dynamic>> doc = await configuration.doc('0P7ZltbztNCsXLZIkDcV')
          .get();
      whatStringList = doc.get('what').cast<String>();
      whereStringList = doc.get('where').cast<String>();
    }  on FirebaseAuthException catch (e) {
      message = 'Erreur ${(e as dynamic).message}';
    }
  }

  // Update choices 'what' 'where'
  Future<void> updateChoices(String col, List<String> list) async {
    // Update cache
    if (col == 'what') whatStringList = list;
    if (col == 'where') whereStringList = list;
    try {
      // Update Firebase
      FirebaseFirestore store = FirebaseFirestore.instance;
      CollectionReference<Map<String, dynamic>> configuration = store.collection("configuration");
      // The first doc
      DocumentSnapshot<Map<String, dynamic>> doc =
          await configuration.doc('0P7ZltbztNCsXLZIkDcV').get();
      // Update Firebase
      await doc.reference.update({col: list});
      // Weird doc has not been updated localy, so fetch updated
      var docUpdated = await configuration.doc('0P7ZltbztNCsXLZIkDcV').get();
      // print('Doleances after [$col] doc:${doc.data()} docUpdated:${docUpdated.data()} $list');
      // Refresh cache
      whatStringList = docUpdated.get('what').cast<String>();
      whereStringList = docUpdated.get('where').cast<String>();
      message = 'Liste de choix mise à jour. $col: $list';
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      message = 'Erreur ${(e as dynamic).message}';
    }
  }

  // Add task to Firebase
  Future<void> addTask(String what, String where, String comment) async {
    String mail = user!.email!; // Should not need bang operator
    if (mail.contains('test')) {
      message = 'Ajouté en local seulement. Test n‘a pas le droit de modifier la base.';
    } else if (mail.contains('client') || mail.contains('gestion')) {
      // Add to class field tasks
      Task task = Task(id: 'toSet', what: what, where: where, comment: comment, priority: 0);
      tasks.add(task);
      // Get and add task to the remote collection,
      CollectionReference<Map<String, dynamic>> doleances = FirebaseFirestore.instance.collection('doleances');
      doleances.add(<String, dynamic>{
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'what': what,
        'where': where,
        'comment': comment,
        'priority': 0,
      }).then((DocumentReference<Map<String, dynamic>> value) {
        task.id = value.id;
        message = '''Ajoutée : $what / $where ${value.id}
        $comment
        ''';
        // We are in a .then()
        notifyListeners();
      }).catchError(_onError);
    }
  }

  // Fetch and fill tasks
  Future<void> fetchDoleances() async {
    // Remove all tasks in cache
    tasks.clear();
    // Get Firebase collection
    CollectionReference<Map<String, dynamic>> doleances = FirebaseFirestore.instance.collection("doleances");
    doleances.orderBy('timestamp').get().then((QuerySnapshot<Map<String, dynamic>> snapshot) {
      List<QueryDocumentSnapshot> list = snapshot.docs;
      for (final d in list) {
        String id = d.id;
        String what = d.get('what');
        String where = d.get('where');
        String comment = d.get('comment');
        int priority = int.parse(d.get('priority').toString());
        Task task = Task(id: id, what: what, where: where, comment: comment, priority: priority);
        // Add to class field tasks
        tasks.add(task);
      }
      message = 'Doléances récupérées';
      // We are in a .then()
      notifyListeners();
    }).catchError(_onError);
  }

  // Set task priority
  Future<void> setPriority(Task task) async{
    CollectionReference<Map<String, dynamic>> doleances =
        FirebaseFirestore.instance.collection("doleances");
    if (task.priority == -2) {
      // Remove from local cache
      tasks.remove(task);
      // Remove from remote
      await doleances.doc(task.id).delete().catchError(_onError);
      message = 'Tache supprimée ${task.id}.';
    } else {
      // Update Firebase CollectionReference<Map<String, dynamic>> doleances
      await doleances.doc(task.id).update({'priority': task.priority}).catchError(_onError);
      message = 'Priorité mise à jour ${task.priority}.';
    }
    // Reload from remote will notify
    fetchDoleances();
  }

  // Gets status
  bool gestion() {
    user = FirebaseAuth.instance.currentUser;
    return (user != null && user!.email!.contains('gestion'));
  }

  // Catch errors and report
  _onError(e){
    message = 'Erreur ${(e as dynamic).message}';
  }
}