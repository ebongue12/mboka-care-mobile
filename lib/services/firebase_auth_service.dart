import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream d'état d'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // =====================================================
  // INSCRIPTION PATIENT
  // =====================================================
  Future<Map<String, dynamic>> registerPatient({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String phone,
    required DateTime dateNaissance,
    required String groupeSanguin,
  }) async {
    try {
      // 1. Créer compte Firebase Auth
      final UserCredential userCredential = 
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

      final User? user = userCredential.user;
      if (user == null) {
        throw Exception('Erreur lors de la création du compte');
      }

      // 2. Générer QR Code unique
      final String qrCodeId = _generateQrCodeId(user.uid);

      // 3. Créer document Firestore
      await _firestore.collection('patients').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'phone': phone,
        'nom': nom,
        'prenom': prenom,
        'date_naissance': Timestamp.fromDate(dateNaissance),
        'groupe_sanguin': groupeSanguin,
        'allergies': [],
        'qr_code_id': qrCodeId,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'user': user,
        'qr_code_id': qrCodeId,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur inattendue: $e',
      };
    }
  }

  // =====================================================
  // CONNEXION
  // =====================================================
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = 
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

      return {
        'success': true,
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _getErrorMessage(e.code),
      };
    }
  }

  // =====================================================
  // DÉCONNEXION
  // =====================================================
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // =====================================================
  // UTILITAIRES
  // =====================================================
  
  String _generateQrCodeId(String uid) {
    return 'MC${uid.substring(0, 8).toUpperCase()}';
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'Cette adresse email est déjà utilisée';
      case 'weak-password':
        return 'Le mot de passe doit contenir au moins 6 caractères';
      case 'invalid-email':
        return 'Adresse email invalide';
      case 'user-not-found':
        return 'Aucun compte avec cette adresse email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      default:
        return 'Erreur : $errorCode';
    }
  }
}
