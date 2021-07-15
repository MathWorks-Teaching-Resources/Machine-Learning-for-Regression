# Machine Learning for Regression [![View Machine Learning for Regression on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/95903-machine-learning-for-regression) 
**Curriculum Module**  
_Created with R2021a. Compatible with R2021a and later releases._  

## Description ##
This package contains several [live scripts](https://www.mathworks.com/products/matlab/live-editor.html) and supporting files that teach the basics of machine learning for regression. The materials are designed to be flexible and can be easily modified to accommodate a variety of teaching and learning methods. These include a brief background, interactive illustrations, tasks, reflection questions, a real-world application in electricity load forecasting, and guided exercises for the different concepts explored. The module can be used to provide a light introduction to the terminology and concepts in machine learning, centered around regression. The overarching goal is to familiarize students with the typical workflow, setup, and considerations involved in solving regression problems with machine learning.  

The instructions inside the live scripts will guide you through the activities and exercises. Get started with each live script by running it one section at a time. To stop running the script or a section midway (for example, when an animation is in progress), use the **Stop** button in the **RUN** section of the Live Editor tab in the MATLAB toolstrip.  

<img src="https://user-images.githubusercontent.com/81376570/124604883-6261a280-de39-11eb-8928-7df4d87ccb58.gif" height = "600"/>  

## Suggested Prework ## 
[MATLAB Onramp](https://www.mathworks.com/learn/tutorials/matlab-onramp.html)—a free two-hour introductory tutorial to learn the essentials of MATLAB®. Additional programming skills (see [MATLAB Fundamentals](https://www.mathworks.com/training-schedule/matlab-fundamentals.html)) are beneficial, but not assumed in the tasks and instructions.  
[Regression Basics](https://www.mathworks.com/academia/courseware/regression-basics.html)—a curriculum module to cover the fundamentals of regression analyis.  

No prior exposure to the subject of machine learning is assumed.    

## Details ##
**`machineLearningIntro.mlx`**  
An interactive lesson that introduces some key concepts in machine learning, along with a few regression models. It contains many independent introductory sections that are easy to edit.

**Learning Goals**
- State the difference between regression, classification, and clustering problems.  
- Outline the common steps involved in applying machine learning techniques.
- Define feature engineering and feature extraction.
- Formulate regression as a machine learning problem.
- Identify and use the different machine learning models commonly used for regression.
- Explain overfitting and underfitting in machine learning, and identify at least two ways of tackling these problems.  

## ##
**`loadForecastRegression.mlx`, `loadForecastRegression_soln.mlx`**  
Students are guided through the steps to apply machine learning for electricity load forecasting using real-world data. This script can be used in two different modes: controls-only or with complete code.

**Learning Goals**
- Apply the steps in the machine learning workflow to solve a practical problem in time series forecasting.
- Formulate the time series forecasting problem as a machine learning problem by engineering appropriate features.
- Validate and compare different types of regression models.
- Test and evaluate the trained model to make predictions.  

## ##
**`electricityLoadDataML.mlx`**  
A supplementary script to download the external electricity load data from [New York ISO](http://mis.nyiso.com/public/) for use in `loadForecastRegression.mlx`. This script contains the code for downloading, organizing, formatting, and cleaning up the raw data.  

## ##
**`FE1_programmaticML.mlx`, `FE2_loadForecastDL.mlx`**  
These two scripts contain ideas to expand on the practical problem presented in `loadForecastRegression.mlx`. Working through the suggestions requires some independent exploration and active learning. `FE1_programmaticML.mlx` encourages students to write their own machine learning algorithm, and `FE2_loadForecastDL.mlx` begins to explore deep learning for load forecasting.  

## Products ##
MATLAB, Statistics and Machine Learning Toolbox™, Deep Learning Toolbox™

## License ##
The license for this module is available in the LICENSE.TXT file in this GitHub repository.

## Support ##
Have any questions or feedback? Contact the [MathWorks online teaching team](mailto:onlineteaching@mathworks.com).

# #
_Copyright 2021 The MathWorks, Inc._
