# Evaluation Metrics and Requirements

## Classification

### Always Required

1. **Confusion Matrix** - Every classification model

```python
from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay

cm = confusion_matrix(y_true, y_pred)
ConfusionMatrixDisplay(cm).plot()
```

2. **Precision, Recall, F1** - Per class, not just averages

```python
from sklearn.metrics import classification_report

print(classification_report(y_true, y_pred, target_names=['Class A', 'Class B']))
```

3. **ROC-AUC** - For probability outputs

```python
from sklearn.metrics import roc_auc_score, RocCurveDisplay

auc = roc_auc_score(y_true, y_proba)
RocCurveDisplay.from_predictions(y_true, y_proba).plot()
```

4. **Comparison to Baseline**

```python
from sklearn.dummy import DummyClassifier

# Baseline: predict majority class
baseline = DummyClassifier(strategy='most_frequent')
baseline.fit(X_train, y_train)
baseline_score = baseline.score(X_test, y_test)

print(f"Baseline: {baseline_score:.3f}, Model: {model_score:.3f}")
```

### When to Use Each Metric

| Metric | Use When |
|--------|----------|
| Accuracy | Balanced classes, equal misclassification cost |
| Precision | False positives are costly (spam detection) |
| Recall | False negatives are costly (disease detection) |
| F1 | Need balance of precision and recall |
| ROC-AUC | Ranking/scoring quality matters |
| PR-AUC | Severe class imbalance |

### Class Imbalance

When classes are imbalanced (>90% vs <10%):

- Don't use accuracy
- Use F1, PR-AUC, or Cohen's Kappa
- Report per-class metrics

```python
from sklearn.metrics import f1_score

# Macro F1: unweighted mean of per-class F1
f1_macro = f1_score(y_true, y_pred, average='macro')

# Weighted F1: weighted by class frequency
f1_weighted = f1_score(y_true, y_pred, average='weighted')
```

## Regression

### Always Required

1. **MAE (Mean Absolute Error)** - Interpretable in original units
2. **RMSE (Root Mean Squared Error)** - Penalizes large errors
3. **R-squared** - Variance explained

```python
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score

mae = mean_absolute_error(y_true, y_pred)
rmse = mean_squared_error(y_true, y_pred, squared=False)
r2 = r2_score(y_true, y_pred)

print(f"MAE: {mae:.2f}, RMSE: {rmse:.2f}, R²: {r2:.3f}")
```

### Visualization Required

1. **Predicted vs Actual scatter plot**
2. **Residual plot** (residuals vs predicted)
3. **Residual distribution histogram**

```python
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(15, 4))

# Predicted vs Actual
axes[0].scatter(y_true, y_pred, alpha=0.5)
axes[0].plot([y_true.min(), y_true.max()], [y_true.min(), y_true.max()], 'r--')
axes[0].set_xlabel('Actual')
axes[0].set_ylabel('Predicted')

# Residuals vs Predicted
residuals = y_true - y_pred
axes[1].scatter(y_pred, residuals, alpha=0.5)
axes[1].axhline(y=0, color='r', linestyle='--')
axes[1].set_xlabel('Predicted')
axes[1].set_ylabel('Residuals')

# Residual distribution
axes[2].hist(residuals, bins=30, edgecolor='black')
axes[2].set_xlabel('Residual')
axes[2].set_ylabel('Frequency')

plt.tight_layout()
plt.show()
```

## Evaluation Checklist

- [ ] Confusion matrix displayed (classification)
- [ ] Precision/recall/f1 per class (classification)
- [ ] ROC-AUC or PR-AUC (classification with probabilities)
- [ ] Baseline model comparison
- [ ] Residual plots (regression)
- [ ] Error distribution analysis (regression)
- [ ] Feature importance shown
- [ ] Confidence intervals or CV variance reported
