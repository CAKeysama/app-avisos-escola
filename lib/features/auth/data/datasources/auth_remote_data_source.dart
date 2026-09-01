import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/user_role.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel?> get authStateChanges;
  Future<UserModel?> getCurrentUser();
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(UserModel user, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<UserModel> updateProfile(UserModel user);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthRemoteDataSourceImpl();

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((fbUser) async {
      if (fbUser == null) return null;
      return await _fetchUserModelFromFirestore(fbUser.uid, fbUser.email);
    });
  }

  Future<UserModel> _fetchUserModelFromFirestore(String uid, String? email) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 4));
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!, uid);
      }
    } catch (_) {}

    // Fallback básico caso o doc ainda esteja sendo criado ou demore a responder
    return UserModel(
      id: uid,
      name: email?.split('@').first ?? 'Usuário',
      email: email ?? '',
    );
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) return null;
    return await _fetchUserModelFromFirestore(fbUser.uid, fbUser.email);
  }

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final creds = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      // Recarrega os dados do Firebase Auth para checar se o usuário clicou no link de verificação
      await creds.user?.reload();
      final currentUser = _firebaseAuth.currentUser;

      if (currentUser != null && !currentUser.emailVerified) {
        // Envia novo e-mail por garantia
        try {
          await currentUser.sendEmailVerification();
        } catch (_) {}
        
        throw const AuthException(
          'Seu e-mail ainda não foi ativado. Enviamos um link de confirmação para sua caixa de entrada. Por favor, verifique seu e-mail.',
          code: 'email-not-verified',
        );
      }

      final uid = creds.user!.uid;
      final userModel = await _fetchUserModelFromFirestore(uid, email);
      NotificationService().saveUserFcmToken(uid);
      return userModel;
    } on AuthException {
      rethrow;
    } on fb.FirebaseAuthException catch (e) {
      String message = 'E-mail ou senha incorretos.';
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        message = 'Conta não encontrada com este e-mail.';
      } else if (e.code == 'wrong-password') {
        message = 'Senha incorreta. Tente novamente.';
      } else if (e.code == 'invalid-email') {
        message = 'Formato de e-mail inválido.';
      } else if (e.code == 'user-disabled') {
        message = 'Esta conta de usuário foi desativada.';
      } else if (e.message != null && e.message!.isNotEmpty) {
        message = e.message!;
      }
      throw AuthException(message, code: e.code);
    } catch (e) {
      throw ServerFailure('Não foi possível entrar. Verifique seu e-mail e senha.');
    }
  }

  @override
  Future<UserModel> register(UserModel user, String password) async {
    try {
      final creds = await _firebaseAuth.createUserWithEmailAndPassword(
        email: user.email.trim(),
        password: password,
      );
      final uid = creds.user!.uid;

      // ── Envia e-mail oficial de ativação de conta via Firebase ──
      try {
        await creds.user?.sendEmailVerification();
      } catch (e) {
        debugPrint('Erro ao enviar e-mail de verificação: $e');
      }

      // ── Bootstrap Inicial: Se for o 1º usuário do banco, torna-se ADMIN automaticamente ──
      bool isFirstUser = false;
      try {
        final existingUsers = await _firestore.collection('users').limit(2).get();
        isFirstUser = existingUsers.docs.isEmpty;
      } catch (e) {
        // Em um banco virgem, trata como o 1º usuário (Admin)
        isFirstUser = true;
      }

      final finalRole = isFirstUser ? UserRole.admin : user.role;
      final updatedModel = user.copyWith(id: uid, role: finalRole);

      // Salva os dados acadêmicos e papel no Cloud Firestore
      try {
        await _firestore
            .collection('users')
            .doc(uid)
            .set(updatedModel.toJson())
            .timeout(const Duration(seconds: 8));
      } catch (e) {
        debugPrint('Erro ao salvar documento do usuário no Firestore: $e');
      }

      // Atualiza displayName no Firebase Auth
      try {
        await creds.user?.updateDisplayName(user.name);
      } catch (_) {}

      // Salva Token FCM para Notificações Push
      try {
        NotificationService().saveUserFcmToken(uid);
      } catch (_) {}

      return updatedModel;
    } on fb.FirebaseAuthException catch (e) {
      String message = 'Erro ao criar conta.';
      if (e.code == 'email-already-in-use') {
        message = 'Este e-mail já está cadastrado no sistema.';
      } else if (e.code == 'weak-password') {
        message = 'A senha deve conter pelo menos 6 caracteres.';
      } else if (e.code == 'invalid-email') {
        message = 'Formato de e-mail inválido.';
      } else if (e.message != null && e.message!.isNotEmpty) {
        message = e.message!;
      }
      throw AuthException(message, code: e.code);
    } catch (e) {
      debugPrint('Erro genérico no registro: $e');
      throw ServerFailure('Erro ao registrar usuário: ${e.toString()}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(
        e.message ?? 'Erro ao enviar e-mail de redefinição.',
        code: e.code,
      );
    }
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toJson());
      return user;
    } catch (e) {
      throw ServerFailure('Erro ao atualizar perfil no Firestore.');
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}
