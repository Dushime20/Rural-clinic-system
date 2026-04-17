"""
Export Training Data from Database

This script exports patient diagnosis data from your PostgreSQL database
to CSV format for model training.
"""

import pandas as pd
import psycopg2
from psycopg2.extras import RealDictCursor
import os
from dotenv import load_dotenv
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load environment variables from parent directory
load_dotenv('../.env')


def connect_to_database():
    """Connect to PostgreSQL database."""
    try:
        conn = psycopg2.connect(
            host=os.getenv('DB_HOST', 'localhost'),
            port=os.getenv('DB_PORT', '5432'),
            database=os.getenv('DB_NAME', 'health_companion'),
            user=os.getenv('DB_USER', 'postgres'),
            password=os.getenv('DB_PASSWORD', '')
        )
        logger.info("Connected to database successfully")
        return conn
    except Exception as e:
        logger.error(f"Failed to connect to database: {e}")
        raise


def export_diagnosis_data(conn, output_file='data/training_data.csv'):
    """
    Export diagnosis data from database to CSV.
    
    Assumes you have tables:
    - diagnoses: diagnosis records
    - patients: patient information
    """
    
    query = """
    SELECT 
        p.age,
        p.gender,
        d.vital_signs->>'temperature' as temperature,
        d.vital_signs->>'bloodPressureSystolic' as bloodPressureSystolic,
        d.vital_signs->>'bloodPressureDiastolic' as bloodPressureDiastolic,
        d.vital_signs->>'heartRate' as heartRate,
        d.vital_signs->>'respiratoryRate' as respiratoryRate,
        d.vital_signs->>'oxygenSaturation' as oxygenSaturation,
        d.diagnosis_name as diagnosis
    FROM 
        diagnoses d
    JOIN 
        patients p ON d.patient_id = p.id
    WHERE 
        d.diagnosis_name IS NOT NULL
        AND d.is_confirmed = true
    """
    
    try:
        logger.info("Executing query to fetch diagnosis data...")
        df = pd.read_sql_query(query, conn)
        
        logger.info(f"Fetched {len(df)} records from database")
        
        # Convert numeric columns
        numeric_columns = [
            'temperature', 'bloodPressureSystolic', 'bloodPressureDiastolic',
            'heartRate', 'respiratoryRate', 'oxygenSaturation'
        ]
        
        for col in numeric_columns:
            if col in df.columns:
                df[col] = pd.to_numeric(df[col], errors='coerce')
        
        # Remove rows with missing diagnosis
        df = df.dropna(subset=['diagnosis'])
        
        # Save to CSV
        os.makedirs('data', exist_ok=True)
        df.to_csv(output_file, index=False)
        
        logger.info(f"Data exported successfully to {output_file}")
        logger.info(f"Total records: {len(df)}")
        logger.info(f"Unique diagnoses: {df['diagnosis'].nunique()}")
        logger.info(f"\nDisease distribution:\n{df['diagnosis'].value_counts()}")
        
        return df
        
    except Exception as e:
        logger.error(f"Failed to export data: {e}")
        raise


def export_with_symptoms(conn, output_file='data/training_data_with_symptoms.csv'):
    """
    Export diagnosis data including symptoms.
    
    This is more complex as symptoms are typically stored in a separate table
    or as JSON.
    """
    
    query = """
    SELECT 
        p.age,
        p.gender,
        d.vital_signs->>'temperature' as temperature,
        d.vital_signs->>'bloodPressureSystolic' as bloodPressureSystolic,
        d.vital_signs->>'bloodPressureDiastolic' as bloodPressureDiastolic,
        d.vital_signs->>'heartRate' as heartRate,
        d.vital_signs->>'respiratoryRate' as respiratoryRate,
        d.vital_signs->>'oxygenSaturation' as oxygenSaturation,
        d.symptoms as symptoms_json,
        d.diagnosis_name as diagnosis
    FROM 
        diagnoses d
    JOIN 
        patients p ON d.patient_id = p.id
    WHERE 
        d.diagnosis_name IS NOT NULL
        AND d.is_confirmed = true
    """
    
    try:
        logger.info("Executing query to fetch diagnosis data with symptoms...")
        df = pd.read_sql_query(query, conn)
        
        logger.info(f"Fetched {len(df)} records from database")
        
        # Save to CSV
        os.makedirs('data', exist_ok=True)
        df.to_csv(output_file, index=False)
        
        logger.info(f"Data exported successfully to {output_file}")
        
        return df
        
    except Exception as e:
        logger.error(f"Failed to export data: {e}")
        raise


def main():
    """Main export function."""
    logger.info("=" * 80)
    logger.info("Starting Database Export")
    logger.info("=" * 80)
    
    # Connect to database
    conn = connect_to_database()
    
    try:
        # Export basic diagnosis data
        df = export_diagnosis_data(conn, 'data/ddxplus.csv')
        
        logger.info("\n" + "=" * 80)
        logger.info("Export Complete!")
        logger.info("=" * 80)
        logger.info(f"\nNext steps:")
        logger.info("1. Review the exported data: data/ddxplus.csv")
        logger.info("2. Run training: python scripts/train.py")
        logger.info("=" * 80)
        
    finally:
        conn.close()
        logger.info("Database connection closed")


if __name__ == '__main__':
    main()
