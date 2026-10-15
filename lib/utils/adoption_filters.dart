import '../models/adoption_listing.dart';

enum AdoptionAgeFilter { any, young, adult, senior }

List<AdoptionListing> filterAdoptionListings({
  required List<AdoptionListing> listings,
  required String type,
  required AdoptionAgeFilter age,
  required String location,
}) {
  final place = location.trim().toLowerCase();
  return listings.where((listing) {
    final matchesType = type == 'todos' || listing.type == type;
    final matchesAge = switch (age) {
      AdoptionAgeFilter.any => true,
      AdoptionAgeFilter.young => listing.ageYears <= 1,
      AdoptionAgeFilter.adult => listing.ageYears >= 2 && listing.ageYears <= 5,
      AdoptionAgeFilter.senior => listing.ageYears >= 6,
    };
    final matchesLocation =
        place.isEmpty || listing.location.toLowerCase().contains(place);
    return matchesType && matchesAge && matchesLocation;
  }).toList();
}
