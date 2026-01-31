# CRISP-DM Methodology

## Overview

Cross-Industry Standard Process for Data Mining - mandatory workflow for all ML projects.

## Phase 1: Business Understanding

### Questions to Answer
- What business problem are we solving?
- What does success look like in business terms?
- What metric improvement matters? (e.g., "reduce churn by 10%")
- What's the current baseline performance?

### Constraints to Document
- Latency requirements (real-time vs batch)
- Interpretability needs (regulatory compliance)
- Resource constraints (compute, storage)

## Phase 2: Data Understanding

### Tasks
- Profile data: distributions, missing values, outliers
- Check class balance (classification)
- Document data lineage: source, freshness, update frequency
- **CRITICAL: Identify data leakage risks NOW**

### Deliverables
- EDA notebook with key statistics
- Data quality report
- Leakage risk assessment

## Phase 3: Data Preparation

### Requirements
- Use sklearn Pipelines for ALL preprocessing
- Document every transformation decision
- Version your datasets (hash or DVC)

### Pipeline Pattern
```python
from sklearn.pipeline import Pipeline

pipeline = Pipeline([
    ('scaler', StandardScaler()),
    ('imputer', SimpleImputer()),
    ('model', LogisticRegression())
])
```

## Phase 4: Modeling

### Strategy
1. **Start simple** - Logistic regression, decision tree
2. Establish baseline with simple model
3. Try complex models only AFTER beating baseline
4. Document why each model was chosen

### Hyperparameters
- Document search space
- Use random/grid search with cross-validation
- Log all experiments to MLflow

## Phase 5: Evaluation

### Required for Every Model
- Appropriate metrics for problem type
- Confidence intervals / cross-validation variance
- Comparison to business success criteria
- Business impact estimate (e.g., "$X revenue lift")

## Phase 6: Deployment

### Checklist
- [ ] Model reproducible from code + data + seeds
- [ ] Inference latency documented
- [ ] Resource requirements documented
- [ ] Monitoring plan (data drift, performance)
- [ ] Retraining triggers defined

## Common Mistakes

| Mistake | Why It Fails | Correct Approach |
|---------|--------------|------------------|
| Skip Phase 1 | Build wrong solution | Define success criteria first |
| Skip Phase 2 | Miss data quality issues | Profile data thoroughly |
| Skip Phase 3 | Data leakage, non-reproducible | Use Pipelines, version data |
| Start with complex model | Overfitting, no baseline | Simple model first |
| Evaluate only on metrics | Miss business impact | Translate metrics to business value |
