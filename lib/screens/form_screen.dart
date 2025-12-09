import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../models/landmark_model.dart';
import '../providers/landmark_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_indicator.dart';
import '../utils/constants.dart';
import '../utils/image_helper.dart';
import '../config/app_theme.dart';
import 'map_picker_screen.dart';

class FormScreen extends StatefulWidget {
  final Landmark? landmark; // If null = ADD mode, if not null = EDIT mode

  const FormScreen({Key? key, this.landmark}) : super(key: key);

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text controllers to get user input
  final _titleController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();

  // Variables to store state
  File? _selectedImage; // Stores the selected image
  bool _isLoadingLocation = false; // Shows loading when getting GPS
  final ImagePicker _picker = ImagePicker(); // Used to pick images

  // Check if we're editing (true) or adding (false)
  bool get isEditMode => widget.landmark != null;

  @override
  void initState() {
    super.initState();

    // If editing, fill the form with existing data
    if (isEditMode) {
      _titleController.text = widget.landmark!.title;
      _latController.text = widget.landmark!.lat.toString();
      _lonController.text = widget.landmark!.lon.toString();
    } else {
      // If adding, get current location automatically
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    // Clean up controllers when screen closes
    _titleController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  // Get user's current GPS location
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    // Get location from provider
    final provider = context.read<LandmarkProvider>();
    final location = await provider.getCurrentLocation();

    // If location found, fill the fields
    if (location != null && mounted) {
      _latController.text = location['lat']!.toStringAsFixed(6);
      _lonController.text = location['lon']!.toStringAsFixed(6);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location detected successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      // If no location, use Bangladesh default
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

  // Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      // Open camera or gallery
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Convert to File
        final file = File(pickedFile.path);

        // Resize image to 800x600
        final resizedImage = await ImageHelper.resizeImage(file);

        // Update the screen with new image
        setState(() {
          _selectedImage = resizedImage;
        });

        // Show success message
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
      // Show error if something goes wrong
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

  // Show dialog to choose camera or gallery
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            // Camera option
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            // Gallery option
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

  // Pick location from map
  Future<void> _pickLocationFromMap() async {
    // Open map picker screen
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

    // If user selected a location
    if (selectedLocation != null && mounted) {
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

  // Submit the form (Add or Update)
  Future<void> _submitForm() async {
    // Validate all fields
    if (!_formKey.currentState!.validate()) {
      return; // Stop if validation fails
    }

    // Get the provider
    final provider = context.read<LandmarkProvider>();

    // Get values from text fields
    final title = _titleController.text.trim();
    final lat = double.parse(_latController.text.trim());
    final lon = double.parse(_lonController.text.trim());

    bool success = false;

    // Check if we're editing or adding
    if (isEditMode) {
      // UPDATE existing landmark
      success = await provider.updateLandmark(
        id: widget.landmark!.id!,
        title: title,
        lat: lat,
        lon: lon,
        imageFile: _selectedImage,
      );
    } else {
      // ADD new landmark
      success = await provider.addLandmark(
        title: title,
        lat: lat,
        lon: lon,
        imageFile: _selectedImage,
      );
    }

    // Show result to user
    if (mounted) {
      if (success) {
        // Success!
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode
                ? 'Landmark updated successfully!'
                : 'Landmark added successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // If adding, clear form and get new location
        if (!isEditMode) {
          _titleController.clear();
          _latController.clear();
          _lonController.clear();
          setState(() {
            _selectedImage = null;
          });
          _getCurrentLocation();
        } else {
          // If editing, go back to previous screen
          Navigator.pop(context, true);
        }
      } else {
        // Failed!
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
    // Watch for changes in provider
    final provider = context.watch<LandmarkProvider>();

    return Scaffold(
      // Top bar
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Landmark' : 'Add New Landmark'),
        actions: [
          // Show GPS button only in add mode
          if (!isEditMode)
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: _isLoadingLocation ? null : _getCurrentLocation,
              tooltip: 'Get Current Location',
            ),
        ],
      ),

      // Body
      body: provider.isLoading
          ? const LoadingIndicator(message: 'Saving...')
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ========== IMAGE SECTION ==========
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: _buildImageDisplay(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to add or change image',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),

              const SizedBox(height: 24),

              // ========== TITLE FIELD ==========
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

              // ========== LATITUDE FIELD ==========
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
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
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

              // ========== LONGITUDE FIELD ==========
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
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
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

              // ========== PICK FROM MAP BUTTON ==========
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

              // ========== SUBMIT BUTTON ==========
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

  // Build the image display widget
  Widget _buildImageDisplay() {
    // If user selected a new image
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(_selectedImage!, fit: BoxFit.cover),
      );
    }

    // If editing and has existing image
    if (isEditMode && widget.landmark!.fullImageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          widget.landmark!.fullImageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => _buildImagePlaceholder(),
        ),
      );
    }

    // Default placeholder
    return _buildImagePlaceholder();
  }

  // Build placeholder when no image
  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 60, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text(
          'Add Image',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      ],
    );
  }
}