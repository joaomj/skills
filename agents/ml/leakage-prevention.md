# Data Leakage Prevention

## What is Data Leakage?

Using information during training that won't be available at prediction time.

## Common Leakage Sources

### 1. Fitting Transformers on Full Data

**WRONG:**
```python
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)  # Fit on ALL data
X_train, X_test = train_test_split(X_scaled)
```

**CORRECT:**
```python
from sklearn.pipeline import Pipeline

pipeline = Pipeline([
    ('scaler', StandardScaler()),
    ('model', LogisticRegression())
])

# Fit scaler on train only
pipeline.fit(X_train, y_train)
# Transform test using train statistics
pipeline.predict(X_test)
```

### 2. Target Encoding Leakage

**WRONG:**
```python
# Calculate mean target by category on FULL data
df['category_encoded'] = df.groupby('category')['target'].transform('mean')
```

**CORRECT:**
```python
from sklearn.preprocessing import TargetEncoder
from sklearn.model_selection import cross_val_predict

# Use cross-validation to encode
encoder = TargetEncoder()
X_train['encoded'] = encoder.fit_transform(X_train[['category']], y_train)
X_test['encoded'] = encoder.transform(X_test[['category']])
```

### 3. Temporal Leakage

**Problem:** Features from the future in training data

```python
# WRONG: Using future sales to predict today's sales
df['future_avg_sales'] = df['sales'].rolling(window=7).mean().shift(-3)
```

**AUDIT:** Check feature timestamps. All features must be known at prediction time.

### 4. Duplicate Rows in Train/Test

**Problem:** Same data appears in both splits

**Solution:** Deduplicate BEFORE splitting

```python
# Remove exact duplicates
df = df.drop_duplicates()

# Remove near-duplicates (fuzzy matching if needed)
```

## Mandatory: sklearn Pipelines

### Why Pipelines?

- Prevents fitting on test data
- Ensures consistent transformations
- Makes code reproducible

### Basic Pipeline

```python
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder

# Preprocessing for different column types
numeric_transformer = Pipeline(steps=[
    ('imputer', SimpleImputer(strategy='median')),
    ('scaler', StandardScaler())
])

categorical_transformer = Pipeline(steps=[
    ('imputer', SimpleImputer(strategy='constant')),
    ('onehot', OneHotEncoder(handle_unknown='ignore'))
])

# Combine
transformer = ColumnTransformer(
    transformers=[
        ('num', numeric_transformer, numeric_features),
        ('cat', categorical_transformer, categorical_features)
    ]
)

# Full pipeline
pipeline = Pipeline([
    ('preprocessor', transformer),
    ('classifier', RandomForestClassifier())
])

# Fit on train only
pipeline.fit(X_train, y_train)

# Transform test using train stats
predictions = pipeline.predict(X_test)
```

## Leakage Checklist

Before training any model, verify:

- [ ] All preprocessing in Pipeline
- [ ] No statistics computed on full dataset
- [ ] No target information in features
- [ ] Temporal features precede target time
- [ ] No duplicates across train/test
- [ ] Random seeds set for reproducibility

## Red Flags

| Symptom | Likely Cause |
|---------|--------------|
| 99% accuracy on first try | Severe leakage |
| Perfect validation, poor production | Train/test leakage |
| Results too good to be true | Data leakage |
| Model "knows" future | Temporal leakage |
