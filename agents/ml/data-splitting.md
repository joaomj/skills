# Data Splitting Strategies

## Split Ratios

| Dataset Size | Train | Validation | Test |
|--------------|-------|------------|------|
| Small (< 10k rows) | Use cross-validation | - | - |
| Medium (10k-100k) | 70% | 15% | 15% |
| Large (> 100k) | 80% | 10% | 10% |

## Golden Rules

1. **Never tune on test set** - Test set is touched ONCE for final evaluation
2. **Stratify for classification** - Preserve class distribution
3. **Group for user data** - Same user in only one split
4. **Time for sequential** - No future data in training

## Strategy by Data Type

### Time-Series / Sequential Data

**Use:** Time-based split (train on past, test on future)

```python
from sklearn.model_selection import TimeSeriesSplit

tscv = TimeSeriesSplit(n_splits=5)
for train_idx, test_idx in tscv.split(X):
    X_train, X_test = X[train_idx], X[test_idx]
    # Train on past, validate on future
```

**Why:** Prevents temporal leakage. Model must predict future, not interpolate.

### User Behavior Data

**Use:** Group split by user_id

```python
from sklearn.model_selection import GroupShuffleSplit

gss = GroupShuffleSplit(n_splits=1, test_size=0.2)
train_idx, test_idx = next(gss.split(X, groups=user_ids))
# Same user never in both splits
```

**Why:** Prevents memorizing user patterns, tests generalization to new users.

### I.I.D. Tabular Data

**Use:** Stratified random split

```python
from sklearn.model_selection import train_test_split

X_train, X_test, y_train, y_test = train_test_split(
    X, y, 
    test_size=0.2, 
    stratify=y,  # Preserve class distribution
    random_state=42
)
```

## Cross-Validation

### When to Use
- Dataset < 10,000 samples
- Need variance estimates
- Hyperparameter tuning

### Types

| Type | Use For |
|------|---------|
| K-Fold (k=5-10) | General use |
| Stratified K-Fold | Classification |
| Time Series Split | Temporal data |
| Group K-Fold | User/group data |

### Implementation

```python
from sklearn.model_selection import StratifiedKFold, cross_val_score

cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
scores = cross_val_score(model, X, y, cv=cv, scoring='roc_auc')

print(f"CV Score: {scores.mean():.3f} (+/- {scores.std() * 2:.3f})")
```

## Nested Cross-Validation

Use when selecting hyperparameters AND estimating final performance:

```python
from sklearn.model_selection import GridSearchCV, cross_val_score

# Inner loop: hyperparameter search
grid_search = GridSearchCV(model, param_grid, cv=3)

# Outer loop: performance estimation
cv_scores = cross_val_score(grid_search, X, y, cv=5)
```

## Common Pitfalls

| Pitfall | Problem | Solution |
|---------|---------|----------|
| Random split for time data | Future data leaks into training | Time-based split |
| Same user in train/test | Memorizes user behavior | Group split |
| No stratification | Class imbalance changes | Stratify=y |
| Multiple test set evaluations | Overfitting to test set | Test set = ONE touch |
