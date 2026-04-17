"""
Data Preprocessor Module

Handles loading and preprocessing of medical datasets (DDXPlus and AfriMedQA).
"""

import pandas as pd
import numpy as np
from typing import Tuple, Dict
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class DataPreprocessor:
    """Handles loading and preprocessing of medical datasets."""
    
    def __init__(self, config: Dict):
        self.config = config
        self.random_seed = config['data']['random_seed']
        
    def load_ddxplus(self, file_path: str) -> pd.DataFrame:
        """Load DDXPlus dataset from CSV."""
        try:
            logger.info(f"Loading DDXPlus dataset from {file_path}")
            df = pd.read_csv(file_path)
            logger.info(f"Loaded {len(df)} records from DDXPlus")
            return df
        except FileNotFoundError:
            logger.error(f"DDXPlus dataset not found at {file_path}")
            raise
        except Exception as e:
            logger.error(f"Error loading DDXPlus dataset: {e}")
            raise
    
    def load_afrimedqa(self, file_path: str) -> pd.DataFrame:
        """Load AfriMedQA dataset from CSV."""
        try:
            logger.info(f"Loading AfriMedQA dataset from {file_path}")
            df = pd.read_csv(file_path)
            logger.info(f"Loaded {len(df)} records from AfriMedQA")
            return df
        except FileNotFoundError:
            logger.warning(f"AfriMedQA dataset not found at {file_path}, skipping")
            return pd.DataFrame()
        except Exception as e:
            logger.error(f"Error loading AfriMedQA dataset: {e}")
            raise
    
    def merge_datasets(self, ddxplus: pd.DataFrame, afrimedqa: pd.DataFrame) -> pd.DataFrame:
        """Merge datasets with consistent schema."""
        if afrimedqa.empty:
            logger.info("AfriMedQA dataset is empty, using only DDXPlus")
            return ddxplus
        
        logger.info("Merging DDXPlus and AfriMedQA datasets")
        
        # Ensure both datasets have the same columns
        common_columns = list(set(ddxplus.columns) & set(afrimedqa.columns))
        
        if not common_columns:
            logger.warning("No common columns found, using only DDXPlus")
            return ddxplus
        
        ddxplus_subset = ddxplus[common_columns]
        afrimedqa_subset = afrimedqa[common_columns]
        
        merged = pd.concat([ddxplus_subset, afrimedqa_subset], ignore_index=True)
        logger.info(f"Merged dataset contains {len(merged)} records")
        
        return merged
    
    def handle_missing_values(self, df: pd.DataFrame) -> pd.DataFrame:
        """Impute missing values using median for vitals, zero for symptoms."""
        logger.info("Handling missing values")
        
        df = df.copy()
        
        # Vital signs columns (use median imputation)
        vital_columns = [
            'temperature', 'bloodPressureSystolic', 'bloodPressureDiastolic',
            'heartRate', 'respiratoryRate', 'oxygenSaturation'
        ]
        
        for col in vital_columns:
            if col in df.columns:
                if df[col].isnull().any():
                    median_value = df[col].median()
                    df[col].fillna(median_value, inplace=True)
                    logger.info(f"Filled {col} missing values with median: {median_value}")
        
        # Symptom columns (use zero-fill)
        symptom_columns = [col for col in df.columns if 'symptom_' in col.lower()]
        for col in symptom_columns:
            if df[col].isnull().any():
                df[col].fillna(0, inplace=True)
                logger.info(f"Filled {col} missing values with 0")
        
        # Age (use median)
        if 'age' in df.columns and df['age'].isnull().any():
            median_age = df['age'].median()
            df['age'].fillna(median_age, inplace=True)
            logger.info(f"Filled age missing values with median: {median_age}")
        
        # Gender (use mode)
        if 'gender' in df.columns and df['gender'].isnull().any():
            mode_gender = df['gender'].mode()[0]
            df['gender'].fillna(mode_gender, inplace=True)
            logger.info(f"Filled gender missing values with mode: {mode_gender}")
        
        return df
    
    def split_data(
        self, 
        df: pd.DataFrame, 
        train_ratio: float = 0.7, 
        val_ratio: float = 0.15
    ) -> Tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
        """Split data into train, validation, and test sets."""
        logger.info(f"Splitting data: train={train_ratio}, val={val_ratio}, test={1-train_ratio-val_ratio}")
        
        # Shuffle the data
        df_shuffled = df.sample(frac=1, random_state=self.random_seed).reset_index(drop=True)
        
        n = len(df_shuffled)
        train_end = int(n * train_ratio)
        val_end = train_end + int(n * val_ratio)
        
        train_df = df_shuffled[:train_end]
        val_df = df_shuffled[train_end:val_end]
        test_df = df_shuffled[val_end:]
        
        logger.info(f"Train set: {len(train_df)} records")
        logger.info(f"Validation set: {len(val_df)} records")
        logger.info(f"Test set: {len(test_df)} records")
        
        # Verify no overlap
        assert len(set(train_df.index) & set(val_df.index)) == 0, "Train and val sets overlap"
        assert len(set(train_df.index) & set(test_df.index)) == 0, "Train and test sets overlap"
        assert len(set(val_df.index) & set(test_df.index)) == 0, "Val and test sets overlap"
        
        return train_df, val_df, test_df
    
    def validate_data(self, df: pd.DataFrame) -> bool:
        """Validate data quality and required columns."""
        logger.info("Validating data quality")
        
        required_columns = ['age', 'gender', 'diagnosis']
        missing_columns = [col for col in required_columns if col not in df.columns]
        
        if missing_columns:
            logger.error(f"Missing required columns: {missing_columns}")
            return False
        
        # Check for invalid age values
        if 'age' in df.columns:
            invalid_ages = df[(df['age'] < 0) | (df['age'] > 120)]
            if len(invalid_ages) > 0:
                logger.warning(f"Found {len(invalid_ages)} records with invalid age values")
        
        # Check for missing diagnosis
        if 'diagnosis' in df.columns:
            missing_diagnosis = df[df['diagnosis'].isnull()]
            if len(missing_diagnosis) > 0:
                logger.error(f"Found {len(missing_diagnosis)} records with missing diagnosis")
                return False
        
        logger.info("Data validation passed")
        return True
