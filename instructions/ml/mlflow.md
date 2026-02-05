# MLflow Experiment Tracking

## Requirements

Every experiment MUST be logged to MLflow with:
- All hyperparameters
- All metrics
- Model artifact
- Feature importance visualization
- Confusion matrix (classification)

## Setup

```python
import mlflow
import mlflow.sklearn

# Set experiment
mlflow.set_experiment("project-name")
```

## Standard Logging Pattern

```python
with mlflow.start_run():
    # Log parameters
    mlflow.log_params({
        "model_type": "xgboost",
        "max_depth": 5,
        "learning_rate": 0.1,
        "n_estimators": 100,
        "random_state": 42
    })
    
    # Train model
    model = XGBClassifier(**params)
    model.fit(X_train, y_train)
    
    # Predictions
    y_pred = model.predict(X_test)
    y_proba = model.predict_proba(X_test)[:, 1]
    
    # Log metrics
    mlflow.log_metrics({
        "accuracy": accuracy_score(y_test, y_pred),
        "precision": precision_score(y_test, y_pred),
        "recall": recall_score(y_test, y_pred),
        "f1": f1_score(y_test, y_pred),
        "roc_auc": roc_auc_score(y_test, y_proba)
    })
    
    # Log model
    mlflow.sklearn.log_model(model, "model")
    
    # Log artifacts
    mlflow.log_artifact("confusion_matrix.png")
    mlflow.log_artifact("feature_importance.png")
```

## Cross-Validation Logging

```python
from sklearn.model_selection import StratifiedKFold

cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)

for fold, (train_idx, val_idx) in enumerate(cv.split(X, y)):
    with mlflow.start_run(nested=True):
        # Log fold number
        mlflow.log_param("fold", fold)
        
        # Train and evaluate
        # ... (training code) ...
        
        # Log metrics with fold prefix
        mlflow.log_metric("accuracy", acc)
        mlflow.log_metric("f1", f1)
```

## Custom Metrics

```python
# Log business metrics
revenue_impact = calculate_revenue_lift(y_pred, y_test)
mlflow.log_metric("revenue_impact_usd", revenue_impact)

# Log multiple values
for threshold in [0.3, 0.5, 0.7]:
    y_pred_thresh = (y_proba > threshold).astype(int)
    f1 = f1_score(y_test, y_pred_thresh)
    mlflow.log_metric(f"f1_threshold_{threshold}", f1)
```

## Artifacts to Log

Always log:
- [ ] Confusion matrix plot
- [ ] Feature importance plot
- [ ] ROC/PR curves
- [ ] Residual plots (regression)
- [ ] Model pickle/joblib
- [ ] Training dataset hash
- [ ] Requirements.txt

```python
# Save and log confusion matrix
plt.figure(figsize=(8, 6))
ConfusionMatrixDisplay.from_predictions(y_test, y_pred).plot()
plt.savefig("confusion_matrix.png")
mlflow.log_artifact("confusion_matrix.png")
```

## Best Practices

1. **Set experiment name** at start of script
2. **Use nested runs** for CV or hyperparameter search
3. **Tag runs** with version or stage
   ```python
   mlflow.set_tag("version", "v1.0")
   mlflow.set_tag("stage", "production_candidate")
   ```
4. **Log random seeds** for reproducibility
5. **Log dataset info** (size, version, hash)
6. **Clean up failed runs** or mark them

## Reproducibility Checklist

- [ ] Random seeds logged
- [ ] All dependencies pinned (requirements.txt)
- [ ] Data version/hash logged
- [ ] Code version (git commit) tagged
- [ ] Environment details logged (Python version, OS)
