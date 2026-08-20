import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/user_display_utils.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.onSurface, size: 20),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.onSurface,
          ),
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          String fullName = 'Guest User';
          String initials = 'G';
          String? networkImage;

          if (state is AuthAuthenticated) {
            final user = state.user;
            fullName = '${user.firstName} ${user.lastName}';
            initials = UserDisplayUtils.initialsFor(user);
            networkImage = user.image;
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2DC28D),
                          shape: BoxShape.circle,
                          image: _imageFile != null
                              ? DecorationImage(
                                  image: FileImage(_imageFile!),
                                  fit: BoxFit.cover,
                                )
                              : (networkImage != null && networkImage.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(networkImage),
                                      fit: BoxFit.cover,
                                    )
                                  : null),
                        ),
                        alignment: Alignment.center,
                        child: _imageFile == null &&
                                (networkImage == null || networkImage.isEmpty)
                            ? Text(
                                initials,
                                style: const TextStyle(
                                  fontFamily: 'Lexend Deca',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 28,
                                  height: 34 / 28,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showImagePickerOptions,
                          child: SvgPicture.asset(
                            'assets/svgs/Change IMG Icon.svg',
                            width: 32,
                            height: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  fullName,
                  style: const TextStyle(
                    fontFamily: 'Lexend Deca',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    height: 25 / 20,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 48),
                _buildListItem('assets/svgs/settings 1.svg', 'Settings',
                    AppColors.onSurface),
                _buildListItem('assets/svgs/friends 1.svg', 'My Friends',
                    AppColors.onSurface),
                _buildListItem('assets/svgs/heart 1.svg', 'My Favourite',
                    AppColors.onSurface),
                _buildListItem('assets/svgs/star 1.svg', 'Latest Reviews',
                    AppColors.onSurface),
                _buildListItem(
                    'assets/svgs/wifi 1.svg', 'Followers', AppColors.onSurface),
                const SizedBox(height: 48),
                _buildListItem(
                  'assets/svgs/power-off 1.svg',
                  'Log Out',
                  const Color(0xFFEB5A5A),
                  onTap: () {
                    context.read<AuthBloc>().add(AuthLogoutRequested());
                  },
                ),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildListItem(String assetPath, String title, Color color,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Row(
          children: [
            SvgPicture.asset(
              assetPath,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Lexend Deca',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                height: 21 / 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
