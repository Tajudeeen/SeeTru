import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../domain/models.dart';

class AccountService extends GetxService {
  final user = Rxn<User>();
  bool available = false;
  String? issue;
  Future<AccountService> initialize() async {
    const key = String.fromEnvironment('FIREBASE_API_KEY');
    const app = String.fromEnvironment('FIREBASE_APP_ID');
    const project = String.fromEnvironment('FIREBASE_PROJECT_ID');
    const sender = String.fromEnvironment('FIREBASE_SENDER_ID');
    if ([key, app, project, sender].any((s) => s.isEmpty)) return this;
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: key,
          appId: app,
          messagingSenderId: sender,
          projectId: project,
          authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
        ),
      );
      available = true;
      user.bindStream(FirebaseAuth.instance.authStateChanges());
    } catch (_) {
      issue =
          'Account services could not initialize. Your local workspace is still available.';
    }
    return this;
  }

  Future<void> authenticate(
    String email,
    String password, {
    bool register = false,
  }) async {
    if (!available) throw const FormatException('Firebase is not configured.');
    try {
      if (register) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
      }
    } on FirebaseAuthException catch (e) {
      throw FormatException(e.message ?? 'Authentication failed.');
    }
  }

  Future<void> resetPassword(String email) =>
      FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
  Future<void> signOut() => FirebaseAuth.instance.signOut();
  DocumentReference<Map<String, dynamic>> get _backup {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) throw const FormatException('Sign in first.');
    return FirebaseFirestore.instance.doc('users/${u.uid}/backups/workspace');
  }

  Future<void> upload(Workspace w) async {
    final text = w.export();
    if (text.length > 700000) {
      throw const FormatException(
        'Workspace is too large for cloud backup. Use JSON export.',
      );
    }
    await _backup.set({
      'workspace': text,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Workspace> download() async {
    final data = (await _backup.get()).data();
    if (data == null) throw const FormatException('No cloud backup exists.');
    return Workspace.parse(data['workspace']);
  }
}
