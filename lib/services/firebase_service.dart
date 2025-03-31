import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Email/password sign
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      // IMPORTANT: This will disable reCAPTCHA verification for testing
      await _firebaseAuth.setSettings(
        appVerificationDisabledForTesting: true,
      );

      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth exceptions
      switch (e.code) {
        case 'invalid-email':
          throw Exception('Invalid email format');
        case 'user-disabled':
          throw Exception('This user account has been disabled');
        case 'user-not-found':
        case 'wrong-password':
          throw Exception('Invalid email or password');
        case 'too-many-requests':
          throw Exception('Too many login attempts. Try again later');
        default:
          throw Exception('Authentication failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to sign in with email: $e');
    }
  }

  // Google sign in
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in aborted');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  // Apple sign in
  Future<UserCredential> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      return await _firebaseAuth.signInWithCredential(oauthCredential);
    } catch (e) {
      throw Exception('Failed to sign in with Apple: $e');
    }
  }

  // Phone authentication
  // In your FirebaseAuthService class
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    // IMPORTANT: Disable app verification for testing
    await _firebaseAuth.setSettings(
      appVerificationDisabledForTesting: true,
    );

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      // Add a timeout to prevent long waits
      timeout: const Duration(seconds: 60),
    );
  }

  Future<UserCredential> signInWithPhoneCredential(
    PhoneAuthCredential credential,
  ) async {
    try {
      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Failed to sign in with phone: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // Auth state changes stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
