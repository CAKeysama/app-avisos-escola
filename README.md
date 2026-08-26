# 🎓 Mural Acadêmico FATEC (App Sala de Avisos)

Aplicativo oficial de comunicação e mural acadêmico institucional para FATEC / Escolas, desenvolvido em **Flutter** seguindo rigorosamente os princípios de **Clean Architecture**, **SOLID**, **Riverpod**, **GoRouter** e **Firebase** (100% gratuito e escalável).

---

## 📌 1. Visão do Produto

O aplicativo funciona como um mural institucional oficial segmentado, permitindo que alunos, professores, representantes e coordenadores recebam e publiquem comunicados direcionados com precisão:

- **Toda a Escola / Instituição**: Comunicados gerais, suspensão de aulas, eventos acadêmicos.
- **Curso Específico**: Prazos de projetos integradores, avisos da coordenação de curso.
- **Turma / Sala de Aula**: Alterações de sala, avisos de representantes, lembretes de aula.

---

## 🛠️ 2. Tecnologias Utilizadas

- **Flutter 3.47+ / Dart 3.13+**
- **State Management & DI**: `flutter_riverpod` (Injeção de dependência e reatividade previsível).
- **Navegação Declarativa**: `go_router` (Guards de autenticação e proteção de rotas por papel).
- **Backend & Cloud (Gratuito)**:
  - **Firebase Authentication**: E-mail institucional, redefinição de senha e persistência de sessão.
  - **Cloud Firestore**: Banco de dados NoSQL com índices compostos e sincronização offline.
  - **Firebase Cloud Messaging (FCM)**: Notificações push por tópicos (`school_all`, `course_{id}`, `class_{id}`).
- **Design System**: Estética institucional moderna inspirada na Apple & FATEC (Clean typography, cards com bordas suaves, suporte a **Light Mode** e **Dark Mode**).

---

## 🏛️ 3. Estrutura do Projeto (Clean Architecture)

```
lib/
├── app/
│   ├── router/               # Rotas declarativas GoRouter com Guards de Auth e Role
│   └── app.dart              # Widget raiz com temas e roteador
│
├── core/
│   ├── config/               # Leitura tipada de variáveis de ambiente (.env)
│   ├── constants/            # Coleções Firestore, tópicos FCM e chaves
│   ├── errors/               # Failures, Exceptions e tratamento amigável de erros
│   ├── services/             # MockDataService, Notificações e Storage
│   ├── theme/                # Design System (AppColors, AppTypography, AppSpacing, AppRadius, AppTheme)
│   ├── utils/                # DateFormatter (relativo pt-BR), Validators de formulário
│   └── widgets/              # Componentes base: AppButton, AppTextField, AppCard, AppBadge, AppEmptyState, AppLoading
│
└── features/
    ├── auth/                 # Clean Architecture (Data, Domain, Presentation)
    │   ├── domain/           # UserEntity, UserRole (RBAC), AuthRepository, UseCases
    │   ├── data/             # UserModel, AuthRemoteDataSource, AuthRepositoryImpl
    │   └── presentation/     # AuthController (Riverpod), SplashPage, LoginPage, RegisterPage, ForgotPasswordPage
    │
    ├── announcements/        # Clean Architecture (Data, Domain, Presentation)
    │   ├── domain/           # AnnouncementEntity, Priority, Category, TargetType, Repositories, UseCases
    │   ├── data/             # AnnouncementModel, AnnouncementRemoteDataSource, AnnouncementRepositoryImpl
    │   └── presentation/     # AnnouncementFeedController, HomePage, AnnouncementDetailPage, CreateEditAnnouncementPage, Widgets
    │
    ├── profile/              # Perfil do aluno/servidor, alternância de tema e simulador de permissões
    └── admin/                # Dashboard administrativo, métricas e gerenciamento de usuários
```

---

## 🔐 4. Matriz de Permissões e Segurança (RBAC)

| Papel | Visualizar Avisos | Marcar como Lido | Criar p/ Turma | Criar p/ Curso | Criar p/ Escola | Fixar Avisos | Painel Admin |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Aluno (Student)** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Representante (Representative)** | ✅ | ✅ | ✅ (Sua turma) | ❌ | ❌ | ✅ | ❌ |
| **Professor (Teacher)** | ✅ | ✅ | ✅ (Turmas vinculadas) | ❌ | ❌ | ❌ | ❌ |
| **Coordenador (Coordinator)** | ✅ | ✅ | ✅ | ✅ (Seu curso) | ✅ | ✅ | Parcial |
| **Administrador (Admin)** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

---

## ⚙️ 5. Configuração de Variáveis de Ambiente (.env)

O projeto inclui o arquivo `.env.example`. Para configurar seu ambiente:

```bash
# Copie o template para .env
cp .env.example .env
```

Edite o arquivo `.env` com as configurações do seu projeto Firebase:
```ini
APP_ENV=development
APP_NAME="Avisos Acadêmicos FATEC"
INSTITUTION_NAME="FATEC"
INSTITUTION_SUPPORT_EMAIL="suporte@fatec.edu.br"

FIREBASE_PROJECT_ID="seu-projeto-firebase"
FIREBASE_API_KEY="sua-api-key"
```

---

## 🛡️ 6. Segurança do Firestore (Security Rules)

As regras de segurança estão definidas no arquivo [`firestore.rules`](./firestore.rules) e garantem que:
1. Alunos não consigam publicar comunicados gerais na escola através de chamadas diretas ao banco.
2. Representantes só consigam criar e alterar avisos direcionados à sua própria turma (`classId`).
3. Somente administradores possam alterar papéis de usuários (`role`).

---

## 🚀 7. Como Executar o Projeto

1. Instale as dependências:
   ```bash
   flutter pub get
   ```

2. Execute em modo de desenvolvimento:
   ```bash
   # Executar no navegador Chrome
   flutter run -d chrome

   # Executar no Windows Desktop
   flutter run -d windows
   ```

3. Executar Testes Automatizados:
   ```bash
   flutter test
   ```

4. Executar Análise Estática de Código:
   ```bash
   flutter analyze
   ```
