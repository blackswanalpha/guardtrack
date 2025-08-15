import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../bloc/check_in_bloc.dart';
import '../widgets/location_status_card.dart';
import '../widgets/site_selection_card.dart';
import '../widgets/check_in_button.dart';
import '../widgets/photo_capture_widget.dart';

class CheckInPage extends StatefulWidget {
  final UserModel user;

  const CheckInPage({
    super.key,
    required this.user,
  });

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  @override
  void initState() {
    super.initState();
    // Initialize location tracking and load user sites
    context.read<CheckInBloc>().add(CheckInInitialized(widget.user.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Check-in'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<CheckInBloc, CheckInState>(
        listener: (context, state) {
          if (state is CheckInError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.errorRed,
              ),
            );
          } else if (state is CheckInSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Check-in successful! Code: ${state.arrivalCode}'),
                backgroundColor: AppColors.successGreen,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  context.read<CheckInBloc>().add(CheckInRefreshed());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location Status Card
                      LocationStatusCard(
                        currentPosition: state.currentPosition,
                        locationAccuracy: state.locationAccuracy,
                        isLocationEnabled: state.isLocationEnabled,
                        onRefreshLocation: () {
                          context.read<CheckInBloc>().add(LocationRefreshed());
                        },
                      ),

                      const SizedBox(height: 16),

                      // Site Selection
                      Text(
                        'Select Site',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.textDark,
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (state.assignedSites.isEmpty)
                        _buildNoSitesCard()
                      else
                        ...state.assignedSites.map((site) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: SiteSelectionCard(
                                site: site,
                                currentPosition: state.currentPosition,
                                isSelected: state.selectedSite?.id == site.id,
                                onTap: () {
                                  context
                                      .read<CheckInBloc>()
                                      .add(SiteSelected(site));
                                },
                              ),
                            )),

                      const SizedBox(height: 24),

                      // Photo Capture Section
                      if (state.selectedSite != null &&
                          state.requiresPhoto) ...[
                        Text(
                          'Photo Verification',
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        PhotoCaptureWidget(
                          onPhotoTaken: (photo) {
                            // Handle photo capture - this would update the bloc state
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Photo captured successfully!'),
                                backgroundColor: AppColors.successGreen,
                              ),
                            );
                          },
                          existingPhotoPath: state.capturedPhoto?.path,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Check-in Button
                      if (state.selectedSite != null)
                        CheckInButton(
                          site: state.selectedSite!,
                          currentPosition: state.currentPosition,
                          isLoading: state is CheckInLoading,
                          onCheckIn: () {
                            if (state.requiresPhoto &&
                                state.capturedPhoto == null) {
                              context.read<CheckInBloc>().add(
                                    PhotoCaptureRequested(
                                      siteId: state.selectedSite!.id,
                                      guardId: widget.user.id,
                                    ),
                                  );
                            } else {
                              context.read<CheckInBloc>().add(
                                    CheckInRequested(
                                      siteId: state.selectedSite!.id,
                                      guardId: widget.user.id,
                                    ),
                                  );
                            }
                          },
                          onCheckOut: () {
                            context.read<CheckInBloc>().add(
                                  CheckOutRequested(
                                    siteId: state.selectedSite!.id,
                                    guardId: widget.user.id,
                                  ),
                                );
                          },
                        ),

                      const SizedBox(
                          height: 100), // Bottom padding for navigation
                    ],
                  ),
                ),
              ),

              // Loading overlay
              if (state is CheckInLoading)
                const LoadingOverlay(message: 'Processing...'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNoSitesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_off,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'No Sites Assigned',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Contact your supervisor to get assigned to security sites.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
