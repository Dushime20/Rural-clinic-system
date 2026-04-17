"""
Model Trainer Module

Trains neural network model for disease prediction.
"""

import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, callbacks
import numpy as np
from typing import Dict, Tuple
import logging
import json
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class ModelTrainer:
    """Trains neural network model for disease prediction."""
    
    def __init__(self, input_dim: int, num_classes: int, config: Dict):
        self.input_dim = input_dim
        self.num_classes = num_classes
        self.config = config
        self.model = None
        self.history = None
        
    def build_model(self) -> keras.Model:
        """Build feedforward neural network architecture."""
        logger.info(f"Building model: input_dim={self.input_dim}, num_classes={self.num_classes}")
        
        model = keras.Sequential()
        model.add(layers.Input(shape=(self.input_dim,)))
        
        # Build layers from config
        for layer_config in self.config['model']['architecture']:
            if layer_config['type'] == 'dense':
                model.add(layers.Dense(
                    units=layer_config['units'],
                    activation=layer_config['activation']
                ))
            elif layer_config['type'] == 'dropout':
                model.add(layers.Dropout(rate=layer_config['rate']))
        
        # Output layer
        model.add(layers.Dense(
            units=self.num_classes,
            activation=self.config['model']['output_activation']
        ))
        
        # Compile model
        optimizer = keras.optimizers.Adam(
            learning_rate=self.config['model']['learning_rate']
        )
        
        model.compile(
            optimizer=optimizer,
            loss=self.config['model']['loss'],
            metrics=self.config['model']['metrics']
        )
        
        logger.info("Model architecture:")
        model.summary(print_fn=logger.info)
        
        self.model = model
        return model
    
    def train(
        self,
        X_train: np.ndarray,
        y_train: np.ndarray,
        X_val: np.ndarray,
        y_val: np.ndarray
    ) -> keras.callbacks.History:
        """Train model with early stopping and checkpointing."""
        logger.info("Starting model training")
        
        if self.model is None:
            self.build_model()
        
        # Convert labels to categorical
        y_train_cat = keras.utils.to_categorical(y_train, num_classes=self.num_classes)
        y_val_cat = keras.utils.to_categorical(y_val, num_classes=self.num_classes)
        
        # Setup callbacks
        callback_list = [
            callbacks.EarlyStopping(
                monitor='val_loss',
                patience=self.config['training']['early_stopping_patience'],
                restore_best_weights=True,
                verbose=1
            ),
            callbacks.ReduceLROnPlateau(
                monitor='val_loss',
                factor=self.config['training']['reduce_lr_factor'],
                patience=self.config['training']['reduce_lr_patience'],
                min_lr=self.config['training']['min_lr'],
                verbose=1
            ),
            callbacks.ModelCheckpoint(
                filepath='models/checkpoint.keras',
                monitor='val_accuracy',
                save_best_only=True,
                verbose=1
            )
        ]
        
        # Train model
        history = self.model.fit(
            X_train, y_train_cat,
            validation_data=(X_val, y_val_cat),
            batch_size=self.config['training']['batch_size'],
            epochs=self.config['training']['epochs'],
            callbacks=callback_list,
            verbose=1
        )
        
        self.history = history
        logger.info("Training completed")
        
        return history
    
    def save_model(self, path: str) -> None:
        """Save model in TensorFlow SavedModel format."""
        if self.model is None:
            raise ValueError("No model to save. Train the model first.")
        
        logger.info(f"Saving model to {path}")
        os.makedirs(path, exist_ok=True)
        self.model.save(path)
        logger.info("Model saved successfully")
    
    def save_training_history(self, path: str) -> None:
        """Save training history to JSON file."""
        if self.history is None:
            logger.warning("No training history to save")
            return
        
        logger.info(f"Saving training history to {path}")
        
        history_dict = {
            'loss': [float(x) for x in self.history.history['loss']],
            'accuracy': [float(x) for x in self.history.history['accuracy']],
            'val_loss': [float(x) for x in self.history.history['val_loss']],
            'val_accuracy': [float(x) for x in self.history.history['val_accuracy']]
        }
        
        with open(path, 'w') as f:
            json.dump(history_dict, f, indent=2)
        
        logger.info("Training history saved successfully")
    
    def get_model_size(self, path: str) -> float:
        """Get model size in MB."""
        total_size = 0
        for dirpath, dirnames, filenames in os.walk(path):
            for filename in filenames:
                filepath = os.path.join(dirpath, filename)
                total_size += os.path.getsize(filepath)
        
        size_mb = total_size / (1024 * 1024)
        logger.info(f"Model size: {size_mb:.2f} MB")
        return size_mb
