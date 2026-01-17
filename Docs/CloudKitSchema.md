# CloudKit Schema (Draft)

Container ID: iCloud.com.ganesh47.yatrai-planner

## Record Types

### Trip
- recordType: Trip
- Fields:
  - tripId (String, UUID)
  - startCity (String)
  - endCity (String)
  - startDate (Date)
  - endDate (Date)
  - vehicleName (String)
  - fuelType (String)
  - mileageKmPerLiter (Double)
  - fuelPricePerLiter (Double)
  - maxKmPerDay (Int)
  - avoidNightDriving (Bool)
  - breakEveryHours (Int)
  - breakDurationMinutes (Int)
  - adults (Int)
  - kids (Data, JSON array)
  - foodType (String)
  - dailyFoodBudget (Int)
  - lodgingBudget (Int)
  - isProUser (Bool)

### Milestone
- recordType: Milestone
- Fields:
  - milestoneId (String, UUID)
  - tripId (Reference -> Trip)
  - type (String)
  - name (String)
  - mustDo (Bool)
  - timeWindowStart (Date, optional)
  - timeWindowEnd (Date, optional)
  - notes (String, optional)
  - sortOrder (Int)

### Itinerary
- recordType: Itinerary
- Fields:
  - itineraryId (String, UUID)
  - tripId (Reference -> Trip)
  - source (String: deterministic|aiDraft)
  - days (Data, JSON array)
  - lastUpdated (Date)

### Costs
- recordType: Costs
- Fields:
  - costsId (String, UUID)
  - tripId (Reference -> Trip)
  - fuelCost (Double)
  - foodCost (Double)
  - lodgingCost (Double)
  - totalCost (Double)

### Checklist
- recordType: Checklist
- Fields:
  - checklistId (String, UUID)
  - tripId (Reference -> Trip)
  - title (String)
  - items (Data, JSON array)
  - sortOrder (Int)

## Notes
- Conflict handling: last-write-wins for most fields; milestone order uses client-side merge.
- Schema versioning: add new fields as optional, keep backward compatible.
