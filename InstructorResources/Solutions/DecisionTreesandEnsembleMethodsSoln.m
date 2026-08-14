%[text] %[text:anchor:T_BB73E10C] # Decision Trees and Ensemble Methods
%[text] [⇦ Main Menu](file:MainMenu.m)
%[text] This script supports the train-and-evaluate part of the machine learning workflow. After building candidate features and controlling complexity, the next question is whether a tree-based model can capture patterns that a single global equation still misses.
%[text]{"align":"center"} ![A decision tree](text:image:85d0)
%[text:tableOfContents]{"heading":"Table of Contents"} %[text:anchor:M_597CA885]
%[text] %[text:anchor:H_51183E7B] **Before you get started:**
%[text] %[text:anchor:H_BF646A47] This live script is intended to be used with the code hidden. On the MATLAB toolstrip, select **View** \> **Hide Code**. Alternatively, select **Hide Code** using the icon ![live script code hidden icon](text:image:3372) at the top right of the Live Editor pane.
%[text] ![Lightbulb mark](text:image:47b6) Although the code is hidden, some interactivity requires familiarity with MATLAB. If you need more instruction, consider taking [MATLAB Onramp](https://matlabacademy.mathworks.com/details/matlab-onramp/gettingstarted), a free 2-hour online tutorial that teaches the essentials of MATLAB.
%[text] %[text:anchor:H_8F8A032D] ![Warning symbol](text:image:7be8) For an optimal experience, follow the instructions and steps in the given sequence. Proceed to a new section only after completing the preceding one. Some sections depend on variables created in prior sections and will generate errors if run out of order.
%[text] The ![Try this icon](text:image:7d42) and ![Exercise icon](text:image:807a) icons mark two different kinds of interactive activities in this script. The ![Try this icon](text:image:03dc) usually marks an exploration activity that helps you visualize a concept introduced in the lesson. The ![Exercise icon](text:image:5846) marks an activity that checks your understanding and may be used for grading or completion checks by your instructor.
%%
%[text] ## Why Tree-Based Models?
%[text] A simple linear model is still a useful baseline, but many regression problems are better described by local rules or combinations of local rules. Regression trees divide the predictor space into regions using a sequence of decision rules. For example, a tree might first split on temperature and then, within one temperature range, split again on humidity. Because later decisions depend on earlier ones, trees naturally capture nonlinear behavior and interactions between predictors. However, regression trees are prone to overfitting, leading to models that can be highly sensitive to the training data and may generalize poorly to new observations. Ensemble methods address this limitation by combining predictions from many trees, reducing variability, improving robustness, and often achieving better predictive performance than a single tree. A single tree is useful when interpretability is important, while an ensemble is often preferred when prediction accuracy and stability are the primary goals.
%[text] Then your three questions become:
%[text] 1. How does a regression tree make predictions by following a sequence of decision rules?
%[text] 2. How can those decision rules capture nonlinear patterns and predictor interactions?
%[text] 3. When is an ensemble of trees preferable to a single regression tree? \
%[text] In this lesson, the main comparison is between a simple baseline and two tree-based approaches. We will focus on three questions: 
%[text] - What kind of pattern a single tree can represent?
%[text] - How does an ensemble improve on one tree?
%[text] - When is the extra flexibility worth it? \
%[text:table]
%[text] | **Model** | **Key Idea** | **Strength** |
%[text] | --- | --- | --- |
%[text] | Linear Baseline | Fit one global relationship | Simple, interpretable reference model |
%[text] | Regression Tree | Split data into regions using decision rules | Captures thresholds and local behavior |
%[text] | Ensemble of Trees | Combine predictions from many trees | Often improves accuracy and robustness |
%[text:table]
%%
%[text] ### A Quick Baseline Reminder
%[text] A single global model is still a helpful reference because it tells us what a simple approach can and cannot explain. The [Feature Engineering and Regularization](file:FeatureEngRegularization.m) lesson handles linear-model refinement in detail, so here we will treat the linear model only as a baseline for comparison.
%[text] In this lesson, the focus is different: when patterns are segmented, thresholded, or strongly nonlinear, tree-based models often become the better next step.
%[text] The comparison below highlights two different modeling decisions. In the **Feature Engineering Keeps a Global Fit** example, adding an appropriate feature allows a single regression model to capture the pattern in the data with low error. In the **Threshold Pattern Suggests a Tree** example, the data follow rule-based, threshold-like behavior that is difficult for a single regression model to represent, making a decision tree a more natural choice. Together, these examples show that improving a model may involve either engineering better features or selecting a different model family.
%[text] ![Finger touching surface icon](text:image:62ba) **Try**. Click **Display Baseline Comparison**. 
DefaultStyle = InitializeDefaultStyle();
  %[control:button:661b]{"position":[1,2]}
BaselineExample = MakeBaselineReminderExample();
tiledlayout(1,2,Padding="compact",TileSpacing="compact")
axFeature = nexttile;
FeatureScatter = scatter(axFeature,BaselineExample.FeatureCase.X,BaselineExample.FeatureCase.Y,DefaultStyle.DataMarkerSize,"filled",MarkerFaceAlpha=DefaultStyle.DataMarkerFaceAlpha,SeriesIndex=DefaultStyle.DataSeriesIndex);
hold(axFeature,"on")
FeatureFit = plot(axFeature,BaselineExample.FeatureCase.XGrid,BaselineExample.FeatureCase.YGrid,LineWidth=DefaultStyle.PrimaryLineWidth,SeriesIndex=DefaultStyle.EngineeredFeatureSeriesIndex);
hold(axFeature,"off")
xlabel(axFeature,"$x$",Interpreter=DefaultStyle.Interpreter)
ylabel(axFeature,"$y$",Interpreter=DefaultStyle.Interpreter)
title(axFeature,"Feature Engineering Keeps a Global Fit",Interpreter=DefaultStyle.Interpreter)
legend(axFeature,[FeatureScatter FeatureFit],["Data","Quadratic-feature fit"],Location="best")
ApplyDefaultAxesStyle(axFeature,DefaultStyle)
text(axFeature,0.03,0.95,"MSE = " + compose("%.2f",BaselineExample.FeatureCase.MSE),Units="normalized",VerticalAlignment="top",BackgroundColor=GetAxesBackgroundColor(axFeature),Margin=DefaultStyle.AnnotationMargin,Interpreter=DefaultStyle.Interpreter)

axThreshold = nexttile;
ThresholdScatter = scatter(axThreshold,BaselineExample.TreeCase.X,BaselineExample.TreeCase.Y,DefaultStyle.DataMarkerSize,"filled",MarkerFaceAlpha=DefaultStyle.DataMarkerFaceAlpha,SeriesIndex=DefaultStyle.DataSeriesIndex);
hold(axThreshold,"on")
ThresholdBaseline = plot(axThreshold,BaselineExample.TreeCase.XGrid,BaselineExample.TreeCase.LinearFit,"--",LineWidth=DefaultStyle.SecondaryLineWidth,SeriesIndex=DefaultStyle.LinearBaselineSeriesIndex);
ThresholdTree = plot(axThreshold,BaselineExample.TreeCase.XGrid,BaselineExample.TreeCase.TreeFit,LineWidth=DefaultStyle.PrimaryLineWidth,SeriesIndex=DefaultStyle.TreeSeriesIndex);
hold(axThreshold,"off")
xlabel(axThreshold,"$x$",Interpreter=DefaultStyle.Interpreter)
ylabel(axThreshold,"$y$",Interpreter=DefaultStyle.Interpreter)
title(axThreshold,"Threshold Pattern Suggests a Tree",Interpreter=DefaultStyle.Interpreter)
legend(axThreshold,[ThresholdScatter ThresholdBaseline ThresholdTree],["Data","Linear baseline","Tree fit"],Location="best")
ApplyDefaultAxesStyle(axThreshold,DefaultStyle)
text(axThreshold,0.03,0.95,["Linear MSE = " + compose("%.2f",BaselineExample.TreeCase.LinearMSE),"Tree MSE = " + compose("%.2f",BaselineExample.TreeCase.TreeMSE)],Units="normalized",VerticalAlignment="top",BackgroundColor=GetAxesBackgroundColor(axThreshold),Margin=DefaultStyle.AnnotationMargin,Interpreter=DefaultStyle.Interpreter)
sgtitle("Quick Baseline Reminder",Interpreter=DefaultStyle.Interpreter)
%%
%[text] ### Regression Trees
%[text] Regression trees are a **supervised learning** method that predicts outcomes by splitting data into smaller groups using simple if–else rules. Unlike linear regression, which fits one global equation, a tree makes local predictions after following a path from the root to a leaf.
%[text] The **root node** represents the first and often most important split in the data. Internal nodes apply additional decision rules that divide the predictor space into smaller regions. Each branch corresponds to the outcome of a split, directing observations left or right through the tree. The **leaf nodes** are the terminal regions of the model and contain the final prediction. A prediction is made by starting at the root node and following the appropriate branches until reaching a leaf node. This sequence of decisions allows a regression tree to make different predictions for different regions of the predictor space rather than using a single global model.
%[text] ![Finger touching surface icon](text:image:5c97) **Try**. Click **Display Parts of a Decision Tree**. 
DefaultStyle = InitializeDefaultStyle();
ShowStaticTreeDiagram(MakeTreeTerminologySpec(),DefaultStyle,FigureName="Decision Tree Anatomy",FigureSize=[820 360]);
  %[control:button:482c]{"position":[1,2]}
%%
%[text] ### Explore Decision Paths
%[text] Here, you will step through a prediction one decision at a time. Starting at the root, the model evaluates conditions such as `Hour < 12` and follows a path based on your input values. The visualization highlights each branch until the final prediction is reached. As you explore, focus on how the model evaluates decisions in sequence. Notice that only some predictors are used along a given path. Compare how different inputs lead to different predictions.
%[text] For example, if `Hour = 15` and `Temperature = 72`, the model first checks `Hour < 12`. That condition is false, so it moves to the right branch and then checks `Temperature < 80`. That condition is true, so the model predicts `5100 MW`.
%[text] ![Finger touching surface icon](text:image:51fc) **Try**. Drag the **Hour** and **Temperature** sliders to follow the decision path and view the final prediction. The figure footer and the text output below report the same path in words.
DefaultStyle = InitializeDefaultStyle();
InteractiveTreeSpec = MakeInteractiveTreeSpec();
Hour = 13; %[control:slider:981b]{"position":[8,10]}
Temperature = 55; %[control:slider:8da7]{"position":[15,17]}
InteractiveTree = EvaluateInteractiveTree(InteractiveTreeSpec,Hour,Temperature);
RenderInteractiveTreeDemo(InteractiveTreeSpec,InteractiveTree,DefaultStyle)
disp(FormatTreeDecisionTrace(InteractiveTreeSpec,InteractiveTree))
disp("Predicted Load = " + compose("%.0f",InteractiveTree.Prediction) + " MW")
%[text] %[text:anchor:TMP_0026] ![Lightbulb Icon](text:image:6b8e) **Reflect**. How many leaf nodes does the tree contain? What variable is used for splitting? What values appear at the leaf nodes? How does this differ from the coefficient-based representation of linear regression? 
%%
%[text] ![Pencil on board icon](text:image:097c) **Exercise 1.** For the decision tree shown in the figure and described below, if `Hour = 9` and `Temp = 63 deg F`, what will the load be?
%[text] 
%[text]{"align":"center"} ![Tree description: if Hour \< 9, predict 4200 MW. Otherwise, check Temp \< 60 deg F. If that condition is true, predict 5100 MW. Otherwise, predict 6200 MW.](text:image:4446)
CheckAnswer("Exercise1",6200) %[control:dropdown:4e16]{"position":[25,29]}
%%
%[text] #### Connecting Tree Structure to Model Predictions
%[text] Regression trees can be viewed both as a collection of decision rules and as a fitted function. Showing these perspectives side by side helps connect each split to both a branching rule in the tree and a change in the model’s predictions. As additional splits are added, the tree grows more complex and the fitted curve becomes more detailed. This makes it easier to see how decision boundaries create distinct prediction regions.
%[text] ![Finger touching surface icon](text:image:3875) **Try**. Drag the **Number of Splits** slider to change the number of splits and observe how the fitted curve changes. As the tree grows, it can fit the training data more closely, but too many splits can overfit and may require pruning or validation-based model selection.
DefaultStyle = InitializeDefaultStyle();
[x,y] = GetLoadMayDayData();
N =2; %[control:slider:53cf]{"position":[4,5]}
mdl = ShowRegressionTreeSideBySide(x,y,N,DefaultStyle);
%%
%[text] ### **Ensemble of Trees**
%[text] Decision trees partition the predictor space into regions and fit a simple prediction within each region. They are easy to interpret but can be sensitive to noise and small changes in the data. Ensemble methods improve performance by combining many trees into a single model. A single shallow tree, often called a weak learner, captures only simple patterns, but many trees working together can form a stronger predictor. Two common ensemble approaches are **bagging** and **boosting**.
%[text] - **Bagging (bootstrap aggregation)** trains trees independently on different random subsets of the data and averages their predictions, reducing variance and improving stability.
%[text] - **Boosting** trains trees sequentially, with each new tree focusing on correcting errors made by the current ensemble, reducing bias and improving accuracy.  \
%[text] The animation below still emphasizes boosting so you can watch later trees correct earlier errors in sequence, but the comparison now includes bagging on the same data. This makes it easier to see the difference between averaging many independently fit trees and sequentially correcting residual error. While training error typically decreases as more trees are added, generalization should be evaluated using validation or holdout data rather than training error alone.
%[text] In the top plot, the filled circles are the observed training data. The dashed line is the prediction from one single regression tree, used as a baseline. The bagging and boosting curves show how the ensemble prediction changes as more trees are added.
%[text] In the summary, **bagging gain** and **boosting gain** mean the percent reduction in training MSE relative to that single-tree baseline. A positive value means the ensemble fit the training data better than one tree; a negative value means it did worse on training MSE for that setting.
%[text] `NumTrees` is the number of trees included in the ensemble, while `MaxSplits` is the number of decision splits each individual tree is allowed to make, so it controls the complexity of each tree rather than the number of trees.
%[text] ![Finger touching surface icon](text:image:568c) **Try**. Click **Fit Ensemble of Trees** to view an example that models the hourly electricity load in a single day.
%[text] 1. Drag the **`NumTrees`** slider to increase the number of trees in the ensemble, then click **Fit Ensemble of Trees** to rerun this section.
%[text] 2. Drag the **`NumSplits`** slider to increase tree depth, then click **Fit Ensemble of Trees** to rerun this section.
%[text] 3. Compare the bagging and boosting curves, then note which one reduces training error more quickly and which one looks more stable. \
DefaultStyle = InitializeDefaultStyle();
[x,y] = GetLoadMayDayData();
NumTrees = 2; %[control:slider:1fad]{"position":[12,13]}
NumSplits = 2; %[control:slider:0685]{"position":[13,14]}
  %[control:button:2f23]{"position":[1,2]}

if ~isfinite(NumTrees)
    NumTrees = 2;
end
if ~isfinite(NumSplits)
    NumSplits = 2;
end
NumTrees = max(1,round(NumTrees));
NumSplits = max(1,round(NumSplits));

ens = ShowEnsembleTreeDemo(x,y,NumTrees,NumSplits,DefaultStyle);
%[text] ![Lightbulb Icon](text:image:0158) **Reflect**. How many trees do you think we need before the fit stabilizes? Will adding trees make the prediction more or less flexible? Why might the ensemble outperform a single tree?
%%
%[text] ### Connection to Feature Engineering and Regularization
%[text] If our main problem is too many predictors rather than the wrong model family, return to the [Feature Engineering and Regularization](file:FeatureEngRegularization.m) lesson which focuses on stepwise regression, Lasso, and other ways to keep a linear model smaller and easier to generalize.
%[text] In this lesson, we stay with a different question: when a linear baseline is still too rigid, does a single tree help, or do we need an ensemble of trees?
%%
%[text] ### Choosing Between a Baseline, a Tree, and an Ensemble
%[text] After learning how regression trees make predictions, the next step is deciding which model is most appropriate for a particular problem. In practice, model selection is part of the **train-and-evaluate** stage of the machine learning workflow. Rather than trying every possible model, you can often begin by looking at the overall structure of the data.
%[text] As you explore the examples below, look for the relationship between the predictors and the response. Ask yourself:
%[text] - Does the data follow a mostly linear trend?
%[text] - Is there a smooth nonlinear pattern that could be captured by a single global model?
%[text] - Do clear thresholds or regions appear where different rules seem to apply?
%[text] - Does the data contain complex patterns or substantial noise? \
%[text] The answers to these questions can help guide your model choice. Linear regression provides a simple, interpretable baseline when a single trend describes the data well. Regression trees are useful when predictions depend on thresholds or local decision rules. Ensembles of trees combine many trees to improve stability and predictive accuracy when patterns become more complex or noisy.
%[text]{"align":"center"} ![Four scatter plots comparing different data patterns: a mostly linear trend, a smooth nonlinear curve, threshold-based clusters with distinct regions, and a complex nonlinear pattern with noise.](text:image:6715)
%[text] The examples below illustrate common data patterns and the modeling approaches that are often a good starting point for each one. As you compare the plots, focus on what features of the data motivate the choice of model.
%[text:table]
%[text] | **If your data looks like...** | **Try this model** | **Why** |
%[text] | --- | --- | --- |
%[text] | Mostly linear trends | Linear Regression | Useful baseline and easy to interpret |
%[text] | Smooth global nonlinear patterns | Feature engineering or nonlinear regression | Keeps one global model while capturing curvature |
%[text] | Thresholds or segmented regions | Regression Tree | Captures local rules directly |
%[text] | Complex nonlinear patterns with noise | Ensemble of Trees | Improves stability and predictive accuracy |
%[text:table]
%%
%[text] ![Finger touching surface icon](text:image:9c28) **Try**. Select a dataset from the **Select a dataset** dropdown menu and predict which model will perform best based on the pattern you observe.
%[text] Dataset summaries: Dataset 1 is mostly linear. Dataset 2 is a smooth nonlinear parabola. Dataset 3 combines periodic structure, trend, and noise. Dataset 4 uses thresholded multivariate interactions. Use these summaries if you cannot inspect the plots visually.
%%\ Create Multiple Example Datasets
DataSetChoice = "Dataset 2: Nonlinear"; %[control:dropdown:8310]{"position":[17,39]}
[T,predictorVars,plotTitle,PatternSummary,isMultivariate] = GetExampleDataset(DataSetChoice);
if isempty(T)
    disp("Select a valid option.")
    return
end

%%\ Dataset Visualization
DefaultStyle = InitializeDefaultStyle();
if isMultivariate
    figure
    tiledlayout(1,2,Padding="compact",TileSpacing="compact")

    axX1 = nexttile;
    scatter(axX1,T.X1,T.Y,DefaultStyle.DataMarkerSize,"filled",MarkerFaceAlpha=DefaultStyle.DataMarkerFaceAlpha,SeriesIndex=DefaultStyle.DataSeriesIndex)
    xlabel(axX1,"$X_1$",Interpreter=DefaultStyle.Interpreter)
    ylabel(axX1,"$Y$",Interpreter=DefaultStyle.Interpreter)
    title(axX1,"Threshold Pattern in $X_1$",Interpreter=DefaultStyle.Interpreter)
    ApplyDefaultAxesStyle(axX1,DefaultStyle)

    axX2 = nexttile;
    scatter(axX2,T.X2,T.Y,DefaultStyle.DataMarkerSize,"filled",MarkerFaceAlpha=DefaultStyle.DataMarkerFaceAlpha,SeriesIndex=DefaultStyle.DataSeriesIndex)
    xlabel(axX2,"$X_2$",Interpreter=DefaultStyle.Interpreter)
    ylabel(axX2,"$Y$",Interpreter=DefaultStyle.Interpreter)
    title(axX2,"Threshold Pattern in $X_2$",Interpreter=DefaultStyle.Interpreter)
    ApplyDefaultAxesStyle(axX2,DefaultStyle)
else
    figure
    scatter(T.X,T.Y,DefaultStyle.DataMarkerSize,"filled",MarkerFaceAlpha=DefaultStyle.DataMarkerFaceAlpha,SeriesIndex=DefaultStyle.DataSeriesIndex,DisplayName=DataSetChoice)

    xlabel("$X$",Interpreter=DefaultStyle.Interpreter)
    ylabel("$Y$",Interpreter=DefaultStyle.Interpreter)
    title(plotTitle,Interpreter=DefaultStyle.Interpreter)

    ApplyDefaultAxesStyle(gca,DefaultStyle)
end
disp(PatternSummary)
%%
%[text] ### Compare Model Performance
%[text] Run these models on the dataset you selected in the previous section to evaluate how well each approach captures the underlying patterns. Compare model accuracy using mean squared error (MSE) and examine the prediction plots to see when a single tree is enough and when an ensemble improves on it. Use the MSE table as the primary text summary of model differences, and use the plots as visual confirmation.
%[text] ![](text:image:1960) **Try**. Click **Compare Regression Models** to view an example that models the hourly electricity load in a single day.
%%\ Compare Regression Models
  %[control:button:9a2e]{"position":[1,2]}
DefaultStyle = InitializeDefaultStyle();
[TTrain,predictorVars,plotTitle,~,isMultivariate] = GetExampleDataset(DataSetChoice);
if isempty(TTrain)
    disp("Select a valid dataset option first.")
    return
end

% Partition data (30% holdout)
cv = cvpartition(height(TTrain),HoldOut=0.3);
idx = training(cv);
Ttrain = TTrain(idx,:);
Ttest  = TTrain(~idx,:);

% Extract predictors and response for training and testing
Xtrain = Ttrain{:,predictorVars};
Ytrain = Ttrain{:,"Y"};

Xtest = Ttest{:,predictorVars};
Ytest = Ttest{:,"Y"};

% Ensure correct shapes: for univariate, use column vectors; for multivariate keep as matrix
if isvector(Xtrain) || size(Xtrain,2)==1
    Xtrain = Xtrain(:);
    Xtest = Xtest(:);
end
Ytrain = Ytrain(:);
Ytest = Ytest(:);

%%\ 1. Linear Regression
mdlLinear = fitlm(Ttrain(:,[predictorVars,"Y"]),"Y");

%%\ 2. Regression Tree
mdlTree = fitrtree(Xtrain,Ytrain);

%%\ 3. Ensemble Model
mdlEnsemble = fitrensemble(Xtrain,Ytrain);

%%\ Make Predictions
yPredLinear = predict(mdlLinear,Xtest);
yPredTree = predict(mdlTree,Xtest);
yPredEnsemble = predict(mdlEnsemble,Xtest);

%%\ Compute MSE
mse = @(y,yhat) mean((y - yhat).^2);

MSELinear = mse(Ytest,yPredLinear);
MSETree = mse(Ytest,yPredTree);
MSEEnsemble = mse(Ytest,yPredEnsemble);

%%\ Compare Results
ModelNames = ["Linear Baseline"; "Tree"; "Ensemble"];
MSEValues = [MSELinear; MSETree; MSEEnsemble];

ResultsTable = table(ModelNames,MSEValues);
%[text:anchor:TMP_5a30]
BestModelName = ModelNames(find(MSEValues == min(MSEValues),1,"first"));
disp("Comparison summary: Lower MSE indicates the better fit on this dataset. The lowest MSE here is from " + BestModelName + ".")


%%\ Visualize Model Fits in Dataset Space

figure(Units="normalized",Position=[0.05 0.05 0.9 1.1])
tiledlayout(1,3,Padding="compact",TileSpacing="compact")

models = {mdlLinear,mdlTree,mdlEnsemble};
titles = ["Linear Baseline","Tree","Ensemble"];

if isMultivariate
    xPlot = Ttest.X1;
    yPlot = Ytest;
    xGrid = linspace(min(TTrain.X1),max(TTrain.X1),300)';
    x2Reference = median(TTrain.X2);
    PredictionTable = table(xGrid,repmat(x2Reference,size(xGrid)),VariableNames={'X1','X2'});
    xLabel = "$X_1$";
    yLabel = "$Y$";
    titleSuffix = " (slice at median $X_2$)";
else
    xPlot = Ttest.X;
    yPlot = Ytest;
    xGrid = linspace(min(TTrain.X),max(TTrain.X),300)';
    PredictionTable = table(xGrid,VariableNames={'X'});
    xLabel = "$X$";
    yLabel = "$Y$";
    titleSuffix = ": " + plotTitle;
end

for i = 1:3
    axModel = nexttile;
    scatter(axModel,xPlot,yPlot,DefaultStyle.DataMarkerSize,"filled",MarkerFaceAlpha=DefaultStyle.DataMarkerFaceAlpha,SeriesIndex=DefaultStyle.DataSeriesIndex)
    hold(axModel,"on")
    if i == 1
        yFit = predict(models{i},PredictionTable);
    else
        yFit = predict(models{i},PredictionTable{:,predictorVars});
    end
    plot(axModel,xGrid,yFit,LineWidth=DefaultStyle.PrimaryLineWidth,SeriesIndex=DefaultStyle.TreeSeriesIndex)
    xlabel(axModel,xLabel,Interpreter=DefaultStyle.Interpreter)
    ylabel(axModel,yLabel,Interpreter=DefaultStyle.Interpreter)
    title(axModel,(titles(i) + titleSuffix),Interpreter=DefaultStyle.Interpreter)
    ApplyDefaultAxesStyle(axModel,DefaultStyle)
end
figure
hMSE = bar(MSEValues); %[text:anchor:TMP_5a30]
hMSE.SeriesIndex = DefaultStyle.ComparisonSeriesIndex; %[text:anchor:TMP_5a30]
xticks(1:numel(ModelNames))
xticklabels(ModelNames)
xtickangle(45)
ylabel("MSE",Interpreter=DefaultStyle.Interpreter) %[text:anchor:TMP_5a30]
title("Model Comparison",Interpreter=DefaultStyle.Interpreter) %[text:anchor:TMP_5a30]
ApplyDefaultAxesStyle(gca,DefaultStyle) %[text:anchor:TMP_5a30]

disp(ResultsTable)
%%
%[text] ![Pencil on board icon](text:image:0a55) **Exercise 2.** A dataset shows clear thresholds or segmented regions rather than one smooth global trend. Which model is the best first flexible choice?
CheckAnswer("Exercise2","Regression Tree"); %[control:dropdown:4419]{"position":[25,42]}
%%
%[text] ![Pencil on board icon](text:image:496f) **Exercise 3.** A dataset shows a complex pattern with trends, noise, and nonlinear relationships. Which model is most appropriate?
CheckAnswer("Exercise3","Ensemble of Trees"); %[control:dropdown:2b4a]{"position":[25,44]}
%%
%[text] ### Summary
%[text] This lesson focused on when tree-based regression models are worth using. We used a simple linear model as a baseline, explored how a regression tree makes local decisions, and then saw how ensembles combine many trees to improve predictive performance. These activities showed how model choice depends on whether the data look mostly global, strongly segmented, or complex and noisy.
%%
%[text] ## Further Exploration
%[text] Review the [Additional Resources](file:../../InstructorResources/AdditionalResources.m:M_080d) section to find more materials for further learning.
%%
%[text] [⇦ Return to Main Menu](file:MainMenu.m)
%%
%[text] %[text:anchor:H_0AAABA39] ## Local Helper Functions
%[text] If you wish to see the details of the code, on the MATLAB toolstrip select **View** \> **Output Inline**. Alternatively, select **Output Inline** using the icon ![live script output inline icon](text:image:4a93) at the top right of the Live Editor pane.
function Style = InitializeDefaultStyle()
Style = DefaultPlotStyle();
ApplyDefaultStyle(Style);
end
%%
function [T,predictorVars,plotTitle,PatternSummary,isMultivariate] = GetExampleDataset(DataSetChoice)

arguments
    DataSetChoice (1,1) string
end

rng default
n = 150;

T = table();
predictorVars = strings(1,0);
plotTitle = "";
PatternSummary = "";
isMultivariate = false;

switch DataSetChoice
    case {"Dataset 1","Dataset 1: Mostly Linear"}
        X = randn(n,1) * 10;
        Y = 3*X + 5 + randn(n,1)*5;
        T = table(X,Y);
        predictorVars = "X";
        plotTitle = "Dataset 1: Mostly Linear";
        PatternSummary = "Pattern summary: Dataset 1 follows a mostly linear trend with noise, so a global linear model can be competitive.";

    case {"Dataset 2","Dataset 2: Nonlinear"}
        X = linspace(-10,10,n)';
        Y = X.^2 + randn(n,1)*10;
        T = table(X,Y);
        predictorVars = "X";
        plotTitle = "Dataset 2: Nonlinear";
        PatternSummary = "Pattern summary: Dataset 2 is a smooth nonlinear parabola, so feature engineering or another global nonlinear model may work well.";

    case {"Dataset 3","Dataset 3: Complex"}
        X = linspace(0,24,n)';
        Y = 50 + 10*sin(X/24*2*pi) + 0.5*X + randn(n,1)*8;
        T = table(X,Y);
        predictorVars = "X";
        plotTitle = "Dataset 3: Complex";
        PatternSummary = "Pattern summary: Dataset 3 mixes periodic structure, trend, and noise, so more flexible models may outperform a simple global line.";

    case {"Dataset 4","Dataset 4: Multivariate with Interactions","Dataset 4:Multivariate with Interactions"}
        X1 = 10*rand(n,1);
        X2 = 10*rand(n,1);
        Y = 20 + 6*(X1 > 5) + 8*(X2 > 6) + 0.8*X1.*(X2 > 6) + randn(n,1)*1.8;
        T = table(X1,X2,Y);
        predictorVars = ["X1","X2"];
        plotTitle = "Dataset 4: Multivariate with Interactions";
        PatternSummary = "Pattern summary: Dataset 4 uses thresholded multivariate interactions, so tree-based models are a natural candidate.";
        isMultivariate = true;

    otherwise
        return
end

end
%%
function mdl = ShowRegressionTreeSideBySide(x,y,N,Style)
% ShowRegressionTreeSideBySide
% Animate a regression tree fit alongside its tree structure.

arguments
    x (:,1) double
    y (:,1) double
    N (1,1) {mustBeInteger,mustBePositive}
    Style (1,1) struct = DefaultPlotStyle()
end

xnew = linspace(min(x),max(x),400)';
fig = figure(Name="Regression Tree: Fit and Structure",NumberTitle="off");
ApplyFullscreenFigure(fig)
t = tiledlayout(fig,1,2,TileSpacing="compact",Padding="compact");

axFit = nexttile(t,1);
dataScatter = scatter(axFit,x,y,Style.DataMarkerSize,"filled",MarkerFaceAlpha=Style.DataMarkerFaceAlpha,SeriesIndex=Style.DataSeriesIndex);
hold(axFit,"on")
fitLine = plot(axFit,xnew,nan(size(xnew)),LineWidth=Style.PrimaryLineWidth,SeriesIndex=Style.TreeSeriesIndex);
splitLegend = plot(axFit,nan,nan,"--",LineWidth=Style.SecondaryLineWidth,SeriesIndex=Style.ReferenceSeriesIndex);
fitLegend = legend(axFit,[dataScatter fitLine splitLegend],["Data","Tree fit","Decision splits"],Location="best");
fitLegend.Interpreter = char(Style.Interpreter);
xlabel(axFit,"x",Interpreter=Style.Interpreter)
ylabel(axFit,"y",Interpreter=Style.Interpreter)
title(axFit,"Regression Tree Fit",Interpreter=char(Style.Interpreter))
ApplyDefaultAxesStyle(axFit,Style)
xlim(axFit,[min(x) max(x)])

axTree = nexttile(t,2);
axis(axTree,"off")
xlim(axTree,[0 1])
ylim(axTree,[0 1])
title(axTree,"Tree Structure",Interpreter=char(Style.Interpreter))

for NumSplits = 1:N
    mdl = fitrtree(x,y,MaxNumSplits=NumSplits,MinParentSize=2,Prune="off");
    fitLine.YData = predict(mdl,xnew);

    if NumSplits > 1
        validLines = splitLines(isgraphics(splitLines));
        if ~isempty(validLines)
            delete(validLines)
        end
    end

    splitPoints = mdl.CutPoint(~isnan(mdl.CutPoint));
    splitLines = gobjects(numel(splitPoints),1);
    for k = 1:numel(splitPoints)
        splitLines(k) = xline(axFit,splitPoints(k),"--",LineWidth=Style.SecondaryLineWidth,SeriesIndex=Style.ReferenceSeriesIndex);
        splitLines(k).Annotation.LegendInformation.IconDisplayStyle = "off";
    end

    RenderRegressionTree(axTree,mdl,Style)
    title(axTree,"Tree Structure (" + string(NumSplits) + " split" + pluralS(NumSplits) + ")",Interpreter=char(Style.Interpreter))
    drawnow

    if NumSplits < N
        pause(0.6)
    end
end

end
%%
function RenderRegressionTree(Ax,mdl,Style)

arguments
    Ax
    mdl
    Style (1,1) struct = DefaultPlotStyle()
end

Layout = MakeRegressionTreeLayout(mdl);
children = mdl.Children;
branchLabelFontSize = ResolveTreeFontSize( ...
    Style.TreeBranchLabelFontSize, ...
    max(Layout.NumLeaves - Style.TreeDenseLeafThreshold,0), ...
    Style.TreeFontShrinkScale, ...
    Style.MinimumTreeBranchFontSize);
nodeFontSize = ResolveTreeFontSize( ...
    Style.TreeNodeFontSize, ...
    ceil(max(Layout.NumLeaves - Style.TreeDenseNodeThreshold,0) / Style.TreeDenseNodeStep), ...
    Style.TreeFontShrinkScale, ...
    Style.MinimumTreeNodeFontSize);

cla(Ax)
hold(Ax,"on")
axis(Ax,"off")
xlim(Ax,[0 1])
ylim(Ax,[0 1])
ApplyDefaultAxesStyle(Ax,Style)

for k = 1:Layout.NumNodes
    if ~mdl.IsBranchNode(k)
        continue
    end

    parentPos = Layout.Positions(k,:);
    leftChild = children(k,1);
    rightChild = children(k,2);

    if leftChild > 0
        leftPos = Layout.Positions(leftChild,:);
        plot(Ax,[parentPos(1) leftPos(1)],[parentPos(2)-Layout.NodeHeight/2 leftPos(2)+Layout.NodeHeight/2],LineWidth=Style.TreeDiagramLineWidth,SeriesIndex=Style.TreeBackgroundSeriesIndex)
        drawBranchLabel(Ax,0.52*parentPos + 0.48*leftPos + [-0.03 0.03],"yes",Style,FontSize=branchLabelFontSize)
    end

    if rightChild > 0
        rightPos = Layout.Positions(rightChild,:);
        plot(Ax,[parentPos(1) rightPos(1)],[parentPos(2)-Layout.NodeHeight/2 rightPos(2)+Layout.NodeHeight/2],LineWidth=Style.TreeDiagramLineWidth,SeriesIndex=Style.TreeBackgroundSeriesIndex)
        drawBranchLabel(Ax,0.52*parentPos + 0.48*rightPos + [0.03 0.03],"no",Style,FontSize=branchLabelFontSize)
    end
end

for k = 1:Layout.NumNodes
    if mdl.IsBranchNode(k)
        drawNode(Ax,Layout.Positions(k,:),Layout.Labels(k),Style,Width=Layout.NodeWidth,Height=Layout.NodeHeight,EdgeColor=GetSeriesColor(Ax,Style.TreeBranchNodeSeriesIndex),FontSize=nodeFontSize)
    else
        drawNode(Ax,Layout.Positions(k,:),Layout.Labels(k),Style,Width=Layout.NodeWidth,Height=Layout.NodeHeight,EdgeColor=GetSeriesColor(Ax,Style.TreeLeafNodeSeriesIndex),FontSize=nodeFontSize)
    end
end

end
%%
function Layout = MakeRegressionTreeLayout(mdl)

arguments
    mdl
end

numNodes = mdl.NumNodes;
children = mdl.Children;
parent = mdl.Parent;
depth = ones(numNodes,1);

for k = 2:numNodes
    depth(k) = depth(parent(k)) + 1;
end

xOrder = nan(numNodes,1);
leafCount = 0;
AssignLeafOrder(1)

if leafCount == 1
    x = 0.5*ones(numNodes,1);
else
    x = 0.10 + 0.80*(xOrder - 1)/(leafCount - 1);
end

maxDepth = max(depth);
if maxDepth == 1
    y = 0.50*ones(numNodes,1);
else
    y = 0.88 - 0.68*(depth - 1)/(maxDepth - 1);
end

labels = strings(numNodes,1);
for k = 1:numNodes
    if mdl.IsBranchNode(k)
        labels(k) = "x < " + compose("%.1f",mdl.CutPoint(k));
    else
        labels(k) = compose("%.0f",mdl.NodeMean(k));
    end
end

nodeWidth = max(0.09,min(0.20,0.95/max(leafCount,5)));
nodeHeight = 0.08;

if leafCount > 8
    nodeWidth = max(0.075,0.80/leafCount);
end

if maxDepth > 4
    nodeHeight = 0.07;
end

Layout = struct("Positions",[x y], ...
    "Labels",labels, ...
    "NodeWidth",nodeWidth, ...
    "NodeHeight",nodeHeight, ...
    "NumLeaves",leafCount, ...
    "NumNodes",numNodes);

    function AssignLeafOrder(nodeIndex)
        if nodeIndex == 0
            return
        end

        if ~mdl.IsBranchNode(nodeIndex)
            leafCount = leafCount + 1;
            xOrder(nodeIndex) = leafCount;
            return
        end

        leftChild = children(nodeIndex,1);
        rightChild = children(nodeIndex,2);

        AssignLeafOrder(leftChild)
        AssignLeafOrder(rightChild)
        childNodes = children(nodeIndex,children(nodeIndex,:) > 0);
        xOrder(nodeIndex) = mean(xOrder(childNodes));
    end

end
%%
function s = pluralS(n)

arguments
    n (1,1) double
end

if n == 1
    s = "";
else
    s = "s";
end

end
%%
function CheckAnswer(exerciseID,option)

arguments
    exerciseID (1,1) string
    option
end

Exercises = struct();
ExerciseTree = MakeExerciseTreeSpec();
ExerciseState = EvaluateInteractiveTree(ExerciseTree,ExerciseTree.ExampleHour,ExerciseTree.ExampleTemperature);
Exercises.Exercise1 = struct("Answer",ExerciseState.Prediction,"Hint","Start at the root and follow the split conditions in order. Use the hour branch first, then apply the temperature rule only if that branch continues.");
Exercises.Exercise2 = struct("Answer","Regression Tree","Hint","Which model is designed to split the data into local regions or rules?");
Exercises.Exercise3 = struct("Answer","Ensemble of Trees","Hint","Which model combines many trees to improve accuracy on complex, noisy data?");

ExerciseName = char(exerciseID);
if ~isfield(Exercises,ExerciseName)
    return
end

CorrectAnswer = Exercises.(ExerciseName).Answer;
HintText = Exercises.(ExerciseName).Hint;

if isequal(option,"Select")
    return
elseif isequal(option,CorrectAnswer)
    disp("You are correct.")
else
    disp("Hint: " + HintText)
end

end
%%
function CheckPatternModelMatch(selection)

arguments
    selection (1,4) string
end

correctSelection = ["Linear Regression","Stepwise Regression","Ensemble of Trees","Regression Tree"];

if any(selection == "Select")
    warning("Select one model in each row.");
elseif isequal(selection,correctSelection)
    disp("You are correct.")
else
    disp("Not quite. Match the rows to the pattern type: linear, smooth nonlinear, threshold-based, or complex and noisy.")
end

end
%%
function drawNode(Ax,pos,label,Style,options)

arguments
    Ax
    pos (1,2) double
    label
    Style (1,1) struct
    options.Highlight (1,1) logical = false
    options.Width (1,1) double = 0.18
    options.Height (1,1) double = 0.08
    options.EdgeColor double = []
    options.FaceColor double = []
    options.FontSize (1,1) double = Style.TreeNodeFontSize
    options.Interpreter = string(Style.Interpreter)
    options.Padding (1,2) double = [0.018 0.016]
end

axesBackgroundColor = GetAxesBackgroundColor(Ax);
edgeColor = GetSeriesColor(Ax,Style.TreeNodeEdgeSeriesIndex);
faceColor = axesBackgroundColor;
lineWidth = 1.2;

if options.Highlight
    edgeColor = GetSeriesColor(Ax,Style.TreeNodeHighlightSeriesIndex);
    faceColor = BlendTowardBackground(edgeColor,axesBackgroundColor,0.82);
    lineWidth = 2;
end

if ~isempty(options.EdgeColor)
    edgeColor = options.EdgeColor;
end

if ~isempty(options.FaceColor)
    faceColor = options.FaceColor;
end

interpreter = char(options.Interpreter);
labelExtent = MeasureTextExtent(Ax,pos,string(label),options.FontSize,interpreter);
xPad = options.Padding(1) * abs(diff(xlim(Ax)));
yPad = options.Padding(2) * abs(diff(ylim(Ax)));
nodeWidth = max(options.Width,labelExtent(3) + 2*xPad);
nodeHeight = max(options.Height,labelExtent(4) + 2*yPad);

rectangle(Ax,Position=[pos(1)-nodeWidth/2 pos(2)-nodeHeight/2 nodeWidth nodeHeight],EdgeColor=edgeColor,FaceColor=faceColor,LineWidth=lineWidth,Curvature=0.1,Clipping="off")
text(Ax,pos(1),pos(2),string(label),HorizontalAlignment="center",VerticalAlignment="middle",FontSize=options.FontSize,Interpreter=interpreter,Clipping="off")

end
%%
function drawBranchLabel(Ax,pos,label,Style,options)

arguments
    Ax
    pos (1,2) double
    label
    Style (1,1) struct
    options.FontSize (1,1) double = Style.TreeBranchLabelFontSize
    options.Interpreter = string(Style.Interpreter)
    options.Padding (1,2) double = [0.012 0.014]
end

interpreter = char(options.Interpreter);
labelExtent = MeasureTextExtent(Ax,pos,string(label),options.FontSize,interpreter);
xPad = options.Padding(1) * abs(diff(xlim(Ax)));
yPad = options.Padding(2) * abs(diff(ylim(Ax)));
labelWidth = labelExtent(3) + 2*xPad;
labelHeight = labelExtent(4) + 2*yPad;

labelBackgroundColor = GetAxesBackgroundColor(Ax);
labelEdgeColor = BlendTowardBackground(GetSeriesColor(Ax,Style.TreeBackgroundSeriesIndex),labelBackgroundColor,0.85);
rectangle(Ax,Position=[pos(1)-labelWidth/2 pos(2)-labelHeight/2 labelWidth labelHeight],EdgeColor=labelEdgeColor,FaceColor=labelBackgroundColor,Curvature=0.12,Clipping="off")
text(Ax,pos(1),pos(2),string(label),HorizontalAlignment="center",VerticalAlignment="middle",FontWeight="bold",FontSize=options.FontSize,Interpreter=interpreter,Clipping="off")

end
%%
function extent = MeasureTextExtent(Ax,pos,label,fontSize,interpreter)

tempText = text(Ax,pos(1),pos(2),string(label),HorizontalAlignment="center",VerticalAlignment="middle",FontSize=fontSize,Interpreter=interpreter,Visible="off",Clipping="off");
extent = tempText.Extent;
delete(tempText)

end
%%
function fig = ShowStaticTreeDiagram(TreeSpec,Style,options)

arguments
    TreeSpec (1,1) struct
    Style (1,1) struct = DefaultPlotStyle()
    options.FigureName string = "Decision Tree Diagram"
    options.FigureSize (1,2) double = [820 360]
    options.ShowTitle (1,1) logical = true
end

fig = figure(Name=char(options.FigureName));
fig.Units = "pixels";
fig.Position(3:4) = options.FigureSize;
ax = axes(fig,Position=[0.05 0.08 0.90 0.84]);
ApplyDefaultAxesStyle(ax,Style)
RenderTreeDiagram(ax,TreeSpec,Style,ShowTitle=options.ShowTitle)
set(groot,"CurrentFigure",[])

end
%%
function RenderTreeDiagram(Ax,TreeSpec,Style,options)

arguments
    Ax
    TreeSpec (1,1) struct
    Style (1,1) struct = DefaultPlotStyle()
    options.HighlightNodeNames = strings(0,1)
    options.HighlightBranchNames = strings(0,1)
    options.ShowTitle (1,1) logical = true
    options.NodeFontSize (1,1) double = Style.TreeNodeFontSize
    options.BranchLabelFontSize (1,1) double = Style.TreeBranchLabelFontSize
end

cla(Ax)
hold(Ax,"on")
axis(Ax,"off")
xlim(Ax,TreeSpec.XLim)
ylim(Ax,TreeSpec.YLim)
ApplyDefaultAxesStyle(Ax,Style)

if options.ShowTitle && isfield(TreeSpec,"Title") && strlength(string(TreeSpec.Title)) > 0
    title(Ax,string(TreeSpec.Title),Interpreter=char(Style.Interpreter))
end

for k = 1:numel(TreeSpec.Branches)
    PlotNamedTreeBranch(Ax,TreeSpec,TreeSpec.Branches(k).Name,Style,false)
end

for k = 1:numel(options.HighlightBranchNames)
    PlotNamedTreeBranch(Ax,TreeSpec,options.HighlightBranchNames(k),Style,true)
end

for k = 1:numel(TreeSpec.Nodes)
    node = TreeSpec.Nodes(k);
    nodeName = string(node.Name);
    nodeWidth = 0.18;
    nodeHeight = 0.08;
    nodeInterpreter = string(Style.Interpreter);

    if isfield(node,"Width") && ~isnan(node.Width)
        nodeWidth = node.Width;
    end

    if isfield(node,"Height") && ~isnan(node.Height)
        nodeHeight = node.Height;
    end

    if isfield(node,"Interpreter") && strlength(string(node.Interpreter)) > 0
        nodeInterpreter = string(node.Interpreter);
    end

    if string(node.Kind) == "leaf"
        edgeColor = GetSeriesColor(Ax,Style.TreeLeafNodeSeriesIndex);
    else
        edgeColor = GetSeriesColor(Ax,Style.TreeBranchNodeSeriesIndex);
    end

    drawNode(Ax,node.Position,node.Label,Style, ...
        Highlight=any(string(options.HighlightNodeNames) == nodeName), ...
        Width=nodeWidth, ...
        Height=nodeHeight, ...
        EdgeColor=edgeColor, ...
        FontSize=options.NodeFontSize, ...
        Interpreter=nodeInterpreter)
end

for k = 1:numel(TreeSpec.Branches)
    branch = TreeSpec.Branches(k);
    if strlength(string(branch.Label)) == 0
        continue
    end

    drawBranchLabel(Ax,branch.LabelPosition,branch.Label,Style,FontSize=options.BranchLabelFontSize)
end

end
%%
function PlotNamedTreeBranch(Ax,TreeSpec,BranchName,Style,highlighted)

arguments
    Ax
    TreeSpec (1,1) struct
    BranchName
    Style (1,1) struct = DefaultPlotStyle()
    highlighted (1,1) logical = false
end

branch = GetTreeBranch(TreeSpec,BranchName);
[startPos,endPos] = GetTreeBranchEndpoints(TreeSpec,branch);

if highlighted
    plot(Ax,[startPos(1) endPos(1)],[startPos(2) endPos(2)],LineWidth=Style.TreeHighlightLineWidth,SeriesIndex=Style.TreeHighlightSeriesIndex)
else
    plot(Ax,[startPos(1) endPos(1)],[startPos(2) endPos(2)],":",LineWidth=Style.TreeBackgroundLineWidth,SeriesIndex=Style.TreeBackgroundSeriesIndex)
end

end
%%
function [startPos,endPos] = GetTreeBranchEndpoints(TreeSpec,branch)

startNode = GetTreeNode(TreeSpec,branch.StartNode);
endNode = GetTreeNode(TreeSpec,branch.EndNode);
startPos = startNode.Position;
endPos = endNode.Position;

end
%%
function node = GetTreeNode(TreeSpec,nodeName)

nodeNames = string({TreeSpec.Nodes.Name});
matchIndex = find(nodeNames == string(nodeName),1);
node = TreeSpec.Nodes(matchIndex);

end
%%
function branch = GetTreeBranch(TreeSpec,branchName)

branchNames = string({TreeSpec.Branches.Name});
matchIndex = find(branchNames == string(branchName),1);
branch = TreeSpec.Branches(matchIndex);

end
%%
function TreeSpec = MakeTreeTerminologySpec()

TreeSpec = struct();
TreeSpec.Title = "Parts of a Decision Tree";
TreeSpec.XLim = [0.04 0.96];
TreeSpec.YLim = [0.08 0.92];
TreeSpec.Nodes = [ ...
    MakeTreeNode("Root",[0.50 0.79],"Root node","branch"), ...
    MakeTreeNode("LeftLeaf",[0.24 0.50],"Leaf node","leaf"), ...
    MakeTreeNode("RightNode",[0.76 0.53],"Internal node","branch"), ...
    MakeTreeNode("RightLeftLeaf",[0.60 0.22],"Leaf node","leaf"), ...
    MakeTreeNode("RightRightLeaf",[0.86 0.22],"Leaf node","leaf")];
TreeSpec.Branches = [ ...
    MakeTreeBranch("RootLeft","Root","LeftLeaf","yes",[0.35 0.67]), ...
    MakeTreeBranch("RootRight","Root","RightNode","no",[0.66 0.68]), ...
    MakeTreeBranch("RightLeft","RightNode","RightLeftLeaf","yes",[0.65 0.36]), ...
    MakeTreeBranch("RightRight","RightNode","RightRightLeaf","no",[0.84 0.37])];

end
function TreeSpec = MakeExerciseTreeSpec()

% Edit the split text, displayed yes/no labels, and leaf values here.
TreeSpec = BuildThreeLeafRegressionTreeSpec( ...
    Title="Exercise 1 Decision Tree", ...
    RootConditionLabel="Hour < 9", ...
    RightConditionLabel="Temp < 60 deg F", ...
    RootThreshold=9, ...
    RightThreshold=60, ...
    LeftPrediction=4200, ...
    MiddlePrediction=5100, ...
    RightPrediction=6200, ...
    BranchLabels=["yes" "no" "yes" "no"]);
TreeSpec.ExampleHour = 9;
TreeSpec.ExampleTemperature = 63;

end
%%
function TreeSpec = MakeInteractiveTreeSpec()

% Edit the split text, displayed yes/no labels, and leaf values here.
TreeSpec = BuildThreeLeafRegressionTreeSpec( ...
    Title="Interactive Regression Tree", ...
    RootConditionLabel="Hour < 12", ...
    RightConditionLabel="Temp < 80 deg F", ...
    RootThreshold=12, ...
    RightThreshold=80, ...
    LeftPrediction=4200, ...
    MiddlePrediction=5100, ...
    RightPrediction=6200, ...
    BranchLabels=["yes" "no" "yes" "no"]);

end
%%
function TreeSpec = BuildThreeLeafRegressionTreeSpec(options)

arguments
    options.Title string = "Decision Tree"
    options.RootConditionLabel string = "Hour < 12"
    options.RightConditionLabel string = "Temp < 80 deg F"
    options.RootThreshold (1,1) double = 12
    options.RightThreshold (1,1) double = 80
    options.LeftPrediction (1,1) double = 4200
    options.MiddlePrediction (1,1) double = 5100
    options.RightPrediction (1,1) double = 6200
    options.BranchLabels (1,4) string = ["yes" "no" "yes" "no"]
end

TreeSpec = struct();
TreeSpec.Title = options.Title;
TreeSpec.RootThreshold = options.RootThreshold;
TreeSpec.RightThreshold = options.RightThreshold;
TreeSpec.LeftPrediction = options.LeftPrediction;
TreeSpec.MiddlePrediction = options.MiddlePrediction;
TreeSpec.RightPrediction = options.RightPrediction;
TreeSpec.XLim = [0.04 0.96];
TreeSpec.YLim = [0.08 0.92];
TreeSpec.Nodes = [ ...
    MakeTreeNode("Root",[0.50 0.79],options.RootConditionLabel,"branch"), ...
    MakeTreeNode("LeftLeaf",[0.24 0.50],compose("%.0f",options.LeftPrediction),"leaf"), ...
    MakeTreeNode("RightNode",[0.76 0.53],options.RightConditionLabel,"branch"), ...
    MakeTreeNode("RightLeftLeaf",[0.60 0.22],compose("%.0f",options.MiddlePrediction),"leaf"), ...
    MakeTreeNode("RightRightLeaf",[0.86 0.22],compose("%.0f",options.RightPrediction),"leaf")];
TreeSpec.Branches = [ ...
    MakeTreeBranch("RootLeft","Root","LeftLeaf",options.BranchLabels(1),[0.35 0.67]), ...
    MakeTreeBranch("RootRight","Root","RightNode",options.BranchLabels(2),[0.66 0.68]), ...
    MakeTreeBranch("RightLeft","RightNode","RightLeftLeaf",options.BranchLabels(3),[0.65 0.36]), ...
    MakeTreeBranch("RightRight","RightNode","RightRightLeaf",options.BranchLabels(4),[0.84 0.37])];

end
%%
function node = MakeTreeNode(name,position,label,kind,options)

arguments
    name
    position (1,2) double
    label
    kind
    options.Width (1,1) double = NaN
    options.Height (1,1) double = NaN
    options.Interpreter = ""
end

node = struct( ...
    "Name",string(name), ...
    "Position",position, ...
    "Label",string(label), ...
    "Kind",string(kind), ...
    "Width",options.Width, ...
    "Height",options.Height, ...
    "Interpreter",string(options.Interpreter));

end
%%
function branch = MakeTreeBranch(name,startNode,endNode,label,labelPosition)

branch = struct( ...
    "Name",string(name), ...
    "StartNode",string(startNode), ...
    "EndNode",string(endNode), ...
    "Label",string(label), ...
    "LabelPosition",labelPosition);

end
%%
function TreeState = EvaluateInteractiveTree(TreeSpec,Hour,Temperature)

arguments
    TreeSpec (1,1) struct
    Hour (1,1) double
    Temperature (1,1) double
end

TreeState = struct( ...
    "Hour",Hour, ...
    "Temperature",Temperature, ...
    "HighlightNodeNames","Root", ...
    "HighlightBranchNames",strings(0,1), ...
    "Prediction",TreeSpec.LeftPrediction);

if Hour < TreeSpec.RootThreshold
    TreeState.HighlightNodeNames = ["Root" "LeftLeaf"];
    TreeState.HighlightBranchNames = "RootLeft";
    TreeState.Prediction = TreeSpec.LeftPrediction;
else
    TreeState.HighlightNodeNames = ["Root" "RightNode"];
    TreeState.HighlightBranchNames = "RootRight";

    if Temperature < TreeSpec.RightThreshold
        TreeState.HighlightNodeNames = ["Root" "RightNode" "RightLeftLeaf"];
        TreeState.HighlightBranchNames = ["RootRight" "RightLeft"];
        TreeState.Prediction = TreeSpec.MiddlePrediction;
    else
        TreeState.HighlightNodeNames = ["Root" "RightNode" "RightRightLeaf"];
        TreeState.HighlightBranchNames = ["RootRight" "RightRight"];
        TreeState.Prediction = TreeSpec.RightPrediction;
    end
end

end
%%
function RenderInteractiveTreeDemo(TreeSpec,TreeState,Style)

arguments
    TreeSpec (1,1) struct
    TreeState (1,1) struct
    Style (1,1) struct = DefaultPlotStyle()
end

fig = figure(Name="Interactive Regression Tree Prediction Path");
ApplyFullscreenFigure(fig)
t = tiledlayout(fig,5,1,TileSpacing="compact",Padding="compact");

axHeader = nexttile(t,1);
axis(axHeader,"off")
xlim(axHeader,[0 1])
ylim(axHeader,[0 1])
ApplyDefaultAxesStyle(axHeader,Style)
text(axHeader,0.5,0.5,"Hour = " + compose("%.0f",TreeState.Hour) + ", Temp = " + compose("%.0f",TreeState.Temperature) + " deg F",HorizontalAlignment="center",VerticalAlignment="middle",FontWeight="bold",FontSize=Style.EmphasisFontSize,Interpreter="latex")

axTree = nexttile(t,[3 1]);
hold(axTree,"on")
axis(axTree,"off")
xlim(axTree,[0.04 0.96])
ylim(axTree,[0.08 0.92])
ApplyDefaultAxesStyle(axTree,Style)
RenderTreeDiagram(axTree,TreeSpec,Style)

pause(0.2)
for k = 1:numel(TreeState.HighlightBranchNames)
    PlotNamedTreeBranch(axTree,TreeSpec,TreeState.HighlightBranchNames(k),Style,true)
    drawnow limitrate nocallbacks
    pause(0.35)
end

RenderTreeDiagram(axTree,TreeSpec,Style,HighlightNodeNames=TreeState.HighlightNodeNames,HighlightBranchNames=TreeState.HighlightBranchNames)

axFooter = nexttile(t,5);
axis(axFooter,"off")
xlim(axFooter,[0 1])
ylim(axFooter,[0 1])
ApplyDefaultAxesStyle(axFooter,Style)
decisionTrace = FormatTreeDecisionTrace(TreeSpec,TreeState);
text(axFooter,0.5,0.67,decisionTrace,HorizontalAlignment="center",VerticalAlignment="middle",FontSize=Style.AnnotationFontSize,Interpreter="latex")
text(axFooter,0.5,-0.23,"Predicted Load = " + compose("%.0f",TreeState.Prediction) + " MW",HorizontalAlignment="center",VerticalAlignment="middle",FontWeight="bold",FontSize=Style.EmphasisFontSize,Interpreter="latex")

end
%%
function traceText = FormatTreeDecisionTrace(TreeSpec,TreeState)

if TreeState.Hour < TreeSpec.RootThreshold
    traceText = "Trace: Hour < " + compose("%.0f",TreeSpec.RootThreshold) + ", predict " + compose("%.0f",TreeSpec.LeftPrediction) + " MW";
elseif TreeState.Temperature < TreeSpec.RightThreshold
    traceText = "Trace: Hour >= " + compose("%.0f",TreeSpec.RootThreshold) + ", Temp < " + compose("%.0f",TreeSpec.RightThreshold) + " deg F, predict " + compose("%.0f",TreeSpec.MiddlePrediction) + " MW";
else
    traceText = "Trace: Hour >= " + compose("%.0f",TreeSpec.RootThreshold) + ", Temp >= " + compose("%.0f",TreeSpec.RightThreshold) + " deg F, predict " + compose("%.0f",TreeSpec.RightPrediction) + " MW";
end

end
%%
function [x,y] = GetLoadMayDayData()

if isfile("LoadMayDay.mat")
    Data = load("LoadMayDay.mat","x","y");
    if isfield(Data,"x") && isfield(Data,"y")
        x = Data.x(:);
        y = Data.y(:);
        return
    end
end

x = linspace(0,23,96)';
baseLoad = 4200 + 180*sin(2*pi*(x-4)/24);
morningRise = 500*exp(-((x-8)/2.6).^2);
afternoonDip = -220*exp(-((x-13)/2.0).^2);
eveningPeak = 1350*exp(-((x-18)/3.2).^2);
localVariation = 90*sin(2*pi*3*x/24);
y = baseLoad + morningRise + afternoonDip + eveningPeak + localVariation;

end
%%
function Example = MakeBaselineReminderExample()

rng(7,"twister")
Example = struct();

xFeature = linspace(-3,3,90)';
yFeature = 5 + 0.6*xFeature + 1.1*xFeature.^2 + 0.9*randn(size(xFeature));
FeatureTable = table(xFeature,xFeature.^2,yFeature,VariableNames=["x","x2","y"]);
FeatureModel = fitlm(FeatureTable,"y ~ x + x2");
xFeatureGrid = linspace(min(xFeature),max(xFeature),300)';
FeatureGridTable = table(xFeatureGrid,xFeatureGrid.^2,VariableNames=["x","x2"]);

Example.FeatureCase = struct();
Example.FeatureCase.X = xFeature;
Example.FeatureCase.Y = yFeature;
Example.FeatureCase.XGrid = xFeatureGrid;
Example.FeatureCase.YGrid = predict(FeatureModel,FeatureGridTable);
Example.FeatureCase.MSE = mean((yFeature - predict(FeatureModel,FeatureTable)).^2);

xThreshold = linspace(0,10,100)';
yThreshold = 3 + 1.5*(xThreshold > 3.5) + 2.5*(xThreshold > 7) + 0.35*randn(size(xThreshold));
TreeModel = fitrtree(xThreshold,yThreshold,MaxNumSplits=3,MinLeafSize=5);
LinearCoefficients = polyfit(xThreshold,yThreshold,1);
xThresholdGrid = linspace(min(xThreshold),max(xThreshold),400)';

Example.TreeCase = struct();
Example.TreeCase.X = xThreshold;
Example.TreeCase.Y = yThreshold;
Example.TreeCase.XGrid = xThresholdGrid;
Example.TreeCase.LinearFit = polyval(LinearCoefficients,xThresholdGrid);
Example.TreeCase.TreeFit = predict(TreeModel,xThresholdGrid);
Example.TreeCase.LinearMSE = mean((yThreshold - polyval(LinearCoefficients,xThreshold)).^2);
Example.TreeCase.TreeMSE = mean((yThreshold - predict(TreeModel,xThreshold)).^2);

end
%%
function ens = ShowEnsembleTreeDemo(x,y,NumTrees,MaxSplits,Style)

arguments
    x (:,1) double
    y (:,1) double
    NumTrees (1,1) double = 10
    MaxSplits (1,1) double = 6
    Style (1,1) struct = DefaultPlotStyle()
end

if ~isfinite(NumTrees)
    NumTrees = 10;
end
if ~isfinite(MaxSplits)
    MaxSplits = 6;
end

NumTrees = max(1,round(NumTrees));
MaxSplits = max(1,round(MaxSplits));

[x,idx] = sort(x);
y = y(idx);
xGrid = linspace(min(x),max(x),500)';

treeMdl = fitrtree(x,y,MaxNumSplits=MaxSplits);
yTreeGrid = predict(treeMdl,xGrid);
yTreeTrain = predict(treeMdl,x);
mseTree = mean((y - yTreeTrain).^2);

t = templateTree(MaxNumSplits=MaxSplits);
bagEns = fitrensemble(x,y,Method="Bag",Learners=t,NumLearningCycles=NumTrees);
ens = fitrensemble(x,y,Method="LSBoost",Learners=t,NumLearningCycles=NumTrees);
yBagTrain = predict(bagEns,x);
yBoostTrain = predict(ens,x);
mseBag = mean((y - yBagTrain).^2);
mseBoost = mean((y - yBoostTrain).^2);
pctImproveBag = 100*(mseTree - mseBag) / mseTree;
pctImproveBoost = 100*(mseTree - mseBoost) / mseTree;

figure(Units="normalized",Position=[0.05 0.05 0.9 1.1])
tiledlayout(2,2,TileSpacing="compact",Padding="compact")

axAnim = nexttile([1 2]);
scatter(axAnim,x,y,Style.DataMarkerSize,"filled",MarkerFaceAlpha=Style.DataMarkerFaceAlpha,SeriesIndex=Style.DataSeriesIndex,DisplayName="Training data (circles)")
hold(axAnim,"on")
plot(axAnim,xGrid,yTreeGrid,"--",LineWidth=Style.SecondaryLineWidth,DisplayName="Single tree baseline (dashed)",SeriesIndex="none")
hBag = plot(axAnim,xGrid,nan(size(xGrid)),":",LineWidth=Style.SecondaryLineWidth,DisplayName="Bagging",SeriesIndex=Style.ComparisonSeriesIndex,Visible="off");
hBoost = plot(axAnim,xGrid,nan(size(xGrid)),LineWidth=Style.PrimaryLineWidth,DisplayName="Boosting",SeriesIndex=Style.TreeSeriesIndex,Visible="off");
xlabel(axAnim,"Predictor",Interpreter="none")
ylabel(axAnim,"$\hat{y}$ (Predicted Load, MW)",Interpreter=Style.Interpreter)
title(axAnim,"Bagging vs. Boosting as Trees Are Added",Interpreter=char(Style.Interpreter))
animLegend = legend(axAnim,Location="best");
animLegend.Interpreter = "none";
ApplyDefaultAxesStyle(axAnim,Style)
ylim(axAnim,"padded")

axLoss = nexttile;
hSingleTree = yline(axLoss,mseTree,"--","Single tree error",LineWidth=Style.SecondaryLineWidth,SeriesIndex="none",DisplayName="Data");
try
    hSingleTree.Interpreter = "none";
catch
end
hold(axLoss,"on")
hBagLoss = plot(axLoss,nan,nan,":",LineWidth=Style.SecondaryLineWidth,SeriesIndex=Style.ComparisonSeriesIndex,DisplayName="Bagging",Visible="off");
hBoostLoss = plot(axLoss,nan,nan,LineWidth=Style.PrimaryLineWidth,SeriesIndex=Style.TreeSeriesIndex,DisplayName="Boosting",Visible="off");
xlabel(axLoss,"Number of Trees",Interpreter="none")
ylabel(axLoss,"Training MSE only",Interpreter="none")
title(axLoss,"Training Error: Bagging vs. Boosting",Interpreter=char(Style.Interpreter))
ApplyDefaultAxesStyle(axLoss,Style)
lossLegend = legend(axLoss,Location="best");
lossLegend.Interpreter = "none";

axMSE = nexttile;
hBar = bar(axMSE,[mseTree mseBag mseBoost],"FaceColor","flat");
hBar.CData = [ ...
    GetSeriesColor(axMSE,Style.ReferenceSeriesIndex); ...
    GetSeriesColor(axMSE,Style.ComparisonSeriesIndex); ...
    GetSeriesColor(axMSE,Style.TreeSeriesIndex)];
xticklabels(axMSE,["Single Tree","Bagging","Boosting"])
ylabel(axMSE,"MSE",Interpreter="none")
title(axMSE,"Prediction Error Comparison",Interpreter=char(Style.Interpreter))
ApplyDefaultAxesStyle(axMSE,Style)
axMSE.TickLabelInterpreter = "none";

bagLossHistory = nan(NumTrees,1);
boostLossHistory = nan(NumTrees,1);
for k = 1:NumTrees
    bagK = fitrensemble(x,y,Method="Bag",Learners=t,NumLearningCycles=k);
    ensK = fitrensemble(x,y,Method="LSBoost",Learners=t,NumLearningCycles=k);
    hBag.YData = predict(bagK,xGrid);
    hBoost.YData = predict(ensK,xGrid);
    hBag.Visible = "on";
    hBoost.Visible = "on";
    yTrainBagK = predict(bagK,x);
    yTrainBoostK = predict(ensK,x);
    bagLossHistory(k) = mean((y - yTrainBagK).^2);
    boostLossHistory(k) = mean((y - yTrainBoostK).^2);
    hBagLoss.XData = 1:k;
    hBagLoss.YData = bagLossHistory(1:k);
    hBagLoss.Visible = "on";
    hBoostLoss.XData = 1:k;
    hBoostLoss.YData = boostLossHistory(1:k);
    hBoostLoss.Visible = "on";
    title(axAnim,"Bagging vs. Boosting After " + string(k) + " of " + string(NumTrees) + " Trees",Interpreter=char(Style.Interpreter))
    drawnow limitrate nocallbacks
    pause(0.5)
end

title(axMSE,"Training MSE Reduction vs. Single Tree: Bagging " + compose("%.1f",pctImproveBag) + "\%, Boosting " + compose("%.1f",pctImproveBoost) + "\%",Interpreter=char(Style.Interpreter))

try
    sgtitle("Bagging vs. Boosting (" + string(NumTrees) + " trees, " + string(MaxSplits) + " max splits)",FontWeight="bold",Interpreter=char(Style.Interpreter))
catch
    hTitle = sgtitle("Bagging vs. Boosting (" + string(NumTrees) + " trees, " + string(MaxSplits) + " max splits)");
    set(hTitle,"Interpreter",char(Style.Interpreter),"FontWeight","bold");
end

summaryLines = [ ...
    ""
    "Single Tree MSE : " + compose("%.3f",mseTree)
    "Bagging MSE     : " + compose("%.3f",mseBag)
    "Boosting MSE    : " + compose("%.3f",mseBoost)
    "NumTrees        : " + string(NumTrees) + " trees in each ensemble"
    "MaxSplits       : " + string(MaxSplits) + " maximum splits allowed in each individual tree"
    "Bagging Training MSE Reduction vs Single Tree  : " + compose("%.1f %%",pctImproveBag)
    "Boosting Training MSE Reduction vs Single Tree : " + compose("%.1f %%",pctImproveBoost)
    "Note            : Filled circles are training data, the dashed line is the single-tree baseline, and the reduction values are percent changes in training MSE relative to that baseline."
    "Note            : This animation tracks training MSE only; use validation or holdout data to judge generalization."
    ""];
disp(join(summaryLines,newline))

end
%%
function Style = DefaultPlotStyle()

Style = struct();
Style.Interpreter = 'latex';
Style.Grid = 'on';
Style.Box = 'on';
Style.DataSeriesIndex = 3;
Style.EngineeredFeatureSeriesIndex = 1;
Style.LinearBaselineSeriesIndex = 2;
Style.TreeSeriesIndex = 7;
Style.ReferenceSeriesIndex = 6;
Style.ComparisonSeriesIndex = 4;
Style.DataMarkerSize = 36;
Style.DataMarkerFaceAlpha = 0.72;
Style.PrimaryLineWidth = 2.4;
Style.SecondaryLineWidth = 1.6;
Style.AnnotationMargin = 3;
Style.BaseFontSize = GetDefaultFontSize();
Style.AnnotationFontSize = Style.BaseFontSize;
Style.EmphasisFontSize = ScaleFontSize(Style.BaseFontSize,1.15);
Style.TreeBackgroundSeriesIndex = 6;
Style.TreeHighlightSeriesIndex = 7;
Style.TreeBackgroundLineWidth = 1.5;
Style.TreeHighlightLineWidth = 3.5;
Style.TreeBranchLabelFontSize = ScaleFontSize(Style.BaseFontSize,0.95);
Style.TreeNodeFontSize = Style.BaseFontSize;
Style.MinimumTreeBranchFontSize = ScaleFontSize(Style.BaseFontSize,0.75);
Style.MinimumTreeNodeFontSize = ScaleFontSize(Style.BaseFontSize,0.70);
Style.TreeFontShrinkScale = 0.95;
Style.TreeDenseLeafThreshold = 8;
Style.TreeDenseNodeThreshold = 6;
Style.TreeDenseNodeStep = 3;
Style.TreeNodeEdgeSeriesIndex = 6;
Style.TreeNodeHighlightSeriesIndex = 7;
Style.TreeDiagramMarkerSize = 8;
Style.TreeDiagramLineWidth = 1.2;
Style.TreeBranchNodeSeriesIndex = 7;
Style.TreeLeafNodeSeriesIndex = 4;

end
%%
function ApplyDefaultStyle(Style)

arguments
    Style (1,1) struct
end

root = groot;
SetRootDefault(root,'DefaultAxesTickLabelInterpreter',char(Style.Interpreter))
SetRootDefault(root,'DefaultTextInterpreter',char(Style.Interpreter))
SetRootDefault(root,'DefaultLegendInterpreter',char(Style.Interpreter))
SetRootDefault(root,'DefaultAxesFontSize',Style.BaseFontSize)
SetRootDefault(root,'DefaultTextFontSize',Style.BaseFontSize)
SetRootDefault(root,'DefaultLegendFontSize',Style.BaseFontSize)

end
%%
function ApplyFullscreenFigure(Fig)

arguments
    Fig
end

try
    Fig.WindowState = "maximized";
catch
    Fig.Units = "normalized";
    Fig.OuterPosition = [0 0 1 1];
end

end
%%
function ApplyDefaultAxesStyle(Ax,Style)

arguments
    Ax
    Style (1,1) struct
end

Ax.TickLabelInterpreter = char(Style.Interpreter);
Ax.FontSize = Style.BaseFontSize;
grid(Ax,Style.Grid)
box(Ax,Style.Box)

end
%%
function color = GetAxesBackgroundColor(Ax)

color = Ax.Color;
if isstring(color) || ischar(color)
    fig = ancestor(Ax,"figure");
    if ~isempty(fig)
        color = fig.Color;
    else
        root = groot;
        color = GetRootProperty(root,'DefaultFigureColor');
    end
end

end
%%
function color = GetSeriesColor(Ax,seriesIndex)

order = colororder(Ax);
numColors = size(order,1);
index = mod(seriesIndex - 1,numColors) + 1;
color = order(index,:);

end
%%
function blendedColor = BlendTowardBackground(color,backgroundColor,amount)

blendedColor = (1 - amount) * color + amount * backgroundColor;

end
%%
function fontSize = GetDefaultFontSize()

root = groot;
fontSize = GetRootProperty(root,'DefaultAxesFontSize');
if ~(isnumeric(fontSize) && isscalar(fontSize) && isfinite(fontSize))
    fontSize = GetRootProperty(root,'FactoryAxesFontSize');
end
if ~(isnumeric(fontSize) && isscalar(fontSize) && isfinite(fontSize))
    fontSize = 10;
end

end
%%
function fontSize = ScaleFontSize(baseFontSize,scale)

fontSize = max(1,baseFontSize * scale);

end
%%
function fontSize = ResolveTreeFontSize(baseFontSize,densityStep,shrinkScale,minimumFontSize)

fontSize = max(minimumFontSize,ScaleFontSize(baseFontSize,shrinkScale ^ densityStep));

end
%%
function value = GetRootProperty(root,propertyName)

value = [];
try
    value = get(root,propertyName);
catch
end

end
%%
function SetRootDefault(root,propertyName,value)

try
    set(root,propertyName,value)
catch
end

end

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"hidecode","rightPanelPercent":40}
%---
%[text:image:85d0]
%   data: {"align":"baseline","height":144,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAJYAAACWCAYAAAA8AXHiAAAACXBIWXMAAA7EAAAOxAGVKw4bAAANn0lEQVR4nO2de0xb1xnAPxsLYzumhjQQ25hgggtBeXSkdC19BSXNEhGt0pYuIV0ntetShaKpnYBIndS\/VlUFpiZbQrvQVWqmJEsbdSEKVZQSQpPmIRYhhQo3PGIXG8IjLtihOLaDL\/sju1FK7vXz3Ke\/33\/43Pudz\/DjnnvueVwFxIhWqzVZLJYtJpPpeb1eb9VoNCatVmuM9XxEnFAUFfL7\/Tf8fv+Yz+e75na720dGRk6Gw+FgMnEV0Q4wGo2Vq1at2m02m3+RTEWIdKAoam5oaOjT3t7e92ZmZq4nEoNVLL1eb127du17Vqt1W+IpIlLn22+\/bbxy5crueM9jFMtsNm985plnDmo0mtzkU0Okzvj4eNe5c+d+Nzs76471nAfEstlsrzz99NOfkE0NkTqzs7Puzs7OX3k8niuxHJ92\/w9ms3ljZWXlMW5SQ6RMenr6Q0ajcZ3T6Tw6Nzfnj3b8vSuWXq+3VlVVXYrW\/OXl5cGaNWsgNzcXDAYDqFQqEnkjAhEIBMDr9cLw8DBcvXoVvF5vxONHR0dPnT59enO0uPesWLt27XuRpLLZbFBVVQWrV6+OK3FEWpw9exba29thamqKsdxsNm8qLS19026374kURwFw95HCpk2bOtkOWr9+Pbz00ktJJYxIB5\/PB62trWC32xnLA4HA5GeffVYQDodvs8VIAwCoqKj4KDMzs4jpAJQq9cjIyICKigqw2+2MVy6VSqWjKCo4Pj5+ji2GUqvVmtgeftpsNpQqhXnttddAqVQyli1btmxrpHOVFotlC1thVVVVkqkhUmbJkiWwZQuzHtnZ2asNBsMKtnOVJpPpeaaCvLw8vFFH4LnnnmMtMxqNG9jKlHq93spUsGbNGgJpIVInKysLbDYbY5lery9gO0+p0WhMTAW5uTiag9wlJyeH8XONRsM6u0XJNvXFYDAQSguROmwuRJo2xXzLD4BP1JF7JOICq1gIkgySvCyFw2EYHR0Fv5\/1wW9cKJUKMJvNoNPpiMRDJCjWxYuX4NChQ3D7Nhmp7qe0dAXU1tZCRkYG8diphqSawmAwCAcPHuREKgAAu\/07+OqrrziJnWpISqyJiQkIhUKc1jE87OI0fqogKbFI3VNFYnZ2lvM6UgFJiYVIBxQL4QTJ9QrZ+OSTf8Z1fFtbG7S1neAoGwSvWAgnoFgIJ6BYCCegWAgnoFgIJ6BYCCegWAgnoFgIJ6BYCCegWAgnoFgIJ8hmrLCtrS2u469d6+coEwRAVmKRGVCmKIpInFRHUk3h4OAg53W43W4IBpPaiRoBCYnV09MDx48f57yeQCAAjY1NKFeSSEKsnp4eaGn5EObn53mpz+l0olxJInqxuru7Yd++\/bzf+9ByBQIBXuuVC6K+ee\/p6YEDB1ojHmM2m2HRokUJxacoCtxuN6s8TqcTmpqaoaGhHtRqdUJ1pCqiFYtu\/tiuVEqlEmpqdkFZWVlS9QSDQWhsbAKn08lYTl+5UK74EGVTyJdUAABqtRoaGurBamXcJgwA8J4rEUQnFp9S0aBc5BGVWEJIRYNykUU0YgkpFQ3KRQ5RiCUGqWhQLjIQ7RW6XC744ov\/wODgILEdYfiUioaWK1pvcdeuGiL1ZWVlwcqVK2Hr1l+DXq8nElNoiF2xwuEw\/O1vf4fe3l6i2wy9\/vpOXqWiUavVUF9fB4WFhZzXNT09DefPn4ejR49yXhdfEBNrcnKS9cU+iaBUKqG29g0oLy8nFjNeMjIyoL6+LmKzSBK7\/Tte6uEDYmLdunWLVChQKBS8N39sxHLPRQqfz8d5HXxBTCyS48Pl5Y+JQioaWi6u4WuQnQ9E0StciNHIun24YOBwTnzwMlbY0NDA+PmRI0fA7Y75\/dWipbp6O1gs+TEf73a74MiRf3OYkfDwIlZJSTHj51qtlo\/qOcdiyWf9jqmKKJtCRPqgWAgnoFgIJ6BYCCfwcvPOtpjU4\/HwUT0iADyJhbsTpxrYFCKcQEwspVJBKhQoFORiIcJATCySr\/pdvHgxsViIMBATKycnh8gMAJ1OC48++jMCGSFCQvTm\/a233oSDB\/8FMzMziSWjSoMXX3wRdDppDfW43fG9ii7e46UIUbEWLVoENTW7SIaUBHIfUE4E7BXGCF8LJ+SyQAPFioFgMAhNTc281NXU1CwLuVCsKNBSORwOXupzOByykAvFigDfUtHIQS4UiwWhpKKRulyi3cZISGKRqrCwEOrr65KaCx+tHlquZOsRArxiLYAvqQBiWxQr1SsXinUffEpFI1e5UKz\/I4RUNHKUC8UCYaWikZtcKS+WGKSikZNckusV3r59G77++msYGEh+q6RouyYD8CcVDS2X1HuLkhNrz549MDg4xEtdfEtFIwe5JNUUejwe2UtFI\/VmUVJiTU9P81KP0FLRSFkuSYkVDnP\/2hN6szWhpaKRqlySEosPLBaLaKSikaJckrt5Z+OFF37JWjY3NwcXL16KqSlVKsX5vxbrDf3bb\/8ZKiqeBJUqtj+tRqOB4uJiWLZsGcl05STWC4yf08+p+Lo\/45JY5Jqenob29i\/jjr1hwwbYsaM62RTvIc5\/T0IIPfWFC7jazbmjowNmZ2eJxZOtWHKUioYruSYnJ4nFkqVYsUiVlZXFY0bkoeUi+T2CwRCxWLITKxAIQHNzZKmWLy+EioonecyKG9RqtWi\/h2xu3gHuXqmam\/8adUC5rq4OTp06xWNm3MHW+9NoNJCfz7zhbn9\/P5cpAYCMxBLTLAUxkJ+fD7t3M+9W\/eqrv+e8ftk0hSiVuJCNWCiVuJCNWGygVMIga7FQKuGQrVgolbDIple4EIfDQewNqFKkv7+fl94fG5K6YoVC5J4Ms\/Hjjz9yXkcqIBmxgsEgL6+2HR0dhZ6eHs7rkTuSEIt++Dk2NsZLfS0tH0pGLrU6g1isjAxysUQvlhCzFCiKkoxcBQVkJuilp6eD0biUSCwAkYt1d+xPmKkvFEXBvn37obu7m\/e646GkpASeeOLnScVQKBTw8su\/JdqDFm2vMJYrldFohG3btkF6enrC9QwODsLx48dZ38d84EArqFQqUb2jeiE7d+6EysrKhBebPPRQJvHXJYtSLD4HlEtKisFsNkFLy4dAUQ\/+YehmsaZml6jlstlsQqfwE0TXFAoxS6GsrAxqanaxLqSQ0j2XWBCVWEJOfUG5yCIascQwnwrlIocoxBKDVDQoFxmI37x\/\/\/33MDAwEPMWQ7EsJuV7QJmWK9IN\/f79LVBe\/ljMvSmFQgFmcx6Ulq4AjUZDOmXRQVSsw4cPQ0fHGZIhYfnyu3PU+Z6lUFZWBjt3\/gE++ugfjOXz8\/PQ3f3fuOPqdFp45513YMmSJcmmKGqINYUzMzPEpaIXPgg19eXxxx+H2to3iC67n531Q0dHB7F4YoXYb+zmzZukQgGAeOZTRbvnSoSJCXILQ8UKsd9WKHSHVCjIysoShVQ0tFykEMuOMFwiil7hQioqnhSNVDRifuouRngZ0ikuLmb83OVyMfYeY92CRyxYLBbQah98K6zH44EffvhBgIyEh5e\/INvCyfffb+RlVS7XVFdXQ0nJg\/88bW1t0NZ2QoCMhEeUTSEifVAshBNQLIQTUCyEE1AshBN46RUKuXCSDxobG4VOQXTgFQvhBBQL4QQlRVGM69YjvWqNiYwMckMwJBdOkoTUMJNYvx8bbC5QFMU6QKz0+\/03mAq8Xm9clRuNxqSWYd2P1WolEoc0pN7eYLUWEInDF2wusLkDcFcsxnXrw8PDcVWuVqthx45qUCgUcZ23kKeeqoBHHnkkqRhcsX379qRnf1osebBx40ZCGfGDy+Vi\/DySWCqfz3ctJyfngT2dr169GncCzz77LBQVFcGtWzNxnwsAoFKlQVFRUULn8kFBwTJ4992\/wPj4RMIxioqWS2qQ3e12s+6Z4fP5BtjOU42MjLTbbLZXFhZ4vV7o6uqCdevWxZWIyWQCkymuUySFwWAAg8EgdBq8cfr0adaykZER1pf2KN1udztFUXNMhSdPngSfz0cgPUSK9Pb2woULFxjLxsbGzgYCAdapsMpwOBwYGhr6lKlwamoKWltbCaWJSInx8XH4+OOPWcsdDsfhSOenAQB4vd6+0tLSPzIdcPPmTbDb7VBSUgI6nS6pZBFp0NvbC3v37mXd3dDj8Vy5dOlSxLnaaQAAoVBoWqVSaXNzc59iOmhqago6OzuBoijIzc1NiXVxqYjb7YZjx47B559\/HnFbzsuXL9f6fL5rkWL95NnA5s2bzy5dunRdtARsNhvk5OSAwWCQVA8HeZBAIABerxdcLldMOyb29fV90N3d\/adox\/1ELJ1OZ6mqqrqg0+ksSeSKyBSXy3XizJkzzK+yXUDa\/T\/cuXPn1sTExHmj0bhOrVYv5iY9RIq4XK4TXV1dv5mfnw\/Hcnzawg\/8fv8Np9N5NDs7e1VmZqZ4n1YivNHX1\/fBN99880qsUgEwiAUAMDc3579+\/fqhUCjke\/jhh8tUKhV2B1MQj8dz5fLly7V2u31vvOdGHdhLS0vTrFy5sq6goGBrdnb26sRSRKTE2NjYWYfDcXhgYID9QVYU4hoxNhgMK4xG43q9Xm\/VaDRGrVZLdkdUhHcoirrj9\/tv+P3+Gz6fb2BkZOTLSE\/UEQRBEARBEARBECQ6\/wPgBva9q2cZQgAAAABJRU5ErkJggg==","width":144}
%---
%[text:image:3372]
%   data: {"align":"middle","height":24,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAArElEQVR42mP4\/\/8\/AwgnJiYapKamfgfS\/ynBUDMMYOYywBggiYcPH\/6nFIDMAJmFYQHIdmoBqFm4LZjrYPd\/gpoyGIPYVLeA5j4gbEASHJNlwZYtW\/93dHTixDCDQTRMDKRn8FhATBDNmTOH\/CAiBI4cOQI2HETTLBW9fv2a\/FRUtPXVf\/WeuyRhkB6iLQBp2HLvP0kYpGfUglELhpMFNM9oNKlw6FHp06TZAgAoeVix9Bg9oQAAAABJRU5ErkJggg==","width":24}
%---
%[text:image:47b6]
%   data: {"align":"baseline","height":24,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAsCAYAAAAXb\/p7AAADlklEQVR42u1YS0hUYRQejR4UvR+SvaCyWiS2DIoCKWjVYzG2SsYWQ+a8HRwXFkOgqdGLSoSeqyBaJUGLCKGkNpGtgiyScnpYBpaU5au+E+eH03Wu93rvP2OEFw46955z\/u8\/7\/\/3eDQ+4XD4Eui65199AK4d1DEJcBLgfw0wGo2ujkQi1yoqKlY5AFgDqnWw5lpaMxaLrbBkDgaDm7HIEKjTCcjxPqFQqABrdYEGsHaRXaESCAyCXpNFMwwuReDw\/77xusurQGJna0ysPR2K94CnGdQKesnUyu92J5PJaelk4c51Chzcu9dp0O9nkO3yvd\/vnwqlEbzvAf2yoB5sIkwyBt0doJ+0Qbdu2AXyC8UrOVuNQH5Q3IJegfrTfH8ikwC\/A9hjsdaYCQQCG6D4vVj0DShB7+HKXMGaQ\/EFADEGrPhJdn1GAhoZvRDKX4jFTvt8vhlWchSD4D0OGiE5AH9eXl4+PxNF+IoCB8sccyBfreQB8qJWcAC0CYqHeYE2cqEDNTmQvcc6hlC+CnXWq\/PCtTtdeGGr0HNWFz7aeTcr\/eT1eqe41PVWJYxd62zkovwXqQ6Cv8vErm9r8MZNEctLVf9Ph4GwecSOjPSQu8V28e6chmRrFPq28btHJhhSBKDIBH0B726HEDilAWCtsGCx6MmjMNgaHqBkiygPl3UmHE1OrjOEiqoqsqDHGizYxrqGAXCOriL9jJUOoq3lO9UDQItpQGD3PtXZRapFHB51oSchwiWsDWA8Hl8Cpb2svA+WWO4AXJ7Q0Z1IJObq7sUBN\/UQLr0hrHfANSCaQihrobiBf+dC+QOxSNk4MrdEyN1VvRy6T+DdVbOp2wpcCyutN8yDahjtVZ3A4sS2ALwflYxhaK1n0C22QfL8dkuNRYZBlKxxRLj6gg3XNgj+w8beLOriHcv50gocJ8wsfP\/ASgfMDlRs8XzwfGPeThMr2QcpEqFprJmPSoSwSvMYfCcFX6nFlNPEfAGrUuC1GkhxQpspTnTfKysrFxl5qqqqZouy0mU81ZmApB6cp2vKlrFVk+Z7TGRuPOsXRZSNfGYmEO\/ofoXmOiKKS3Ga6wPYeRNxk9Vo49BONAIL1mUdIBa9bxPgn+zMOkAqIXDdQbp1sKAy6uWeyWd0Cyuk5LDh3pTtez\/NSVJqNwbh5kNZB8htkTrP1zHA9dM1nZ07nExmc50ZQGA7M+GxyLden9MA\/OLm\/KKe34xPoKAD7jPkAAAAAElFTkSuQmCC","width":22}
%---
%[text:image:7be8]
%   data: {"align":"baseline","height":23,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAADoAAAA6CAYAAADhu0ooAAAEp0lEQVR42t2a208TQRTG67OJxvv9fiGoD6LGgPiCGo1G\/wljTKDl1pL00RuKIKCIIiKg6ItB8IJ38K4Panz13RcfSBBBQQHRek4ys\/kYpu1uu2132+Sku6eb6X7zmzlz5ux6PEn6lJaWbi0uLu4mGyLrJWvMz8+f4UmnjxA5QhZS7HNZWdnUdNE5hQR9EsLGioqKWuj7kRRbUlJSmS40D4Co4yD+rfAPEdW5rhdKQj4KQQM4J0n0DhjCVW4XuR9oHlV\/J98rSZVsnmuF0nz8oNIsLCxcFQwGp4vf86AjzrhV5D4dTTq+Tr8d0VD95fP5Frpx2L4XAgYlTQpMq+n8DxKm4+0wV6tdJZIo7YWbPwbi26QfqdL5S+H\/7SqqdMPvJE2iOFPOTUEzpM5bpEodUOMWkXs06yb7r6qZEc5dOn\/hKqqQCESiOYkqic4Ff62jRZKg3XCzJ0B8q0akjupzSZU6aZGTl5Q34kZ\/BgKB2ezzer3LOMcNJ5SpSvJIlY7POTWn3QUBpRzEt0QQqYvMzxxNlW7staRJQ3gO0Bw1IdSYz9Qx28Bf57QhuxNu7iSIbzYhclKEpvZ6HElVR5OOl5qkGZEqdcB5p9DMC0OzyYJIXaTuFr4R6rzFTkj3jK1WHDRDarSmdnPAX59qkbkQaU+B\/7IqglM7+g4qVqu5rhzaeeoIqpC2RaVJN52pGfYbdFRlW0iVrr2QcppkFSC+MUxUNSt0AlU6f5JSqpCuGcUtv9+\/JExZ05JQpErf2eC\/mOxIi4v6aRDfEGGdtCJUjeCPhW+Uk5BkCu2xQjNGoQZVWl+30Pk\/4W9I1tzM0RWfeVhFyXysCp0QyaHoPUZtLU\/G3OxWadIfL+Dilt1CMZrTtZuB6qVE7zezdUVnDv0mctlYhKpUHyaFKoR6SzTjEYr\/pVBtTDhNLDZz0m1ydxKrUHWdfiCp+ny+FYmgKUP8sHx8YJamDUK1VDnVtHs5wSFTDeLrLOw34xGqrtf3E0IVgoBRiiwoKJhvlqZNQjEubIKOb7Jr3TQaxeIyF6+sbMFsEKqu2\/ZShQZVmsPJFhqOKrVzxTaaWFTW7SNNCD3IlUI08h2KYXOO63eXpErtrYwnCHWpNDniWqVpsxlUacnLAhDNsa6bWTqaolIQSrFVwei6FxdVGlZ3baY5SNav2KCdVLlYblXkRqB5FnqvOlYKNgWjUJjsTEIZpzbXWIm0d9QCMlfneI\/oFKFKhoZgWs0GIP7zv+qDHu7BeOZVAoSqWZqEM+73+9eaodlpN80ECjXiBwLih87Rnoith4vrgGZlvJEyQUJVqrdNUaULOmRp0U6a8uUMssNo\/BDYBqHDnKlppt21qDTxwQ7vGhywbkbrxBrN1Bsny9DRbFcLxV6vdxad\/3C6UJyryvRrU7OgdfBjPYivcIHIkCYX79BSpZObLqYZkSq\/kicjaqZ04oMcrpS7SGRIzeJIy60JVDk6SZpcbRdDeRr5v2hyU6fbV\/l8VVlXm5lcX0wJsTveYpMVw14PzMOGNBQqE4h+3M8x5hti3UwH64S52y6D0YALA49Z6+P3hCXiDLH2fEsjgd+ZKr9wyRr\/A+UKAPezYlA8AAAAAElFTkSuQmCC","width":23}
%---
%[text:image:7d42]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[text:image:807a]
%   data: {"align":"baseline","height":20,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAADUAAAAxCAYAAAB6d+FmAAAC0ElEQVR42u2aO4gTURSGs6Lugo1WW2ghgiyCr1VWbRSR9YEgKoKohcQmEDAviYhBIaVbbKEWYi22YidoobUItoqwjSui6wt119Wsj+\/onXAcJslMZpI7AxP4Sbh37pnz3TP3zJ2TyWQS9imVStvRK1G5XL5ZqVRWZpL8MUCf0G+lz+hYIoGIyDYPIEc\/i8ViLmkRGkMfWwA5WkD7EwHEutmCs+87ADl6zfHLm4MLhcIqGs7RcV0WoA1xCa3vIkL\/CTsX\/w7G2Bka5oIMjlo4M6GBmOTRABHSeirh3S0LzSYQugHHgAPEJG+l7UOXtr6LgQeqYQZdRVf6Jc5frdfriyKIkOgHQToi1+0XpxGD+ywnhc348a5bICboqLMYmx02784hgRYAOqEzjHWoSIHiABU5kG2osECMP9lqC2IFiqS0qSdAtqAM0Ey3QOhUp81iX6F6DtRvKM6xsedA\/YQKCdQgyx0PcrKeQ4WNkE4K+LhGb6usQOHQOnnOCb31+WdrNW1TQC22BoW9Ddh9i6bRfNDdNkCH1c59LW0vpc8qFDYfo\/tkvMFqtbqM3xdkffgAmseXQ44dM3ba6bcGlc1mh9yzbaK3k\/Y37YAYc9Dl47A+xhoU0dlh7A579I3qRx6lbwAd8PAxHlA4V5BF3ea8Z11Ac62e52IDhb1bZuZL+lFdRWtQpflZzj3exlZsIvVc2b7jdW8xiWSWVL2ng4\/2ofL5\/Ars\/XJdXudN9wC\/R4Ce5PurFH58RN0+FLb2et130D1VVJlCu3zasw9FFC67dwboialUnZadQcBJsg+F09ewd9tkwLFcLrckZOTjkSgi3pmkUClUCpVCpVApVAqVQqVQ0UDp6s5IHKFMeaz5doufYuYz9bf\/XXmXQaqgcZH4I34pqBd+Qluz\/LpBUF3qCEUol3LgwyQAEbFHUrDxW6OTyk7NFEsaMYNpGL9qfoH+AOOEPfJuI6OmAAAAAElFTkSuQmCC","width":22}
%---
%[text:image:03dc]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[text:image:5846]
%   data: {"align":"baseline","height":20,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAADUAAAAxCAYAAAB6d+FmAAAC0ElEQVR42u2aO4gTURSGs6Lugo1WW2ghgiyCr1VWbRSR9YEgKoKohcQmEDAviYhBIaVbbKEWYi22YidoobUItoqwjSui6wt119Wsj+\/onXAcJslMZpI7AxP4Sbh37pnz3TP3zJ2TyWQS9imVStvRK1G5XL5ZqVRWZpL8MUCf0G+lz+hYIoGIyDYPIEc\/i8ViLmkRGkMfWwA5WkD7EwHEutmCs+87ADl6zfHLm4MLhcIqGs7RcV0WoA1xCa3vIkL\/CTsX\/w7G2Bka5oIMjlo4M6GBmOTRABHSeirh3S0LzSYQugHHgAPEJG+l7UOXtr6LgQeqYQZdRVf6Jc5frdfriyKIkOgHQToi1+0XpxGD+ywnhc348a5bICboqLMYmx02784hgRYAOqEzjHWoSIHiABU5kG2osECMP9lqC2IFiqS0qSdAtqAM0Ey3QOhUp81iX6F6DtRvKM6xsedA\/YQKCdQgyx0PcrKeQ4WNkE4K+LhGb6usQOHQOnnOCb31+WdrNW1TQC22BoW9Ddh9i6bRfNDdNkCH1c59LW0vpc8qFDYfo\/tkvMFqtbqM3xdkffgAmseXQ44dM3ba6bcGlc1mh9yzbaK3k\/Y37YAYc9Dl47A+xhoU0dlh7A579I3qRx6lbwAd8PAxHlA4V5BF3ea8Z11Ac62e52IDhb1bZuZL+lFdRWtQpflZzj3exlZsIvVc2b7jdW8xiWSWVL2ng4\/2ofL5\/Ars\/XJdXudN9wC\/R4Ce5PurFH58RN0+FLb2et130D1VVJlCu3zasw9FFC67dwboialUnZadQcBJsg+F09ewd9tkwLFcLrckZOTjkSgi3pmkUClUCpVCpVApVAqVQqVQ0UDp6s5IHKFMeaz5doufYuYz9bf\/XXmXQaqgcZH4I34pqBd+Qluz\/LpBUF3qCEUol3LgwyQAEbFHUrDxW6OTyk7NFEsaMYNpGL9qfoH+AOOEPfJuI6OmAAAAAElFTkSuQmCC","width":22}
%---
%[text:image:62ba]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:button:661b]
%   data: {"label":"Display Baseline Comparison","run":"Section"}
%---
%[text:image:5c97]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:button:482c]
%   data: {"label":"Display Parts of Decision Tree","run":"Section"}
%---
%[text:image:51fc]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:slider:981b]
%   data: {"defaultValue":13,"label":"Hour:","max":38,"min":0,"run":"Section","runOn":"ValueChanging","step":1}
%---
%[control:slider:8da7]
%   data: {"defaultValue":55,"label":"Temperature:","max":180,"min":0,"run":"Section","runOn":"ValueChanging","step":1}
%---
%[text:image:6b8e]
%   data: {"align":"bottom","height":24,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAsCAYAAAAXb\/p7AAADlklEQVR42u1YS0hUYRQejR4UvR+SvaCyWiS2DIoCKWjVYzG2SsYWQ+a8HRwXFkOgqdGLSoSeqyBaJUGLCKGkNpGtgiyScnpYBpaU5au+E+eH03Wu93rvP2OEFw46955z\/u8\/7\/\/3eDQ+4XD4Eui65199AK4d1DEJcBLgfw0wGo2ujkQi1yoqKlY5AFgDqnWw5lpaMxaLrbBkDgaDm7HIEKjTCcjxPqFQqABrdYEGsHaRXaESCAyCXpNFMwwuReDw\/77xusurQGJna0ysPR2K94CnGdQKesnUyu92J5PJaelk4c51Chzcu9dp0O9nkO3yvd\/vnwqlEbzvAf2yoB5sIkwyBt0doJ+0Qbdu2AXyC8UrOVuNQH5Q3IJegfrTfH8ikwC\/A9hjsdaYCQQCG6D4vVj0DShB7+HKXMGaQ\/EFADEGrPhJdn1GAhoZvRDKX4jFTvt8vhlWchSD4D0OGiE5AH9eXl4+PxNF+IoCB8sccyBfreQB8qJWcAC0CYqHeYE2cqEDNTmQvcc6hlC+CnXWq\/PCtTtdeGGr0HNWFz7aeTcr\/eT1eqe41PVWJYxd62zkovwXqQ6Cv8vErm9r8MZNEctLVf9Ph4GwecSOjPSQu8V28e6chmRrFPq28btHJhhSBKDIBH0B726HEDilAWCtsGCx6MmjMNgaHqBkiygPl3UmHE1OrjOEiqoqsqDHGizYxrqGAXCOriL9jJUOoq3lO9UDQItpQGD3PtXZRapFHB51oSchwiWsDWA8Hl8Cpb2svA+WWO4AXJ7Q0Z1IJObq7sUBN\/UQLr0hrHfANSCaQihrobiBf+dC+QOxSNk4MrdEyN1VvRy6T+DdVbOp2wpcCyutN8yDahjtVZ3A4sS2ALwflYxhaK1n0C22QfL8dkuNRYZBlKxxRLj6gg3XNgj+w8beLOriHcv50gocJ8wsfP\/ASgfMDlRs8XzwfGPeThMr2QcpEqFprJmPSoSwSvMYfCcFX6nFlNPEfAGrUuC1GkhxQpspTnTfKysrFxl5qqqqZouy0mU81ZmApB6cp2vKlrFVk+Z7TGRuPOsXRZSNfGYmEO\/ofoXmOiKKS3Ga6wPYeRNxk9Vo49BONAIL1mUdIBa9bxPgn+zMOkAqIXDdQbp1sKAy6uWeyWd0Cyuk5LDh3pTtez\/NSVJqNwbh5kNZB8htkTrP1zHA9dM1nZ07nExmc50ZQGA7M+GxyLden9MA\/OLm\/KKe34xPoKAD7jPkAAAAAElFTkSuQmCC","width":22}
%---
%[text:image:097c]
%   data: {"align":"baseline","height":20,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAADUAAAAxCAYAAAB6d+FmAAAC0ElEQVR42u2aO4gTURSGs6Lugo1WW2ghgiyCr1VWbRSR9YEgKoKohcQmEDAviYhBIaVbbKEWYi22YidoobUItoqwjSui6wt119Wsj+\/onXAcJslMZpI7AxP4Sbh37pnz3TP3zJ2TyWQS9imVStvRK1G5XL5ZqVRWZpL8MUCf0G+lz+hYIoGIyDYPIEc\/i8ViLmkRGkMfWwA5WkD7EwHEutmCs+87ADl6zfHLm4MLhcIqGs7RcV0WoA1xCa3vIkL\/CTsX\/w7G2Bka5oIMjlo4M6GBmOTRABHSeirh3S0LzSYQugHHgAPEJG+l7UOXtr6LgQeqYQZdRVf6Jc5frdfriyKIkOgHQToi1+0XpxGD+ywnhc348a5bICboqLMYmx02784hgRYAOqEzjHWoSIHiABU5kG2osECMP9lqC2IFiqS0qSdAtqAM0Ey3QOhUp81iX6F6DtRvKM6xsedA\/YQKCdQgyx0PcrKeQ4WNkE4K+LhGb6usQOHQOnnOCb31+WdrNW1TQC22BoW9Ddh9i6bRfNDdNkCH1c59LW0vpc8qFDYfo\/tkvMFqtbqM3xdkffgAmseXQ44dM3ba6bcGlc1mh9yzbaK3k\/Y37YAYc9Dl47A+xhoU0dlh7A579I3qRx6lbwAd8PAxHlA4V5BF3ea8Z11Ac62e52IDhb1bZuZL+lFdRWtQpflZzj3exlZsIvVc2b7jdW8xiWSWVL2ng4\/2ofL5\/Ars\/XJdXudN9wC\/R4Ce5PurFH58RN0+FLb2et130D1VVJlCu3zasw9FFC67dwboialUnZadQcBJsg+F09ewd9tkwLFcLrckZOTjkSgi3pmkUClUCpVCpVApVAqVQqVQ0UDp6s5IHKFMeaz5doufYuYz9bf\/XXmXQaqgcZH4I34pqBd+Qluz\/LpBUF3qCEUol3LgwyQAEbFHUrDxW6OTyk7NFEsaMYNpGL9qfoH+AOOEPfJuI6OmAAAAAElFTkSuQmCC","width":22}
%---
%[text:image:4446]
%   data: {"align":"baseline","height":396,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAB60AAALJCAIAAABgDCHyAAAACXBIWXMAAB7CAAAewgFu0HU+AAAAB3RJTUUH6ggMDwE3q1e1TgAAACR0RVh0U29mdHdhcmUATUFUTEFCLCBUaGUgTWF0aFdvcmtzLCBJbmMuPFjdGAAAACJ0RVh0Q3JlYXRpb24gVGltZQAxMi1BdWctMjAyNiAxMTowMTo1NdFZm20AACAASURBVHic7N17eFT1nT\/wb0KIA8RwqwoBhEC94GqFFrvielmUbWvUqP3ZYlsvrWKN2xatu724faSW9qnt9mfptqWbeqmK2i2ttTYq3pcHRWIriu1PxGo1UGAMKBJCgGFy+\/1x6DgOSURIMpPJ6\/VPZ845wHf6mMyZ93zO+xS0t7cHAAAAAADIU4XZXgAAAAAAAPSgomwvAADYLbl2a7aXANDbiscPzfYSAADIf3JwAMia5NqtyTWNWxa+kFzbuH3pumwvByA7iseXhhCGX3T0kFPGlZwyLtvLAQAgDxXoBweA3pdcu3XL7auiBDzbawHIIcXjS4dfdPQhc0\/I9kIAAMgrcnAA6G3JtVtfO22RBBygM8XjS8fecrrZcAAAuoscHAB61Z4hePH40qgKYOD4oSGE4gml2VsdQK9KrmkMIUTFUBu\/vTx9V\/H40iP\/+vnsLAsAgLwjBweAXrVl4QvrLn0oemzgESBdcu3WdZc+lLpfwrhbPjb8oqOzuyQAAPJDYbYXAAD9y1sLV4UQiseXRqOOQnCAlOLxQyc9NmvI338xNrmBMAAA3UQODgBZkFzbaMgRoEMlJ+\/Owd1HAQCA7iIHBwAAAAAgn8nBAQAAAADIZ3JwAAAAAADymRwcAADIIcm1W7O9BAAA8o0cHAAAAACAfCYHBwAAAAAgn8nBAQAAAADIZ3JwAAAAAADymRwcAAAAAIB8JgcHAAAAACCfycEBAAAAAMhncnAAAAAAAPKZHBwAAAAAgHwmBwcAAAAAIJ\/JwQEAAAAAyGdycAAAAAAA8pkcHAAAAACAfCYHBwAAAAAgn8nBAQAAAADIZ3JwAAAAAADymRwcAAAAAIB8JgcHAAAAACCfycEBAAAAAMhncnAAAAAAAPKZHBwAAAAAgHwmBwcAAAAAIJ\/JwQEAAAAAyGdycAAAAAAA8llRthcAANBfLFq06Pe\/\/\/0zzzzT2toabSkpKTnllFMuvPDCD3\/4wyGEF1544ec\/\/\/nTTz+9efPm6IABAwYcd9xxH\/3oRz\/zmc8UFeXnmVtra+tDDz20YMGCbdu27dixo7S0tKqqqrKyctCgQdleGgAAkCfy89MUAEAOmjVr1qxZs+6+++6vfvWrIYQDDzzwtttumzp1auqAo48++ic\/+UldXd2nPvWpTZs2hRCuvvrqqqqqgoKCrC26h23btm3OnDl\/+9vffvrTn06ePLm1tfXuu+\/+5je\/ec899yxYsOB973tfthcIAADkA70oAAC96ogjjjjwwANDCOXl5ePHj9\/zgIMOOmjixIkhhFgsduyxx+ZxCN7c3Hz99dcvXbr04osvnjx5cghhwIABn\/zkJ88\/\/\/xnnnnmK1\/5ys6dO7O9RgAAIB\/IwQEAsqOgoGDAgAFdHzNw4MDeWUxW\/PnPf77\/\/vtHjhz5j\/\/4j6mNBQUFZ511VklJydKlSx9++OEsLg8AAMgbcnAAALpfa2vrI488cvXVV7\/11ludHbNkyZKmpqZDDjlk6NCh6dvLy8vHjh0bQvj9739vJBwAANh\/cnAAALpTc3Pzfffdd+qpp1ZVVdXV1XU2875r166XXnophDBw4MCMW2IOGTKkrKwshPDyyy+\/8cYbvbBmAAAgv8nBAQD6ki1btsyfP\/8jH\/nIySeffMwxx5xwwgnf\/\/73Gxsbo70tLS2PPPJIRUXFxIkTJ06ceO+990Ybb7\/99vPPP3\/SpEkTJ0784he\/2NLSEh3f3Nz85JNPfu5zn5s\/f\/6WLVuuvPLKww477OSTT\/7b3\/62D2uLEvCZM2deeeWVb7311qWXXvrTn\/40Y9Y7\/eAdO3Z0uOuAAw4YNmxY9GI3bty4DysBAABIV5TtBQAAsLf+93\/\/98tf\/vLJJ5\/8q1\/9asSIETt37qyurv7pT396991333TTTVOmTCkqKvrIRz4yfPjwiy++OJFIRH+qqKjo4osvPueccz772c\/+6U9\/ijY2NTX9+Mc\/\/u1vf7tly5YQwpgxY6666qoXXnihtbV1\/fr1zz333KGHHrr3C9u5c2dNTc38+fM3bdo0ZMiQSy+99LLLLjv44IO7+CMDBw4cPHhwCGHTpk1bt27tMC5vaWlJvQoAAIB9Zh4cAKBveP7557\/2ta8deuih11xzzYgRI0IIgwYN+uIXv\/jxj3988+bNX\/ziF+vq6qIjY7HYnjfYHDBgQHr9SElJyX\/8x3\/88pe\/HDlyZAjh7rvvPuuss5YtWzZnzpwTTzzx2GOP3ctV7dy58\/bbbz\/ppJOuueaa7du3X3rppY8\/\/vg3vvGNrkPwEMIBBxxw5JFHhhBef\/31VatWdXhMUVFRLBbby5UAAAB0xjw4AEB2\/OlPf5o6depeHtzS0nLrrbdu3rz5vPPOGz16dGr7wIEDL7rookceeSQej\/\/sZz\/7z\/\/8z4KCgr1fw\/DhwwcPHrx58+azzjrr7LPPHjhw4FVXXbWXf7apqek3v\/nNggUL3nrrrb2cAc8wY8aMhQsXNjU1\/frXv\/7nf\/7nVEzf3Nzc1NS0938PAABA1+TgAADZccwxx8yfP7+kpCRj+\/bt27\/61a8+++yz6Rvr6upqa2tDCEcccURG0l1eXv4P\/\/APTz\/99B\/\/+Mc33njjPSXRKYcccsieI+SdaWxsXLhw4Y033tjU1DRkyJAvfelLn\/nMZ\/bh3\/3gBz94ySWX\/OQnP1m6dOk3vvGNa6+9dtiwYWvWrPnBD37w6KOPhhBGjhw5atSo9\/rXAgAAZJCDAwBkR2Fh4ciRI\/fsxW5qatozkt64cePWrVs7\/HtKSkqOOOKIp59+uqGhYePGjfuWg++lpqamBQsW3Hnnndu3b9+fBDxSUFDwhS98YcSIET\/72c\/uvffe6K6e5eXl559\/\/qpVq9atW\/f+97\/\/fe97X7e+AgAAoD\/SDw4A0AckEonm5uYQQktLy557DznkkBBCc3NzT99VctCgQSeddNLEiRNDCNu3b3\/sscfWrl3b3t6+z39h1OtSW1u7YsWKp59++vnnn3\/88ccPP\/zw+vr6goKCmTNnpneaAwAA7Bs5OABAHzB06NDojpEvv\/xyZ8cMGTKktLS0R5cxYMCAE0444d577\/3tb3\/7oQ996KWXXpo1a9aZZ575zDPP7E8aXlBQMGLEiIMPPri0tHTnzp233nprc3PzUUcdNWPGjG5cPAAA0G\/JwQEA+oBRo0aNHDkyhPDKK6\/s3LkzY+\/GjRtDCGPGjBkxYkQvLKagoGDq1Km\/\/vWv77\/\/\/pNOOqm70vDIgw8++OSTTxYXF19yySVlZWXdsmAAAKCfk4MDAPQBo0eP\/uAHPxhCePbZZzNGwnfu3FlXVxdC+OhHP5rRpp1eotLa2rpngL4\/CgoKJk+efPvttz\/66KMzZ87sljT8+eefv\/7660MIVVVVZ555ZjeuFgAA6M\/k4AAAOaq9vb21tTV6XFRUdNVVV5WVlTU1Nd15553pQfOLL7743HPPTZ069bzzzisoKAghjBw5MipIeeCBB6Lsu7W19be\/\/e1f\/vKXEML27dujqvHuMnHixBtvvPHRRx\/92Mc+9vLLL8+aNev000\/fhzT8T3\/605w5c7Zt2\/a1r33tC1\/4wp43CwUAANg3cnAAgF71l7\/8Zdu2bSGEdevWxePxPQ944403XnvttRDCrl27Vq9endpeXl7+X\/\/1XwcddNA999xTXV0dReTr16\/\/zne+U1ZW9p3vfOeggw6Kjhw9evS\/\/Mu\/hBCWLl36sY997Oqrr54xY8bq1atPPvnkEMITTzzxyU9+cvny5SGERCIRzYzH4\/H9rDSZOHHiz372s\/\/93\/\/9P\/\/n\/7z66qvvKQ3fuXPnjTfeeMEFFwwcOPAXv\/jFZZddJgQHAAC6UcH+dzgCAHvv1ZmLti9dF0I45NoTDpl7QraXQ69atGjR448\/\/sQTTySTyWhLSUnJKaeccvnllx999NEhhBdeeOG2225btmzZpk2bogMKCgqOPvroT3\/607NmzYq2NDY23nLLLb\/97W+3bt06fPjwoUOHVlZWzpo1K+MOmU1NTfPnz7\/nnnsaGxsnTZp0xRVXnHnmmd\/61rd27dp19tlnH3fccW1tbbfccstvfvObdevWRf\/QiSeeeMkll\/zTP\/1TUVHRfr7STZs2LViwYNGiRZMnT77tttuGDh3a4WHNzc11dXW\/+tWvfv\/730+cOPGzn\/3sqaeeOmjQoP381+nr1l364JaFq0IIQ04ZN+mxWdleDgAA+UAODgC9Sg5O\/7Fly5bHHnvs9NNPLykp6fCApqamZ5999tBDDx07dqwBcFLk4AAAdLv9HfYBAIAODR8+\/BOf+EQXB0Tj8L22HgAAoN\/SDw4AAAAAQD6TgwMAAAAAkM\/k4AAAAAAA5DM5OAAAAAAA+UwODgAAAABAPpODAwAAAACQz+TgAAAAAADkMzk4AAAAAAD5TA4OAAAAAEA+k4MDAAAAAJDP5OAAAAAAAOQzOTgAAAAAAPlMDg4AAAAAQD6TgwMAAAAAkM\/k4AAAAAAA5DM5OAAAAAAA+UwODgAAAABAPpODAwAAAACQz+TgAAAAAADkMzk4AAAAAAD5TA4OAAAAAEA+k4MDAAAAAJDP5OAAAAAAAOQzOTgAAAAAAPlMDg4AAAAAQD6TgwMAAAAAkM\/k4AAAAAAA5DM5OABkR3Lt1mwvAQAAAPoFOTgA9Kri8aXRgy0LVzUtXZfdxQDkmuTardv9bgQAoLvJwQGgV5WcMi71+LWZizbOWy4NB0iu3Zpcu3XjvOUvvf+m5NrGaOMh156Q3VUBAJA3Ctrb27O9BgDoX16duShj2jEaEh9yyrji8UOztCiA7Eiu3Zpc27jnDPjwi\/5h3C2nZ2VJAADkHzk4AGTBxnnLN357ebZXAZCLiseXDr\/o6EPmGgYHAKDbyMEBIDuSa7duuX2VNBwgpXh86ZBTxh0y9wQXxwAA0L3k4ACQZVEgHkJoemJdCKF5zdZsryg\/xRNt0YOyWGFnW6AzHf7XktoY\/Fe0rwZOGBpCKB5fWnLKuIHjh6bfQQEAALqRHBwAyHM19cma15MrGlqip8\/PGBY9mLKkoSxWWDmquKo8lr3V0WesaGiZNqwo9XTKkob0van\/rgAAgBwkBwcA8lxGXhlElnSHznLw6rqEb1YAACDXuH4TAMg38URbTX0y9TQj9dZfwf6LJ9qqJrwddqf\/N1a9JjFlSUN1XSK9NQUAAMgu8+AAQP6IJ9pWNLREEWR6NBmN7mpBodtV1yVq6pOLp5dGTzOGxMtihaldAABAFsnBAYD8UVHbmD6Emx6F19QnK0cVZ2NR9CNKwwEAIDe5LhgA6NvSg+8umiiE4PS0jLKUDBW1jdV1id5cDwAAkGIeHADoq1ItKOnVE6mB3LJYYVV5TPxNL4sn2mpeT1avSezZzBOpmhBTzgMAAL1MDg4A9D3pPeDRllTmOGVJgwScXKMvBQAAsqso2wsAAHjPymKFc1fv6HCXhJFck\/HfasZ3Nu7dCgAAvUA\/OADQN3TR\/R1CqKht7LWVwHsyb\/LgxdNLO6wOjyfaqtckVIcDAEBP04sCAOS6qHC5pj4ZT7Tt2blcFiucN3nwtGGuciPXxRNtZbG3x1CUpQAAQK\/xiREAyGnVdYkoAd9zlwScviU9BO\/iCoaK2kYF9wAA0L3MgwMAuc7YLHkpnmiLvuYJ7\/yvOnWhg+pwAADoLvrBAYDcEoWDnU3Lpk\/UQp8WXdDQdXV4768KAADyknlwACBXRD3gqewvY0K2clRx5ehiLSjkt86ufqiuS1SOLvY9EAAA7Bs5OACQKzISwJAWAq5oaJGA0x9kFOKnfgRSZSmqwwEAYB\/IwQGAbIon2tJHXFWBQ\/h7O9C8yYOjpxk\/F2WxwsXTS7OxLgAA6KtcWQkAZEfXPeCVo4pvnlrSy0uCHBFVh3e2Nz0ET02OAwAAXTAPDgBkQXVdIv0egOlz33NX79ADDikZvfmho+r8qvKY6nAAAOiCHBwAyAL9J\/BeparDM0rDI8pSAACgC3JwAKA3RDOtVeWx1JZUhFcWK5w2rKiLFgigQ75PAgCAveSKYwCgZ6W3OlSvSaRHdVECrtIB9kF1XSL9afpPVkVtY+Wo4srRxX6yAAAgYh4cAOhZXYysxhNtcjrYZ9GXTF2UpURXWvgpAwAAOTgA0LMycnAtxtCjlKUAAMCezIYAAN0pnmirrkukJ3GpGK4sVlg5qvjmqSVZWhrkv7mrd3SxN6NKBQAA+g\/z4ABA90jvAQ\/aiiFL0n8S038Mo2+noq+j\/DACANDfyMEBgG6jkAFyRJSGV5XHUlv8eAIA0J8ZAwEA9l3UgtLhLtOmkEVlscK9DMGVpQAA0B+YBwcA9kVnLShTljQoXoBc08UPbPh7WUp6bg4AAHlGDg4AvGdzV++oqU+mb0nFatV1CQk45CZlKQAA9FtycABgX2TEZ2WxwsXTS7O1GGAfZPwUh7QcvKY+WTmquNdXBAAAPcWsFgDw7uKJtrmrd+yZmoWohnhCTAgOfc7NU0umDStKPU0fBp+7ekdFbaPqcAAA8oZ5cACgK9GdMFMtKOlJWUVto05h6OtS1eHpP92pL71UhwMAkB\/k4ADAu9AgDP1KZz\/y8USb6n8AAPooJ7IAQKZ4om32yqYOd0nBIO919mNeUdtYUduYcY9cAADoE8yDAwBvi3rAVzS0hHfOfU9Z0qAeAfqPVCFS6vdA+pC43wYAAPQ5cnAAYLfZK5uiBDwlFYFV1yVkXtDfpBeh6EcCAKBPc2kzALDbzVNLOtslBId+aC97kKrrEvFEW08vBgAA9occHAD6r657wKsmyL6B3Z6fMaxqQmzPZHzKkobqNQnV4QAA5Di9KADQH9XUJ2teT6ZaUNIrDipqGzX\/Ap1JL0sJ+lIAAOgjirK9AAAgC+au3tHZrsXTS3tzJUDf0kVZSnoI7qYCAADkFL0oANBfpFcWZMxsVtQ29vpygD4vnmjrsEApKkuZsqRBdTgAADlCLwoA5L\/0FpRUAh61GZTFCrWgAPupui5RU59MXU2iLAUAgFwjBweAPDd7ZVOqBzwoLgB6WEYIHuTgAADkADk4AOQ5mRTQm+KJtprXk9VrEtHT9F84U5Y0uAYFAICs0A8OAHklnmirqU+m932nh1BlscIOy3wBuktZrLCqPLZ4emmHv23iibZUdXjvrw0AgH7LPDgA5Il4om1FQ0vqrnR7zmBWlccqRxVnb4FAv6Y0HACALJKDA0D+EDMBOWvu6h019cnU0\/R79ipLAQCgp+lFAYA+LGpByfYqAN7dvMmDU2UpGd\/SRWUpFbWNylIAAOgh5sEBoE9Kb0HJqEAJf+\/n1YIC5KB4oq0stnscx418AQDoHUXZXgAA8J5V1yVq6pNRD3gIYcqShlRyJAEHclwqBI8ep36VhXeG4BW1jX6bAQDQXcyDA0CfpAocyA\/xRFv03V7Y4wa\/IQTV4QAAdAs5OAD0AfFEW83ryfQkKD0HL4sVzps8eNowl3kBfVV6WUrwVR8AAN3NfTIBIKdFk5KzVzZVr0mkB0NRKlQWK7x5asni6aVCcKBPSw\/BuzB39Y70HhUAANhL5sEBIKdV1DZ2Vp67oqFF\/A3kpfS7IChLAQBg\/8nBASDnZLSg6AcA+qfogph5kwdHTzN+GZbFChdPL83GugAA6HsMkQFADokS8Oo1iRDCnqOOlaOKK0cXZ2NdAFkQ3fygs73pIXhGvTgAAGQwDw4AuaK6LhEl4Cmp0e+5q3dUji7WggL0W9HXhKmylLBHX8q0YUXzJg+WhgMA0CE5OADkioxL\/oMKFIA91NQnq+sS6cPg6b88laUAANAh4xIAkDVR9W3qaUbqXTlKBQpApspRxV0k3ek3FgYAgBSXVwNAFqT3gFevSeyZgGtBAdgb6d8mhrQvFKMh8aoJscrRxcpSAADQiwIAWZBRgZKeg69oaJGAA+y99OrwjBw8Mm1Y0c1TS7K0OgAAcoIcHAB6STzRlppJzMjBFdoCdK8uvm4EAKAfcoUgAPS4qAe8orYxlcukEpmyWGHlqGKDigDdKKMsJV1FbWMXewEAyFfmwQGgZ1XXJaIe8EgqAa+obZw2rKiqPKa4FqDbpd+GIX0YPPV9pOpwAIB+RQ4OAD0r49r84PJ8gF5UXZeoKo9Fj5WlAAD0W8YfAKCbRS0oqafpOUvUgpKNRQH0U6kQvAvKUgAA8l5RthcAAPkj\/TL8jOQlSsBdgw+QRYunl6Z+S6eLJ9qq1yRq6pOVo4r3JjcHAKDP0YsCAN2miyvu44k2CThALoi+s+ysLCXoSwEAyEc+kAPAfokn2vbmMCE4QI4oixV2MfSdHoLX1Cd7ZUUAAPQ4n8kBYB\/FE21zV++oqG1MbUmlJ2WxwqoJsb2MyAHIosXTSzu7c0P0S151OABAHtCLAgDvWXQnzPQ5wVQCXlHbqAccoM\/JKEsJ7+xLKYsVLp5emo115aH29vYNGzYsXrx40aJFn\/70p0899dR58+YtW7asra3tgx\/84A033HDooYemH\/\/aa6\/ddNNNGzZsOPjgg5944okxY8ZcccUV\/\/Iv\/1JQUJCtlwAA9EVycADYF11UgQOQBzr7Pe9+D\/tp+fLlzz333I033tjU1HT88cc3NDRUVFSMGDGiurp6\/fr1J5544n\/\/938PGTIkhNDe3n7HHXf84Ac\/mDNnzuzZswsKCrZs2TJnzpynnnrqjDPOuP7660tKSrL9agCAPmPAddddl+01AEAfEE+0HVj09uhZ9Zq3L5MvixVua2mfNrwoG+sCoPtV1yXiibZtLbtnhtK\/7Dzpya019ckDBxYcUTIgS6vr28aNG3fUUUf94Q9\/WL9+fUlJyYIFCz760Y8ec8wxw4cPf\/jhh7ds2TJjxoxDDjkkhLBs2bKvfvWrH\/jAB\/7jP\/7jgAMOCCEMGjRo6tSpjz322HPPPdfc3HzSSSdl+9UAAH2GQQYAeBepHvD02cAoE4l6wBdPL+3ilmsA9DlV5bHF00v3rA6P3ghS7wuqw\/fTscceW15eHj2eNGnSgQce2NTU9Oabb4YQdu3adddddyWTyQ984AMHHnhg6o9MmDBh5syZIYQHHnigrq4uK8sGAPoiOTgAdCVKOtKrwFMk4AD5rSxWOG\/y4M6ar+KJNm8BPWfz5s2rVq0KIUSz4SkFBQVTpkwJIbz++uuvvvpqdhYHAPRBcnAA6Mq8yYPTn6aPhIs\/APqVrqe\/oyqVXltM3tu8eXNjY2OHu8rLy6Nm8LVr1\/buogCAPkwODgDvEE+0zV7ZlHF7tEjUgtL7SwIgF1SVx56fMaxqQiy6T2b6nPiUJQ3VaxIVtY2dXULEPtu4cWPGlsLCwoKCgoKCgqIid+YAAPaW8wYA2C3qe13R0JKx\/fkZwypqGytHFRsAB6CqPFZVHuts9Dt6K8loFWcfjBo16n3ve9+2bdvWrl2bTCaLi9\/+v7Stra29vb2wsHDChAnZWyAA0MeYBweA3SpqG9ND8PSRcD3gAKSLRsIjGZcQpebE3UhzfwwfPvzDH\/5wCGHVqlVvvPFG+q54PN7U1DRp0qTDDjssS6sDAPoeOTgA\/Vr6QF\/GndDSMw4A6Mzi6aUdtmbFE23VaxJTljSoDt8HRUVFn\/nMZ0aOHBmPxx966KHU9paWlieeeGLAgAGf\/OQny8rKsrhCAKBv8QkfgH6qpj45e2VTRW0H9+CKesAXTy\/t\/VUB0OeUxQpT1eEZX6lGourw3l9Yzmptbd25c2cIobm5ObVx69atiUSivb29tbU12nL00UfPmzdvyJAh1dXVzz\/\/fLTx0Ucfvf\/++2fPnn3hhRf2\/soBgL6roL29PdtrAGC3J5988vrrr3\/ppZdCCEceeeQVV1wxc+bMQYMGbdmy5Xe\/+92PfvSj4uLib33rW2eccUYIYcOGDT\/5yU8eeOCB7du3Dxky5Kyzzrr66qvf9773pf62Z555Zv78+QMHDiwtLV21atWhhx565plnnnfeeVl7eblk9sqm9AqU9Niiui6hAgWA\/bTn\/ZZT7zX9\/I1m9erV1dXV999\/f3t7e3Fx8ac+9anZs2evWrXqRz\/6UXQKNHr06K9\/\/esVFRUDBgwIIaxbt27BggWPP\/74lClTCgsLW1tbP\/\/5zx933HEFBQXZfikAQF8iBwfILc8+++znPve5pqamiy+++Jvf\/GZqezwe\/9SnPvX5z3\/+M5\/5TAhh2bJl11xzzYUXXnjhhRcmEolvf\/vb99577+GHH\/6LX\/wiukb4hRdeuOSSS2bPnn3ZZZcVFBSsX7\/+4osv\/vSnP33ppZdm7bXlks66XAGgW8QTbTWvJ6vX7O4HT3+jmbKkoSxWWDmquHJ0sQ4uAIDe4awLILcce+yxM2bMCCH84Q9\/eOutt1LbX3zxxebm5uOOOy6EEI\/Hv\/Od70ybNu1zn\/vcoEGDhg8ffvnll48cOfLll19esGBBdDXxQw899Oabb06cODGalho7duzFF1+cpdeUE6IWlNTT9DyiLFboPmYAdK+oLKXr6nBlKQAAvUYODpBbioqKPv7xjw8cOPCll1568MEHo43t7e0PP\/zw0UcfPW7cuBDCr3\/961deeeWMM84YOHBgdMCYMWMmTZoUQnj66aej9Hz79u0hhDvuuKOpaXf4O23atBEjRvT+K8q6KAGfu3rHioaWjDHwVA94f74+HYCek6oOT23Zsy8lUlOf7K1FAQD0R3JwgJzzoQ996EMf+lAIoaamprGxMYSwfv36P\/zhD6eddtqgQYO2b9\/+3HPPFRYWXnfddSf\/XUVFRTweHzt2bCwWe\/PNN0MIp556anFx8ZNPPnn22Wc\/\/fTTIYSjjjrq3HPPze5Ly4ooAd9z+\/MzhknAAehllaOKO9w+d\/WOitpG1ycBAPQQ\/eAAuei+++676qqrioqKbrnllhNPPPG+++77wQ9+cNddd40bN27Tpk2f+MQntmzZcuutt0ZxeYfa29vvuOOO7373u8lksqCgOG1\/qQAAIABJREFU4IMf\/OANN9xw6KGH9uaryJZ4oi29bnXPGfDF00t7fVEAsFuqOjw1J57+VhVVh\/uaFgCge5kHB8hFxx9\/\/BFHHNHc3HzPPffs2rXrscceO+6440aPHp06oKmpacuWLV38DQUFBRdddNFtt912+OGHt7e3P\/vss2ecccZjjz3W82vPpniiLWpBSQ8UUilDWaxw3uTBQnAAsitVHd7h3niiTQgOANDt5OAAueiggw46\/\/zzQwjLli176qmn\/vznP5966qlFRUUhhKKioiFDhoQQnnrqqT3\/4FtvvVVXVxdCaGpqam1tPf744x944IEf\/ehHI0aM2L59+ze\/+c1ob15K9YDHE20Zu1IJeGdXowNAL0u\/dCn9cQZlKQAA3UIODpCjZsyYMWbMmDfffPN73\/teQUHBlClTou2lpaWHHXZYCOGBBx5YvXp1+h9pbm7+4Q9\/+OKLL4YQvvWtbz3xxBMhhAEDBlRWVt57773l5eX19fVr1qzp7VfSw1Kpd+Wo4vQEPH0kXAIOQC5bPL20w7eqKUsa4om26jUJaTgAwH6SgwPkqLFjx55zzjkhhL\/+9a\/HH398WVlZtL2oqOi8884rLi5+8803v\/jFL77yyivR9sbGxmuuuWbjxo2nnHJKCKG9vf2+++5rbW1N\/W1Tp04dMmRIaWn+tILEE23VdYnZK5s63NvFbB0A5JrUpUupOq90URre+6sCAMgbMgKAHFVQUHDmmWeOHDmyuLj49NNPLygoSO06\/vjjzzvvvIKCgrq6uo997GPHH3\/8SSed9OEPf\/jFF1+87rrrSkpKosMWL168ZMmS6PH69etXrlx50kknHXXUUVl4Md0tlYBXr0nEE22p0e8oO9ADDkAf1cWXuOn5+OyVTSsaWnplRQAAeaKgvb0922sAoGM7d+684oorNm3adPvttx900EHpu1pbWx966KH\/+q\/\/evXVV0MIo0ePPuuss6644orUuPf3vve9DRs2bNq0qbCwcMyYMX\/+859POumkL3\/5y6mUvE+rqG3MKAFPpQMrGlqmDSvKxqIAoJutaGhJ3fci9U6X+va3LFZYOarYTTUBAPaGHBwgd23duvWzn\/3s1KlTr7322vR58P4pnmhLn5JLr\/8OIZTFCg2AA5CX4om2mteTqbw74x2wwx4VAAAy6EUByF0vv\/zyhg0bzjjjjH4egqdaUDI++UfKYoU3Ty0RggOQr8pihZ2F4BkyLpYCACDFleMAOaq5uXnhwoWTJ08+4ogjsr2WbKquS9TUJ\/f8YP\/8jGEVtY3zJg\/WggJA\/7F4emnN68nUO2P6MHgUkUeheeWo4qwtEQAgJ+lFAcghO3fuXLBgwQsvvHDmmWe+9tprt912249\/\/OOZM2dme11Z5gJwAMiwoqGlui5x89S3b\/uR\/napLgwAIIMZOoAc8te\/\/vWOO+7Ytm3bE088UVBQ8KlPfeqUU07J9qJ6W9SCWr0m0WHebcANAEII04YVdRaChxCE4AAAGfSDA+SQ8vLymTNnDhgwYOjQoZ\/97Ge\/\/vWvDxw4MNuL6j1RD3hFbWP1mkT69igQrxxVfPPUknmTB2dpdQCQu6omxDrcPmVJw5QlDdV1CdXhAEA\/pxcFgFyx572\/UiPhKxpa9IADQNeim2qkD4MrSwEAiMjBAcimeKKtLPb2xUmqwAGgu3TxBTMAQH+jFwWA7Ei1oHS4N2pB6eUlAUA+yShLSQ\/BK2obq+sSe\/wJAIC8ZR4cgCyorkukl4CnfzKfu3pHVXksfUgcANg3qbtPh3e+26ZGxasmxCpHF3vbBQDynhwcgCzQfwIA2eJdGADoh3ztD0BviFpQUk\/TP3KXxQrnrt6RjUUBAG9TlgIA5DHz4AD0rPQrskNaAj5lSUNZrHDasCItKADQm7ouSymLFVaOKq4qj3X65wEA+iA5OAA9q4uLr+OJNgk4AGRFlIan8u6M9+ugLwUAyC\/SBwB6VUVtY+qxEBwAsqUsVtjF0Hd6CF5Tn+yVFQEA9CABBADdKeoBT58pS32QLosVVk2I3Ty1JEtLAwA6tXh6aeWo4j23T1nSMHf1DtXhAEBfpxcFgO7RWQ94CKGitrFyVHHl6GID4ACQyzLKUsI7+1LKYoWLp5dmY10AAPtLDg5At+miChwA6Is6e3N3kw8AoG9x4gLAvosn2uau3tHhLp+NAaCvq65LpL+hp0LwKUsaKmobK2obVYcDAH2FeXAA9kXUAx59+k2f+56ypKEsVqgFBQDyRupNPz0HT+1VlgIA9AlycADes7mrd2TMf6U+GFfXJdJLRQGAPJPRlBI0oQEAfYFJPQDes3mTB3e2SwgOAPmtasI73uszLgurrkvEE229vigAgHchBwfg3XXdA57xeRgAyGNV5bHnZwyrmhDrsACtek1CdTgAkIP0ogDQlfQe8PDOma+K2sbKUcUGwAGg34on2lJpeEZfirIUACCnFGV7AQDktIraxs52uSkWAPRze3NP7OiLczfQBgCyy4kIAJniibbZK5uixxnDXF3E4gBAf7Z4emmqKi39\/CGeaIvKUuau3qE6HADIFr0oALwt6gFf0dAS0j7BRpc5l8UKtaAAAO+qui6ROmHIKEsJ+lIAgCyRgwOw2+yVTVECnpL6pJr+gRYAYC91URru7AIA6E16UQDYLSMET+djKgCwD9LLUjJEZSnVdQllKQBALzAPDtB\/1dQna15P3jy1JLUlNbSlBQUA6C7xRFvN68n084ou5sQBAHpCUbYXAEAWRAl4NAA+ZUlD+odPCTgA0L3KYoV7eWqhLAUA6CHmwQH6I0NYAEC2ROPh1WsS0dP085ApSxp8JQ8A9AT94AD9RU19srNdFbWNvbkSAKA\/i8bD96wOj76njyfaqtckpixpqK5LZGmBAEAeMg8OkOfiibYVDS2pFpTUyFX0UdPIFQCQI1yvBgD0HP3gAHlu9sqmeKJtz+0ScAAgd6xoaCmLFXZ40hJCqKhtdN4CAOwP8+AAeS5jtCqYrgIAclWqOjyjNDx64Ft8AGCf6QcHyCvxRFtNfTK97zv9Y2RZrHDe5MHZWBcAwLtLVYd3uDeqDu\/lJQEA+UEvCkCeiHrAq+sSnbWgVJXHKkcV9\/7CAADek7LY2wNbGXfzTr\/TidMbAGDv6UUByB\/uLgUA5J\/om\/4O7\/gdlKUAAHtHLwpAHxZPtFXXuToYAMhn04YV3Ty1ZPH00g6\/41eWAgDsDTk4QJ8UJeCzVzalf\/BLfTjUAw4A5Jn0spQ9bwOe0llHHADQz+lFAeh7qusSNfXJ9M94qQS8orZx3uTB04a5\/QMAkM\/ST4fS58SjiFx1OACQQQ4O0CepAgcAiK6QS78MLv0cyQkSAJCiFwWgD+i6B7wsVhjdOQoAoF\/J6ILrrC\/F\/VQAAPPgADktnmireT3Z2WW\/0Wc\/LSgAACGE6rpEh7dOifLxqgmxytHF6T3jAED\/IQcHyGld9J+saGiRgAMAZIiqwxdPL42eZpxNlcUKU7sAgP5DDg6Qc+KJtvRJJVXgAAD7zKkUABD0gwPklKgHvKK2scN2y8pRxTdPLen9VQEA9F1VE2Kd7aqobVQdDgD9hHlwgFzRWaNlCGHu6h2Vo4u1oAAA7IPohivRiVZGaXikakKsqrzTuBwAyANycIBcsecMuOt2AQB6iL4UAOhX9KIAZE3UgpJ6mv7pqyxWWDmqOBuLAgDIf3NX70h\/mn4apiwFAPKSeXCALOjw4twQwpQlDWWxwmnDiqrKY+m3ygQAoHt1XZYSDSUoSwGAvCEHB8iCLq7DjSfaJOAAAL0jSsNTebeyFADIV6IWgF4ST7TtzWFCcACAXlMWK0yF4BW1jV0cWVOf7JUVAQA9wjw4QI9LXXWbUYESQtCCAgCQO6Lbt0SRd4dnbspSAKCPkoMD9KD03slI6gNVRW2jBBwAIAdllKWEd\/allMUKF08vzca6AIB9JwcH6FlaJgEA+jR3dgGAPOANG6CbddEDXhYrrK5LdLYXAIAcVDWh4wv4pixpqKhtrKhtVB0OALnPPDhAt0lvQckolIzaJCtHF5sYAgDoi6Lq8HmTB6e2KEsBgD6kKNsLAMgT1XWJ9B7wdFUTYhJwAIA+rSxW2FkIHt55RaCyFADIQd6bAfZL6jNP+p2Uwjs\/GrkZJgBAnskoS0m\/FrCitnH2yqYuuvIAgN4nlwHYR\/FE29zVOypqG\/fcVRYrrJoQ23M7AAD5oao8tnh66bzJgzscd1jR0BJVh7s3DADkCP3gAO9Z1A6ZfkOk1ARQRW1j5ajijNlwAAD6iYy+lPQ5cQAgi\/SDA7xnHc6AR9wfCQCAPUXTEu4ZAwDZYh4cYK9k3O8ofdKnLFZoBhwAgBBCPNFW83qypj4ZT7SlhsHTTx2nDSuqKo9NG2YoDQB6lRwc4F1EPeArGlpC2pWt0YcZCTgAAB1a0dCSCruVpQBA1vkKGqArs1c2RQl4hudnDKuuS0jAAQDo0F5OfDulBIDeYR4c4F2Y3wEAYH9EZSnVaxLR0z37UqomxFSHA0CPkoMDvEOqBWXPzydaUAAA2GdRGp5+MmneAgB6jRwcYLf0HvDwzs8hFbWNEnAAALpXeg6efvKpLAUAup0cHGC3jHmcYCQHAIAe03VZiisRAaB7aR8D+rWa+mTqcUbqrZ8RAICeUxYrrCqPLZ5eWjWhg7A7nmirXpPYc1ADANg35sGBfqqmPlnzejK9BzyYvgEAIKtcoQgAPUQODvRHs1c2pXrAgzZGAAByQzzRVl2XSF2zmDGxYVwDAPaZHBzojzIGbUzZAACQO1LV4XteuRhcvAgA+0QODuS\/eKJtRUNLzevJm6eWpDb6IAEAQC6LJ9pSd6wxxgEA+6ko2wsA6EFRAl5dl4gn2kIIU5Y0pH9mkIADAJCz0m\/bXhYrjE5oM0RlKVXlscpRxb24NADoe8yDA3nO7AwAAHkgVR2uLAUA9oEcHMg36ReQhj1y8LJY4eLppb2+KAAA6AZdlKUEMx8A0LnCdz8EoI+IJ9pq6pOzVzalfyRIfRgoixXOmzxYCA4AQN+VPvCRIT0ETxUDAgAR\/eBAnqipT3Z2uq8zEQCA\/PP8jGFRU8qe58DVaxLVaxJOgwEgRS8KkD9UgQMA0A91XQzorBgAgl4UoO+K7hRUUdvY4d4urhgFAIB8spenvtV1iZ5eCQDkLPPgQN8TT7TVvJ5MXQGaPuEyZUlD1AM+bZjeJwAA+p3oVLl6ze7IO+NUOYRQNSFWObrY1AgA\/Y0cHOh7KmobMzoQU+f3KxpaJOAAABBVh6fuEp9RllIWK3QDeQD6FTk40DcoPQQAgH3m\/BmAfs6VUECue9ce8JunlvTykgAAoA+JJ9qqJsQ621tR26g6HIC8Zx4cyGnVdYlUuWF459zK3NU7KkcXa0EBAIC9kaoO37M0PFI1IVZV3mlcDgB9mhwcyGmu3wQAgJ7jfBuAfkIvCpBbohaU1Ol4xon43NU7srEoAADIQxln16lz7ylLGpSlAJBnzIMDuSJ1nWb0NP0sPIRQOapYCwoAAHSv9JPwjDPwEEJZrLByVLGyFADygBwcyBUZl2SGtBPxFQ0tEnAAAOgh8URbWezt68WVpQCQf\/SiANkUT7R1tiv9RFwIDgAAPSf93LuitrGzw5SlANB3mQcHsqOLu9WXxQqnDSuqKo+ln44DAAC9I7pnT019MrxzGDx1uq4sBYA+Rw4OZEF1XSLVAx7Szq0rahsl4AAAkAuiyZVU3q0sBYA+TdUAkAXpIXi6xdNLe3klAABAh8pihXsz9D17ZdO8yYMNsgCQ47xRAb0hurKyw11lscK5q3f08noAAID3pLOwe0VDS0Vto+pwAHKcXhSgZ6V6wKOnqcsnpyxp0AMOAEAvS67dmlzT2Lx2a3JNp3eDpAvxRFtNfbJqwu458YwLPaPq8GysC3h3xRNKB44fWnLKuGwvBLJDDg70rM5qBKvrEpWjiyXgAAD0tOTarduXrmtaum7LwlXZXgtA9hWPLx1+0dHDL\/6H4vFDs70W6D1ycKBnZeTgZbFCJeAAAPSapqXr1l\/6YHKt6W+ATMXjSyc+PksaTj8hBwe6U6oFJf328VEUHl0jaQYcAIBes3He8o3fXr7n9uLxJjOAfqezbwQnPjZLWQr9QVG2FwDkiYwe8HQScAAAel\/T0nXpIXjx+NIhp4wbftHR4h6g34rukbD9nb8eX5u56Mi\/XmYqnLxnHhzoNp1VgQMAQO97deai7UvXhb834R4y94RsrwggVyTXbt04b3nqrgnjbvnY8IuOzu6SoKeZzQT2XTzRNnf1jg53Gf0GACC7mtdsjR4IwQEyFI8fOu6W01MlUU1L12V3PdALBFXAvogS8Iraxpr6ZGpjNABeFiusmhBzM0wAAHJE8QSnpgAdGDhBFwr9iH5w4D2bu3pHevw9ZUlDqgKlakKsqjyWpXUBAAAAQAfMgwPv2bzJgzvbJQQHAAAAINfIwYF3F0+0zV7Z1OGuqAWll9cDAAAAAHtPLwrQlagHfEVDS3hn\/8nzM4ZV1DZWjio2AA4AAABAjpODA12pqG3sbJc7YQIAAADQJ+hFATLFE22px6kB8EgXsTgAAAAA5Cbz4MDb0ltQMhLwslihFhQAAAAA+iI5OLDb7JVNUQKe4fkZw6rrEhJwAAAAAPoovSjAbhkh+JQlDanHQnAAAAAA+i45OPRfNfXJ2SubUk\/Ti1DKYoVVE2TfAAAAAOQDvSjQH9XUJ2teT3bYgqIHHAAAAIA8IweH\/mju6h2px1OWNKQmwTPujQkAAAAAeUAvCvQL8URbTX0y26sAAAAAgCyQg0OeixLw2Sub0mfAU3PfZbHCeZMHZ2lpAAAAANAb9KJAPqupT1bXJeKJtuhpegVKWaywqjxWOao4e6sDAAAAgN5gHhzyWeWo4lQInmHx9FIhOAAAAAD9gRwc8krXPeBlsUIt4QAAAAD0N3pRIE\/EE20rGlqiFpS5q3ek+k+enzFsypIGLSgAAAAA9FtycMgTs1c2dVaBMm\/yYAk4AAAAAP2WXhTow+KJtuq6RPR48fTS9F1TljSkHgvBAQAAAOjPzINDnxRPtNW8nqypT8YTbVXlsYy9ZbHCeZMHZ2VhAAAAAJBr5ODQ91TXJaIEPHo6ZUlD1Ab+\/IxhFbWN8yYPnjbMjzYAAAAA7CYsg76nek2is10Z7SgAAAAAgH5w6APSe8BDCNH0d0pZrHBFQ0uvLwoAAAAA+gbz4JDToh7waAC8ek0iIwGvHFVcObpYCwoAAAAAdKHj+GzruuTa5dv\/9lRTw7rk1nXNW9cle3lZQLpP\/v3Bd8PfMrY8EsIjvb+gfmDouOIQwvgThgwdV\/yB84dHTwEAAADoizJz8K3rkk\/+YOOfF23JymoAckT0\/d+fFyVDCE\/+341DxxV\/YNbwk75ySLbXBQAAAMB79nYOvnVd8s+\/2vLk\/92YxdUA5Kat65JP\/t+Na5c3XfC7SdleCwAAkM9aW1uTyeSgQYN69F9pb2\/fvn37kCFDCgoKevQfAsgRb+fge4bgQ8cVR50AQw9VCAD0L1v\/lgwhrF3e9Lfl21Mb\/7Z8+4JpL31hxZHZWxcAAOSuTZs2feITn1i3bt1eHl9WVrZo0aIxY8b06Kr6hG3btj366KP33ntvfX39aaed9s\/\/\/M\/Tpk0bMGBAtHfnzp0PPvjgHXfcMXr06I0bN7a1tX3pS1+aMWPGPkTYzc3NL7zwwt133\/3II4+MHTv2tttuGzp0aHe\/mg4sWrTo\/vvvf+aZZ5LJd6\/e\/eEPf3jOOef0wqqAfmV3Dr52eVMqBI8u\/9eHC3BSOCS6VubPi7ZETSlb1yXvn7PuzB+Py\/bSAAAgRw0ZMuTiiy+eOXNmWVlZCOGOO+5YsGBBCOFzn\/vc5ZdfHkLYsmXLL3\/5y0WLFrW3t7e2tmZ5udnW2Ng4f\/78\/\/mf\/xkzZszXvva1GTNmDBw4MP2AN95449\/+7d9Wr149f\/78E088sb29\/f777\/\/Xf\/3X008\/\/T\/\/8z8zDn5Xa9asefHFF5cuXbp58+axY8d260vpyqxZs2bNmrVw4cLrrrsuhHDkkUfedNNN6V+BtLa21tfX\/\/znP7\/rrrt6bVVAv7I7B\/\/bU7sHHoeOK77gdxMl4ACRoeOKT\/rKISd95ZA7z301mg1vcOtgAADoyJtvvrljx46vfOUrF154YWpUeciQIdGDQYMGHXzwwSGEgw8++Lrrrhs1atSdd96ZtbXmhldeeeVLX\/rSK6+8UllZee21144YMSLjgObm5nnz5i1btmzOnDnHH398CKGgoOD0009fvnz5okWLxo8ff9VVV72nf\/Gwww477LDDVq5cec8993Tby9hrkydPjsViiUTigAMOKCkpSd81YMCAMWPGfOUrX1m1alXvLwzoDwqj\/4nmHFNFKFldEkAu+sD5u09Jt65rzu5KAAAgN7W2to4dO\/bUU099176OgoKCM844I4rF+60XXnjh0ksvffnll88+++xvf\/vbe4bgIYTly5c\/8sgjBx544GmnnVZUtHuWsaio6Iwzzhg4cOBdd931l7\/8pXdXvV9isVjXA+wHHnjg9OnT16xZ01srAvqRwvQnWw05AgAAAPukqKjomGOOGTly5N4cPHLkyMmTJ2\/fvv3dD+072tvbV65c+a\/\/+q91dXVdH7lhw4Yvf\/nL69evnzp16jXXXJMxHB1paWn5zW9+09zcPHHixIwOk0mTJpWVlW3evHnRokXd+QJyQFVV1SWXXJLtVQB5qOjdDwEAAAB4N5MnT543b95eHjxkyJDvfve7Pbqe3tTa2vqHP\/zh+9\/\/\/v\/7f\/9v9OjRqVtcdqilpeW\/\/\/u\/X3311ZKSki984QsHHXRQh4fF4\/GVK1eGEA499NADDzwwfVdpaem4cePWrl27cuXKrVu39s69LntHh18JAOy\/wnc\/BAAAAKDH7Ny5c+HChRUVFVF79dlnn718+fL29vbUAbt27XrkkUcuuuiiL33pS7t27XrggQc+8pGPTJo06bDDDvv85z+\/ZcuWEMKGDRu+\/vWvT506deLEiccdd9zvfve79L9hy5Ytd91111lnnfXMM8+8\/PLLl1122THHHHPkkUfOmjXrmWee2Z\/Ft7a2Ll++\/OMf\/\/gFF1zw4osvnnvuubfeeuu4ceO6+COrV6++7777QghHHXXUcccd19lhGzdujF7auHHjUqUokSFDhkStMuvXr6+vr+96hY2NjfPmzfvHf\/zHE0888UMf+tBPfvKTRCLR4ZEvv\/zynDlzov8Pp06dOm\/evMbGxoxjdu7cefvtt5922mn\/9E\/\/dMQRR1RUVNx9991NTU1dr2FvLFmy5IYbbtj\/vwegQ3JwAAAAIGvi8finP\/3plStX3nTTTS+++OL3v\/\/9NWvWXHDBBT\/84Q+jIHv58uX\/\/u\/\/PmfOnGXLlm3ZsuXKK6+88cYbL7jggjlz5gwePPixxx679tprH3nkkcsvv3zy5Mnf\/OY3jz322M2bN3\/jG99YsWJFCGHDhg2XX375CSeccO211\/71r3\/9n\/\/5n\/POOy+RSBxzzDGtra3PPPPM+eefv283jWxtbX3kkUfOOOOMVAL+8MMP33DDDYcffnjXDekPP\/zwtm3bQghjx4798Y9\/fMIJJ0ycOHHSpEkzZsyoqalpbW2NDnvzzTejwLrDEeloQnz79u17RtXpXnjhhTPPPPONN9647777li1btnTp0g0bNixevDjjsPb29oULF1566aUf\/ehH\/\/jHPy5duvS444677bbbKioq0jtetm3bdvnlly9cuLC6uvqpp5566KGHmpubv\/rVr37gAx+YOHHixIkT77333r36\/64jf\/nLX9K\/ugDoXnJwAAAAIDuampquueaa4uLib3zjG2PGjBk4cOC555577rnnhhBuvPHG2traEMIJJ5wwf\/78mTNnhhBWrFgxY8aMe+6556KLLrryyiuvuOKKEMLixYt\/8Ytf3HrrrRdffPE555xz4403Hn744YlE4v777w8hjBkz5uc\/\/\/n1118fQti1a1dTU9ODDz54xx13\/PKXv\/zVr341cuTI9vb2733ve6+++ureL7u1tfWBBx449dRTq6qqXn311VQCPnHixL15yVFAH0L44x\/\/eMQRR\/zmN7958MEHP\/GJT6xfv\/6qq6664oordu7cGUJYu3ZtdNioUaP2\/HsOOeSQEEIikdiwYUNn\/1Y8Hv\/3f\/\/3Aw444Otf\/3o0P15SUhLF1hlHPv744zfccMOVV14Z3YFz3Lhx\/\/Zv\/zZy5Mh4PP7d7353165dIYT29vYbb7xx2bJlH\/nIR97\/\/veHEMrLy6+++uqBAwfGYrFFixa99tpr55xzzl78\/5cp+kLizjvv3Ic\/C7CX5OAAAABAdjz77LNPP\/30jBkz\/j979x8fVX3mC\/ybkMRBQgi\/FINoqPUHLmqyDS5QLYu6rQWl1e3WWuuPrinG67X7au\/u3tLdSxV7V3ftrbZ72abK7mqrbXVfu3ZjQVq11FpFr+kmWhFLxYDAAIIyYIAxCcn949jxOCAESJjJ5P3+65wzJ+GZkMwkn\/M9zzNmzJjoSFFR0YwZM4qKijo7OzPLtEtKShKJRAhh0qRJF154Yab79oc+9KHo+Gc+85lMl+0xY8acfvrpIYTXXnstCpTD75dUJxKJa665Zvz48ZkPnzdvXlFR0datWx999NHeFNzZ2fnwww+fd955N954YzKZPKgEPLJjx44ouR49evS3v\/3tT33qU+PHjz\/11FNvvfXWv\/qrvyoqKnrsscfuvffeXn62\/XvwwQdXrVo1c+bMKDSPjBo1KkqxM3bv3n3fffeNHTt22rRpmYPHH3\/8pEmTQgj\/7\/\/9v1WrVoUQtm3b9vjjj4cQTj311MyC97q6uokTJ6bT6ZUrV\/a+sOeffz7qvhI5+eSTL7vssmQyeRjPFeAAzMkE6JXtr3XkugQAACgoPT09P\/nJTzo7O79Par3DAAAgAElEQVT73e\/+4Ac\/yBzv6Hjnd++2tra33nora0RkXCKRKC0tzep2XVRUVFxcHEJIpVIdHR1Dhw6NP1paWhrfnTZt2gknnLB27drW1tbOzs6sR+N2797d1NR0xx13vP7660OGDPn0pz993XXXTZw48WCecQghvPHGG1Enk8mTJ5966qnxsi+55JL\/+I\/\/WLVq1U9\/+tPLL7\/8YD9zljfffPNnP\/tZaWlpbW1tVnvxLK+88kpLS8uuXbsuu+yy6EsXibqTv\/XWW2vWrDnjjDN2794dVf7KK69kzqmoqDj++ONXrVr1+uuv9762s84665577smM9+zp6VmxYsVf\/MVfHNQTBDgocnAAAAAgB3bu3Llu3boQwu233x61PTnyRo0addJJJ61du3bz5s27du3KJLNxnZ2dP\/zhD7\/97W+\/+eabh5OAR4YMGRKl0sOGDcuK3ceOHTt58uRVq1ZF0y9PPPHE6Pg+O4BHoykTiUTU8GRvGzZs2LBhw5AhQzJr7d\/P+vXr33rrralTp95111377EUeKS0tjVbixydzHnXUUZWVlSGE9yujN4qKiiZPnvznf\/7nGzduPORPArB\/+qIAAAAAObBr164o94wi3ZzIxLj7UVJSMmXKlD\/4gz8oKiras2fPr371q5dffjkzzfJgjRkzZj9Zc9SxJJp+WVVVFZ25z6XWURg9bNiw0aNH7\/NTbd68OZrGeUBRI\/Ldu3fv\/0mNGjWqpqYmhLB8+fLXXnstOvj222+nUqnRo0f\/4R\/+YW\/+rf0466yz4gvkAfqWHBwAAADIgaOOOmrUqFEhhJdeeinXtYTx48cPGzZsnw8VFRVNmjTp3nvvffTRRy+88MLNmzffcMMNM2bMeOSRRw4hDR82bFi00Hvjxo2Z9uVZosmTxxxzTJRxr127Nusf2rlzZxSOjx8\/PtMYfZ\/S6fT27dv3X1I0h3Pjxo1vvvnmfk4rKSn567\/+69NOO23jxo233HJLdPXiqaeeeu65566++urDj7AnT5588cUXH+YnAXg\/cnAAAAAgBxKJRJTz\/upXv9pnAnv\/\/fc\/99xz\/VpDJlCePHny\/ptohxA+8IEP\/NM\/\/dPPf\/7zP\/3TPz3kNHzYsGFnnnlmCGHTpk1RA+64rq6uEMLYsWNHjRo1duzY6MxkMrlr1674abt27YqGbZ599tkVFRX7\/IfGjh0bLSdvbW3df0ljxowpLS19\/fXXly9fvvejyWTyjjvuiJq2jx8\/\/kc\/+tFHP\/rRtWvXXnLJJZdddtnPf\/7z++6774YbbthPa3WAfCAHBwAAAHLgqKOOmjx5cgjh5ZdffuCBB3p6euKPtra2\/uxnP6uuru7XGt588822trZjjjnmvPPO6+WHTJgw4fbbb3\/qqac++9nPHloa\/rGPfWz48OEbN25csWJF\/HhXV9fLL78cQqitrT3mmGNKSkouvfTS0tLS1157LZlMxs9cs2bNxo0bhw8f\/sd\/\/MfvF99PmDDh+OOPDyE8\/vjjW7Zs2U89J554YtTd+7vf\/W4Ur2d0dnYuXLjwmGOOKSsrCyG0t7f\/\/d\/\/\/cyZMx955JFHH330gQce+PrXv37GGWcUFRX18rkD5IocHAAAAOgvmzdv3s+js2bNitp6fOMb31i4cGFnZ2cIYc+ePU888cSNN974yU9+cv9NPw5WV1dXOp2OH1m2bFkymfzc5z73gQ984KA+1THHHPP1r3\/9qaeeuvLKK7du3XrDDTdMnz69l2n4pEmTogYg3\/\/+9+O90detW9fa2jp69OgrrrgiWl599tlnz5gx44033nj00Uczp\/X09CxevDidTn\/605+eMmXK+\/0ro0aNmjNnTgjht7\/97b\/+679mCtu6devq1atDCLt3746+4Mcff\/yf\/MmfRAVcc801r776anTmtm3b5s2bt3bt2o997GMhhK6urttuu+2ZZ575yEc+Eg3MPFjbt2\/P+voDHDFycAAAAKBf7N69u62tLdpesWLF3u2wTznllJtuumnYsGE9PT3f\/OY3Tz\/99HPOOaempua666678sorL7rooui0TH7d1dXV3d2d+fB0Oh0luevXr88czJycyXnjD82bN+\/555\/v6enp6el57LHH7rjjjs997nPXXHPNAZui7NMxxxxz8803L1++vL6+fteuXb1Mw0tKSv7n\/\/yfM2bMeOaZZ77+9a9HUfi2bdtuvfXWt956a\/78+WeddVZ05tChQ\/\/3\/\/7fZ5999l133fXss89GB5cuXfqjH\/1o9uzZ119\/\/f67kVxxxRUzZswIITQ2Nn70ox\/9wQ9+cO+9915zzTXReNJVq1bNnj37O9\/5Tnd395e+9KXozNWrV19wwQW1tbVTp06tq6v73e9+d8stt4wZMyaqcPny5W1tbR\/+8Idra2s\/8ntXXXXVbbfdtmrVqqwV\/Xt79dVXo\/+RDRs2bN26tXdfY4C+URS9SP3ki+teeGBbCOHMy0Ze9O0Jua4KIO88efvmJ7+xOYQwYkLZDc2n5bocAAAO4OUP3tWxdkcIYcI\/Xzjyqsm5LmfQWb9+\/aJFi5588slMDh5CmDhx4rnnnltfXx\/168hYtWrV\/\/2\/\/\/eZZ57ZunXriBEjLrjggquuumry5MlRt43nnnvu3\/\/933\/84x9HLarPO++86667bvLkyYsXL77rrrteeeWVEMKwYcOuvvrqK664Ytu2bf\/0T\/\/005\/+NEqizzvvvGuuuWbq1Km\/+MUv5s6dm0gkrr\/++l\/+8pe\/\/e1vhw8fPmHChLlz586YMePQVjdn2bFjx\/e+97277rpr+PDhP\/zhD0844YT9n79nz56lS5cuXLhw3bp1I0aMGDJkyDnnnHPttdfuvTJ99+7dDz744P333z9u3Lji4uLdu3dffvnlH\/vYx4YOHXrAqqKPveeee1577bXS0tJzzjnnhhtuePDBB7ds2fKZz3zmj\/7oj4YPH54589\/+7d8eeOCB1atX79mz5+STT77iiisuvvjiTP\/xnp6exx9\/\/G\/\/9m+jjupZioqKbrzxxr\/4i7\/YZ4+UBx544LHHHvvFL36RuUJQXl4+Y8aM6L\/ygM+CfrL6ggd2PrEuhDDyqj+Y8M8fz3U50L\/k4AC9IgcHABhY5ODEPfbYY1EOfu+99+6nl8jha29vf+yxx6ZPnx513C4kUQ7+wAMP3HTTTWVlZZ2dnatXr96xY0cIob29\/eGHH16zZs0PfvCDA14AIH\/IwRlUDuWuHwAAAAD2Vl5e\/slPfjLXVfSLpUuX3nrrrd\/97nfHjx8fHamqqso8Onv27BtvvHHLli1ycCA\/6Q8OAAAAwP5s2bLlW9\/61ogRI8aNG7fPE1KpVHl5uRAcyFtycAAAAAD2Z8uWLVu2bHnppZeampqypoD29PSsXLnyq1\/96mWXXTZ27NhcVQiwf\/qiAAAAAIWsp6fn+eefDyGk0+mVK1f2a3\/wQnXyySd\/\/OMf\/+EPf3jzzTffeuutp59++mmnnRZCWL9+\/W9+85vq6uq\/\/\/u\/P+WUU3JdJsD7koMDAAAABeu55577u7\/7uzfeeOP4448PISxatOihhx76yEc+8sUvfnHIkCG5rm7AKC0tvfnmm2fNmnXXXXc9\/\/zzra2tv\/nNb0444YQZM2Z86UtfOvPMM30xgTwnBwcAAAAK1pQpUx566KFcV1EIhgwZMn369OnTp+e6EIBDoT84AAAAAACFTA4OAAAAAEAhk4MDAAAAAFDI5OAAAAAAABQyOTgAAAAAAIVMDg4AAAAAQCEryXUBFL5nn332C1\/4wlVXXfWXf\/mXWQ9t27btnnvuWbx48fr160tLSz\/4wQ9ef\/31559\/\/pAhQ7LO3LNnzxNPPHH33XcfddRR3d3dmzZtmjt37ic+8YnS0tJDPhMAAAAAGAzk4PSvDRs2\/O3f\/m17e\/veDz3\/\/PNz587dsmVLtNvR0fH88883NDR84hOf+Id\/+Id4bN3e3n7zzTcvXrx4wYIFf\/qnf1pUVPTrX\/+6oaHh3\/7t3xobG0eOHHkIZwIAAAAAg4S+KPSjzs7OhQsXrl69eu+HtmzZMm\/evDPOOGPx4sW\/\/e1vX3jhhW984xujRo0KIfznf\/7nD3\/4w8yZPT093\/3ud\/\/93\/\/9T\/7kT2bPnl1UVBRC+NCHPnTttdc+99xzN910U1dX18GeCQAAAAAMHnJw+tHDDz+8YsWKiRMn7v3QI488UlFRceutt06aNKm0tLS8vPzSSy+9++67hw8fHkJYunRpZgn5qlWrfvSjH5WWll544YVDhw7NfIbzzz9\/zJgxS5cufeqppw72TAAAAABg8JCD019efPHF73znO9dff\/2xxx6b9VB7e\/svf\/nLuXPnjh07Nn78jDPOOPfcc0MIa9euffPNN6ODDz\/88BtvvDF27NjTTjstfvJxxx33wQ9+sLOz87777nv77bcP6kwAAAAAYPCQg9Mv3nrrrX\/4h3\/4sz\/7s+nTp+\/96O7du\/\/oj\/5oypQpWcdLSkomT54cQiguLo66mmzfvj1axH3ssceOGTMmfnJ5efmJJ54YQnjppZc2b97c+zP78GkCAAAAAPlPDk7f6+npue+++yorKz\/72c8WF+\/je2zs2LFf+MIXohYo+zRhwoRopuX27dtff\/31EMJxxx0Xb3USidLtLVu2rF27tvdnHtZzAwAAAAAGGjk4fe\/xxx9vamq68cYby8vLD\/Zjo5z63HPPHTZsWAhh27Ztb731Vghhn6F5dLCrq+uNN97o\/ZkHWxIAAAAAMKCV5LoACs2GDRvuvPPOuXPnnnzyyQf7sdu3b3\/55ZcnTJhw4YUXRn1RtmzZEg3MHD16dElJ9rdrpvP4K6+8Ul5e3sszD7YqAAAAAGBAsx6cvtTZ2XnnnXdOmzbtoosuOoQPf\/rpp1euXHnttddWV1f3dWkAAAAAwCAlB6cvPfjgg+vXr587d25paenBfuy2bdvuuuuuWbNmXXrppdFicAAAAACAwycHp8+0trbec889N9xww9ixYw\/2Y3t6en70ox8dddRR8+bNi3cVHzt2bLQb9f7OEjVCCSFUV1f3\/syDrQ0AAAAAGND0B6fPPPDAA+vWrZs3b158NXdPT8+WLVtCCPfee29TU1MIYf78+RdccEHWxy5dunTJkiXf\/OY3szL0sWPHjhgxor29\/Y033ujq6spq\/L1p06YQQiKRGDVqVO\/P7MvnDAAAAADkPTk4faazs7Ojo2PDhg37fHTnzp07d+4MsaXZGY888sjChQvvuOOOvUdrVlRUTJgwYcOGDRs3bty9e\/fw4cPjj65duzY6Z+LEib0\/8\/CeJQAAAAAwwOiLQp\/5xje+8epeXnjhhalTp4YQ\/tt\/+2\/RkU9+8pPxj\/r1r399991333LLLXuH4CGE8vLys88+O4SwefPmHTt2xB\/auXNnlLmfeeaZ48aN6\/2Zffy0AQAAAID8Jgcnl1pbW7\/yla98+ctfrq2tjR\/v6en5l3\/5lyVLloQQPv7xj48ePfr1119\/9dVX4+e88cYbq1evLi0t\/ehHPzp06NCDOhMAAAAAGDzk4OTMiy+++NWvfvW666774Ac\/+Pp7\/eAHP\/jpT386ZcqUEMIpp5xy8cUXd3V1PfTQQz09PZkP\/8UvfrFx48aPfOQjF154YXSk92cCAACDR8eaHQc+CQAoaPqDkxsbNmz40pe+tHr16r\/+67\/e5wk33HDDmDFjQghFRUVf\/vKXU6nUf\/7nf55zzjmXXnppCKG1tfUf\/\/Efp0yZ8jd\/8zfl5eXRh\/T+TAAAoOANmzGh43srQgibb3k6hHDs\/Om5rgggX3Ss3b7t3hU7n1gX7ZadOCK39cARIAcnB5LJ5HXXXbd69er3O2H48OHnnXdeUVFRtFteXn777beff\/75jY2N999\/\/7HHHrtx48a5c+dedtllFRUV8Q\/s\/ZkAAEBhG3nV5G3fWxFtb77l6W3fe3HkVZOHzZhQPmNCbgsDyJWOtdt3PrGu\/Yl1mZfHEELZiRWuFDIYFEXtI37yxXUvPLAthHDmZSMv+rbfCQCyPXn75ie\/sTmEMGJC2Q3Np+W6HAAADmzb915cd+3SvY+XnWiVDDDodKzdR5OoshMrjv\/nj7tAyGBgPTgAAACFaeRVk0tPHLH+2key0p99hkEAg83Iq\/7g2PnTNUVhkJCDAwAAULDKZ0w47ZW5USfcqFE4wCBXdmLFsBkTRl412TJwBhU5OAAAAAWu7MQRx86ffuz86R1rt3es2dG5dnvHGkvCC0oy3V2VKM7sNq5JhxDmjCuLHxwkouceQqirLKmrFPvwrrLqitITR8i+GbS8IAIAADBYlJ04ouzEESGIgQpKMt39Ny3tyXR368zK6MjXQmhsS9dOTOS2sCOvZlkqnPvO9rOJ4iXTtMIHeMeguy4KAAAAFIxkuru+pT2Z7g5RCvx7DYMvBA8hNFS\/+6yjr0wOiwHIK3JwAAAAYEBqTnXNWr4jCsEjs5YP6o43DRMT8V4ozamuHBYDkFfk4AAAAMCAlNX\/uipRvKi2PFfF5IkFk46ONlpnVmYaxQAgBwcAAAAGqkzUW5UoXjKtYhAOxswSXQyQgANkGexvDwAAAMAAkkx3N7al40daZ1Y2VCfMhMzIWiYfQpi\/cldOKgHIH9mvjAAAAAD5KTMVs3FNOr7keXBOxeyNzOzQOceV7Z2PAwwe1oMDAAAAA0AmBI92Mwkv7yf+JYp\/6QAGITk4AAAAMABUJYrjSW5Vorg51ZXDevJfZmZmRHcUYDCTgwMAAAADQ3wq5qLaco0+9m\/OuPf0QllUW57DYgBySw4OAAAA5KloKma8v0frzMqqRPGSaRVVCZnGgS2qLa9KFLfOrIy3UwcYhLxnAAAAAPkome5u2tjRuCaddXzJtIqc1DNAZX25Zi3fkatKAHJIDg4AAADknWgqZiYENxWzT9QsS0Vf2FwXAnCkycEBAACAvLP3VMzGtuyF4fRefUt75lpCc6rLiFFgsJGDAwAAAHmtKlG8YNLRDRMTuS5kAFsw6ej4bn1LuygcGFTk4AAAAEC+iC\/6jkY7ViWKF9WW11WW5K6oQhB9GeNHfEmBQUUODgAAAOReMt3d2JZuXJOOtwJvnVm5qLa8KiG+6AN1lSUN1e+sqY+uMQAMHi79AQAAADmWTHc3bezITMWME4L3oYaJCe1lgMHJewkAAACQY\/Ut7fEQPL4knH5VsywVn0cKUKjk4AAAAECOLZlWkdmuShRn2nfQr6LrDfNX7sp1IQD9Tg4OAAAA5EZzqiuznZmKuWDS0Xp39Lf6lvbMovvmVFd8PClAQZKDAwAAADnQ2JaOp7Hh91Mx6yoNM+t3WdNH99mZHaCQyMEBAACAIyqZ7m5sS2ey13gUbirmEbNg0tGZ7WgxPkAB8+4CAAAAHFFNGzuyFiDry3Hk1VWWRH3YheDAYCAHBwAAAI6orPbfDdUJDcFzomFiIh6C1yxLNW3qyGE9AP1HDg4AAAAcaZmpmELwPBF1p5m\/cld8eClAwcjOwV94YNvap9tzUgpA3tq+rsNrIwAAHI7mVFe8D3gIoXVm5YJJRwvB80H8v2b+yl05rASgn7yTg5\/w4fLMofsvefXJ2zfnqB6A\/LJ9XccLD2y775JXX3t6Z3TkxOnDclsSAAAMOI1t6fqW9vDevDWEUFdZkqOKeI+oUXgkme4WhQOFp6inpyfauu+S1ZmUJzJiQtmJ04eNmFA24oSyXNQGkEuvPdWeWtex9wvjDc2n5aokAAAYiBrb0llTMQ1mzEP1Le2Zjij+g4DC824OHkJ48vbNT37DSnCAfRsxoexzD31gxASXBgEA4ODEl4HPGVe2YNLROSyGfUqmu2ct3xGE4ECBek8OHkLYvq7jyds3v\/DAtlwVBJCHRkwoO\/Oykef+1bG5LgQAAAaMZLq7KvHuWLIoCjcVM581p7p0qgEKVXYOHtm+rmPt0zu3v9ax9un27es6t6\/rOPKVAeRQtOj7xOnDTvhw+YgJpSdOLz\/ghwAAABnJdHd9S\/uSaRWZI7OW75gzrkwIPoDULEu5bgEUjH3n4AAAAACHJtNhI2iyMWBlWtksqi23SBwoAMUHPgUAAACgdxrb0pkQPLy3MzgDQnOqK\/6\/Nn\/lrhwWA9BX5OAAAABAn2lck47vViWKk+nuXBXDIairLGmofrcXStTiJof1APQJfVEAAACAvpRZTTxnXNmCSUfnthgOTX1Le3OqK+hsAxQK68EBAACAwxJvCB5+n5w2VCeE4ANX9H8nBAcKhvXgAAAAwKGL+mYk090y08I2a\/mOJdMqcl0FwCGSgwMAAACHaJ8rwSkwmUY3dZUli2rLc1sMwKHRFwUAAAA4RPEQfO9dCkB8SGZzqitqGg4w4MjBAQAAgEMUXwBelSi2WLjwZDV5j3rg5KoYgEMmBwcAAAAOQjLd3diWzuxGUficcWVLplVUJeQMhWbvyxv+l4GBSH9wAAAAoLcyUzGDbuCDSX1Le3Oqy\/84MHDJwQEAAIBeiYfgEcEoAAOCO1kAAACAXpm1fEc8BK9KFDdt6shhPeSQmajAwGI9OAAAANBbNctS0UbUNlqr6EEo8z1QV1liMiowUHi7AgAAAHoraoQiBB+06lvaM9vNqa74xFSAfGY9OAAAALBvyXR308aOxjVpfcDJyKwHj\/jeAAYEV24BAACAfUimu+ev3NW4Jh32ij4ZzOK9UITgwEBhPTgAAACwD3tPxVwyrSKH9ZA\/GtvSDRMTua4C4CBYDw4AAADsQzz1rkoUyz3JyPpmqFmWak515aoYgN6QgwMAAAD7E03FnDOuLNeFkI+injn1Le2icCCfycEBAACAdzS2peOtwFtnVkYheFVCgEC25lRX\/LulsS2dw2IA9k9\/cAAAACAk091NGzuiqZjB\/EN6J2sZeEN1Qv8cID\/JwQEAAGCwS6a756\/cldXXQhROb8SjcN8zQN5yWxMAAAAMdlWJ4ngIXpUobqi2qpdeySwAF4ID+cx6cAAAACCE3w88rEoUzxlXprsFAIXEenAAAAAYpLIGG2amYgrBORw1y1JmZgL5xnpwAAAAGIwa29LRVEztLOgr0S0FkUW15XWVJTksBiDOenAAAAAYXJLp7kwIHt6bXcIhy5qzOn\/lrlxVArA3OTgAAAAMLlWJ4kwIHtHFgsNXV1kSH6+aTHfnsBiALPqiAAAAwGBkKib9ob6lPVoYrt8OkFesBwcAAIBBIZnunrV8R2Y3moopBKdvLZh0dBCCA\/nHenAAAAAofPGG4DJKjpiaZam6ypJFteW5LgQY7KwHBwAAgAIXD8GDwZgcKdF3WnOqSwN6IOfk4AAAAFDgsqZizhlXlqtKGDzqW9oz241r0lHTcIBckYMDAABAgYs3QmmoTkQdnKFfZfWdj8fiAEeeHBwAAAAKUDLdHd+NpmI2VCdMxeTIqKssiV9x0ZUeyC05OAAAABSaZLq7vqU9qw\/4nHFlQnCOpDnjyuoqS4IQHMgDRT09PbmuAQAAAOgzWVMxRZAAYD04AAAAFJSsqZiQP2qWpWYt35HrKoDBSA4OAAAABSvqSgH5IGrUEzXtyXUtwKAjBwcAAIABLz4VM9MIpaE6sai2PEcVwXvEs+\/mVFdzqiuHxQCDkP7gAAAAMLBFC2yT6e54K\/DGtrSpmOSPZLo7qyOKzvXAkSQHBwAAgAEsE4JHu7JF8lZzqitaFe67FDjy9EUBAACAgappU8es5TviTVEMISRv1VWW1FWWCMGBnJCDAwAAwEA1Z1xZfLcqUawhOPks6\/uzZllKo3DgyNAXBQAAAAa2mmWpEEJdZYkQnIEi+qaNLJlWUZWwUhPoX15lAAAAYCBJprvnr9wVP9I6s7KhOiEEZ6Bo2tQR3836fgboD9aDAwAAwIARn4qpzzIDV31Le7wjSkN1omFiIof1AAVPDg4AAAADQzwEj4jCGbjiI159JwP9TV8UAAAAGBiqEsXxEDxrFwaWBZOODiG0zqwUggNHgPXgAAAAMJBEAwarEsWLastNFwSA3vB+CQAAAPkrme5ubEtH2XekdWZlXWXJkmkVQnAKTM2yVLxpOEAfsh4cAAAA8lQUgjdt6oh2tY+gUMWv9CyqLa+rLMlhMUBBcukYAAAA8lE0FTMTgkOhyloD3tiWzlUlQAGTgwMAAEA+2nsqpnyQglRXWTJnXFlmV2sUoD\/oiwIAAAD5y1RMBon6lvYoAdf\/B+gPcnAAAADII41t6YaJicxuzbKUEJzBIJnuzvom3\/sIwCGTgwMAAEBeSKa7mzZ2NK5JB0tiGfRqlqXqKksW1ZbnuhCgQLiqBgAAALmXTHc3tqWjEBwGuagdUHOqS098oK\/IwQEAACD36lvamzZ1ZHZnLd+Rw2Igh+Lf\/I1r0sZmAn1CDg4AAAC5t2RaRWa7KlE8Z1xZDouBHFow6ej47vyVu3JVCVBI5OAAAACQM\/E14FFP8GgqZnxUJgwqdZUlDdXvfv\/HLxEBHDJzMgEAACA3Mg3B41Mxk+nuqoRVawx29S3tzakuA2OBviIHBwAAgCMtme5u2tgRn4op74P9a0511VWW5LoKYKByhRkAAACOtMxK8PiRXBUD+a9mWcrPCHA4rAcHAACAHKhZlspsN1QnNASHfYr\/pMwZV5Y1RROgl6wHBwAAgBzITMUUgsN+xHuhNG3qaE515bAYYOCyHhwAAACOhKZNHfNX7srqA24qJuxfMt09a\/mOzK5O+sCh8V4LAAAA\/a6xLT1\/5a7w3iYPIQQhOOxfVaI40wtFCA4cMm+3AAAA0L+ypmJmReHA\/s0ZV1ZXWSIEBw6HHBwAAAD6V1b774Zq3cDh4CyqLc9s1yxL1SxLaRQOHBQ5OAAAAPSLZLo7s51ZymoqJhyOzO0UUaMhgF6SgwMAAEDfS6a761va4y1QqhLFQnA4HI1t7\/YXin7EclgMMLAU9fT05LoGAAAAKChNmzoyi1U1NYY+VN\/SHu+Isqi2vK6yJIf1AAOFHBwAALiSeEsAACAASURBVAD6UtZUzCAKh76TTHfPWr4j2vaTBfSevigAAADQl7I6n1Ql\/OkNfaYqURzNzBSCAwfFenAAAADoY5m24BqCA0A+cFEaAAAADle8V0P4\/UpVITgcATXLUjXLUvGm4QB7sx4cAAAADksy3V3f0p5Md2vUAEdY5t6LEMKSaRXaEAHvx6sDAAAAHLqmTR2zlu9IprvDeyM5oL9lrQGfv3JXrioB8p8cHAAAAA5dVvQW744C9Ku6ypK6ypLMrtYowH7oiwIAAACHJbMMvCpRvGRaRW6LgcEmuiFDVyJg\/+TgAAAAcHCS6e6mjR3xGZg1y1KmYkJONKe64qvCAfZJDg4AAAAHITMVM4RgCSrkm5plqbrKkkW15bkuBMgvcnAAAADorXgIHhGFQ56ID6pdMOnoOePKclgMkG\/MyQQAAIDeijoRZ3arEsVG80E+iP9ghhDmr9zlZxOIk4MDAABAb8VXf1clihfVlmtMDPkg+nmMH5m\/cleuigHykBwcAAAA9idrnWkUhVclipdMq6hK+LMa8kVdZUlD9buzapdMq8hhMUC+0R8cAAAA3lcy3d20saNxTVofcBgQ6lvaDckE9iYHBwAAgH3LmoopCoeBKJnudusG4FUAAAAA9i0egocQZi3fkcNigENQsyylUTgQ5OAAAADwfuL9hasSxQsmHZ3DYoCDUrMsVbMsFUJoTnU1tqVzXQ6QY3JwAAAAeI+9I7OqRPGi2vK6ypKc1AMcgvgPbOOadHOqK4fFADknBwcAAIB3JNPdjW3pxjXv5uCtMyujEFx\/YRhYGiYm4rsD6DpWT0\/P+vXr77rrrvPPP\/+f\/\/mf29raPv\/5z5988sknnXTSn\/3Zn7322mtZ57\/66qvz5s276qqr\/vIv\/\/Lss8++5JJLfvazn5kICFnMyQQAAIAQQkimu5s2dmRCcFMxYaDLXNYaWD\/OTz\/99H\/913\/ddddd7e3tU6dOTaVSs2bNGjVqVGNj4\/r1688555zvfOc7w4YNCyH09PR8\/\/vfv\/3227\/4xS\/W19cXFRVt27bti1\/84lNPPTV79uxbb721vLw8188G8oUcHAAAAEIIYdbyHfGpmGGgZWfAATW2pbPWieen9vb2uXPnPvPMM6eddtrChQsnTpwYQvjxj3\/85S9\/efjw4ffdd98ZZ5wRQnjyySe\/8IUv1NTU3H333cOHD48+tq2t7corr0wmk\/X19V\/96ldz+TQgn7irCwAAAEIIIR6CVyWKG6oHQFgG9F7NstSAaxR+1llnRSF4COGkk04aPnx4e3v71q1bQwhvv\/32\/fff39HRceaZZ2ZC8BBCdXX1BRdcEEJYvHhxW1tbTsqGPCQHBwAAgBBiq7+rEsULJh09IBaNAr1UsywVbcxfuSu3lfSVN954Y8WKFSGEY489Nn68qKiopqYmhLBx48bVq1fnpjjIP3JwAAAABq\/GtnR8NzMVcwCN1AMOKP6Tnkx3F0YU\/sYbb+zYsWOfD02cODHqDL527dojWxTkLzk4AAAAg1Ey3R3N0MusEo0smVZRlfDHMhSUhomJ+MWtpk0dOSymz23evDnrSHFxcVFRUVFRUUmJS3rwDm\/tAAAADDrJdHfTxo7GNe8sEc2KwoHCs2DS0ZntwhiBO27cuDFjxoQQ1q5d29HxnmS\/u7u7p6enuLi4uro6N8VB\/pGDAwAAMOhUJYozIXgkq0EKUGCilkehUELwEMLIkSPPPvvsEMKKFSu2bNkSfyiZTLa3t5900kknn3xyjqqDvCMHBwAAYDCKT8VsqE6YigkFr66yJCsEH9AXwEpKSq644orRo0cnk8mlS5dmjnd1df3yl78cMmTIpz\/96aqqqhxWCHlFDg4AAMBg0ZzqirdAiaZiLph0tBAcBqGaZanGNenmVFeuC9mHPXv27N69O4TQ2dmZObh9+\/Z0Ot3T07Nnz57oyOTJkxcsWDBs2LDGxsbW1tbo4KOPPvqTn\/ykvr7+yiuvPPKVQ94q6unpyXUNAAAA5J0nn3zy1ltvffnll0MIp5122vXXX3\/BBRcMHTp027ZtDz300J133llWVnbzzTfPnj07hLBhw4Z\/\/Md\/XLx48c6dO4cNG3bxxRd\/+ctfjhrXRp577rk77rijtLS0oqJixYoVJ5xwwkUXXfSpT33qSD6jaCpmtF0wjRGAQxC\/HlaVKF4yrSKHxext5cqVjY2NP\/nJT3p6esrKyi6\/\/PL6+voVK1bceeed0Wvycccd95WvfGXWrFlDhgwJIaxbt27hwoWPP\/54TU1NcXHxnj175s6dO2XKlKKiolw\/FcgjcnAAAAD27de\/\/vXnP\/\/59vb2q6+++mtf+1rmeDKZvPzyy+fOnXvFFVeEEH71q1\/NmzfvyiuvvPLKK9Pp9C233PLjH\/\/4lFNO+Zd\/+ZfolvwXX3zxz\/\/8z+vr67\/whS8UFRWtX7\/+6quv\/uxnP3vttdcemSeSNRUzIgqHQSt+VSyEUFdZErUOBwqYvigAAADs21lnnTVz5swQwrPPPvvmm29mjr\/00kudnZ1TpkwJISSTya9\/\/et1dXWf\/\/znhw4dOnLkyOuuu2706NGrVq1auHBhdPP+0qVLt27d+oEPfCBanHj88cdfffXVR\/KJ7D0Vc864siNZAJBXGiYm6ipLMrtCcBgM5OAAAADsW0lJyaWXXlpaWvryyy8\/8sgj0cGenp6f\/vSnkydPnjBhQgjhwQcf\/N3vfjd79uzS0tLohPHjx5900kkhhGeeeSZKz3fu3BlC+P73v9\/e3h6dU1dXN2rUqCP5XOKrvxuqEwsmHX0k\/3Ug32Syb7eGwCAhBwcAAOB9fehDH\/rQhz4UQmhqatqxY0cIYf369c8+++z5558\/dOjQnTt3\/td\/\/VdxcfFNN930kd+bNWtWMpk8\/vjjE4nE1q1bQwjnnXdeWVnZk08++YlPfOKZZ54JIZx++umXXHJJfxefTHfHd6OpmA3VCVMxgRDCotpyITgMHiUHPgUAAIDBqry8\/PLLL3\/22WdbW1tfeOGFc845p7W1NYQwffr0EMLOnTvXrl07dOjQb33rW1Fcvk\/nnHPOV7\/61b\/7u79ra2u74oor\/vAP\/\/D\/\/J\/\/c8IJJ\/Rr5cl096zlO0LWSvCJCR1RgEi8NUo0OVOjcChg1oMDAACwP1OnTj311FM7Ozv\/4z\/+4+23337sscemTJly3HHHZU5ob2\/ftm3bfj5DUVHRVVdddc8995xyyik9PT2\/\/vWvZ8+e\/dhjj\/VfzY1t6SgED7+PtyJCcGBvmVeJ5lRXc6ort8UA\/UQODgAAwP6MHTv2M5\/5TAjhV7\/61VNPPfXCCy+cd955JSUlIYSSkpJhw4aFEJ566qm9P\/DNN99sa2sLIbS3t+\/Zs2fq1KmLFy++8847R40atXPnzq997WvRo\/0haypmJhMHyJLVQKm+pT3rCFAY5OAAAAAcwMyZM8ePH79169bbbrutqKiopqYmOl5RUXHyySeHEBYvXrxy5cr4h3R2dn7zm9986aWXQgg333zzL3\/5yxDCkCFD5syZ8+Mf\/3jixImbNm1as2bNESh+zriyJdMqjsA\/BAxEVYnirF4o81fuylUxQP+RgwMAAHAAxx9\/\/Cc\/+ckQwiuvvDJ16tSqqqroeElJyac+9amysrKtW7f+9\/\/+33\/3u99Fx3fs2DFv3rzNmzfPmDEjhNDT0\/Pwww\/v2bMn89lqa2uHDRtWUdGX8XR8CWemJ3hDdWLBpKP78F8BCk9dZUmmV3jrzEotwqEgycEBAAA4gKKioosuumj06NFlZWUf\/\/jHi4qKMg9NnTr1U5\/6VFFRUVtb24UXXjh16tRzzz337LPPfumll2666aby8nfipCVLlixbtizaXr9+fUtLy7nnnnv66af3VYXJdHd9S3u8FXjrzMqG6kTDxERf\/RNAAVtUW15XWRIfqwsUmKKenp5c1wAAAEC+27179\/XXX\/\/666\/fe++9Y8eOjT+0Z8+epUuXfutb31q9enUI4bjjjrv44ouvv\/76zHLv2267bcOGDa+\/\/npxcfH48eNfeOGFc88990tf+lImJT9MyXR3vAO4JAsAyCIHBwAA4MC2b99+zTXX1NbW\/q\/\/9b\/i68FzrrEtnTUVsypRrCE4cDiim0vqKkv0SIGCoS8KAAAAB7Zq1aoNGzbMnj07r0LwEEJW55O9R94BHJRMh6XmVFdjW3r\/JwMDhRwcAACAA+js7Pze9743adKkU089Nde17EOmEcqccWVLplVUJfypCxy6+GtI45p0c6orh8UAfaUk1wUAAACQj3bv3r1w4cIXX3zxoosuevXVVx9\/\/PFvf\/vbfdXR+zBFUzHjzU9aZ1Y2tqVNxQQO34JJR9e3tGd26yqlZ1AI9AcHAABgH37zm9987nOfe+utt0IIRUVFl19++de+9rXS0tJc1\/VOCJ5MdwcjMYH+EQ0e8AoDhcTNYgAAAOzDxIkTL7jggiFDhowYMeKaa675yle+kich+KzlO6IQPMTa+AL0oYaJiawQXHcUGOisBwcAAGAgiWff0VRMDcGBfhW97CyqLdcjBQYuOTgAAAADTJRJCcGB\/ha\/8FZXWbKoNi9mJACHwK8LAAAA5LVkuruxLR1Po1pnVs4ZV7ZkWoUQHOhX8QXgzamuxrZ0DosBDof14AAAAOSvZLp7\/spdmc68xtYBR1h9S3u8ObhXIRigXDkHAAAgTyXT3VkJFMAR1jAxkdkWgsPAZT04AAAA+StrKmbDxMSccWU5rAcYhJo2dXjlgYFODg4AAEBeMxUTyDeNben4OnEg\/5Uc+BQAAAA4gvYOmITgQJ7I3KRSN7IkPkUTyHPWgwMAAJAvkunupo0djWvSQR9eIP9kdWpaMq0ih8UAB8W1dAAAAPJCMt09f+WuKAQP782bAPJBQ\/W7t6pEg3xzWAxwUOTgAAAA5IX6lvbmVFdmVxcUIN80TEzEe6Esqi3PYTHAQfFbBQAAAHkh3mGgKlFsBh2QhxZMOjra0LsJBhb9wQEAAMilrKmYNctSpmICA0h9S7uF4ZD\/5OAAAADkTGNbeu+pmMl0txAcGBCiSQYN1Qm3sECek4MDAACQA8l0d9PGjsxUzKDJADDQxMf5Lqotj7cOB\/KNC+wAAADkwPyVu+IheAihsS39ficD5Jtkuju+W9\/SnnUEyCtycAAAAHIg3k63KlGsqwAwsFQlijMzMzNHclUMcEB+PgEAAMiNqBFKVaJ4zrgyITgw4MwZV5bphaKzE+Q5\/cEBAAA4QqKpmFlpkamYwIA2a\/mOJdMqcl0FcABycAAAAI6EKASPti2cBAqVWBzyk0vuAAAA9Lt4CB5CqFmWymExAP2kZlkqme6ub2nPdSFANjk4AAAA\/S6r\/XdDtW7gQEGpb2nPXOFrTnU1p7pyWw+QRQ4OAABAf0mmuzPbmamYDdUJUzGBArNg0tHx3fqWdlE45BX9wQEAAOgXUXOAZLo73g28sS0tBAcKUnOqK9MRxRQEyDfWgwMAAND3GtvSs5bviK8HjwjBgUJVV1kyZ1xZEIJDXrIeHAAAgD6WNRUzSIWAwao51VVXWZLrKoDg5xAAAIA+1jAxEc\/BowWSAINKZmzmkmkVVQktGSDH\/BACAADQjxqqE1nj4wAKXiYEDyHMX7krh5UAETk4AAAAfSCZ7p61fEdmt3VmZVWiuKE6oSE4MAjFe6E0p7oa29L7ORk4AvQHBwAA4HAl0931Le3RVEytwAFCCFmzgr02Qm5ZDw4AAMBhadrUkRX3AJBpCdU6s1IIDjlnPTgAAACHJd4GN4RQlSheMq0iV8UA5I\/GtrTeUJAn5OAAAAAcrkwUXldZsqi2PLfFAOSt5lRXvHU4cMToiwIAAMBBS6a756\/cldmNbvlvqE4IwQH2qWZZqmZZqr6lvTnVletaYDCyHhwAAICDYyomwEGJ949y3wzkhPXgAAAAHIR4CB72ag4OwN4aqt\/tEt6c6orfTwMcGXJwAAAADsKs5TsyIXgIoSpRHN8FYG8NExPxtuALJh2dw2JgcNIXBQAAgIOTWQNelSheVFtelbDECuAAkunuWct36CUFueKXFQAAAA4ga8V3lOPUVZYsmVYhBAfojapEcVYIXt\/SnqtiYBCyHhwAAID9Saa7G9vSTZs6LGME6CvRjTUN1YmGiYkDngwcPjk4AAAA7ytrKqYoHOAwZU1ZWFRbHm8dDvQT968BAADwvuIheAhh1vIdOSwGoABkDcmcv3JXriqBQUUODgAAwPtaMq0isx1NxcxhMQAFoK6ypKH63V4oWQMYgH4iBwcAACBbY1s6sx31QolCcFMxAQ5fw8REpheKflNwZOgPDgAAwLuS6e6mjR2Na9LxaKa+pd1KcIA+lEx3u7IIR5IcHAAAgHck092NbemmTR3RrlWKAEfMrOU74q2ogL4lBwcAAOAds5bviHeqrUoUC2UA+lvNslS0MWdcWdYUTaCvuP8CAACAd2SF4HPGleWwGIDBoL6lPbPdtKmjOdWVw2KggFkPDgAAwLuiZYmmYgIcGcl096zlO+JH9KSC\/uB3GgAAgEGtsS2duSU\/hNA6s1IIDnDERC+5mV0hOPQTv9YAAAAMUtFUzMY16azjS6ZVCMEBjpi6ypK6ypIgBIf+pC8KAADAYBSF4E2bOjJH5C8AeaJmWWpRbXkUjgN9whV+AACAwagqURwPwasSxY1t2QvDATjyol5V81fuynUhUFDk4AAAAINUZgF4VaJ4zriyhomJ3NYDQGZgQzLdXd\/SnttioJDIwQEAAAaRpk0d+5yKKQQHyAfxXijNqa74jTvA4dAfHAAAYLCIT8XUDRwgDyXT3bOW78jseq2GvmI9OAAAQOGLpmJmQvAQu\/UegPwR3aMTbQvBoQ\/JwQEAAApfVaI4HoKHEBqqNUIByEd1lSUN1QkhOPQtOTgAAMCgEI9UGqoTGoID5K2sl+iaZanmVFeuioHCoD84AABAwUqmu6sS71n\/NGv5jjnjyoTgAANFpo3VkmkVWS\/pQO\/JwQEAAApT06aO+St3BR1mAQam5lRXfUt7ZreusiTTOhw4WC4iAQAAFKDGtnQUggcjMQEGprrKkrrKksxuc6qrsS29n\/OB\/bAeHAAAoABlZd9VieIl0ypyVQwAh6y+pT1qDu7mHjgc1oMDAAAUoKypmEJwgAEqmuggBIfDJAcHAAAoEMl0994HG6oTpmICDFx1lSVZIXi8aTjQS\/qiAAAAFIJkuru+pT2Z7o7HJY1taSE4QMHI9LxyjRMOlhwcAABgwGva1JGZihncPg9QiLIGPyyqLY9P0QT2T18UAACAga2xLR0PwUMIs5bvyFUxAPSTRbXl8d2sV35g\/+TgAAAAA1vWrfFViWJTMQEKT11lSUP1uy\/4+5wJAbwffVEAAAAGpGS6uyrx7tqm6H55HWMBClt9S3tzqkv\/KzhYcnAAAICBJ5qKmbXu21RMgIKXdREU6CU5OAAAwAATheDRHfGWBAIMcvUt7Vmtw4G9ycEBAAAGkuZUV31Le\/yIKBxgcIo6YgVNsaAX3EYBAAAwkNRVlsR3qxLFRqUBDELxa6KNa9LNqa4cFgP5Tw4OAAAwAMTD7swC8KpE8ZJpFRrFAgxCWQvA56\/clatKYEDw2xIAAEC+S6a7mzZ2ZO5\/DyG0zqxsqE5kzckEYPCoqyxpqH43CveOAPunPzgAAEBei0\/FDLqBAxBjSCb0kvXgAAAA+SsrBA8hzFq+I4f1AJBXskLwmmUpjcJhn+TgAAAA+StrDGZVonjBpKNzWA8AeStqn6VROOyTHBwAACCvxadiLqotr6ssyW09AOSbxrZ0ZoZEdCNRbuuBPCQHBwAAyC\/JdHdjWzp+pHVmZVWieMm0iqqEP+IAyNYwMRG\/Stqc6tIdBbKYkwkAAJBHkunupo0djWvSwUhMAHotme6OD5DwDgJZ5OAAAAD5Yu+pmIIMAHqpOdUVdUTx3gF701cOAAAgX+w9FTOHxQAwsNRVlkjA4f34pQoAACAfVSWKF0w6OtdVADCA1SxLaRQOEX1RAAAAcqyxLd0wMZHZrVmWqkoUL6ottx4cgENTsywVbURjlnNbDOQDOTgAAEDOvN9UzGS6WwgOwKFpbEtH7yyRusqSRbXlOawH8oHfqwAAAHIjHoKH2Nq9oDM4AIehYWKirvLdoYBao0CQgwMAAORKfUt7fL1eCKGxLf1+JwNA78WbaxmeCUEODgAAkCvxhq1VieKG6kS8SzgAHI5o2LIQHCL6gwMAAORSNBVzwaSj4\/ewA0DfqlmW0iicwUwODgBAf9m+rmPt0zu3v9axfV1HrmuBPNK0qWPOuLL4EVMxC9KICWUhhBM+POzE6VIn+lf0Pus9l\/1o2vTON0bWGxAUhhETykacUHbi9GHRm+8+ycEBAOhj29d1vPCjbU9+Y3OuCwHICyMmlJ152cgzPzNyP3+cw6HZvq7jyds3v\/DAtlwXApAX9vOeKwcHAKDPSMAB9uOE6cM+99BJua6CAiEBB9iPvd9z5eAAAPSN7es67rvk1b1vxx4xoWzEhNIQQqWFkMCgkVrXsX1d5z5fEi\/69vE6pXCY9vmeGy1+HDGh1BsuMHik1nWEEN7vPfeG5tMyu3JwAAD6xk++uC6zKm3EhLITpw874zMjZT3AILf3jTJZf5bDIbjvktWvPb0z2o6aAOhEDwxy29d1pNZ1vPbUzvh77pmXjbzo2xOibTk4AAB9YPu6joV1L0fbIyaUfe6hD2iDC5CxfV3Hw19clwkub2g+zYskh2zt0+33X\/JqtB2PeAAIe73nfnXzmdGGieQAAPSB1O\/vQxSCA+xtxISyeJfStb\/\/4xwOwfZ1ndHGiAllQnCALCMmlF0ce21c+3R7tCEHBwCgL+3dmA8A6A\/ecwF6Tw4OAAAAAEAhk4MDAAAAAFDI5OAAAAAAABQyOTgAAAAAAIVMDg4AAAAAQCGTgwMAAAAAUMjk4AAAAAAAFDI5OAAAAAAAhUwODgAAAABAIZODAwAAAABQyOTgAAAAAAAUMjk4AAAAAACFTA4OAAAAAEAhk4MDAAAAAFDI5OAAAAAAABQyOTgAAAAAAIVMDg4AAAAAQCGTgwMAAAAAUMjk4AAAAAAAFDI5OAAAAAAAhUwODgAAAABAAaqcUBZtyMEBAAAAAChkcnAAAAAAAAqZHBwAAAAAgEImBwcAAIAjasSE0lyXAACDixwcAAAAAIBCJgcHAAAGjJ\/\/\/OctLS25rgIAClxPT8\/OnTtzXQX0pZJcFwAAALAPTzzxxNy5czs7O+MHzzzzzLvvvnuf57\/66qu33Xbbqaee+j\/+x\/\/Y5wl79ux54okn7r777qOOOqq7u3vTpk1z5879xCc+UVqa3aGi92cCQMF4++23n3jiiaamppUrV06dOvX888\/\/8Ic\/fNRRR0WPbtu27Z577lm8ePH69etLS0s\/+MEPXn\/99eeff\/6QIUOyPo83XPKTHBwAAMg7u3fv\/td\/\/desEDyEcPbZZ48cOTLr4IYNG2677balS5fu2bPn\/7d3\/6FV1n0fwK9j23TsuOGPNcWW0zZTSjH2TMNbw7Ji6RORhhbPH\/mjphQl2pNoQT8UXFgJKYFpSIi3zkpSTF2gFJrjER\/BjZoaaqypS8eca5srXZznj\/Ow+zS1e1vWjqfX66\/rfK\/P+fI9\/+zD9d51fa9hw4Zdc8KmpqY333xz586dS5cunTZtWigUOnz48Lx58z755JM1a9bEztnxSgBIDC0tLRs3bly9enVKSsrLL7\/81ltvhcPh2ILy8vKioqLa2trox8uXL5eXl8+bN++xxx5bsWJFbGyt4RK37IsCAADEncrKyhMnTmzYsOF\/fuull15KSvrX3Tytra3r16\/fvn17bm5ujx7XvbqJRCIffPDB1q1bH3rooSlTpoRCoSAI8vPz58yZc+jQoTfeeKO1tbWzlQCQGGpra+fOnVtcXHzXXXd9+umnM2bMaBeC19bWLlmyZOTIkTt37jx+\/HhFRcU777zTt2\/fIAi2b9++efPmtkoNl3gmBwcAAOJLa2vrhg0b8vPz8\/Pzb\/2ttqezo5KSkmbPnv3cc8899dRTAwYMuN6E3333XUlJSXJycmFhYWpqatv4pEmT+vfvX1paeuDAgc5WAkACOHv2bFFR0ddffz1mzJhVq1bl5ORcXbN79+709PTi4uIRI0YkJyeHw+GpU6euW7eud+\/eQRCUlpY2NTVFKzVc4pkcHAAAiC8nT548ePBgXl7e1fuidM2OHTvq6uoyMzOHDx8eOz5w4MDc3NwrV65s3Ljxl19+6VQlANzsGhsbFy9eXF5enp2dvXTp0szMzKtrmpqa9u3bV1RU1O7syJEjJ0yYEARBVVXVhQsXooMaLvFMDg4AAMSRSCSyefPm8+fPr1y5cvTo0SNHjly8eHF1dXWXJ2xoaIjeU5aVldW\/f\/\/YU+FwePDgwUEQVFZWnjt3ruOVXV4MAMSPkpKSAwcOhEKhOXPm5OXlXbOmpaVl7NixBQUF7caTkpLuvvvuIAh69OgR3dVEwyXOycEBAIA4cvr06b1797Z9bG5u\/vjjjydOnLh8+fKu3R7e0NBw\/vz5IAgGDhwY++R1VPRiu7a2tqqqquOVXVgGAMSVM2fObNmyJRKJ5OTkPPDAA9Es+2qZmZnPPvtsdAuUa8rOzo6+01LDJc7JwQEAgDiSnZ29f\/\/+ioqK3bt3z5w5M\/qqrkgk8uGHH65atSoSiXR2wvr6+sbGxiAIrnkNHx1sbW2tq6vreGVn1wAA8ebQoUOnTp0KgmDQoEHbtm27\/\/7777jjjqFDh44bN27dunUtLS3\/doZoTj1hwoS0tLRAwyXuycEBAIC4Ew6H77zzztdee+3gwYPz58+\/5ZZbgiBYu3btvn37OjtVbW1t9P1d\/fr1S0pKanc2KysrenDixImOV3Z2DQAQVyKRSFtLLS8vT0tLW79+\/Z49e1544YXGxsbi4uJp06bVETS0zgAAB3NJREFU1tb+zgwNDQ3Hjh3Lzs4uLCyM3kuu4RLn5OAAAED8Sk1NnT9\/\/qpVq1JSUrw1CwBuiObm5rNnzwZBkJKS8tZbb82aNWvIkCFDhgxZsGDBihUrUlJSjh07tmLFit95DKusrOzo0aNz5szJycn569YNf4AcHAAAiHeFhYVPPvlkEATV1dXRJ6kBgC67dOlSTU1NEAS5ubn33HNP7KmJEyfee++9QRCUlZVd7z3V9fX1a9eunTx58tSpU6+3sTjEGzk4AAAQ70Kh0JQpU3r16tXY2Hjp0qVOfTczMzO6yfg1A\/Toc9lBEOTk5HS8slMLAIB4EwqFohuSJCcnt3tTZWpqajQHv96bKiORSElJSc+ePZcsWRLtm1EaLnFODg4AANwEBg0a1K9fvy58MTMzMyMjIwiCurq61tbWdmd\/\/PHHIAh69erVt2\/fjld2YRkAED9SU1PbtuG+Wm5ubnD9N1WWlpbu2rVr2bJlmZmZseMaLnFODg4AANwEkpKSevToceutt0avnDsuPT09Ozs7CIKampqWlpZ2Z6N3uqWnpw8ZMqTjlV3+FQAQD8Lh8ODBg4OYl1teLTk5uWfPnu0Gd+\/e\/f77769cuTIvL6\/dKQ2XOCcHBwAAbgLnzp27ePHi8OHD09LSOvXFcDg8ZsyY6Aw\/\/fRT7Knm5uYzZ84EQTBq1KgBAwZ0vPIP\/hYA6HZjx44NguDChQvRF2bGunLlShAEvXr1uu2222LHDx8+vG7dumXLll0dggcaLnFPDg4AANwE9u7dG4lECgsLo\/uZdsojjzzSr1+\/8+fPnzp1Kna8rq7u5MmTycnJDz\/8cHR31I5XAsBNraCgYOjQoT\/\/\/PPBgwfbnfr222+DIBgxYkTsDt1HjhxZvHjxwoUL271XMxKJrF+\/fteuXYGGS3yTgwMAAPGiqanp9ddfnzRp0rp162IflD5y5MimTZtmz549bty4Lkw7bNiwRx99tLW19bPPPotEIm3jX331VU1NzX333VdYWNjZSgC4qQ0aNGjGjBmhUGjr1q01NTVt4\/X19QcOHEhJSXn66ad79+4dHfzmm29eeeWVuXPn5ubmnv+tTZs2ffHFFwUFBYGGS3zr9J0UAAAAf5KGhoYvv\/zy9OnTxcXFJSUl7733Xl5e3p49e5YvXz59+vRnnnkmOTn5ml\/8\/vvv6+vrgyCor6+PRCKhUCj2bCgUWrhw4cWLF7dv3z5+\/PipU6cGQXDkyJHVq1cXFBS8+uqr4XC4s5UAcLObOXNmVVXV5s2bFy1atHLlyszMzJaWltWrVx89enThwoUPPvhgtOzMmTMLFiw4efLkokWLrjnP888\/379\/\/0DDJb6FYv\/lAgAAXVNV1vTPx\/\/\/sdbn\/3d4RnZK966Hm9ehQ4fefffd48ePNzQ0pKWlDRw4cNKkSdOnT8\/JyWmXbrfVb9u2bceOHdHXfIVCofHjxz\/xxBPjx4\/v06dPbOWvv\/5aWlq6Zs2alJSUrKysmpqayZMnz5gxIz09vd2cHa+ETlmeVRE9+K\/Phg4eJ+Khiyq21H\/+YnX0+JVzo7p3MdzsIpFItPNWVlZmZGREIpH8\/PxZs2aNHj062nbPnj1bVFRUWVl5vRl69+790UcfxW6WouHS7RqqL7\/\/H8eix23XJnJwAABuADk4wL8lB+eGkIMD\/L5r5uD2BwcAAAAAIJHJwQEAAAAASGRycAAAAAAAEpkcHAAAAACARCYHBwAAAAAgkcnBAQAAAABIZHJwAAAAAAASmRwcAAAAAIBEJgcHAAAAACCRycEBAAAAAEhkcnAAAAAAABKZHBwAAAAAgARxsfry1YNycAAAAAAAEpkcHAAAAACARCYHBwAAAAAgkcnBAQAAAABIZHJwAAAAAAASmRwcAAAAAIBEJgcHAACAP11D9eXuXgIA\/H3JwQEAAAAASGRycAAAAAAAEpkcHAAAAACARCYHBwAAAAAgkcnBAQAAAABIZHJwAAAAAAASmRwcAAAAAIBEJgcHAAAAACCRycEBAAAAAEhkcnAAAAAAABKZHBwAgBvsYvXl7l4CAPwtNOi5AB0jBwcA4AYYPC6ckZ0SPf78xdP73z7XvesBiCsVW+o3Pn4qetz21xK6ZtSMPm3HGx8\/VbGlvhsXAxBXGqov73\/73D9jem5b2w1FIpHuWxgAAIlj\/9vn9r\/zr\/g7IzsleqF++z\/SBo8Ld9+6ALpB9C7dqrLmHw40VZU1x960O2pGn\/9cld19SyMRbHz85A9lzW0foz034\/aUjOxkPRf4u4ntue3+NTjhv7MmvJwVPZaDAwBww7SLwgFoRwjOjdIuCgegndgQPJCDAwBwY1WVNX3+4mnblQK0E71jN\/aCHP6g\/W+fq9hSr+cCtJORnTLh5azYXaQCOTgAAH+GhurLFSX1VWVNblUD\/uYyslMGj0u7\/R\/hdlfjcKNUlTX9cKDZ81gA0Z478sk+19whSg4OAMCfq6H68sXqyw3VV7p7IQB\/nYzs5CAI7NTMXyl6Y7ieC\/zddLDnysEBAAAAAEhkPbp7AQAAAAAA8Cf6P\/FbDdA3khMlAAAAAElFTkSuQmCC","width":1092}
%---
%[control:dropdown:4e16]
%   data: {"defaultValue":"6200","itemLabels":["Select","4200","5100","6200"],"items":["\"Select\"","4200","5100","6200"],"label":"Select an answer.","run":"Section"}
%---
%[text:image:3875]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:slider:53cf]
%   data: {"defaultValue":3,"label":"Number of Splits:","max":6,"min":1,"run":"Section","runOn":"ValueChanging","step":1}
%---
%[text:image:568c]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:slider:1fad]
%   data: {"defaultValue":2,"label":"NumTrees:","max":10,"min":1,"run":"Section","runOn":"ValueChanging","step":1}
%---
%[control:slider:0685]
%   data: {"defaultValue":2,"label":"NumSplits:","max":5,"min":1,"run":"Section","runOn":"ValueChanging","step":1}
%---
%[control:button:2f23]
%   data: {"label":"Fit Ensemble of Trees","run":"Section"}
%---
%[text:image:0158]
%   data: {"align":"bottom","height":24,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAsCAYAAAAXb\/p7AAADlklEQVR42u1YS0hUYRQejR4UvR+SvaCyWiS2DIoCKWjVYzG2SsYWQ+a8HRwXFkOgqdGLSoSeqyBaJUGLCKGkNpGtgiyScnpYBpaU5au+E+eH03Wu93rvP2OEFw46955z\/u8\/7\/\/3eDQ+4XD4Eui65199AK4d1DEJcBLgfw0wGo2ujkQi1yoqKlY5AFgDqnWw5lpaMxaLrbBkDgaDm7HIEKjTCcjxPqFQqABrdYEGsHaRXaESCAyCXpNFMwwuReDw\/77xusurQGJna0ysPR2K94CnGdQKesnUyu92J5PJaelk4c51Chzcu9dp0O9nkO3yvd\/vnwqlEbzvAf2yoB5sIkwyBt0doJ+0Qbdu2AXyC8UrOVuNQH5Q3IJegfrTfH8ikwC\/A9hjsdaYCQQCG6D4vVj0DShB7+HKXMGaQ\/EFADEGrPhJdn1GAhoZvRDKX4jFTvt8vhlWchSD4D0OGiE5AH9eXl4+PxNF+IoCB8sccyBfreQB8qJWcAC0CYqHeYE2cqEDNTmQvcc6hlC+CnXWq\/PCtTtdeGGr0HNWFz7aeTcr\/eT1eqe41PVWJYxd62zkovwXqQ6Cv8vErm9r8MZNEctLVf9Ph4GwecSOjPSQu8V28e6chmRrFPq28btHJhhSBKDIBH0B726HEDilAWCtsGCx6MmjMNgaHqBkiygPl3UmHE1OrjOEiqoqsqDHGizYxrqGAXCOriL9jJUOoq3lO9UDQItpQGD3PtXZRapFHB51oSchwiWsDWA8Hl8Cpb2svA+WWO4AXJ7Q0Z1IJObq7sUBN\/UQLr0hrHfANSCaQihrobiBf+dC+QOxSNk4MrdEyN1VvRy6T+DdVbOp2wpcCyutN8yDahjtVZ3A4sS2ALwflYxhaK1n0C22QfL8dkuNRYZBlKxxRLj6gg3XNgj+w8beLOriHcv50gocJ8wsfP\/ASgfMDlRs8XzwfGPeThMr2QcpEqFprJmPSoSwSvMYfCcFX6nFlNPEfAGrUuC1GkhxQpspTnTfKysrFxl5qqqqZouy0mU81ZmApB6cp2vKlrFVk+Z7TGRuPOsXRZSNfGYmEO\/ofoXmOiKKS3Ga6wPYeRNxk9Vo49BONAIL1mUdIBa9bxPgn+zMOkAqIXDdQbp1sKAy6uWeyWd0Cyuk5LDh3pTtez\/NSVJqNwbh5kNZB8htkTrP1zHA9dM1nZ07nExmc50ZQGA7M+GxyLden9MA\/OLm\/KKe34xPoKAD7jPkAAAAAElFTkSuQmCC","width":22}
%---
%[text:image:6715]
%   data: {"align":"baseline","height":511,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAA1EAAAH\/CAIAAAA5bsBKAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAgAElEQVR4nOydeUAT19rwz2QhgYR9EQgiiyBa0ap1p7jXfb8ubRVaebWbXu+n1Vtt9bq87l77aou1eqvVVqu3Lq1WtNW61KUoihY3djQkJBB2CFkmyXx\/HDsdkxACBBLC8\/sLZiYnz5nMnPOc5zwLQVEUAgAAAAAAAJwalr0FAAAAAAAAAFoc0PkAAAAAAACcH9D5AAAAAAAAnB\/Q+QAAAAAAAJwf0PkAAAAAAACcH9D5AAAAAAAAnB\/Q+QAAAAAAAJwf0PkAAAAAAACcH9D5AAAAAAAAnB\/Q+QAAAAAAAJwf0PkAAAAAAACcH9D5AAAAAAAAnB\/Q+QAAAAAAAJwf0PkAAAAAAACcH9D5nI2cnJyNGzf27NkzIiKiZ8+eDx48MHsZRVFr1qyJiIiIiIgYPHjwwYMHZTKZDcXQaDT379\/fsmVLXFzcxYsXm9CCTCajOxIRETF58uSTJ09WVFSYvfjo0aNdunTZuHEjRVHNE9w27NmzJ6IhunXrlpaW1grCaDSaq1ev\/v3vf9+wYUMrfB3gsGRnZ8+ePTsqKioiIiImJmbkyJFz5sxZsGCBRqOxt2h\/QZLkvXv3Pv744yVLliiVykZ9Vq\/X37x5c+HCha+++mqfPn0GDx4cHx\/\/4Ycf\/vDDDwsXLtyzZw++5unTp4cPH546dery5cutaZaiKIlEcujQodmzZz958qSxPWrwG3U63dWrV+fOnRsREREZGbl3717mOIbPJiYmRkZGRkVFLV26tAkyGEFRlFwuP3nyZGJiYmJiYm1tLT7uaAPp7du333\/\/\/cjIyIiIiKioqLi4uH79+sXExIwfP37fvn3V1dX2FrDtATqfsxEVFbVy5cq5c+cihGpqak6cOGH27ZVIJL\/++iv++\/33309MTAwKCrKhGEVFRZmZmcePHy8qKmpaC0FBQXRHhELhunXrpk2b5u3tbfZiuVxOkmRxcbFer2+60DbF19f3q6++ysnJyc\/P37t3L0LI3d39xx9\/zM\/Pz8rKWrJkiUajqaqqamkxVCrV5cuXd+zY8dNPP9WnMQPtgYcPH7755ptlZWW\/\/PJLfn7+hQsXIiIibt68WVtbS5KkvaX7i4cPH3711VffffedXC5vlOZRUFAwbdq0OXPmaLXaQ4cO3blz58aNGykpKT169Fi1alVKSopOp0MIVVdXP3v27PTp03\/88YfBYLCm5dzc3CNHjmzcuPHJkye4kUbR4DdyOJwhQ4bs37\/\/tddeoyhqx44d58+fNzqbnJzcv3\/\/0aNHb9mypWvXro2VwQi1Wp2bm3v58uVr164xf31HG0j79eu3adOmHj16IIT69u17\/vz527dv\/\/777127dt28efOoUaP++OMPe8vYxgCdzzkRCoX4j19\/\/VUikZhecPny5eLiYoIgEEIdOnSwyZeKxeLPP\/8c\/x0eHj5hwoSoqKhmtok7QhAEi2XpWV20aNGdO3e2b9\/O4XCa+Y02QafTzZo1a9iwYWw22\/Qsl8t96623+vfv3wqSuLq6jhkzZuzYsa3wXYAjc+LEibKysg8++CA8PBwh1LFjx+Tk5NmzZ0ul0rq6OjsKRlHUwYMHadtVr169pkyZ0thGpFLpggULHjx4MHv27OTk5PDwcDy4CYXChISErVu3uri4PH36FCHk7e09ZMiQYcOGWd94VFTUW2+91eRx0spv5HK5eLjTarU7duyQSqXMs0KhMDg4uHv37jYZ4lxdXePi4iZPnmx03NEGUoQQm812dXVlHvH29l6zZk3\/\/v0VCsW6detqamoabCQtLe348ePMI8zZql0BOp\/TEhAQIBQKpVLp2bNnjU4pFIqjR49OmDCBVg2bT01NzSeffIJH1daHzWb7+PhwuVy7fLspVVVVAwYMsHCBUCiMj4\/n8\/mtJhLQnqmtrc3KyjI6yOVyExMThUKhWq22i1SY8+fP7969uwn2MxqVSrV27dq8vLyePXsuW7bMdBwYM2bM7NmzmydmK9G1a1cXF5e8vLwVK1ZYo83YFkcbSOtDKBT27t0bIZSbm9vgpCOVSleuXFlaWkofse9sZV9A53NaXnnlFfxW\/PDDDwqFgnkqNTW1trZ2xIgRtvoukiQ3bdp0\/fp1WzXYNJRKpYO4oXz88cdxcXGWr3n33XcbvAYAbAKXy3Vzc0MIJScnFxQU0McjIyOnTJlCu3O1Pvfv31+9enUzlc7Hjx+npqYihEaPHm3W\/YMgiDfffNPyMsxBmDBhwpIlSwiCuH79+qZNm+yy7e44A6kFsMGCoiitVmvhspqamhUrVuTl5dFHHGS2sheg8zktfD5\/+vTpBEHk5OTgARGjUqlOnDgxfPjwkJAQ009RFHX79u25c+cuXLhw8uTJ8fHx+\/btY04JqampCQkJu3fv3rhx44wZM7Zu3YoQ2rVr17lz5xBCP\/\/8c3x8\/N\/\/\/ncj52udTnfmzJm+fftGRESMGDEiJSVFpVIhhNLS0qZOnRoXF3fp0qUm97SiouLw4cMjRoyYP38+\/t6ampqUlJSEhISEhIR79+5hv\/UePXp8++239FiGezp79uxXX321a9eu48aNu3nzJn326dOnixYtmjVr1sKFC\/v167d+\/Xr6Jkil0n\/\/+9+vvfbaxYsXFy1aFBUVlZSU1LRZU6\/Xp6WlLVq0KDEx8eLFi2PGjImKitq\/fz9CqLq6esuWLSNGjOjXr19sbOy6deuwwzIOyFi0aNGoUaPu37+\/aNGimJiYmJiYrVu3MqcH\/PEZM2Z88MEHU6dOvXLlSpNvL+AE8Hi8cePGEQSRl5c3Y8aMixcv4kedw+HMnz+\/W7duiPHWLF++nI72iIqKWrJkSU1NTVpa2owZM6KiokwfNmxHweEgffr0WbZsmZEFpb4L8vLyVq1aVVlZWVtbO3\/+\/Pj4eKOZODU1ddy4cZGRkbGxsdu3b69PAbp8+XJtbS2fz+\/Tp099dyAqKupvf\/ubhVvU4NCHEYvFCxYsiImJiY2NXbx4MXMH1sKgYT0EQbz99tuzZs1CCJ04cYLp2Ge9wDjoZO\/evSNGjNi9e\/fp06fj4uIiIiLGjBnz8OHD+ho0GkitbESlUh08ePC1114bMGBA165dFy1aZOU9aeZAWlxcjBDi8\/keHh4kSR4\/fnzixImLFy+eMGHCuHHj8JSnUqnWrVt37949hNCXX34ZHx+\/YcOG+mar7Oxs\/BDGxsbGxcWdPn0aOzWSJHnx4sWEhIRly5adOXNmwIABsbGxFy9ebMIddggowBn54osvli5dWl5ePmXKlPDw8GnTplVXV+NTd+7c6d+\/\/507dzIyMnr06BEeHn7hwgV8ymAwfPnll717905PT8f\/Hj16NDo6eu7cufjjeXl5AwcOPHXqFL7+22+\/nT9\/vlqtxt8YHh6+dOlSWoaamprXX3+d2f7BgwfDw8OnTJlSWVmJj9TV1SUmJn7xxRcWOhIeHt6jR4+MjAyzF9TV1V26dAl7Kb3++us1NTUURT1+\/Hj16tXh4eHR0dEzZ85MTU39\/vvvY2Njme2kpKSMHDkyKyuLoqjCwsLhw4d36dIFiyqRSEaMGDFr1izc2unTpyMiIj799FOKom7cuLF9+\/bo6Ojo6Oj4+PjVq1f36NFj\/Pjx5eXlFn6OCxcumPairq7u9OnT8+fPx6dmzpz5j3\/8IyIiYsOGDdXV1XPnzt2+fbtWqzUYDLt37w4PD09ISKipqXn27Nnu3bsjIiI6d+48duzYlJSUS5cuDR48OCIigr7PxcXFU6dOXbp0aV1dHe7OyJEjjX4doL2h1Wo\/\/vjjiIiI8PDwiIiIhIQE\/PBjSJK8c+fOwoULw8PDX3755TfffDM1NfXRo0f4yZk9e\/b777\/\/6NGj9PT0+Pj46OjoK1eu4A\/eu3fvlVde2b17t8FgoCgqKysrPj7+lVdeuXfvnjUXFBcXx8fHG70a9PsyefLk33\/\/\/cKFC6+88grzS5mQJIlf\/969ez969MjKu2E0XjU49GE5IyIiYmNj16xZ8\/XXX8fHx4eHh48cOVIikVAWBw2z32iWpUuX4sEQjwDh4eHMO0mfbVDgurq633\/\/fcKECeHh4bGxsatXr87MzFy5ciVzkKTvMz5iOpBa04hWq12xYsWiRYvoXkdHR48ePVoqlVq+J9YPpPQ8wpQcj9jh4eELFy7UarX43qakpOBbN23atLi4OLFYTN+38PBw5ixj+lvcu3dv+PDhv\/32G25h1qxZERERe\/fuVSgUJ0+exNNojx495s+fn5CQEBERcejQIWvusAMCdj5nxtvbe+rUqQihhw8fpqenI4Qoijpz5kz\/\/v179uxpev3169d37NgxcODA2NhYhBBBEJMmTRo4cOD169fxi5qfny+Xy2UyGUVRCKHhw4d7enpav\/swbNgwkUj0+PHj+\/fv4yO5ubmFhYWN8qc2wtXVddiwYUZO3127dn311VfxH1988UX\/\/v2nTJkSHx9fU1OTkZGBECosLNy4ceP48eOjo6MRQiEhIf369dNqtfv376+trc3Ozi4oKKDjGcPCwoRCYXp6ulKpHDRo0Ny5cwMDA3U63eLFi9euXZuWlnbq1Kn6AootSz5x4sSZM2cihNzd3Tdv3vzpp59mZGSsWLHiq6++KigomDlzJpfLJQhiyJAh3t7e169fT01NDQ0NjYuLEwqFvr6+ycnJY8eOxd2nKOrGjRsIIYqi9uzZk5eXl5iYiH2fRSKRqbM20N7gcrlr16799NNPfXx8KIq6du3apEmT9u7dix9yDofTp08f\/Jx06tRp165d\/fv379at21tvvYUQUqlU69ev79atW69evSZOnEiSJE4CpVAoVq5c6eLiMn78eBwzER0dnZSUVFZWtnLlSoVC0eAFFgQOCwvbt2\/fgAEDRo4cOWHCBJIkzZqr1Wp1eXk5QkgoFPr5+RmdZeauioyMXL58eU5OjmkjDQ59+DIOh7Nhw4Z\/\/etfiYmJR44ciYyMzMvL+\/777xFCFgaNxvxKz3F3d1++fLmvr29ZWdmyZcuM4jkaFJjP5w8YMKBLly4IoTfffHPNmjVdunR55513goKCcnNzzablMh1IXV1dG2zk\/PnzP\/30E\/YKRQgNGDAgJCQkOzv79OnTlu9JkwdSkiRTU1P\/53\/+p6CgICYm5qOPPtJqtTdv3kQI4Z0Qd3f38PDwoqKi3NxcK+92TU3N+vXru3fvPnDgQNzCqFGjKIo6cuQISZJTp04dPXo0QigiImLLli1ff\/11RkbG3LlzG3uHHQRHic0BWohhw4bt27dPKpUeP3580KBBcrn82rVrq1evNhuWdenSJa1WywwNc3V1nTJlym+\/\/ZaamlpRUREaGurv779z506E0FtvvRUUFLRt2zbrhQkJCZkyZUpycvLhw4f79evn6up648aN8PDwsLAwG3TVHG5ubi4uLgghDoeDAyawW\/Tdu3elUumRI0dOnjyJr8THcQxjfHz8mTNnPD09vb299Xp9YWEhSZI6nY5i+LgIhUIclYzbbyb4xiKEBAJBVVXV1atXFQrFG2+8gadJg8GAjQ25ubkjR47EH+HxeAKBgBaG7oJcLr98+XJERERoaCjdvuNE4QF2hM1mT5o0adSoUZ9++umBAwe0Wu3mzZufPn26du1apts+\/dagP4P6mUfww4Y3Z7OysvLy8vr06ePj40N\/fOjQoUFBQXl5eThqxPIFeNFlFoFAQAdsYjHMxjTQroo6nc7ULxDnriovLz958mSXLl0++ugjpiQ0DQ59+CCfz6cHK5FINH369K1bt2L3aGsGjUbRvXv3devW\/b\/\/9\/\/y8vI2b968Y8eORglMd9PT0xMPI3w+n8Ph1NbWNsF70mwjOp3u559\/VqlUixcvxnkVKIrCejzWt2w7kKanp48dO5YgCC6X261bt3fffXf06NH4Cdm5c+fTp0+7d++OEKqoqFAoFBRFWZ9uJjMz88mTJ\/n5+cOHD8dH8C0qLy8vLS2ls5hFRkZilZQeeC3cHCu\/uvWBmcDJ6dix4\/Tp03ft2nX16tWMjIxHjx55eXnh2A4jzEb2IYTCw8Nx\/K9UKu3evfsHH3ywcePGbdu2HT169KOPPhozZgx+3K2BIIgJEyYcPXo0NTX18ePH0dHRFy5cmDt3Lo\/Ha1YnGw\/OX7Nx40ZahTKiW7duFRUV27dvJwjipZdeas1ANqVSWVpa2rt377179zYhsFoikRQXFwcFBZlNEwMArq6uK1euHD58+PLlyyUSyYkTJ1599dWmZfN5+PChqZnfx8enY8eOMpkMOzZZvsCCzmclPB6vY8eOCKGKiori4mLmUoemc+fOCCEvLy+zioU1Q5\/ZRC19+vTh8\/kymayurk4oFNp80BgzZkxhYeGWLVtSUlJiY2NpVckagc2qtrZFrVaXlpYGBwd\/\/\/33AQEBphew2Wwb3hMLQ6K3t7eHh8etW7eOHz8+btw4T0\/PRrVcWlqqVqv\/\/ve\/v\/vuu00Wr60Ae7vOz9ixY319fWtraw8dOnTq1KnJkye7u7ubXkYQBF4yYt9YGhaLhU+x2WyCIBISEr755pvY2NjCwsKFCxeuWrWqUZFl0dHR48ePr62tPXPmTGZmplKptOB23XLgvZJnz56ZPavX6w8ePDhp0qRhw4YtXbpUJBK1pmyVlZV1dXXFxcU4zKWxVFVVqdVqlUrlIFlVAUcgLS3NqBzOgAEDtm3bJhQKSZL87bffmtYsnsIrKyuNYiex1YfL5TZ4QdO+14ihQ4dyuVy1Wo3dGxqLNUOf2Q\/y+XwulysQCDgcTksMGnQ8B0VRO3bsoH\/BJgtsW1QqlUKhqK2tZaZBYdJqA6lEInnjjTfOnDmzYcOGkSNHNnbvBRcOqG86cDJA53N+IiMjBw0ahBA6c+ZMaWlpfc5zAoEgMjISIZSVlcUMnlKr1SRJhoaGikQimUwmlUr79u178uTJHTt2CIXC77777urVq9YLQxDExIkThULhxYsXDx061KVLl+bU\/7h27dqSJUuakNkLr\/uvXbtmpFfdvn07LS3tl19+2bhx4+TJk+2ij\/r7+3t5eUkkksePHzOP19bWHjt2rMG4Nk9PTz6fL5VKS0pKWlJMoC1RW1v7xRdfGBViiYmJwa98k+nSpQuXy8WGJfqgXq9XqVR8Pr9Hjx4NXtCcb6fp3bs33tc7c+aM2RT0lrFm6DP7QXxBRESEh4dHCw0aXC534cKF0dHRWq2W3tpussC2xc3NTSQSVVRU3Llzh3lcp9MdP35coVC0zkBaW1uLLdbvvfeeUfZmK4mIiCAI4t69e0YOpjk5ORbiptsooPM5PxwOJyEhAZvEp0+fjvdBzIKzND98+JC5cfDkyRO1Wj1kyBBPT89Hjx7t27ePoig2mz1lypRVq1ZRFNXY5VHPnj2HDRtWVFSUkpIyceLEJrua1dTU7Nu3r0+fPk1o4eWXXxYKhampqXTSCoTQw4cPP\/\/88+Dg4N9++40kSTphMh5JmyYkxmg5bhlvb+\/u3buTJPmf\/\/yHnqRJkty1a1d1dXWDu72RkZFhYWGlpaWnT5+mu9achLeAE+Dn5\/f06dPvv\/+e6UpVV1dXWVlJEAReEzaBnj17du\/evaamhi7kiBCSy+USiaRr164xMTENXtDkHjFxd3dftWqVr69vQUHBjh07TNdFDT7\/DQ59Zj\/15MkTg8Ewa9YsDodj80GDJjg4ePPmzb6+vs0X2LYIBALsJvTNN9\/QSR9x6MODBw+8vb1b7p4wEYvFWVlZLBYLTwRm3Tot07lz5+Dg4JycnOPHj9PbI0VFRevXr2\/lTZ5WAHQ+J4SiqLy8vKKiInrs69atW+\/evX19fZleOxKJBC8c6ZK4vXv3XrRokUql2rlzJx3T8M033wwZMiQpKQlfc+7cOWaFb19fX1xDrHPnznip9Mcff2zevPnWrVsIofqKS06bNo3L5UZFRZkNH2ZCp5syaqqwsHDp0qV\/\/PEHNhXgocRC9UyjFnr06DFhwgStVrtkyZJFixYdP3585cqVb7311uuvvy4SibDvztGjR8+ePXvu3Ll\/\/etfJEmKxeKbN2\/iADGzIlkAq24kSdY3GDGb4nA4b7\/9tq+v740bN6ZMmbJ79+5Dhw5Nnjw5MzOzvloCzCnNx8dnwYIFbDZ7z549W7dulUqlZ86cOXjwIEII56xp\/eT+gN3p0KGDUCjcsWPHnj17sG1bpVIdOXLk2bNns2bNGjNmjOWP1\/eou7u7r1692t\/f\/\/DhwzgYnyTJgwcPslis1atXu7u7N3gBthVhpTA1NXXt2rX0LjDzSxtU2l5++eX\/\/ve\/PXv2\/OGHH+bOnZuWlkZP3k+ePDl16hRCiFlhwqjBBoc+vGdKkmRlZSX+yN27dz\/\/\/PN33nkHZ1ZvcNBosAu1tbVFRUVmS\/q+\/PLL69atY25ZWjNWG6HT6Yx+R1MNrMGB1KiRGTNm4ODlGTNmbNmy5dixY3Pnzj1y5MiCBQs4HI6tBlJ8gYWH0M3NTSqV7tq16+HDh+vXr8e+Crdu3Tpz5kx1dTXe1bly5cqTJ08+\/vjjgoICo9lKKpXiwu7bt29PTEw8duzYli1bJk+eHBcXh+3HtBiWI3JM77ADwl6zZo29ZQBsSVpa2meffXb69GmxWCyRSPz8\/EQiEZfLZbPZer1+1qxZLBaroqLixIkT2G6EEMrIyNBqtR07dnR3d+\/du\/eAAQOuXbv25Zdf3r9\/\/8SJE3\/729+WL1+OI5WKioqys7MvX75cXl5+6dKlGzdurF27tlevXgghf3\/\/7Ozse\/fuXbp0ac6cOUFBQd988825c+f0er1cLvf29g4KCqIHXG9v7xs3bvTt23fcuHH1dUQmk3322WdHjhzRarVarfbUqVPHjh37+uuvDxw4sGvXrj179uTn53ft2hWn39u\/f39RUZFCoeByuT4+Pvn5+Z9\/\/nlRUVFlZaW7u3tgYOD58+e\/++47lUpVVlYWEhISGho6dOhQPz+\/\/Pz8u3fv3rx508fHZ8eOHThTPx7FHj9+fP36dQ6Hs3r1aoVC8eDBg5qamr59+3711Ve3bt3SarUKhcLNzY3ZL1NycnK+++67r7\/+WqVS6XS6hw8fcjgcX19fd3d3nU537dq1nTt3lpSUKBQKnU6HW0MIBQYGjho1SiqV5uTk\/PbbbwUFBXPmzPnoo48EAkFOTk5ycvKjR49UKpXBYIiIiLhz587evXsrKyurqqq8vb3DwsK6d+8eFRWVmZl58eLFb7\/9FiHUq1ev2traDz74YMyYMWa9OQHnBqfyEYlEt27d2r1797fffvv5559LJJKPP\/743Xff5XK5Op3u5s2bX3zxRVFRUVVVlZubW2BgYEZGxoEDB8RiMX6zQkJC7t27t3\/\/\/tLS0traWm9v7w4dOoSFhY0bN06hUHz22We4qqmfn9\/WrVvpWtuBgYEWLnBxcXF3d79y5crNmzc1Gs0\/\/\/nPJ0+e4JcXf2lAQMDvv\/++f\/\/+ysrKkpISb2\/viIgIs2+ct7f3jBkz4uLiioqKvv766y1btvz3v\/\/973\/\/e+nSpVdffXXTpk1z5szhcDgVFRU\/\/fTTgQMHqqurS0pK+Hx+QEBAg0OfQCAYOHBgYWHh3r17Dx48eOjQoQcPHqxfvx7nvUcWB40xY8b8+uuvpt9IS46Hgg0bNvz++++5ubm5ublhYWE4kJ+mc+fOPB6PxWLhfVKCICwIrFKpfvjhhyNHjtAjHpfL\/c9\/\/nP9+nWNRqPVakUiUXp6+p49e0pKSkpKSnCp34yMDOZAKhQKr169aqERnHJh7Nix1dXVOTk5N27cePToUXx8\/NatW7HwzR9I09LSPv\/8c5yXEacJEwgEwcHBzPLrHh4e3t7ed+\/evXfvXnp6+tSpU6dNm3bx4sXc3NzBgwf37NkzODj47t276enpd+7c+cc\/\/hETE2M0W7366qt9+vSJjo7Oy8vLyMi4evUqRVH\/+7\/\/O3HiRLVafebMmX379lVXV0ulUg6H4+Hh4evr2+AdDg8PNzLNOghEkyPJAaDJiMXit99+e\/PmzX379rW3LAAAAADQLoC9XcAOXLlyxcvLy1bePAAAAAAANAjk5wNaierq6tu3b3fo0EGr1X7++eerVq2CTUbA6aEoKi0tbcOGDYsWLTJKBqlQKNatWyeRSPz9\/YuLi1esWIFdC6w5CwAA0ARA5wNaie+\/\/37Dhg3471dffbU59dYAoE2QnZ29ffv2a9euaTQao1NSqRRXsjl06JBQKNy3b9+8efN27dqF9ULLZwEAAJoG7O0CrcTYsWNfe+218PDwd955Jzk5uQkVJgCgbSESib788svx48cbHacoat++fWKxOCkpyd3dHSet7NChQ3JyckVFheWzdukIAADOAdj5gFYiODh4z5499pYCAFoPo7qcNHK5\/OrVqwEBAXRwq7+\/\/0svvXThwoWMjIzo6GgLZ4cMGdJK0gMA4HSAnQ8AANuQKVNuPVuw\/Fj28mPZmTKlvcVxXDIzM8VisUgk8vDwwEc4HE5MTAxJkleuXLF81m5CAwDQ9gGdDwAAG5ApU25LKciSK8tqtWW12m0pBaD21UdRURFFUcwcYwghXEWgsLCwsLDQwllT10AAAAArgb1dYyQSSRMqNgJAO+fHXF5lxQs1rw6mlE5+iW\/bbwkJCQkJCbFtm60PLpzg4+NDl6VCCOEw9rq6uqqqKgtnSZLk8Xj1tQzDFwA4LI4wfIHO9wISiWTZsmW4bhgAANbDHfgPoyMZ6upjG\/bb9lv69++\/bds2u4+bLUF9zn\/WnMXA8AUAjowjDF+g872ARCK5devWtm3bnK+yMpNbt27t3LkTuuk0OEJPf8zlZctfsPP5Cl3mLbNlbhHcTYlE0tZ1Pmy0Ky8vV6vVdAC7XC5HCLm5uXl6elo4a6HQHwxfzkQ76SZqNz11kOELdD4ziESi9pD+FLrpZNi3p16dlNtSCuh\/fYUu8+JFMUENW6faIZ06deJyuUbl2HU6HUKoY9xLbnkAACAASURBVMeOuJ5sfWctbOxi2skDD910MtpPT+0LxHC0RwIDAxMTEwMDA+0tSMvSTrqJHKOnMUGCZePCuwQKfIUuvkKXSb0CQOGrj8jIyODgYKlUWl1djY9QFJWfn08QxODBgy2ftZ\/UjoIjPO2tQDvpJmpPPXUEwM7XHgkMDExISHD6d6yddBM5TE9jggQx48PtK0ObIDAwcNiwYYcPH87JyQkODkYIlZaWPn78OCoqqmfPnn5+fhbO2lt2++MgT3tL0066idpTTx0BsPMBAAC0FBRFGe3SIoQIgkhKSgoNDT1+\/DhJkhRFnTt3TiwWL1682N\/f3\/JZu\/QCAADnAOx8AAAALUJOTk5KSsqvv\/6KENq3b5\/BYBg0aBAOyxCJRAcOHFi3bt3MmTP9\/f0lEklycvLQoUPxBy2fBQAAaBpOovPV1NR88MEHAQEB27dvpw8qFIp169ZJJBJ\/f\/\/i4uIVK1aAiygAAK1GVFTU4sWLFy9ebPZsSEjI3r176\/us5bMAAABNwEn2do8ePXrjxg3mEalU+sYbb1RVVR06dAiXOZ83b97FixftJSEAAAAAAIAdcQad7+HDh\/\/5z3+YRyiK2rdvn1gsTkpKcnd3Jwhi4sSJHTp0SE5OrqiosJecAAAALU2WrA6qHgMAYJY2r\/OpVKo9e\/bMmDGDTl6KEJLL5VevXg0ICIiKisJH\/P39X3rppcePH2dkZNhJUgAAgJaF8gg5nceFqscAAJilzet8J0+eFAqFw4YNYx7MzMwUi8UikcjDwwMf4XA4MTExJEleuXLFDlICAAC0POyQ\/kZHbmTDzgYAAM9p2zEcBQUFZ8+e3bp1q9GObVFREUVRLNYLGi2Hw0EIFRYWajQay7nsccHKwMBAZ80YpFarNRqNSqWytyAtSzvpJmoHPZXL5XK5XCqV2lsQR4ft2dHoSJa8zi6SAADggLRhnY8kyR07dvztb38LCQkx0vlqamoQQj4+Pnw+nz6Ia1zW1dWRJGlZ59u5cydCKDExMSEhoUVEtzcajUahUCCEGqzj1KZpJ91E7aCnhw4dOnjwoL2laAPoqwoR6mVvKQAAcFDasM53\/vx5Lpc7ceJEK68XCKytBIWLPTuxnQ8bhAIDA5k6sfPRTrqJ2kFPExMTR48ejYuU21sWh0YvuYXQJPpfXPXYjvIAAOBQtFWdTyKRfPvtt+vXr+dyuaZnsUmvvLxcrVbTsR1yuRwh5ObmZvYjTNpDsWcej8fn851VRaBpJ91Ezt7TsLCwsLAwe0vRBiCqJZMiyWIXQWktiRCCqscAADBpkzqfTqfbs2ePUCjMycnJyclBCBUWFpIkKZFIzp49Gxwc3KlTJy6Xa1TySKfTIYQ6duzorPtfAAAAXYLcEgdA1WMAAMzQJnU+tVqdn5+fmpp6+fJl5vHbt2\/fvn172rRpS5cuDQ4Olkql1dXV2M5HUVR+fj5BEIMHD7aT1AAAIIRQpkx5Or0EG6LmxYvAEAUAANA6tEmdTygUHjlyhHnkwYMHc+bMGTVqFK69RlHUsGHDDh8+nJOTExwcjBAqLS19\/PhxVFRUz5497SM0AAAIZcqU21IK6H+3pRQsGxdujdqXKVP+mMtj95q3\/z7h1UkJmiIAAEBjafP5+cxCEERSUlJoaOjx48dJkqQo6ty5c2KxePHixf7+\/vaWDgDaL6fTS4yOWJNADmuK2fJaFt8DUg0DAAA0jTZp57MGkUh04MCBdevWzZw509\/fXyKRJCcnDx061N5yAUC7JkturKtZk0DOrKYIpj4AAIBG4SQ6X2xs7B9\/\/GF0MCQkZO\/evXaRBwAAs3QJFJiqfRbAzn9n04sRQm4sPX0cUg0DAAA0Fufc2wUAwDGZ1DuA+a\/lBHJ4SzdLruSwCVJnKFMSiOOcyWgAAABaAdD5AABoPWKCBMvGhXcJFPgKXXyFLpYTyNFbuv6ez\/MrsXjuCFINAwAANAkn2dsFAKCtEBMkiBlvVQI5ehdYwOeEBriJZRVIr21QUwQAAADMAnY+AAAclC6Bfyl2Aj4nyIujqyyc9zIVF+1lR6kAAADaKKDzAQDgoBg5\/yFNjS7vFzvJ0gYoJV1Z3abvv08sP5YNuWwAADAF9nYBwPlpo6UvsPMfLXm3UNa9aom9hXJQMmXKA7eq2Z4dy2q1eq7W+mTXAAC0H0DnAwAnp8mlLxwBpvNfamp5sn2lcWAghSEAAA0COh8AODm21QZa1GRIN67U6HwFLmqdoSW+xSlpWrJrAADaFeDPBwBOjg21ATphXlmt1uY10OjGxaV19\/IqL2aUiEvroNKalTDjXQAAAMwCOh8AOAP5ZeT28+Llx7JN\/fdtqA00rVpuYxtXVGnwH1VK0ubf4qww412Ual1RmUqp0UEwBwAATEDnA4A2T34p+dXvlXklKrPmNytLX2TKlFvPFpjVGmladAORblyleV5jre7PP2CbskFiggRv9\/fQVxWSekpWrnbjc9SkAaykAAAwAX8+AGjz\/GjRY88o+tVsQmNmnIdSrfvgwMOYEHcBj2PkS9e0arn4ewdFeWXLlBYcAenGXXlsWu0DrMePqzI8PsHt1adzWHd8RKnWKao063\/IFfm4glskAABg5wOANk+2vNboiJFhLCZIsHx8+NZZ0VtnRZtNaEzvqyrVOnFJnUqjz5crm2wyxDCd\/8SldVt\/zE1\/WmXBEZBuHFda43JYQT78Br8FMMbz+b2if0pJqQoMfgAAIND5AMAJiA4UNrMF2npH+9LR+6pMX7qmVculm6X985A5Fz268VA\/t16RXgO7+IT6uUGltcbiy1XjP+ifkgbcIgGgnQN7uwDQ5pnwsu+DZ2X0v00wjNH7qqabqqYmw8ZWy6WbrWM0btZFz\/rGgfoYHMr+rRyhP+85bS5F4BYJAO0e0PkAwP40M+ldVAA\/aaDX7SJ2hUqP6vHYs8yk3gHYnw\/70jEVhSbDdP4DF71Wo0uQW\/8B4afTS4rKVHUavZ8nT8CHcR4AAIRA5wMAu1NfnYxGKYIRvtzB3YP4\/CYqanScB5\/LevismlYUrDEZ1icnrUcihPw9ebJyNa1Hgotei4LNpcz7j+CeAwAAOh8A2J36kt61csE0el+VqcM1aDK0UNiNGS\/sK3SZ1jfwqUJlZbNAY8mUKX\/M5bF7zdt\/n\/DqpIwJElgTr01\/ti2WYwYAoLGAzgcAdsZs0ruyWtLoYKuVT22UU53lwm7gn9c6YM27sqKWxffAIbpY88b3H6t0p++VnL5XYqrStelyzAAANArQ+QDAzphNetdWyqealbOxdiOwMzUTC5q3BZUO3\/bLj0rrNPogHz7t9tdqqwsAAFoZ0PkAwM6Y9bs6nV7SqOzHZmkFXcpUYZVXqq20G2HxnpWpHj6rpnUOsDM1AQsrBFN18PvbxTwOQd92nEBHXFIXGuCGfwLHXF0AANB8ID8fANgZs0nvGpX92CzMlMgtl5LXVE4ux3hUMZsWjhYvU1JD6gzikjqlWmfhesACFkoqM9VBpVqXL6v94Xfp2fTijKdV+LbTZ5nZEwEAcErAzgcALUKjbGymfm\/WO+DXh2VPO1uZAE3lPHBNYnSNWbsRLR6dw6VKSYKdqWlYCNGlDbG4LIdGozdQFKkz1Kl0fB6bxSK4HBapMxgMlKJCXafRc9jEm4OC7dMNAABamLat86Wlpf373\/9+9OgRSZI9e\/b88MMP+\/btS59VKBTr1q2TSCT+\/v7FxcUrVqwYMGCAHaUF2g828YtvZgCEhf0+27rtG8l5M6fCml1p09R9dZDAr6lgzXvHf2UGdbVR5RJaHcRlOQwUxXNhI4TYLEKnM7i4sBFCHXz4YpmSxSYQQl5Cl8M3i4K9eLC9DgDORxve27148eJ7773XtWvXTz75pEuXLmlpae+\/\/\/79+\/fxWalU+sYbb1RVVR06dOjLL78cP378vHnzLl68aF+ZgXaCWRtbpky59WzB8mPZy49lt1zlU\/pbispU9G6pNeJZ2WyDwlu5K01vR+Lqug1eD1gmJkgwr7+7\/t7+eS9TzJLKtOeATk9xOSwPoQuLRSCEuFyW3kDha6qVpFDAjQwWdg4Wegm4CLbXAcBJaas6X01Nzf79+9evX\/+vf\/1r1qxZx48fnz59ellZ2eHDhymKoihq3759YrE4KSnJ3d2dIIiJEyd26NAhOTm5ogLGMqDFMTV0Xc0sbwnvOqyKfXyqYNul8pwSNdOHz1PAZTrJYV0KX382vTi3qJapEVreTm2Ua6CVNXlp1VDA54QGuIn8XLt38oDqui0Bdg\/1FHARQlpSbzBQCCEWixC4cvFt1+kpo3IdsL0OAE5JW93bffr0aWho6MiRI\/G\/XC538uTJp0+flkqlSqWypqbm6tWrAQEBUVFR+AJ\/f\/+XXnrpwoULGRkZQ4YMsZ\/gQLvANJpVUaUJ9nVlHml+Rgx6i9ag12s0+h3nn3kJ\/7KZYV2Kz2X7Cl0QQpN6BaA\/8zxz2IRKo2eGalrGsmugKdbsShtlbJ7UK4BpnQJsCH5O3Hjs0ioNQRAURbHZhK+7i8jX9fUBwXHRXlvPFjQ\/SBwAAMenrep8MTExq1at4nK59BFPT08+n+\/j48Pn89PS0sRicd++fT08PPBZDocTExOTkpJy5coV0PmAlsbUp950m7X5phRTVSxTUsPULAV8jq\/QZeusaPzv1rN\/VULDAZs4VLNKSfK5rOXHsusL5rBJEj5TIGNz64CfE7wGUFRpdHoqxM\/1vRGdaCUbqrQBQDuhre7tcrlcgeCFOaaqqkqtVvfr14\/D4RQVFVEUxWK90DsOh4MQKiws1Gg0rSor0P4w3d\/sHeZJn1WqdU+LlXfzKprp2NdY2wx9PZ7+XXnsWrVOVq5243PUpMHCpq1pKhCchK+lE8EANoH5u4d1EHQOFop8XM36\/NGPK0KoFXxPAQBoZdqqnc+UO3fudOzYccSIEQihmpoahBC2+dEXuLu7I4Tq6upIkuTxePW1gxC6desWQigwMDAwMLBlhbYTarVao9GoVCp7C9Ky2LebYd7sv48Iov8Vcj2eSKsRQnVag7ikjssmAn34iirVljO5S8Z0igrg199SvYT7uuSVqBBChj\/p6OtC6v+KfvVyY7\/Rz1etVhtdjxBy5RKhfvyiCk2wNw8hZPjzU5cflYR5B6EXea3bc+HpZiv1lEH\/Qpit2Q\/aCrlcLpfLpVJpC7Xv3Jgt9GIEs0rbd6lFkCUbAJwSJ9H5JBLJL7\/8snTpUpGo3i0JI7ugBXbu3IkQSkxMTEhIsI18DoZGo1EoFAghy7pvW8ehuumJ0Jzerr9m1d1WqFgE5eHK4iCdRqNDCJ27Kxa+7E5fmV9G\/ppVV6nWI4Sm93SP8OXW1+bAEPS4UIMQMhgMWq3Wy5U9o6cnQoj++OBQF09ULZNVG12P8XJju3IMRmbvB8\/KZZH1Ck83e\/IP441psx+0FYcOHTp48GBLte7sWLl1S7uHPi1W4nTNtLsnVGMDAOfAGXQ+kiS\/+OKLKVOmjBkzBh\/BJr3y8nK1Wi0UCvFBuVyOEHJzc2N6AZpl27ZtIpHIie182PQVGBjItIM6H47WzaAgNLg7eu9QltHxYjU3KOi5hSxTpvw2XYIQgd\/Nb9NVi0f51jfdBgWhgICAn+6XySuVGjV7xsCOg6O8EEKDu9crAL6+VKlFCE3uFXAjuzJbXsu8xtXNhRbGVHianEqplR+0CYmJiaNHj7516xZejwGNwsr83jbPkg1llAHA0WjzOh9FUQcOHEAIvf322wRB4IOdOnXicrkGg4F5pU6nQwh17NixQauPSCRy+uzNPB6Pz+c7iDLUcjhgN7uKPIw22tgsNi3hL49lLDabefauWPVyuG99rcWG8mNDvdRqtUwmCwryarCn+Hr63wBPvqkFyJrbNbVvYNM+2DTCwsLCwsJaqPH2gDXhMrbNkm3bvN8AANiEthrDQXP+\/Pnbt29\/9NFHTOtdZGRkcHCwVCqtrn6+q0VRVH5+PkEQgwcPtpOkAIDQiymLlWpdUZlKqdHRnvIWime0BFbm0rPhBwFHwGyGbdMs2VpS\/7RY+bRYqdToGhvJ0YS83wAAtDRt28536dKlH3\/8cdu2bXgzFyEkkUiOHTv2j3\/8Y9iwYYcPH87JyQkODkYIlZaWPn78OCoqqmfPnnYVGWjv0BttDyU1snK1nydPTRrUpBYbQqxxt7e5PBYsQBa25yDTim2hKOry5cuvvPIKnWGqmdT329VngaPd\/nBYd0mlRksa6tQ6hNDDZ9Xv\/OfBv+d0eyXcWtmsWb3A5i8AtDJt2M53\/\/79FStWGAyGbdu2rVy5cuXKlR999NHcuXOjo6PZbHZSUlJoaOjx48dJkqQo6ty5c2KxePHixf7+\/vYWHGjvxAQJlo8P7x7iTpe6wtzIrrCycFnr0KjyG0Bj0el0ixcvjviTyMjIH3\/80c3NDZ9VKBSLFi2aOnXqggULJk+enJqa2qjGLfx29VngmLbbUD+3rh3dQ\/xdCYIgCILUGUidYdX3WdY\/AKb5fayXEACAFqKt2vkKCgqWLl2qUCiMSuhGR0djVzyRSHTgwIF169bNnDnT399fIpEkJycPHTrUPuICgAlmDSFJQ0JM3e3tZQ5pbPkNoFHk5eU9ePBg6tSp2MOYw+G8\/vrrOI2oVCp96623goKCDh06JBQK9+3bN2\/evF27dtGVhxrEwm\/HfPCUap2iSvO0WJklr8OPFm27TfrqoaLqhZjuOo3e+gegwWBheLoAoPVpqzpfeHj4r7\/+avmakJCQvXv3to48ANBY6tvGNdozNbsThxBiaoFh3mzTdppPKzsXtisoivrpp5+GDh26atUqOviMPoXLhX\/yySfYa2XixInfffddcnJynz59vL29rWnfwm9HP3hKtQ6XY+FyWNjSxgyz6BIoeCKurq+RBmkwWBieLgBofdqqzgcAbR0rs6aZmkP2\/yYtq9XS\/25LKVg0PMgT2Z7Wdy5sP0gkkp9++ql37943btzo27cvM5mAXC5vfrlwC78d\/eBhMx6XwwryeR5wjTd5saImr1QzP8W8zEose3zC0wUArU8b9ucDgDaNlaGvpvPig2dVRkeut0xEpEM5FzoZly9ffvbs2alTpxISErp377527dra2uf5DjMzM8VisUgkMioXTpLklStXrGzfwm9HP3g6PcXlsPw8eTgJH0LoamY57WPH5bBEfq5sNsHlsPBloX5udCNmI38bBTxdAND6gJ0PAOyGNaGvpuYQ06xpeQo1ira9I5SVuXyBJjBlypQRI0bcunXr4MGDDx48OHjwYH5+fnJyslAobLBcuJWlIxcND\/oxvaRSpUcIvdbVPcybTVfhw4UBtST5vHbfn2X0iiuf1+LDCHmsVyLcvVzZzEYeiCv\/e7vk6uMyhFCQD9\/NhdW0+oFh3mwLEloASkc6GU7fU4cqHQk6HwA4NKZbwB6RXtUqXet8OyRkaSE8PDw8PDymTZs2derUn3766ZNPPrl+\/frZs2dnzZrVzHLhzNKRCb3pFtQymczoSmtq8WnY7ITBPnQjNx6Kv\/q9sqiC1GoNCKFn8tpAb66bC+vcXXFJR76VNQNpPBGyLKFZLNdUtL50oYPjUKUjWxQn7il+Gq\/fvi+TSHR5vxANf6LFAZ0PABwaU2ObnzvXSAt8o58vQsbu9kCbgCCIiRMnkiS5bNmya9euTZ8+3exl1pcLt750ZBNq8R3+Q8zj8TQ6kvjTDKnSsbzdeX\/IDU8UKitrBjYTCzUVG1W60MFxtNKRLYez9pR+GkM6d\/PvGFnVtWfeT9vsLRTofED7oPnpTiy30KLpVEyNbSZbrnyZDHS+NszAgQNDQ0NxifBmlgtvVOnIxtbiKyjTsthsNz6Hrsmr1hpYbHZ5pSrY15XZsuWagc2kvpqKjS1d6OA4YOnIFsIpe0o\/ja5ubq5ubgghln83ewsFOh\/QDmh+6U\/LLbR+aVEjLdAaLyjALDk5OUKhkGnKsgvu7u5BQUEcDocgiGaWC28ODXpwYu9Sf0+euKTOYKBI0qDR6J8WKz0ExpqoXRKvQP4XwHEwfRpZHiF2keQFGewtAAC0OM0v\/Wm5BSgt2nb59ddfL1y4YG8pkF6vV6lUkZGRAoHAvuXCcZGYrbOit86Kjov2MjqLg20FfE4HHz5JGlhswpXP8RK6VCtJpbqVfEwt0GDxDwBoNRzzaQQ7H+D8NGH1b7RXa7l0geWztusH1CdtET777LOIiIi4uDg7ypCZmSmTyT755BOEUGBgoAOWC6efPVJn8HV3KSpTCQVcP08eLh5I6gzPiutcuCyEUJAPn5nVpTWxMuclALQCRk8j0tTo8n5ByNpSOi1ES9n5lErl5s2bcTAOANiXxq63TCuB0qdw6QKVRq\/TU3SRULp9s2dt1QuoT9pCVFdXJyUlbdy4sdWyRaSmpsbExLzyyisXL16kKKqgoGDNmjVJSUm9e\/dGCBEE4WjlwpnPHpfDqlbpPAVculq0Uq0rrdKwWQSHTSCEZOXqLoFu9S1Imp\/YzwJW5rwEgFbA6GkcFMoiqiX2FqrF7HwURWVkZIwYMWL27NmJiYkiESy2ALvR2NW\/6V6tr9AFl74wW7rAysIGqHnGOahP2kL83\/\/9X2xs7NKlSydMmLBhw4b6AiBs6PnXuXPn0aNH\/\/zzz++8805oaGh0dPTatWv79u1LF2FztHLhps8eqafov\/Fjz2YTYR0sPY2ZMuWRm7Krj0sRQkE+fAGf0xKer5BdCHAcmE9jamp5sn2lQQi16N5uTEzMypUrf\/755+nTpwsEgvfee2\/06NE4JA0AWpPG5hY2WxIKt5BbVGtUuiBLXpc0JKS+s1czy2\/mVtKNNGeSA\/\/0lmDEiBFYkzty5Mjx48cXLFgwderUpUuX0jUwaH7++eeYmBib6Hx+fn44i54FHKpcePrTKkWVRqen0J\/qWqAXT00+jzJRafRGldlMn0xsKXxarCR1BoSQuKQuNMBNwOfAugUAWpOW0vmEQuHq1asRQt27d1+yZMnTp0+\/+eabTZs2vfTSSwkJCUOGDGkw4wAA2JBGrf7NVgKlW6BP0a57y49lz4sXLX\/xLEZRpTHKYdHkSQ7qk7YEdE1bNps9a9asuLi4FStWTJgwYf369V27dqUvk0qlp06dWrFihZ3EtCeZMqWiSkMnZ8Hqmq\/QbdEo0en0koeSGp3eYDBQsnI1VgfpT9GrrEFRXt\/fkklKVdW1Wp4Lm8UiEEJVSlLA58C6BQBak9aI4SAIIjw8fNWqVWPHjl23bt2CBQsEAsGYMWPmz58fFRVFb2cAgL0wio1g7gUr1boqJcnnsrBiR5\/CrnvYvIG965aNCzfdRDYNZmzyJAf+6a2ASCTatGnT+++\/\/\/bbb9tbFkfhdHoJTs5CH2GziOdeCr0DsuTKiCChuKSO1BmwOhjq5zYoyov5Bl1\/XGowUCwWwSIItUbP57FZLMK0hKARELEEADanpWI4KIqqra2lKAohRJLkL7\/8Mnbs2FmzZj169Khjx44ffvhhp06dEhISpkyZkpaW1kIyAIA1mI3YwL63pM4gK1e78Tlq0mB0qkpJGm3jYgOekQt57zBPW8kJ\/uktjV6v\/+GHH8aNG\/fgwQN7y+JAZMmVAj4nNMDNlcfmclhcDsuNx8bPHvbzY55ls4hJvQKyGcEZ2NvPQFEIIS6XhRDS6Z5vCltYt0DEEgC0BC1l51MqlZs2bZo\/f\/7ly5e\/\/PLLkpIShFB0dPSSJUtGjBjBZrMRQklJSXv27ElMTFy5cuWcOXNaSBIAsIzZ2IikISEx48O3ni3gclhmT9XnXWe0iWxaJ605xjnwT7c5ly9f9vf37969u1QqXbFixfXr1xFCPj4+mzdvHjFiBN6F0Ov1YrH4ww8\/tLew9gE7FQj4HHp54y1wwX\/QbwF91lfoEhftdeDaX\/GJeFPYhcM2UBSLRfB5bIpCAV48ka+rhXULRCwBDoKT2ZtbMCdzQUHB8OHD169fr1Ao+vTpc+LEiXPnzr322mvsP2vjuLq6Tp8+3dvb+6uvvrKyujYA2BwLsREWTlmZ\/wWMcw5OVlbW\/fv3jx49OmbMmOvXrxMEMWbMmHPnzo0cOZJ2O2Gz2eHh4aNGjbKvqPYC52HGKNW6ojKVUqPDmVbqewuYx115bIQQm01gWyDPhR3ky\/9wfGRyQjfTnM80ELEEOALOZ29uWX8+NpsdFxe3fPnymJgYs357jx49kslk3t7eFRUVdi9\/BLRPLMRGWDhlvXcdGOccHBxthhByd3dfu3btxIkT2S\/WbMXMmTOnfUae0WHvDyU1snK1nydPTRrUpHZbSsHEXgHMF8RX6DIoymvr2YKHkppnJXU4pMPfk0eHdwj4HPymNLjygYglwBFwPntzC+p83t7eR48e7dOnj4VrAgMDfX19Bw0aFBoa2nKSAIAFLGhvFk41Nv8L4ODExcVt2rTJQiZRoVDYmvI4FHjdYurqUFajZb4FXQLdztwrQX+mqFRUaXzdXXyFbtP6Bj5VqBr1pkDEEuAIWG9vtrAFjE\/lFhLsXvNKSVezH281WkrnEwgEW7ZsEQgaeLd79eoFMRyAXWC+ohN7BWTLlKZzkmXFDgx4zgFBEIsWLfrggw\/apxnPeszOf9i9Ff+79exfWhq26vXu5JE0pCl15WFNBTgCVtqb8RYw\/e+akznRgUK1zoAQGhTlhRdClbVaFt\/jwK3qzp2VdnyYW0rnIwiiPS+LAZvQcs6zRq\/omXsl9aVKBsXO6Xn\/\/fcXL14MSaMapMH5r2lOePW95vDqAXbHSnszcwsYp\/GqUpI4M+tn5wv8GekdkL13h1sjPx\/QpjHKrUrbw1o6gslILbNVmSbcncuPSus0emYK2bbupQE0jS5duvj7+4PCZw0Nzn9mlUJTlc5oSMFWEISQUq374MDDmBB3AY\/jBAGSgBNgpb2Z+djj5ER0+kmVRo\/TjzMutmc0Euh8gCWYihfOAAOiaAAAIABJREFUrYorJiHbKWH10RLOs3R3qpQkYhSAQvZ+DwF7MWzYMHuL0GZocP4zVQqZyZkRQjjsg1byEMMKgq0jCKF8uTLY17WlhxcAsBJr7M3M1Y7qxWTjrjx2g+nHWxPQ+do1DW6eMhUvvHxhLlla1DbWnGQNuF\/F1WpVXd17o7xjQ59XAqW748pj4zfTaAUGAIAFLM9\/WCn88nJhpqRGqzMo1TpSbzC65pvrUi8BF\/1ZurC8SqNU6cICBXh4QQwDCZjegdakOa5EzNWOK4+t01N0+Wkct05fafdoJGee7RQKxbp16yQSib+\/f3Fx8YoVKwYMGGBvoRyITJnys0t\/pUU0u7BmKl5YSWIuWVrUNtbkZA20Mc+g12s0+h3nn\/1zIhf3i26QriWFu2P39xAAnIZqlY6uMX0rq5w2pWNKqzReAi5t1WMRhEarF5fU4eJsBgOlrCNzi2oRQnwuK8kuHQCcEcsqnfWuRGbbYZrA+VyWvFJDP\/Ohfm6zBwZny5S35GKDunpQKNu+Kxmn1fmkUulbb70VFBR06NAhoVC4b9++efPm7dq1a+TIkfYWzVH40YrNU6biRdvGmNAvgFKj8xW44Eglm\/jiNDlZg4VNYbo7uFqUokrj7sqBVMkAYCuM3j5XHtvIlO7GY6M\/Nw0QQlwuS6PVI1yczYA0Wj3PhU3qDAihh8+qM2X2jHAEnIYGVTr6ucXmZ52eWv9D7qopna1XDZkmcKZeOKlXAM49nupb\/MZX+2N87KyBOKfOR1HUvn37xGLxJ5984u7ujhCaOHHid999l5yc3KdPH29vb3sL6BA8LdOyXsw9a2q3YypedG5V\/C\/TWYdeteM1vU18cZqQrAG\/aWfTixFCQT58Vy5h1C9mdwR8Tqifm9lESk5TZgcAWhkj27zpxhb256NXjzwXdoA3X6nWufJc5KUqLpfFYhHozwx\/9W3v5peRh\/8QV2sQgvcUsIIGvcPTn1YpqjQarUGpInkubBaLkJSqLKiG9bWDceSQc+fU+eRy+dWrVwMCAqKiovARf3\/\/l1566cKFCxkZGUOGDLGveA5CZIBrQZnW8jVMxctX6GKUW\/VmTgW+jF6102t6631xLKhZjXpz6BUYh02oNHpxSV2In7GnnmU9soUihQGg\/WDkkiHgc7p38ujk68q0ecQECdb\/kCspVSGE\/Dx5XgKuvyfPV+gi5HOwiQUfF\/A5Zr1H8kvJr36v5PF4eMkK7ynQIJa9wzNlSkWVRqXRazR6ikJqjZ7Pe24NMZrInKAkoHPqfJmZmWKxuG\/fvh4eHvgIh8OJiYlJSUm5cuUK6HyYCT19mf589W2eWlC86Erq9Kqd9vaz8k2woZpFr8BoX71KJeknIHzcX+iXhe44X5kdAGhlzLpkGL1EMUGCVVM6m152Or3EGhdea5xSaMByD6CGvMNPp5fgWUNvoOiDeEfLaCJzgpKArIYvaYMUFRVRFMVivdA7DoeDECosLNRoNHaSy7HARq8ugQJfoUvTfNroSuquPDP1Sa3BKJXl02Ll+h9ycfl25mWZMuXWswXLj2WbnqKhX0Xsq+fKY7uwkZcbe0IPXyv75QRrOACwL1aOKmYvm9Q7gHlNfavQbHmt0REL5bC2pRRkyZVltdqyWu22lIJMmdKawQRwMiw\/WllyJZ41+Dw2QSCCQGwWYTafg5WPqCPjnHa+mpoahJCPjw+fz6cPYse+uro6kiR5PJ6Fj9+6dQshFBgYGBgY2MKS2ge1Wq3RaFQqVZi3699HBDGPN6qd17p5PJFWI4R83bmFah2XTXTwcjHo9V5u7Df6+VrTGv44QqhOa8DGucISpQsbbTmTu2RMp6gAPkIop0S94\/wz+iP0qZwS9U\/3y0qVWoTQW4ODwn1d8kpU+BpXLhHqxxdwqYUD+R06cK3sF7MFDElqG3tP7AL9g9pbkJZCLpfL5XKpVGpvQYCGsdIlw\/QyK114owOFD55ZtW43tdzv\/01aVvuXQwvsC7cTLDxaeGMXZ2wN8OaXVmkQQhwOC5lT6Rr0DnJ8o7Jz6nxmabD4L83OnTsRQomJiQkJCS0pkd3QaDQKhQIhZFn3bRBPhOb0dv01q66STbkFuQhcWBSiENINDnXxRNUyWXWDLQQJqKflWoRQcQVJGQwIIT1BYEPsubti4cvuCKHvblZpNC\/4HZ67Ky7pyP\/q90r6yKYfa4ZFuT1mWHC93Njjol0a1c2BIehx4QstTIhxlclkFj7iINjqB3VYDh06dPDgQXtLAbQ41uiLE172ffCsjP7Xgq3F1HL\/4FkVnUcGA\/4b7QSzj9alJ+UbTuXUqXVqjZ7nwi7VGfw8eTwuK8CTJ+BxjFRDy\/oc7aeEI39vZZd37+SxaFQnR3u6nFPnwya98vJytVpNl\/2Vy+UIITc3twYrqW\/btk0kEjmxnQ8bhAIDA5l2UCMyZcof00sqVXqEUOLgoPoe3KAgNLh7A19noanXX\/XGNjyNjiRYLBysx3NhIYSK1dygoCCEkExZbaTKFKu5v0uM9RsdR7Bicght+ZvcKyC2A6u4mGu5m0Z9CQgIYLbQL8yxXtf6sOYHbdMkJiaOHj361q1beD0GtGeiAvhJA71uF7ErVHpkMaLf1PvKtCIC+G+0WzJlyg2nclQaPUEQPBc2SRpc+Rx3V857Izrh7CrMKxv0O8dGZTqFBUIoX66kr8yUKX\/M5bF7zdt\/n\/DqZM8MRM6p83Xq1InL5RoML6SA1+l0CKGOHTs2aAsRiUROn72Zx+Px+fz6VASjdM2fXZI1eQfEclOxofx\/TuSeTi+RV2rrNHo\/T57Q9blGzmaxsXhdRR5GAzebxS4wSTRTUEa+F+oVG\/rXu6pWqy1305TYUD6zhTZEY3vatggLCwsLC7O3FICjEOHLHdw9iH7a67PBmAaUsETCfLkShwYzy203kzaxqdfWsflNPp3+V84gFovg8djubhyRj6uRwocY+hwdV\/7zgzKjytHi0joBn0OnsEB\/LjBuZFcghLalFFRW1LL4Htiv1I4eBc6p80VGRgYHB0ul0urqamznoygqPz+fIIjBgwfbW7o2gA0jWBtsCpvcmaOzUq2rUpJ8Lmv5sex58SKzkYBWhvgBAODEZMqUR27Krj4uRX\/qcEZpcpneV10C3S48rKOneXFJXa9Ir+b74OP9QVqPBB\/BlsDKDA9YCXtWpiqp0gR48hBCFioFZMmVRoUGmGZgI30OIUQb8BBCJ28VdfLjMytHY23PtGxBlryurJY0OmhHjwLnjNsNDAwcNmxYSUlJTk4OPlJaWvr48eOoqKiePXvaVzYLOE5AmQ0jWK1sio7jI3UGWbnajc9Rkwa8JEIINTnEDwAAZwXrATeyykidgdQZxCV1SrUO\/WlZwcQECZaPD986K3rrrOiyWpIO6udyWFwOy1fg0sypl94fZMrAFACwCWZtB0ZH8POQ\/rTqXl6ltFR1N6fibk7FxYwScWkdHbXNvFhRpalT61RqneHPFC3eQi6eR4wivhVVGmmZcYTcN9dfCCnz9+RVKUk6hQX2U8J\/O1RGCOe08xEEkZSUdO3atePHjw8aNIjD4Zw7d04sFv\/73\/\/29\/e3t3TmsUmmOltZv22Yhcj6prDBb+vZAi7nhaXIjeyKpCEhTQvxg3z9ANDmsLKiI9YDmJYVnBO+vgmVrrtIb+nils1+tdlvNIW5P0jLAD6CNscatQk\/D\/TuKkkaCAK5uLBNKwXg2daNx2Z68vl5urwx+PkvbqRi+nvyciU1Li4v6HOycrWX4K\/YAAGf4+vu4itwwVZnnFTcAXelnFPnQwiJRKIDBw6sW7du5syZ\/v7+EokkOTl56NCh9parXpq\/nWrD\/MZNrnXb\/KasXxI1GOIH+foBoM3BjH\/Eu2l+njylWkcHQoZ5P5968VjB3J4zDdFg0uD60+wQihCyoAVa3h8EbIU1tgN8Af1b6A0UQSBkrlIAnm3pqus6FyrEz5UZumH0XQI+x8eTpzdQzCIxbiZZaQU8zrrpnTMHBRkbI2w3nzYfp9X5EEIhISF79+61txTW0nzzrw2d8JpQ65bGdKFMNyWvVMsr1ft\/k6L619BNMDHWtzRvVL5+AAAcAXocwwYbg4EqUtRhEwsOhFw0PMgTIfTnWEHX3cFYmFCN1p+kzkDqDcuPZSOE8EfoinB0eEeD+fy6BAqYoZqIsT8I2BBrbAf4eaBVcDaLMFCU0TVGNdlpo6+v0IUZumE6DUUFC9XkX1ZhunK0qUi0MQJ\/1+l7JQihib0CUq7JDOrqppU\/sCHO6c\/XFqFrWjQZ2zoNMP1gTOOY6sNs4nvc1Lx4EfahYZ4ybaGxjnpmvxGfsj5fPwAADgI9juGZmyQNdEUsbLC5\/qcjFx4raBe9AC9e904eFiZUZvEPUmdQavTVKh0eN9aczFlzMqdArjRyDXzwrMqoESM3skm9A2gBKIoyGCiCRez\/TQoVPmyLNfVd8PPg7\/k8L4crn8NzYdN+db5Cl0FRXniy4LAJ5q9siuk0tGhUJyMBpvQOoH3Qi8pU4tI65u9uNDGduVcyOJStv7d\/3suU9fNpS+DMdr62RfO3U1uzFGB9pjULtkYrzZCNNTFaaNb6fP0AADgI9DiGDTb0Dh1NnkKNoo3DckP93Cb1CqhvNjUdr7aeLWCOlooqjQuHxdylxU5gDebzo2V4KKl5VlLn58nzEnDtno\/DKWnQmYf+LXzdXUqqNF4CrguH5c7nGCiEt5i+vPisTqMP8uHTtmH8K1tfb8PUrRz1DsiSK3Gib+bvbmZiynGIyB7Q+RyFJmynGg1kNnTCa\/B763MctGBrtKGj3ouN1Nus9fn6AQBwEOhxDE\/MHDbB4bAMBkqnM7AIIreotkvw80IaVsZbmB2vjMYNlUav01NBPnx6l7ZOo\/cVunhEelWrzJuCaCwEn4HO18qYnTvoBwAXWBOX1IUGuGFPPh6XZWo1bFQcT31GB9OJqYx0RQ4A6HwOhGVdx+hBRAiZDmRNdsJrFBZMaxZsjS1khrTQrPX5+gEAsCNGgxs9jvm6u7hwWKmZZWqNnstl6fQGtcbwuNCw9rx2fG+X8w\/\/MpxYsKuZHa+Mxg1XHlunp\/AurbRMpVLp9HpKXFo3e2CwWZ8tU5rmWgPJnG1Ig7tPtB23SkkG+7piC9\/WWdFGjTAn1jUnc6IDhfVFjqP6f\/fW3HZrFKDztQ1Ml6oersa\/HTOnCdN71OZDiYXRzYKt0bIDdZMltGzdNMrXDwCAo2HWDrecsfpdfSL3RlYZLorK5bL0BkpSTn5xQRzg7cospFGfXc3seDUvXsT80pgQ97Ka57Eaej0lcONiB\/8z90om9grIlikbXEhbmOPr00VsmGkBsGb3id7SxVv2ZjV45goBR+dgBRHV8wPV97ubTkzx3fj3mtdHmwAxHG0D06VqpqSG\/lup1j0tVh65IcXJnC2ENdgEC+EmFjxtLThQN0dCa3x7AQBwWBpMtyutVId1ELjxOa58DofNQgiptAaV1oC36mjqs6uZHa+Mxo3XBwSvmRbVJVBQpSS5HBZOxoGvLKvRWhPNhr3+8VCcW1T7tFg5pocfshhkZk2eYWeiRYsOWLiZ9ANAR9sYKMo06gJj5OWJXky+Y\/oD1Rd0aDoxdQlya04HbQXY+doGFqzEdKYAHBJbnwnQhpqQZdOahR1q+pSRA3UzJWyU\/x8AAA5Fg7ui2JRilPrYlcc2DbAwa1Grb7wyHTdixhv7+ZkKUx8xQYI3BwXTRdi8hC6HbxYFe\/EseMI4VHmGFoKZXrusRktr0s00apr+0FbuPgn4HBcOS6szYElMo22YdjuzhdSMjlhwxDd6wFJTm9ZXGwM6X9vA1IAcESjA6YLwWoRZ6SVTUoNt0TTWDyXW+Jc0J3vfn\/I0cbAD9xcAcDIa9HzCczbtjMVlEz5CtouLS3HlX5nz6Ewc9BF6Lm\/UeEULo1TrFFUanZ56yiZwwqkGO3InvyqswwuX3ciusDDWOazLl61g7rc+LVaqNPrQADda7WvyOt\/sNq6Fm2n0ACg1OmamPSNJmAoi9vKkJ9b6aFtGB9D52gb1LVVPp5fkFtUabUY0Gev9S5r5lDdtsAP3FwBwPhpMOIDn7CM3ZbiqlY+Q48oxBPm5vjE4hOlpd\/PFXBhKtW7zmfwATx5CaF68aLl14xUWhrl54u\/Js3KoMaveWRjrWjrTgt1XyEwbJx08Qc9TWPfNlClPpckLFZX\/n70zj2vieBv4bA4SSAJySgCVgCBWEY+KWhHv1rPifbQe9egptfVqrW3V+tZfVbTeVrEq3rYeVRSpWk9UFCuHF4eAIhAg3ASSkGPfP8Zut0kIEQKB8Hz\/8CO7m9lndmdnnnnmeZ6xtpHPG9DWmPhZvaZT41ef5vz6SOvndIsDXUHkshl5pQpKYMvI\/AA6X\/PAcLqgmkyAGONbqgl38jBM3Tq7RhMPAIBGwxg7nJ+QR+1qJS6pVCgUo7o4Duz0H1eqfTezqf9jpY3NYjCZBHqd+SEWZunRZDaLUa1UVyvV4mI5QujPh0W1\/lyvemegr6vbgkl9MtQ0cm+pFRktU6i1luOxkBq1WqFQy9TV9M3uXhTJHr0opzZEqTUj2Jz+HvSH2cHV5uyDgr36nlKtFge6gkh\/2pbhLA46X7OhJtOaARPg67bURvMvqVtn1xLcXwCgBWLkugFOgXs6Lu+lRHEuqUjowKtpLMceL3R+v5fPYRH0XFc1aU5+Qp6zHceGw8SmPqVKgxA6dTf3HX9Hw92U3q7YcF\/3ugsmxmtyDTpDNlLvpL8RvVvk6QpJbXb3PL8Sb5VBLQfrZgTTXX+n0lYYeEqvZXFoXuu2xgA6X1On1q+r1ozhOFrKGAt\/Y\/qX1OFbsnj3FwAADKDXLKR3LJcp1HQX50q56nJSQXs3Pv5z5ak0hBDWJCrlqs\/2PfLzEPA4LKp77ODK+zPxtXWmGrti0+kNxmtyDTdDNl7v1Aqe6ObdypFnJVdpqI3X76YWCx241ux\/N1p5+KIMO6NrbYiCdGIyDKy\/G35K9fdHb9aAztekMfLrMtCn6C3B056p92LT+peY3Juk0TYaAQCgCWL8WM61YsoUKrwsK3Tgapn98E5rPC6L0hsy8irdHK2pDvbd7i5\/3BNT12P10RidyeRmoWRx5cUnYqoXNV6Ta7gZsvF6p652FeTb6srTYhzd\/KKgClvyPJz+dUWnFn+pkB3d6Gz6+jtCiPJl1xsQjW2Bz\/MrcVJGk2jhZneUrA+g8zVp6m+f11uCZy8nvRebcALUEN4kLXx+BgAtnFo1HjyWJ4srswqrsgrUeFk2q6CKQRAezv+mMsA7rSHaEjClWOAO1k\/IG9LF5VZKEb7sdSPkTKUTZBQpDz3IZjBfTdHpPWqtNNwM+bUsiPT11rMPCo7G5t59WsRiMRgMAiGk0ZAIodJKpROPqFSoK2TVTAbxLFdK3xIXIVQpV5VVKrlsxtLjqfh54vV3ZzuOXjHoi79aiczqPww1BUfJ+gA6X5Om\/vZ5vTOeJ7kVI3yYQqGe6001T20gbxLL864AAMBIjLRdnX1QgLPvYmcvhBDfmkVX2nAODmQwAdu0t4Q5pXLqOM4FY4yTjAl1gr9SqhAi6Ecc+VbY3Y36syZNzvAM2XitVPdKrbdQKVflFskM76hEPZPn+ZUqNalSq7kcJoNBMBgEm8VQqjTZxWqpTGHFZrjYcwvLFNSWuGoNqSGRuFjuZMeRKzVy5b96G10MamjDSiGl7+omMqv\/MNTcQwlB5\/uXZHHlmWccZrfZexOIVu2MSsjU0NTfPq93xpNdJF+dVvXGIyXfmo2\/UpMbqyHeAgAA02Kk7Qp3Pjzuv3oel82gpzKgdlrDC4h0neDfa\/6rM3VwtaFvvNs4wRPPi6s5HI7WQePXOmqaIRuvlepeObqbi7hM8SxXihDCD01cLBc6cLEmWlNR1DORKdRMBqHWkCqVxsqKiRCqVqrZTIJBEBwrgiCIwjKFkx2nUq5iMgh3B2ucgkdvAn+qMVAx2lgM+tbzuonM6j8MNfehDXS+V+DGXVoiZXBtTWUErj\/1t8\/rznjseOysgipSo8nIr3R3ssGfsZHdmfFAvAUAAKYF62En7ubkFqmsbWrcaFG38+FxWKFD3emqkpOAffZBAZfNePSinNIJDCR1W3dee10Vb8OlO1U2RidIFlceuS1+mluhVGncHa1Dh7bTWxFPByvdLcrqs9aB5\/ZXHxdWKdRUGhT0jxalO\/PX0l8r5apdl1+4OVpjF0lxsZzJILQWvvUquNQzseYwNRpSrVCrNSQ+QpLI1YGblV9JMF7tBKtUaTxb8xz5Vusm+6L\/puD5p7Qq9E9j2HX15ZMX5dXVas0\/BaL\/bj1v8mGoPlm7mwKg872iaRps6+\/BRpVAzXhK\/1kaoFxYDsbktOKx6b+qf90h3gIAAJPjJ+QtHtZWLBYLhUIu91\/jHF1fecunFX2kp3Km6O60hoxOwKarOlxPLr79rJT6U++ao16SxZUrT6VRzmoFpYqVFdUrx\/no3npwB5tDD2RaFTFQsmEoox3ep5ieBiUlr0qv8U+rItRaOf6VpExRUaWqlKnyWQwmk8BK5PXk4iKpUksPpp6Jsx1HplBzOUySRGwWw57PVmlIHofJtWIoVK\/uohW0Yfh5lstUBIE4HCa9Rnp3XUMmGobqk7W7KQA63yuarMG2\/h5sVAm4juIimdYFhWUKLZ2v\/nWHeAsAABoHLX0lMr5gdDcX+hYddVgA1SpfUqbAqhJlHpOUKbS2uNRac8Ro6RnJ4srVfzx7ll2h1pAcKyYOZSirVOqdZns5shcMdbz4pNwkvShl16BCYum7Yui1emjZtIrLFAyCqJSrEEJZBVUaDalQqAiCUFSruRxmVkGVkx2nrFKJw2kRTQ+mngn2s1RrSBc7Do\/Dwku3T3PKW\/GY+WX\/qnr0h2bgeWKZqepo1Qg1zDBUa9RwEwd0vlcYnkyY0N3NXGHe1JdjzWFWyVVMJkF1WDYc\/alb6gnEWwAA0Ajo6itFFdVGbrZWK1ihtOEwC8sUGg2Z9rLCmsviWDFs\/ztPRv9dc9SrZ+CiMvMqsbVMrngVylClUNc0zfYT8rqKHF9XYL1DjG56ZGxRU6o0SrXm\/IN8RNNocXVmB7vTbVpMBsFiMbIKqvDuJkqlhsEgSBIhhLB\/XlGZoo2LDV0YKg6aeiaOfCuctAVf4CRgP80pt7FitHG2KqpQCqxZ7o7W9Idm4HlStkPKaFqlUBtYoDcVhqOGmzig873CwGTChHFYZgzzpr4cLpvxMLPU1pqBM2E68q20\/PlgHRYAgGZEg67SYIWSx2W1duBmiSs1JKlSa1rzuaXSag6LoTeHS016BmWXUvzj0EaFMuSVymsKCn4tM4GBIYaya1BBzQJrllKlqVSo2SwVi0nIFGr6gi\/SsWk52FoVl1cjhGQylZUVU0OSHCsmQkip1BAMgs1iqFQarQdCvYianomfkLdwWLujN58rGBxPFz5dHaz1eeIa0WO07fnsxllTar4O66DzvQI37o2\/iTXycjwRodqNCV39zOs1SH05D7NKj958rmBYMRlM\/I1hd11YhwWAJoJEIvnhhx+ys7OdnZ3z8\/OXLVvWu3dvcwvVRGnQAZgqubxSif3GSJIslVZXyVXPZSpPV57e+A+9ihpll6qUqdQKNUJIrSGxm3W1SkPdiJ45P1lcufWKGP2zuno3tbhzO9uaYj7wwnF2oQzRLHbUEKO1K0ZbJxu8+5mWtQwvj2LjH87AYsNhUjYtPpclKVNoNCSbxWDzrXAGRA6HSZIki0lUyTQ4u95rpTP0ceHOe8tOy0HTGOhLxjwui3LcfK1C6kbzdVgHne9f\/IS82b0Elzfvnb1kSG\/aVMMkk0jcBei1n9dD5Dqi+43BOiwANB1ycnJmzZolFAoPHDjA5\/PDw8Nnz569ZcuWIUOGmFu0pkiDDsCUQomdxjQaUlGtJgiCIAgmg5CUKRwFVtg1TWsNlypBK7yDx2V5uvLyS+RVcrUtj+3Z2saK9W8qGazbrf7jmWsrqxE+zJgXBYiWaQshlJFXqXeBiFo4xn\/qBjToXSRd\/8\/1lLWMw2ZQxj98Cud8wGMW1q5w7htKKpIkSRKp1KTQyZrKrkcpYaZ6EbqY0Wu8+Tqsg85XO\/WZRGJV70WR7NGLcqEDV6\/9HAAAgIIkyfDw8KysrG+\/\/VYgECCERo8effTo0e3bt\/fo0cPe3t7cAjY5GnQApntCyxRqlUqDFzQRQkwm4dma172d7Zz+HvSf1LSeQ7dLeQn5lF1qzq+P8GWUFpVdKLNiol\/vKNQEm2\/Npu8dh53wdBeIag1oQPrm9vTRjbKWOfHZ9CHP2Y5DL4rS5M4+KHAUWBWUKQrLFBoSOdlxWvHYNhympEzBZBBKlQZvqotqWJKmTKFqjbqmPQJqxYzWimZqKGneakdcXNyGDRseP36sVCoDAgIWL17cs2dP6qypFkfqMInUUvUkZQq8saCTHYceMNWMDMIAADQOeXl5169fd3Fx8fHxwUecnZ07dep06dKlpKSk\/v37m1e8pknDDcB0T+hHL8pVag0OtqUyOeuu1ehN7IIzmChVGkeBFZvJQDTdlFK88kvkCoVaQ5IKgqhUWLEQwounBvYL0bqp3oAGAx6Bekc3rU3eeFyWo8CqnaO1lkpNPXBKZ0X\/KI5KlQa7ANaUq5luCtWo1b\/eUbi4uPi3fb21XaAONGOd7\/Lly19\/\/fXo0aPHjh175MiRuLi4Tz\/9NDw8vGvXrsikiyOvO4mk7zODVT2NhsTdhFKlodvPa5oGGXbabdYbPAMAYJjk5OSsrKyePXva2triIywWy8\/PLyoq6tq1a6DzNT5+tE1jKYc5bNASF8t1U\/Lq7k4mLpZjHYjNYpTLVFoKEJXyraS8GiFEEIjNZryUyFrbMYUONtWaf6139C1DtAaCmgIa0H836tVSv\/SObnqTWhuIg9a9vqbPtibGAAAgAElEQVRENtSfuqbQO+nlbDYbhraGhmFuAepIRUXF3r17V69evWLFismTJ584cWL8+PFFRUWHDx8mSZJaHJkzZ45AICAIYvTo0a1bt96+fXtJSUkdbucn5C0dKVo32XfdZF\/dqCIt6PvM4P9oyFcpwqsUah6X5dmaZ2vDZrMYeONnvO1H8j8J17HKmJJXqXuq1rMAADR3cnNzSZJkMP7TObNYLITQy5cvFQpFDb8DGhw\/Ie+7kPbt3fhCB25ZpRL38DglL70ffre7C\/1XZZVKrb3d8B4e9GKXjBBVKdQsJoEVPmwjkMo1NlzmkhGivh0c8XiBs8E58q1Eztaf7Xt0\/kH+3dTirMKq9VGZvv9oSHiI6eXr8NMUvyDfVnoXmrXurjW6aclf63qU7vV2NSSyof2pxxQKQ1sj0FztfM+fP2\/bti1ltGOz2WPGjDl79mxOTk5lZWVFRYUZF0fo+8zgTsGKxaTUPqSzTzaGmgYZju1tmvuFAABgKioqKhBCDg4O9DBG7NhXVVWlVCp192Clc\/fuXYSQq6urq6trA0tqHuRyuUKhkMm0c8s3Dp72zNBBwuUn0nHiYQc+y5pNaNTqq48LPO2F9GvOPCgolakRQsVsAl9DFfLoZalc7qRVrCOfxWXzXkpkCCGSJBFCDKSe1tPJ0575zUiPcd3tqQJFjuwTsblV8lcxFi\/yK9u62IiLK+k3fbujwNOeKZfLn+aUa1VB9+5663jmQUFqgaKwvLqiqjr8WtasvkKE0LmEosLKaoTQrL5CHxeu3vq+3VEQm4HSC\/7zgpTKarlcTv0pcrSiLtBoNBqNpqhE5uH0KrdfVbWmsLx61alUNwdu3\/atUsRVujdtRuTl5eXl5eXk5JhbEISar87n5+f33Xffsdn\/Tibs7Oy4XC7uKOPi4sy4OELfZ+ZVKksm4eFgTU8+XtMegqi2MOEmu18IAAANB49n7Lxu8+bNCKGZM2fOmDGjISUyGwqFQiKRIIQM677Gk1Gk\/CulqlSuRgiNDxB4OWrbqLSwQ8iOi+xexTRosOX14Ytisfd\/rpnR\/ZV2En5b9bz4P9ZZBZMpFou1ihXyyOcKVWs7ZmmlWqkmlSpNeRUZfuU5g8nAUtEKLKus+o\/VoKhM9vCFZpj3vzdFSI5vIeSRz4v\/c7Heu+vWMagdMyW32tEGIaQSF1Z893sZQsjG6pX5+X9nKub0aUU9K3p9EZITHujJy3+r3MqGOcrPmn7TPrQLNBoNh6jmcazwk6yq1uSVKBFCWQqlTK649bjQ1Z6N7\/vd72WeDlbVGhIZ96aaCAcOHIiIiDC3FK9orjofm82mK3wIobKyMrlcHhgYyGKxal0cMeFEOa1ArjX1efsNWzy1smYTHk7caqXKxY7D4zBHdnEM8n0Vc3eNNsvBUNMgUc2naj1rJOadKDcaLaSaqAXUtElNlBsabNIrLi6Wy+V8Ph8fzMvLQwjZ2Nho9Xu6rF+\/3t3d3YLtfLidu7q6vm46N70kiysPPchGiMCj4aEHsgVDHWtdOfFvp0nNk9KPWNtYCXVCT5PFlWceFLwoR9nFKlcHLkKosEyBCEJgwy1Dtlp3mdrPfmP0Cw4H2QtQpUItLpI58hkyDYuBGFpSiSvLeTZWlJ0PIVStJqxtbHQFoIql\/nQQWM3qKxT+11qG5cRWupl9hfhGhxOz6ANlXrmMzWLYC\/49klrK7ttZWFMhy8a4UCPjmG4ugZ7\/qaxQiFxcXl2gUir7thUkFzEzixT4RgSDgRBiMhnlckQwGDIVw17AqVSo88tkMpXKzZ6DjH5TTYGZM2e+8847d+\/exfMx89JcdT5d7t+\/36ZNm8GDB6N6L44YM1HGU8PccmVansLZloVnIdTU5\/3u1njiaG2DBvkIerTBYsipiU6fmqdBBk7VetZITD5Rbpq0kGqiFlDTJjVRbmjatWvHZrM1Gg39oEqlQgi1adOm1lfs7u5u8dmbORwOl8s1ic538YmYwfzP5pN\/Z8lq3e5sbE9X3XBXLXmodMpcK5abk01OkYzUICaTcLLlqBBj6xWxViSHf1vuV6NfBTHkvShzsuNYszQMBgOLR5eqo7utTElm0YJ5HQRW8wa01ftA6MUihN7t5uLf9j8u6ZScCKFKuWrR0Wd+HgIeh5VVWEVP9SKv1qg1iP6sMouU1B3phSCEcO2WvUuzfOoTDEsil8vFYrFvO1tcgrxaQxAEjlbJKqgiCEJerWEwmUUVcur\/uARj3lRTwNPT09PT09xSvMJCdL7s7OyLFy8uWrTI3b1GV1PjF0dqnShTU8OsYrWGJPLL1G2crXgcJvpn6iMUor6dDd2CPstB\/50GGThV61kjMe1EucnSQqqJWkBNm9REuaHx9vZ2c3PLyckpLy\/Hdj6SJDMyMgiC6Nu3r7mlszTq5i1jTDIHuu81j8uyYjGsWAx6NKuuKzYVIDzn10catZoer4OlwrG6j7IrxMVyJztOpVyF43On9TUU5Wo4kQ0lJ5UdMCOv0s3Rmp6KGSFkzWHibYINF0IV9VNkhosdBxkdgUs90twiWZVCjaNV6OkGjUlYA9RKM9D5VCrV\/fv3i4qKqCPdu3enG7GVSuXOnTtDQkKGDRuGj9RzcaTWiTI1NcQzEoRQhUwtsLFC\/536GIaa5bzWqVrPGokJJ8pNmRZSTWTpNW1SE+WGxtXVdeDAgYcPH05LS3Nzc0MIFRYWPnnyxMfHJyAgwNzSWRp1Trlfa0ZArWJlCrWWzmRAZengytONvaCygGEbmKRMgQ1yeveoNR5KTirzc9U\/8cj0VMx+HoKiin\/9ArWCebVy02QVVLFZDCaTQAitPJXm68qXqzSoNv0PP1J6ykBnO464WI6jnrHSKXTg4q1KVGpSN0sOUCvNQOeTy+VbtmyJjY2ljuzevZvS+UiS3LdvH0Logw8+wOoXqvfiSK3oRuZW6UxBAAAA6gBBEHPmzLl58+aJEyfeeustFot14cKFrKysDRs2ODs7m1s6S6Ph9m3T0iZrspPpzbfqK+T9mVggVyiZTLWbozW1Ny71K5z6WHcLkPrIqWVI003F7CRg12TapFeWvmsI1v\/KKpXYwKl31zgt6DZUR77VuJ6uzyWyQqmSy2bklSoQQtgYyWYxcJacWgsE6DQDnY\/P5x85cqSms9HR0ffu3fv555\/p1ruGWxzB3yc2PgsduPSk56hZbbQMAECTxd3dfd++fT\/88MOkSZOcnZ2zs7O3b98+YMAAc8tlgTTcvm1a2qReO5nenXkRQpHxBU62VvnFKg1C4mL50M5O9L1xKUyyuKm1uRw97bNuKuaaTJv0ytILwfof3SZiTHKxmmyoyeLKpUeTcXZrvPhrZIEARTPQ+Qxw5cqVM2fOrF+\/Hi\/mIoSys7OPHz\/+xRdfNMTiCPV92vHYZZVKvG1uWxcbehIWaHwAANQfDw+P3bt3m1uKFkED7dumq03q2snWnc\/U+tWt1JIiqRIhZGPFcLNnczgcKmRB7zK08dsy1XSl1uZylC71WiYMemXteGwbLgsXYlonPD8hz9mO42z3n5U68Op7LZqxzpeQkLBs2bKAgID169fjIxqN5u7duwsXLmQymQ2xOEKZ1qn9bZgMwt3Bup7uFLCXGgAAgOWhq01q\/ak3gkQ3Yz9Wa3SXod\/yaWVgXzU6eg2KdLWP2lyuziZPeiHUvSgnPOPLMUyd\/S8BTHPV+TIzMxctWiSRSC5fvkw\/7uvri8MvGmJxhN7UsDuFI99q3WTf+pRp+FMEAAAALBW9GkxNao2u4fB22r+7qOHIhtV\/PHN3sNa1HRi5gZNJTJ50ObETHhUIUn\/3p4bzv2whNFedTyQS\/fXXX4avMfniSEPMMGAvNQAAgJZJTRpMTWqNlk5G7edEpVnJLpRxrZh02wE23Z1\/kI8QEjpwKfUrJa+q4ZaY6HLWx3aot+QG8r9sITRXnc8sGJ5h1O37gb3UAAAAWiY1aTBLRohO3M3JLVJZ21gZUGsoMwQ9VBaDbQfUOhKLScgUauyDjtW+vFJ54ywxmdxdsoH8L1sIoPO9BgZmGHVeogXvBAAAgBaLXg3GT8hbPKytWCwWCoUGkm5iM0SlXFVaXq0hSQZBtP7Hcw7bDqh1JCrFRFmlEv+LY2nplj9YYmoJgM5nCF3TXU0zjDov0YJ3AgAAAFAH\/IS8995y+\/F0GkEgRCImi8gvlnNYDNoC7iuDAhV3KJWr8C4XWPmjW\/5giaklwDC3AE0XbLpLyassklYXSavXR2Umi2s0yNV5iRbbDju48hz5Vo58Q2Z8AAAAAKBzP6PMszWvvYfAmstiMRkIobJKJWU76OD672jC47I8W\/P4XFZ7N34rHtua8yoFDFb+gBYC2Plq5LVMd\/VZogXvBAAAAKAO4HGHMuOp1CSHzaBsB7rrSJVyFf4\/tdqLF3lhiamFAHa+Gnkt09273V3of8L3AwAAADQ0lCUPm\/Hau\/F93QRUvljddaTunnbU9W1dbKw5THs+G5aYWg5g56uR1zLdQQA5AAAA0MjU6hGutY7kJGBT1\/O4LLyTr9ZoBdsEWDBg59NDirhq3fnMR9kVz3KllCW8VtOdn5C3dKRo3WTfdZN967MtRyOQl5d34MCBvLw8cwvSsLSQaqKWVFMAaCGt3chq1uQRniyuXHc+c+nx1KXHU+me6LV6kL+WI7tJaCEvtIkAOp82pK3H2XR2Sl4l3iVaUqbgshkWZvrOy8uLiIiw+G+shVQTtaSaAkALae3GV1PX3GBYbzNsntDryF7v2hiihbzQJgKs7WrD9OhVVlpK\/dnKCtkqC8b4clFxcWysGeUyJTk5OQihu3fvmluQhqWFVBO1mJriagKGaSHNAKppgDPPOKUlUvqRiKjCMZ2M2vT27lPtMN6omKxOnOw6iGEkLeqFmh2CJElzy9CEyM7ODvnflQqazocQ0sjL1fF7zSUSAAAUvXr1Wr9+vYeHh7kFaYpkZ2cvWbLE4sdOoFbYfb7QOmL8KMZ4YzzTrk3dfgsYpil0X6DzabPq5NOkzEL6EUe+1eyu8JQAwPx4eHiAwmeA7Ozs7OwGNMkAzYIzzzipef+x8xk\/ihUqrffdLaf\/8N1OXCe2zMQitkiaQvcFOp82Wruo4dANi\/HkAwAAACybeo5i9Ljdd7u5NPGQROC1AJ1PD9DiAQAAgOYLjGKAXkDnAwAAAAAAsHwgVwsAAAAAAIDlAzofAAAAAACA5QM6HwAAAAAAgOUDOh8AAAAAAIDlAzofAAAAAACA5QM6HwAAAAAAgOUDOh8AAAAAAIDlAzofAAAAAACA5QM6H\/AvT58+ffr0qbmlAOoFSZJXrlwpLy+v\/VIAsCCg+7IAoPtqaEDne0VOTs6SJUuWLl2qdVypVIaHhw8dOjQ0NHTo0KHh4eFKpdIsEjYEkZGR3t7eXv\/w4Ycf8vl8cwtlGiQSSWho6NixYz\/88MMxY8bExsaaW6KGQqVSLViwgHqJ3t7eZ86csbGxMbdcJoAkyXv37o0ZM+by5ctap1rO+zUG6L6g+2qmQPfVyO+X1Wh3arKUl5fv3Lnz1KlTEolk3Lhx9FNKpXLFihWXLl0KDw\/v2rVrQkLCvHnzXrx4sXLlShar2T86mUz2xx9\/BAcHC4VCfCQwMNDDw8O8UpmEnJycWbNmCYXCAwcO8Pn88PDw2bNnb9myZciQIeYWzfSkp6c\/fPhw7NixHA4HIcRisaZOnWoB7TM1NTUsLOzmzZsKhULrVIt6v4aB7gu6r2YNdF+N\/X7JFo9Coaiurr506ZJIJFq0aBH91LVr13x9fVesWKHRaEiS1Gg0ixcv9vf3j42NNZOwpiQ2NnbChAkFBQXmFsTEaDSaFStW+Pr6Xrt2DR\/Jzc0dMGBASEhIcXGxeWUzORqNJiwsbNWqVbiJWhJSqVSj0SxatEgkEl26dIk63qLeb61A92VuQUxMi2re0H2Rjf5+YW0XWVlZsdls3eMkSZ47d06pVPbq1YsgCIQQQRB9+\/aVSqUXLlwgSbLRJTUlKpXqyJEjKpXq5s2bEonE3OKYkry8vOvXr7u4uPj4+OAjzs7OnTp1evLkSVJSknllMznZ2dnnzp0rKyu7deuW7oSyWcPj8fB3p0WLer+1At0XdF\/NF+i+UKO\/X9D5aqSwsPDBgwd8Pt\/NzY06KBKJ+Hz+vXv3SkpKzChb\/UlPT799+3ZiYuLixYt79eo1duzYzMxMcwtlGpKTk7Oystzd3W1tbfERFovl5+enVCqvXbtmVtFMz9WrV1+8eHH69OkZM2Z07tx51apVUqnU3EI1LC3q\/dYZ6L6aKS2qeUP3hRr9\/YLOVyOlpaUVFRUEQTAY\/z4lBoNBEERhYWFRUZEZZas\/np6e58+fP3DgwNixY5lMZmJi4qRJkx49emRuuUxAbm4uSZL0t4YQwg4iL1++tLDZZEhIyM2bN8PCwvz9\/dVqdURExGeffWbZ\/WaLer91BrqvZkqLat7QfWEa8\/2CzlcjcrlcoVDw+Xw7OzvqIJfL5XA4CoVCLpebUbb6w+FwXFxcgoKCNmzYcPHiRX9\/\/6Kiom3btllAn1JRUYEQcnBw4HK51EGBQIAQqqqqsqS4RYSQra2tu7v7uHHj\/vjjj82bNwsEgpiYmPPnz5tbrgakRb3fOgPdVzOlRTVv6L4wjfl+Qed7PTgcjl7vmWaNSCTatGmTm5vbw4cP8\/PzzS1Og8Dj8cwtQsNCEMTo0aNXrFiBELp586ZKpTK3RI2Kxb9fkwDdVzPF4ps3dF+Ndq9mHxFtPGKx+MGDB9Sfjo6Ob775poGYcDwnlkqlZWVl1MGysjKpVMrhcOhKehPHmIp7enr26dPn4sWL9Mo2U\/Ccqbi4WC6XU\/m68vLyEEI2NjaWN+bR6dOnT9u2bbXqbmG0zPcL3RcGui9zCtfAQPfVCO+3Bel8jx8\/Dg0Npf7s3bv37t27DTQsR0dHJyen7OxsjUZDHcQh5U5OTo6Ojg0rrukwpuIEQXh7e7NYLCaT2egCmph27dqx2Wz6W0MI4YljmzZtcBYoS0UgEAiFQhaLpTdkzDJome8Xui8MdF9mkqsxgO6rEd5vC9L5hgwZkpGRYfz19vb2nTp1Sk5Ozs3NDQgIwAdzc3OlUmmnTp3s7e0bRkzTY2TFpVJp69atXV1dG0GkBsXb29vNzS0nJ6e8vByPDSRJZmRk4FwV5pauYVGr1TKZrGvXrha8GNQy3y90X4aB7ssCgO6rEQQAf74aIQji3XfftbKyunv3Lk5nRZLk3bt32Wz2qFGjLGwiUlJScuvWrbffftvBwcHcstQXV1fXgQMHFhQUpKWl4SOFhYVPnjzx8fGhBj9LJTk5WSwWjxo1ytyCNCAt+f0aD3RfzZSW3Lyh+2oEAUDne4XeeJnevXuPGzfu8uXLz58\/Rwg9ffr0woUL48ePf+uttxpbPpNSUlIyatQoHx+fNWvWyGQymUy2bt26Vq1azZkzx9yimQCCIObMmdO2bdsTJ04olUqSJC9cuJCVlbVgwQJnZ2dzS2dKYmNj\/fz83nzzzcuXL5MkmZmZuXLlyjlz5nTv3t3copkGnLZe62DLeb\/GA90XdF\/NDui+zPJ+ieaekL3+lJSUXL16dc+ePcnJyY6OjqGhoYMHD3Z3d8dnZTLZrl27zp8\/7+fnl5ycPHLkyI8++sja2tq8MtcTlUp14MCBnTt3FhUVOTo6ent7jxgxYuLEic29XnSys7N\/+OEHiUTi7OycnZ29ZMmSAQMGWJh5o7CwcPXq1X\/++adSqWzbtq2vr++cOXN69uxpGdVMS0uLiorau3dvRUVFz54958yZ89Zbb1GOXC3h\/RoDdF\/QfTVToPsyy\/sFnQ8AAAAAAMDygbVdAAAAAAAAywd0PgAAAAAAAMsHdD4AAAAAAADLB3Q+AAAAAAAAywd0PgAAAAAAAMsHdD4AAAAAAADLB3Q+AAAAAAAAywd0PgAAAAAAAMsHdD4AAAAAAADLB3Q+AAAAAAAAywd0PgAAAAAAAMsHdD4AAAAAMCdPnz5dtGiRj4+Pl5eXl5dXUFDQ4cOH09LSEEIqlSomJmbmzJleXl4+Pj6LFi2Ki4szt7xAc4UgSdLcMgAAAABAS+fChQtffvlldXV1QEDA\/v377ezsqFObNm3at2\/fzz\/\/PGjQIDNKCDR3wM4HAAAAAOZn2LBhCxYsQAglJSX99ddf1PGEhIQjR46sWLECFD6gnoDOBwAAAADmhyCI999\/PygoiCTJ7du3Z2dnI4RycnKWLFkyZMiQ0aNHm1tAoNkDOh8AAAAANAkEAsGXX34pEAgyMzM3b94slUq3b98uFAqXLVvGZrPNLR3Q7AGdD7AoZDLZqVOngoODvby8AgICIiMjnz59OmXKFH9\/\/7CwMLFYbG4BAQAADNG1a9ePP\/4YIXT27Nl58+bdvHlz1apVAoHA3HIBlgDofIBFYW1tPW7cuC1btjg6OpIk6eLi4urqqlQqv\/7668WLFwuFQnMLCAAAYAi8whsYGKhUKv\/++++lS5eKRCJzCwVYCMyVK1eaWwYAMDGtW7dWq9XXrl3Lz89PS0tjMpkLFy5kMpnmlgsAAKB2OByOg4NDVFSUSqXi8XgDBw6E7gswCWDnAywQgiCmTJkSEBAQExNz6dKlhQsXgisMAADNhYqKiv379\/N4PITQqVOnIiMjzS0RYCGAzgdYJvb29l9\/\/TWfz1cqlUql0tziAAAAGIVSqfzf\/\/4nFosPHjwYEBBAkuTGjRszMzPNLRdgCYDOB1gsz549q6yslEgkW7duBbUPAIBmwW+\/\/Xb58uX169d37twZT1xzc3M3btwInRhQf0DnAyyTR48e7d+\/f9OmTW5ubhcvXoyOjja3RAAAALWQkJCwefPmBQsWdO3aFSEUGBg4YcIEhFBUVBSs8AL1B3Q+wAKRSqXr168fN27cqFGjPvnkE5VKtWnTJpzgFAAAoGlCpV+eNGkSPkIQxNy5c319fUmSXLt2bWpqqnklBJo7oPMBlgZJkkeOHJFKpVOmTCEIYsyYMUFBQZmZmTt27IDFEQAAmiYVFRXLli0rLS2dOXMmPebMzc1t2rRpCCGJRPJ\/\/\/d\/FRUV5pMRaPaAzgdYFCUlJXv27Nm6dWu7du3kcjlCqKKigsPhIISOHz++fPlySMsMAECTQqVSXbx48f3334+JiamoqDhy5Eh8fDw+JZPJoqOjL126hP+MiYl5\/\/33L168qFKpzCcv0IwhSJI0twwAAAAAAABAwwJ2PgAAAAAAAMsHdD4AAAAAAADLB3Q+AAAAAAAAywd0PgAAAAAAAMsHdD4AAAAAAADLB3Q+AAAAAAAAywd0PgAAAAAAAMsHdD4AAAAAAADLB3Q+AAAAAAAAywd0PgAAAAAAAMsHdD4AAAAAAADLB3Q+AAAAAAAAywd0PgAAAAAAAMsHdD4AAAAAAADLB3Q+AAAAAAAAywd0PgAAAAAAAMsHdD4AAAAAAADLB3Q+AAAAAAAAywd0PgAAAAAAAMsHdD4AAAAAAADLB3Q+AAAAAAAAywd0vtfjl19+8aqNN954Iy4uTiKRHD9+fPz48TExMQ0tlVKpjI+PX758+cKFCysrK+tQgkKhSEhIWLt2bVBQ0OXLl\/Veo1ar09LS1q5dO2PGDIlEUjdRxWLxwIEDp02bJpVKdc\/KZLLw8PCePXviJxkYGDht2rT+\/fs3wjNsmlRUVERFRc2aNevw4cO6Z8Vi8dq1a9988038uPz9\/fv16+fn5xcYGDhr1qwrV66o1WpTSUKS5Jo1azp06HDs2DFTlQkYj0wm++OPP8aPH9+tW7du3boFBwcPHjx48eLFJ06cmDx5ck3fbEOjVqufP39++PDhsWPHLl261OTli8XizZs3BwQEeHl5DR06NCcnR+vstm3bcPvv37\/\/sWPHZDJZPe8olUpjYmKWL18+ePDghw8f4oMSiSQkJKRv375paWn1LN8klJSUhIeH9+3bF3\/43bp1oz78zz\/\/PD4+niRJc8vYsBw7dqxDhw5r1qypqaYKheL69euff\/75jz\/+aEyBDdHSmlqzwYDO99o4Ojr++uuvaWlpGRkZu3fvRggJBIIzZ85kZGSkpKQsXLhQoVCIxeJLly6FhYXFx8fL5fKGFunRo0e\/\/vrr0aNH8\/Ly6va15+bmJicnnzhxIjc3t6ZrkpKSwsPDd+\/e\/eLFizr3KY8fP87KygoODubz+VqnVCrVjz\/++NNPP82ePTstLS0lJeXrr79+\/Pjxy5cvG+EZNkFKSkqio6N\/+umnGzduVFRU6F4gFAq\/+uqruXPnIoT4fP6hQ4du3rz5+PHjDRs2ZGRkzJ07d+7cuXp\/WAfUanV+fr5SqczLyzNJgYDxPHr0aNSoUYsWLRKJRBcvXoyPj79x4wZWvr\/66qu4uDhzCVZeXv7ixYuzZ88mJiZqNBqTly8UChcsWLBz504ul5uenr5s2TJ6exYKhfPnz\/\/pp5\/4fH5YWNiUKVOsra3recfMzMynT5+ePHmysLCQOiiXy4uKiioqKsrLy+tZvkmwt7efN2\/ekiVL8J\/r16\/HH\/769evv3r07YcKE7777TqlUmlfIBiUvL0+pVObn5+ud1qpUqri4uB07dpw7d66kpMSYAhuipTW1ZoMBne\/1UKlUkydPHjhwIJPJ1D3LZrNnzZrVq1cvGxubd99918fHp3Gk6tatW0hISH1KEIlEo0aNMixwt27dpk+frqurGQ9Jkn\/++Sefz+\/bt6\/u2czMzIsXL3bp0mXatGlMJpPNZo8bNy4iIsLR0fHZs2d1vqnZiYuLO3HiRB1+aG9vP3HixMDAQGMuJgiCwWAghJhMZr9+\/VavXs1ms2\/cuBEVFVWHW+vCYrHCwsLu378fGhpqkgIBI0lISPjggw+eP3++ePHitWvXOjs74+POzs5r165dvHgxQRDmks3e3r5\/\/\/4DBw5s0LsIBAI2m40QunXr1tGjR7UmnK1bt27Xrl27dkmZpqUAACAASURBVO1Mci9\/f\/8xY8a0bt2afrBNmzYXLlyIiYnp0aOHSe5iErS6YiaT2b9\/\/5UrV7JYrKNHj0ZHR9daglKp\/Pnnn+mLNiRJRkREPH361PTimpTQ0ND79++HhYWxWCx8hC45i8UKCgqqQ7M0bUtrms0GdL7Xo6ysrHfv3gYu4PP5wcHBXC630URqRuTl5d2\/f79bt27t27fXPfvixQv63BoTEBAwcuRIvQvBzYKcnJxvvvlGt14NjY+Pj4uLC0mSJjQCsdlsBwcHvbMdoIGQSqU\/\/\/xzUVFRz54933\/\/fa2Hz2Qyp0+f3qtXr+b7gRiJnZ2dSCQiSXLjxo3GaDMmh8\/n29raNv59X5dOnTo5OTmRJHn9+nXDV5IkuW\/fvrNnz9I1m+jo6B07dqhUqgYWs74wmUwHBwesn2FMJblpW1oTbDag870ey5cvDwoKMnzNxx9\/XOs1LRO8sDto0CC9hnEul8tms5OSko4cOUJZ7AmCeO+997hcrgld0xqNioqKZcuWpaenN\/6tKysrFQqFyYslSbJuDqNA3fj7779jY2MRQqNHjxYIBLoX8Pn8wYMHW\/yCu52d3bp167y9vaurq7\/\/\/vuEhITGl0GpVFZXVzf+fV8LLpeLTV8KhcJwnxkdHb1x40b6inxCQsL333\/fjBxpKisrscJqQslN3tKaWrMBna\/BqaqqWr16tb+\/v7e394gRIx49eoSPYz\/cwYMHnz179ocffvDz8xs1alRubi5Jkvfu3ZsyZUq\/fv06duw4YsSI27dvU1Ox2NjYGTNm7NixY82aNRMnTly3bp3W7WJjY0eMGOHt7e3v7x8WFkb36igvL1+7du3UqVM\/++yzwMDAuXPnJiYmGhZerVafP39+\/Pjx8+fPHzt27KZNm+gFkiQZGRn5\/vvv7927d\/ny5ePHjzfg4I8Xdh0cHHr16qX3gk6dOr3xxhskSYaFhX3xxReUH4aPj8\/8+fMpC0dqauq8efOCg4P9\/f2DgoLOnj1L79pwFMjYsWMnTpzYo0ePr7\/+mvLGxV69oaGhM2fOTEtLCw0N9fPz8\/b2njJlSm5ubmZm5ty5c\/38\/Hx8fBYuXEh35qjpjjjAYsaMGTNmzIiPj58yZYqPj0+XLl0OHTpEkqRMJvvhhx\/i4+MRQrt27QoODqa8iQ1XAZsGJ0+e\/NFHH02ZMuXJkyeG35Fe7ty5U1hYSBBE\/\/796Q8nIiLi7bff7t27d8eOHUNDQ+muyiRJ3r59e\/z48TNnzuzRo8fkyZPv3btHNbycnJwdO3b06dNnxYoV9J\/cu3dv+vTp8+fPHzNmTHBwcHh4OLY5kSSZnZ29e\/fuwYMH79ix4+zZs0FBQV5eXsOGDaM+AWREe27hREdHK5VKPp\/fuXPnmq6ZM2fOxx9\/jP+PP9jJkyeHhoYOHTr07bffPn36NP5mqRist99+Oy4ujgqW6t2799WrV6VS6dq1a\/ER+jvKycnZsGHD22+\/ffPmzeXLl+NPZuzYsfSXqEtNLS0uLm7u3Lk48uCHH37IzMzcsGGDt7f3hx9+WKtBuk2bNuvXr3d0dCwqKvrpp58MOKriL+j999\/\/8MMPe\/TosWTJkufPn+NThr9ZvaWp1er4+PjFixf7+\/vfuHED0XqSoUOHJiQk4J7Ez89v3bp19O7RwGculUq3bt06ZsyYhQsXDh48eMqUKZmZmfiUUqm8fPnyjBkzlixZEhkZ2bt3b39\/f+NjdMrKynB4gZOTE5PJfP78eWho6OTJk+fPnx8YGLh69Wr8ed67d+\/HH39UKpW5ubnjxo0bOXLk5cuXv\/vuu9LSUqlUisXGkXMGOg2qbVy+fDk0NNTHx2fOnDlFRUXGPBwKmUyGdSwvL68VK1aIxeLbt28PHjzYy8srKCjo9OnTMplMJpMdOHCgS5cu8+fPLykpKSkpOXz48ODBg+fNm1dZWZmenq5XcgwepHDn07NnTwMvmsL4lmZgSNVtNgghqVS6Zs2a+fPnHzhwYO7cudOnT6eW0Q2P+6aEBOrBpUuXRCJRly5dkpKStE5VVFRMnTpVJBK99dZbP\/30U0ZGxpdffikSiWbOnFlVVfXw4cPdu3d36dJFJBIFBQV99dVX\/fr169OnT3p6elRU1JAhQ1JSUkiSfPny5aBBgzp06HDp0iWSJNPT0\/v06XP69Gl8i0OHDs2bN08ul9MlGTNmzJ07dy5duvTmm2\/6+vpeu3YNX5ydnT1kyJDFixdXV1eTJFlQUDBu3LgOHTpERUVpCYzvRZKkUqn86aefBg8enJGRQZJkdXX1smXLRCJRcHBwfn4+SZJ37tzp3r071gw0Gs2qVatWrlxZ07PKzc0dMGAArn5N1yQkJAQGBopEIpFI1KNHj\/3792tdHB8fP2jQoBs3bpAkWV5ePnnyZC8vr927d+OzWMJBgwa9fPlSpVKtXbtWJBK1b9++b9++\/\/d\/\/5eUlPTjjz96eXl16dLl3XffjYqKyszMfP\/990UiUUhIyPTp02NjY1NTU8eNGycSiSIiImq945MnT77\/\/nuRSOTr6ztp0qTY2Njff\/\/d39+f3h6w3\/3OnTuNrMKTJ0\/69eu3detWlUqFL37zzTe1StBi586d9EZYUVERERHRuXNnLy+v5cuX49dNPZzQ0NCKigqSJM+ePevr6\/vOO+\/k5OTgC6Kiorp06YLXem7duuXv7y8SiXr27Dl58uS0tLSoqKhJkyaJRKJFixbh6zUaza5du7p37\/7gwQP857Fjx3x9fadPn15eXl5VVXXnzp1Ro0aJRCJ\/f\/\/vv\/8+OTn5m2++EYlEU6dOxTIYaM8ASfskqS\/OMPT2j\/8MCwsTiUTLli2rrq7Ozc39\/fffcbcwYMCATZs2ZWdnb9myxcvLq2\/fvpMmTTp69Gh2djb+avB3mpGRsXbt2g4dOnh5efXo0SMsLOz06dMhISEikSgwMBD3UeQ\/LZBqGIZbWnl5+fTp00UiUVhYmEqlCgsLmzdvnoE+gSTJpKSkUaNG4ScQFRXVoUMHqlJaZ8l\/PpkdO3ZoNBqSJFNSUoKDg998800czWrMN5ufnx8cHEwdSU1NjYiIwJ8h7htfvHixY8cOLy+v9u3bDx8+PCoq6sqVKziKluo8DXzmSqXy66+\/9vf3T0hIIEkyKysrKCho3Lhx5eXlEonk1KlT+Al36dJl3rx5M2bM8PLyOnbsmO5jwX0+vcfWaDQ7duzAX1xsbGx2dvbgwYMnT55MvQgvL6+ff\/6ZeqpdunShNy2tiht+lbdu3QoLC\/P19fX19Q0ODv7++++7dOkycuTIxMTEWh+OFgUFBe+8845IJKIGo0uXLnl5eVGS42c+ePDg+\/fvV1VVXbly5bPPPqP3JLqSk7SOccaMGY8fPz506FCHDh3efPPN5ORkk7Q0w0OqbrMhSfLHH38MCQkpLS3F148ZM+bmzZv4lIFx37SAna\/B+fzzz5cuXSoSiT755BMnJ6cnT55kZ2d37tx56tSpnTp1QgiFhIT873\/\/++uvv65du8Zms9esWTNy5EhfX1+EkIeHR2BgYHV19d69e6VSaUZGRl5enlgsJkkSITRo0CA7Ozv65MnT0zM8PLx3795DhgwZNWqUUqm8du0aQkgmk61atSonJ2fSpEnYB8LZ2fnzzz8nSXLlypWpqal6Jb9z586+ffsmTJggEokQQmw2e\/LkyXTH4YSEBKlUiteVCIIYO3asgdg9wwu7mICAgFOnTg0bNowgiOLi4lWrVtFnwBUVFatXr+7cuXOfPn0QQgKBYOjQoSRJHjlyRCwWI4SSkpLOnTsXEBDg7u7OZDKnTp3q7u5uY2Ozc+fO5cuX+\/v7jx49ms\/nW1tbb9q0afjw4Z6enh999BGbzRaLxatWrerVq5ePj8\/06dNx1UiSNHzHjh079uvXDyHUsWPHnTt39urVKyQkJDg4uKKiIikpSW8FDRcok8l+\/vlnJpM5fvx4bNcMCAjAt6gVPMft3bt3QEDAhg0bxo0b98cff+BIDnxBdHT0uXPnZs6cid9g7969PTw8UlNTz549iwXbs2ePra0tdjcODAzEHtCzZ88+duwY7r61fKJjYmI2btzYp08ff39\/3ADefffdPn36xMTE\/Pzzz1wut3fv3h06dEAIvffeeytXruzQocNHH30kFAqfPXuG31et7Rl4LX777bfjx48PHz7cw8MDIcRms2fMmOHr63v8+PHffvtNKBQOGzbMx8dHqVR+9tlnCxYscHd3f++99zp06JCbmztx4sQpU6a4u7tPmTJFKBSmp6eXlJSIRKJZs2a1bt2aw+Fs2bJl0aJFISEhe\/fuDQgIkEgkR44cIfXZIQy3NIFA8OWXXwoEgmPHju3fv\/\/PP\/9ctmyZ8fG2Q4cOnTBhAkLo+PHj+\/bt0xJAIpF88803VlZWI0eOxKEtvr6+2Pj0zTffSCSSOnyzPj4+48aNo8e3tW3bNigoiM\/nOzo6bt++HX8aISEhJEneunUL1faZl5SU3Lt3r7q6Ghvk7O3t27Rp8\/z585cvXzo5OY0dO\/add95BCHl5ea1du3b\/\/v1JSUmTJ0+u9clIJJJ169Zt3LiRyWSGhoYGBgampqZmZmZKpVL8TXl6evL5\/AcPHhjvnmHgVb711lvTp093dXVVqVQLFixYtWpVXFzc6dOnu3TpYvjh6OLs7Dxs2DB8O+yQFxAQ4OPj8+TJk5SUFHxNYmJiu3bt3njjDWtra1ygkVXo1avXL7\/88sYbb0yYMCEoKKioqOj+\/fvG\/NBwS6t1SNVtNlKp9NGjR+Xl5dhwiGuN16NfvnxpYNw3sqZGwjJtcYAujo6OuPexs7OztrYuLS3VcjsICAggCAK3m7\/\/\/jsnJ+fIkSOnTp3CZ3H7yMnJqaqqatu2rbOz8+bNmxFCs2bNEgqF69evpxfF4\/Go3hOHnuGfZ2dnJyQkODs702OOunbt+sYbbyQmJsbFxeGmRockybNnzzIYDHrMEYPBoAcJdurUiSCIb7\/9Vq1Wjx492t\/fHw\/\/uqhUqsjISAMLuxTu7u47duxITExcuHBhZmbmw4cPJ02aFB4e3rVr1+Tk5KdPn2ZkZAwaNAhfjJ9kcXFxYWGhUCjEOmh1dbVarWaxWEKhMCAgICoqKj8\/ny4Yh8Ph8Xj4\/3Z2dlwul34E9255eXmVlZW13hEftLGxsbKyQgixWCwcvlPTcoDhAgsLC+\/evduvXz8qNpOKxq0VPp+\/a9euM2fO7N+\/X6FQ9OvXj15llUr1559\/ymSyBQsW4AJJksTxejgm+uXLl8+fP+dyubjPZbFYAwcOjIyMNBAxfeXKlerq6s6dO1Ohc9bW1iEhITdu3IiNjS0pKXFwcKAeMm422NlIKpXiWtfangGMRqOp1TldoVBcvXqVJMmuXbtSB52dnYcMGZKamnr16lU8gGFatWqF\/2NlZYX\/Tx3B76i0tLSoqMjNzQ0fZLPZlDehvb39hAkTEhMTExMTy8vL7ezs6GLU2tIQQl27dp0xY8b27dvXrFmzfv16PKU0EhaL9dVXX2VlZcXExGzbti0gIMDGxoY6m5KSkp6e3qNHD6rtIYQGDBiAtdiUlBTqyzL+mzWAbr+BCzH8mfv7+x84cKCsrAzPiCQSSWlpqUql0nK\/8\/b2tre3RwhRt6iJb7755ocffkAIOTs7z5kzZ9KkSV5eXgih4ODgyMhIOzs7e3t7tVr98uVLpVKJFxCMqZ0xrxJXHGs2+HnW+nD0Mnz48MOHD9+\/fz83N7dt27bV1dUqlUoqlZ47d65Hjx44OWVISEgdcvHY2triX3E4HNzIjXzRhltaHYZUHo\/n5+cXGxv72WefrV+\/3tfXl3LJMDzu1ydXhp56mbAsoP5kZ2cjhNasWTNkyBDds87Ozp999hnuKI8dO\/b1119jk1itxeKQ2DZt2tAP2traikSixMTE+Pj49957T+sn5eXlz549Y7PZBmKQe\/fuPWPGjF9\/\/XXhwoX79u379ttve\/bsqfdKsVj84MGDTp06tW3btlZpEUIBAQFnzpxZv379oUOHioqK1q1bt3v37sLCQrlc\/vnnn1Ofihbt2rUjCOLZs2clJSXOzs64NxcIBFqZF4yn1juatsA\/\/vijoqKC8sJ+XRgMxpdffvns2bOYmJi1a9d27NjR3d0dn5LL5YWFhW5ubr\/\/\/ruLi4vub+3t7W1tbbFfI35HuKPRG2GNEJJKpdQUnI5IJOLz+Tk5OTk5OfRxVy8+Pj51a88tBB6Ph99gWVmZRCKhNDC9lJWV6U39ihcT0tLSysrK6INWfejcuTOfzy8uLtaNE6q1pSGECIKYPXt2TExMUlJSHbIoCwSC\/\/3vf7NmzUpPT\/\/222+\/+OIL6tSjR4907cQODg5t2rQRi8WPHj1qnOi6WvsNd3d3FxeXqKio69evjxkzxtbWVisJ8GtR03jBZDLfeOONkpKSsLAwgiA6depED3StFWNepanw9vZ+6623IiMjr127NmPGjL\/++ksul\/P5\/Dt37kgkkqysrOLiYsMZMxoCAy2tDkMqQRBz586Nj49PTEwcOXJkSEjI0qVL8STE8LhvWmBtt2mBv\/wXL17oPUsQxIwZMw4ePOjv7\/\/y5cv58+cbmXuTyWQSBCGTycrKyuil4dmb3o5AoVAUFxcrlUoDwVBsNnvZsmXbtm1r06bNw4cPp02bFh4erncSmZCQkJuba2BhVyqVRkRE0PNn8vn8b7\/9dsSIEQihlJSUrKwsnC+6poeDEOrVq1dwcHBaWtqJEyfUanVeXl5SUtLIkSP9\/Pxq+olhar2jaQvEq+RyubzOGQcEAsGqVavc3Ny00orKZDKJRCKVSmvKGuPq6jpt2jSNRrNnz56SkhK1Wn316lVvb+\/Ro0frvZ4gCKyY5ufn049jSzCLxTImpUud23MLgSCI4OBggiCkUmmt4VY1vRH8dbNYLBMq0\/gtOzg4cDgcrVO1tjSMRCLB8Wo7d+6knDeMx93dHXvZ48GYUhxxZUtLS7UiJQ10dA1Brf1GYmLi8OHDsfdkt27djLTlvy5qtToiIuLdd98dOHDgokWLqBmgkRj5Kk0Ci8UaPXo0QRBnzpzJzMw8derUypUrBw4cmJaWduvWrcjIyP79+1M22sakppZWhyEVIeTm5nbw4MGPPvqIy+WePHly1KhR+Ls2PO6bFtD5mhbYrHLz5k2t6e+9e\/fi4uLEYnFOTk7Pnj1PnTq1ceNGPp9\/9OjRWvMwIYQ8PDxwFBK9ValUKqzP6V1v5XA4Dg4Ocrm8Jm8\/hFBmZmZJScnw4cOjo6OXLFnCZDK3bdumG9CnUqkuX75seGGXIIgrV65cvXqVfpDNZg8ePJj608vLiyCI+Ph4rZ3f0tLScCIlgUDwyy+\/jB8\/\/sSJExMmTFi9evXXX39N92l7XWq9o2kLdHV1RQhlZGTUJ2+7SCRavny5lZVVTEwMFaRmY2Pj7u5eUlKi5cuiUqlOnDghkUjwHHTTpk2ZmZnTp0+fPXu2p6fnyZMnaxoneDyet7c3QiglJYXucSKXy5VKZdu2bY0ZYOrcnlsOlE\/k6dOna9pRQK1Wy2QybGNA\/7iiUmfx2+nYsSNeKDQJZWVlcrm8ffv2urnHam1pWKQff\/xx5syZI0eOzM3N3bFjRx0U\/a5du3744YcEQZSVlVE\/79ChA5vNxmZm6kr8fLhcbpcuXV67qnXC8Geek5OzaNEigUCAk883nBgXL15cs2bNmDFj6pYT2JhXaUKwD9\/Tp0937NjB5\/N79+6NJ5y7du26d+\/e8OHDTXs749Hb0uowpKpUqkePHnE4nK+++io6OnrIkCESiWTt2rVSqdTwuG\/a6oDOVy+0ptT1p2vXrnw+PzY29vLly1TH\/ejRo23btrm5uT1+\/Bgb0phMZkhIyHfffUeSpDGTA5FI1KdPH5IkIyMjKRtSSUnJs2fP3N3d9fYIdnZ22DHoxIkT1GCDQ+Goa\/78889z584hhKytrT\/++OMPPvhA76TQmIVdHo\/n7Oy8c+dOrTUObPry9PRs06ZN+\/bt3dzcKDMeviA3N3f16tVYwyBJMiIiom3bthcvXjx9+vT27dsHDRpUn1611juatkCcTzUlJQVH3uAa1WFLq2HDhs2bNw8htHnzZqyb8ni87t27I4QOHjxImVWwU\/nDhw+xNpCYmHj27NnIyMhz585FRETMmzfPcDbRUaNG8fn8R48e0Rd5nz59KpfL+\/fvr+XmpZc6t+eWg7Oz88KFC3k8XmJi4rp163RXQktKShYsWLBv3z4WizVmzBiCIHDAJj5LkmRCQgJBEO+8807dHAb0cv\/+fRyyo2s7NKalHT16VKlUTp8+PTQ01NnZ+ezZs3WbQc2aNUsruCEgIKBz584VFRV\/\/fUXdTAvLy87O7tjx451tve\/LoY\/cxxaweFwcNeEVdKGEOPGjRtKpZJyzsHzMeN\/bsyrNCFUTMOpU6dwsCDWAlNSUlxcXIx0CmogdFtaHYZUuVy+c+fOjIwMhJC7u\/tPP\/3UpUuX\/Px8mUxmeNw3bV1A56sXWBkyvABKfWYqlUrv+E3\/Drt06TJq1Kjq6uqFCxeGhoaeOHHim2++mTVrFg5BRQhduHCBvjGOo6MjfUpBL5++PshisZYuXern5\/fnn39eunQJIUSS5OnTp8Vi8TfffEM5JWiJ98EHH3h4eCQmJn766adPnjx58uTJmjVrcKDunj17cC9w7Ngx+oTPx8cHmyXo1Lqwi2nfvn16evqnn35KWRafPHly9OhRR0fH7777TiAQeHh44KDasLCwmTNnHj9+fO3atWPGjAkKCsLZy+7evbtx48bnz59fvXo1JyenoKCgoKDAmNTENfnI13pHLXRVNDyBu3bt2tOnT5cvX46HupoKbN++\/bRp0xBCK1asOHDgQE5OzoEDB\/DmaWfPnr18+bLeumDJ6Y2QIIgPP\/wwKCiourp65cqVOMPfxIkTvb2909PTJ06cuHbt2uPHj0+fPv3IkSMffvghi8UqKSn59ttvX758ef369ZSUFPzotMyN+EaU3t+9e\/fQ0FCZTLZ582bK4\/jgwYP9+\/efM2eO3ues+wkYbs8AQmjIkCFbtmxxcHA4fvz4tGnT7t69i5tBRUUFtmf7+fnNmzePyWQOGzZs6tSpubm5O3fuxL1KYmJiVFTU1KlTcVykAQxrA1Kp9Pr16\/iav\/\/++8iRI1OmTMFBqei\/XQ2qraUlJCQcPHhwwYIFAoHA19d37ty5KpVqy5YtBhza8vPzX7x48fLlS63j2LeE7qInEAi+\/\/57Z2fnw4cP42y6SqUyIiKCwWB8\/\/33epNa636zejtqfMTAU6I\/BMP9hq2tLY\/Hi4+P37VrV3x8\/LJly5KTk6VS6YMHDyIjI6lvXGuCrQslTE1SYT\/mY8eOnT9\/\/sKFCytWrFAqlVlZWbdv3759+7aTk5ODg0NeXt6NGzfOnz+\/detWbNjDGnNsbOyqVavGjBlj4FXW9AANPxwDDB8+3NHRsWvXrgMGDED\/aIEEQYwfP15r7MBVpu6rKzm1uE89RmPkNL6lvdaQSr2gkpIS+o4DCKE+ffrY29vXOu6bEObKlStNW2ILIS0t7ejRo\/v375fJZNhmy2KxHB0dcbdSUlJy9OjR06dPq9VqiUQiFAorKysPHjwYExOjUCjKy8vt7e1PnjwZFRWFw6n4fL6Li4u1tTWTyQwODnZycsrIyPj7779v377t4OCwceNG7L6am5uLQ\/CKi4uvXLly69atVatWdevWLS4ubtu2bbm5uRKJhM1mu7i43LlzZ+\/evaWlpQUFBfb29l5eXg4ODqNHj1apVHv27Ll8+fK5c+ekUum6detwyWlpaQcPHrxw4QJ2g7O3txcKhU5OTgMGDMjOzr53796hQ4cePHgwYsSInJycsWPHzpgxo23btqmpqS9fvoyOji4vL\/\/jjz9yc3PXrFmjNSFTqVS\/\/PJLYWHh559\/7uTkZOCRSiSS1NRUa2vrAwcOhIeH\/\/rrr0ePHg0MDNy0aROeoBME0b17d19f3\/T09KSkpOvXr5Mk+X\/\/93\/YEQQhVF5eHh0d\/ffff0dGRu7bt2\/Pnj179uz55ZdfiouL+\/btm5SUFB4e\/vjxY7lcThCEi4tLVlbWwYMHExMTpVKpWq12d3fPyMjYs2dPVlZWWVlZq1atWrdu3b9\/\/5ruSD320tJSgUDg6uoaHR199OhRmUxWVFTk4eHh4eHh7u7+999\/P3jw4P79+1988UXHjh0NVIEgiB49ejg6Oj5+\/DgyMvK3337z8PBo3bq1ra3tZ599FhwcrOU+JRaLIyIi6I3Q2tra1dXV2tqaw+H07Nnz2rVrOTk50dHRarW6W7duY8eOLS8vxy4yjx8\/Dg4OXrduHfaSUavVN2\/evH\/\/\/p9\/\/nn48GHq0V29erVfv35qtfrSpUv79+8vLS2VSCRcLtfFxUUgEHTv3r137943b97ctWtXQkLCyZMnJ0yYsHTpUh6Ph0Ptjhw5Qj0NNpu9Z88e\/AlUV1eLRCKFQqG3PZv4W23+iESiadOmtW7dOikpae\/evVu2bNm2bduFCxdcXFy+++67IUOGYIsR3nHVx8cnMjLyyJEj2GywYMGCuXPnslgssVh85MgRnBm4srISb6N3+vTpc+fOVVdX426KyWTu27fv1q1bMpmMzWa3atXK1tb2999\/VygUSqVyw4YNERERf\/3111dffYXLLCkpOXfu3L59+8rLywsKCnDDcHNzGz58uG5Ls7e3v3bt2qpVq5hM5sCBAz08PGQyWWJi4t27dwsLC+\/fv+\/t7a01wuEWHhYWVlZWFhsbS5Kkn58f3VWDw+EEBgY+ePBg6NChOErU1dV1xIgREolk69ateKtrJyendevW4djSWr\/ZoqKiX3\/99d69e7ijdnBwqKysPHnyZGRkJO7M7e3tZTLZL7\/88vjxY5lMptFovLy87t+\/v3v37tLS0rKyMnt7e09Pz169etX0mTs7InRt5wAAIABJREFUOzMYjPj4+Li4uGfPnn366acBAQE3b95MT08fOnQo7qbKy8tzcnJYLJatra2jo6NWeygpKTl58uSWLVvwrOzhw4cMBqN169ZaSi1W1548eRITE8Nisb7\/\/nuJRPLw4cOKiorJkye7uLhoNJrbt29fuXLF3d39k08+4fF4AoHg2rVrt2\/fVigUX331lVAo1PsqnZ2d09LStm3bdvfuXdx4bGxshEIhm81OS0vbvn274YdTk7NNq1atUlJSRo0aRcWe29vbZ2RkzJ07lwoBlslk169f37t3LzXeOTg4CIVCuuSLFi26f\/\/+L7\/8gvsrPp\/P5\/MvXLhw\/PhxmUyWm5vbpk2bNm3a0N0o69DSbG1tDQ+pJ06coDcbZ2fnxMTEzMzMO3fuFBQUHDhwoHPnzgsXLuRyuYbHfdNCGBm2DQBNH+wn1LFjR1dXV6VSqVQqExMTJRLJzZs3N2zY0AghUc0XkiRPnjyJe7SqqiqEUGpqan5+\/p07dwIDA9etWwfhtC2TgoKCiRMnlpaWHjp0qKZMTAAANBcgVwtgISiVyjVr1nA4nOnTp1MKCk7duW3bNvASM0x0dPTBgwf37NlDBceNHDkSIZSYmLhr166qqqpak4QBAAAATZzmrfPFxcVt2LDh8ePHSqUyICBg8eLF9PxwEonkhx9+yM7OdnZ2zs\/PX7ZsWeMn+AEajbt37548eXL27NlaxysqKtLT0z\/55BOzSNUsKC4u3rp1q5WVlVa8C0mS9+7d69u3Lyh8Jockybi4uK1bt+Jgl9TU1NmzZ0+cOJF6BdB9AQBgcpqxP9\/ly5e\/\/PLLvn37jhs3TiwWx8fHX716NTAwECe8yMnJmT59OnYhGj9+fMX\/s\/fu4W1U197wmptG0siWr4pkO45DYseUUEgot+QtgQLlvNCkXHra0kMJTQ5t36flcFre0MKBfin9+tCSwnkoT04LHMIHPTSHHkpLAuFSaLglYGgdICE4dogvsS1ZthzL1kgzmtv3x7Z3JjPSWJJlWbLn95c9M9qzZ8+etddel9+amLjjjjtQ4ci57riNWYEgCC+++OK+ffsGBwdrampIkgyHw7t37966dev1119\/\/vnn295JC+zfv\/+dd95pa2urqalxOp0TExNtbW0\/+9nPNE1D5enmuoPzDa+99tr3v\/\/922+\/\/fvf\/\/6VV17Z0tJy++23V1RUID6R4hFf\/f39Tz\/9NM\/zl112WVNTU4HvbsOGjfyiVOP5JiYmvvOd73zzm99EtD2SJN15551\/\/OMfr7vuuvvuuw8AfvrTn+7cufORRx5Zt24dAASDwW984xsVFRU7duzIe5K5jSJBZ2fntm3b3n33XZ7nKYpqbm6+5pprvvKVr9hvfFqMj4\/\/5je\/ee655xA5jt\/vv+SSSzZu3Njc3GzrynmHLMv\/+q\/\/evDgQVzhIBaL\/fM\/\/7PD4fjNb37jdruLRHy1tbXt2bMHZR0SBOH3+\/\/xH\/8Rbapt2LBRiihV325PT09jYyOOymcY5stf\/vKuXbsGBgZ4np+YmHjjjTd8Ph+ucFxbW3vGGWf85S9\/+eijj5AYtTH\/0NLS8uijj851L0oS5eXlP\/rRj370ox\/NdUcWBFBO6NjY2NDQkL6qlcPhoGk6FAoVifg6\/\/zzbeocGzbmE0qVn6+1tfXuu+\/Wu5y8Xq\/T6ayqqnI6nR0dHX19ffX19ZhUlqbp1tZWSZIw260NGzZszAkQ2+3ExMS2bdsQteGBAwc++eST6667jmVZW3wtTHQE+fte6L796c7bn+7sCPJz3R0b8xOlaudjGMYQY4TKAZ133nk0TaNKjoYihohD8vjx46IomstE2rBhw0bBsHnz5vb29rfffvuGG2748pe\/\/Lvf\/e7+++9HlQZt8bUA0RHkt+05WXd4257uLVcubQ3YuVM28oxS1fnM+Nvf\/rZ48WIkNNHWGdn88AWIrzIej0uSZCE0+\/v7ceUiGzZsFBUQ0\/Vc9yIPKCsru\/\/++2+77ba333774MGD3\/ve99atW4dCJ23xtQDx3FF27ERMf+SJPSNfPsOZ7nobpYhiEF\/zROfr7+9\/5ZVXbrvtNotCJZnwTfT392\/ZsqWtrS2vvbNR1NDKG6iG8wnWCwDyp68Q4\/aSWbw4\/\/zzt23bNudyMy9A9UjOOeecDz74YPv27d3d3ffee2\/K+mBgi6\/5DubCf538i3ZSrkog6U9U+b8fesgWRxjzQFAXg\/iaDzqfJEm\/+c1vrr76alxTEsnN0dFRQRA8Hg86iBIS3W63BfFEf39\/W1vbtm3b8l7kzkbh0dbW9uCDD1q\/zSPB+K5PdfPhwnUblkkrAu5C9M9GlkAvtL+\/fx7ofAMDA9\/61reuvfba7373u++8884PfvCDPXv2oFpqtvgqJDKREgXAc0fZzlAsLioRfjJNnqbJ02\/4eXGKo0IO2pFgfFd7mCfco0muuoxysxRASQrqIhFfJa\/zaZr2+OOPA8C3vvUtTCqxZMkShmHMlbMBYPHixdNGw9TX19v0p\/MG1m\/zzRe6KypPCZeWqyouuKDkVQobRY7\/\/M\/\/jEajl112GUEQa9as+e1vf3vTTTft3bv35ptvtsVX4THng1axhN+2p3tsiKcZBQAYmgxUOTknnXdx1BHkd7WHR2ISAGy6qH4mIYMFGLSOIP\/mx90VTb6xIZ4mlGgSvBVuzkmDLahzRanm7WK89NJL77333o9\/\/GP99nfZsmV1dXUDAwOoBDUAaJp27NgxgiDWrl07Rz21UWj4\/f6NGzda04kdCRnz446E4rPZKRs2IBaLHTlyxOVyoSIcAHDmmWd+\/vOfHx0dHRkZscVXIZGJlJhVdAT5n\/zx6N3PdHYOTJwYT5IEwdBkjZdFmk1+xRHKFDkS4iOxZCSW3LanO7cE4YIN2q72MPojISrojygvoT9sQZ0bSlvn++tf\/\/rcc89t27YNB8H09\/fff\/\/9Pp\/vkksuCYfDXV1d6PjIyMjhw4ebm5vPOuusueuvjYLC7\/ffeOON1oJphd\/OjLNRaDidztra2kQiEY1G0RGaphHVVE1NDSLEtsVXYZCJlJg9dAT5rc92vfpReGAkoSgaASAraqDKWcGl9eDPhNIFq1AY+zpP5NDtgg0a3pO72MmahPEp5c9Gbihhne+DDz644447VFXdtm3bnXfeeeedd\/74xz\/+5je\/2dLSQlHU5s2bGxsbn3nmGUmSNE178cUX+\/r6br31VlxC3oYNANiw2qf\/t9rj2HSRVYSKzaFlY+agaforX\/nK+Pj4yy+\/rCgKAPT39x84cOCSSy7x+\/0EQdjia4FgV3t4OCrifxmGlGUVm7LM4miGhrqSc2vgPXmt95SQhmkFtY10KNV4vu7u7ttuu214ePjVV1\/VH29paUERBvX19Y8\/\/vg999zz1a9+tba2tr+\/f\/v27RdffPHcdNdGsaI1wG25cikOcNmwymcR4GJzaNnIFz7\/+c\/\/7ne\/+9WvfvXaa68tW7bsyJEjGzduvP7661FQsi2+FgiOhPiEznBFkoSTpT0uutrjCI0JoTFhx5sDvChXcw5BVgFAUlRDC\/s6T2Quglb4ObPaV8zYsNqHRC7npBt9bkXVfF6WY2lrQW3DAqWq8y1duvS1116zvqahoeGRRx4pTH9slC5aA1zrVUszuTKlZ8QWPTZyw7nnnvv000+nO2uLr4WAFX6uZ+gUtY+iiKU+btNF9UjX6QrF+oK8qmmci2modfWF442+ySQGhKwMdViFQih+a5l+T17tcWxY5ftfLRVz3anSRqnqfDZs6JHHZDSLxts6R1EyHT5V5J4RGzZsFDM2rPa190T7wpNihKHJlUvKN11Uj7aXvCD3BXlF1QBAEGV0WZSX9CLIDAthmJVbo0iQ+Z7cRiawdT4bJQ9rl2tHkH\/lcDBndVDfOE0R5n22DRs2bOSG1gC39drm3+8PfjI4IclqrZe9\/oK61gC3tSc6HBWjE0lJVkmCBEJDmh9DkyiJgRdkFAjoZMiOIK8Xd9bxJ7YKtcBhL102Sh4WLtdjEem\/2vtJajLnK4cIPH3jtV62LxzH++zi94zYsGGjyNEa4O65brn+SEeQH46KCVGRFQ0AVE0lgQRCQ2dXLil30OTRwRgA1HhZQVL1Ys2OP7FhDVvns1HysEhGe+1IHIDQn8pWAuobx3HE1R4HlIhnxIYNG6UC5Jbd+\/FIXJA1DSiSAI1QNRUIjXVQAFDpYW65fMmu9vDyOo\/+h\/\/z3hBLE3b8iY1pYet8NkoeFsloPaNJQ92CbCWgoXHOSVd7HPd9rSWHftqwYcNGOmC3bJSXCILQNM3JUnFBpoCgaZJ1UJUe5htr61sD3LZTxR0vyK9+NKkF2vEnNqxRwvx8NmwgWHDsNVU5Zq9xGzZs2MgBKWk+sVsW8Q+TJFHOMSsay6u8bH2N6\/yWqv971bKvnucHE5O8nuEP8dhZMPzZWOCwdT4bJQ+UjLbCz1V7HCifH7tcL11xShHuHCRga4Bbv8o3HBV7hvieIX6F3237c23YsJEz0vEqY38C5h+OiwrnpM9ZVvmLr7fe97UWTFNi2IjKihaocqK\/UfwJYvgzCEMbNsD27dooRZjJCNIlo51Wzdx6efUrh8dz5iboCPK7D4RrvSwSxPuPjq1tqbTFqA0bNnJDujQLHEaC9LbhqFjmolPqbQbKldoVVcMTSXzWjj+xYQFb57NRYpiWmQWLwm+cV+0FaA1wZy+tzvl2dh6cDRs28oh0OWd6wmTOSTfWuDG3lPUu1yASbX+uDQvYOp+NYoQFraiFEmaQfQ\/+pf+G1a5AYEY9KbkKlTZs2ChaIB4WFG9nSLBNR5icCeWe+YezSlNvo3Rh63w2ig7WMs5CCTOrg38\/LqxdmaL9zKVhyVWotGHDRnECSTY3S41ERQBACbbInocuSBmjkomroTXAwWofEmu7DoRHYsndB07+at5UBrcV2ZnDzuGwUXRIKePw34acNT3MylnPqGQ4ki6AOh3svF0bNmzkBUiyoXA9F0sxNEmRxLRBxpm4Ggxi7aGXunlB1l+gF6ElimxFt42UsO18NooO1jLOokx4Jja5bOPzClah0t7C2rAxv4GlE+ekOSfNC\/LoRHLXgfCuA2HzJ48FwmAk4eWYlHx7+JqDvVH9NQlRMZTlnQcRKXZodV5g63w2ig7WqptZCQOA+17oHolJoTEhKatY0lW4qS+1ugw\/zyE+rwAVKqcN2bFhozhh71UyB5JsqFSumFT5hMS5mEgsCaly0bBA8HKMnmYZ73L110R5KcpL+BoXS6GyvPMJdmh1XmDrfDaKDhaWPIR0OWsMTSZltdxFMxQJAF88vey0MsHQeOHj81IuioaD9hbWRiliQe1VZq7dbljt2\/psV184DgCiqACArKi8ICNFTf\/J6wUC8gU7GcpQ8lF\/jYul9La9Wi8bHD0p+uZHRIodWp0X2DqfjaJDVu5Ug7bEOemV9Z7N6xoAQBCEYDBouH5ahTK\/SLkooj\/0B7Hcx7C3sDaKHwtnr5IX7bY1wLX4PcNRUVa0hCAzDEmSBFbU9J+8QblJSbmnv6bWy\/aF49i211jj\/vqFdZ1BfrYjUmYPZg27wKJ7vsLW+WwUI5AlD3326eJdELI1+BcsPg8h5aIYiRkzSyRFm70+2LAxS1g47rZ8abcDY0LTIg4Aeob4hKgAAFbUQmMCilHJsCm93QvZAhVVw7ZAXLRj5ii8+z6dhl1I0T1fYet8NooUGW6sczD45z0+z0ImplwUUQSPHv4KVpBU\/G\/JbWHtoK6FiYXjbsuLdqsn5\/NyTEIXcifJalJW8V1Q1i22\/acUCAa7l57DOY9IKYebKqn83sUArGGj2EdZ0X7256N3X728AKHV8x42V4uNIoU1YwvGbHCppKyAnu7Kn\/zx6Hf+8+AL7UN9I3Ezg0BKZhnzQY6l05UMLn7YHArzFdN+CAuHyciCIipDYHI+SVYlWR2JijVetr7GtXJJebXHUeai9dEdqA6HtUCwqDOeR2Qoh\/MLpPvygtwXjidERZLV\/pGELVjyAlvns1GkyHBjnXfBl7kGg67cdySChHhfOI5253qZmHJRTHmwNcDdftXS+77Woi+mXhKYk1XBxmwjkw+hMGpHMWDm2q2BnE\/TtLFYkiIJjqU3XVSvN\/NjTCsQkNDYdFF9jYfZdSA87R41B8yJ+x5p2MNR0XDcFiwzh+3btVGkyNxtlF+DfyaBO8iVuffjkbioiEmFJAl0HIVj62ViuhiU+RSYsnCCuhYULPxr+ssWiLtt5sFk+tg7AOgTFYIgOCeN9Gk8yGCqyWaN2U6dnhP3PXJbY983Q5OBKifYgiUfsHU+G0UK9NljUUhTxD+tqcu5tUwCztA1L7QPwali1yBosJBFcTmSpKL8O9CFY+uRclGcTyvlwgnqWlDQ+9fQkf6RxNZnu1r8HkFWIafAzZKO+5zhN6v\/TAwWLF6Qg6OCJE+a+vrC8VXLKjK0I8526vScZMsiDftnfz7aP5IAgBovm7kSbMMatm\/XRpGiNcD905o6vPet8Die2j+Ym+ciEy8VvoamCL2j1gwsZF0sBQAMQ8qyCgCqqvFxqWeI50V5QcWdLJygrgUFs38tKSl94fj7n57ILXBzgcd96j+ThKhg2xVMDTIuyMbQZDXnsNDb9HGW7T1Rw9n8GsNydt9nHhWd7r53X718eZ1neZ2ngmPAFix5gq072yhe\/O1YFPEaYOS2hc1kK4yvQUxXMOWoNQsavFlHV5Ik4WRpggRJVp0sXeFxCJI6v8lpDbA5FOYlzP41ZIjSG7Oz+h4XDplfSug\/Ey\/HuJ20vlQaQ5Pc1BFekN\/\/9MTtT3fCqdZQZCXtjSQO9Y4jfXE4KkYnkk6Wbqh16S1h+bWn5mDgzBedoS1Y8g5b57NRvMhXoJieAQEZDnuG+LUtlSlJVVCQ9XBUZBky5b4W+2jwlWUuWpRUX4UT7UcRLNazdBK5dD1f88lVbQPB7F8LRhKGa7L6Hu24T\/yZGFQiL8d4p0QHcqYzNGmoyYZ\/0jPES7J6bDAmK5qmaZoGCVHGxdmqPY41zRVzXhwlX\/q9LVjyDlvns1GMQNrPYCQRF5WsIppTApe5xJFJSUn73uOHWhvKUNJca4AzEJymJL5H0Ae4IEqFTRfVo9DDniEeR2GnW8\/S7YAXVBkrGyUB5F\/D03IslpQVDXsks4Ud94mB9OmH9x7v6J\/QlwgHgOGoqHf7wpS29Pv9QSRexmNJmiLFpEIQQBAEAKiqRlEERRJoj7q\/y5jcWnh76kz0e\/PWt3Q3w0UIO57PRtEBx\/14OUYfWpdzPAeKpMGRSVObY+VYiMdxRegapLcdHYz1DPH\/8Nkac8fue6F7x5sDkqyWu2h9gEt9hRNTSU32WZwmHBADERDYjCc2ihD6cK7WhjJ9NH223+MCifvMPI5tPCHXVbuaFnG1XhYAkEiRFc2QsnAkFO8I8q9+FEbihSQIMakAgKar3eNx0vVVLsTqMrf2VPT4g5HE0cFYupBo658bgj7\/3B5eyGGgeYdt57NRdMDaD3ae4i1sbjs8tG597\/FDDE0CgKJoqqaBLjJpX+eJzesa\/mlN3c\/\/1KVPGamrYPWOV2zwYGhyPCFb2OEYmmzxe1KeSieRbc+XjeKE3r+mt7hk+z0uhPCsdPW1zWaqdIXC73uh2ywKdrWHXSyFYisZhsQZvgBAEMA6KH2Q5Qo\/194T1TO\/oIJsBQB+fC\/HRHlJ73HG+r210c689f3d2wP6mBlYYGGgeYet89koOuhFnrWbNXO0BrgrzvKhlj\/pGzfdMQ7TpYxYR6gMjAlIPUVytsbLDpwQUvYknYfL9nzZKEKYV+iZxFfNy\/As\/RBJipFaecebA\/paizhmI90eLyU3yrY93Ti3jCQJmiYJAlRVAwBEFFXpYbBS9bnTvH9+L4hb6B3iKz0Oc0bIbGDa7bpeJ+YF2RBgA6m2voMj8bEYrWcutDfDM4Ht27VRdJh5maOUwK4lxLGiaZqqaUcHY0cHY8gPa21psz67ws9xTrppEacnF7DuBgLeAS8Qz5eNEsICZ1fJBIYhajsyanBoHuw1cqmgmI10Ui4lNwoSL5jMxe2knQ5qRWN5lZd1sbSvgv3G2pPK3N+ORfGVmqYpqtYzVKA3aNiuNy3isMcZHdQTfaNgGH2AjXlYeEGWJPWUmJns\/cU29LDtfDaKDrPEAopdS06GbD96QlE1QtEU0BiajEwkO4K8taXN+mzmfU7n4VoIni8bpYUFzq6SCQxD5GKp8JhIECf9qmaedgt7HvrbbA1FF2MyF5Sc2xnksazQF2c7EuLxlT1DfEJUcqbXyRbTOivMrNRxUUF0Cj\/789H6Ktea5lPiEaO8VFfrHtGRRFIkYW+GZwJb57NRdGgNcOtX+Xa8fhxt6dYsr8iXkMLC9Cd\/PLrvSAT7YTknva\/zhLXehs8iCQUATobsCPJZaWzYDcSLcjXnEGR114FwTRmDG5lDz5edHGfDADvGdFoYhqicY3oGY66pDIzgqIAycPWl1ZxLyiHLPZ75YouS3HrFK5FG45wlTLv1xX3DHUNE3wDQP5JwOqjdB8LrV\/mwOjvGSxUc42YpPHpulrJF00ywgHQ+TdP27t37uc99rry8fK77YsMKHUF+94FwrZdF6Wz7j47pufTyopoMjAmG0L0jofjmdQ0ppTC+oySrSVkNjgoAUONlDdzL02psOJYFs8agAOdioGWxmWJsmGHHmE4LwxCN8xLnYlgHifeTjTXuvpE4ZonCXoXWAJfVHi\/dxWZ5qFe8XCw1E3qdbDGtIov7hlJSMNG3HpGJ5O1TT4oyWjgdf3UlV6B8lPmKktf5NE17\/\/33f\/7zn99yyy2XXXaZ\/pQsy7fddtvu3bvxkfXr11900UUF76ON7GDhUdKrTcNRsa1zdOWS8lsuX5KtdpJuMTMLVkO67kAkYeALzJx7GT8X9mugUh\/WjcwerGPPbS\/eQgaaG4f6J3rDcTzh7RhTMwyWLVnRDCUxAKDF79FndyGvQl4+rnRbNax4ORkyNCbmTK+TA6wVWX2AzaHecUz0rack1Fsi56Ta7\/xGaet8nZ2dv\/rVr9566y1RFM1nP\/3004MHD15zzTUsywIATdPXX389TZf2I89X6PWPvpG4QWhiKYDUJj278rEQn4NRKp0oMWhpAIDrEKCVLyEqWFEz9M38RAZxzAsy+iH2a+A4mwITaOkrOKEufdI3joyO+DLbi7dggacuWomHo2J1mYNjab3Zxo4EQMBKzKH+ieGoSBKT\/lz9p5TSq5CXu6fbHueLXmc2oC9Gsqs9vFeQ46JioCTUX2xHOecXpa0A1dfXP\/zww1u2bHn22WcNpzRNe\/755y+++OK7774bkZXbKFoY1CNkBkspApBxTl\/3HalN2e6bU4oSQze2PtsFAFi5RFxTLpYyB2WnhFkcS8okiSqm2io8DBWcMIGWi6UMuqyNBQv91EVutdVLyjeva8AHCxYJUBKaZWuAg9W+IyG+rtqFtqPoswKA8JgYYoWhUYEAYB2U2QQ4Q2QScIl0LDSSuw6Edx0Iz9VIpuT9mdaSNy\/5feYQpS3iOS7txO3v73\/++edXr169b9++c889F5n6bBQnDOpRrZfV6x96KYB8shkGJneFhZ37oyIpUCRlFnNmUWLoxnBUdNCkXj+L8lKtl0XxfOa+mbpkFMf+ClaQVPSAqKQmcmcU0mGBn1H\/UJyTtniuklh3beQFHUH+9\/uDLx8YUjWNZU7qKIbvqzD5vCUUY2rmpRuOinFBliR1NKqBRqiaKklaj8I3+TlUrTEv98UxKicriVMETiyDNEb9ORnJdG\/TtuQVGKWt81lg7969vb29vb29f\/rTnyiKuuGGG2677TaPJ3VpBBtzC4PYAoCli7gVfs4sBdCm8CQl\/amFKfXoCPIPvNQrikmWJUiKykTMGbS0hKig8Gds6ouLyplLvF+\/sE7PkpCuTXPIIMfSt1xej6RbdZmjzEmrGlg3knfgLuExRGZLzkmvXFK+pNplzl8plXXXxgzREeS3PtvVF47LsqqomiSpPSG1yc+ZTVOFyectIaYYM438YCQBTnosmQQAIDQSSA1UMakNjCTyeF8kD3GsC0OTtV7WUMKbF+SeEC8mlfFYcnlDWbmb4QX5F7uP+bwsFHAXZ\/E2M7fk2fvPmWPe6nxXX331pZde2tbW9sQTTxw8ePCJJ544duzY9u3bbbWvCIGKBWHVCgC6h\/gfrz\/N\/EmjTeHv9wffODwCUwHRKe1kOSwYBi0NpbzhjbusaJUexpolQY+UPos591PgZ8S0\/gi4e\/qLO4K8IZwRUg2jLYjnB3a1h1HUBMOQiqgAgCyrUV4y26UKk89bQkwx5gGJi4okq4p6siYuKo9LkkQeU\/WRPLx9ZweqKomj4tBHuqs9jNRBYcqo3z0YQ3R3DE1SFAGWu7j8ftczf5v2\/jMvmLc6X3l5eXl5+bXXXnvNNdc8\/\/zzd91119tvv\/3CCy987Wtfm\/a3bW1tAOD3+\/1+\/+z31AZ88TPlL38Y1qZqhjMUsajCsffjcFNlwHxxUyV151UN166ufK49PJZQAOCLp5c1VVKCcEqts08GxtUpoCOHjo8JQo11Nz4ZOFmWbdki51hcURUFdYwiIVDBep1guFE6NFVSt3whYN3JwgM\/o4shGmqcSUn2eVmOhS+eXiZJ0r27Ph3hkwBw09oAADzwUu+xYAz9sHeIb\/S53Q7SMIxdYeGBl3rxv7\/cffSH\/7Ck2efUX\/D8BxHcrP5U5giFQqFQaGBgIJdntpEZcNQESRJOlpIklSAJliEtGDcQDJuufOkKJcQUYx6Q8mUVH\/VERVFBap+qzVZefGuAw7RWGLiEN1LiKZJA3VBULTSaoKlT6m+l7EmGClbm73rmb7OE7L7FjHmr82EQBLF+\/XpJkrZs2fLWW29dd91106buPvjggwCwcePGG2+8sSB9XOjwApSxmiIE8ic9AAAgAElEQVRPZjmUu0ga5IO9o8FlVj+5cTXWHoRgMGi4IMBpx0bEZDIJACRJAoBIUebLDG3esNr12pH4mKAAwBea3ZVu6r\/bx\/uHBQCo5KhoLH7vc52bL6w4rTptabWsOgkAxyISvuN1Z5Vl2HLO0D+jyw1faC47Z7ETAI5FJu597ji+7N7nJjiWFEWVpUFITi5XkWiCKqcNw7hzf1QUk\/pbvPj3Ps\/ZZfjpHntnTN9s5qOHW3jtSPzt9z4I9vfLn75iZ2PNHlb4OVS2AQBIkmBZiqHJlroys2HbIgYrj8aYEuLpMA9ITRmz9VmBT8jKlI2NogjOxaRkJJkhLEp4o9ri2HALAJKkulhaHxKj7wnW4Q72Rr0cY01K1RHkH\/rrSVFg\/a5zeJt6hXJNc8XLH4b1VXehiO2+xYz5r\/MhXHjhhY2NjaOjo4IgTOve3bZtW319vW3nKyTOb1Y7QzH9EZfbEQgEAKAjyGNr2ca1Aev1A18cngBJoxwOB8uyJElWlTluWhsITGdkCgRg7cpTjrzT3yfDKTpK5xizdmUKA2QO6Ajy\/9XeD0CgL\/G\/2hO3Xl49852r9YiZnxEAnvqwz5Dn1HdCrKtkF1Ux2AWcVIhATZlhGIP8uOGHQwKDXlzKZrMaPTw+Dcs\/U7t4WfT0sz59fluGv7WRLTas9ulDLBiaXLmk3KKEYMoohTwaY0orut88IFuvbf79\/uCh\/vFYQo7GJJoiFp3K4ZIvpCsRtGG17+UPwwlRQYZbTQOGJmVFTUeMotfXo7wU5SU9f5NZwXoum3ed1dtEuUQogAepp28fHsFnMduAxZjYSIeFMmplZWWBQICm6Ux4W+rr6y+44IIC9MoGxjXn+s27QKfTqd9K8oJ8286jrQ1lHEun9CPoL3Y6aFnRyhxEeZmTIqkNq3xnNmYUh2dAdyRJUtSpRySnMz+89q8cDhoa\/3tf4uyl1TNp07D5fuivwUwMLebHJAmCpCiPi1qyiMPhjNecEzAM4+n15XobAy\/Ih4\/HfvJcHwBsuqg+q9EzbOs7g\/zej0fiohKocnJut8vtBgCy9jOZDIKNHNAa4JCa8snghCSrtV72+gvqslWz8huEN+fxrzNBa4C757rl6G+D+TO\/NkukTj289\/jRwRicWiLol9ef\/qOdn8QFWZZVmiZZB\/lPFzT8rTuasid6fR3leFnzN\/WYvm7rd53h20RjhcikAKAvHEehh\/qiHSnDTG1kgoWi8ymKkkgkzj77bAt6FxtziHS7QCyGcG7asRBfV+1K6Ucw2BjcDrK5lvqX\/710JirarAYVzUaUem6GFvNjnubnELMMykNMmeQBp7pseEFGhLSRWBIA9IucAeYwIP2iyAvy24dHGn3uKC\/Bqdt6srwhXZs2MoRFDJZeTckN6b6XeZnok3Iap3zM2bZZtga4gJddXneKC2tf54nN6xr+7Zrmn\/+pS2Y0AKjwOP7WHdUXtNX3RP\/iUI4X5iJNqaQu87m6I0nIN5AE0xNyJRKyw0EBAE6nSxlmaiMTLBSdr6OjIxgM3nXXXXPdERtpkXIXiMUQ5mHGYsisypgXm55RaYa9mtWgovoK574jEUOQygyRmx6Z7jGnXaX0i9lgJGFwG1V7HEj\/0zebMuQLV1gZjorRiaSiaqMTSZYhx2OSqmk9Ib7Jb8v3PCC\/yY+Y\/i0cFX1elmPpNc0V+hlo8cZLfcE2P9T6Vb7dB8L6I\/rHnG2bpZnxysmQmwH+dixqqAKiL2irh15fR3wFiqpVexyQ5vP\/0lnVepdCvmQj6kNK4npceLfa48iQP8GGASWv82mahhMzMd59992bbrrJ4\/H84he\/uPTSS3t6erZu3bp58+bVq1fPSSdt5AwshjLhYZ4Nm9zsbdA7gnxnKIafqyfEl3OMkyFvf7ozj9mOvCAPRhK3P90JlvaVdI+ZySqFF7PNjx0yn8XNhsaE0Jiw482BlOHhR0I8NuWiFSs8KjA0ifINxaTSF46XayfkT18BuMx8FxsZwmwG\/p\/3hiRZRf7c+mpX5tWrMf0bemsDI4lGnzsSS5rNSPe9YLT4zoOMS\/NI\/ufePkTqCVNbuLw\/poW51Mx4dah3vCPIT7sJxG2GxoSkrOIPEzlPLfo\/S7IRSTA9mZSTpSmKwHknxZzNU\/wobZ2vq6trz549r732GgA8+uijqqquWbPG4\/EsX778iiuuePnll7\/zne80Nja2tLT89Kc\/Pffcc+0ibCUHbH9C2z4LEmYwGasq3NSXWl0z78MsbdB3tYcx+d9EXBJFRZJVUVIDVc58ZTuana0WzebwmIYVKKXOjUs\/oV5FYsmU4eEr\/NzLH04uoohaAgGRhpAUwdAkTIwT4\/1Z9dCGAYYXxAvynr8HsWAMj4lbJ5Jbr23OZO4hpUdfCBH54v\/8tyED328JMe1lDoNdTVE0PiG5pqY0CkiY4WOay39bmEtRxgY+i0Tlvs4T1jthvbWSocmkrJa7aIYiITMdbjZkI5JgWDaWuej6ate61qqe4URJZPMUOUpb52tubr711ltvvfVWw\/GamhrEt2Kj1IG3kk6GPNQ7jl2HKbd6hn3nF08vO61sjvnwLIAEMXqcsfEkQRCqquEauHnJdjQ7W\/NoeEjp2zL79dDf+rhMSVJlRUXuWty3Dat9f35v0k\/EMKSaVEAjFVVzkISHY5DVZCxUlZeeLxCktAkZNIDhqChJKgqWQojyUoaTxGyAH4slo7xk5vstIaa9zGGwq4mioqqaqmokOalAR3kJrPhAp4H5+yp3Gddr\/ZtCRH3YsYs+\/COh+KaL6i2iUwzWSs5Jr6z36GsrFx56CdZY486cBt9GJihtnc\/GQgDeSurXMIvwMrzvFITUlHh5wcxj0vFCOBwV9Xz9ABDlpbxkOxqcrbwgP9MWRC3PPI7e7NuKTCTT+XqwUQRl4UnypLu20ed20KSkqDveHHA6KElRSYIAgJoKdmRMVFSNocl01BI20sFAdaEv\/GCwhcuKRtOnMPTGRQXNELORyTDh0QTWx10Z1EeYUkpKiGkvE6CROdQ\/cbR\/gqZJpOSpmuZgKFk+OQIsQ87kMc3fV0f\/RF31KY4Lg5RY3eRNaWhHX+Wh\/onhqMgL8o43BwwmWHMU4BxiXqb7FA9sSVoasP4MFshHUjzEDXmJSccLYUJUKJJQNY2dWi3ipuDF3KC3ryB9i6HJTPy8mSClw27zuoaU7wj1BPkB9Wxhw1GxwuNgaBkAfBVsXzhe73MhDW9JrTsykcTaXrXHcdFnnAdy7u6CwZFg\/M2PT6G6QG50pH4ZbOG1K6reP3rCHCxrmOFbn+0CAM5JI+WgrXN05ZLyy1fW6OOuGJpUVc0QfYGUktJi2rMGHhmGJmmalCSVoglV0QiCkBXVydKoZiMA1HrZmRSuMHvhI+Mikgzp8r3S6datAQ5W+46EeKQyRmJJvQk2ZRRggV8QHhZelPVf\/fxI9ykq2DpfCcBaw5iXOXFFjrwQz+KFcDCSmCCIpKxgr1Clh8mLIUS\/BgxHRcN6PEM\/b0qHXbolDfUE6xasg0LrVneIH4slR6IiAASqnI0+t5OhcKrgSCy54\/XjvCADwJrlFStYd869XTjY1R6uaPLp1TjEsoZtQvq9U0eQ7xmOm3mYDTN8OCo6aBIA8JXHQvxuSUXpGtVljnBUrOCY\/pGEeyqz0oCUG7ZS3KzqR4Zz0TzIyLanqpogKoIoL1nkBoAoLzloYz5WynAInO9izskwbNgcNKXX480EdRa6dTqRZY4C9HLML3YfM0RkzhwW71o\/LKgSjD7Ydx6k+xQVbJ2vBGCtYRRPFcJSlOC5IV8x6WghRPoQdq9UephvrE07elkNsn4NODoYMzhJZxhgbjYqrGmuSLf9QD352Z+P9o8kYCrYiBfkE+OiIezd52Xv+1oLetLH3+rHtUT3Hx2jq0o+8L8Q8NbDqVQXFmbjdDzM206d4SgdNSmfZEhAbRpYP7JiHi7RzaqBxG5sPKlqGgCQJOFxMwxNoK8YESMLUlL\/XAZZzQvyw6\/2YnetOScj5YYNtU+RREpzqUGhv++FbiQr+kbiBl0cm2D1UYBulhqJilFeMkRkznDQrN+1fljQpNVzQc+DdJ+igq3zlQCsNYwiyYkrUQmeOfTKVn5h3p2ni1lOOcgAgNdsM9cGXgPue6E7v3H05m6\/cnCkZ4hPx1XRGuDuvnq5vv9RXvJwjKJo+iM47D3FZqbrRB77P19RzQjKFKfuyYPp1a+UPMwGIy7yV07Ll5SVD7d4NqtZwUBixzAkilIAgBovW8Exg5FE06JTou7wcxk+QKxpma+E9Bu2DAnqDLIChVWkNMHqowB7howi4n\/eG2JpYoY7eet3rY8pTCYVRdVIgoAZVSOykRa2zlcCsM56K5KcuBKV4BnCIECRt1EfajZDV2yGoYrmQd7x5kDfyEnfnAXXxgxrnKcU9wajwqsfnexeSq4Kg04wxktejtGrJvqwd\/Osjkh5YN4pNkiS9MYbb+zcuVOW5Wuuueayyy5DBcGHh4fvueee\/v7+2traoaGhO+64I8OCkGsbqTdHwUB1kW0InWG2tDaURSaSw1ERqX0WlEnmmZxuFhXJZjVbGEamssxhIJs0W1XxcxlkNSKfSnklwkw2bAZZUetl9cYz\/eevfyIDHxYvyK9+FMblPXLeyVu\/a31MIU2TsqjwCYkXZFz+J9vb2bCArfOVAKxX6yLJiStRCZ4hzIwG1R5HjYcpcEy6eZAP9kb1HjdIz7VhtsEAAHb9pEwMyspwu6s9bKDOT8lVodcJ0EqG6ynBqWHvRbKZmVV0dXXdcsst8Xj8F7\/4xYUXXoh58gYGBm666aZAIPDkk096PJ5HH31006ZNv\/71ry+7bHo+6hUB9\/kXZER1YV2EzTBbasqY+1\/sPtB1QtNAVTU4VdSka8piFpXK+zU\/mn5krjiz5uWDI\/jiao+jfFnFeEJO2ZRBVns5xssxmfQhByFvGFvOSVeXOZZUu8wiS\/9EXo7RR2TqyRcRctvJW79rfUwhdpFTJFHtcZR0uk9xwtb5SgDWHpMiyYkrFQmeG1I+Wsr6RbMK8yDHRUU6VefDXBtmGMxy1ipdtoZbA3U+ZMBVgclXU3Iumte5eZa3+8EHH9x8880VFRU7d+6srz\/54JqmPfroo319fXfddVdZWRkArF+\/fufOndu3bz\/nnHMqKyutmz0SjA9Fpo\/4nHYCGCx2HUFe1WB5QxlS0IOjwuUra9D1Fk1ZzKIi2ayaoVfy1jRXpCynph+Zzy4uMyjH6Z5rWn3Rwv+erZA3ywqOpdOJLD0floHKx2DQzW0nn+5dI1KhTwYnRqMiQRA0TaiKRtMkRVEVHIPiem3kF7bOVxqw9v0VA4lJ0UrwvGAONVrDCmQgPS5fVvFRT9QcaDUtplXpMjHcGmIcsT\/RgqtCj2w3M\/ToaFbPWMwYHBz88Y9\/PDEx8cADD+gVPgAIhUJvvPGGz+drbm5GR2pra88444y\/\/OUvH3300bp16yya1cobdn3KVFROvjsL66zFBEhptEPXc6nSci2asphFRbJZNcCg9Dz0UnftdKzmZvFrPast9EWLEchWyOcmkM1UPsMTSeufZJJVltLJ8JM\/Hv3rwWE+IbEOiiQIRYGkojmdJEkSkqzOCWXMQoCt8806Fkg2a3FK8HxhrjRawwq0+0DYUMy0pozZ+qxg5tqYtuVpVbpp1dx0MY4WhVLMyGoz8+6707ZXMvjDH\/7Q2dl50UUXfe5znzOc6ujo6OvrO\/fcc8vLy9ERmqZbW1v37Nnz+uuvW+t8VMP5hiPprLPpJoCZma\/F74nwyb91nkAFNjA5HJ4w5qbe6BiNxCRUCcYQ7qZHMWxWDTDorwlR0YfBQWaGrtYAB6t9SBjuOhCuKWPSCcPZG4GcBbKFN8D8UWceAWJutmeITwiypoEgKgxNSrJCECDL4HBQuHDcfFpEigS2zje7KJVs1rwopkUowfOFudJoU9a6MDhoUnJtTNvytCqdhTsGjcPB3qh+OZ+rGMdSxOjo6CuvvAIAPM9feeWVfX19brf7qquuuu2222prawcHBzVNI8lTovtpmgaA48ePi6LIsmy6linvYsORdDpKugmgn3KIFi44KkiyKsuqmFScLIVJntM1hao8o+wElKODry9+8397TxQbqgNVThdL5UCQXiRi31ogp5T51sGL5o86t9Q99KuEqOD6Q5qmkQQJhEaQBC69M58iwosHts43uyiJbNYikVBFjjnRaK2tcXoB\/bOvtFi8MrMon9ZymVLc66dKlJeivGRY\/gsf41iKGBgYGBgYIAhizZo13\/3udxVFefjhh\/\/jP\/5jcHBw+\/btExMTAFBVVeV0ngylQoF98XhckiQLnU+JHo+OLQUAlmXRZZKUFAQBALrCwh\/eC38yGJNkrb7KecnpFZ8MjOMfVripb5xXLQiC\/uBwVNQ0LRaXHAxJ04SS1CRZdTDkiVgy4KXR9QDwxc+U6391IpZcVOFQFQUAXAzRUOMkQSlnaQD44ullTZUU+lWRQBAEURQTiQQAdIWF8JiAIyV6h\/jqcsc4L6FnAd0oGRrpCgvPfxAZ4ZMAcNPawPMfRPBPEPZ+HG6qDMz6w2SMrrDwwEu9+N9f7j76w39YAgDmg80+579cerLnB\/vGnv8gMjwhxPn4zV\/w6N87wqHjY4IwTZlh9CungxREUFUAAEXVSAo0DVwO8rRFLgBQFQVP3VJHKBQKhUIDAwNz3REAW+ebbZRENmtJKKYLExbWuMw19XRXTmu5NKu5+qmCsnQNni8bmWBoaGhiYqK1tXXjxo0ulwsAvv3tb+\/fv3\/fvn2vv\/56yp9wXEbfo9Lfdty7+DiAv6GhvqGhwk19qdUVDAaPRaSH3hgNnZAAQFW1vqHYgU9Hq8voQAXDUAQArG10eGE8GBwPcFrP6GQIFx9PAoCqqBoFBICDBg00ktBifLJ\/RHvkrz0AcN1ZZadVMzesdr12JD4mKADAEAoNIIqTuas0QIWT+pe1qP+zWAI7N4iiODw8fCwivd2jvNcTj8UV0DRcEcdBKt88v7w7IqNHw6Okb+FYRHrsnTH8773PTcSTqtsxaaaNJ9UxXukOxQ72jqKxKtSTpcCxiIReU2dI9DhJ3EkAePHvfWNxVRQnXz3q9v\/zTIffy+Bu4ydVVTWZTG574VO9NRr9BAB++NTH1k+K5li5E2I8iIoGAAQA6yABoMpDiqIIAHjqzsY4FBhPPvnkE088Mde9mERBhTXP8w899NDmzZtra2sLed85RElks5aEYrowkdIah4x2ez8eiYuKvvJmOk09nU6freWyI8i\/\/GEYu71qvWxPiB8+ISDnV4ZxhKWLvIuviooKh8OB\/i4rK\/vsZz974MCB9vb25cuXA8Do6KggCIirDwBCoRAAuN1uhrFSGojx\/h98aXmvEojJhINlv7zKd14TBwBPfdg3LgBBkqqqJWUNgEjKIGmUDMz3vtCgnzbXf74SG3s4tybJKsOArKgAQJHA0KS\/kg2dED1uZ0IBAPiv9sStl1evXcmtXTnZwr+\/MtAZiul75XI7olD+XHt4LKEAwMa1AWQzNhzJZNBy+5UFEonEsYj09EGZJEle1CiKVFWNYUjEm1Pl9Xzz4uX4vvv6lH19vOG+T33YZ7C8CorMsjQA8KIyFE0AAEOTCYVGYzVX2+mOIP9f7f0ABADNiwIvKotrHRw7WeP7w5AajCTQ113mpkcnFAAYiWlez8lu4ydVVRUAWJat8TpHJ5L4SVEcXkIhrZ8UzTGWBZZlh8ZEB006aNJf6bx8ZfWxoTgyl+KpOw+wcePGK664oq2t7cEHH5zrvhRW59M07aOPPrr00ku\/\/vWvb9y40ZCtNi9REtmsJaGYLkykzHdDMyrKSzBFfWyIqTcgLzo9Nhbiip81XhYAKGpyox8aE\/UXz7+8pTyKr9raWo\/HgxZOjEWLFgHAxMTEkiVLGIYxnJVlGQAWL15s4dhFOHtp1XcvWGU42B1JCkmVIAh5itlHVTUhqZIU9fe+xNlLTxY9OLPR+aP1DHp9bicTGhMZikBJQmhFj\/JSXbWLpChcLXDbS\/13X70cv+VrzvWbi\/I99NeTBpuH\/hpcv8qn50BBR9JVnsXoCPKGdvIShfJ2j0KSJElRbiedEBWKIjwuBpVEq\/I4nE6n9X27I0mSovQNBqoYQVIBIDIhEASBxg1dYxjtQuKVw0HcT\/SkEwmlzO2AqRBMmiJlSQGAUERkGJIkCYIg0E92fxR95fD4Xw6OAgpzZEgEiqR+tH452oI6GKrGy3pck3sSiyfVz7EltZyeQhKLjuc\/jPi8zvkhOpqampqamua6F5MotFOmtbX1zjvvfPnll6+77jqO4\/7P\/\/k\/V1xxBQpVmZfIPPa\/AMtkuluUhGK6YGGwxt33wuSbwgTI03pXZ67TdwR5VCo3KSmaBsjzFRpNuFjabGicpfDQjiD\/3FGWWrVpxwdExZK5IXHIl\/havHhxQ0PDwMDA+Pg4tuQhNDU1LVu2rK6uTn9W07Rjx44RBLF27drcer7Cz6Hq9ThqHsO8ATCkWO5qD1eXOcJRsYJjKjnHpwqPaiXjbPH+kYS5trJe6O3XFc1DmuK2547SNIknj3XlWYxZikLpGU0iTRoTTCLTNZaE1vdNyYR3y+X1u9rDRwdjOCMBnZpDF4q+xFlckAVRwSXOoryEePjQ4yuqRsgq52bQQVyNg6aIhKj0heMNNSclDpot2W4sUzoZ7MjyAqCgOp\/H4\/nJT34CACtXrvzhD3\/Y09Pzu9\/97t577z3jjDNuvPHGdevWWbstShSZeNAKMNctblH8NCvz0m6UG7BsTbc+mdES4PQ+2cYad1Y6PZo53SEeAAiC0DSNogiSICRZrTmVugxJ+dlYmFEfxk7ESGd5JJack8Ugj+KrsrLyvPPO27lzZ1dXV11dHQBomtbZ2enxeC688EK\/33\/JJZc89dRT+OzIyMjhw4ebm5vPOuusHHreEeS7hvgT40lFmUyQJEiNczEp66eZvzWD+ELVU6wrNKBfoaZ2HQi3dY4i9Q5riglBdjlpZC3mBXlsIqko2kRcxlwwKedM3qNQOoL8n94PhcflpKLUVbswwWRSVgcjCV6Qd7w5sOmieuv7ptwz43ErHheKvsQZQRCsg5Jk1cmQHEuPTe0b0eMLoiIrmphUgqNCoMqJ3jUvyElZTQgyAETGk4vKyaqykzInL84iO7K8ACCnv2R2QBDE0qVL77777t\/+9rcnTpz49re\/vXr16i1btnR2dmqacSc675FyrhfyFq0B7varlt73tZb7vtZiXbq78EDr\/ZEQH4kl0XrfESwWMVoAdAT5+17ovv3pztuf7uwI8iv8kxIQrU8ulqr0MNUexwq\/e1d7GF+m\/\/nuA+FaL0tTBAAER4UVfndWYhTNHNdU3A9JEh4nvbzOgyrKm6+fNtdY\/zhZ9UGPvH8gWWGG4osgiJtvvrmxsfGxxx5DWbo9PT3vvffehg0bzjrrLIIgNm\/e3NjY+Mwzz0iSpGnaiy++2NfXd+utt+YQStgR5O\/4w5H2zhOqqmmaShCkBsA6qEVVTnM900y+tQ2rfQCQEBVV1URREUVFUTRekA3ql74pmiL6wnFkYUJnKZIAAFXVBofjfEKWJFVVtVhcEpMKujKlMocnf16AetgZinmcpCSr6L6ck66vdtVXu5AKiAbBuh20Z17h56o9DkO5MDRWGHPrQtmw2qfX1FkHtTTArV5Sft\/XWs5fNinzOSdd62UdDEkQgLiR+8JxMakizh1F0RB\/cjQmOWjiS589GbHXEuB6hvijg7GjgzFekCVZlRQ128\/cjiwvAAodz8fzPMdxBEFIkrR3794HHnigs7MTABYvXrxp06aJiYkbb7xx0aJFd91117nnnlvIvs0tCjDXS\/dzWsibP7N1dv0qH36VnJPGRjvr4lcpyydkCHQ7fV21uKhUexyGkCy8ntVXOPcdiWCzov6+Oduzi2H25ld81dfXP\/744\/fcc8+111575plndnV1ffvb377++usRDx8++9WvfrW2tra\/v3\/79u0XX3xxDt3+\/f5gX5BHLl2SJAA0j5tZXufxeVkwGfUz+daQivNv\/9N5bGACABiGVDWtLxyXFE1fvlnfFJo8UV5C0QjI3TkSFSVJVTVNk1SCAAJIAE2WVYeDSlmpGfIdhYJ76HaQi2sdkQkJ1XjlRRlF4+lvFIkl9f+aiY1SOnOKyoXSGuBqvSxmH9Rz4OkHdjgqsg7KV+nkBTkuyJKkEiQxOBynaZIkCZIkWJaiSfiMn71w2SRnON5YosZ7h\/gKjwMRNEIGnzk2LVszeNvICwqdt3vvvffefPPNe\/fuffjhh8PhMAC0tLT88Ic\/vPTSSymKAoDNmzf\/9re\/3bhx45133nnDDTcUsnt5QW5eyFnKojCUxipRFMN6P1dIyclsXkVwkB9GJsWvMgSanPq6apUeBoVdtwY4M4FfZyiGGc76wvFVyyrwApmz+l4MaUZ5F18NDQ2PPPJIbmczx74jEUMMn6yoPi+bsphphrOlNcCdUV8WjCTwEU3TRqIiDiHoG4kDgJ6vu9HnRt2IiwqyELtZquv4BE2Tsqw6GArlBqFr0lVqzq8KpX9YjqXK3I5qj+O+r7VsfuyQ+WJ839CYEBoTdrw5AJlJ+KJiql\/d5E35HekH9uhgDL+gPlFxOCiSIGJxSVYUJ0uRJMHQ5KIKR8\/oyWXFsLHsGeJFSe0Z4vHGz+Iz1+8DS47BuxRRaIW6u7v7C1\/4AgAQBHHOOefceeedZ599NsqKR3C5XNddd90zzzzz2GOPXXrppYFAEfFYTouczRizkUWRrjRWHm9RGBTDej9XSLkGb17XYFhFLJbqbEfPgr0ZyXQcrgRpCPwMVXerOQf+BHJWQIskzahExRdFEnq1z5zGgZH5bBkYE\/RvOSmp47Gka0q89IXjBoMNnjnoPSI\/L0kSLEMhg2YPTtwAACAASURBVBBFEZKkkhTB0KRFpeY8qlDpHjblcRyhiPqPzH4ll2SAvyPsZ3cyJCpriwcWxWsCwElHPEVUljvGYxJM2Wg5lgSQcbOG4eITsphU9JOhvXd8c5ou6feBSHQ4Gara44C5NovOV8xBPB9FUevWrXv++ef\/8Ic\/rFq1Si8xET7++ONgMDg+Pn7ixFyG7EwLc2RSDlFHqJEdbw5IslruonFECADkEPakh6EzyA+YMuikyFFUMTEFRoYBTBaXZTV6KcO5LMKVzEDSn3PSTYu45XWe5XUeQT7pJss5Hgv1oZoRVGF8bmdvyYmvs5d6VU1TVU1VNdAIgoBFVc50cyDz2bLCz+nfcjJpLFDGMqcsLnirsOXKpeUuOjgqyIq2qNqJ+0aShIdjltV5zm+puu1\/L80t7jMrpHtYi0EotrjSbGEY\/wqPQ5BUQ9QmfnzsiA9UORdVOlmWYh3U8jpPBcdUuKnrzjqZrj7tdz3Gp\/U1GVOenTQyQhdhZPn8QKHtfJWVlf\/93\/99zjnnWFzj9\/urq6vXrFnT2NhYsI5li5QmPeN2R5CfaQsiS0ZKL4C+EYYmxxMy2jXmJY035Rb2dl0y3a4D4ZLIgS2qmJgCI0P7lsVlWY3ezNmbrQ1FMzHXtQa4TeeXvfrgjk1bLrtgjhaDkhNfHUF+YFRgHVRSUlVV0zTwV7tu\/HyDhRUtw9lieJUEASxDGa5J2VRrgAt42eV1kww1Hic9HBXLXDRDk4gLZoXf\/fv9wTcOjwAAyiz+3uOHWhvKOJbOr7xCD\/tM28BgRHa5HfoephuEeRBnYhh\/BEPONXr8wUgCOeJxSq+iasgC98XTy04rO1kVzTAZVE0DAJThyzoo1kEJkqqP9dS\/xIXsxpkTFFTn4zjul7\/85bRFhFatWvX+++8Xpks5I+XqqJ++iJWAoUkLL0C6JTYvWQspv6USJUAqqpiYQiLDNdj6Mjx6WN0HAEw8phfEM1\/SNqz2bX22C7v8DMU5Slp9L0XxhVztTX4Ov5HzllV+9Ty\/xU8y\/NYMr\/LzZ9a2HRnFZxmarK92pWvqlEC6qYABFF+IBFTPEI\/C+3pCPACQJHEsxNdVu\/Iur1oD3P\/9h8ZgMBgIBPTVjdP1fH4oKNN+5ujxDZocShdDgy8Ip9TQ00+G0JjgYmmSUFCCjphUWAc1EhXxTQ0vsUjCNhYOCqrzEQRhICAtfqTLydDzWyJh6mTIWy5fos9+QlZx3JRZb0v37aU7nlWCSMpvKS\/apM2WV0hkvgZbX2ZQ97c+2wW6+E4kiPO+pOmLc2TYz6JFKYov7GrHL1rvap8hDNTNwRMCFoYt9Z5bLl8CaWSFxTRDAgrnAEmSShDgcFDxqSNzm7M\/PxSUDD\/zrHZo+nDApKz2hePsFLuTLKuLfW79xSnNiqW4DyxF2EnRVrCwiun5LREO9Y6Dzp2Bsp\/MjLV6pDPFDUdFVFlLT3WRrYnO8C0h\/rYX2ocMzWZryClRS+FCA15reVGu5hyCrB7sjerD6oejooMm9fNzX+eJnJc0fDt0l6ZFJ+fDwiHWKULMhl0qpRrXGuC2XttsTuJOKSssphnqLa4xo6iaIWBybn2p80NByfwzz2GHps\/xR1QviqohbmdEyj0cFXuG+COhuEUqmI3Zg63zWcHCKrZhte\/lD0+eRSa9fZ0ncE4lzn6CKXNgzxB\/+9Od1kXP1jRXbNvT7WapkagIU9VUkVE9BxOd3qmHboSL5+B8+DyOiY0iAX7duOxBo88d5aUoL+H3nhAVZJLBQBnBOSxp+qVdf5eU8j3bB9GrF9n+3EZKCZMusioTWJfzMSdxG36Ow0PXr\/LteP04IhNYs7wCdwMpqZgMkiIJVdMMDpOCIZ12W+oKSjrNdSYOnJQce4jqJZlUELczImUEABTyZNsL5gS2zmcFi7iH1vT8lgj6rHgU2BeochomuvnbQ4Up9WwXFEmgb3Jbqs5k+JVi4YuFKSrSat7hTdtgDiFfti+4wMCvG7MtRHkJ2U5wcV4XSxl0PoQcljT90o7vAlO1O3OW72b14qKqEouXn0Pgj06S1eoyB0ORALDC79bTaOfwUrLa8lnEqCAK31ovCwD7j46tbanEe+lte7qxAKwqd4xNSNhhUkhf6vx2aJg\/85k8b0qOveEp9Q6reqHRBE2Reg3ethcUHrbOZwWLigKQnt8SAetzez8eMZTZNhemxL96\/K1+9AcOwan2OFDKutlNExoTMvxKT6nc4HMPR0WWIc2cF5l89jnwvW3b041MPmJSfePg8KrlFeUuxlb+Zg\/4BeG4qLioBKqcfeE4jotqbSiLTFiVFsjhdjC1qYiLSlJWYcr+jU5lK99TqBddpcSLMYdIRwhgwd2dIbLa8mFZgeOeeygCKaMW3Sh30R92R+OC7GIpj5P+50saO4N84X2pC82hMZPnTcmxJysaWvgQvfNwVBznVcNSWHJZz\/MAc1Zvt\/iBKwpIsiomla7jE8eCMV6UMZXRtFxWrQHu9quW1lW7EKcRPm4tJdOdMt8OF7fBSEcWpW8WsWq11JWZCZAyYZ\/Kli1vV3sYWTr5hIzqaf7tyGjfSHyhlc0tJPDrxkVyYUoW+ypYRLN3\/QV1W69tzgtfo2F2obtgiZ+zfDerFxHJlVsPFxrSfch5KcqS+cVIVqDPH20\/ar3stj3d7T3RlN1AqmrwhCAkFZIkREkFgN0HwhtW+2aDsA1RAP7bn7q3\/XW0KywYzurHihfkniH+9\/sGZo8scM4xk7mRkmPvqtWL8MKHFp0aL2tYCm0UHrbOlxa4ogBFEWJSQZxDegbL1sy4anOQkhhmojX97cw\/T\/eVZqioZfLZZ\/jU+jaRkV+aKmGpqBry\/ZUWnWkJAb9u5DvDxrbGGvfPvtKCl0+0J5n5amqYXegueomfG3ImcLaR7kOe+ZBmteVDsiIuKgxN6jcAUqqgAphSVYejoqpqoqgkBLknxPOCPBNBkY7buSPIb3226+UPw+93jX3Yl\/h\/dxm3oHiseEHuCfFj48mx8WRb5+jWZ7vmpdo3k7mR8rfmqfKdy5YYjthBuoWH7dtNC0xz4KBJVEYGlyzCRm8DW0HK4OisciEzJFpD2N91IkM3a8pmzWF2mefwZx7ytcLPfdI3DqdWfEIeRtuwP0vQv+7qMkeZk0ZjP0uusdSTdsasFuYP56LPOA\/kq9PzGumcqjOnGsk2cRXFPaO9hx76YqwoRw0wAVZCFqYiEMSkYl25yxoWwSq\/3x9E8aaapmmq1heOv3wwon8WPFZDJwRBVAgCWAeFchEMV84PzGRutAQ4XGoZv1ADaV9oTNjfNaaPLi3RrOdSh63zpQWWmzgoCsOsrFins2UrJTPUqLLVJvXNpuzwbLBPoQTnhKigop9IdM6wTRvTYlazC827BfPtZs5qYW6BHh2d9lcLHFp5w462CcHp7g3HvRyD0ySRU3XLlUsNy\/CONwdg6iVmmGuV7dQy7CR5QR6JioEqJ1JGg6PC5StrrHn7LCp3WcMiRm3fkYjh1HufngA4WToFT78Pj54gCGAYkiSJlFeWNPQvff0qX+ahk8ci0iNt3UeHhURSGZuQqsodvCAbXmirqUgxii5FNyqhWlDzCSWv82ma9v777\/\/85z+\/5ZZbLrvsMv2p4eHhe+65p7+\/v7a2dmho6I477rjgggsybxkrQCgV0ZovwCBceEH+xe5jPi8LeFGchQV4JstqSmmYLVVHJotEa4D75fWn\/2jnJyRB8AmJYUjWQQWqnLZhf26RczJ15vl9M5\/2hhbefXcmjc1zdAT553q9rjU\/OBRxNi5SA1XOTwdirIOiKAI7VTGZlH4ZBoBte7rXr\/LNMKU3HQw7ySgvoXw4HOg5OJZEHpLQmJDUUUaj\/SGqyZbbrbOKUUPEMXqg6Ye2rNZXligM3\/LuA+EMX\/qxEemhN0aHogpBEKKoKKomK2qTn0vJ\/2VeHB9+tbeuejI2d54lRBc\/Slvn6+zs\/NWvfvXWW2+JopHuf2Bg4KabbgoEAk8++aTH43n00Uc3bdr061\/\/2qAXWgBrVE6GPNQ7bs0XYNjIInIWiiJglud0zstqOmmYeYOZr\/2fW1q+\/Vsrd7WHeyOJcFREVTVtw\/4cYia8DAstn7EkgF7opwNRgqRlWUVkGQxDlrlpvLiCTuMxv8TfvT1gUK1m+FrTGZDGptiCEHhBfvWjMCr\/ytBkUlY5F01TpCSrNEXQKAqQzXGdMpsYu0P8Pz50QJLVuCBrGmDTHSoWl7KRtSuqX\/3oFCrWdFeWHHL+lp9rD4\/xk3owCtqRZRXzQBkUa8NagwnOsr2pjbygtHW++vr6hx9+eMuWLc8++6z+uKZpjz76aF9f31133VVWVgYA69ev37lz5\/bt288555zKysoM29dzGhsKWuxIX00Ik6JhWMzpvHDX5dDIzAn6s5IX84DIdD5hJnpbXgoD2sgv0AuN6+xPiJExbopLQTC\/xJGoaND5ZhJua2FA0pPVg0lack66scaNrI8oGHEsluQr2I4gn8OM0psYeUHuHeI1DYSkAgCaBoqiMQxJaKAQRHO955bLl6Scw99YE+gMxcxl5eYB2nui+LmQ8TXDl94ZiglJVQNCllVN0zQNFALSTTbDWoOcZvoL7MDuQqK083Y5jiMMpXkAACAUCr3xxhs+n6+5uRkdqa2tPeOMMw4fPvzRRx\/lcCOc4bjpovr9R8eOhPhILImYZlEOlz5HyewITjenkWQ0t6a\/ACWdfff\/+3jzY4eu\/ve\/X\/3vf39q\/6A+E23aRlIiW8oVM2bO+2BjrjCTd5cyRy+3SWgjX0Av1K2zn8VFxZA5of\/GzS\/RzeYzytaC9ckgeWRFM8fMbLlyabmLDo4KsqJVeBx6toSsoCcZiPISRZ6MySNJwu2il\/k95ywrP6vRdcMFiwAg5RxuDXBbr22+4izf+S1V57dUbfxfDfNjP4OKfCIyMpSbkrnPuqHKJclaQlCkKV+8omiKovGCPBhJ8KKsz5I2vHEvx8xJVRUbCKWt86VDR0dHX19ffX19eXk5OkLTdGtrqyRJr7\/++kxaTifL9MLFyzE1XhYAeob4o4Oxo4MxXkz9LVnz4eF1tDvMv3s48vcjo6FRITQqbPvz0fePjWHB9PDe4xaNpENrgFu\/yodKY\/UM8Sv87mwF2bS5\/elYEmzMOWbCy5Byt5AJs6ON2QN6oV7XKRvgxhr3D646LSWt0mzzaFhXMNKTPV24osocBNYa4AJednmdR0\/3k9uMwtv1umoX4tvSw+dl7\/3K8i1fqLpwWbnFHM4Xq1FRYVd72LAroEgik5feEeQ7Q7w6xcOAXOROlmJoIjgquJ20IKkGpVn\/xr918WL9G7cDuwuM0vbtpsPg4KCmaSR5ikZL0zQAHD9+XBRFljVyB1gD2\/zbOkcNBTn0sgw7grc+24WIAADVnppIpvRNWJtbsAwajCTQH7I8KbVGxpPl7klR+GF3lCAgW\/u8RfmjDGGd5Du\/KxeVOmaSoJ0ycyhlYcB89dbGtEAvlCYUeSLo9lVVlLH11a4Nq3zpFBTzS0R8jTPJs9bDOnTEQHGVcirm3Y2wws\/1DPE4G0NVNT4u\/f3TE\/\/2J+XKZioQWHCOiyMhXl\/kEwDcLJXJS9\/VHnY7SIYmQAFNA00jHAyxeBEXF+S6UyMdU5KaAcBnF5fla6bZyBbzU+ebmJgAgKqqKqfzpA0ZBfbF43FJkqx1vra2NgDw+\/1+vx8AusLCAy\/1olMUCb1DfKPP7XZMKpSSlBSEUzjcmyqp5T5X+EQCfUhVHtrFEHs\/DjdVBgw3Wlrt+DSc0B\/Rt\/bJwDj6g49PmgkVVUM631hU7CFAklVV1fiE7Jzyy6C+lbNg6JIZf3o\/pCqnhF\/gHnaFhec\/iIzwSQC4aW2g2XdyDA2nbvlC4Ln28FhCAYAvnl7WVEnh+z61b6BniEeW\/0CV0+0gU47ArEIQBFEUE4nE9JcuMDRVUhbvLpOf\/8ulJ1+lIAjWM3nmCIVCoVBoYGAgXw3OMyAd7oE\/BNVYuMV31o1fWDatOcpM3pTHcMzMNxXpyAcyDzjOsOcbVvvae6JoK66qmphUOBdT62VHJ5KPvSP6fL6ZhziXFtDz6hOoKzmH4ZqUYzsVSECJMqDYKpRbPWIKZE+nNNvh3XOI+anzpQTHZSrFHnzwQQDYuHHjjTfeCAA790dFcbIyabkTYrzSE4zRNAEAzX72S63eYDBoaOFYKOr34vgYVRTFg72jwWXGG13YAIePn\/xOKtzUl1pduDUvo3xwPCEpGmiapgEQQAAQBKgKaAB8PAkAoqRqKiiyguNUpKT4pVbO3CUDDvYa6alQD49FpMfeGcMH731uYvOFFadVMwCpT924GmuEAr7psYj0lw+G8JW9oZi\/kjnYK5tHYFYhiuLw8DAAZGvWXQjwAqR8d7nBeibPHE8++eQTTzyRr9bmJVoD3Kbzy159cMemLZddkKX\/Me9W+axopFJqABlqjVkxB229tvn3+4OfDE4cD8fdTnpRlZNz0mjr+86n45ncEelAiH\/A52U5li7ddKVpnzfd2K7wc58MjFdw1FBU0f+8fFnFeGKesNjMY8xPnQ+Z9EZHRwVB8Hg86GAoFAIAt9vNMNOwPW3btq2+vh7b+YL8OFYaZFAIUgYAiqIAYDxJVVdXB0zf\/JlL1M5QTH\/E5XYEAkYrVyAAPp8PW86+vMp3XtNkUx1BPsiPiTIAECxLJQSFIgiHgwQAUVNZB6kBSJKqKECShMNBEwTEBUXTtPC4mrJLGfbwqQ\/7DBpS5xizdmUAACxOGfDUh32c2xGLS5I0GfQREwmX220egVkFsvD5\/X69udfGbMBiJucFGzduvOKKK9ra2tB+zEZ+MRv8O2ZNLitTollrBABzoaNs2QPuuW45AGx+7JDh1JEQ\/+1LGq31VKQDISouABgYSTT63KUbtTKtXp5ubDes9n0yMO52kItrHZEJqcxFo0CCmjIm75T+NvKO+anzLVmyhGEYVVX1B2VZBoDFixdPa\/WJkZVvRhaN9CYB+jZdVH96fTm2+UcmBIoiGZpEhFIA8Pe+xNlLqw0tnN5Q9uqhEUMtmpSax5mNzjMbU2zKXzkc9LiYJYs4FGxB02RlmYMmCQAQJTUmyDFeAgCKIjVNi8VlJ0uh+hYURT701+C0Yuiac\/3m79PpdHZHkiR1SgZfd0RCPbc4ZUB3JFnOMZGxk4afKC9ddfaiwuteLMs6nU5b5ysA0s3kvKCpqampqWmWGrcxG6FsBg0PALI1JVqE\/eGf59bzdG5ca58jLgeMjyBGutKll7N+XgsO1x\/+w5Kdb\/WIJNvk8+jDRmdYesdGATA\/db5ly5bV1dUNDAyMj48jO5+maceOHSMIYu3atda\/1cobdn3KVFROTnfEUI+LV46NJwGAJAhekFPyT4IuPcJcXChz4Gq\/ONgCJ0ju\/XgkkZBZB0WShKpqgqhomibLqsNBYY6YacVQDmE0mce7rPBzL3\/IO1lKklSUdeKgye5wHE6vymIIbNiwURDkPZTNrKKVu4xrTVaqErY54QrCP\/vz0buvXp5bzw1uzQo3tfnzDdP+ylyKc37XDbcY22af8+Y13kAgYNhO24F6xY\/5qfP5\/f5LLrnkqaee6urqqqurA4CRkZHDhw83NzefddZZ1r+lGs43HIlMJLdcufThvcePDsYIAkiKUDUNMd1blJrRq2s5wPy9hcYEJKe8HBMcSciK4mQpkiQ8biYuyARJMIizPo0maka2YTSZx2VvWO3783tBkiRYlgIApInOV8loI4+wiZ3nBPkqtI1f38HeqJdj9AKwo3\/CkNSZlUDAu27Mh9A\/ktBvyM09t5hL+h2vJCXXNjpOq5m+vBuSyagUZ+Y9L12kmxUdQf5P74eOD4+53MLNFzfaH2lpoeR1Pk3TDD5cACAIYvPmzW+99dYzzzyzZs0amqZffPHFvr6++++\/v7a21rpByrvYcORIKL55XQPii9ILnSgvIaet6fo8OErM3xvipgcAzklXljvGYxIAID1vLJaUFQ27m2cCiyCPzOOyWwPcZZ\/17TsSQd5trInasGEBm99nrjCTyt0Y+tcX5aUoL6XbFecApG+ZSxyhDbm5SBIvypGJJL47mksAYM7AaKqk9h3q+9VLfeMiwHSZv9v2dNd6WbQEoK3sPI5aSxlS+ZM\/Hn3j8IimaVUcUakk7Y+05FDaK3FXV9eePXtee+01AHj00UdVVV2zZg1y5tbX1z\/++OP33HPPV7\/61dra2v7+\/u3bt1988cXTtqlEjwOsMh\/HzlZMaMQyZErhmK27IeV+1Py9Pf5WP\/7JokqnKKk4rNBfwUYmkvjsDMWQhX3eEGFjDqnG+MaawMDYSaqOeSwZbeQLdiXfgsEsc2buldO\/PmQMi+pK657m5wTp5OY8W4GA9C1sYMNBLG90jEZiEnqQNc0Vuw9M9gFR8emVzh1vDkRiSXMGxlWfrX7m3TGWZVGwskGJMQwUksnVZY5Pjk9IimrWQecZzCGViIFL07TQCZVlWY+Lsj\/S0kJp63zNzc233nrrrbfemvJsQ0PDI488km2bSn8bwAb8L5ZNWJNDQmQ4Kk4k5F0HwjVljGHGZ+UosbBtGKTw\/q4TWJVEqqeiatUeBwCgnKn\/v707j2vqyvsHfm4WEkgCCAUJIIoIUpVSrbZW\/bmM7WMdiwtdxD5VWtEu4zhOq7ba6qsu03nawU5r+6L7Y2t1qv6mU+tGrfXnUrVVtIrWBUFBMEBkEwghCTfJ\/f1x29trgkmAhJtcPu+\/zOGSHI73nnzP3p2TZ912ybDnfGw4dJ09z2fUgHDUCz4lglHRnrYprlB81J\/K\/+9jO8O4A1i5OrDTdRTbBl77zRVdnYn8NnTAHqFbWW+ytNlpq33\/mRshSll8VLBKKWOjQ37Q+Ut5U2xksPMKjE1HKx2mGnJBTLsF9dKURDF1SHteb7AxPX9cu8lIq4PleEgDS2DHfL5ANeumJtE3glQOdRMXybEtRbahyZ4w4xzueD5Q4nnfhkMoyQ4r3\/K53Th51m22+ed8GM3WL49Vni5vDujtrPyZOL6EetqmuELxUX8q\/7\/PuVH6azvWZR3lOv5I1apWTh\/Av89rGi0MQ4wmq9liI4TY7YzJYmVnWrMdja1O6y2cV2DUN7fFR9zyPcgFMbcrKNF0SHeo3mD\/c\/nTGVt7xrxGkUHM146B2pDskY51ExfJHbxQx18tQdp74PnnsO08XbPleNXt9vD0vG\/DK3NuvMVttvnr7NjBlFK9MTYymKtWRNAv5T\/E8SXkrZUE4JqP+lPdNkpd8yT+cKgDL9MGiYSy8CIPm40hhDQZaW7WHYvbMdh5BUbwb9U4tyL4mpRij8q8XUGJpkO6Q\/UGG9M7Fywe0sCCmK8D2Eiu3Qe+3QjGkz08O9S34aOV8J0Iv9xmm\/spN5jCNQrZk8tF0C\/lP8TxJeR2G16B8ycWPupP7WKj1JP4w6Gm+vnqTZPFZvt133cioSTs0ZStFltsZPDQpPBIVZDZaie\/zX5pdwXGQ0N6bS+oNFpsujozmx4VpmBrpNsVlGg6pDtUb7AxPduDW9NoVkglidrQTi\/3QYNfKIj5OszFLiosLoLxZA9Pwfs2POzed3hK3WabKyXnfQ0u61vrW2iHxEDsl\/IfovkScr0N79iIwAtk\/ZDv6pyuNErdxh8O98Oqr0varHaT2cowDEUkhGIoCSOTUDRtt9mYazeMT4yOyxl3y6573AqMmiZLuEreSxU0dWj08ARlhNT4z4ONcpmE8GYKvrGr1M4w5TWt2gglO6TDFRRbgFy\/oExK\/feo2M791cLqaI8DF9Nrw2SjE6QP35vYie3uxTERJXAh5uswF7uocNgIxpM9PDvUOPZF88jD5rXzU+o621wpsYMp3Do7ljj6pfyH4C0HX2jnziy5KUhORMavZolw3MYf\/PuBm1StCJK20Xar1S6VUDKpRCqlFEFSNkr78Urj6JReDjOtnUNSs9ncP1IeHaaIiZDy35xhmBClrI22XdEZhg+MCA2W\/z4rUav671Gxr28vYfeiClcH\/evHqthwhT8UY4d0tN7gCtBs7sAJ3Q5fW+KYiBK4EPN1mOtdVFhsBOPhHp4eNo67YbXdbymO4Ve7T2nOuHgX2eZKSSmXnC9v5qY\/0lY7bbNX1ZtaLTauAQ1d5J\/f4l3kfGfW08HtXgkd5YfnJbiNP\/j3Azd40i9GVdtksbTZQ1Uyk8VmZ4jrmda3kxQdXFbfxr253c5Y2mwURVEUFRQkLa9pfXv2IP5bnSpt6tf7lncOxMClG+oN568t7ggrDhr83QnfuJ3hYhcVPu\/u4dkNq+1up3Pdcg4LWepaaH2j2WixyWXWMJW8yUhzZ5mIo19KWH74Ld5FohmwBk\/cLv7gao+qehN7tgd7BqadYSwURSKUbOzV7niL58HEw+mR7x34tePKZLFZrXb2+HJWq8XmUNmKZqTC1\/WG89cWbWN893HgFmI+L+Bv48I2QJVyCbvyiz20rabR0mq22mxMpCao020p51qGvx+p50O9HZ2ZR7r87ctVK\/\/YU+awtbVUQkWqO18mIGLOd+bYQcozAmYIfMw5\/uD3EoWp5BU1rXeEKeqaLAwhdjtDJORyRfOAeE1oiJzwqinnFbiefDQXcYap5PU2u0RC8S9wCOnQIPGQcynFhCu6sjs3dJFE6AyIAbv\/sK7OVHLd0NjcFiSTmGl7bn5ZUbWRENJssibGqAb3CxvYR2Om7Xdo3B\/s2K6BMbfUXEaztbym9bLeWN\/Sxm4TyH6ca2wdyv8tQgi7Qi1SHXS78GvqsGj+y04\/pfznX6WU9eutiosI\/sfMlDEp4Z14NxA39muYf2cO1IYInSm\/VkcHSwY9sqGQemlbsSe1gf\/j9xKxDcWG5jaGYRiGIUTCMIRhSFlVi1IuYZuv5LfZeOx0GnYFrodFkapVvTQl8R8zU96ePUgT8nstLE+LIgAAHShJREFU7TAXmeWtKjGwsGcvvbSt+NXtZaX1juvw2uXwtUUIUSlkbr9xwHfQz+cF7P7DVptdoZASQpqMNDsGcaz4phcXqDp0ezQZaYeayJN37sTMPOK9aR9oHEOHOHT8HD8uYF78XVG18bMTzdKwPvUtbTa5SA5CdaguVEqZVEopgmQURdntDE3b7QxDSahIVRD7ly79Y+JLW4r4K3DJb5tD8Qc3+C+fuDcy7NYPTdWq3px158tbLnHHhTufqy7KGbSu8ftc7Tbb\/\/5kiY6OTktws2633XEk8U1ECSCI+byg3UNpVErZZX1rV6aYOHCoZRp5xwp5\/s6dnobiladUlMtLAfyBKJdDOrcSQxTSJiNNCJFIKLaNLZdJzFY7N2WFbQzz68bDRQ0\/XmnkXq76uoT8doQmIWT997onhwVrtbd87vDE0Lynh7gO6Xpa4OJ8g\/10tTktwc0QTQ8Mjv0cYj4vcHEojXd7tlK1KjIsmn1+Ws1WuZTq6LpXYXva8PwD+Mjpa031rRJpWJ\/qZiIPtrJtTqEz1VXOrcSModHv7S3jalp24JW\/Q6pMSnGLw9iU2iZLbOTvK75rmyxBMgm\/5vz5ujky0rjvYjV\/bnRPC+ncaq+\/wNNBc5Sk\/0DM5wWuD6XxYs+W84xmrmrz8J0F72nD8w\/gdUXVxtomS6vZSklkVqudrRnYs24DmnMrcUxKeHwvpcPAK384ha2Hm34bBolUBxnNVv57miw2661LR0+Wmy7V6iTSXxfqimNY3Os611+AIzf8DWI+L+AfSlPbZNEEy+Iig7lOLC\/2bDnPaFbKpQ6nmLuGnjYA8dl5uiYqTGFoMXMpUgkljokTzq1E54FX\/g6pbMVoszNcxeiwl1awQuoQ89002tS3rg4SwbC41zn0F4SHSHP+T7yL6wmO3PBLiPm8gB9IJdwRwjZG+T\/1Vs+W84zmSHXQP2amdDS36GkDEJPLeqNKKdP2kpc0mGWycLlMEqKQevLlWlRt\/PLH6ktVBtpqj4sMXvhg34D4Sna9Q6pDxcietPv778Zr6g2\/9wuGh0hvKh33rxDBsLjX8b\/maLptdEJQ\/zvc7EEhyjmmgQ4xn3d0TyCFda8A4IytGWSUzWao1g6ICe+l7qVyP7BbVG1c9XUJNyOlptGyytC2KjM54L6VXU9ZcR7cuEMj514mRsovXm9u0LdSFIWTgVzr6Nlrotm5WkxwfwcSwWfjAYAf6lzNsPN0DXeIGavJSAdQTwx\/rljG0OjiauPtzvAgTpPJuCOC3tx1JThI0myyUdSviz+cd2aBzkEnhR9CzBdIMBsPAJyxNcM\/\/2+13dzs+T63l\/VGh6PAWy22QOmJcZgrtutMjcNcMU8mk7GDjyFBkj5RQfUG2mpjpBIK9aq3oJPCDyHm84j\/LD7CbDwAcJaqVc29T7N\/\/Ya5Sx8Y6dnBNgNjVNduOIZ9gcLtXDFPJpNxvVAqhVQTEkQIiVQH4Vggb0EnhR9CzOceFh8BgPhMHRZ9+loTN59PLpMM6RsaKD0xbueKeTKZbGCM6lJls9fzBhx0UvgbxHzuBdziI\/\/plQQAv5WqVa3KTObW7UaFKWaNjPXD6qLdCs3tXDFPJpNNHRbNj\/kw+Aiih5jPvcBafIReSQDwUKpWteaRAULnwlUz9XYVmtu5Yp5MJkvVql58qO+WI9cskiCpRIrBRxA9xHzuBdbio4DrlQSAnsx1M\/V2FZrbuWKpWlXG0OgNh66z53CMGhDebjWYHK2cPypMq9UqlUrv\/l0Afggxn3uBtfgosHolAaCHc91MdVGhuZ4rVlRt3HWmJipMERWmIIT8eKVxdEovtH6hh3PcfxycsQ3KgTGqSHWQ5\/sgCGVgjP\/mDQDAgetmaqcrtHZDyc69FYBooJ\/PIwG0+CiweiUBwGAwLFiwIDo6et26dVxibW3tmjVrdDpdVFTUjRs3li9fPnLkSAEz6TuuJ890ukLDiAeAM\/TziU1g9UoCwNatW48dO8ZPqaysfOKJJ5qamr744ouPPvpoypQpc+fO3b9\/v1A59Kmpw6L5L9s9Oc2TCq2o2viPPWUvbSt+aVtxUbURIx4AztDPJ0IB1CsJ0MOdP3\/+008\/5acwDPPJJ59UVFSsWLFCo9EQQjIyMrZs2ZKXl3fPPff06tXL7XsG1m5NnqzGcFuhOSwEWfV1iSZYdqWqhRDCnqKLEQ8AgpgPAEAoJpPpww8\/fOyxxzZt2sQl6vX6w4cPR0dHJycnsylRUVGDBw\/+\/vvvz507N27cONfvebm69YcLAbZbU9ebqfzZe0aztaKmNUwl10Yoa5ss5TeMmhC50Wzd8EOl\/0fAAD6FsV3wFYehFqGzA+B3vv76a7VaPWHCBH5iUVFRRUVFXFxcaGgomyKTyVJTU2maPnTokNv37JlrF\/iz92qbLISQVotNpZRFhSkoipJKKJVSVt\/SlptfhroIejLEfOAT7FDLZb2xvqUNVS2As7Kysj179vz5z38OCgrip1dVVTEMI5HcUjnLZDJCyPXr1y0Wi5v3DXMcwewJaxf4s\/f4Jwhz8R+X0hMiYIDbwdgu+AS2hgZwgabpf\/7zn48++mh8fPzNm7dEIQaDgRASERHB3yWYndjX2tpK07RCoXDxzo3l5wkZolAouMtous1sNnv\/b+hGJTXm3YX1dcY2QshTo7XJ0Y77J\/\/XoFDuFDVlkMRqtfcOD7LbbK1mKyGEsdtbTHRdcxtttZfpW+5NVHPvYDabLRaLyWTqxr8m4KHQOkSv1+v1+srKSqEzQkiPivkYhjl48ODw4cO5ERPwHWyUAODC3r175XJ5RkaGh9erVJ62l0qPbAlqeDQmPj4uPp4QEh4ifTg1uLq6upMZ9QOl9fT\/\/tTIvfyfHYac+8P7R8r514QR8uSw4P93ubXRbEuIkNYZGBmxWixWhYzQNiY4iCrXt7BX2qTU\/+wo5t7BYrHU1tYSQlxH0sCHQuuQL774YuPGjULn4ldijvmsVuvixYt37drFpWRkZIwdO1bALPUcgXVgHUB30ul0mzdvXrt2rVwud\/4p26XX0NBgNpvVajWbqNfrCSEhISHt\/grfupWLFNEDTunlBitFCJk2NPrefoHdv\/6vsxUOsUVxo3z0EK3DZVotGT3k139z\/YLhGru+ydLY0kZJGEKIXCbRRigVQRLuHdjOqpiYGJy95jkUWodkZ2dPmjTpxIkT69evFzovoo75rl69+ssvv8yYMYOtL2Qy2axZs9hpMeBr2BoaoF1Wq\/XDDz9Uq9UlJSUlJSWEkOvXr9M0rdPp9uzZExsb27dvX7lcbrfbHX6LENKnTx+3PStxcXEjR6Y\/7Ls\/oNuV1bdJpNJbU2jX0UZagjItIZz9d1G1ccFn54PkUkLIHWEKdbDc4R0UCoVSqUT40iEoNM\/169evX79+QufiV6INgBiG2b179\/jx41euXElRlNDZ6XHc7rkF0DOZzebS0tLjx48fPHiQn15QUFBQUJCZmbl48eLY2NjKysrm5ma2n49hmNLSUoqiRo8eLVCuhdTFQYNUrWpSejSGHQCIiGM+nU63e\/fuYcOGHTt2bMSIEZh20P2wNTSAM7Va\/eWXX\/JTfvnllyeffPLBBx9kz15jGGbChAn\/+te\/SkpKYmNjCSF1dXUXL15MTk5OT08XJtOC6vqgAYYdAFii3avl4MGD5eXl27dvnzNnzpAhQ1avXt3S0iJ0pgAA3KAoKicnJyEh4auvvqJpmmGYb7\/9tqKiYtGiRVFRUULnTgBdP08SJ1ICsETbzzd9+vSJEyeeOHFi48aNv\/zyy8aNG0tLS\/Py8rg50QAA\/ikuLu6zzz5bs2bN448\/HhUVpdPp8vLyxo8fL3S+BNP1QQMMOwAQEcd8oaGhoaGhmZmZM2bM2L1794oVK44ePbpnz56ZM2e6\/d0TJ04QQmJiYmJiYnyfU\/AVbCIlGn61wZXXpaWlnT171iExPj7+448\/FiQ\/ACBWoo35OBRFZWRk0DS9dOnSI0eOPPLII26X7rILqrOzs+fMmeOjXJXW0+xWUoSQR9I1DntNgVdgEynR8KsNrgAAApT4Yz7W\/fffn5CQ4LDl1e3k5ubGxcX5rp+vqNq4+bSOEIot\/82nTYsejBT9\/JKiauOO0zWNJhshJHu0thv+3mvXruXn52dnZ2u1jlt5QWDxqw2uwJ8VVRu57QLmjo1zW8\/o9fovvvgiOzvbf3bT8H8otMDVU2I+jUaj1WplMpkn+7bExcWNHDnSd5nZd7HaYbupnytMdydG+u4TBVdUbXzvwO8nAbx3oHrpHxN9HfY1NjZu27Zt2rRp2EQq0PnVBlfgt9hjvrmXufllbusZvV6\/cePGSZMm4QbzHAotcPWUmM9ms5lMprvvvtuTI4zY+Xy+c+IS7ZCSf7RisELn0w8V1o4risabt6yb3phfN22wb0MxdvqXr\/83oduIdT6fd\/XkG74T9QxqiU5AoXWCn1RfFMMwQuehO5w4cWLRokV5eXn33HOPi8t0Ot3SpUt9fStLBj0iDevDT7Gbm21nNvj0Q4Ulv\/+vDimi\/5PBF+67777c3Nz4+HihM+KPuqf68meoZ8Cf+UP1Jc6Y7\/jx40899ZRarX7jjTcmTpx47dq1P\/3pT5mZmfPmzXM7tqvT6XQ633a51dHBn51o5l5GqoOmDlbeIRfz8tIdVxTF+lva35HqoLl3i\/DeA5+Kj49HwOdCN1Rf\/gz1DPgzf6i+xBnz1dXVrV279rvvvqNpOiEhISUlJScnZ8SIEf5zCBt\/ovHUodFjUsKFzpFvOcyzYffBF\/2yFQDoTqhnAFwTZ8wHfqinhbkA0P1QzwC4gJgPAAAAQPxEe94uAAAAAHAQ8wEAAACIH2I+AAAAAPFDzAcAAAAgfoj5AAAAAMQPMR8AAACA+CHmAwAAABA\/xHwAAAAA4oeYD3oEhmEOHDjQ3Nzs\/lIAAAAxQsz3q9ra2oULF86YMeOZZ56ZNm3a8ePHhc4RdInVal20aFH\/3yQlJe3YsSMkJETofEEHMAxTUFAwbdq0\/fv3O\/wIDywfSsNDuKM64eTJk1lZWWlpaampqTNnzjx58iT\/pyi3dp08efKxxx5LTk5OTk7OysoqKyvj\/1TIQmOAYXQ63QMPPDB79uzm5ma73f7RRx\/deeed33\/\/vdD5gs4rKiqaMGHCiy++uHz58uXLl69cufLixYtCZwo64PLly\/Pnz09NTU1MTHR4GPHA8qE0PIQ7qhO+\/\/77e+65Z9WqVVu3bp06dWpiYuLw4cPPnDnD\/hTl1q6CgoIpU6bk5+frdLo33nhjwIABmZmZzc3N7E+FLTTEfIzdbn\/ttddSUlIOHTrEplRVVY0fP3769OkNDQ3C5g06x263r1u3bvXq1Xa7Xei8QCe1tLTY7fbFixc7fEPjgeVDaXgOd1RHNTc3z5o1Kz8\/n33Z1ta2ZMmSxMTEJUuW2O12lFu7WltbX3755StXrnAvs7Oz77rrrnPnzjF+cLNhbJfo9frDhw9HR0cnJyezKVFRUYMHD7548eK5c+eEzRt0jk6n2717d1NT07FjxywWi9DZgc5QqVQURTmn44HlQ2l4DndUR127di0hIeGBBx5gX8rl8mnTpsnl8srKSqPRiHJrl9VqfeaZZ5KSktiXwcHBd9xxR2hoaHh4OPGDmw0xHykqKqqoqIiLiwsNDWVTZDJZamoqTdOHDh0SNGvQSQcPHiwvL9++ffucOXOGDBmyevXqlpYWoTMF3oEHlg+l0XUow9tJTU1duXKlXC7nUsLCwpRKZUREhFKpRLm1S6PR9O\/fn3vZ0NBw9erV2bNnx8fHEz+42RDzkaqqKoZhJJJbikImkxFCrl+\/jl6iQDR9+vQjR46sW7cuLS3NZrNt3LhxwYIFCPvEAQ8sH0qj61CGtyOXy1UqFT+lqanJbDbfe++9MpkM5eaWyWTKzc2Ni4t74okn2D5mwQsNMR8xGAyEELbhwiVqNBpCSGtrK03TguUMOis0NDQuLi4zM\/Obb75Zv369RqM5evTonj17hM4XeAEeWD6URtehDD136tSpPn36TJw4kaDcXKJpevv27Q899NC2bdvy8\/Nnz55dVVVF\/KDQEPO1z6FxAwGKoqiMjIzXXnuNEHLkyBGr1Sp0jsAn8MDyoTS6DmXoTKfT7du3b\/HixXFxcbe7BuXGksvlM2bM2LdvX15eXnx8\/NmzZz\/++GOGYdq9uDsLDTHfryF2Q0OD2WzmEvV6PSEkJCSEP5UBAtT999+fkJDg8F8MAQoPLB9Ko+tQhp6gafqDDz6YPn36Qw89xKag3NxSKBSTJ0\/Ozc1Vq9UFBQU3b94UvNAQ85G+ffvK5XK73c5PZDuE+vTpo1AoBMoXeI1Go9FqtTKZrN1VexBY8MDyoTS6DmXoFsMwn332GSHk6aef5mpRlJuHBg8ePGjQIKPRaLVaBS80xHwkKSkpNja2srKSO5iLYZjS0lKKokaPHi1s3sArbDabyWRKSkrCuIMI4IHlQ2l0HcrQrb179xYUFCxbtozfEYVy85xEIunbt69KpRK80BDzkZiYmAkTJtTU1JSUlLApdXV1Fy9eTE5OTk9PFzZv4BVFRUXV1dUPP\/yw0BkBL8ADy4fS6DqUoWsHDhzYsWNHbm4uOy5JCNHpdG+99VZ0dDTKzRMNDQ0VFRWTJk1SqVSC32yI+QhFUTk5OQkJCV999RVN0wzDfPvttxUVFYsWLYqKihI6d9Bhx48fT01NHT58+P79+xmGKSsrW7VqVU5OzrBhw4TOGnQMu229QyIeWD6URofgjuqowsLC5cuX2+323NzcV1555ZVXXlm2bNns2bNTUlKkUinKzVlVVdWsWbOefPLJ4uJiQojJZPrwww\/Hjx\/\/+OOPEz+42ajbLSTpaXQ63Zo1a2pra6OionQ63dKlS8ePH4\/pX4Gorq5u7dq13333HU3TCQkJKSkpOTk5I0aMwP9mYCkpKcnPz9+wYYPBYBgxYkROTs6oUaPUajX7UzywfCgNT+CO6qiysrJ58+aVlZU5pKekpGzatImNUVBuDgwGw5IlSw4cOEAI6dev35133jl9+vRx48ZJpVLuGgELDTEfAAAAgPhhbBcAAABA\/BDzAQAAAIgfYj4AAAAA8UPMBwAAACB+iPkAAAAAxA8xHwAAAID4IeYDAAAAED\/EfAAAAADih5gPAAAAQPwQ8wEAAACIH2I+AAAAAPFDzAcAANB9Kisrly1bdvHixXZ\/WlJSMnr06OnTp9fW1vri0w8fPrxixYrm5mZfvDn4OcR8AAAA3eT8+fMLFizIysoaNGhQuxc0NzcbDIb6+nqz2eyLDIwbN2706NHPPfdcVVWVL94f\/BnFMIzQeQAAABC\/wsLCBQsWrFixYvLkyVziyZMny8vLH330US6lublZIpGo1Wrf5eSTTz45cuRIXl6eRqPx3aeAv0E\/HwAAgM8ZDIY33nhj2LBhDzzwAJdYWVn5yiuv1NXV8a8MDQ31acBHCMnKyjIajW+\/\/Tb6fXoUxHwAAAA+t3PnzsLCwpkzZ8rlcjbFYDAsX7786tWrzhe3tbXRNO27zGg0mmnTpu3atau4uNh3nwL+BjEfiIrJZPr666\/Hjh3bv3\/\/9PT0Xbt2Xbp0KSsrKy0tbd26ddXV1UJnEAAC3smTJ+fNm9e\/f\/\/+\/fuvWbOmrKzsrbfeSkpKeuaZZ06ePNnur7S0tOzZsycuLm7gwIFsislkWrNmzZkzZwghH3300dixY19\/\/XWapo8cOfL000+PGjWqqKiIEGKxWA4fPrxw4cLs7OySkpKFCxempqYmJSVlZWVVVVWVlZXNmzcvNTU1OTn5xRdfNBgM3CcWFxfPnz9\/7NixaWlpY8aM2blzp81m42cpPT3dYrFs3brVV8UE\/gcxH4hKcHBwZmbmu+++GxkZyTBMdHR0TEwMTdPLli1bsmSJVqsVOoMAEPBGjBjx9ttvjxkzhhCiUqkSEhIIIRMnTly\/fv2IESPa\/ZWKiorLly\/37t07ODiYTQkODs7NzZ00aRIh5Nlnn\/3hhx9effXV8+fPFxYW\/vTTT1wnX3Fx8bFjx\/Lz8wsLC5csWfLHP\/5x7969o0aNKigoWLBgwWuvvTZ\/\/vxdu3bddddd33zzzfbt29nfKiwsfP755+fMmfPDDz\/8+OOP8fHxL7zwwoYNG\/hZ0mq1vXr1OnHiRENDg2\/KCfwOYj4QofT09Llz57a0tOTl5b377ruxsbGPP\/640JkCAPHQaDQvvPCCRqPZunXr559\/\/t133y1fvpyL55xVVVXdvHkzNjbW9US9oUOHzpw5s3fv3lxKWlpaRkaGWq0ODg5+5513Jk+e3K9fv2effVYul1dXV69evfq+++5LTk6ePXs2IaSwsJBhGIPBsHbt2iFDhtx\/\/\/1sVh988EGGYb788kv+WEdISIhWq71x44Zer\/dCiUAgkAmdAQDvoygqKytr3759R48eLS0t3bRpEzeBBgDAK+6+++45c+bk5eX9\/e9\/z83NTUxMdHHxlStXuvhxCoVCpVKx\/w4LC1MqlfwUNpTU6\/VGo7GoqOjSpUulpaV\/+MMf2J+y2740NDTU1dXxhzskEkljY+ONGzdut3EMiAxiPhCnXr16LVu2bP78+TRN+3QqNAD0TBRFzZ079+jRo+fOnTOZTEJn53d1dXVms\/kvf\/nLc8895\/ZihmEc5vmBiGFsF0TrypUrRqOxtrb2vffeQ9gHAF5XW1tbVVXFMMwHH3xQVlbm4sru3AaP3Wy5vLzck4vlcrlSqfRxjsBfIOYDcTp\/\/vznn3\/+zjvvxMbG7tu3b+\/evULnCABEpaWl5fXXX8\/Ozp4yZUpVVdX777\/vom3Zt29fuVze2NhosVh8nbH+\/ftTFHXmzBmH09tKSkr4NaHNZjOZTGq1OiIiwtdZAj+BmA9EqKWlJTc3NzMz8+GHH37++eetVus777yj0+mEzhcAiMeWLVtomp49e\/bChQujoqJ27tzpom2ZlJQUGxvruxPV+AYMGBAbG1tSUvLVV19x47ZVVVVr166Ni4vjLrNYLA0NDQkJCfxEEDfEfCA27PK0lpaWrKwsiqKmTZs2ZsyYsrIy161wAADPFRYWbtq0adGiRRqNJiUlZd68eVar9d13362srGz3+qioqLvuuquysrKmpoafPmDAAELIoUOHLl269Oqrr5aVlVmtVrvdzjCM3W53nQe73W61Wp3T4+Pj2WW869aty87O3rZt25tvvsnWhEOGDOEuKy8vr62tHTduXFhYWEf\/fAhQ0lWrVgmdBwCvuXnz5ubNm997771hw4bdd999Go2mvr7+yJEjpaWlFy5cqK6uHjJkCM6XBIBOs1qthw4dWr16tVQqnTBhQnx8vMlkOnv27IkTJ+rq6k6dOpWUlOTccyaRSKKjo\/\/zn\/8kJCSkp6dz6Vqt9ueffz59+vSpU6f++te\/mkymLVu2HD16tK2tzWAwRERE3Lhx49NPP71w4YLZbKYoKjo6uqKiYtOmTWfPnm1pabHZbHFxcaWlpZ9++mlFRUVTU1N4eHjv3r3HjRuXkpJy9erVc+fOHT58mGGYv\/3tbxkZGRRFcR\/973\/\/u7i4+OWXX46MjOymsgOhUThrDwAAwNesVuuqVasuXLiwYcOGXr16CZuZysrKp5566rHHHps\/fz4\/EARxw9guAACAz8lkspdfflmj0WzYsEHY3haapvPy8kaMGPH0008j4OtREPMBAAB0B41G89Zbb507d27Tpk1ChX00Tb\/\/\/vsSiWTlypXYrL6nwdguAABA9zGZTJs3bx4+fPjQoUO7\/9N37twpk8kmT56MHr4eCDEfAAAAgPhhbBcAAABA\/BDzAQAAAIgfYj4AAAAA8UPMBwAAACB+iPkAAAAAxA8xHwAAAID4IeYDAAAAED\/EfAAAAADih5gPAAAAQPwQ8wEAAACIH2I+AAAAAPFDzAcAAAAgfoj5AAAAAMQPMR8AAACA+CHmAwAAABC\/\/w8vGa9xQJzZ7QAAAABJRU5ErkJggg==","width":849}
%---
%[text:image:9c28]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:dropdown:8310]
%   data: {"defaultValue":"\"Dataset 2: Nonlinear\"","itemLabels":["Select","Dataset 1: Mostly Linear","Dataset 2: Nonlinear","Dataset 3: Complex","Dataset 4: Multivariate with Interactions"],"items":["\"Select\"","\"Dataset 1: Mostly Linear\"","\"Dataset 2: Nonlinear\"","\"Dataset 3: Complex\"","\"Dataset 4:Multivariate with Interactions\""],"label":"Select a dataset.","run":"Section"}
%---
%[text:image:1960]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:button:9a2e]
%   data: {"label":"Compare Regression Models","run":"Section"}
%---
%[text:image:0a55]
%   data: {"align":"baseline","height":20,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAADUAAAAxCAYAAAB6d+FmAAAC0ElEQVR42u2aO4gTURSGs6Lugo1WW2ghgiyCr1VWbRSR9YEgKoKohcQmEDAviYhBIaVbbKEWYi22YidoobUItoqwjSui6wt119Wsj+\/onXAcJslMZpI7AxP4Sbh37pnz3TP3zJ2TyWQS9imVStvRK1G5XL5ZqVRWZpL8MUCf0G+lz+hYIoGIyDYPIEc\/i8ViLmkRGkMfWwA5WkD7EwHEutmCs+87ADl6zfHLm4MLhcIqGs7RcV0WoA1xCa3vIkL\/CTsX\/w7G2Bka5oIMjlo4M6GBmOTRABHSeirh3S0LzSYQugHHgAPEJG+l7UOXtr6LgQeqYQZdRVf6Jc5frdfriyKIkOgHQToi1+0XpxGD+ywnhc348a5bICboqLMYmx02784hgRYAOqEzjHWoSIHiABU5kG2osECMP9lqC2IFiqS0qSdAtqAM0Ey3QOhUp81iX6F6DtRvKM6xsedA\/YQKCdQgyx0PcrKeQ4WNkE4K+LhGb6usQOHQOnnOCb31+WdrNW1TQC22BoW9Ddh9i6bRfNDdNkCH1c59LW0vpc8qFDYfo\/tkvMFqtbqM3xdkffgAmseXQ44dM3ba6bcGlc1mh9yzbaK3k\/Y37YAYc9Dl47A+xhoU0dlh7A579I3qRx6lbwAd8PAxHlA4V5BF3ea8Z11Ac62e52IDhb1bZuZL+lFdRWtQpflZzj3exlZsIvVc2b7jdW8xiWSWVL2ng4\/2ofL5\/Ars\/XJdXudN9wC\/R4Ce5PurFH58RN0+FLb2et130D1VVJlCu3zasw9FFC67dwboialUnZadQcBJsg+F09ewd9tkwLFcLrckZOTjkSgi3pmkUClUCpVCpVApVAqVQqVQ0UDp6s5IHKFMeaz5doufYuYz9bf\/XXmXQaqgcZH4I34pqBd+Qluz\/LpBUF3qCEUol3LgwyQAEbFHUrDxW6OTyk7NFEsaMYNpGL9qfoH+AOOEPfJuI6OmAAAAAElFTkSuQmCC","width":22}
%---
%[control:dropdown:4419]
%   data: {"defaultValue":"\"Regression Tree\"","itemLabels":["Select","Linear Regression","Stepwise Regression","Regression Tree","Ensemble of Trees"],"items":["\"Select\"","\"Linear Regression\"","\"Stepwise Regression\"","\"Regression Tree\"","\"Ensemble of Trees\""],"label":"Select an answer.","run":"Section"}
%---
%[text:image:496f]
%   data: {"align":"baseline","height":20,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAADUAAAAxCAYAAAB6d+FmAAAC0ElEQVR42u2aO4gTURSGs6Lugo1WW2ghgiyCr1VWbRSR9YEgKoKohcQmEDAviYhBIaVbbKEWYi22YidoobUItoqwjSui6wt119Wsj+\/onXAcJslMZpI7AxP4Sbh37pnz3TP3zJ2TyWQS9imVStvRK1G5XL5ZqVRWZpL8MUCf0G+lz+hYIoGIyDYPIEc\/i8ViLmkRGkMfWwA5WkD7EwHEutmCs+87ADl6zfHLm4MLhcIqGs7RcV0WoA1xCa3vIkL\/CTsX\/w7G2Bka5oIMjlo4M6GBmOTRABHSeirh3S0LzSYQugHHgAPEJG+l7UOXtr6LgQeqYQZdRVf6Jc5frdfriyKIkOgHQToi1+0XpxGD+ywnhc348a5bICboqLMYmx02784hgRYAOqEzjHWoSIHiABU5kG2osECMP9lqC2IFiqS0qSdAtqAM0Ey3QOhUp81iX6F6DtRvKM6xsedA\/YQKCdQgyx0PcrKeQ4WNkE4K+LhGb6usQOHQOnnOCb31+WdrNW1TQC22BoW9Ddh9i6bRfNDdNkCH1c59LW0vpc8qFDYfo\/tkvMFqtbqM3xdkffgAmseXQ44dM3ba6bcGlc1mh9yzbaK3k\/Y37YAYc9Dl47A+xhoU0dlh7A579I3qRx6lbwAd8PAxHlA4V5BF3ea8Z11Ac62e52IDhb1bZuZL+lFdRWtQpflZzj3exlZsIvVc2b7jdW8xiWSWVL2ng4\/2ofL5\/Ars\/XJdXudN9wC\/R4Ce5PurFH58RN0+FLb2et130D1VVJlCu3zasw9FFC67dwboialUnZadQcBJsg+F09ewd9tkwLFcLrckZOTjkSgi3pmkUClUCpVCpVApVAqVQqVQ0UDp6s5IHKFMeaz5doufYuYz9bf\/XXmXQaqgcZH4I34pqBd+Qluz\/LpBUF3qCEUol3LgwyQAEbFHUrDxW6OTyk7NFEsaMYNpGL9qfoH+AOOEPfJuI6OmAAAAAElFTkSuQmCC","width":22}
%---
%[control:dropdown:2b4a]
%   data: {"defaultValue":"\"Ensemble of Trees\"","itemLabels":["Select","Linear Regression","Stepwise Regression","Regression Tree","Ensemble of Trees"],"items":["\"Select\"","\"Linear Regression\"","\"Stepwise Regression\"","\"Regression Tree\"","\"Ensemble of Trees\""],"label":"Select an answer.","run":"Section"}
%---
%[text:image:4a93]
%   data: {"align":"middle","height":24,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAjElEQVR42mP4\/\/8\/AwgnJiYapKamfgfS\/ynBUDMMYOYywBggiYcPH\/6nFIDMAJmFYQHIdmoBqFm4LZjrYPd\/gpoyGIPYVLeA5j6gmwUlJaVAxUlgDGKPBhFODaQG1QgIoqKtr\/6r99wlCYP0EG0BSMOWe\/9JwiA9oxaMWkBHC2ieD2iSk+lR6dOk2QIAjF+EgB\/BqfoAAAAASUVORK5CYII=","width":24}
%---
