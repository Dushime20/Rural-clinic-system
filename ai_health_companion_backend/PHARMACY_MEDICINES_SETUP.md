# Pharmacy Medicines Population Guide

## Overview
This script populates all 3 pharmacies with medicines that the AI diagnosis model can predict. The medicines are extracted from the diagnosis model's medication dataset and distributed across pharmacies with realistic pricing and stock levels.

## What It Does

1. **Reads Medication Data**: Extracts all unique medicines from `model-training/dataset/medications.csv`
2. **Distributes to Pharmacies**: Adds all medicines to each of the 3 pharmacies
3. **Varied Availability**: Each pharmacy has ~80% of medicines in stock (randomly determined)
4. **Realistic Pricing**: Generates prices based on medicine type (500-50,000 RWF)
5. **Stock Quantities**: Random stock levels (10-500 units)
6. **Categorization**: Automatically categorizes medicines by type
7. **Medicine Forms**: Determines form (tablet, injection, cream, etc.)

## Medicine Categories

The script automatically categorizes medicines into:
- **Antibiotic** - Bacterial infections
- **Antiviral** - Viral infections
- **Antifungal** - Fungal infections
- **Pain Relief** - Analgesics and pain relievers
- **Fever Reducer** - Antipyretics
- **Allergy** - Antihistamines
- **Steroid** - Corticosteroids
- **IV Therapy** - Intravenous medications
- **Diabetes** - Insulin and diabetes medications
- **Cardiovascular** - Heart and blood pressure medications
- **General** - Other medicines

## Pricing Strategy

- **Common medicines** (Antibiotics, Antihistamines, Pain relievers): 500-5,000 RWF
- **Specialized medicines**: 2,000-50,000 RWF
- Prices vary between pharmacies to simulate market competition

## How to Run

### Prerequisites
- Database must be running and initialized
- At least 3 active pharmacies must exist in the database
- TypeScript and ts-node must be installed

### Running the Script

```bash
# From the backend directory
cd ai_health_companion_backend

# Run the script
npx ts-node scripts/populate-pharmacy-medicines.ts
```

### Expected Output

```
Connecting to database...
Database connected!
Found 3 pharmacies:
  1. Kigali Central Pharmacy (ID: xxx)
  2. Gasabo District Pharmacy (ID: xxx)
  3. Nyarugenge Health Pharmacy (ID: xxx)

Reading medications from: /path/to/medications.csv

Found 186 unique medications

Clearing existing medicines...

Distributing medicines to pharmacies...

Adding medicines to Kigali Central Pharmacy...
  ✓ Added 186 medicines

Adding medicines to Gasabo District Pharmacy...
  ✓ Added 186 medicines

Adding medicines to Nyarugenge Health Pharmacy...
  ✓ Added 186 medicines

✅ Successfully added 558 medicine entries across 3 pharmacies!

📊 Summary by Pharmacy:

Kigali Central Pharmacy:
  Total medicines: 186
  In stock: 149
  Out of stock: 37
  Average price: 15234 RWF

Gasabo District Pharmacy:
  Total medicines: 186
  In stock: 152
  Out of stock: 34
  Average price: 14987 RWF

Nyarugenge Health Pharmacy:
  Total medicines: 186
  In stock: 148
  Out of stock: 38
  Average price: 15456 RWF

🎉 Medicine population completed successfully!

Script finished successfully
```

## Data Source

The medicines are sourced from the AI diagnosis model's dataset:
- **File**: `model-training/dataset/medications.csv`
- **Diseases**: 41 diseases
- **Medications**: ~186 unique medicines

### Sample Diseases Covered
- Fungal infection
- Allergy
- GERD
- Diabetes
- Gastroenteritis
- Bronchial Asthma
- Hypertension
- Migraine
- Malaria
- Chicken pox
- Dengue
- Typhoid
- Hepatitis (A, B, C, D, E)
- Tuberculosis
- Common Cold
- Pneumonia
- Heart attack
- Arthritis
- Urinary tract infection
- And more...

## Medicine Examples

Each pharmacy will have medicines like:
- Antifungal Cream, Fluconazole, Terbinafine (for fungal infections)
- Antihistamines, Decongestants, Epinephrine (for allergies)
- Insulin, Metformin, Sulfonylureas (for diabetes)
- Antibiotics, H2 Blockers, Antacids (for GERD and ulcers)
- Antimalarial drugs, Antipyretics (for malaria)
- Bronchodilators, Inhaled corticosteroids (for asthma)
- And many more...

## Database Schema

Each medicine entry includes:
- `medicationName` - Name of the medication
- `genericName` - Generic name (nullable)
- `brandName` - Brand name (nullable)
- `strength` - Dosage strength (nullable)
- `form` - Tablet, Injection, Cream, etc.
- `category` - Medicine category
- `price` - Price in RWF
- `currency` - Currency (RWF)
- `stockQuantity` - Number of units in stock
- `isAvailable` - Boolean availability status
- `notes` - Additional information

## Re-running the Script

The script can be run multiple times. Each run will:
1. Clear all existing medicines from all pharmacies
2. Re-populate with fresh data and new random prices/stock levels

## Troubleshooting

### Error: No pharmacies found
- Ensure you have created at least 3 pharmacies in the database
- Check that pharmacies are marked as `isActive = true`

### Error: Cannot read medications.csv
- Verify the file exists at `model-training/dataset/medications.csv`
- Check file permissions

### Database connection error
- Ensure PostgreSQL is running
- Verify `.env` file has correct database credentials
- Check that database exists and is accessible

## Next Steps

After populating medicines:
1. **Verify in Admin Dashboard**: Check pharmacy medicine listings
2. **Test Pharmacy Dashboard**: Login as pharmacist to view inventory
3. **Update Prices**: Pharmacists can update prices through their dashboard
4. **Manage Stock**: Pharmacists can update stock quantities
5. **Add Custom Medicines**: Pharmacists can add additional medicines not in the model

## Integration with Diagnosis System

When the AI model makes a diagnosis:
1. It suggests medications based on the predicted disease
2. The system searches pharmacies for those medications
3. Displays available pharmacies with prices
4. Shows stock availability status
5. Provides GPS locations for navigation

## Maintenance

Pharmacy managers can:
- Update medicine prices
- Adjust stock quantities
- Mark medicines as available/unavailable
- Add notes about specific medicines
- Add new medicines not in the original dataset
