import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Set to `true` while developing – allows any email domain.
// Flip to `false` before shipping to production.
// ─────────────────────────────────────────────────────────────────────────────
const bool kDevMode = true;

const String _requiredDomain = 'da.edu.pk';

/// Thrown with a human-readable [message] whenever admin gate-keeping fails.
class AdminAuthException implements Exception {
  const AdminAuthException(this.message);
  final String message;

  @override
  String toString() => 'AdminAuthException: $message';
}

/// All admin authentication logic lives here so [LoginController] stays thin.
class AdminAuthService {
  AdminAuthService._();

  static final AdminAuthService instance = AdminAuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── 1. Domain check ────────────────────────────────────────────────────────

  /// Returns `null` when the email passes the domain check, or a
  /// human-readable error string when it fails.
  String? checkDomain(String email) {
    if (kDevMode) return null; // all domains allowed in dev
    final lower = email.trim().toLowerCase();
    if (!lower.endsWith('@$_requiredDomain')) {
      return 'Access restricted. Only @$_requiredDomain accounts are allowed.';
    }
    return null;
  }

  // ── 2. Firestore admin-collection lookup ───────────────────────────────────

  /// Returns `true` when the signed-in user's UID exists in the `admins`
  /// collection.  Signs the user out automatically if they are not an admin.
  Future<bool> _verifyAdminRecord(User user) async {
    try {
      final doc =
          await _firestore.collection('admins').doc(user.uid).get();
      if (doc.exists) return true;

      // Not in the admins collection – revoke the session immediately.
      await _auth.signOut();
      return false;
    } catch (e) {
      // Network / Firestore error – treat as access denied and sign out.
      debugPrint('AdminAuthService._verifyAdminRecord: $e');
      await _auth.signOut();
      return false;
    }
  }

  // ── 3. Email + password sign-in ───────────────────────────────────────────

  /// Signs in with email / password and then verifies admin status.
  ///
  /// Throws [AdminAuthException] for domain or admin-record failures.
  /// Re-throws [FirebaseAuthException] for credential failures so the
  /// controller can map them to friendly messages.
  Future<void> signInWithEmail({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    // 1. Domain gate
    final domainError = checkDomain(email);
    if (domainError != null) throw AdminAuthException(domainError);

    // 2. Firebase Auth
    if (kIsWeb) {
      await _auth.setPersistence(
        rememberMe ? Persistence.LOCAL : Persistence.SESSION,
      );
    }

    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // 3. Admin-collection gate
    final isAdmin = await _verifyAdminRecord(credential.user!);
    if (!isAdmin) {
      throw const AdminAuthException(
        'Access denied. This account does not have admin privileges.',
      );
    }
  }

  // ── 4. Google sign-in ─────────────────────────────────────────────────────

  /// Signs in with Google and then verifies admin status.
  ///
  /// Returns `false` silently when the popup was dismissed by the user.
  /// Throws [AdminAuthException] for domain or admin-record failures.
  Future<bool> signInWithGoogle() async {
    final provider = GoogleAuthProvider()
      ..setCustomParameters({'prompt': 'select_account'});

    UserCredential credential;
    try {
      credential = kIsWeb
          ? await _auth.signInWithPopup(provider)
          : await _auth.signInWithProvider(provider);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request') {
        return false;
      }
      rethrow;
    }

    final email = credential.user?.email ?? '';

    // 1. Domain gate (applied to Google accounts too)
    final domainError = checkDomain(email);
    if (domainError != null) {
      await _auth.signOut();
      throw AdminAuthException(domainError);
    }

    // 2. Admin-collection gate
    final isAdmin = await _verifyAdminRecord(credential.user!);
    if (!isAdmin) {
      throw const AdminAuthException(
        'Access denied. This Google account does not have admin privileges.',
      );
    }

    return true;
  }

  // ── 5. Sign-out ───────────────────────────────────────────────────────────

  Future<void> signOut() => _auth.signOut();
}
