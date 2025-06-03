import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controller/fitness_controller.dart';
import '../../model/user_photo_model.dart';

class PhotoCompareScreen extends StatefulWidget {
  const PhotoCompareScreen({Key? key}) : super(key: key);

  @override
  State<PhotoCompareScreen> createState() => _PhotoCompareScreenState();
}

class _PhotoCompareScreenState extends State<PhotoCompareScreen> {
  List<UserPhotoModel> photos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    try {
      final loadedPhotos = await FitnessController().getUserPhotos();
      
      // Sort photos by timestamp in descending order (newest first)
      loadedPhotos.sort((a, b) => 
        (b.timestamp ?? DateTime.now())
            .compareTo(a.timestamp ?? DateTime.now()));

      setState(() {
        // Take only the two most recent photos
        photos = loadedPhotos.take(2).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error loading photos: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading photos: $e')),
        );
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Compare Photos",
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.blackColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Add refresh button
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.blackColor),
            onPressed: _loadPhotos,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : photos.length < 2
              ? const Center(
                  child: Text("Not enough photos to compare",
                      style: TextStyle(fontSize: 16)))
              : Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          // Display second newest photo as "Before"
                          _buildPhotoCard(photos[1], "Before"),
                          Container(
                            width: 2,
                            color: AppColors.primaryColor2.withOpacity(0.3),
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          // Display newest photo as "After"
                          _buildPhotoCard(photos[0], "After"),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor2.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildProgressInfo(
                            "Weight Progress",
                            "${photos[1].weight} kg → ${photos[0].weight} kg",
                            double.parse(photos[0].weight ?? '0') -
                                double.parse(photos[1].weight ?? '0'),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.grayColor.withOpacity(0.3),
                          ),
                          _buildProgressInfo(
                            "BMI Progress",
                            "${photos[1].bmi} → ${photos[0].bmi}",
                            double.parse(photos[0].bmi ?? '0') -
                                double.parse(photos[1].bmi ?? '0'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildPhotoCard(UserPhotoModel photo, String label) {
    String dateStr = photo.timestamp != null 
        ? DateFormat('MMM dd, yyyy').format(photo.timestamp!)
        : 'No date';
    
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor2.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor2.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColors.primaryColor2,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    dateStr,  // Added date display
                    style: TextStyle(
                      color: AppColors.grayColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: photo.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: photo.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error_outline, color: Colors.red),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressInfo(String label, String value, double change) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: AppColors.primaryColor1,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          change >= 0 ? "+${change.toStringAsFixed(1)}" : "${change.toStringAsFixed(1)}",
          style: TextStyle(
            color: change >= 0 ? Colors.green : Colors.red,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}