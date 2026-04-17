"""
Model Evaluator Module

Evaluates trained model performance and generates reports.
"""

import tensorflow as tf
from tensorflow import keras
import numpy as np
from sklearn.metrics import (
    accuracy_score, precision_recall_fscore_support,
    confusion_matrix, classification_report
)
import matplotlib.pyplot as plt
import seaborn as sns
from typing import Dict, List
import logging
import time
import json

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class ModelEvaluator:
    """Evaluates trained model performance."""
    
    def __init__(self, model: keras.Model, config: Dict):
        self.model = model
        self.config = config
        
    def evaluate(
        self,
        X_test: np.ndarray,
        y_test: np.ndarray,
        disease_labels: List[str]
    ) -> Dict:
        """Calculate accuracy, precision, recall, F1-score."""
        logger.info("Evaluating model performance")
        
        # Get predictions
        y_pred_probs = self.model.predict(X_test)
        y_pred = np.argmax(y_pred_probs, axis=1)
        
        # Calculate overall metrics
        accuracy = accuracy_score(y_test, y_pred)
        precision, recall, f1, support = precision_recall_fscore_support(
            y_test, y_pred, average='weighted', zero_division=0
        )
        
        logger.info(f"Overall Accuracy: {accuracy:.4f}")
        logger.info(f"Weighted Precision: {precision:.4f}")
        logger.info(f"Weighted Recall: {recall:.4f}")
        logger.info(f"Weighted F1-Score: {f1:.4f}")
        
        # Calculate per-class metrics
        precision_per_class, recall_per_class, f1_per_class, support_per_class = \
            precision_recall_fscore_support(y_test, y_pred, average=None, zero_division=0)
        
        per_class_metrics = {}
        for i, disease in enumerate(disease_labels):
            per_class_metrics[disease] = {
                'precision': float(precision_per_class[i]),
                'recall': float(recall_per_class[i]),
                'f1_score': float(f1_per_class[i]),
                'support': int(support_per_class[i])
            }
        
        metrics = {
            'overall': {
                'accuracy': float(accuracy),
                'precision': float(precision),
                'recall': float(recall),
                'f1_score': float(f1)
            },
            'per_class': per_class_metrics
        }
        
        return metrics
    
    def generate_confusion_matrix(
        self,
        y_true: np.ndarray,
        y_pred: np.ndarray,
        disease_labels: List[str],
        save_path: str = None
    ) -> np.ndarray:
        """Generate confusion matrix."""
        logger.info("Generating confusion matrix")
        
        # Get predictions if y_pred is probabilities
        if len(y_pred.shape) > 1:
            y_pred = np.argmax(y_pred, axis=1)
        
        cm = confusion_matrix(y_true, y_pred)
        
        # Plot confusion matrix
        if save_path:
            plt.figure(figsize=(12, 10))
            sns.heatmap(
                cm, annot=True, fmt='d', cmap='Blues',
                xticklabels=disease_labels,
                yticklabels=disease_labels
            )
            plt.title('Confusion Matrix')
            plt.ylabel('True Label')
            plt.xlabel('Predicted Label')
            plt.xticks(rotation=45, ha='right')
            plt.yticks(rotation=0)
            plt.tight_layout()
            plt.savefig(save_path)
            plt.close()
            logger.info(f"Confusion matrix saved to {save_path}")
        
        return cm
    
    def measure_inference_time(self, X_sample: np.ndarray, num_runs: int = 100) -> float:
        """Measure average inference time."""
        logger.info(f"Measuring inference time over {num_runs} runs")
        
        # Warm-up run
        _ = self.model.predict(X_sample[:1])
        
        # Measure inference time
        times = []
        for _ in range(num_runs):
            start_time = time.time()
            _ = self.model.predict(X_sample[:1])
            end_time = time.time()
            times.append(end_time - start_time)
        
        avg_time = np.mean(times)
        std_time = np.std(times)
        
        logger.info(f"Average inference time: {avg_time*1000:.2f} ms (±{std_time*1000:.2f} ms)")
        
        return avg_time
    
    def check_model_size(self, model_path: str) -> float:
        """Check model size in MB."""
        import os
        
        total_size = 0
        for dirpath, dirnames, filenames in os.walk(model_path):
            for filename in filenames:
                filepath = os.path.join(dirpath, filename)
                total_size += os.path.getsize(filepath)
        
        size_mb = total_size / (1024 * 1024)
        logger.info(f"Model size: {size_mb:.2f} MB")
        
        return size_mb
    
    def generate_report(
        self,
        metrics: Dict,
        inference_time: float,
        model_size: float,
        output_path: str
    ) -> None:
        """Generate evaluation report with visualizations."""
        logger.info(f"Generating evaluation report: {output_path}")
        
        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <title>Model Evaluation Report</title>
            <style>
                body {{ font-family: Arial, sans-serif; margin: 20px; }}
                h1 {{ color: #333; }}
                h2 {{ color: #666; margin-top: 30px; }}
                table {{ border-collapse: collapse; width: 100%; margin-top: 20px; }}
                th, td {{ border: 1px solid #ddd; padding: 12px; text-align: left; }}
                th {{ background-color: #4CAF50; color: white; }}
                tr:nth-child(even) {{ background-color: #f2f2f2; }}
                .metric {{ font-size: 24px; font-weight: bold; color: #4CAF50; }}
                .warning {{ color: #ff9800; }}
                .error {{ color: #f44336; }}
            </style>
        </head>
        <body>
            <h1>Model Evaluation Report</h1>
            
            <h2>Overall Performance</h2>
            <table>
                <tr>
                    <th>Metric</th>
                    <th>Value</th>
                    <th>Status</th>
                </tr>
                <tr>
                    <td>Accuracy</td>
                    <td class="metric">{metrics['overall']['accuracy']:.4f}</td>
                    <td>{'✓ Pass' if metrics['overall']['accuracy'] >= 0.90 else '✗ Below Target'}</td>
                </tr>
                <tr>
                    <td>Precision</td>
                    <td class="metric">{metrics['overall']['precision']:.4f}</td>
                    <td>✓</td>
                </tr>
                <tr>
                    <td>Recall</td>
                    <td class="metric">{metrics['overall']['recall']:.4f}</td>
                    <td>✓</td>
                </tr>
                <tr>
                    <td>F1-Score</td>
                    <td class="metric">{metrics['overall']['f1_score']:.4f}</td>
                    <td>✓</td>
                </tr>
            </table>
            
            <h2>Model Specifications</h2>
            <table>
                <tr>
                    <th>Specification</th>
                    <th>Value</th>
                    <th>Status</th>
                </tr>
                <tr>
                    <td>Model Size</td>
                    <td>{model_size:.2f} MB</td>
                    <td>{'✓ Pass' if model_size < 50 else '✗ Too Large'}</td>
                </tr>
                <tr>
                    <td>Inference Time</td>
                    <td>{inference_time*1000:.2f} ms</td>
                    <td>{'✓ Pass' if inference_time < 2.0 else '✗ Too Slow'}</td>
                </tr>
            </table>
            
            <h2>Per-Class Performance</h2>
            <table>
                <tr>
                    <th>Disease</th>
                    <th>Precision</th>
                    <th>Recall</th>
                    <th>F1-Score</th>
                    <th>Support</th>
                </tr>
        """
        
        for disease, class_metrics in metrics['per_class'].items():
            html_content += f"""
                <tr>
                    <td>{disease}</td>
                    <td>{class_metrics['precision']:.4f}</td>
                    <td>{class_metrics['recall']:.4f}</td>
                    <td>{class_metrics['f1_score']:.4f}</td>
                    <td>{class_metrics['support']}</td>
                </tr>
            """
        
        html_content += """
            </table>
        </body>
        </html>
        """
        
        with open(output_path, 'w') as f:
            f.write(html_content)
        
        logger.info("Evaluation report generated successfully")
        
        # Check if accuracy is below threshold
        if metrics['overall']['accuracy'] < self.config['evaluation']['min_accuracy']:
            logger.warning(
                f"Model accuracy ({metrics['overall']['accuracy']:.4f}) is below "
                f"minimum threshold ({self.config['evaluation']['min_accuracy']:.4f}). "
                "Consider retraining with different hyperparameters."
            )
