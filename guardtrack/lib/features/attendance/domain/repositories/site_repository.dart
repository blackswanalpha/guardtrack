import '../../../../shared/models/site_model.dart';

abstract class SiteRepository {
  /// Get all sites assigned to a specific guard
  Future<List<SiteModel>> getAssignedSites(String guardId);

  /// Get site details by ID
  Future<SiteModel?> getSiteById(String siteId);

  /// Get all sites (for admin users)
  Future<List<SiteModel>> getAllSites();

  /// Update site information
  Future<void> updateSite(SiteModel site);

  /// Check if guard is assigned to a specific site
  Future<bool> isGuardAssignedToSite(String guardId, String siteId);
}

class SiteRepositoryImpl implements SiteRepository {
  // Mock implementation for now - replace with actual API calls

  @override
  Future<List<SiteModel>> getAssignedSites(String guardId) async {
    // Mock data - replace with actual API call
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      SiteModel(
        id: 'site_1',
        name: 'Downtown Office Complex',
        address: '123 Business Ave, Downtown',
        latitude: -1.2921,
        longitude: 36.8219,
        allowedRadius: 100.0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        description: 'Main office complex requiring 24/7 security',
        contactPhone: '+254700123456',
        emergencyContact: '+254700654321',
        shiftStartTime: '08:00',
        shiftEndTime: '18:00',
        specialInstructions: 'Check all entry points every 2 hours',
      ),
      SiteModel(
        id: 'site_2',
        name: 'Westlands Shopping Mall',
        address: '456 Mall Road, Westlands',
        latitude: -1.2634,
        longitude: 36.8047,
        allowedRadius: 150.0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        description: 'Large shopping mall with multiple entry points',
        contactPhone: '+254700789012',
        emergencyContact: '+254700210987',
        shiftStartTime: '06:00',
        shiftEndTime: '22:00',
        specialInstructions: 'Monitor parking areas and main entrances',
      ),
    ];
  }

  @override
  Future<SiteModel?> getSiteById(String siteId) async {
    final sites = await getAssignedSites(''); // Get all sites for now
    return sites.firstWhere(
      (site) => site.id == siteId,
      orElse: () => throw Exception('Site not found'),
    );
  }

  @override
  Future<List<SiteModel>> getAllSites() async {
    return getAssignedSites(''); // Return all sites for now
  }

  @override
  Future<void> updateSite(SiteModel site) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<bool> isGuardAssignedToSite(String guardId, String siteId) async {
    final assignedSites = await getAssignedSites(guardId);
    return assignedSites.any((site) => site.id == siteId);
  }
}
