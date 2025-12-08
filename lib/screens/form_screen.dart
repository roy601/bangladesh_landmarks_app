import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/landmark_model.dart';
import '../providers/landmark_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_indicator.dart';
import '../utils/constants.dart';
import '../utils/image_helper.dart';
import '../config/app_theme.dart';
import 'map_picker_screen.dart';
import 'package:latlong2/latlong.dart';

class FormScreen extends StatefulWidget {
  final Landmark? landmark; // null for add, not-null for edit

  const FormScreen({Key? key, this.landmark}) : super(key: key);

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();

  File? _selectedImage;
  bool _isLoadingLocation = false;
  final ImagePicker _picker = ImagePicker();

  bool get isEditMode => widget.landmark != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _titleController.text = widget.landmark!.title;
      _latController.text = widget.landmark!.lat.toString();
      _lonController.text = widget.landmark!.lon.toString();
    } else {
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    final provider = context.read<LandmarkProvider>();
    final location = await provider.getCurrentLocation();

    if (location != null && mounted) {
      _latController.text = location['lat']!.toStringAsFixed(6);
      _lonController.text = location['lon']!.toStringAsFixed(6);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location detected successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      _latController.text = AppConstants.bangladeshLat.toString();
      _lonController.text = AppConstants.bangladeshLon.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Using default location (Bangladesh)'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    setState(() => _isLoadingLocation = false);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);

        // Resize image
        final resizedImage = await ImageHelper.resizeImage(file);

        setState(() {
          _selectedImage = resizedImage;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image selected and resized to 800x600'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<LandmarkProvider>();

    final title = _titleController.text.trim();
    final lat = double.parse(_latController.text.trim());
    final lon = double.parse(_lonController.text.trim());

    bool success;
    if (isEditMode) {
      success = await provider.updateLandmark(
        id: widget.landmark!.id!,
        title: title,
        lat: lat,
        lon: lon,
        imageFile: _selectedImage,
      );
    } else {
      success = await provider.addLandmark(
        title: title,
        lat: lat,
        lon: lon,
        imageFile: _selectedImage,
      );
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode
                ? AppConstants.updateSuccess
                : AppConstants.addSuccess),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Clear form for add mode
        if (!isEditMode) {
          _titleController.clear();
          _latController.clear();
          _lonController.clear();
          setState(() {
            _selectedImage = null;
          });
          _getCurrentLocation(); // Reset to current location
        } else {
          // For edit mode, pop back
          Navigator.pop(context, true); // Pass true to indicate success
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Operation failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LandmarkProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Landmark' : 'Add New Landmark'),
        actions: [
          if (!isEditMode)
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: _isLoadingLocation ? null : _getCurrentLocation,
              tooltip: 'Get Current Location',
            ),
        ],
      ),
      body: provider.isLoading
          ? const LoadingIndicator(message: 'Saving...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image section
                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : (isEditMode &&
                                    widget.landmark!.fullImageUrl != null)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      widget.landmark!.fullImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stack) =>
                                          _buildImagePlaceholder(),
                                    ),
                                  )
                                : _buildImagePlaceholder(),
                      ),
                    ),

                    const SizedBox(height: 8),
                    Text(
                      'Tap to ${_selectedImage != null || (isEditMode && widget.landmark!.image != null) ? 'change' : 'add'} image',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title field
                    CustomTextField(
                      controller: _titleController,
                      label: 'Title',
                      hint: 'Enter landmark title',
                      prefixIcon: Icons.title,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Latitude field
                    CustomTextField(
                      controller: _latController,
                      label: 'Latitude',
                      hint: 'Enter latitude',
                      prefixIcon: Icons.location_on,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^-?\d*\.?\d*'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter latitude';
                        }
                        final lat = double.tryParse(value.trim());
                        if (lat == null) {
                          return 'Invalid latitude';
                        }
                        if (lat < -90 || lat > 90) {
                          return 'Latitude must be between -90 and 90';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Longitude field
                    CustomTextField(
                      controller: _lonController,
                      label: 'Longitude',
                      hint: 'Enter longitude',
                      prefixIcon: Icons.location_on,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^-?\d*\.?\d*'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter longitude';
                        }
                        final lon = double.tryParse(value.trim());
                        if (lon == null) {
                          return 'Invalid longitude';
                        }
                        if (lon < -180 || lon > 180) {
                          return 'Longitude must be between -180 and 180';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _pickLocationFromMap,
                      icon: const Icon(Icons.map),
                      label: const Text('Pick Location from Map'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppTheme.primaryColor),
                        foregroundColor: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit button
// Submit button (around line 250)
                ElevatedButton(
                  onPressed: provider.isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    isEditMode ? 'Update Landmark' : 'Add Landmark',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate,
          size: 60,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 8),
        Text(
          'Add Image',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      ],
    );
  }
  Future<void> _pickLocationFromMap() async {
    final selectedLocation = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(
          initialLat: _latController.text.isEmpty
              ? null
              : double.tryParse(_latController.text),
          initialLon: _lonController.text.isEmpty
              ? null
              : double.tryParse(_lonController.text),
        ),
      ),
    );

    if (selectedLocation != null) {
      setState(() {
        _latController.text = selectedLocation.latitude.toStringAsFixed(6);
        _lonController.text = selectedLocation.longitude.toStringAsFixed(6);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location selected from map'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
