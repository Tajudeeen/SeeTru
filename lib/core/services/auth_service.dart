import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// ✅ Fix 5: Typed exception instead of raw String throws
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _box = GetStorage();

  // ── Reactive user state ────────────────────────────────────────────
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final RxBool isLoggedIn = false.obs;

  // ✅ Fix 2: Hold worker reference so it can be disposed
  Worker? _authWorker;

  @override
  void onInit() {
    super.onInit();
    // Bind Firebase auth state stream
    firebaseUser.bindStream(_auth.authStateChanges());
    // ✅ Fix 2: Store worker reference for cleanup
    _authWorker = ever(firebaseUser, _handleAuthChanged);
  }

  // ✅ Fix 2: Cancel stream subscription and worker on close
  @override
  void onClose() {
    _authWorker?.dispose();
    firebaseUser.close();
    super.onClose();
  }

  void _handleAuthChanged(User? user) {
    // ✅ Fix 3: Guard against firing during shutdown
    if (!Get.isRegistered<AuthService>()) return;

    if (user != null) {
      isLoggedIn.value = true;
      // ✅ Fix 1: Offload storage writes off the main thread
      Future.microtask(() {
        _box.write('auth_token', user.uid);
        _box.write('user_name', user.displayName ?? 'User');
        _box.write('user_email', user.email ?? '');
      });
    } else {
      isLoggedIn.value = false;
      Future.microtask(() => _box.remove('auth_token'));
    }
  }

  // ── Current user helpers ───────────────────────────────────────────
  User? get currentUser => _auth.currentUser;
  String get uid => _auth.currentUser?.uid ?? '';
  String get displayName => _auth.currentUser?.displayName ?? 'User';
  String get email => _auth.currentUser?.email ?? '';
  String get photoUrl => _auth.currentUser?.photoURL ?? '';

  // ── Email / Password Sign In ───────────────────────────────────────
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    }
  }

  // ── Email / Password Sign Up ───────────────────────────────────────
  Future<UserCredential?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      await credential.user?.reload();
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    }
  }

  // ── Google Sign In ─────────────────────────────────────────────────
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    } catch (e) {
      throw const AuthException('Google sign-in failed. Please try again.');
    }
  }

  // ── Password Reset ─────────────────────────────────────────────────
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    }
  }

  // ── Update Profile ─────────────────────────────────────────────────
  Future<void> updateProfile({String? name, String? photoUrl}) async {
    try {
      if (name != null) await currentUser?.updateDisplayName(name);
      if (photoUrl != null) await currentUser?.updatePhotoURL(photoUrl);
      await currentUser?.reload();
    } catch (e) {
      throw const AuthException('Failed to update profile.');
    }
  }

  // ── Sign Out ───────────────────────────────────────────────────────
  Future<void> signOut() async {
    try {
      // ✅ Fix 4: Run both sign-outs in parallel
      await Future.wait([
        _googleSignIn.signOut(),
        _auth.signOut(),
      ]);
      Future.microtask(() => _box.remove('auth_token'));
    } catch (e) {
      throw const AuthException('Sign out failed.');
    }
  }

  // ── Delete Account ─────────────────────────────────────────────────
  Future<void> deleteAccount() async {
    try {
      await currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    }
  }

  // ── Error mapping ──────────────────────────────────────────────────
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'invalid-credential':
        return 'Invalid credentials. Please try again.';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action.';
      default:
        return e.message ?? 'An unexpected error occurred.';
    }
  }
}