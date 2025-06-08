import 'package:flutter/material.dart';
import 'package:paydiddy/providers/user_provider.dart';
import 'package:paydiddy/utils/constants.dart';
import 'package:paydiddy/utils/validators.dart';
import '../../widgets/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  _loadUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? '';
    }
  }

  _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      await userProvider.updateProfile(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      Fluttertoast.showToast(
        msg: 'Profil berhasil diperbarui',
        backgroundColor: Colors.green,
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Gagal memperbarui profil: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Tidak ada data pengguna'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profil',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: OverlayLoadingIndicator(
          isLoading: _isLoading,
          loadingMessage: 'Menyimpan perubahan...',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppConstants.primaryColor.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Profile Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Pribadi',
                      style: AppConstants.subHeadingStyle,
                    ),
                    const SizedBox(height: 16),

                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                        ),
                      ),
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                        ),
                        enabled: false, // Email cannot be changed
                      ),
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Nomor Telepon',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: Validators.validatePhoneNumber,
                    ),

                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: LoadingButton(
                        isLoading: _isLoading,
                        text: 'Simpan Perubahan',
                        onPressed: _saveProfile,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}