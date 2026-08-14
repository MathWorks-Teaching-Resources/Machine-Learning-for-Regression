%[text] # Additional Resources
%[text] This guide follows the current lesson order in `README.m` and groups official MathWorks resources by active script so students can extend each topic with aligned online training, documentation, and function references.
%[text] [⇦ Main Menu](file:../MainMenu.m)
%%
%[text] %[text:anchor:M_2e47] ## 1.[ Overview of Machine Learning for Regression](file:MLOverview.m)
%[text] ### Online Training
%[text] - [MATLAB Onramp](https://matlabacademy.mathworks.com/details/matlab-onramp/gettingstarted) - Useful for students who want a quick refresher on MATLAB syntax, plotting, and tables before starting the lesson.
%[text] - [Machine Learning Onramp](https://matlabacademy.mathworks.com/details/machine-learning-onramp/machinelearning) - Covers baseline modeling, validation, and model comparison ideas introduced in the script.
%[text] - [Regression Methods with Machine Learning](https://matlabacademy.mathworks.com/details/regression-methods-with-machine-learning/otmlrmml) - Extends the lesson into broader regression-model selection and evaluation. \
%[text] ### Documentation and Examples
%[text] - [Supervised Learning Workflow and Algorithms](https://www.mathworks.com/help/stats/supervised-learning-machine-learning-workflow-and-algorithms.html) - End-to-end workflow reference for baseline training, evaluation, and improvement.
%[text] - [Cross-Validation](https://www.mathworks.com/discovery/cross-validation.html) - Background on why held-out error matters when comparing candidate models.
%[text] - [Overfitting](https://www.mathworks.com/discovery/overfitting.html) - Supports the lesson discussion of underfitting, overfitting, and generalization.
%[text] - [Train Regression Models in Regression Learner App](https://www.mathworks.com/help/stats/train-regression-models-in-regression-learner-app.html) - Complements the script’s workflow and model-comparison framing. \
%[text] ### Key Functions and Apps
%[text] - [`fitlm`](https://www.mathworks.com/help/stats/fitlm.html) - Simple linear regression baseline, fitted values, and residual analysis.
%[text] - [`cvpartition`](https://www.mathworks.com/help/stats/cvpartition.html) - Holdout and k-fold splits for comparing models on unseen data.
%[text] - [`fitrtree`](https://www.mathworks.com/help/stats/fitrtree.html) - Flexible nonlinear model previewed as a next step beyond the linear baseline.
%[text] - [`fitrensemble`](https://www.mathworks.com/help/stats/fitrensemble.html) - Stronger nonlinear regression option referenced later in the module.
%[text] - [Regression Learner App](https://www.mathworks.com/help/stats/regression-learner-app.html) - Interactive environment for training, comparing, and diagnosing regression models. \
%%
%[text] %[text:anchor:M_6138] ## 2. [Optimization and Gradient Descent for Regression](file:OptimizationandGradientDescentforRegression.m)
%[text] ### Online Training
%[text] - [Machine Learning Onramp](https://matlabacademy.mathworks.com/details/machine-learning-onramp/machinelearning) - Reinforces the relationship among training, evaluation, and iteration.
%[text] - [Regression Methods with Machine Learning](https://matlabacademy.mathworks.com/details/regression-methods-with-machine-learning/otmlrmml) - Useful follow-up for thinking about training error, evaluation, and model refinement.
%[text] - [MATLAB Onramp](https://matlabacademy.mathworks.com/details/matlab-onramp/gettingstarted) - Helpful for students who want more practice with arrays, plotting, and script-based experimentation. \
%[text] ### Documentation and Examples
%[text] - [Supervised Learning Workflow and Algorithms](https://www.mathworks.com/help/stats/supervised-learning-machine-learning-workflow-and-algorithms.html) - Puts optimization inside the larger train-evaluate-iterate workflow.
%[text] - [Cross-Validation](https://www.mathworks.com/discovery/cross-validation.html) - Useful when deciding what to change after a training run.
%[text] - [Overfitting](https://www.mathworks.com/discovery/overfitting.html) - Connects iterative improvement to generalization, underfitting, and overfitting.
%[text] - [Visualize and Assess Model Performance in Regression Learner](https://www.mathworks.com/help/stats/assess-model-performance-in-regression-learner.html) - Practical diagnostics for deciding whether to keep iterating or change the model. \
%[text] ### Key Functions and Apps
%[text] - [`polyfit`](https://www.mathworks.com/help/matlab/ref/polyfit.html) - Direct least-squares solution for simple polynomial and linear fits.
%[text] - [`fitlm`](https://www.mathworks.com/help/stats/fitlm.html) - Linear regression fitting and residual-based evaluation.
%[text] - [`cvpartition`](https://www.mathworks.com/help/stats/cvpartition.html) - Validation splits for the broader iterate stage.
%[text] - [Regression Learner App](https://www.mathworks.com/help/stats/regression-learner-app.html) - Interactive environment for checking error metrics and comparing alternatives after training. \
%%
%[text] %[text:anchor:M_0e5b] ## 3. [Feature Engineering and Regularization](file:FeatureEngRegularization.m)
%[text] ### Online Training
%[text] - [Machine Learning Onramp](https://matlabacademy.mathworks.com/details/machine-learning-onramp/machinelearning) - Reinforces validation, model comparison, and generalization.
%[text] - [Regression Methods with Machine Learning](https://matlabacademy.mathworks.com/details/regression-methods-with-machine-learning/otmlrmml) - Useful follow-up for improving regression models with better representations and controlled complexity. \
%[text] ### Documentation and Examples
%[text] - [Feature Engineering](https://www.mathworks.com/discovery/feature-engineering.html) - Overview of transformed, derived, and interaction-based predictors.
%[text] - [Principal Component Analysis](https://www.mathworks.com/help/stats/principal-component-analysis.html) - Supports the script’s PCA and variance-explained discussion.
%[text] - [Feature Selection](https://www.mathworks.com/help/stats/feature-selection.html) - Connects engineered features to selecting a smaller, more useful predictor set.
%[text] - [Lasso Regularization](https://www.mathworks.com/help/stats/lasso-regularization.html) - Background for sparse regression and coefficient shrinkage.
%[text] - [Regularized Regression](https://www.mathworks.com/help/stats/regularized-regression.html) - Overview of Ridge, Lasso, and related penalty-based methods.
%[text] - [Cross-Validation](https://www.mathworks.com/discovery/cross-validation.html) - Reinforces why transformations and penalties should be judged on held-out performance. \
%[text] ### Key Functions and Apps
%[text] - [`fitlm`](https://www.mathworks.com/help/stats/fitlm.html) - Linear fits before and after transformations or engineered feature sets.
%[text] - [`stepwiselm`](https://www.mathworks.com/help/stats/stepwiselm.html) - Greedy feature selection baseline.
%[text] - [`lasso`](https://www.mathworks.com/help/stats/lasso.html) - Sparse regression with cross-validated regularization strength.
%[text] - [`fitrlinear`](https://www.mathworks.com/help/stats/fitrlinear.html) - Ridge and other regularized linear models.
%[text] - [`pca`](https://www.mathworks.com/help/stats/pca.html) - Principal components, explained variance, and score-based regression workflows.
%[text] - [`cvpartition`](https://www.mathworks.com/help/stats/cvpartition.html) - Validation splits for comparing feature sets and regularization choices. \
%%
%[text] %[text:anchor:M_080d] ## 4. [Decision Trees and Ensemble Methods](file:DecisionTreesandEnsembleMethods.m)
%[text] ### Online Training
%[text] - [Regression Methods with Machine Learning](https://matlabacademy.mathworks.com/details/regression-methods-with-machine-learning/otmlrmml) - Primary follow-up for tree-based and ensemble regression.
%[text] - [Machine Learning Onramp](https://matlabacademy.mathworks.com/details/machine-learning-onramp/machinelearning) - Useful review of training, validation, and model comparison in MATLAB. \
%[text] ### Documentation and Examples
%[text] - [Decision Trees](https://www.mathworks.com/help/stats/decision-trees.html) - Documentation overview for threshold-based supervised learning.
%[text] - [Regression Tree Ensembles](https://www.mathworks.com/help/stats/regression-tree-ensembles.html) - Background on bagging, boosting, and combining many trees.
%[text] - [Train Regression Models in Regression Learner App](https://www.mathworks.com/help/stats/train-regression-models-in-regression-learner-app.html) - App workflow for comparing a linear baseline, tree, and ensemble.
%[text] - [Choose Model Options in Regression Learner](https://www.mathworks.com/help/stats/choose-regression-model-options.html) - Helps explain how flexibility and interpretability trade off across models.
%[text] - [Supervised Learning Workflow and Algorithms](https://www.mathworks.com/help/stats/supervised-learning-machine-learning-workflow-and-algorithms.html) - Broader model-selection context for deciding when tree-based models are appropriate. \
%[text] ### Key Functions and Apps
%[text] - [`fitlm`](https://www.mathworks.com/help/stats/fitlm.html) - Simple global baseline for comparison.
%[text] - [`fitrtree`](https://www.mathworks.com/help/stats/fitrtree.html) - Regression trees and split-based local prediction rules.
%[text] - [`fitrensemble`](https://www.mathworks.com/help/stats/fitrensemble.html) - Bagged and boosted regression ensembles.
%[text] - [`templateTree`](https://www.mathworks.com/help/stats/templatetree.html) - Tree templates used to configure ensemble learners.
%[text] - [Regression Learner App](https://www.mathworks.com/help/stats/regression-learner-app.html) - Interactive tool for training, comparing, and diagnosing regression models. \
%%
%[text] [⇦ Return to Main Menu](file:../MainMenu.m)

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline","rightPanelPercent":40}
%---
