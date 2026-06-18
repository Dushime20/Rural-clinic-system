import 'reflect-metadata';
import { AppDataSource } from '../src/database/data-source';
import { Pharmacy } from '../src/models/Pharmacy';
import { PharmacyMedicine } from '../src/models/PharmacyMedicine';
import * as fs from 'fs';
import * as path from 'path';

/**
 * Script to populate all 3 pharmacies with medicines that the diagnosis model can predict
 * Medicines are distributed evenly across pharmacies with varied pricing and stock
 */

interface MedicationData {
  Disease: string;
  Medication: string;
}

// Parse medication string (it's stored as string representation of array)
function parseMedicationString(medStr: string): string[] {
  try {
    // Remove brackets, quotes, and extra whitespace
    const cleaned = medStr
      .replace(/[\[\]'"]+/g, '') // Remove brackets and all types of quotes
      .trim();
    
    return cleaned
      .split(',')
      .map(m => m.trim())
      .filter(m => m.length > 0);
  } catch (error) {
    console.error('Error parsing medication string:', medStr, error);
    return [];
  }
}

// Generate random price for medicine (between 500 and 50000 RWF)
function generatePrice(medicationName: string): number {
  // Common medicines are cheaper
  const commonMedicines = ['Antibiotics', 'Antihistamines', 'Pain relievers', 'Antipyretics', 'Analgesics'];
  const isCommon = commonMedicines.some(common => medicationName.includes(common));
  
  if (isCommon) {
    return Math.floor(Math.random() * (5000 - 500) + 500); // 500-5000 RWF
  } else {
    return Math.floor(Math.random() * (50000 - 2000) + 2000); // 2000-50000 RWF
  }
}

// Generate random stock quantity
function generateStock(): number {
  return Math.floor(Math.random() * (500 - 10) + 10); // 10-500 units
}

// Categorize medicine type
function categorizeMedicine(medicationName: string): string {
  if (medicationName.includes('Antibiotic')) return 'Antibiotic';
  if (medicationName.includes('Antiviral')) return 'Antiviral';
  if (medicationName.includes('Antifungal')) return 'Antifungal';
  if (medicationName.includes('Pain') || medicationName.includes('Analgesic')) return 'Pain Relief';
  if (medicationName.includes('Antipyretic')) return 'Fever Reducer';
  if (medicationName.includes('Antihistamine')) return 'Allergy';
  if (medicationName.includes('Corticosteroid')) return 'Steroid';
  if (medicationName.includes('IV') || medicationName.includes('Intravenous')) return 'IV Therapy';
  if (medicationName.includes('Insulin')) return 'Diabetes';
  if (medicationName.includes('Hypertension') || medicationName.includes('Blood pressure')) return 'Cardiovascular';
  return 'General';
}

// Determine medicine form
function determineMedicineForm(medicationName: string): string {
  if (medicationName.includes('Cream') || medicationName.includes('Topical')) return 'Cream';
  if (medicationName.includes('Injection') || medicationName.includes('IV')) return 'Injection';
  if (medicationName.includes('Syrup')) return 'Syrup';
  if (medicationName.includes('Inhaler') || medicationName.includes('Inhaled')) return 'Inhaler';
  if (medicationName.includes('Spray')) return 'Spray';
  return 'Tablet';
}

async function populatePharmacyMedicines() {
  try {
    console.log('Connecting to database...');
    await AppDataSource.initialize();
    console.log('Database connected!');

    // Get all pharmacies
    const pharmacyRepo = AppDataSource.getRepository(Pharmacy);
    const pharmacies = await pharmacyRepo.find({
      where: { isActive: true },
      order: { createdAt: 'ASC' },
      take: 3
    });

    if (pharmacies.length === 0) {
      console.error('No pharmacies found! Please create pharmacies first.');
      process.exit(1);
    }

    console.log(`Found ${pharmacies.length} pharmacies:`);
    pharmacies.forEach((p, i) => {
      console.log(`  ${i + 1}. ${p.name} (ID: ${p.id})`);
    });

    // Read medications CSV
    const csvPath = path.join(__dirname, '../model-training/dataset/medications.csv');
    console.log(`\nReading medications from: ${csvPath}`);
    
    const csvContent = fs.readFileSync(csvPath, 'utf-8');
    const lines = csvContent.split('\n').filter(line => line.trim().length > 0);
    
    // Skip header
    const dataLines = lines.slice(1);
    
    // Collect all unique medications
    const allMedicationsSet = new Set<string>();
    
    for (const line of dataLines) {
      const parts = line.split(',');
      if (parts.length >= 2) {
        const medicationStr = parts.slice(1).join(','); // In case medication has commas
        const medications = parseMedicationString(medicationStr);
        medications.forEach(med => allMedicationsSet.add(med));
      }
    }

    const allMedications = Array.from(allMedicationsSet);
    console.log(`\nFound ${allMedications.length} unique medications`);

    // Distribute medicines across pharmacies
    const medicineRepo = AppDataSource.getRepository(PharmacyMedicine);
    
    // Clear existing medicines for these pharmacies
    console.log('\nClearing existing medicines...');
    const pharmacyIds = pharmacies.map(p => p.id);
    const existingMedicines = await medicineRepo.find({
      where: pharmacyIds.map(id => ({ pharmacyId: id }))
    });
    
    if (existingMedicines.length > 0) {
      await medicineRepo.remove(existingMedicines);
      console.log(`  Removed ${existingMedicines.length} existing medicines`);
    } else {
      console.log('  No existing medicines to remove');
    }
    
    console.log('\nDistributing medicines to pharmacies...');
    
    let totalAdded = 0;
    
    // Each pharmacy gets all medicines but with different prices and stock
    for (let i = 0; i < pharmacies.length; i++) {
      const pharmacy = pharmacies[i];
      console.log(`\nAdding medicines to ${pharmacy.name}...`);
      
      let addedCount = 0;
      
      for (const medication of allMedications) {
        // Random chance (80%) that this pharmacy has this medicine in stock
        const hasInStock = Math.random() > 0.2;
        
        const medicine = new PharmacyMedicine();
        medicine.pharmacyId = pharmacy.id;
        medicine.medicationName = medication;
        medicine.price = generatePrice(medication);
        medicine.currency = 'RWF';
        medicine.stockQuantity = hasInStock ? generateStock() : 0;
        medicine.isAvailable = hasInStock;
        medicine.category = categorizeMedicine(medication);
        medicine.form = determineMedicineForm(medication);
        medicine.notes = `For treating various conditions. Consult healthcare provider.`;
        
        await medicineRepo.save(medicine);
        addedCount++;
      }
      
      console.log(`  ✓ Added ${addedCount} medicines`);
      totalAdded += addedCount;
    }

    console.log(`\n✅ Successfully added ${totalAdded} medicine entries across ${pharmacies.length} pharmacies!`);
    
    // Display summary statistics
    console.log('\n📊 Summary by Pharmacy:');
    for (const pharmacy of pharmacies) {
      const medicines = await medicineRepo.find({
        where: { pharmacyId: pharmacy.id }
      });
      
      const inStock = medicines.filter(m => m.isAvailable).length;
      const outOfStock = medicines.filter(m => !m.isAvailable).length;
      const avgPrice = medicines.reduce((sum, m) => sum + Number(m.price), 0) / medicines.length;
      
      console.log(`\n${pharmacy.name}:`);
      console.log(`  Total medicines: ${medicines.length}`);
      console.log(`  In stock: ${inStock}`);
      console.log(`  Out of stock: ${outOfStock}`);
      console.log(`  Average price: ${avgPrice.toFixed(0)} RWF`);
    }

    console.log('\n🎉 Medicine population completed successfully!');
    
  } catch (error) {
    console.error('Error populating pharmacy medicines:', error);
    throw error;
  } finally {
    if (AppDataSource.isInitialized) {
      await AppDataSource.destroy();
    }
  }
}

// Run the script
populatePharmacyMedicines()
  .then(() => {
    console.log('\nScript finished successfully');
    process.exit(0);
  })
  .catch((error) => {
    console.error('\nScript failed:', error);
    process.exit(1);
  });
