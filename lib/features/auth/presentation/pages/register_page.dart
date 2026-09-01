import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/user_role.dart';
import '../controllers/auth_controller.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  String? _selectedCourseId = 'dsm';
  int _selectedSemester = 4;
  String? _selectedClassId = 'dsm-4-a';

  UserRole _requestedRole = UserRole.student;

  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
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
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _anim.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final selectedCourse = MockDataService.courses.firstWhere(
      (c) => c['id'] == _selectedCourseId,
      orElse: () => {'id': 'dsm', 'name': 'Desenvolvimento de Software Multiplataforma'},
    );
    final selectedClass = MockDataService.classes.firstWhere(
      (c) => c['id'] == _selectedClassId,
      orElse: () => {'id': 'dsm-4-a', 'name': 'DSM 4º Semestre - Turma A'},
    );

    final success = await ref.read(authControllerProvider.notifier).register(
          name: _nameCtrl.text,
          email: _emailCtrl.text,
          password: _passCtrl.text,
          courseId: _selectedCourseId,
          courseName: selectedCourse['name'],
          semester: _selectedSemester,
          classId: _selectedClassId,
          className: selectedClass['name'],
        );

    if (success && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Row(
            children: [
              Icon(Icons.mark_email_read_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Ative sua Conta'),
            ],
          ),
          content: Text(
            'Enviamos um e-mail com o link de ativação para ${_emailCtrl.text}.\n\nPor favor, abra sua caixa de entrada e clique no link para validar seu e-mail antes de fazer login.',
            style: AppTypography.subheadline,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Entendi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );

      // Encerra a sessão temporária para que o usuário faça login após clicar no link
      await ref.read(authControllerProvider.notifier).logout();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authControllerProvider);

    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final separator = isDark ? AppColors.separatorDark : AppColors.separatorLight;
    final textPrimary = isDark ? AppColors.labelPrimaryDark : AppColors.labelPrimary;
    final textSecondary = isDark ? AppColors.labelSecondaryDark : AppColors.labelSecondary;
    final textTertiary = isDark ? AppColors.labelTertiaryDark : AppColors.labelTertiary;
    final accent = isDark ? AppColors.primaryLight : AppColors.primary;

    final availableClasses = MockDataService.classes
        .where((c) => c['courseId'] == _selectedCourseId)
        .toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        title: Text('Cadastro',
            style: AppTypography.navTitle.copyWith(color: textPrimary)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 18, color: accent),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
              height: 0.5, color: separator.withOpacity(0.6)),
        ),
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 28),

                // ── Título da seção ──────────────────────────────────────
                Text(
                  'Criar conta',
                  style: AppTypography.title1.copyWith(color: textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  'Vincule seu curso e turma para receber os avisos corretos.',
                  style: AppTypography.footnote.copyWith(color: textSecondary),
                ),
                const SizedBox(height: 28),

                // ── Seção: Dados pessoais ────────────────────────────────
                _SectionLabel(label: 'DADOS PESSOAIS', textTertiary: textTertiary),
                _GroupedSection(surface: surface, separator: separator, children: [
                  AppTextField(
                    hint: 'Nome completo',
                    controller: _nameCtrl,
                    prefixIcon: Icons.person_outline_rounded,
                    validator: Validators.required,
                    textInputAction: TextInputAction.next,
                    fillColor: Colors.transparent,
                  ),
                  AppTextField(
                    hint: 'E-mail institucional',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.mail_outline_rounded,
                    validator: Validators.email,
                    textInputAction: TextInputAction.next,
                    fillColor: Colors.transparent,
                  ),
                  AppTextField(
                    hint: 'Criar senha (mín. 6 caracteres)',
                    controller: _passCtrl,
                    isPassword: true,
                    prefixIcon: Icons.lock_outline_rounded,
                    validator: Validators.password,
                    textInputAction: TextInputAction.done,
                    fillColor: Colors.transparent,
                  ),
                ]),

                const SizedBox(height: 24),

                // ── Seção: Dados acadêmicos ──────────────────────────────
                _SectionLabel(label: 'DADOS ACADÊMICOS', textTertiary: textTertiary),
                _GroupedSection(surface: surface, separator: separator, children: [
                  // Curso
                  _DropdownRow(
                    label: 'Curso',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    textTertiary: textTertiary,
                    value: _selectedCourseId,
                    items: MockDataService.courses
                        .map((c) => DropdownMenuItem<String>(
                              value: c['id'],
                              child: Text(
                                c['name']!,
                                style: AppTypography.subheadline
                                    .copyWith(color: textPrimary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() {
                      _selectedCourseId = val;
                      final cls = MockDataService.classes
                          .where((c) => c['courseId'] == val)
                          .toList();
                      _selectedClassId =
                          cls.isNotEmpty ? cls.first['id'] : null;
                    }),
                  ),
                  // Semestre
                  _DropdownRow(
                    label: 'Semestre',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    textTertiary: textTertiary,
                    value: _selectedSemester,
                    items: List.generate(6, (i) => i + 1)
                        .map((s) => DropdownMenuItem<int>(
                              value: s,
                              child: Text(
                                '$sº semestre',
                                style: AppTypography.subheadline
                                    .copyWith(color: textPrimary),
                              ),
                            ))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedSemester = val ?? 1),
                  ),
                  // Turma
                  _DropdownRow(
                    label: 'Turma',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    textTertiary: textTertiary,
                    value: _selectedClassId,
                    items: availableClasses
                        .map((c) => DropdownMenuItem<String>(
                              value: c['id'],
                              child: Text(
                                c['name']!,
                                style: AppTypography.subheadline
                                    .copyWith(color: textPrimary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedClassId = val),
                  ),
                  // Cargo Pretendido
                  _DropdownRow<UserRole>(
                    label: 'Cargo Pretendido',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    textTertiary: textTertiary,
                    value: _requestedRole,
                    items: UserRole.values
                        .where((r) => r != UserRole.admin) // Admin não é solicitável via cadastro público
                        .map((role) => DropdownMenuItem<UserRole>(
                              value: role,
                              child: Text(
                                role == UserRole.student
                                    ? '${role.label} (Padrão)'
                                    : '${role.label} (Requer Aprovação)',
                                style: AppTypography.subheadline
                                    .copyWith(color: textPrimary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _requestedRole = val ?? UserRole.student),
                  ),
                ]),

                const SizedBox(height: 32),

                // ── Botão ───────────────────────────────────────────────
                AppButton(
                  text: 'Criar Conta',
                  isLoading: authState.isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 16),

                // ── Login existente ──────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Já tem conta? ',
                      style: AppTypography.footnote
                          .copyWith(color: textSecondary),
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        'Entrar',
                        style: AppTypography.footnote.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Componentes internos ────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color textTertiary;
  const _SectionLabel({required this.label, required this.textTertiary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        label,
        style: AppTypography.caption2.copyWith(
          color: textTertiary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _GroupedSection extends StatelessWidget {
  final Color surface;
  final Color separator;
  final List<Widget> children;
  const _GroupedSection({
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
      // Campos transparentes dentro do container branco — padrão iOS
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
                  margin: const EdgeInsets.only(left: 16),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DropdownRow<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  const _DropdownRow({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          labelText: label,
          labelStyle:
              AppTypography.caption.copyWith(color: textTertiary),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12),
        ),
        icon: Icon(Icons.keyboard_arrow_down_rounded,
            size: 20, color: textTertiary),
        isExpanded: true,
        items: items,
        onChanged: onChanged,
        style: AppTypography.subheadline.copyWith(color: textPrimary),
        dropdownColor:
            Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : AppColors.surfaceLight,
      ),
    );
  }
}
