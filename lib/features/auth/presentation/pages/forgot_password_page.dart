import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  late final AnimationController _anim;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 360));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _anim.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(_emailCtrl.text);
    if (ok && mounted) {
      await _anim.reverse();
      setState(() => _sent = true);
      _anim.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
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
      appBar: AppBar(
        backgroundColor: surface,
        title: Text(
          'Recuperar Senha',
          style: AppTypography.navTitle.copyWith(color: textPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 18, color: accent),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: separator.withOpacity(0.6)),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: _sent ? _buildSuccess(textPrimary, textSecondary, accent) : _buildForm(surface, separator, textPrimary, textSecondary, accent, authState),
        ),
      ),
    );
  }

  Widget _buildForm(
    Color surface,
    Color separator,
    Color textPrimary,
    Color textSecondary,
    Color accent,
    dynamic authState,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 36),
        Text(
          'Esqueceu sua senha?',
          style: AppTypography.title1.copyWith(color: textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          'Informe seu e-mail institucional e enviaremos um link para redefinir sua senha.',
          style: AppTypography.footnote.copyWith(color: textSecondary),
        ),
        const SizedBox(height: 32),

        // Campo agrupado
        Form(
          key: _formKey,
          child: Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: AppTextField(
              hint: 'E-mail institucional',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.mail_outline_rounded,
              validator: Validators.email,
              textInputAction: TextInputAction.done,
            ),
          ),
        ),
        const SizedBox(height: 24),

        AppButton(
          text: 'Enviar link',
          isLoading: authState.isLoading,
          onPressed: _submit,
        ),
        const SizedBox(height: 20),

        Center(
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Text(
              'Lembrou a senha? Entrar',
              style: AppTypography.footnote.copyWith(
                color: accent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess(
      Color textPrimary, Color textSecondary, Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícone de sucesso — discreto, sem círculo colorido pesado
          Icon(
            Icons.mark_email_read_outlined,
            size: 56,
            color: AppColors.success,
          ),
          const SizedBox(height: 28),
          Text(
            'E-mail enviado',
            style: AppTypography.title1.copyWith(color: textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Enviamos as instruções para ${_emailCtrl.text}. Verifique sua caixa de entrada e spam.',
            style: AppTypography.footnote.copyWith(color: textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          AppButton(
            text: 'Voltar ao Login',
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
