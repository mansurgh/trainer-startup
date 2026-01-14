// =============================================================================
// muscle_assets_map.dart — SVG Asset Path Mapping
// =============================================================================
// Maps MuscleId enum values to their corresponding SVG asset paths.
// Handles:
// - Male/Female gender variants
// - Left/Right symmetry for limbs
// - Defensive fallbacks for missing assets
// =============================================================================

import 'muscle_heatmap_widget.dart' show MuscleId, BodyGender;

/// Static class for mapping MuscleId to SVG asset paths
class MuscleAssets {
  MuscleAssets._(); // Prevent instantiation

  // ===========================================================================
  // ASSET BASE PATHS
  // ===========================================================================
  // NOTE: Male assets are in the ROOT folder (assets/muscles/)
  //       Female assets are in the subfolder (assets/muscles/female/)
  //       The male/ subfolder only contains detailed parts (head, hands, feet)
  
  static const String _malePath = 'assets/muscles';         // ROOT folder for male
  static const String _femalePath = 'assets/muscles/female'; // Subfolder for female
  
  // ===========================================================================
  // AVAILABLE ASSETS (what we actually have)
  // ===========================================================================
  
  /// Assets available in the main (male) folder
  static const Set<String> _availableMaleAssets = {
    'abs.svg',
    'arms.svg',
    'back.svg',
    'body_back.svg',
    'body_front.svg',
    'chest.svg',
    'glutes.svg',
    'legs.svg',
    'shoulders.svg',
    'traps.svg',
  };
  
  /// Assets available in the female folder
  static const Set<String> _availableFemaleAssets = {
    'abs.svg',
    'arms.svg',
    'back.svg',
    'body_back.svg',
    'body_front.svg',
    'chest.svg',
    'glutes.svg',
    'legs.svg',
    'shoulders.svg',
    'traps.svg',
  };
  
  // ===========================================================================
  // MUSCLE TO ASSET MAPPING
  // ===========================================================================
  
  /// Maps MuscleId to the primary asset filename(s)
  /// Returns a List because some muscles have left/right variants
  static List<String> getAssetFilenames(MuscleId muscleId) {
    switch (muscleId) {
      // Torso - single assets
      case MuscleId.chest:
        return ['chest.svg'];
      case MuscleId.abs:
        return ['abs.svg'];
      case MuscleId.back:
        return ['back.svg'];
      case MuscleId.traps:
        return ['traps.svg'];
      case MuscleId.shoulders:
        return ['shoulders.svg'];
      case MuscleId.glutes:
        return ['glutes.svg'];
        
      // Arms - use combined 'arms.svg' (includes biceps, triceps, forearms)
      case MuscleId.biceps:
        return ['arms.svg'];
      case MuscleId.triceps:
        return ['arms.svg'];
      case MuscleId.forearms:
        return ['arms.svg'];
      case MuscleId.lats:
        return ['back.svg']; // Lats are part of back
        
      // Legs - use combined 'legs.svg'
      case MuscleId.quadriceps:
        return ['legs.svg'];
      case MuscleId.hamstrings:
        return ['legs.svg'];
      case MuscleId.calves:
        return ['legs.svg'];
    }
  }
  
  /// Get the full asset path for a muscle
  static String getAssetPath(MuscleId muscleId, BodyGender gender) {
    final basePath = gender == BodyGender.female ? _femalePath : _malePath;
    final filenames = getAssetFilenames(muscleId);
    
    // Return the first available filename
    return '$basePath/${filenames.first}';
  }
  
  /// Get all asset paths for a muscle (for muscles with left/right variants)
  static List<String> getAllAssetPaths(MuscleId muscleId, BodyGender gender) {
    final basePath = gender == BodyGender.female ? _femalePath : _malePath;
    final filenames = getAssetFilenames(muscleId);
    
    return filenames.map((f) => '$basePath/$f').toList();
  }
  
  /// Check if an asset exists for the given muscle
  static bool hasAsset(MuscleId muscleId, BodyGender gender) {
    final filenames = getAssetFilenames(muscleId);
    final availableAssets = gender == BodyGender.female 
        ? _availableFemaleAssets 
        : _availableMaleAssets;
    
    return filenames.any((f) => availableAssets.contains(f));
  }
  
  /// Get body silhouette asset path
  static String getBodySilhouettePath(BodyGender gender, {required bool isFront}) {
    final basePath = gender == BodyGender.female ? _femalePath : _malePath;
    return '$basePath/${isFront ? 'body_front.svg' : 'body_back.svg'}';
  }
  
  // ===========================================================================
  // MUSCLE GROUPS BY VIEW
  // ===========================================================================
  
  /// Muscles visible from the front
  static const List<MuscleId> frontMuscles = [
    MuscleId.chest,
    MuscleId.abs,
    MuscleId.shoulders,
    MuscleId.biceps,
    MuscleId.forearms,
    MuscleId.quadriceps,
  ];
  
  /// Muscles visible from the back
  static const List<MuscleId> backMuscles = [
    MuscleId.back,
    MuscleId.traps,
    MuscleId.triceps,
    MuscleId.lats,
    MuscleId.glutes,
    MuscleId.hamstrings,
    MuscleId.calves,
  ];
  
  /// All defined muscles
  static const List<MuscleId> allMuscles = MuscleId.values;
  
  // ===========================================================================
  // UNIQUE ASSET DEDUPLICATION
  // ===========================================================================
  
  /// Get unique asset paths for a list of muscles (avoids rendering same SVG twice)
  /// Returns Map of asset path to list of MuscleIds that use it
  static Map<String, List<MuscleId>> getUniqueAssets(
    List<MuscleId> muscles, 
    BodyGender gender,
  ) {
    final Map<String, List<MuscleId>> assetToMuscles = {};
    
    for (final muscleId in muscles) {
      final path = getAssetPath(muscleId, gender);
      assetToMuscles.putIfAbsent(path, () => []).add(muscleId);
    }
    
    return assetToMuscles;
  }
  
  /// Get the maximum fatigue level for muscles sharing the same asset
  static double getMaxFatigueForAsset(
    String assetPath,
    Map<String, List<MuscleId>> assetMap,
    Map<MuscleId, double> fatigueMap,
  ) {
    final musclesUsingAsset = assetMap[assetPath] ?? [];
    double maxFatigue = 0.0;
    
    for (final muscleId in musclesUsingAsset) {
      final fatigue = fatigueMap[muscleId] ?? 0.0;
      if (fatigue > maxFatigue) maxFatigue = fatigue;
    }
    
    return maxFatigue;
  }
}
