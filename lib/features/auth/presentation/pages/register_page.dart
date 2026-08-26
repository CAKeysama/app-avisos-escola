import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedCourseId = 'dsm';
  int _selectedSemester = 4;
  String? _selectedClassId = 'dsm-4-a';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          courseId: _selectedCourseId,
          courseName: selectedCourse['name'],
          semester: _selectedSemester,
          classId: _selectedClassId,
          className: selectedClass['name'],
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta criada com sucesso! Bem-vindo.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authControllerProvider);

    final availableClasses = MockDataService.classes
        .where((c) => c['courseId'] == _selectedCourseId)
        .toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Novo Cadastro'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Complete seu cadastro',
                      style: AppTypography.displayMedium.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Vincule seu curso e turma para receber os avisos corretos',
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Campos de Perfil
                    AppTextField(
                      label: 'Nome completo',
                      hint: 'Ex: Gustavo Henrique Santos',
                      controller: _nameController,
                      prefixIcon: Icons.person_outline,
                      validator: Validators.required,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    AppTextField(
                      label: 'E-mail institucional FATEC',
                      hint: 'exemplo@fatec.sp.gov.br',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    AppTextField(
                      label: 'Criar senha',
                      hint: 'Mínimo 6 caracteres',
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline,
                      validator: Validators.password,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Seleção Acadêmica
                    Text(
                      'Dados Acadêmicos',
                      style: AppTypography.labelMedium.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Dropdown Curso
                    DropdownButtonFormField<String>(
                      value: _selectedCourseId,
                      decoration: const InputDecoration(
                        labelText: 'Curso',
                        prefixIcon: Icon(Icons.school_outlined, size: 20),
                      ),
                      items: MockDataService.courses.map((course) {
                        return DropdownMenuItem<String>(
                          value: course['id'],
                          child: Text(
                            course['name']!,
                            style: AppTypography.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCourseId = val;
                          final validClasses = MockDataService.classes
                              .where((c) => c['courseId'] == val)
                              .toList();
                          _selectedClassId = validClasses.isNotEmpty ? validClasses.first['id'] : null;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Row(
                      children: [
                        // Semestre
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<int>(
                            value: _selectedSemester,
                            decoration: const InputDecoration(
                              labelText: 'Semestre',
                              prefixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                            ),
                            items: List.generate(6, (i) => i + 1).map((sem) {
                              return DropdownMenuItem<int>(
                                value: sem,
                                child: Text('$semº Sem'),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedSemester = val ?? 1),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        // Turma
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            value: _selectedClassId,
                            decoration: const InputDecoration(
                              labelText: 'Turma',
                              prefixIcon: Icon(Icons.groups_outlined, size: 20),
                            ),
                            items: availableClasses.map((cl) {
                              return DropdownMenuItem<String>(
                                value: cl['id'],
                                child: Text(
                                  cl['name']!,
                                  style: AppTypography.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedClassId = val),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    AppButton(
                      text: 'Concluir Cadastro',
                      isLoading: authState.isLoading,
                      onPressed: _submit,
                      icon: Icons.check_circle_outline,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
