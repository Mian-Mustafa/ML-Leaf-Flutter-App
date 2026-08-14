import 'interview_models.dart';

abstract final class InterviewData {
  static const _foundation = <InterviewQuestion>[
    InterviewQuestion(
      id: 'foundation-ml-vs-programming',
      prompt:
          'How would you explain the difference between machine learning and traditional programming to a non-technical stakeholder?',
      moduleIds: ['foundations'],
      focusPoints: ['Learning from examples', 'Predictions', 'Clear contrast'],
      suggestedAnswer:
          'Traditional programs apply rules written by people to inputs. In machine learning, we provide historical examples and an algorithm learns a mapping that can make predictions for new inputs. I would also mention that the learned model still needs evaluation because it can generalize poorly or inherit bias from the data.',
      followUp:
          'Give one business problem where explicit rules are preferable to machine learning.',
    ),
    InterviewQuestion(
      id: 'foundation-learning-types',
      prompt:
          'Compare supervised and unsupervised learning, then give one appropriate example for each.',
      moduleIds: [
        'foundations',
        'supervised_learning',
        'unsupervised_learning',
      ],
      focusPoints: ['Labels', 'Prediction versus discovery', 'Examples'],
      suggestedAnswer:
          'Supervised learning uses labelled examples to learn a target, such as predicting house prices or classifying spam. Unsupervised learning has no supplied target and is used to discover structure, such as customer segmentation with clustering. The right choice depends on whether a useful outcome label exists.',
      followUp:
          'What would you do if only a small share of the records has labels?',
    ),
    InterviewQuestion(
      id: 'foundation-features-target',
      prompt:
          'Define an observation, a feature, and a target. Why does this distinction matter during model design?',
      moduleIds: ['foundations', 'supervised_learning'],
      focusPoints: [
        'Dataset vocabulary',
        'Input versus output',
        'Leakage awareness',
      ],
      suggestedAnswer:
          'An observation is one example or row. Features are the input attributes used by a model, while the target is the value or class we want to predict. Keeping the distinction clear prevents accidentally using target-derived or future information as a feature and guides both preprocessing and evaluation.',
      followUp:
          'Describe a feature that looks legitimate but would leak the target in a churn project.',
    ),
    InterviewQuestion(
      id: 'foundation-regression-classification',
      prompt:
          'How do you decide whether a problem is regression or classification?',
      moduleIds: ['supervised_learning', 'regression', 'classification'],
      focusPoints: ['Target type', 'Output interpretation', 'Metric choice'],
      suggestedAnswer:
          'I start with the target. Regression predicts a continuous numeric value, for example revenue or delivery time. Classification predicts a discrete label or probability, such as fraud or not fraud. This decision affects the model family, loss function, evaluation metrics, and the business action taken from a prediction.',
      followUp:
          'Where would an ordinal rating from one to five need extra care?',
    ),
    InterviewQuestion(
      id: 'foundation-workflow',
      prompt:
          'Walk me through a responsible end-to-end machine learning workflow.',
      moduleIds: ['foundations', 'data_preprocessing', 'model_evaluation'],
      focusPoints: ['Problem framing', 'Validation', 'Monitoring'],
      suggestedAnswer:
          'I begin with the decision, target, success metric, and constraints. I audit and split the data before fitting transformations, build a reproducible preprocessing and modelling pipeline, validate alternatives on appropriate folds, and keep a final test set untouched. After deployment I monitor performance, data drift, fairness, latency, and feedback loops.',
      followUp:
          'At which point in that workflow can leakage occur most easily?',
    ),
    InterviewQuestion(
      id: 'foundation-generalization',
      prompt:
          'What does generalization mean, and how do bias and variance relate to it?',
      moduleIds: ['foundations', 'model_evaluation'],
      focusPoints: ['Unseen data', 'Underfitting', 'Overfitting'],
      suggestedAnswer:
          'Generalization is performing well on new, representative data rather than only the training set. High bias causes underfitting because the model is too simple to capture the signal. High variance causes overfitting because the model reacts to noise or quirks in the training sample. Validation is used to find a useful balance.',
      followUp:
          'Which learning-curve pattern would make you suspect high variance?',
    ),
  ];

  static const _dataReadiness = <InterviewQuestion>[
    InterviewQuestion(
      id: 'data-audit',
      prompt:
          'You receive a new dataset for a prediction project. What do you inspect before choosing a model?',
      moduleIds: ['data_preprocessing'],
      focusPoints: ['Quality checks', 'Target definition', 'Data split'],
      suggestedAnswer:
          'I inspect the grain of each row, data types, missingness, duplicates, outliers, class balance, target quality, and the time range. I identify which columns are available at prediction time and define a split that reflects production. I also check whether a simple baseline can answer the business need before investing in a complex model.',
      followUp:
          'How would your audit change for a time-based forecasting dataset?',
    ),
    InterviewQuestion(
      id: 'data-missing-values',
      prompt:
          'How would you handle missing values without introducing leakage?',
      moduleIds: ['data_preprocessing'],
      focusPoints: [
        'Fit on training only',
        'Imputation strategy',
        'Missingness signal',
      ],
      suggestedAnswer:
          'I first understand why values are missing. Depending on the feature and model, I may impute with a training-set median, mode, or a model-based method, and sometimes add a missing-value indicator. Every imputer must be fitted on training folds only and then applied to validation or test data through a pipeline.',
      followUp: 'When is dropping a row safer than imputing it?',
    ),
    InterviewQuestion(
      id: 'data-encoding',
      prompt:
          'How do you choose an encoding approach for categorical features?',
      moduleIds: ['data_preprocessing', 'feature_engineering'],
      focusPoints: [
        'Nominal versus ordinal',
        'Cardinality',
        'Unseen categories',
      ],
      suggestedAnswer:
          'For low-cardinality nominal variables, one-hot encoding is a reliable baseline. Ordinal encoding is appropriate only when order is meaningful. For high-cardinality variables I consider frequency, carefully cross-fitted target encoding, hashing, or models with native categorical handling. The encoder must handle unseen categories and be fitted inside the training workflow.',
      followUp: 'Why is ordinary target encoding particularly risky?',
    ),
    InterviewQuestion(
      id: 'data-scaling',
      prompt: 'Which models need feature scaling, and which commonly do not?',
      moduleIds: ['data_preprocessing', 'feature_engineering'],
      focusPoints: ['Distance-based models', 'Regularization', 'Trees'],
      suggestedAnswer:
          'Scaling is important for distance-based methods such as KNN and SVM, gradient-based models, PCA, and regularized linear models because feature magnitude changes the optimization or distance. Tree-based models generally do not require scaling because they split on feature thresholds. I fit the scaler only on training data.',
      followUp: 'When might robust scaling be preferable to standardization?',
    ),
    InterviewQuestion(
      id: 'data-feature-engineering',
      prompt:
          'Give an example of a useful engineered feature and explain how you would validate that it helps.',
      moduleIds: ['feature_engineering', 'model_evaluation'],
      focusPoints: [
        'Domain logic',
        'Availability at prediction time',
        'Ablation',
      ],
      suggestedAnswer:
          'For a property-price model, I might create property age from sale year minus build year, or price per area only when it is available at prediction time. I validate it by comparing the same pipeline with and without the feature using cross-validation and the business-relevant metric. Improvement must be stable across folds, not just one split.',
      followUp: 'What would make an aggregate customer feature invalid?',
    ),
    InterviewQuestion(
      id: 'data-pipeline',
      prompt:
          'Why should preprocessing and modelling be placed in one pipeline?',
      moduleIds: [
        'data_preprocessing',
        'feature_engineering',
        'model_evaluation',
      ],
      focusPoints: [
        'Reproducibility',
        'Leakage prevention',
        'Deployment parity',
      ],
      suggestedAnswer:
          'A pipeline applies the same sequence of transformations during training, validation, and inference. It prevents accidental fitting on validation or test data, makes cross-validation trustworthy, and reduces train-serving differences. It also makes parameter tuning and deployment easier because the full workflow is versioned as one object.',
      followUp:
          'Name one preprocessing step that must never be fitted on the full dataset before a split.',
    ),
  ];

  static const _modelling = <InterviewQuestion>[
    InterviewQuestion(
      id: 'model-regression-diagnostics',
      prompt:
          'How would you assess whether a linear regression model is appropriate for a problem?',
      moduleIds: ['regression'],
      focusPoints: ['Residuals', 'Assumptions', 'Baseline comparison'],
      suggestedAnswer:
          'I inspect the relationship and compare against a simple baseline. After fitting, I examine residuals for non-linearity, changing variance, outliers, and dependence, and check for multicollinearity among predictors. If assumptions are weak, I consider transformations, regularization, tree-based models, or another model family and validate the comparison.',
      followUp: 'What residual pattern suggests heteroscedasticity?',
    ),
    InterviewQuestion(
      id: 'model-imbalance',
      prompt:
          'How would you approach a highly imbalanced classification problem?',
      moduleIds: ['classification', 'model_evaluation'],
      focusPoints: ['Metric selection', 'Thresholds', 'Resampling'],
      suggestedAnswer:
          'I first clarify the cost of false positives and false negatives, then use stratified splits and metrics such as precision, recall, F1, PR-AUC, or a cost-based metric instead of accuracy alone. I may adjust thresholds, class weights, or resampling within training folds. The final choice should be evaluated on representative untouched data.',
      followUp:
          'Why can a model with 99% accuracy still be useless for fraud detection?',
    ),
    InterviewQuestion(
      id: 'model-algorithm-choice',
      prompt:
          'How would you choose between a linear model, KNN, a decision tree, and an SVM?',
      moduleIds: ['classification', 'regression'],
      focusPoints: ['Data scale', 'Interpretability', 'Geometry'],
      suggestedAnswer:
          'I start with the data size, feature types, relationship complexity, latency, and explainability needs. Linear models are strong interpretable baselines. KNN can work for local structure but needs scaling and becomes expensive at inference. Trees capture non-linear interactions and are easy to explain, while SVM can be effective on well-scaled medium-sized data with a clear margin structure.',
      followUp:
          'Which of these methods is most affected by the curse of dimensionality?',
    ),
    InterviewQuestion(
      id: 'model-clustering',
      prompt:
          'How would you build and validate a customer-segmentation clustering project?',
      moduleIds: ['unsupervised_learning', 'data_preprocessing'],
      focusPoints: ['Feature design', 'Cluster validity', 'Business action'],
      suggestedAnswer:
          'I define the segmentation decision first, prepare comparable behavioural features, handle skew and scale them, then evaluate candidate cluster counts with measures such as silhouette score and stability. I inspect cluster profiles with stakeholders and only keep segments that are distinct, actionable, and stable over time. A low mathematical score alone does not make a segment useful.',
      followUp: 'When would DBSCAN be more suitable than K-means?',
    ),
    InterviewQuestion(
      id: 'model-pca',
      prompt:
          'When would you use PCA, and what important caveat would you mention in an interview?',
      moduleIds: ['unsupervised_learning', 'feature_engineering'],
      focusPoints: ['Dimensionality reduction', 'Scaling', 'Interpretability'],
      suggestedAnswer:
          'I use PCA to compress correlated numeric features, reduce noise, or make high-dimensional data easier to model or visualize. I standardize features when their units differ and fit PCA on training data only. The caveat is that components maximize variance, not necessarily predictive signal, and they can reduce interpretability.',
      followUp:
          'Why might PCA preserve variance but still harm classification performance?',
    ),
    InterviewQuestion(
      id: 'model-baseline-selection',
      prompt:
          'What makes a model selection decision defensible beyond choosing the highest validation score?',
      moduleIds: ['regression', 'classification', 'model_evaluation'],
      focusPoints: ['Business constraints', 'Stability', 'Operational cost'],
      suggestedAnswer:
          'I compare models under the same preprocessing, splits, and metrics, then consider score uncertainty, calibration, fairness, latency, memory, maintainability, and explanation requirements. A simpler model can be preferable when its performance is essentially tied with a more complex model. The chosen model should solve the real decision problem reliably, not merely win one experiment.',
      followUp:
          'How would you communicate a tiny metric improvement with a large latency increase?',
    ),
  ];

  static const _evaluation = <InterviewQuestion>[
    InterviewQuestion(
      id: 'evaluation-splits',
      prompt:
          'Explain the different roles of training, validation, and test data.',
      moduleIds: ['model_evaluation'],
      focusPoints: ['Fitting', 'Model selection', 'Final estimate'],
      suggestedAnswer:
          'Training data fits model parameters. Validation data or cross-validation supports model and hyperparameter selection. The test set is held back for a final, unbiased estimate after decisions are finished. Reusing the test set for tuning turns it into validation data and produces an overly optimistic result.',
      followUp: 'What changes when you have very limited data?',
    ),
    InterviewQuestion(
      id: 'evaluation-cross-validation',
      prompt: 'When should you use stratified or time-series cross-validation?',
      moduleIds: ['model_evaluation', 'classification'],
      focusPoints: [
        'Class proportions',
        'Temporal order',
        'Representative folds',
      ],
      suggestedAnswer:
          'I use stratified folds for classification, especially with imbalance, so each fold preserves the class distribution. For time-dependent data I use a forward-looking split that trains on the past and validates on the future. Random K-fold would leak temporal information and make future performance look better than it is.',
      followUp:
          'Why can standard shuffled K-fold be misleading for customer transactions over time?',
    ),
    InterviewQuestion(
      id: 'evaluation-confusion-matrix',
      prompt:
          'A classifier has high precision but low recall. What does that mean and when might it be acceptable?',
      moduleIds: ['classification', 'model_evaluation'],
      focusPoints: ['False positives', 'False negatives', 'Decision cost'],
      suggestedAnswer:
          'High precision means predicted positives are usually correct, while low recall means many real positives are missed. It can be acceptable when false positives are expensive, such as escalating an expensive manual investigation. For medical screening or fraud discovery, missing positives may be worse, so I would usually seek higher recall and adjust the threshold.',
      followUp: 'Which confusion-matrix cell increases when recall is too low?',
    ),
    InterviewQuestion(
      id: 'evaluation-curves',
      prompt:
          'How do ROC-AUC and PR-AUC differ, and which would you emphasise for rare-event detection?',
      moduleIds: ['classification', 'model_evaluation'],
      focusPoints: ['Class imbalance', 'Ranking', 'Positive class'],
      suggestedAnswer:
          'ROC-AUC measures ranking quality through true-positive and false-positive rates across thresholds. PR-AUC focuses on precision and recall for the positive class. For rare events, PR-AUC is often more informative because it shows whether positive alerts remain trustworthy when negatives dominate the data.',
      followUp:
          'Why should neither curve replace a decision threshold chosen from business cost?',
    ),
    InterviewQuestion(
      id: 'evaluation-learning-curves',
      prompt:
          'How would you diagnose overfitting and underfitting from training and validation behaviour?',
      moduleIds: ['model_evaluation'],
      focusPoints: ['Learning curves', 'Complexity', 'Next action'],
      suggestedAnswer:
          'Underfitting appears as poor training and validation performance, suggesting insufficient model capacity, features, or training. Overfitting appears as strong training performance with a noticeably worse validation result, suggesting excessive complexity or weak regularization. I use learning and validation curves to decide whether to add data, simplify, regularize, or improve features.',
      followUp: 'Why can adding data help high variance more than high bias?',
    ),
    InterviewQuestion(
      id: 'evaluation-fair-comparison',
      prompt:
          'What must remain consistent when comparing two candidate models?',
      moduleIds: ['model_evaluation', 'feature_engineering'],
      focusPoints: [
        'Same data split',
        'Same metric',
        'Same preprocessing scope',
      ],
      suggestedAnswer:
          'Models should be compared using the same task definition, data splits or folds, preprocessing protocol, metric, and evaluation procedure. Any feature selection, encoding, imputation, or tuning must occur within each training fold. I also report variability across folds and compare operational constraints rather than highlighting one best-looking score.',
      followUp:
          'What kind of unfair advantage results when one model sees features selected on the full dataset?',
    ),
  ];

  static const _ensembles = <InterviewQuestion>[
    InterviewQuestion(
      id: 'ensemble-bagging-boosting',
      prompt:
          'Compare bagging and boosting. What problem does each primarily address?',
      moduleIds: ['ensemble_methods'],
      focusPoints: [
        'Parallel versus sequential',
        'Variance versus bias',
        'Sensitivity',
      ],
      suggestedAnswer:
          'Bagging trains diverse models independently, often on bootstrap samples, and aggregates them to reduce variance. Boosting builds models sequentially so later learners correct earlier errors, which can reduce bias. Boosting can be more sensitive to noise and tuning, while bagging is usually more robust with unstable base learners.',
      followUp:
          'Why are deep decision trees a natural base learner for bagging?',
    ),
    InterviewQuestion(
      id: 'ensemble-rf-extra-trees',
      prompt:
          'How do Random Forest and Extra Trees create diversity among their trees?',
      moduleIds: ['ensemble_methods'],
      focusPoints: [
        'Bootstrap samples',
        'Feature subsets',
        'Random thresholds',
      ],
      suggestedAnswer:
          'Random Forest commonly combines bootstrap samples with random subsets of features at each split. Extra Trees introduces additional randomness by selecting split thresholds more randomly and may use the full sample instead of bootstrapping. Both decorrelate trees so averaging or voting is more effective, with a small trade-off between bias and variance.',
      followUp: 'What does the out-of-bag score provide in a Random Forest?',
    ),
    InterviewQuestion(
      id: 'ensemble-boosting-libraries',
      prompt:
          'How would you distinguish Gradient Boosting, XGBoost, LightGBM, and CatBoost in a practical interview answer?',
      moduleIds: ['ensemble_methods'],
      focusPoints: ['Regularization', 'Efficiency', 'Categorical features'],
      suggestedAnswer:
          'Gradient Boosting is the general sequential residual-correction idea. XGBoost adds strong regularization and optimized training. LightGBM uses histogram-based, leaf-wise growth for speed on large data but needs careful constraints. CatBoost is especially useful with categorical features and uses ordered techniques to reduce target leakage. I would validate all candidates on the project constraints rather than assume one wins.',
      followUp: 'Why can a smaller learning rate require more trees?',
    ),
    InterviewQuestion(
      id: 'ensemble-stacking-blending',
      prompt:
          'Explain stacking versus blending, and why out-of-fold predictions matter.',
      moduleIds: ['ensemble_methods', 'model_evaluation'],
      focusPoints: [
        'Meta-learner',
        'Out-of-fold predictions',
        'Data efficiency',
      ],
      suggestedAnswer:
          'Stacking trains a meta-model on base-model predictions, ideally using out-of-fold predictions so the meta-model sees predictions made for rows that were not used to fit that base model. Blending is simpler because it uses a held-out validation set for the combiner, but it spends data and may be less stable. Without out-of-fold predictions, the meta-model can learn overconfident training artifacts.',
      followUp:
          'How do you prepare base models after a stacking workflow is chosen for production?',
    ),
    InterviewQuestion(
      id: 'ensemble-importance',
      prompt:
          'How would you discuss feature importance from a tree ensemble responsibly?',
      moduleIds: ['ensemble_methods', 'feature_engineering'],
      focusPoints: [
        'Association not causation',
        'Correlated features',
        'Validation',
      ],
      suggestedAnswer:
          'Feature importance shows how a model used inputs, not whether a feature causes an outcome. Impurity-based measures can favour high-cardinality features, and correlated variables can split credit unpredictably. I corroborate findings with permutation importance, stability across folds, domain review, and where needed local explanation methods. I do not make causal claims from importance alone.',
      followUp:
          'Why can permutation importance look low for two highly correlated predictors?',
    ),
    InterviewQuestion(
      id: 'ensemble-tuning-deployment',
      prompt:
          'How would you tune and decide whether an ensemble is worth deploying?',
      moduleIds: ['ensemble_methods', 'model_evaluation'],
      focusPoints: [
        'Cross-validation',
        'Early stopping',
        'Operational trade-offs',
      ],
      suggestedAnswer:
          'I define the success metric and latency or explainability constraints first, then tune a focused set of parameters with cross-validation. For boosting I use a sensible learning-rate and tree-complexity search with early stopping on validation data. I compare against a strong simple baseline and deploy the ensemble only when the validated gain justifies its additional runtime, maintenance, and interpretability cost.',
      followUp:
          'When would you deliberately choose the simpler baseline instead?',
    ),
  ];

  static const tracks = <InterviewTrack>[
    InterviewTrack(
      id: 'foundations',
      title: 'ML foundations',
      subtitle: 'Core concepts, targets, and generalization',
      moduleIds: ['foundations', 'supervised_learning'],
      questions: _foundation,
    ),
    InterviewTrack(
      id: 'data-readiness',
      title: 'Data readiness',
      subtitle: 'Preparation, encoding, scaling, and pipelines',
      moduleIds: ['data_preprocessing', 'feature_engineering'],
      questions: _dataReadiness,
    ),
    InterviewTrack(
      id: 'model-selection',
      title: 'Modelling decisions',
      subtitle: 'Regression, classification, and unsupervised methods',
      moduleIds: ['regression', 'classification', 'unsupervised_learning'],
      questions: _modelling,
    ),
    InterviewTrack(
      id: 'evaluation',
      title: 'Evaluation & validation',
      subtitle: 'Metrics, cross-validation, and reliable comparisons',
      moduleIds: ['model_evaluation'],
      questions: _evaluation,
    ),
    InterviewTrack(
      id: 'ensembles',
      title: 'Ensemble strategy',
      subtitle: 'Bagging, boosting, stacking, and model trade-offs',
      moduleIds: ['ensemble_methods'],
      questions: _ensembles,
    ),
  ];

  static final mockInterview = InterviewTrack(
    id: 'mock',
    title: 'ML mock interview',
    subtitle: 'A cross-module screening round',
    moduleIds: const [
      'foundations',
      'data_preprocessing',
      'supervised_learning',
      'regression',
      'classification',
      'unsupervised_learning',
      'model_evaluation',
      'feature_engineering',
      'ensemble_methods',
    ],
    questions: [
      _foundation[0],
      _foundation[3],
      _dataReadiness[1],
      _dataReadiness[4],
      _modelling[1],
      _modelling[3],
      _evaluation[1],
      _evaluation[2],
      _ensembles[0],
      _ensembles[3],
    ],
  );

  static InterviewTrack? trackForId(String id) {
    if (id == mockInterview.id) return mockInterview;
    for (final track in tracks) {
      if (track.id == id) return track;
    }
    return null;
  }
}
