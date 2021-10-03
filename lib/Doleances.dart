import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// See https://firebase.flutter.dev/docs/firestore/usage/
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:provider/provider.dart';
import 'package:doleances/Task.dart';

// Provider
class Doleances with ChangeNotifier {
  bool connected = false;
  bool notified = false;
  String message='';
  User? user;
  List<String> whatStringList = ['Rien'];
  List<String> whereStringList= ['Ici'];
  List<Task> tasks = [];
  // Listen to List updates
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  String? notification;

  // Connect with code
  Future<void> connect({String? codeToTest}) async {
    String code = 'wrongCode';
    if (codeToTest == null) {
      // Check stored identity if any
      final storage = new FlutterSecureStorage();
      String? storedCode = await storage.read(key: 'code');
      // Use stored code, if any
      if (storedCode != null) {
        code = storedCode;
        // Should show a spinner not do get another code during check
      } else {
        // No code. No stored code.
        return;
      }
    } else {
      code = codeToTest;
    }
    // We have a code to test
    try {
      await Firebase.initializeApp();

      // Listen to List updates and push then as a notifcation
      _subscription = FirebaseFirestore.instance.collection('doleances')
          .orderBy('timestamp').limitToLast(1)
          .snapshots()
          .listen((snapshot) {
        print('connect in listen subscription ${snapshot.docs.length}');
        // notifyListeners();
      }, onDone: () {
        print('connect in listen subscription onDone');
        notifyListeners();
      });

      user = FirebaseAuth.instance.currentUser;
      // User is not already connected
      if (FirebaseAuth.instance.currentUser == null) {
        // 3 registered profiles, 3 codes, not in clear, this is opensource !
        // Hash would be overkill just to choose between profiles.
        if (code.contains('test')) { // Code isn't verified here, all you know is code contains test
          await FirebaseAuth.instance
              .signInWithEmailAndPassword(
              email: 'test@doléances.fr', password: code * 2);
        } else if (code.contains('s')) { // Code isn't verified here, all you know is code contains s
          await FirebaseAuth.instance
              .signInWithEmailAndPassword(
              email: 'client@doléances.fr', password: code);
        } else if (code.contains('St')) {
          await FirebaseAuth.instance
              .signInWithEmailAndPassword(
              email: 'gestion@doléances.fr', password: code);
        }
        user = FirebaseAuth.instance.currentUser;
        message = 'Connecté : ${user!.email}.';
        connected = true;

        // Store code locally
        final storage = new FlutterSecureStorage();
        await storage.write(key:'code', value:code);

        // Fetch items for Dropdown and liste
        await fetchChoices();
        await fetchDoleances();

        notifyListeners();
      } else {
        connected = true;

        // Fetch items for Dropdown and liste
        await fetchChoices();
        await fetchDoleances();

        // Break infinite loop when showing connection
        if (!notified) {
          notified = true;
          notifyListeners();
        }
      }
    } on FirebaseAuthException catch (e) {
      message = 'Erreur ${(e as dynamic).message}';
      notifyListeners();
    }
  }
   //
  Future<void> sendNotification() async {
    await fetchDoleances();
    notification = 'Liste mise à jour';
    notifyListeners();
  }

  // Disconnect current user
  void signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      message = 'Déconnecté';
      connected = false;
      final storage = new FlutterSecureStorage();
      storage.delete(key:'code');
      notified = false;
      _subscription?.cancel();
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
      whatStringList.sort((a, b) => a.compareTo(b));
      whereStringList = doc.get('where').cast<String>();
      whereStringList.sort((a, b) => a.compareTo(b));
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
      // Refresh cache
      whatStringList = docUpdated.get('what').cast<String>();
      whatStringList.sort((a, b) => a.compareTo(b));
      whereStringList = docUpdated.get('where').cast<String>();
      whereStringList.sort((a, b) => a.compareTo(b));
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
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      // Add to class field tasks
      Task task = Task(id: 'toSet', what: what, where: where, comment: comment, priority: 0, timestamp:timestamp);
      tasks.add(task);
      // Get and add task to the remote collection,
      CollectionReference<Map<String, dynamic>> doleances = FirebaseFirestore.instance.collection('doleances');
      doleances.orderBy('timestamp', descending: true);
      doleances.add(<String, dynamic>{
        'what': what,
        'where': where,
        'comment': comment,
        'priority': 0,
        'timestamp': timestamp,
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
    QuerySnapshot<Map<String, dynamic>> snapshot = await doleances.orderBy('timestamp').get();
    List<QueryDocumentSnapshot> list = snapshot.docs;
    for (final d in list) {
      String id = d.id;
      String what = d.get('what');
      String where = d.get('where');
      String comment = d.get('comment');
      int priority = int.parse(d.get('priority').toString());
      int timestamp = int.parse(d.get('timestamp').toString());
      Task task = Task(
          id: id,
          what: what,
          where: where,
          comment: comment,
          priority: priority,
          timestamp: timestamp);
      // Add to class field tasks
      tasks.add(task);
    }
    print ('fetchDoleances after list build ${tasks.length}');
    tasks.sort((Task a, Task b) => a.timestamp.compareTo(b.timestamp));

    message = 'Doléances récupérées';
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
    // Reload from remote and notify
    await fetchDoleances();

    notifyListeners();
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