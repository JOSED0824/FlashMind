import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/router/route_names.dart';
import '../../../../../core/theme/theme_cubit.dart';
import '../../../../../core/utils/no_params.dart';
import '../../../../../core/widgets/app_loading_indicator.dart';
import '../../../../../core/widgets/shimmer_loader.dart';
import '../../../../../injection.dart';
import '../../../../../features/auth/domain/usecases/logout_user.dart';
import '../../../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../../../../features/auth/presentation/cubit/profile_cubit.dart';
import '../../../../../features/auth/presentation/cubit/auth_state.dart';
import '../../../../../services/tts_service.dart';
import '../../domain/entities/category_entity.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/categories_grid.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/home_header.dart';
import '../widgets/stats_row.dart';

class HomePage extends StatefulWidget {
  final String userId;
  final String username;

  const HomePage({super.key, required this.userId, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTab = 0;
  String _selectedFilter = 'Todas';
  bool _notificationsEnabled = false;
  final _imagePicker = ImagePicker();

  static const _filters = [
    'Todas',
    'Historia',
    'Ciencia',
    'Idiomas',
    'Tecnología',
    'Matemáticas',
    'Arte y Cultura',
    'Geografía',
    'Filosofía',
    'Economía',
  ];

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadHome(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final photoUrl = authState is AuthSuccess
        ? authState.user.photoUrl
        : FirebaseAuth.instance.currentUser?.photoURL;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [context.acBg, context.acBgMid, context.acBgEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading || state is HomeInitial) {
                return _buildShimmer();
              }
              if (state is HomeError) {
                return Center(
                  child: Text(state.message, style: AppTextStyles.body),
                );
              }
              if (state is HomeLoaded) {
                return _buildTabContent(state);
              }
              return const AppLoadingIndicator();
            },
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: context.acNavBar.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: context.acBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedTab,
          backgroundColor: Colors.transparent,
          elevation: 0,
          height: 62,
          indicatorColor: AppColors.accentStart.withValues(alpha: 0.2),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (i) => setState(() => _selectedTab = i),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: _ProfileNavIcon(photoUrl: photoUrl, selected: false),
              selectedIcon: _ProfileNavIcon(photoUrl: photoUrl, selected: true),
              label: 'Perfil',
            ),
            const NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Ajustes',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(HomeLoaded state) {
    return IndexedStack(
      index: _selectedTab,
      children: [
        _buildHomeContent(state),
        _buildProfileContent(state),
        _buildSettingsContent(),
      ],
    );
  }

  Widget _buildHomeContent(HomeLoaded state) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: HomeHeader(
            username: widget.username,
            streak: state.progress.currentStreak,
            photoUrl: (context.read<AuthCubit>().state is AuthSuccess)
                ? (context.read<AuthCubit>().state as AuthSuccess).user.photoUrl
                : FirebaseAuth.instance.currentUser?.photoURL,
          ),
        ),
        SliverToBoxAdapter(child: StatsRow(progress: state.progress)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Categorías',
                    style: AppTextStyles.headline
                        .copyWith(color: context.acText)),
                const SizedBox(height: 4),
                Text(
                  'Elige un tema y completa una sesión de aprendizaje.',
                  style:
                      AppTextStyles.caption.copyWith(color: context.acTextSub),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: CategoryFilterBar(
            selectedFilter: _selectedFilter,
            filters: _filters,
            onFilterSelected: (f) => setState(() => _selectedFilter = f),
          ),
        ),
        SliverToBoxAdapter(
          child: CategoriesGrid(
            categories: _selectedFilter == 'Todas'
                ? state.categories
                : state.categories
                    .where((c) => c.name == _selectedFilter)
                    .toList(),
            onCategoryTap: _onCategoryTap,
          ),
        ),
      ],
    );
  }

  Future<void> _pickAndUploadPhoto(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: context.acSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.acBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.photo_library_rounded,
                  color: AppColors.accentStart),
              title: Text('Galería',
                  style: AppTextStyles.body
                      .copyWith(color: context.acText)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_rounded,
                  color: AppColors.accentStart),
              title: Text('Cámara',
                  style: AppTextStyles.body
                      .copyWith(color: context.acText)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (picked == null || !mounted) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) return;

    context.read<ProfileCubit>().uploadPhoto(
          picked, // XFile — funciona en mobile y web
          authState.user,
        );
  }

  Widget _buildProfileContent(HomeLoaded state) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    final completedTopics = state.progress.completedTopicIds.length;

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, profileState) {
        if (profileState is ProfileUploadSuccess) {
          context.read<AuthCubit>().updateUser(profileState.updatedUser);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto actualizada correctamente')),
          );
          context.read<ProfileCubit>().resetToIdle();
        } else if (profileState is ProfileUploadFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(profileState.message)),
          );
          context.read<ProfileCubit>().resetToIdle();
        } else if (profileState is ProfileUsernameUpdated) {
          context.read<AuthCubit>().updateUser(profileState.updatedUser);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nombre actualizado correctamente')),
          );
          context.read<ProfileCubit>().resetToIdle();
        } else if (profileState is ProfileUsernameFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(profileState.message)),
          );
          context.read<ProfileCubit>().resetToIdle();
        }
      },
      builder: (context, profileState) {
        final isUploading = profileState is ProfileUploading;
        final isUpdatingName = profileState is ProfileUpdatingUsername;
        final authState = context.watch<AuthCubit>().state;
        final photoUrl = authState is AuthSuccess
            ? authState.user.photoUrl
            : FirebaseAuth.instance.currentUser?.photoURL;
        final currentUsername = authState is AuthSuccess
            ? authState.user.username
            : widget.username;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Perfil',
                      style: AppTextStyles.headline
                          .copyWith(color: context.acText)),
                  GestureDetector(
                    onTap: () => _showEditProfileSheet(
                      context,
                      currentUsername: currentUsername,
                      email: email,
                      photoUrl: photoUrl,
                      isUploading: isUploading,
                      isUpdatingName: isUpdatingName,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.accentStart.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppColors.accentStart.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_rounded,
                              size: 14, color: AppColors.accentStart),
                          const SizedBox(width: 6),
                          Text('Editar',
                              style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.accentStart,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Avatar card ──────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 28, horizontal: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [context.acSurface, context.acSurface2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: context.acBorder),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: isUploading
                          ? null
                          : () => _pickAndUploadPhoto(context),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor:
                                AppColors.accentStart.withValues(alpha: 0.2),
                            backgroundImage: photoUrl != null
                                ? NetworkImage(photoUrl)
                                : null,
                            child: photoUrl == null
                                ? Text(
                                    currentUsername.isNotEmpty
                                        ? currentUsername[0].toUpperCase()
                                        : 'U',
                                    style: AppTextStyles.display.copyWith(
                                        color: AppColors.accentStart),
                                  )
                                : null,
                          ),
                          if (isUploading)
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.5),
                              ),
                              child: const AppLoadingIndicator(),
                            ),
                          if (!isUploading)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.accentStart,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: context.acSurface,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Username row with inline loading
                    isUpdatingName
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.accentStart),
                              ),
                              const SizedBox(width: 8),
                              Text('Actualizando...',
                                  style: AppTextStyles.body.copyWith(
                                      color: AppColors.accentStart)),
                            ],
                          )
                        : Text(currentUsername,
                            style: AppTextStyles.title
                                .copyWith(color: context.acText)),
                    const SizedBox(height: 4),
                    Text(email,
                        style: AppTextStyles.caption
                            .copyWith(color: context.acTextSub)),
                    if (isUploading) ...[
                      const SizedBox(height: 8),
                      Text('Subiendo foto...',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.accentStart)),
                    ],
                    const SizedBox(height: 16),
                    // Quick-edit chips
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _EditChip(
                          icon: Icons.badge_rounded,
                          label: 'Cambiar nombre',
                          onTap: () => _showChangeNameSheet(
                              context, currentUsername),
                        ),
                        const SizedBox(width: 10),
                        _EditChip(
                          icon: Icons.photo_camera_rounded,
                          label: 'Cambiar foto',
                          onTap: isUploading
                              ? null
                              : () => _pickAndUploadPhoto(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Estadísticas ─────────────────────────────────────────
              Text('Estadísticas',
                  style: AppTextStyles.title.copyWith(color: context.acText)),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.0,
                children: [
                  _StatCard(
                    icon: Icons.star_rounded,
                    label: 'Puntos',
                    value: '${state.progress.totalPoints}',
                    color: AppColors.warning,
                  ),
                  _StatCard(
                    icon: Icons.check_circle_rounded,
                    label: 'Sesiones',
                    value: '${state.progress.totalSessions}',
                    color: AppColors.correct,
                  ),
                  _StatCard(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Racha',
                    value: '${state.progress.currentStreak} días',
                    color: const Color(0xFFFF6B35),
                  ),
                  _StatCard(
                    icon: Icons.school_rounded,
                    label: 'Temas vistos',
                    value: '$completedTopics',
                    color: AppColors.accentStart,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditProfileSheet(
    BuildContext context, {
    required String currentUsername,
    required String email,
    required String? photoUrl,
    required bool isUploading,
    required bool isUpdatingName,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.acSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: context.acBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text('Editar perfil',
                  style: AppTextStyles.title.copyWith(color: context.acText)),
              const SizedBox(height: 20),
              _ProfileSheetTile(
                icon: Icons.badge_rounded,
                title: 'Cambiar nombre',
                subtitle: currentUsername,
                onTap: () {
                  Navigator.pop(context);
                  _showChangeNameSheet(context, currentUsername);
                },
              ),
              const SizedBox(height: 10),
              _ProfileSheetTile(
                icon: Icons.photo_camera_rounded,
                title: 'Cambiar foto',
                subtitle: 'Galería o cámara',
                onTap: isUploading
                    ? null
                    : () {
                        Navigator.pop(context);
                        _pickAndUploadPhoto(context);
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangeNameSheet(BuildContext context, String currentUsername) {
    final controller = TextEditingController(text: currentUsername);
    showModalBottomSheet(
      context: context,
      backgroundColor: context.acSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: context.acBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Cambiar nombre',
                style: AppTextStyles.title.copyWith(color: context.acText)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: 30,
              style: AppTextStyles.body.copyWith(color: context.acText),
              decoration: InputDecoration(
                hintText: 'Tu nombre',
                hintStyle: AppTextStyles.body
                    .copyWith(color: context.acTextSub),
                filled: true,
                fillColor: context.acSurface2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: context.acBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: context.acBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppColors.accentStart, width: 2),
                ),
                prefixIcon: Icon(Icons.person_rounded,
                    color: context.acTextSub, size: 20),
                counterStyle:
                    AppTextStyles.caption.copyWith(color: context.acTextSub),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(sheetCtx);
                  context
                      .read<ProfileCubit>()
                      .changeUsername(controller.text);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accentStart,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text('Guardar',
                    style: AppTextStyles.label
                        .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsContent() {
    final tts = sl<TtsService>();
    return StatefulBuilder(
      builder: (context, setInner) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ajustes',
                  style: AppTextStyles.headline
                      .copyWith(color: context.acText)),
              const SizedBox(height: 24),

              // ── Apariencia ──────────────────────────────────────────────
              _SectionHeader('Apariencia'),
              const SizedBox(height: 10),
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, themeMode) {
                  final isDark = themeMode == ThemeMode.dark;
                  return _SettingsTile(
                    icon: isDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    title: 'Tema visual',
                    subtitle: isDark ? 'Modo oscuro' : 'Modo claro',
                    trailing: Switch(
                      value: isDark,
                      onChanged: (_) =>
                          context.read<ThemeCubit>().toggleTheme(),
                      activeThumbColor: AppColors.accentStart,
                      activeTrackColor:
                          AppColors.accentStart.withValues(alpha: 0.35),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // ── Sonido y accesibilidad ───────────────────────────────────
              _SectionHeader('Sonido y accesibilidad'),
              const SizedBox(height: 10),
              _SettingsTile(
                icon: Icons.record_voice_over_rounded,
                title: 'Leer preguntas en voz alta',
                subtitle: 'Activa el lector de pantalla al estudiar',
                trailing: Switch(
                  value: tts.enabled,
                  onChanged: (v) {
                    setInner(() => tts.enabled = v);
                    if (!v) tts.stop();
                  },
                  activeThumbColor: AppColors.accentStart,
                  activeTrackColor:
                      AppColors.accentStart.withValues(alpha: 0.35),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showSpeedSheet(context, tts, setInner),
                child: _SettingsTile(
                  icon: Icons.speed_rounded,
                  title: 'Velocidad de voz',
                  subtitle: _speechRateLabel(tts.speechRate),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      size: 18),
                ),
              ),
              const SizedBox(height: 20),

              // ── Notificaciones ───────────────────────────────────────────
              _SectionHeader('Notificaciones'),
              const SizedBox(height: 10),
              _SettingsTile(
                icon: Icons.notifications_active_rounded,
                title: 'Recordatorios diarios',
                subtitle: 'Recibe recordatorios para mantener tu racha',
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (v) =>
                      setInner(() => _notificationsEnabled = v),
                  activeThumbColor: AppColors.accentStart,
                  activeTrackColor:
                      AppColors.accentStart.withValues(alpha: 0.35),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _notificationsEnabled
                    ? () => _showInfoDialog(
                          context,
                          'Hora del recordatorio',
                          'Próximamente podrás personalizar la hora de tu recordatorio diario.',
                        )
                    : null,
                child: Opacity(
                  opacity: _notificationsEnabled ? 1.0 : 0.4,
                  child: _SettingsTile(
                    icon: Icons.schedule_rounded,
                    title: 'Hora del recordatorio',
                    subtitle: '8:00 AM',
                    trailing: const Icon(Icons.chevron_right_rounded,
                        size: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Acerca de ────────────────────────────────────────────────
              _SectionHeader('Acerca de'),
              const SizedBox(height: 10),
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'Versión de la app',
                subtitle: '1.0.0 (build 1)',
                trailing: const SizedBox.shrink(),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showInfoDialog(
                  context,
                  'Calificar FlashMind',
                  'Próximamente disponible en Google Play y App Store. ¡Gracias por usar FlashMind!',
                ),
                child: _SettingsTile(
                  icon: Icons.star_rounded,
                  title: 'Calificar la app',
                  subtitle: 'Déjanos tu opinión en la tienda',
                  trailing: const Icon(Icons.chevron_right_rounded,
                      size: 18),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showTermsDialog(context),
                child: _SettingsTile(
                  icon: Icons.description_rounded,
                  title: 'Términos y condiciones',
                  subtitle: 'Consulta nuestras políticas de uso',
                  trailing: const Icon(Icons.chevron_right_rounded,
                      size: 18),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showPrivacyDialog(context),
                child: _SettingsTile(
                  icon: Icons.shield_rounded,
                  title: 'Política de privacidad',
                  subtitle: 'Cómo manejamos tu información',
                  trailing: const Icon(Icons.chevron_right_rounded,
                      size: 18),
                ),
              ),
              const SizedBox(height: 32),

              // ── Zona de peligro ──────────────────────────────────────────
              _SectionHeader('Cuenta'),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout_rounded,
                      color: AppColors.incorrect),
                  label: Text(
                    'Cerrar sesión',
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.incorrect),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.incorrect),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    await sl<LogoutUser>()(const NoParams());
                    if (context.mounted) context.go(RouteNames.auth);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Settings helpers ────────────────────────────────────────────────────

  String _speechRateLabel(double rate) {
    if (rate <= 0.36) return 'Lenta';
    if (rate <= 0.54) return 'Normal';
    return 'Rápida';
  }

  void _showSpeedSheet(
      BuildContext ctx, TtsService tts, StateSetter setInner) {
    final options = [
      ('Lenta', 0.35),
      ('Normal', 0.48),
      ('Rápida', 0.65),
    ];
    showModalBottomSheet(
      context: ctx,
      backgroundColor: ctx.acSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: ctx.acBorder,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Velocidad de voz',
                style: AppTextStyles.title.copyWith(color: ctx.acText)),
            const SizedBox(height: 16),
            ...options.map((opt) {
              final selected = tts.speechRate == opt.$2;
              return GestureDetector(
                onTap: () {
                  setInner(() => tts.speechRate = opt.$2);
                  Navigator.pop(ctx);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.accentStart.withValues(alpha: 0.12)
                        : ctx.acSurface2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? AppColors.accentStart
                          : ctx.acBorder,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(opt.$1,
                          style: AppTextStyles.body.copyWith(
                              color: selected
                                  ? AppColors.accentStart
                                  : ctx.acText,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w400)),
                      const Spacer(),
                      if (selected)
                        const Icon(Icons.check_rounded,
                            color: AppColors.accentStart, size: 18),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext ctx, String title, String message) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: ctx.acSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: AppTextStyles.title.copyWith(color: ctx.acText)),
        content: Text(message,
            style: AppTextStyles.body.copyWith(color: ctx.acTextSub)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Entendido',
                style: AppTextStyles.label
                    .copyWith(color: AppColors.accentStart)),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext ctx) {
    _showInfoDialog(
      ctx,
      'Términos y condiciones',
      'Al usar FlashMind aceptas nuestros términos de servicio. '
          'La app es de uso personal y educativo. '
          'Nos reservamos el derecho de modificar el contenido sin previo aviso. '
          'No nos hacemos responsables por el uso indebido de la plataforma.',
    );
  }

  void _showPrivacyDialog(BuildContext ctx) {
    _showInfoDialog(
      ctx,
      'Política de privacidad',
      'FlashMind almacena únicamente tu correo electrónico y nombre de usuario '
          'para identificar tu cuenta. Tu progreso de estudio se guarda en '
          'servidores seguros. No compartimos tu información con terceros. '
          'Puedes eliminar tu cuenta en cualquier momento.',
    );
  }


  Future<void> _onCategoryTap(CategoryEntity category) async {
    await context.push(
      RouteNames.topicSelection,
      extra: {
        'categoryId': category.id,
        'categoryName': category.name,
        'gradientType': category.gradientType,
      },
    );
    // Reload stats after returning from any session (back-button path)
    if (mounted) {
      context.read<HomeCubit>().loadHome(widget.userId);
    }
  }

  Widget _buildShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoader(width: 160, height: 28, borderRadius: 8),
          const SizedBox(height: 8),
          const ShimmerLoader(width: 120, height: 18, borderRadius: 6),
          const SizedBox(height: 24),
          Row(
            children: const [
              Expanded(child: ShimmerLoader(width: double.infinity, height: 80, borderRadius: 14)),
              SizedBox(width: 10),
              Expanded(child: ShimmerLoader(width: double.infinity, height: 80, borderRadius: 14)),
              SizedBox(width: 10),
              Expanded(child: ShimmerLoader(width: double.infinity, height: 80, borderRadius: 14)),
            ],
          ),
          const SizedBox(height: 28),
          const ShimmerLoader(width: 120, height: 24, borderRadius: 6),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: List.generate(
              4,
              (_) => const ShimmerLoader(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section header for settings ──────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: context.acTextSub,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Profile nav icon ─────────────────────────────────────────────────────────

class _ProfileNavIcon extends StatelessWidget {
  final String? photoUrl;
  final bool selected;

  const _ProfileNavIcon({required this.photoUrl, required this.selected});

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null) {
      return CircleAvatar(
        radius: 13,
        backgroundImage: NetworkImage(photoUrl!),
      );
    }
    return Icon(
      selected ? Icons.person_rounded : Icons.person_outline_rounded,
    );
  }
}

// ── Edit chip ───────────────────────────────────────────────────────────────

class _EditChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _EditChip({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: context.acSurface2,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: context.acBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: context.acTextSub),
              const SizedBox(width: 5),
              Text(label,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: context.acTextSub)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Profile sheet tile ──────────────────────────────────────────────────────

class _ProfileSheetTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ProfileSheetTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: context.acSurface2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.acBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accentStart.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: AppColors.accentStart),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.body
                            .copyWith(color: context.acText,
                                fontWeight: FontWeight.w600)),
                    Text(subtitle,
                        style: AppTextStyles.caption
                            .copyWith(color: context.acTextSub)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: context.acTextSub, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stat card para el perfil ────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.acSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.acBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    style: AppTextStyles.label
                        .copyWith(color: context.acText, fontSize: 15)),
                Text(label,
                    style: AppTextStyles.caption
                        .copyWith(color: context.acTextSub, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings tile ────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.acSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.acBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.accentStart.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.accentStart, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.label
                        .copyWith(color: context.acText)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: AppTextStyles.caption
                        .copyWith(color: context.acTextSub)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
