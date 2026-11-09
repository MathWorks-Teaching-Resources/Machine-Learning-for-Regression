%[text] # Additional Resources
%[text] This guide follows the current lesson order in `README.m` and groups resources by active script. Each section includes aligned MathWorks Academy training, Help Center concept documentation, and function references for topics covered in that script.
%[text] [⇦ Main Menu](file:../MainMenu.m)
%%
%[text] %[text:anchor:M_2e47] ## 1.[ Overview of Machine Learning for Regression](file:../Scripts/MLOverview.m)
%[text] ### Online Training
%[text] - [MATLAB Onramp](https://matlabacademy.mathworks.com/details/matlab-onramp/gettingstarted) - Useful for students who want a quick refresher on MATLAB syntax, plotting, and tables before starting the lesson.
%[text] - [Machine Learning Onramp](https://matlabacademy.mathworks.com/details/machine-learning-onramp/machinelearning) - Covers baseline modeling, validation, and model comparison ideas introduced in the script.
%[text] - [Regression Methods with Machine Learning](https://matlabacademy.mathworks.com/details/regression-methods-with-machine-learning/otmlrmml) - Extends the lesson into broader regression-model selection and evaluation. \
%[text] ### Concept Documentation
%[text] - [Supervised Learning Workflow and Algorithms](https://www.mathworks.com/help/stats/supervised-learning-machine-learning-workflow-and-algorithms.html) - End-to-end workflow reference for baseline training, evaluation, and improvement. \
%[text] ### Function Documentation
%[text] - [`fitlm`](https://www.mathworks.com/help/stats/fitlm.html) - Simple linear regression baseline, fitted values, and residual analysis.
%[text] - [`cvpartition`](https://www.mathworks.com/help/stats/cvpartition.html) - Holdout and k-fold splits for comparing models on unseen data.
%[text] - [`fitrtree`](https://www.mathworks.com/help/stats/fitrtree.html) - Flexible nonlinear model previewed as a next step beyond the linear baseline.
%[text] - [`polyfit`](https://www.mathworks.com/help/matlab/ref/polyfit.html) - Polynomial fits used to compare simple and increasingly flexible regression models. \
%%
%[text] %[text:anchor:M_6138] ## 2. [Optimization and Gradient Descent for Regression](file:../Scripts/OptimizationandGradientDescentforRegression.m)
%[text] ### Online Training
%[text] - [Machine Learning Onramp](https://matlabacademy.mathworks.com/details/machine-learning-onramp/machinelearning) - Reinforces the relationship among training, evaluation, and iteration.
%[text] - [Regression Methods with Machine Learning](https://matlabacademy.mathworks.com/details/regression-methods-with-machine-learning/otmlrmml) - Useful follow-up for thinking about training error, evaluation, and model refinement.
%[text] - [MATLAB Onramp](https://matlabacademy.mathworks.com/details/matlab-onramp/gettingstarted) - Helpful for students who want more practice with arrays, plotting, and script-based experimentation. \
%[text] ### Concept Documentation
%[text] - [Supervised Learning Workflow and Algorithms](https://www.mathworks.com/help/stats/supervised-learning-machine-learning-workflow-and-algorithms.html) - Puts optimization inside the larger train-evaluate-iterate workflow. \
%[text] ### Function Documentation
%[text] - [`polyfit`](https://www.mathworks.com/help/matlab/ref/polyfit.html) - Direct least-squares solution for simple polynomial and linear fits. \
%%
%[text] %[text:anchor:M_0e5b] ## 3. [Feature Engineering and Regularization](file:../Scripts/FeatureEngRegularization.m)
%[text] ### Online Training
%[text] - [Machine Learning Onramp](https://matlabacademy.mathworks.com/details/machine-learning-onramp/machinelearning) - Reinforces validation, model comparison, and generalization.
%[text] - [Regression Methods with Machine Learning](https://matlabacademy.mathworks.com/details/regression-methods-with-machine-learning/otmlrmml) - Useful follow-up for improving regression models with better representations and controlled complexity. \
%[text] ### Concept Documentation
%[text] - [Feature Selection](https://www.mathworks.com/help/stats/feature-selection.html) - Connects engineered features to selecting a smaller, more useful predictor set.
%[text] - [Lasso Regularization](https://www.mathworks.com/help/stats/lasso-regularization.html) - Background for sparse regression and coefficient shrinkage.
%[text] - [Regularized Regression](https://www.mathworks.com/help/stats/ridge-regression.html) - Overview of Ridge, Lasso, and related penalty-based methods. \
%[text] ### Function Documentation
%[text] - [`fitlm`](https://www.mathworks.com/help/stats/fitlm.html) - Linear fits before and after transformations or engineered feature sets.
%[text] - [`stepwiselm`](https://www.mathworks.com/help/stats/stepwiselm.html) - Greedy feature selection baseline.
%[text] - [`lasso`](https://www.mathworks.com/help/stats/lasso.html) - Sparse regression with cross-validated regularization strength.
%[text] - [`fitrlinear`](https://www.mathworks.com/help/stats/fitrlinear.html) - Ridge and other regularized linear models.
%[text] - [`cvpartition`](https://www.mathworks.com/help/stats/cvpartition.html) - Validation splits for comparing feature sets and regularization choices. \
%%
%[text] %[text:anchor:M_080d] ## 4. [Decision Trees and Ensemble Methods](file:../Scripts/DecisionTreesandEnsembleMethods.m)
%[text] ### Online Training
%[text] - [Regression Methods with Machine Learning](https://matlabacademy.mathworks.com/details/regression-methods-with-machine-learning/otmlrmml) - Primary follow-up for tree-based and ensemble regression.
%[text] - [Machine Learning Onramp](https://matlabacademy.mathworks.com/details/machine-learning-onramp/machinelearning) - Useful review of training, validation, and model comparison in MATLAB. \
%[text] ### Concept Documentation
%[text] - [Decision Trees](https://www.mathworks.com/help/stats/decision-trees.html) - Documentation overview for threshold-based supervised learning.
%[text] - [Regression Tree Ensembles](https://www.mathworks.com/help/stats/regression-tree-ensembles.html) - Background on bagging, boosting, and combining many trees. \
%[text] ### Function Documentation
%[text] - [`fitlm`](https://www.mathworks.com/help/stats/fitlm.html) - Simple global baseline for comparison.
%[text] - [`cvpartition`](https://www.mathworks.com/help/stats/cvpartition.html) - Holdout split used to compare models on unseen data.
%[text] - [`fitrtree`](https://www.mathworks.com/help/stats/fitrtree.html) - Regression trees and split-based local prediction rules.
%[text] - [`fitrensemble`](https://www.mathworks.com/help/stats/fitrensemble.html) - Bagged and boosted regression ensembles.
%[text] - [`templateTree`](https://www.mathworks.com/help/stats/templatetree.html) - Tree templates used to configure ensemble learners. \
%%
%[text] [⇦ Return to Main Menu](file:../MainMenu.m)
%%
%[text] ## Help us Improve
%[text] [Share your feedback](<matlab: ShareFeedback>) to help us improve this module.

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline","rightPanelPercent":40}
%---
