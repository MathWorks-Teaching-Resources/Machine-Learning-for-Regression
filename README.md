<a id="T_DEF03274"></a>

# <span style="color:rgb(213,80,0)">Machine Learning for Regression</span>
<a id="H_053613DF"></a>


[![View on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/95903-machine-learning-for-regression) or [![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=MathWorks-Teaching-Resources/Machine-Learning-for-Regression&project=MLforRegression.prj&file=README.mlx)

[![MATLAB Versions Tested](https://img.shields.io/endpoint?url=https://mathworks-teaching-resources.github.io/Machine-Learning-for-Regression/TestedWith.json)](https://mathworks-teaching-resources.github.io/Machine-Learning-for-Regression)

**Curriculum Module**

_Created with R2026a. Compatible with R2026a and later releases._

# Information

This curriculum module contains interactive [MATLAB® live scripts](https://www.mathworks.com/products/matlab/live-editor.html) that introduce machine learning for regression through baseline modeling, model improvement, tree\-based methods, and optimization.

<img src="Images/image_0.png" width="280" alt="image_0.png">

<a id="H_F00D98E4"></a>

## Background

You can use these live scripts as lecture demonstrations, in\-class activities, or interactive assignments outside class. The lesson sequence starts with baseline linear regression, residual analysis, and cross\-validation, then moves to feature engineering and regularization, then to regression trees and ensembles, and finally to optimization and gradient descent for iterative training.

Together, the four scripts show a disciplined regression workflow: start with a simple baseline, diagnose where it fails, improve the representation or model family, and evaluate changes using held\-out error metrics. The instructions inside each live script guide students through the exercises one section at a time. To stop a running section midway, use the <img src="Images/image_1.png" width="19" alt="image_1.png"> Stop button in the **RUN** section of the **Live Editor** tab in the MATLAB Toolstrip.

## Contact Us

Contact the [MathWorks Educator Content Development Team](mailto:onlineteaching@mathworks.com) if you would like to provide feedback, or if you have a question.

<a id="H_30BC7141"></a>

## Prerequisites

This module does not assume any prior exposure to the subject of machine learning.

<a id="H_330E72C3"></a>

## Getting Started

### Accessing the Module

### **On MATLAB® Online**™:

Use the [<img src="Images/image_2.png" width="136" alt="image_2.png">](https://matlab.mathworks.com/open/github/v1?repo=MathWorks-Teaching-Resources/Machine-Learning-for-Regression&project=MLforRegression.prj) link to download the module. You will be prompted to log in or create a MathWorks account. The project will be loaded, and you will see an app with several navigation options to get you started.

### **On Desktop:**

Download or clone this repository. Open MATLAB, navigate to the folder containing these scripts and double\-click on [MLforRegression.prj](matlab:open('matlab:open(''MLforRegression.prj'')')). It will add the appropriate files to your MATLAB path and open an app that asks you where you would like to start. 

Ensure you have all the required products ([listed below](#H_E850B4FF)) installed. If you need to include a product, add it using the Add\-On Explorer. To install an add\-on, go to the **Home** tab and select  <img src="Images/image_3.png" width="16" alt="image_3.png"> **Add-Ons** > **Get Add-Ons**. 

<a id="H_E850B4FF"></a>

## Products

MATLAB® is used throughout. Tools from Statistics and Machine Learning Toolbox™, and System Identification Toolbox™ are used frequently as well.


<a id="H_577C7603"></a>

# Scripts
<a id="TMP_86c6"></a>

## [Overview of Machine Learning for Regression](MLOverview.m)
||||
| :-- | :-- | :-- |
| <img src="Images/image_4.png" width="145" alt="image_4.png"> <br>  | **In this script, students will...** <br> $\bullet$ recognize when simple linear regression is inadequate for real‑world data. <br> $\bullet$ evaluate and compare regression models using residuals and cross‑validation to assess generalization. <br> $\bullet$ describe the machine‑learning regression pipeline and its goal of generalization. <br>  | **Academic disciplines** <br> $\bullet$ Math <br> $\bullet$ Statistics <br> $\bullet$ Data Science <br> $\bullet$ Machine Learning <br>   |

<a id="TMP_59ba"></a>

## [Optimization and Gradient Descent for Regression](OptimizationandGradientDescentforRegression.m)
||||
| :-- | :-- | :-- |
| <img src="Images/image_5.png" width="145" alt="image_5.png"> <br>  | **In this script, students will...** <br> $\bullet$ explain how regression training can be framed as an optimization problem. <br> $\bullet$ compare SSE, MSE, and RMSE to interpret model prediction error. <br> $\bullet$ apply gradient descent updates to reduce a regression model’s cost function. <br> $\bullet$ evaluate how learning rate and iteration count affect convergence, oscillation, and model improvement. <br>  | **Academic disciplines** <br> $\bullet$ AI and Machine Learning <br> $\bullet$ Data Science <br> $\bullet$ Statistics <br> $\bullet$ Engineering <br>   |

<a id="TMP_98bc"></a>

## [Feature Engineering and Regularization](FeatureEngRegularization.m)
||||
| :-- | :-- | :-- |
| <img src="Images/image_6.png" width="145" alt="image_6.png"> <br>  | **In this script, students will...** <br> $\bullet$ apply feature transformations and compare engineered feature sets. <br> $\bullet$ use stepwise selection, Lasso, and Ridge to control model complexity. <br> $\bullet$ connect richer feature representations to generalization and interpretability. <br>  | **Academic disciplines** <br> $\bullet$ AI and Machine Learning <br> $\bullet$ Engineering <br> $\bullet$ Applied Mathematics <br>   |

<a id="TMP_8758"></a>

## [Decision Trees and Ensemble Methods](DecisionTreesandEnsembleMethods.m)
||||
| :-- | :-- | :-- |
| <img src="Images/image_7.png" width="145" alt="image_7.png"> <br>  | **In this script, students will...** <br> $\bullet$ compare different regression models and identify when each may be useful. <br> $\bullet$ explain how model structure affects predictions and interpretability. <br> $\bullet$ use visualizations and diagnostics to choose an appropriate model for a prediction task. <br>  | **Academic disciplines** <br> $\bullet$ AI and Machine Learning <br> $\bullet$ Data Science <br> $\bullet$ Statistics <br> $\bullet$ Engineering <br>   |

# Related Courseware Modules
<a id="H_5F86F1DE"></a>

## [Machine Learning Methods: Clustering](https://www.mathworks.com/matlabcentral/fileexchange/135381-machine-learning-methods-clustering)
|||
| :-- | :-- |
| <img src="Images/image_8.png" width="171" alt="image_8.png"> <br>  | **Available on:** <br> [<img src="Images/image_9.png" width="129" alt="image_9.png">](https://www.mathworks.com/matlabcentral/fileexchange/135381-machine-learning-methods-clustering)[<img src="Images/image_10.png" width="130" alt="image_10.png">](https://matlab.mathworks.com/open/github/v1?repo=MathWorks-Teaching-Resources/Machine-Learning-Methods-Clustering&project=MLMethodsClustering.prj) <br> [GitHub](https://github.com/MathWorks-Teaching-Resources/Machine-Learning-Methods-Clustering) <br>   |

<a id="TMP_1081"></a>

## [Regression Basics](https://www.mathworks.com/matlabcentral/fileexchange/93435-regression-basics)
|||
| :-- | :-- |
| <img src="Images/image_11.png" width="161" alt="image_11.png"> <br>  | **Available on:** <br> [<img src="Images/image_12.png" width="129" alt="image_12.png">](https://www.mathworks.com/matlabcentral/fileexchange/93435-regression-basics)[<img src="Images/image_13.png" width="130" alt="image_13.png">](https://matlab.mathworks.com/open/github/v1?repo=MathWorks-Teaching-Resources/regression-basics&project=RegressionBasics.prj&file=README.mlx) <br> [GitHub](https://github.com/MathWorks-Teaching-Resources/Regression-Basics) <br>   |

Or feel free to explore our other [modular courseware content](https://www.mathworks.com/matlabcentral/fileexchange/?q=tag%3A%22courseware+module%22&sort=downloads_desc_30d).

# Educator Resources
- [Educator Page](https://www.mathworks.com/academia/educators.html)

<a id="H_0FA5DA18"></a>

# Contribute 

Looking for more? Find an issue? Have a suggestion? Please contact the [MathWorks Educator Content Development Team](mailto:%20onlineteaching@mathworks.com). If you want to contribute directly to this project, you can find information about how to do so in the [CONTRIBUTING.md](https://github.com/MathWorks-Teaching-Resources/Machine-Learning-for-Regression/blob/release/CONTRIBUTING.md) page on GitHub.

*©* Copyright 2026 The MathWorks, Inc
