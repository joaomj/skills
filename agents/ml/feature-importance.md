# Feature Importance

## Requirement

Every trained model MUST include feature importance analysis.

## Methods by Model Type

### Tree-Based (Random Forest, XGBoost, LightGBM)

**Built-in importance:**
```python
import pandas as pd

# Random Forest
importances = model.feature_importances_
feature_importance = pd.DataFrame({
    'feature': feature_names,
    'importance': importances
}).sort_values('importance', ascending=False)

# XGBoost
importances = model.get_booster().get_score(importance_type='gain')
```

**SHAP (recommended):**
```python
import shap

explainer = shap.TreeExplainer(model)
shap_values = explainer.shap_values(X_test)

# Summary plot
shap.summary_plot(shap_values, X_test, feature_names=feature_names)

# Values for single prediction
shap.waterfall_plot(shap.Explanation(
    values=shap_values[0],
    base_values=explainer.expected_value,
    data=X_test.iloc[0],
    feature_names=feature_names
))
```

### Linear Models

**Coefficients (after scaling):**
```python
from sklearn.preprocessing import StandardScaler

# Scale features first
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X_train)

# Fit model
model = LogisticRegression()
model.fit(X_scaled, y_train)

# Coefficients
importance = pd.DataFrame({
    'feature': feature_names,
    'coefficient': model.coef_[0],
    'abs_coefficient': np.abs(model.coef_[0])
}).sort_values('abs_coefficient', ascending=False)
```

### Neural Networks

**SHAP (slow but accurate):**
```python
explainer = shap.DeepExplainer(model, X_train[:100])
shap_values = explainer.shap_values(X_test[:10])
shap.summary_plot(shap_values, X_test[:10])
```

**Integrated Gradients (alternative):**
```python
# Requires tensorflow/pytorch libraries
```

### Any Model (Model-Agnostic)

**Permutation Importance:**
```python
from sklearn.inspection import permutation_importance

result = permutation_importance(
    model, X_test, y_test, 
    n_repeats=10, 
    random_state=42
)

importance = pd.DataFrame({
    'feature': feature_names,
    'importance_mean': result.importances_mean,
    'importance_std': result.importances_std
}).sort_values('importance_mean', ascending=False)
```

## Reporting Format

Include in every model evaluation:

```markdown
## Feature Importance

### Top 10 Features
| Rank | Feature | Importance | Direction |
|------|---------|------------|-----------|
| 1 | feature_a | 0.234 | Positive |
| 2 | feature_b | 0.189 | Negative |
...etc...

### Sanity Check
- Do top features make business sense? [Yes/No]
- Are unexpected features explained?
- Are there proxy variables leaking target information?
```

## Common Issues

| Issue | Detection | Solution |
|-------|-----------|----------|
| Proxy variables | Feature too predictive | Remove or acknowledge |
| High cardinality | Categorical with many levels | Check if overfitting |
| Correlated features | Similar importance | Group or select one |
| Wrong sign | Direction unexpected | Investigate data |

## SHAP Best Practices

1. **Sample size:** Use subset (100-1000) for speed
2. **Background:** Use training set mean for expected value
3. **Visualizations:**
   - `summary_plot()` - Global importance
   - `waterfall_plot()` - Single prediction
   - `dependence_plot()` - Feature interactions
4. **Save SHAP values** to MLflow for later analysis
