import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _anim.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(authControllerProvider.notifier)
        .login(_emailCtrl.text, _passCtrl.text);
    if (ok && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        final isVerificationPending = next.errorMessage!.contains('não foi ativado') ||
            next.errorMessage!.contains('verifique seu e-mail');

        if (isVerificationPending) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              title: const Row(
                children: [
                  Icon(Icons.mark_email_unread_rounded,
                      color: Colors.orangeAccent),
                  SizedBox(width: 8),
                  Text('Ative sua Conta'),
                ],
              ),
              content: Text(
                next.errorMessage!,
                style: AppTypography.subheadline,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
      if (next.isAuthenticated && mounted) {
        context.go('/home');
      }
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authControllerProvider);

    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final separator = isDark ? AppColors.separatorDark : AppColors.separatorLight;
    final textPrimary = isDark ? AppColors.labelPrimaryDark : AppColors.labelPrimary;
    final textSecondary = isDark ? AppColors.labelSecondaryDark : AppColors.labelSecondary;
    final accent = isDark ? AppColors.primaryLight : AppColors.primary;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 24),

                // ── Ícone ───────────────────────────────────────────────
                Center(
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.fillDark
                          : AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.school_rounded, size: 36, color: accent),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Título ──────────────────────────────────────────────
                Text(
                  'Mural Acadêmico',
                  style: AppTypography.title1.copyWith(color: textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'FATEC — Avisos e Comunicados',
                  style: AppTypography.footnote.copyWith(color: textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),

                // ── Erro ────────────────────────────────────────────────
                if (authState.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.destructive.withOpacity(0.07),
                      borderRadius: AppRadius.borderMd,
                    ),
                    child: Text(
                      authState.errorMessage!,
                      style: AppTypography.footnote
                          .copyWith(color: AppColors.destructive),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Campos agrupados ────────────────────────────────────
                Form(
                  key: _formKey,
                  child: _GroupedFields(
                    surface: surface,
                    separator: separator,
                    children: [
                      AppTextField(
                        hint: 'E-mail institucional',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.person_outline_rounded,
                        validator: Validators.email,
                        textInputAction: TextInputAction.next,
                        fillColor: Colors.transparent,
                      ),
                      AppTextField(
                        hint: 'Senha',
                        controller: _passCtrl,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline_rounded,
                        validator: Validators.password,
                        textInputAction: TextInputAction.done,
                        fillColor: Colors.transparent,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Esqueci a senha
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => context.push('/forgot-password'),
                    child: Text(
                      'Esqueceu a senha?',
                      style: AppTypography.footnote.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Botão Entrar ─────────────────────────────────────────
                AppButton(
                  text: 'Entrar',
                  isLoading: authState.isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 20),

                // ── Link de cadastro ─────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Não tem conta? ',
                      style: AppTypography.footnote
                          .copyWith(color: textSecondary),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/register'),
                      child: Text(
                        'Cadastrar',
                        style: AppTypography.footnote.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Seção agrupada de campos — superfície branca com separadores internos.
class _GroupedFields extends StatelessWidget {
  final Color surface;
  final Color separator;
  final List<Widget> children;

  const _GroupedFields({
    required this.surface,
    required this.separator,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      // Sobrescreve o tema para que os campos sejam transparentes
      // dentro do container branco — padrão iOS grouped list
      child: Theme(
        data: theme.copyWith(
          inputDecorationTheme: theme.inputDecorationTheme.copyWith(
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        child: Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1)
                Container(
                  height: 0.5,
                  color: separator,
                  margin: const EdgeInsets.only(left: 52),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
