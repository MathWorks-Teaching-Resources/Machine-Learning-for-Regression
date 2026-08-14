%[text] # Feature Engineering and Regularization
%[text] [⇦ Main Menu](file:MainMenu.m)
%[text] Feature engineering and regularization help improve regression models by refining how inputs are represented and how model complexity is controlled. In this lesson, you will transform and construct features, compare feature sets, select useful predictors, and apply Lasso and Ridge regression to improve generalization.
%[text]{"align":"center"} ![](text:image:2aea)
%[text:tableOfContents]{"heading":"Table of Contents"}
%[text] **Before you get started:**
%[text] %[text:anchor:H_BF646A47] This live script is intended to be used with the code hidden. On the **View** tab of the MATLAB toolstrip, in the **View** section, select **Hide Code**.  Alternately, select **Hide Code** using the icon ![live script code hidden icon](text:image:4e10) at the top right of the Live Editor pane.
%[text] ![Lightbulb mark](text:image:51ff) Although the code is hidden, some interactivity requires familiarity with MATLAB. If you need more instruction, consider taking [MATLAB Onramp](https://matlabacademy.mathworks.com/details/matlab-onramp/gettingstarted), a free 2 hour online tutorial that teaches the essentials of MATLAB.
%[text] %[text:anchor:H_8F8A032D] ![Warning symbol](text:image:0fb1)   For an optimal experience, follow the instructions and steps in the given sequence. Proceed to a new section only after completing the preceding one. Some sections depend on variables created in prior sections and will generate errors if run out of order.
%[text] The ![Try this icon](text:image:5af8)  and  ![Exercise icon](text:image:1c31) icons refer to two different types of interactive activities that you will find in this script. The ![Try this icon](text:image:25bf)  usually indicates an interaction where you will explore the visualization of some concept introduced in this script. The ![Exercise icon](text:image:4641) interactions are designed to challenge your understanding of those concepts and may be used for grading and completion checks by your professor.
%%
%[text] ## Why Engineer Features?
%[text] A regression model can only learn patterns that are represented by its input features. While some relationships are apparent in the original predictors, many real-world problems contain nonlinear trends, periodic behavior, or interactions that a simple linear model cannot capture directly.
%[text] Feature engineering is the overall process of improving how predictors are represented for the model. In this lesson, feature **transformation** means re-expressing one predictor with a mathematical mapping such as $x^2${"altText":"x^2"} or $\\log(x)${"altText":"log(x)"}, while feature **construction** means building a richer set of predictors from the original variables, often including transformed terms and interaction terms together.
%[text] ![Try this icon](text:image:5474) **Try**. Click **View Example Features** to see a candidate set of features over the range of $x${"altText":"x"}.
  %[control:button:210a]{"position":[1,2]}
%%\ Visualize Candidate Feature Transformations

if ~exist("x","var") || isempty(x)
    x = linspace(-1,1,400).';
end

x = x(:);

Features = GetFeatureLibrary();
Style = DefaultPlotStyle();

figure(Units="normalized",Position=[0.05 0.05 0.9 0.6])
tiledlayout(2,4,TileSpacing="compact",Padding="compact")

for k = 1:numel(Features)

    nexttile
    y = Features(k).Fcn(x);
    scatter(x,y,Style.DataMarkerSize,"filled",...
        MarkerFaceAlpha=Style.DataMarkerFaceAlpha,SeriesIndex=Style.DataSeriesIndex)
    xlabel("$x$",Interpreter=Style.Interpreter)
    ylabel(Features(k).Latex,Interpreter=Style.Interpreter)
    title(Features(k).DisplayName,Interpreter=Style.Interpreter)
    ApplyDefaultAxesStyle(Style,AxisMode="tight")

end
%[text] Better features often improve predictive performance, but they also increase model complexity. As Models become more flexible, they become more susceptible to overfitting. Later, we will explore regularization methods that help control model complexity while preserving predictive accuracy.
%[text] ![Exercise icon](text:image:9caf) **Exercise 1.** Which statement best describes the relationship among feature engineering, feature transformation, and feature construction?
%[text]     a. Feature engineering is the umbrella process, and transformation and construction are two distinct ways to engineer features.
%[text]     b. Feature transformation mainly improves features that were already engineered.
%[text]     c. Feature construction is the same as feature selection.
%[text]     d, Feature engineering refers only to interaction terms.
CheckAnswer("ExerciseFeatureHierarchy","Select")  %[control:dropdown:2af3]{"position":[40,48]}
%%
%[text] ## Feature Transformations: Building Intuition
%[text] A feature transformation is one type of feature engineering. It replaces a predictor with a mathematically transformed version of the same underlying information. The goal is not to change the regression algorithm, but to provide the algorithm with a representation that better reflects the underlying relationship.
%[text] Before comparing many possible transformations, it is useful to develop intuition by looking at the data. Often, the shape of a scatter plot suggests an appropriate transformation. For example:
%[text] - Curved trends may benefit from polynomial features.
%[text] - Exponential growth may require an exponential basis such as $e^{cx}${"altText":"exp(c\*x)"}. If you transform the response instead, taking $\\log(y)${"altText":"log(y)"} can also linearize the relationship.
%[text] - Periodic behavior may be represented using sine or cosine functions with a period that matches the data. \
%[text] ### 1. Select a 1-D Dataset
%[text] ![Try this icon](text:image:880c) **Try**. **Select a dataset** from the dropdown menu, then click **Plot Selected Dataset** to visualize the raw pattern.
%[text] **Expected Results**
%[text] Examine the shape of the data before selecting a transformation. Curved patterns often suggest polynomial features, exponential patterns may call for an exponential basis or a transformed response, and repeating patterns may require sine or cosine features with an appropriate period. The goal is to choose a representation that makes the relationship easier for a regression model to learn.
DatasetChoice = "Cubic trend"; %[control:dropdown:a001]{"position":[17,30]}
  %[control:button:a002]{"position":[1,2]}
[x,y,datasetLabel] = MakeManualDataset(DatasetChoice);
Style = DefaultPlotStyle();
figure
scatter(x,y,Style.DataMarkerSize,"filled",...
    MarkerFaceAlpha=Style.DataMarkerFaceAlpha,SeriesIndex=Style.DataSeriesIndex)
xlabel("x",Interpreter=Style.Interpreter)
ylabel("y",Interpreter=Style.Interpreter)
title("Selected Dataset: " + datasetLabel,Interpreter=Style.Interpreter)
ApplyDefaultAxesStyle(Style,AxisMode="padded")
%[text] ![MATLAB Icon](text:image:5753) **Pro-tip**. Use the visual pattern to guess which transformation may produce a more linear relationship.
%%
%[text] ### 2. Test a Candidate Transformation
%[text] ![Try this icon](text:image:9c8f) **Try**. Choose a transformation from the **Select a feature vector** dropdown menu. If you choose sine or cosine, set the period with the **Select a period** dropdown menu. Then click **Test Selected Transformation** to compare the raw and transformed fits.
Features = GetFeatureLibrary();
FeatureItems = string({Features.DisplayName});
Periods = GetPeriodLibrary();
PeriodItems = string({Periods.Label});
SelectedFeatureChoice = FeatureItems(6); %[control:dropdown:a003]{"position":[25,40]}
SelectedPeriodChoice = PeriodItems(2); %[control:dropdown:8575]{"position":[24,38]}

  %[control:button:a004]{"position":[1,2]}
if exist("DatasetChoice","var")
    [x,y,~] = MakeManualDataset(DatasetChoice);
    SelectedFeature = GetSelectedFeatureSpec(SelectedFeatureChoice,SelectedPeriodChoice);
    [~,~,summary] = TestFeature(x,y,SelectedFeature,PlotRaw=false,ShowStats=false);
    disp("Selected transformation: " + SelectedFeature.DisplayName)
    disp("Model comparison for the selected transformation:")
    disp(summary)

else

    warning("Select a dataset above.")
    return

end
%[text] **Reflect.** Does the transformation make the relationship more linear? Do the residuals look less structured after the transformation?
%[text] ![Exercise icon](text:image:8caf) **Exercise 2.** What makes feature transformation different from feature construction in this lesson?
%[text]     a. Transformation and construction both mean selecting a smaller subset of predictors.
%[text]     b. Transformation re-expresses one predictor, while construction builds a broader feature set from the original variables.
%[text]     c. Construction replaces one predictor, while transformation combines several predictors.
%[text]     d. There is no meaningful difference between them in this lesson.
CheckAnswer("ExerciseTransformVsConstruct","Select")  %[control:dropdown:58ad]{"position":[44,52]}
%%
%[text] ## Comparing Feature Transformations
%[text] Visual inspection helps generate hypotheses, but selecting the best transformation requires objective evaluation. In this section, several candidate transformations are compared using cross-validation to determine which representation is most likely to generalize to new data.
%[text] ### 1. Select a Dataset
%[text] ![Try this icon](text:image:2800) **Try**. Choose a nonlinear dataset from the **Select a dataset** dropdown menu and click **Plot Dataset** to inspect its raw pattern.
DatasetChoiceCV = "Sinusoidal pattern"; %[control:dropdown:a005]{"position":[19,39]}
  %[control:button:a006]{"position":[1,2]}
[x,y,cvLabel] = MakeCVDataset(DatasetChoiceCV);
Style = DefaultPlotStyle();
figure
scatter(x,y,Style.DataMarkerSize,"filled",...
    MarkerFaceAlpha=Style.DataMarkerFaceAlpha,SeriesIndex=Style.DataSeriesIndex)
xlabel("x",Interpreter=Style.Interpreter)
ylabel("y",Interpreter=Style.Interpreter)
title("Selected Dataset: " + cvLabel,Interpreter=Style.Interpreter)
ApplyDefaultAxesStyle(Style,AxisMode="padded")
%%
%[text] ### 2. Evaluate Candidate Transformations
%[text] A model with the lowest training error is not necessarily the best model. Cross-validation estimates how well each transformation is expected to perform on unseen data and provides a more reliable basis for comparison.
%[text] Include candidates that reflect the patterns seen in the data. Over a limited input range, a polynomial can sometimes mimic exponential or periodic behavior well enough to score competitively, but that does not make it the best representation outside the observed range.
%[text] ![Try this icon](text:image:5632) **Try**. Click **Evaluate Models** to fit the candidate transformations and compare training and cross-validated performance.
  %[control:button:a007]{"position":[1,2]}
%%\ Evaluate Candidate Transformations
if exist("DatasetChoiceCV","var")

[x,y,~] = MakeCVDataset(DatasetChoiceCV);

TransformAnalysis = EvaluateTransformLibrary(x,y);
Results = TransformAnalysis.Results;
Style = DefaultPlotStyle();

figure
b = bar([Results.MSE Results.MSECV],"grouped");
b(1).SeriesIndex = Style.DataSeriesIndex;
b(2).SeriesIndex = Style.FitSeriesIndex;

xticklabels(Results.Transform)
xtickangle(25)

ylabel("MSE",Interpreter=Style.Interpreter)
title("Transformation Comparison: Training Versus Validation Error",Interpreter=Style.Interpreter)
legend("Training MSE","Cross-Validated MSE",Location="northwest",Interpreter=Style.Interpreter)

% Use TeX so labels like x^2 render without LaTeX math wrappers.
ax = gca;
ax.TickLabelInterpreter = "tex";
ApplyDefaultAxesStyle(Style)

disp("Transformation ranking by cross-validated MSE:")
disp(Results)
else
    warning("Select a dataset from above.")
    return
end
%%
%[text] ### 3. Visualize the Best Transformation
%[text] After identifying the best transformation numerically, examine it graphically in both the original and transformed feature spaces.
%[text] ![Try this icon](text:image:0ec3) **Try**. Click **Visualize Best Transformation** to visualize the best-performing transformation in the original space, transformed space, and residual plots.
  %[control:button:a008]{"position":[1,2]}
[x,y,~] = MakeCVDataset(DatasetChoiceCV);
TransformAnalysis = EvaluateTransformLibrary(x,y);
Style = DefaultPlotStyle();
xBest = TransformAnalysis.BestFcn(x);
valid = isfinite(xBest) & isfinite(y);
xRaw = x(valid);
yBest = y(valid);
xBest = xBest(valid);
mdlRaw = fitlm(xRaw,yBest);
[xSorted,~] = sort(xRaw);
yPredRaw = predict(mdlRaw,xSorted);
[xBestSorted,~] = sort(xBest);
yPredBest = predict(TransformAnalysis.BestModel,xBestSorted);


figure(Units="normalized",Position=[0.05 0.05 0.9 0.6])
tiledlayout(2,2)
sgtitle("Feature Transformation Diagnostics",FontWeight="bold",Interpreter=Style.Interpreter)
nexttile
scatter(xRaw,yBest,Style.DataMarkerSize,"filled",...
    MarkerFaceAlpha=Style.DataMarkerFaceAlpha,SeriesIndex=Style.DataSeriesIndex)
hold on
plot(xSorted,yPredRaw,LineWidth=2,SeriesIndex=Style.FitSeriesIndex)
hold off
title("Original Space",Interpreter=Style.Interpreter)
xlabel("x",Interpreter=Style.Interpreter)
ylabel("y",Interpreter=Style.Interpreter)
ApplyDefaultAxesStyle(Style,AxisMode="padded")

nexttile
PlotResiduals(mdlRaw,"Original")

nexttile
scatter(xBest,yBest,Style.DataMarkerSize,"filled",...
    MarkerFaceAlpha=Style.DataMarkerFaceAlpha,SeriesIndex=Style.DataSeriesIndex)
hold on
plot(xBestSorted,yPredBest,LineWidth=2,SeriesIndex=Style.FitSeriesIndex)
hold off
BestLatex = string(TransformAnalysis.BestLatex);

title("Transformed Space: " + BestLatex,Interpreter="latex")
xlabel("Transformed Feature",Interpreter=Style.Interpreter)
ylabel("y",Interpreter=Style.Interpreter)
ApplyDefaultAxesStyle(Style,AxisMode="padded")
nexttile
PlotResiduals(TransformAnalysis.BestModel,"Best")
disp("Best transformation by validation RMSE: " + TransformAnalysis.BestName)
%%
%[text] ## From Transformations to Rich Feature Sets
%[text] Thus far, each example has transformed a single predictor at a time. In many machine learning applications, however, feature engineering moves beyond one transformed predictor and into **feature construction**, where multiple engineered features are created simultaneously.
%[text] Rather than searching for one ideal transformation, we construct a richer feature set that captures different aspects of the underlying relationship. Some engineered features are single-predictor transformations, while others combine predictors or encode additional structure. Common engineered features include
%[text] - polynomial terms for nonlinear trends,
%[text] - trigonometric functions for periodic behavior,
%[text] - interaction terms that describe combined effects, and
%[text] - logarithmic or square-root transformations for scaling. \
%[text] The challenge is no longer finding one good transformation, but it is identifying the combination of engineered features that provides the best balance between predictive performance and generalization.
%[text] ![Exercise icon](text:image:9ff5) **Exercise 3.** Is it correct to say that a feature transformation mainly improves an already engineered feature?
%[text]     a. Yes. A transformation usually comes after feature engineering and improves an already engineered feature.
%[text]     b. No. A transformed feature is itself an engineered feature, while construction is the broader step of assembling multiple engineered predictors.
%[text]     c. Yes. Transformation is only useful after feature selection.
%[text]     d. No. Transformation and construction are unrelated ideas.
CheckAnswer("ExerciseTrasnsformMiconception","Select") %[control:dropdown:51b5]{"position":[46,54]}
%%
%[text] ### Problem Setup: Observed Predictors, Hidden Response Structure
%[text] Feature construction is most useful when the raw predictors do not expose the full relationship between the inputs and the response. In this example, both $x${"altText":"x"} and $z${"altText":"z"} are observed predictors. The word *hidden* refers to the nonlinear structure in the response, not to a missing predictor.
%[text] ![MATLAB Icon](text:image:5a72) **Pro-tip**. To keep the visualization 2-D, the data is split into low, medium, and high bands of $z${"altText":"z"}. This makes it easier to see how the relationship between $x${"altText":"x"} and $y${"altText":"y"} changes as $z${"altText":"z"} changes.
%[text] ![Try this icon](text:image:321b) **Try**. Click **Generate Data with Hidden Structure** to generate the dataset and inspect the observed relationship.
  %[control:button:9b34]{"position":[1,2]}
Traw = MakeConstructionDataset();
Style = DefaultPlotStyle();
PredictionSlices = MakePredictionSlices(Traw);

figure(Units="normalized",Position=[0.05 0.05 0.95 0.45])
PlotObservedSlices(Traw,PredictionSlices,"Observed Data by $z$ Band",Style)
%%
%[text] ### Baseline Model with Raw Features
%[text] The baseline model uses only the original predictors $x${"altText":"x"} and $z${"altText":"z"}. This gives you a reference point before any new predictors are added.
%[text] ![Try this icon](text:image:10e3) **Try**. Click **Run Baseline Model (Raw Features)** to fit the raw-feature regression model and compare representative $z${"altText":"z"} slices of that model.
  %[control:button:97db]{"position":[1,2]}
Traw = MakeConstructionDataset();
Style = DefaultPlotStyle();
PredictionSlices = MakePredictionSlices(Traw);
mdlRaw = fitlm(Traw,"y ~ x + z");
BaselineCurves = PredictModelSlices(mdlRaw,PredictionSlices);
disp(mdlRaw)
PredictionSets = struct( ...
    "Label","Baseline: $y \sim x + z$", ...
    "LineStyle","-", ...
    "SeriesIndex",Style.FitSeriesIndex, ...
    "YValues",{BaselineCurves});
figure(Units="normalized",Position=[0.05 0.05 0.95 0.45])
PlotSlicePredictions(Traw,PredictionSlices,PredictionSets, ...
    "Baseline Model Across Representative $z$ Slices",Style)
%[text] ![MATLAB Icon](text:image:97ec) **Pro-tip**. Use these three baseline slices as the benchmark for the engineered models that follow.
%%
%[text] ### Create Engineered Features
%[text] Feature construction expands the design matrix with new columns that encode patterns the raw inputs do not express directly. In this example, some new columns are transformed versions of one predictor, such as $x^2${"altText":"x^2"}, $x^3${"altText":"x^3"}, $\\sin(x)${"altText":"sin(x)"}, $\\cos(x)${"altText":"cos(x)"}, $\\log(x)${"altText":"log(x)"}, and $\\sqrt{x}${"altText":"sqrt(x)"}. The interaction term $x\_z${"altText":"x\_z"} is different: it is a constructed combination feature that uses both original predictors together.
%[text] ![Try this icon](text:image:0f62) **Try**. Click **Create Engineered Features** to create the engineered feature table and inspect the new predictors.
  %[control:button:7428]{"position":[1,2]}
Traw = MakeConstructionDataset();
T = AddEngineeredFeatures(Traw);
disp("First rows of the engineered dataset:")
disp(head(T))
disp("The new columns create alternative representations of the original predictors without changing the regression algorithm.")
%%
%[text] ### Compare Candidate Feature Sets
%[text] Instead of guessing the best engineered model by eye, compare several candidate feature sets using a train-validation split. Training error measures how well the model fits what it has seen; validation error measures whether that improvement generalizes.
%[text] ![Try this icon](text:image:8b32) **Try**. Click **Compare Feature Sets** to compare the candidate feature sets and rank them by validation MSE.
  %[control:button:76b7]{"position":[1,2]}
Analysis = AnalyzeConstructionModels();
Style = DefaultPlotStyle();
figure
b = bar([Analysis.TrainMSE Analysis.ValMSE]);
b(1).SeriesIndex = Style.DataSeriesIndex;
b(2).SeriesIndex = Style.FitSeriesIndex;
xticklabels(string({Analysis.FeatureSets.Name}))
xtickangle(20)
ylabel("MSE",Interpreter=Style.Interpreter)
title("Feature Set Comparison: Training Versus Validation Error",Interpreter=Style.Interpreter)
legend("Train MSE","Validation MSE",Location="best",Interpreter=Style.Interpreter)
ApplyDefaultAxesStyle(Style)
disp("Validation ranking from best to worst:")
disp(Analysis.Results)
%%
%[text] ### Visualize the Best Model
%[text] After identifying the best-performing feature set numerically, compare its predictions across the same representative slices used in the baseline plot. The best model combines low validation error with predictions that closely follow the observed pattern in the data.
%[text] ![Try this icon](text:image:25a1) **Try**. Click **Visualize Best Model** to visualize the best-performing engineered model.
  %[control:button:7985]{"position":[1,2]}
Analysis = AnalyzeConstructionModels();
Style = DefaultPlotStyle();
BestCurves = PredictModelSlices(Analysis.BestModel,Analysis.PredictionSlices);
PredictionSets = struct( ...
    "Label","Best model", ...
    "LineStyle","-", ...
    "SeriesIndex",Style.FitSeriesIndex, ...
    "YValues",{BestCurves});
figure(Units="normalized",Position=[0.05 0.05 0.95 0.45])
PlotSlicePredictions(Analysis.Traw,Analysis.PredictionSlices,PredictionSets, ...
    "Best Feature Set by Validation: " + Analysis.BestName,Style)
disp("Best feature set: " + Analysis.BestName)
disp("Best model formula: " + Analysis.BestFormula)
%%
%[text] ## From Feature Engineering to Feature Selection
%[text] The previous examples compared several predefined feature sets. In practice, however, feature engineering often produces many candidate predictors simultaneously. A model may contain polynomial terms, interaction terms, trigonometric functions, and other transformations all at once.
%[text] While a richer feature set can improve predictive performance, including every engineered feature is rarely the best strategy. Some predictors contribute little information, while others may be highly correlated or increase the risk of overfitting.
%[text] The next step is **feature selection** which is identifying the subset of engineered features that provides the best balance between model complexity and predictive performance. One classical approach is **stepwise regression**, which automatically adds or removes predictors according to a statistical criterion.
%%
%[text] ### Feature Selection with Stepwise Regression
%[text] Stepwise regression searches a candidate pool of engineered predictors by repeatedly adding or removing terms according to a selection criterion. Here, the candidate pool is the full set of engineered features. In this particular example, we begin with the following model:
%[text]{"align":"center"} $y = x + z + x^2 + x^3 + sinx + \\cos(x) + x\_z + \\log(x) + \\sqrt{x}${"altText":"y = x + z + x^2 + x^3 + sinx + \cos(x) + x\_z + \log(x) + \sqrt{x}"}
%[text] Stepwise regression can be useful for exploring candidate predictors, but it is a greedy search procedure. Because it repeatedly evaluates many Models, it can be unstable and may select different features when the data changes slightly.
%[text] For this reason, modern workflows often combine domain knowledge, validation data, and regularization methods such as Lasso rather than relying exclusively on stepwise selection.
%[text] ![Try this icon](text:image:071d) **Try**. Click **Run Stepwise Model** to evaluate the selected model on the validation split.
  %[control:button:81a1]{"position":[1,2]}
Analysis = AnalyzeConstructionModels();
CandidateFormula = "y ~ x + z + x2 + x3 + sinx + cosx + x_z + logx + sqrtx";
mdlStep = stepwiselm(Analysis.Ttr,"constant","Upper",CandidateFormula,"Criterion","aic","Verbose",0);
yhatTrStep = predict(mdlStep,Analysis.Ttr);
yhatVaStep = predict(mdlStep,Analysis.Tva);
mseTrStep = mean((Analysis.Ttr.y - yhatTrStep).^2);
mseVaStep = mean((Analysis.Tva.y - yhatVaStep).^2);
disp(mdlStep)
disp("Selected stepwise model formula:")
disp(mdlStep.Formula)
disp("Stepwise regression performance:")
disp(table(["Train"; "Validation"],[mseTrStep; mseVaStep],VariableNames=["Split","MSE"]))
%%
%[text] ## From Feature Selection to Regularization
%[text] Stepwise regression reduces model complexity by selecting a subset of engineered features. However, it does so through a sequence of discrete include-or-exclude decisions, which can make the final model sensitive to changes in the training data, particularly when predictors are highly correlated.
%[text] Regularization takes a different approach. Instead of removing predictors, it modifies the optimization objective by adding a penalty term that discourages large regression coefficients. This penalty reduces the influence of less important predictors and helps improve generalization to new data.
%[text] If we start with the linear regression optimization objective ( [$\\star${"altText":"\star"}](file:./OptimizationandGradientDescentforRegressionSoln.m:M_29e7)),
%[text]{"align":"center"} $J(\\theta\_1,\\theta\_0) = \\frac{1}{n} \\sum\_{i=1}^{n} (\\theta\_1x\_i+\\theta\_0-y\_i)^2${"altText":"J(\theta\_1,\theta\_0) = \frac{1}{n} \sum\_{i=1}^{n} (\theta\_1x\_i+\theta\_0-y\_i)^2"} ,
%[text] regularization adds a penalty term controlled by the regularization parameter, $\\lambda${"altText":"\lambda"} :
%[text]{"align":"center"} **Regularization Expression Generalized**: $J(\\theta) = \\frac{1}{n} \\sum\_{i=1}^{n} (\\hat y\_i-y\_i)^2 + \\lambda \\cdot \\text{Penalty}${"altText":"J(\theta) = \frac{1}{n} \sum\_{i=1}^{n} (\hat y\_i-y\_i)^2 + \lambda \cdot \text{Penalty}"}
%[text] As $\\lambda${"altText":"\lambda"} increases, the penalty becomes stronger, encouraging smaller coefficient values and reducing model complexity.
%[text] Ridge regression uses an L2 penalty based on the squared coefficient values: 
%[text]{"align":"center"} **Ridge Regression**: $J(\\theta) = \\frac{1}{n} \\sum\_{i=1}^{n} (\\hat y\_i-y\_i)^2 + \\lambda \\sum\_{j=1}^{p} \\theta\_j^2${"altText":"J(\theta) = \frac{1}{n} \sum\_{i=1}^{n} (\hat y\_i-y\_i)^2 + \lambda \sum\_{j=1}^{p} \theta\_j^2"},
%[text] while Lasso regression uses an L1 penalty based on the absolute coefficient values:
%[text]{"align":"center"} **Lasso Regression**: $J(\\theta) = \\frac{1}{n} \\sum\_{i=1}^{n} (\\hat y\_i-y\_i)^2 + \\lambda \\sum\_{j=1}^{p} |\\theta\_j|${"altText":"J(\theta) = \frac{1}{n} \sum\_{i=1}^{n} (\hat y\_i-y\_i)^2 + \lambda \sum\_{j=1}^{p} |\theta\_j|"}
%[text] Although both methods shrink coefficients, they do so differently. Ridge regression reduces the magnitude of all coefficients while retaining every predictor in the model, asking "How much should each feature contribute?" Lasso regression can shrink some coefficients exactly to zero, effectively performing automatic feature selection by asking "Which features should stay and which can be removed?"
%%
%[text] ### Regularization with Lasso and Ridge Regression
%[text] As we compare the coefficient paths for Lasso and Ridge, notice the differences in which features are removed or kept. Each path tracks the coefficient for a single feature. As the regularization penalty increases, Lasso repeatedly asks, "Which features are worth keeping?" Features that add little predictive value have their coefficients driven all the way to zero and are effectively removed from the model. As the regularization penalty increases, Ridge repeatedly asks, "How much should each feature contribute?" Coefficients become smaller, but features are rarely removed completely.
%[text] ![Try this icon](text:image:4d0a) **Try**. Click **Show Paths** to compare how Lasso and Ridge change feature coefficients as regularization increases.
RegularizationAnalysis = AnalyzeRegularizationModels();
Style = DefaultPlotStyle();

%%\ Visualization: paths and final Models

% Lasso coefficient paths
  %[control:button:6abb]{"position":[1,2]}
figure(Units="normalized",Position=[0.05 0.05 0.9 0.6]);
tiledlayout(1,2)
nexttile
semilogx(RegularizationAnalysis.Lasso.FitInfo.Lambda,RegularizationAnalysis.Lasso.Path',LineWidth=1.2)
xline(RegularizationAnalysis.Lasso.Lambda,"--","Chosen $\lambda$",...
    LabelOrientation="horizontal",Interpreter=Style.Interpreter)
xlabel("Regularization strength ($\lambda$)",Interpreter=Style.Interpreter)
ylabel("Feature influence (coefficient)",Interpreter=Style.Interpreter)
title("Lasso: Features are removed as regularization increases",...
    Fontweight="bold",Interpreter=Style.Interpreter)
ApplyDefaultAxesStyle(Style)

% Ridge coefficient paths
nexttile
semilogx(RegularizationAnalysis.Lambdas,RegularizationAnalysis.Ridge.Path',LineWidth=1.2)
xline(RegularizationAnalysis.Ridge.Lambda,"--","Chosen $\lambda$",...
    LabelOrientation="horizontal",Interpreter=Style.Interpreter)
xlabel("$\lambda$",Interpreter=Style.Interpreter)
ylabel("Standardized coefficient",Interpreter=Style.Interpreter)
title("Ridge: All features stay, but their influence shrinks",...
    Fontweight="bold",Interpreter=Style.Interpreter)
ApplyDefaultAxesStyle(Style)
legend(RegularizationAnalysis.FeatureNamesLatex,Interpreter=Style.Interpreter,Location="eastoutside")
%[text] ![Lightbulb Icon](text:image:40c5) **Reflect**. Which coefficients does Lasso drive completely to zero? Which coefficients remain nonzero in the Ridge model, even for large values of $\\lambda${"altText":"\lambda"}?
%%
%[text] #### Compare Models
%[text] ![Try this icon](text:image:796a) **Try**. Click **Compare Models** to compare the selected penalty values, coefficient estimates, and prediction errors for the final Lasso and Ridge Models.
  %[control:button:1dd9]{"position":[1,2]}
%%\ Results
RegularizationAnalysis = AnalyzeRegularizationModels();

disp("Final regularized model comparison:")
disp(RegularizationAnalysis.PerformanceSummary)

disp("Chosen penalty values:")
disp(table(["Lasso";"Ridge"],[RegularizationAnalysis.Lasso.Lambda;RegularizationAnalysis.Ridge.Lambda],VariableNames=["Model","Lambda"]))

disp("Final standardized coefficients:")
disp(RegularizationAnalysis.CoefficientSummary)
%[text] ![Lightbulb Icon](text:image:1327) **Reflect**. Which model achieved the lower validation MSE? Did removing features noticeably improve or reduce predictive performance?
%%
%[text] #### Compare Fits
%[text] ![Try this icon](text:image:3198) **Try**. Click **Compare Fits** to compare the final Lasso and Ridge fits across the same representative $z${"altText":"z"} slices.
%%\ Compare final fits
  %[control:button:5eae]{"position":[1,2]}
RegularizationAnalysis = AnalyzeRegularizationModels();
Style = DefaultPlotStyle();
PredictionSets = [
    struct("Label","Lasso","LineStyle","-","SeriesIndex",Style.DataSeriesIndex,...
        "YValues",{RegularizationAnalysis.Lasso.YPredictionSlices})
    struct("Label","Ridge","LineStyle","--","SeriesIndex",Style.FitSeriesIndex,...
        "YValues",{RegularizationAnalysis.Ridge.YPredictionSlices})
    ];
figure(Units="normalized",Position=[0.05 0.05 0.95 0.45])
PlotSlicePredictions( ...
    RegularizationAnalysis.ConstructionAnalysis.Ttr, ...
    RegularizationAnalysis.ConstructionAnalysis.PredictionSlices, ...
    PredictionSets, ...
    "Final Fits from Lasso and Ridge",Style)
%%
%[text] ## Summary
%[text] In this lesson, we explored how feature engineering can improve regression Models by changing how predictors are represented. We compared feature transformations using cross-validation, constructed richer feature sets using polynomial, trigonometric, and interaction terms, and evaluated their impact on model performance. Finally, you examined feature selection and regularization techniques, including stepwise regression, Lasso, and Ridge, to balance model flexibility with generalization.
%[text] **Key Takeaways**
%[text] - Feature engineering is the umbrella process; feature transformation and feature construction are two different ways to engineer predictors.
%[text] - Feature transformations can reveal relationships that are difficult to model using raw predictors alone by re-expressing one predictor.
%[text] - Feature construction builds a broader candidate feature set that can include transformed predictors and interaction terms.
%[text] - Cross-validation helps identify Models that generalize well to new data.
%[text] - Engineered features can improve predictive performance, but excessive complexity can lead to overfitting, so feature selection and regularization help control that risk.
%[text] - Lasso and Ridge regularization help control model complexity and improve generalization. \
%[text] ## Further Exploration
%[text] Review the [Additional Resources](file:../InstructorResources/AdditionalResources.m:M_0e5b) section to find more materials for further learning.
%%
%[text] [⇦ Return to Main Menu](file:MainMenu.m)
%%
%[text] ## Local Helper Functions
%[text] If you wish to see the implementation details, switch to **Output Inline** from the **View** tab.
function [x,y,label] = MakeManualDataset(datasetChoice)
rng("shuffle")
x = rand(21,1);
switch datasetChoice
    case "Periodic signal"
        y = 0.5 + 0.5*sin(2*pi*x) + 0.21*rand(size(x));
        label = "Periodic Signal";
    case "Quadratic trend"
        y = -1 + 2*x.^2 + 0.1*rand(size(x));
        label = "Quadratic Trend";
    case "Cubic trend"
        y = 0.5 + 0.8*(x.^3 + 2*x.^2 + x) + 0.2*rand(size(x));
        label = "Cubic Trend";
    case "Mixed nonlinear signal"
        y = 1 - 2*(x.^2 + sin(4*pi*x) + sin(2*pi*x)) + 0.2*rand(size(x));
        label = "Mixed Nonlinear Signal";
    otherwise
        error("Unknown manual dataset selection.")
end
end
%%
function CheckAnswer(ExerciseID,Option)
arguments
    ExerciseID (1,1) string
    Option (1,1) string
end
Exercises = struct();
Exercises.ExerciseFeatureHierarchy = struct( ...
    "Answer","a.", ...
    "Hint","Feature engineering is the umbrella idea. Transformation and construction are two different ways to engineer features.");
Exercises.ExerciseTransformVsConstruct = struct( ...
    "Answer","b.", ...
    "Hint","Transformation re-expresses one predictor. Construction builds a broader candidate feature set that may include several transformed and combined predictors.");
Exercises.ExerciseTransformMisconception = struct( ...
    "Answer","b.", ...
    "Hint","A transformed feature is already an engineered feature. Construction is the broader step of assembling multiple engineered predictors.");
ExerciseName = char(ExerciseID);
if isfield(Exercises,ExerciseName)
    CorrectAnswer = Exercises.(ExerciseName).Answer;
    HintText = Exercises.(ExerciseName).Hint;
    if Option == "Select"
        return
    elseif Option == CorrectAnswer
        disp("You are correct.")
    else
        warning("%s",HintText)
    end
end
end
%%
function [x,y,label] = MakeCVDataset(datasetChoice)
n = 100;
x = linspace(1,10,n)';
rng(0,"twister")
switch datasetChoice
    case "Exponential growth"
        y = exp(0.3*x) + randn(n,1);
        label = "Exponential Growth";
    case "Logarithmic growth"
        y = 3*log(x) + 0.5*randn(n,1);
        label = "Logarithmic Growth";
    case "Sinusoidal pattern"
        y = 0.8*sin(0.5*x) + 0.5*randn(n,1);
        label = "Sinusoidal Pattern";
    otherwise
        error("Unknown cross-validation dataset selection.")
end
end
%%
function TransformAnalysis = EvaluateTransformLibrary(x,y)
BaseTransforms = [
    struct("Name","x","Latex","$x$","Fcn",@(x) x)
    struct("Name","x^2","Latex","$x^2$","Fcn",@(x) x.^2)
    struct("Name","x^3","Latex","$x^3$","Fcn",@(x) x.^3)
    struct("Name","log(x)","Latex","$\log(x)$","Fcn",@(x) SafeLog(x))
    struct("Name","sqrt(x)","Latex","$\sqrt{x}$","Fcn",@(x) SafeSqrt(x))
    struct("Name","1/x","Latex","$1/x$","Fcn",@(x) SafeReciprocal(x))
    ];
BaseTransforms = BaseTransforms(:).';

ExpScales = [0.1 0.3 0.5];
ExpTransforms = repmat(struct("Name","","Latex","","Fcn",[]),1,numel(ExpScales));
for i = 1:numel(ExpScales)
    scale = ExpScales(i);
    ExpTransforms(i) = struct( ...
        "Name","exp(" + num2str(scale) + "*x)", ...
        "Latex","$e^{" + num2str(scale) + "x}$", ...
        "Fcn",@(x) exp(scale.*x));
end

Periods = GetPeriodLibrary();
PeriodicTransforms = repmat(struct("Name","","Latex","","Fcn",[]),1,2*numel(Periods));
for i = 1:numel(Periods)
    idx = 2*i - 1;
    period = Periods(i).Value;
    label = string(Periods(i).Label);
    latexLabel = string(Periods(i).LatexLabel);
    PeriodicTransforms(idx) = struct( ...
        "Name","sin(2*pi*x/" + label + ")", ...
        "Latex","$\sin(2\pi x / " + latexLabel + ")$", ...
        "Fcn",@(x) sin(2*pi*x./period));
    PeriodicTransforms(idx + 1) = struct( ...
        "Name","cos(2*pi*x/" + label + ")", ...
        "Latex","$\cos(2\pi x / " + latexLabel + ")$", ...
        "Fcn",@(x) cos(2*pi*x./period));
end

TransformLibrary = [BaseTransforms ExpTransforms PeriodicTransforms];

nT = numel(TransformLibrary);

Models = cell(nT,1);

Results = table(...
    Size=[nT 6],...
    VariableTypes=["string","double","double","double","double","logical"], ...
    VariableNames=["Transform","MSE","MSECV","Rsq","Index","IsBest"]);

for i = 1:nT

    TransformSpec = TransformLibrary(i);
    xT = TransformSpec.Fcn(x);

    valid = isfinite(xT) & isfinite(y);

    xT = xT(valid);
    yT = y(valid);

    mdl = fitlm(xT,yT);

    Models{i} = mdl;

    Results.Transform(i) = TransformSpec.Name;
    Results.MSE(i) = mdl.RMSE^2;
    Results.MSECV(i) = ComputeCrossValidatedMSE(xT,yT,5);
    Results.Rsq(i) = mdl.Rsquared.Ordinary;
    Results.Index(i) = i;

end

Results = sortrows(Results,"MSECV");

Results.IsBest(:) = false;
Results.IsBest(1) = true;

BestTransform = TransformLibrary(Results.Index(1));
BestModel = Models{Results.Index(1)};

TransformAnalysis = struct();
TransformAnalysis.Transforms = TransformLibrary;
TransformAnalysis.Models = Models;
TransformAnalysis.Results = Results;
TransformAnalysis.BestModel = BestModel;
TransformAnalysis.BestFcn = BestTransform.Fcn;
TransformAnalysis.BestName = BestTransform.Name;
TransformAnalysis.BestLatex = BestTransform.Latex;
end
%%
function PlotResiduals(mdl,label)
arguments
    mdl
    label (1,1) string = ""
end
Style = DefaultPlotStyle();
yhat = mdl.Fitted;
res = mdl.Residuals.Raw;
scatter(yhat,res,Style.SmallMarkerSize,"filled",...
    MarkerFaceAlpha=Style.DataMarkerFaceAlpha)
hold on
yline(0,"k--",LineWidth=1.2)
hold off
xlabel("Fitted Values",Interpreter=Style.Interpreter)
ylabel("Residuals",Interpreter=Style.Interpreter)
title("Residuals vs Fitted: " + label,Interpreter=Style.Interpreter)
ApplyDefaultAxesStyle(Style,AxisMode="padded")
end
%%
function mse = ComputeCrossValidatedMSE(x,y,K)
arguments
    x (:,1) double
    y (:,1) double
    K (1,1) double {mustBePositive,mustBeInteger}
end

rng(11,"twister")
cv = cvpartition(numel(y),"KFold",K);

mseFold = zeros(K,1);

for k = 1:K

    idxTrain = training(cv,k);
    idxTest  = test(cv,k);

    mdl = fitlm(x(idxTrain),y(idxTrain));

    yPred = predict(mdl,x(idxTest));

    mseFold(k) = mean((y(idxTest) - yPred).^2);

end

mse = mean(mseFold);

end
%%
function [mdlRaw,mdlFeat,summary] = TestFeature(x,y,Feature,opts)
%TESTFEATURE Compare regression using x versus a transformed feature.

arguments
    x (:,1) double
    y (:,1) double
    Feature (1,1) struct

    opts.LabelInterpreter (1,1) string {mustBeMember(opts.LabelInterpreter,["none","tex","latex"])} = "latex"
    opts.Alpha (1,1) double {mustBeGreaterThan(opts.Alpha,0),mustBeLessThan(opts.Alpha,1)} = 0.05
    opts.IntervalType (1,1) string {mustBeMember(opts.IntervalType,["curve","observation"])} = "curve"
    opts.MarkerSize (1,1) double {mustBePositive} = 36
    opts.PlotRaw (1,1) logical = true
    opts.PlotFeature (1,1) logical = true
    opts.ShowStats (1,1) logical = true
end
Style = DefaultPlotStyle();

%%\ Compute feature

feature = Feature.Fcn(x);
feature = double(feature(:));

%%\ Remove invalid values

mask = isfinite(x) & isfinite(y) & isfinite(feature);

x = x(mask);
y = y(mask);
feature = feature(mask);

%%\ Fit models

mdlRaw = fitlm(x,y);
mdlFeat = fitlm(feature,y);

%%\ Plot raw data

if opts.PlotRaw

    figure

    scatter(x,y,opts.MarkerSize,"filled",...
        MarkerFaceAlpha=Style.DataMarkerFaceAlpha,SeriesIndex=Style.DataSeriesIndex)

    xlabel("$x$",Interpreter=Style.Interpreter)
    ylabel("$y$",Interpreter=Style.Interpreter)

    title("Raw Data",Interpreter=Style.Interpreter)
    ApplyDefaultAxesStyle(Style,AxisMode="padded")

end

%%\ Plot transformed feature

if opts.PlotFeature

    figure

    tiledlayout(1,2,TileSpacing="compact",Padding="compact")

    %%\ Overlay

    nexttile

    scatter(x,y,opts.MarkerSize,"filled",...
        MarkerFaceAlpha=Style.DataMarkerFaceAlpha,...
        DisplayName="Data",SeriesIndex=Style.DataSeriesIndex)

    hold on

    featureScaled = rescale(feature,min(y),max(y));

    [xSorted,idx] = sort(x);

    featureInterp = interp1(xSorted,featureScaled(idx),linspace(min(x),max(x),300),"pchip");

    plot(linspace(min(x),max(x),300),featureInterp,LineWidth=2,...
        DisplayName=Feature.DisplayName,SeriesIndex=Style.FitSeriesIndex)

    hold off

    xlabel("$x$",Interpreter=Style.Interpreter)
    ylabel("$y$",Interpreter=Style.Interpreter)

    title("Feature Overlay",Interpreter=Style.Interpreter)

    legend(Location="best",Interpreter=Style.Interpreter)

    ApplyDefaultAxesStyle(Style,AxisMode="padded")

    %%\ Feature space

    nexttile

    scatter(feature,y,opts.MarkerSize,"filled",...
        MarkerFaceAlpha=Style.DataMarkerFaceAlpha,DisplayName="Data",...
        SeriesIndex=Style.DataSeriesIndex)

    hold on

    FeatureSorted = sort(feature);

    [yFit,yCI] = predict(mdlFeat,FeatureSorted,...
        Alpha=opts.Alpha,...
        Prediction=opts.IntervalType);

    fill( ...
        [FeatureSorted; flipud(FeatureSorted)],[yCI(:,1); flipud(yCI(:,2))],...
        Style.ConfidenceFillColor,...
        EdgeColor="none",...
        FaceAlpha=0.4,...
        DisplayName="Confidence Interval")

    plot(FeatureSorted,yFit,LineWidth=2,DisplayName="Linear Fit",...
        SeriesIndex=Style.FitSeriesIndex)

    hold off

    xlabel(Feature.Latex,Interpreter=opts.LabelInterpreter)

    ylabel("$y$",Interpreter=Style.Interpreter)

    title( ...
        "Linear Regression Using " + Feature.DisplayName,Interpreter=Style.Interpreter)

    legend(Location="best",Interpreter=Style.Interpreter)

    ApplyDefaultAxesStyle(Style,AxisMode="padded")

end

%%\ Summary table

summary = table( ...
    ["Raw (y ~ x)";
     "Transformed (y ~ " + Feature.SummaryName + ")"], ...
    [mdlRaw.Rsquared.Ordinary;
     mdlFeat.Rsquared.Ordinary], ...
    [mdlRaw.Rsquared.Adjusted;
     mdlFeat.Rsquared.Adjusted], ...
    [mdlRaw.RMSE;
     mdlFeat.RMSE], ...
    VariableNames=["Model","R2","AdjR2","RMSE"]);

if opts.ShowStats

    disp("Model Comparison")
    disp(summary)

end
end
%%
function Analysis = AnalyzeConstructionModels()
Traw = MakeConstructionDataset();
T = AddEngineeredFeatures(Traw);
PredictionSlices = MakePredictionSlices(Traw);
rng(19,"twister")
cv = cvpartition(height(T),"HoldOut",0.3);
idxTr = training(cv);
idxVa = test(cv);
Ttr = T(idxTr,:);
Tva = T(idxVa,:);
FeatureSets = [
    struct("Name","Raw: x + z","Formula","y ~ x + z")
    struct("Name","Polynomial: x + z + x^2 + x^3","Formula","y ~ x + z + x2 + x3")
    struct("Name","Trigonometric: x + z + sinx + cosx","Formula","y ~ x + z + sinx + cosx")
    struct("Name","Interaction: x + z + xz","Formula","y ~ x + z + x_z")
    struct("Name","Mixed: poly + trig + interaction","Formula","y ~ x + z + x2 + x3 + sinx + cosx + x_z")
    ];
nSets = numel(FeatureSets);
TrainMSE = zeros(nSets,1);
ValMSE = zeros(nSets,1);
Models = cell(nSets,1);
for i = 1:nSets
    Models{i} = fitlm(Ttr,FeatureSets(i).Formula);
    yhatTr = predict(Models{i},Ttr);
    yhatVa = predict(Models{i},Tva);
    TrainMSE(i) = mean((Ttr.y - yhatTr).^2);
    ValMSE(i) = mean((Tva.y - yhatVa).^2);
end
[~,BestIdx] = min(ValMSE);
Results = table(string({FeatureSets.Name})',TrainMSE,ValMSE,VariableNames=["FeatureSet","TrainMSE","ValidationMSE"]);
Results = sortrows(Results,"ValidationMSE");
Results.Rank = (1:height(Results))';
Results = movevars(Results,"Rank","Before","FeatureSet");
Analysis = struct;
Analysis.Traw = Traw;
Analysis.T = T;
Analysis.Ttr = Ttr;
Analysis.Tva = Tva;
Analysis.PredictionSlices = PredictionSlices;
Analysis.FeatureSets = FeatureSets;
Analysis.Models = Models;
Analysis.TrainMSE = TrainMSE;
Analysis.ValMSE = ValMSE;
Analysis.Results = Results;
Analysis.BestModel = Models{BestIdx};
Analysis.BestName = string(FeatureSets(BestIdx).Name);
Analysis.BestFormula = string(FeatureSets(BestIdx).Formula);
end
%%
function RegularizationAnalysis = AnalyzeRegularizationModels()
ConstructionAnalysis = AnalyzeConstructionModels();

FeatureNames = ["x","z","x2","x3","sinx","cosx","x_z","logx","sqrtx"];
FeatureNamesLatex = ["$x$","$z$","$x^2$","$x^3$","$\sin(x)$","$\cos(x)$","$xz$","$\log(x)$","$\sqrt{x}$"];
PredictionSlices = ConstructionAnalysis.PredictionSlices;

XTrain = ConstructionAnalysis.Ttr{:,cellstr(FeatureNames)};
XValidation = ConstructionAnalysis.Tva{:,cellstr(FeatureNames)};
YTrain = ConstructionAnalysis.Ttr.y;
YValidation = ConstructionAnalysis.Tva.y;

[XTrainStandardized,MuX,SigmaX] = zscore(XTrain);
SigmaX(SigmaX == 0) = 1;
XValidationStandardized = (XValidation - MuX) ./ SigmaX;

Lambdas = logspace(-4,3,60);

rng(29,"twister")
[LassoPath,FitInfo] = lasso(XTrainStandardized,YTrain,"Lambda",Lambdas,"CV",5,"Standardize",false);

LassoIndex = FitInfo.IndexMinMSE;
Lasso = struct();
Lasso.Path = LassoPath;
Lasso.FitInfo = FitInfo;
Lasso.Index = LassoIndex;
Lasso.Lambda = FitInfo.Lambda(LassoIndex);
Lasso.Beta = LassoPath(:,LassoIndex);
Lasso.Intercept = FitInfo.Intercept(LassoIndex);
Lasso.YHatTrain = XTrainStandardized*Lasso.Beta + Lasso.Intercept;
Lasso.YHatValidation = XValidationStandardized*Lasso.Beta + Lasso.Intercept;
Lasso.TrainMSE = mean((YTrain - Lasso.YHatTrain).^2);
Lasso.ValidationMSE = mean((YValidation - Lasso.YHatValidation).^2);
Lasso.SelectedMask = Lasso.Beta ~= 0;

RidgePath = zeros(numel(FeatureNames),numel(Lambdas));
RidgeTrainMSE = zeros(numel(Lambdas),1);
RidgeValidationMSE = zeros(numel(Lambdas),1);
RidgeModels = cell(numel(Lambdas),1);

for i = 1:numel(Lambdas)

    RidgeModels{i} = fitrlinear(XTrainStandardized,YTrain,Learner="leastsquares",Regularization="ridge",Lambda=Lambdas(i),Solver="lbfgs");

    RidgePath(:,i) = RidgeModels{i}.Beta;

    yhatTrain = predict(RidgeModels{i},XTrainStandardized);
    yhatValidation = predict(RidgeModels{i},XValidationStandardized);

    RidgeTrainMSE(i) = mean((YTrain - yhatTrain).^2);
    RidgeValidationMSE(i) = mean((YValidation - yhatValidation).^2);

end

[~,RidgeIndex] = min(RidgeValidationMSE);
Ridge = struct();
Ridge.Path = RidgePath;
Ridge.Models = RidgeModels;
Ridge.PathTrainMSE = RidgeTrainMSE;
Ridge.PathValidationMSE = RidgeValidationMSE;
Ridge.Index = RidgeIndex;
Ridge.Lambda = Lambdas(RidgeIndex);
Ridge.Model = RidgeModels{RidgeIndex};
Ridge.Beta = Ridge.Model.Beta;
Ridge.Intercept = Ridge.Model.Bias;
Ridge.YHatTrain = predict(Ridge.Model,XTrainStandardized);
Ridge.YHatValidation = predict(Ridge.Model,XValidationStandardized);
Ridge.TrainMSE = mean((YTrain - Ridge.YHatTrain).^2);
Ridge.ValidationMSE = mean((YValidation - Ridge.YHatValidation).^2);

Lasso.YPredictionSlices = cell(numel(PredictionSlices),1);
Ridge.YPredictionSlices = cell(numel(PredictionSlices),1);
for k = 1:numel(PredictionSlices)
    XSlice = PredictionSlices(k).Table{:,cellstr(FeatureNames)};
    XSliceStandardized = (XSlice - MuX) ./ SigmaX;
    Lasso.YPredictionSlices{k} = XSliceStandardized*Lasso.Beta + Lasso.Intercept;
    Ridge.YPredictionSlices{k} = predict(Ridge.Model,XSliceStandardized);
end

CoefficientSummary = table(FeatureNames',Lasso.Beta,Ridge.Beta,VariableNames=["Feature","Lasso_StdCoef","Ridge_StdCoef"]);
PerformanceSummary = table(["Lasso";"Lasso";"Ridge";"Ridge"],["Train";"Validation";"Train";"Validation"],[Lasso.TrainMSE;Lasso.ValidationMSE;Ridge.TrainMSE;Ridge.ValidationMSE],VariableNames=["Model","Split","MSE"]);

RegularizationAnalysis = struct();
RegularizationAnalysis.ConstructionAnalysis = ConstructionAnalysis;
RegularizationAnalysis.FeatureNames = FeatureNames;
RegularizationAnalysis.FeatureNamesLatex = FeatureNamesLatex;
RegularizationAnalysis.XTrainStandardized = XTrainStandardized;
RegularizationAnalysis.XValidationStandardized = XValidationStandardized;
RegularizationAnalysis.MuX = MuX;
RegularizationAnalysis.SigmaX = SigmaX;
RegularizationAnalysis.Lambdas = Lambdas;
RegularizationAnalysis.Lasso = Lasso;
RegularizationAnalysis.Ridge = Ridge;
RegularizationAnalysis.CoefficientSummary = CoefficientSummary;
RegularizationAnalysis.PerformanceSummary = PerformanceSummary;
end
%%
function Traw = MakeConstructionDataset()
rng(7,"twister")
n = 140;
x = linspace(0,10,n)';
z = 0.4*x + randn(n,1);
y = 2 + 0.6*x + 1.7*sin(x) + 0.25*(x.*z) + 0.6*randn(n,1);
Traw = table(x,z,y);
end
%%
function T = AddEngineeredFeatures(T)
T.x2 = T.x.^2;
T.x3 = T.x.^3;
T.sinx = sin(T.x);
T.cosx = cos(T.x);
T.x_z = T.x .* T.z;
T.logx = log(T.x + 1e-6);
T.sqrtx = sqrt(T.x);
end
%%
function PredictionSlices = MakePredictionSlices(Traw)
SliceLabels = ["Low z band","Middle z band","High z band"];
zEdges = quantile(Traw.z,[0 1/3 2/3 1]);
PredictionSlices(1,3) = struct( ...
    "Label","",...
    "ZValue",NaN,...
    "ZRange",zeros(1,2),...
    "XGrid",zeros(0,1),...
    "Table",table());

for k = 1:3
    if k < 3
        BandMask = Traw.z >= zEdges(k) & Traw.z < zEdges(k+1);
    else
        BandMask = Traw.z >= zEdges(k) & Traw.z <= zEdges(k+1);
    end

    ZBand = Traw.z(BandMask);
    XBand = Traw.x(BandMask);
    ZValue = median(ZBand);
    XGrid = linspace(min(XBand),max(XBand),200)';

    SliceTable = table(XGrid,ZValue*ones(size(XGrid)),zeros(size(XGrid)),...
        VariableNames=["x","z","y"]);
    SliceTable = AddEngineeredFeatures(SliceTable);

    PredictionSlices(k) = struct( ...
        "Label",SliceLabels(k), ...
        "ZValue",ZValue, ...
        "ZRange",[min(ZBand) max(ZBand)], ...
        "XGrid",XGrid, ...
        "Table",SliceTable);
end
end
%%
function Style = DefaultPlotStyle()
%DEFAULTPLOTSTYLE Plot appearance used throughout the lesson

Style = struct();

%%\ Grid
Style.Grid = "on";
Style.Box = "on";

%%\ Text
Style.Interpreter = "latex";

%%\ Visual encoding
Style.DataMarkerSize = 40;
Style.SmallMarkerSize = 24;
Style.DataMarkerFaceAlpha = 0.7;
Style.DataSeriesIndex = 3;
Style.FitSeriesIndex = 6;
Style.BackgroundMarkerColor = [0.7 0.7 0.7];
Style.BackgroundMarkerFaceAlpha = 0.18;
Style.BackgroundMarkerSize = 18;
Style.ConfidenceFillColor = [0.85 0.90 1.00];
Style.PredictionLineWidth = 2;

end
%%
function ApplyDefaultAxesStyle(Style,opts)
arguments
    Style (1,1) struct
    opts.AxisMode (1,1) string {mustBeMember(opts.AxisMode,["none","tight","padded"])} = "none"
end

grid(Style.Grid)
box(Style.Box)

switch opts.AxisMode
    case "tight"
        axis tight
    case "padded"
        axis padded
    otherwise
        % No axis adjustment requested.
end
end
%%
function PlotObservedSlices(Traw,PredictionSlices,plotTitle,Style)
arguments
    Traw table
    PredictionSlices (1,:) struct
    plotTitle (1,1) string
    Style (1,1) struct
end

tiledlayout(1,numel(PredictionSlices),TileSpacing="compact",Padding="compact")
sgtitle(plotTitle,Interpreter=Style.Interpreter,FontWeight="bold")
XLimits = [min(Traw.x) max(Traw.x)];
YLimits = [min(Traw.y) max(Traw.y)];

for k = 1:numel(PredictionSlices)
    nexttile
    BandMask = GetSliceMask(Traw.z,PredictionSlices(k));
    scatter(Traw.x,Traw.y,Style.BackgroundMarkerSize,...
        Style.BackgroundMarkerColor,"filled",...
        MarkerFaceAlpha=Style.BackgroundMarkerFaceAlpha)
    hold on
    scatter(Traw.x(BandMask),Traw.y(BandMask),Style.SmallMarkerSize,"filled",...
        MarkerFaceAlpha=Style.DataMarkerFaceAlpha,SeriesIndex=Style.DataSeriesIndex)
    hold off
    xlim(XLimits)
    ylim(YLimits)
    xlabel("$x$",Interpreter=Style.Interpreter)
    ylabel("$y$",Interpreter=Style.Interpreter)
    title(FormatSliceTitle(PredictionSlices(k)),Interpreter=Style.Interpreter)
    ApplyDefaultAxesStyle(Style)
end
end
%%
function PlotSlicePredictions(TData,PredictionSlices,PredictionSets,plotTitle,Style)
arguments
    TData table
    PredictionSlices (1,:) struct
    PredictionSets (1,:) struct
    plotTitle (1,1) string
    Style (1,1) struct
end

tiledlayout(1,numel(PredictionSlices),TileSpacing="compact",Padding="compact")
sgtitle(plotTitle,Interpreter=Style.Interpreter,FontWeight="bold")
XLimits = [min(TData.x) max(TData.x)];
YMin = min(TData.y);
YMax = max(TData.y);
for p = 1:numel(PredictionSets)
    for k = 1:numel(PredictionSlices)
        YMin = min(YMin,min(PredictionSets(p).YValues{k}));
        YMax = max(YMax,max(PredictionSets(p).YValues{k}));
    end
end
YLimits = [YMin YMax];

for k = 1:numel(PredictionSlices)
    nexttile
    BandMask = GetSliceMask(TData.z,PredictionSlices(k));
    scatter(TData.x,TData.y,Style.BackgroundMarkerSize,...
        Style.BackgroundMarkerColor,"filled",...
        MarkerFaceAlpha=Style.BackgroundMarkerFaceAlpha)
    hold on
    scatter(TData.x(BandMask),TData.y(BandMask),Style.SmallMarkerSize,"filled",...
        MarkerFaceAlpha=Style.DataMarkerFaceAlpha,SeriesIndex=Style.DataSeriesIndex)

    for p = 1:numel(PredictionSets)
        plot(PredictionSlices(k).XGrid,PredictionSets(p).YValues{k},...
            LineStyle=PredictionSets(p).LineStyle,...
            LineWidth=Style.PredictionLineWidth,...
            DisplayName=PredictionSets(p).Label,...
            SeriesIndex=PredictionSets(p).SeriesIndex)
    end

    hold off
    xlim(XLimits)
    ylim(YLimits)
    xlabel("$x$",Interpreter=Style.Interpreter)
    ylabel("$y$",Interpreter=Style.Interpreter)
    title(FormatSliceTitle(PredictionSlices(k)),Interpreter=Style.Interpreter)
    ApplyDefaultAxesStyle(Style)
    if k == numel(PredictionSlices)
        legend(Location="best",Interpreter=Style.Interpreter)
    end
end
end
%%
function YPredictionSlices = PredictModelSlices(mdl,PredictionSlices)
YPredictionSlices = cell(numel(PredictionSlices),1);
for k = 1:numel(PredictionSlices)
    YPredictionSlices{k} = predict(mdl,PredictionSlices(k).Table);
end
end
%%
function TitleText = FormatSliceTitle(PredictionSlice)
TitleText = sprintf("%s (z approx %.2f)",PredictionSlice.Label,PredictionSlice.ZValue);
end
%%
function BandMask = GetSliceMask(zValues,PredictionSlice)
BandMask = zValues >= PredictionSlice.ZRange(1) & zValues <= PredictionSlice.ZRange(2);
end
%%
function FeatureLibrary = GetFeatureLibrary()
%GETFEATURELIBRARY Collection of feature transformations used throughout
%
% FeatureLibrary(k).Name
% FeatureLibrary(k).DisplayName
% FeatureLibrary(k).SummaryName
% FeatureLibrary(k).Latex
% FeatureLibrary(k).Fcn

FeatureLibrary = struct("Name",{},"DisplayName",{},"SummaryName",{},"Latex",{},"Fcn",{},"SupportsPeriod",{},"PeriodicKind",{},"Period",{},"PeriodLabel",{});

FeatureLibrary(end+1) = struct("Name","x2","DisplayName","Square","SummaryName","x^2","Latex","$x^2$","Fcn",@(x)x.^2,"SupportsPeriod",false,"PeriodicKind","","Period",NaN,"PeriodLabel","");
FeatureLibrary(end+1) = struct("Name","x3","DisplayName","Cube","SummaryName","x^3","Latex","$x^3$","Fcn",@(x)x.^3,"SupportsPeriod",false,"PeriodicKind","","Period",NaN,"PeriodLabel","");
FeatureLibrary(end+1) = struct("Name","sqrtx","DisplayName","Square Root","SummaryName","sqrt(x)","Latex","$\sqrt{x}$","Fcn",@(x)SafeSqrt(x),"SupportsPeriod",false,"PeriodicKind","","Period",NaN,"PeriodLabel","");
FeatureLibrary(end+1) = struct("Name","logx","DisplayName","Logarithm","SummaryName","log(x)","Latex","$\log(x)$","Fcn",@(x)SafeLog(x),"SupportsPeriod",false,"PeriodicKind","","Period",NaN,"PeriodLabel","");
FeatureLibrary(end+1) = struct("Name","expx","DisplayName","Exponential","SummaryName","exp(x)","Latex","$e^x$","Fcn",@(x)exp(x),"SupportsPeriod",false,"PeriodicKind","","Period",NaN,"PeriodLabel","");
FeatureLibrary(end+1) = struct("Name","sinx","DisplayName","Sine","SummaryName","sin(x)","Latex","$\sin(x)$","Fcn",@(x)sin(x),"SupportsPeriod",true,"PeriodicKind","sin","Period",2*pi,"PeriodLabel","2*pi");
FeatureLibrary(end+1) = struct("Name","cosx","DisplayName","Cosine","SummaryName","cos(x)","Latex","$\cos(x)$","Fcn",@(x)cos(x),"SupportsPeriod",true,"PeriodicKind","cos","Period",2*pi,"PeriodLabel","2*pi");
FeatureLibrary(end+1) = struct("Name","invx","DisplayName","Reciprocal","SummaryName","1/x","Latex","$1/x$","Fcn",@(x)SafeReciprocal(x),"SupportsPeriod",false,"PeriodicKind","","Period",NaN,"PeriodLabel","");
end
%%
function PeriodLibrary = GetPeriodLibrary()
PeriodLibrary = [
    struct("Label","0.5","LatexLabel","0.5","Value",0.5)
    struct("Label","1","LatexLabel","1","Value",1)
    struct("Label","2","LatexLabel","2","Value",2)
    struct("Label","2*pi","LatexLabel","2\pi","Value",2*pi)
    struct("Label","4*pi","LatexLabel","4\pi","Value",4*pi)
    ];
end
%%
function PeriodSpec = GetPeriodSpec(periodChoice)
arguments
    periodChoice (1,1) string
end

PeriodLibrary = GetPeriodLibrary();
PeriodLabels = string({PeriodLibrary.Label});
PeriodIndex = find(PeriodLabels == periodChoice,1);

if isempty(PeriodIndex)
    error("Unknown period selection.")
end

PeriodSpec = PeriodLibrary(PeriodIndex);
end
%%
function FeatureSpec = GetSelectedFeatureSpec(featureChoice,periodChoice)
arguments
    featureChoice (1,1) string
    periodChoice (1,1) string = "2*pi"
end

FeatureLibrary = GetFeatureLibrary();
FeatureChoices = string({FeatureLibrary.DisplayName});
FeatureIndex = find(FeatureChoices == featureChoice,1);

if isempty(FeatureIndex)
    error("Unknown feature selection.")
end

FeatureSpec = FeatureLibrary(FeatureIndex);

if FeatureSpec.SupportsPeriod
    PeriodSpec = GetPeriodSpec(periodChoice);
    FeatureSpec = MakePeriodicFeatureSpec(FeatureSpec,PeriodSpec);
end
end
%%
function FeatureSpec = MakePeriodicFeatureSpec(BaseFeatureSpec,PeriodSpec)
arguments
    BaseFeatureSpec (1,1) struct
    PeriodSpec (1,1) struct
end

switch BaseFeatureSpec.PeriodicKind
    case "sin"
        DisplayName = "Sine (T = " + PeriodSpec.Label + ")";
        SummaryName = "sin(2*pi*x/" + PeriodSpec.Label + ")";
        Latex = "$\sin(2\pi x / " + PeriodSpec.LatexLabel + ")$";
        Fcn = @(x) sin(2*pi*x./PeriodSpec.Value);
    case "cos"
        DisplayName = "Cosine (T = " + PeriodSpec.Label + ")";
        SummaryName = "cos(2*pi*x/" + PeriodSpec.Label + ")";
        Latex = "$\cos(2\pi x / " + PeriodSpec.LatexLabel + ")$";
        Fcn = @(x) cos(2*pi*x./PeriodSpec.Value);
    otherwise
        error("Unknown periodic feature kind.")
end

FeatureSpec = struct(...
    "Name",BaseFeatureSpec.Name + "_T_" + replace(PeriodSpec.Label,"*","x"),...
    "DisplayName",DisplayName,...
    "SummaryName",SummaryName,...
    "Latex",Latex,...
    "Fcn",Fcn,...
    "SupportsPeriod",BaseFeatureSpec.SupportsPeriod,...
    "PeriodicKind",BaseFeatureSpec.PeriodicKind,...
    "Period",PeriodSpec.Value,...
    "PeriodLabel",PeriodSpec.Label);
end
%%
function y = SafeLog(x)
y = NaN(size(x));
mask = x > 0;
y(mask) = log(x(mask));
end
%%
function y = SafeSqrt(x)
y = NaN(size(x));
mask = x >= 0;
y(mask) = sqrt(x(mask));
end
%%
function y = SafeReciprocal(x)
y = NaN(size(x));
mask = x ~= 0;
y(mask) = 1./x(mask);
end

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"hidecode"}
%---
%[text:image:2aea]
%   data: {"align":"baseline","height":150,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAJYAAACWCAYAAAA8AXHiAAAACXBIWXMAAA7EAAAOxAGVKw4bAAANT0lEQVR4nO2dbUxUVxrH\/zPDwODIvKAMrxJeWl9QsxqjVrpu7KJpBmnjNt02aWP7gUKModWmaVY3rZUlKbitWBNba22a7DaxG7WlzbppszW7UpNugCYdw5CSaOhUXnRAGWFkgJFx9gMdCgXmnjtzzsy9w\/NL+MDMc888GX6cc++55z5HAways7Mfyc3NtdtstodMJtNyg8GwVKPR6FiOJZRLIBAY8\/l8vYODg+1ut7v5+vXrX3i93h95tK0J9+by5csrS0pK9lmt1rU8PoxQPi6X65zT6Xx7YGCgNZp25hTLarWu3bx58\/Hs7OxHommcUC\/t7e1\/\/e677\/4U6fGzxMrPz9+1bdu2MzqdLjW61Ai109vb++9Lly495ff7h+QeO+M8KT8\/f1dZWVmTVqvV80uPUCsmk6k4Kyvrd11dXZ8Eg8EJOcdOiWW1Wtc++uijX5FUxHSMRuMys9m8wuVynZNz3JRY27Zt+4fJZHqQf2qE2rFYLCV+v98zMDDQwnqMFpi8+qMTdSIc69ev\/4terzexxusAYOvWrX9LTU3NFJcWoXZ0Op1hYmLirtvtvswSn5Sdnf2InHmq0tJSFBcXIzk5OfIsVcoXPWmSMeutY8g33otBNtEzNDQEh8OBa9euMcUXFxfvvnLlypsssUm5ubl2lsCsrCxUV1ejoKCAKYlEpPJol2TMljWFeHi1tIBKoby8HBcvXsSZM2ckY81m80qr1brW4\/G0S8VqbTbbQywJLHSpEpnt27fjscceY4rNyMjYzBKnNZlMy6WCSktLSaoEx263Q6MJe4cPAMA6c6A1GAxLpYKKi4tZ2iJUjMFgQGFhIUvcEpb2tCyrFBbiifpChOXvzLqqRRt1NgQxByQWIQQSixBCUrwTUAK3RgLoGvRzaatr8B5au0fDxqSl6LDKltjnrSQWgMsuHw5+NcClrdOtd3C69U7YmI15Bnz8dA6Xz1MqNBQSQiCxCCGQWIQQSCxCCCQWIQQSixACiUUIgcQihEATpAC2FizC35\/Klox77uwNyZiqTRZsLQj\/rG9aCp+yF\/fv38fdu3cxMjIy42eu13bv3o2MjAwun8sCiQVgqVGHpUY+D34XpeuxaRmftt56661ZgkwXZ3Q0\/K2j6bz00ktccmKFxFIwr776KhoaGnDhwoWo2jGbzUhKiu2fms6xFM6BAwewa9euqNqwWq2csmGHxFIBr732GioqKiI+nsQi5uXw4cOw25me1JtFeno652ykIbFURF1dHTZs2CD7OOqxiLC0tbWhvV3yWdFZkFjEvLS1tWHfvn3w++WvdI3HUJjw0w1NHV70DoWvGbbSloztDxgl26rZIv2fvzIjhTk3VlpbW7F3796Ij49Hj5XwYn3m9KKtZyxszK7VaWxilcb+D9TW1ob9+\/dH1QYNhcQMohn+pkNXhcQUvKQCqMcifiYSqYxGI4qKima9rtVqYbFYeKbHBImlMCKRavHixTh16hROnjyJFStWzHgvHsMgQGIpikilev\/997Fy5UosWbIEjY2NM6oDxWMYBEgsxRCtVCEyMzNx7NixqXpmJNYChpdUIXJyctDY2Ii8vDwaChcqDoeDq1Qh8vPz0djYGLceS7UTpL3DEyg7fZ1LW593ePF5h1cyrvOV2Vdd0eBwOFBTU8NdqhBFRUWoqqqKJsWIoR4rToSkGhsLf1dgOnKkCmEyMdf854qQHuv8+fOwWCywWCwwm81TPykp\/O+jqZFYSRVPhIjl9\/tx4MCBWa+npqbOkk3q98WLF4tIMW4sBKkAQWKZzeY5Xx8dHcXo6Chu3JB+jAoAysrKcOTIEZ6pxZVIpFq0aJHqpAIEnWPxGNdJqkmp3nvvvZhJFQwGubUlRKz5eixWtm\/fTlL9LNWaNWsEZiYOxYm1Y8cONDQ0cMwmvnz\/\/feypUpNTVW1VIDChsIdO3agvr6eczbxw+Fw4MUXX5TdU508eVLVUgExPnkPh16vlzWZt3SRjqnewpv\/vY3OgfATkL8tSEX1Jr5LS2I1\/DV1ePGZM\/zkboYxCY0VNuY2eSBELK1Wi7S0NHi90rPZIe7du4fKykqcOnUKy5dL7huFlCQNU42EtBTpTnmpMYlbvQXgl+FvfHyc+ZjU1FS8++67snuq3qEJyaXXOabY32ARNvMeyXDo9XqxZ88e5o0ZlUho+JMjVWj4W7uWeT9SxSNMrEhP4IeHh1FdXa1KuRbi1d98KKrHCqFGuUiqmSiuxwqhJrlIqtnEvMdi2cUzhBrkcjqdJNUcxLTHstvtaGhogFbL\/rFKlsvpdGLv3r0k1RzErMcqLy9HXV0dysrKUF9fH5FcLpeLc5aRE5LK5\/MxH7NQpAIEriCd3mPt3LkTtbW1U7+H5Dp48CDu37\/P1N7w8DCqqqpw+vRpWRufr7JJrwErStcztwfETqorN8YxPhH+++kZDl+XAgDGJ4KSW90BgB\/yvodwCBfr11KFiEQuj8cjW64\/P8K0NzYzkUhlMBgi6qlevuBGH4M4Utz2BZgqPts1\/O4+CB0KKyoq5pQqRCTDYkiueAyLkUp14sSJBTH8TUeYWOnp6Th8+LBknFrkikaqdevWCcxMmQgTKy8vjzlW6XKRVPJRzFM6SpWLpIoMxYgFRCdXd3c393xIqshRlFhA5HK98MILXOUiqaJDcWIBk3LV1tbKkuv27dvc5CKpokeRYgGTt3\/iIRdJxYeYLy38\/enrkpN+NVusqCm1Tu3E8MYbbzBPoobk+vDDD7Fs2TJZuSlNqv9U5UvGnPjWgxP\/84SNyTElMbV15Mg5DDFnFx7F9lghYtVzKU0qtaN4sQDxcnV2dpJUnFGFWEB0cvX19c0b09nZiT179pBUnFGNWAB\/uUJS3b17l7k9kooNVYkFRCZXf3\/\/LLlIKrGoTizgF7nkMF0ukko8qi0VabfbEQwGcejQIeZj+vv7UVlZidHRUVlSAcDx48dJKhmoVixgcrmzRqORNc81MDAg6zOSk5Nx\/PjxiDagXMhwE6t3eAJNEjUEAMA7Li1AS\/co8G34mLQULZ7fYI5oEpWVkFQbN27k2i7rd\/XcBjNMEiUCNi0zoAbhKyOzlBngDT+xhu5JzgCz0tYzxlSP4PkNk8uf7XY7AoEA08JCVlJSUvDOO+9wlwpg\/67+sCaNQaxUrnUneKHKk\/e5qKioQF1dnayrxflITk4WJtVCIWHEAiKbivg1ooa\/hYaqT97nInTOdejQIdk1NUkqfiRUjxXCbrfj9ddfl\/U4P0nFl4QUCwAef\/xxZrlIKv4krFgAm1wklRgSWixgUq7a2lokJyfPes9isdDVnyC4nbynpeiwMc8gGSc1PwVMzlHlStTNzDCyp15eXo5169bh7Nmz+Omnn6DX61FYWIhnn32W+yZGXYP3cGsk\/ArZH\/rZdvty9I2hd0gXNibXrJf8ruIBt4xW2ZLx8dM5knEsS5OfWJ2GmlK+++zl5ORg\/\/79XNuciw9a7zBtUcfCK\/\/ql4wJLeNWGgk\/FBLxgcQihEBiEUIgsQghkFiEEEgsQggkFiEEEosQQsynbI9VZEpWAs4186vey8Jllw8ftNyRjGOZAK7eZMETq8NvkP5Dvx\/1l25LtnV0pw0ZRumZdyUSc7F+ky1dHjvW3BoJMN1qYqEoXS+7vPd8rMsxKPJ2DQs0FBJCILEIIZBYhBBILEIIJBYhBBKLEAKJRQhBnZMkMmjq8KJ3SGKp8ADbUuET30o\/Fl\/2gBGrbLPX108n16xHzRbpVZ\/xqLnAi4QX6zOnl9vkJ0u9hVxzkrRYpiRFLifmiXr\/JQhFQ2IRQiCxCCGQWIQQSCxCCCQWIQQSixACiUUIIeEnSFmWEzd1eHHwK+ky3Z2vFPFIaUFAPRYhBBKLEAKJRQiBxCKEoA0EApK3\/oeGeO0UTCgZr1e6YByLLwCg9fl8vVJBDoeDpS1CxbhcrrA70Ybw+XzSQQC0g4OD7VJB165dw8WLF1naI1TKp59+yhTn8XicLHFat9vdzBJ45swZNDU1YWyMz6I5Qhm4XC4cPXoUHR0dTPFut\/syS5wmLS2t8Mknn+xiTUSj0aCwsHDO8tZKQO42JwAwCgOGNGmScVlBeXsdKh2v18s0\/IXo6en58uuvvy5niU3yer0\/ulyucwUFBX9kOSAYDKKri9nDhGKhX8JcvXr1I9ZYLQA4nc63xaVDJAI3b978xuVynWeN1wGAz+frTUpKWpSZmfmwuNQINdPc3PzMyMhIN2v8VPGlvr6+izabrdRkMhWLSY1QKy0tLS+7XK5zco6ZUdWru7v7n1lZWb8zGo3L+KZGqBWHw1HX3t5eL\/e4GWIFAoHxrq6uT8xm8wqLxVLCLz1CjbS0tLwciVTAr8QCgGAwOOFyuc75\/X6PzWYr1el00jsvEQnFzZs3v2lubn5G7vA3nbC7ROr1elNJSUlNcXHxbrPZvDLSDyHUQU9Pz5dXr179SM7V33ww721rtVrXZmRkbDaZTA8aDIYlGo0mfNVVQvEEAoExn8\/X5\/F4nG63+\/LY2NiteOdEEARBEARBEARBEARBEAShev4Pc32Wu8NTtdgAAAAASUVORK5CYII=","width":150}
%---
%[text:image:4e10]
%   data: {"align":"middle","height":24,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAArElEQVR42mP4\/\/8\/AwgnJiYapKamfgfS\/ynBUDMMYOYywBggiYcPH\/6nFIDMAJmFYQHIdmoBqFm4LZjrYPd\/gpoyGIPYVLeA5j4gbEASHJNlwZYtW\/93dHTixDCDQTRMDKRn8FhATBDNmTOH\/CAiBI4cOQI2HETTLBW9fv2a\/FRUtPXVf\/WeuyRhkB6iLQBp2HLvP0kYpGfUglELhpMFNM9oNKlw6FHp06TZAgAoeVix9Bg9oQAAAABJRU5ErkJggg==","width":24}
%---
%[text:image:51ff]
%   data: {"align":"baseline","height":24,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAsCAYAAAAXb\/p7AAADlklEQVR42u1YS0hUYRQejR4UvR+SvaCyWiS2DIoCKWjVYzG2SsYWQ+a8HRwXFkOgqdGLSoSeqyBaJUGLCKGkNpGtgiyScnpYBpaU5au+E+eH03Wu93rvP2OEFw46955z\/u8\/7\/\/3eDQ+4XD4Eui65199AK4d1DEJcBLgfw0wGo2ujkQi1yoqKlY5AFgDqnWw5lpaMxaLrbBkDgaDm7HIEKjTCcjxPqFQqABrdYEGsHaRXaESCAyCXpNFMwwuReDw\/77xusurQGJna0ysPR2K94CnGdQKesnUyu92J5PJaelk4c51Chzcu9dp0O9nkO3yvd\/vnwqlEbzvAf2yoB5sIkwyBt0doJ+0Qbdu2AXyC8UrOVuNQH5Q3IJegfrTfH8ikwC\/A9hjsdaYCQQCG6D4vVj0DShB7+HKXMGaQ\/EFADEGrPhJdn1GAhoZvRDKX4jFTvt8vhlWchSD4D0OGiE5AH9eXl4+PxNF+IoCB8sccyBfreQB8qJWcAC0CYqHeYE2cqEDNTmQvcc6hlC+CnXWq\/PCtTtdeGGr0HNWFz7aeTcr\/eT1eqe41PVWJYxd62zkovwXqQ6Cv8vErm9r8MZNEctLVf9Ph4GwecSOjPSQu8V28e6chmRrFPq28btHJhhSBKDIBH0B726HEDilAWCtsGCx6MmjMNgaHqBkiygPl3UmHE1OrjOEiqoqsqDHGizYxrqGAXCOriL9jJUOoq3lO9UDQItpQGD3PtXZRapFHB51oSchwiWsDWA8Hl8Cpb2svA+WWO4AXJ7Q0Z1IJObq7sUBN\/UQLr0hrHfANSCaQihrobiBf+dC+QOxSNk4MrdEyN1VvRy6T+DdVbOp2wpcCyutN8yDahjtVZ3A4sS2ALwflYxhaK1n0C22QfL8dkuNRYZBlKxxRLj6gg3XNgj+w8beLOriHcv50gocJ8wsfP\/ASgfMDlRs8XzwfGPeThMr2QcpEqFprJmPSoSwSvMYfCcFX6nFlNPEfAGrUuC1GkhxQpspTnTfKysrFxl5qqqqZouy0mU81ZmApB6cp2vKlrFVk+Z7TGRuPOsXRZSNfGYmEO\/ofoXmOiKKS3Ga6wPYeRNxk9Vo49BONAIL1mUdIBa9bxPgn+zMOkAqIXDdQbp1sKAy6uWeyWd0Cyuk5LDh3pTtez\/NSVJqNwbh5kNZB8htkTrP1zHA9dM1nZ07nExmc50ZQGA7M+GxyLden9MA\/OLm\/KKe34xPoKAD7jPkAAAAAElFTkSuQmCC","width":22}
%---
%[text:image:0fb1]
%   data: {"align":"baseline","height":23,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAADoAAAA6CAYAAADhu0ooAAAEp0lEQVR42t2a208TQRTG67OJxvv9fiGoD6LGgPiCGo1G\/wljTKDl1pL00RuKIKCIIiKg6ItB8IJ38K4Panz13RcfSBBBQQHRek4ys\/kYpu1uu2132+Sku6eb6X7zmzlz5ux6PEn6lJaWbi0uLu4mGyLrJWvMz8+f4UmnjxA5QhZS7HNZWdnUdNE5hQR9EsLGioqKWuj7kRRbUlJSmS40D4Co4yD+rfAPEdW5rhdKQj4KQQM4J0n0DhjCVW4XuR9oHlV\/J98rSZVsnmuF0nz8oNIsLCxcFQwGp4vf86AjzrhV5D4dTTq+Tr8d0VD95fP5Frpx2L4XAgYlTQpMq+n8DxKm4+0wV6tdJZIo7YWbPwbi26QfqdL5S+H\/7SqqdMPvJE2iOFPOTUEzpM5bpEodUOMWkXs06yb7r6qZEc5dOn\/hKqqQCESiOYkqic4Ff62jRZKg3XCzJ0B8q0akjupzSZU6aZGTl5Q34kZ\/BgKB2ezzer3LOMcNJ5SpSvJIlY7POTWn3QUBpRzEt0QQqYvMzxxNlW7staRJQ3gO0Bw1IdSYz9Qx28Bf57QhuxNu7iSIbzYhclKEpvZ6HElVR5OOl5qkGZEqdcB5p9DMC0OzyYJIXaTuFr4R6rzFTkj3jK1WHDRDarSmdnPAX59qkbkQaU+B\/7IqglM7+g4qVqu5rhzaeeoIqpC2RaVJN52pGfYbdFRlW0iVrr2QcppkFSC+MUxUNSt0AlU6f5JSqpCuGcUtv9+\/JExZ05JQpErf2eC\/mOxIi4v6aRDfEGGdtCJUjeCPhW+Uk5BkCu2xQjNGoQZVWl+30Pk\/4W9I1tzM0RWfeVhFyXysCp0QyaHoPUZtLU\/G3OxWadIfL+Dilt1CMZrTtZuB6qVE7zezdUVnDv0mctlYhKpUHyaFKoR6SzTjEYr\/pVBtTDhNLDZz0m1ydxKrUHWdfiCp+ny+FYmgKUP8sHx8YJamDUK1VDnVtHs5wSFTDeLrLOw34xGqrtf3E0IVgoBRiiwoKJhvlqZNQjEubIKOb7Jr3TQaxeIyF6+sbMFsEKqu2\/ZShQZVmsPJFhqOKrVzxTaaWFTW7SNNCD3IlUI08h2KYXOO63eXpErtrYwnCHWpNDniWqVpsxlUacnLAhDNsa6bWTqaolIQSrFVwei6FxdVGlZ3baY5SNav2KCdVLlYblXkRqB5FnqvOlYKNgWjUJjsTEIZpzbXWIm0d9QCMlfneI\/oFKFKhoZgWs0GIP7zv+qDHu7BeOZVAoSqWZqEM+73+9eaodlpN80ECjXiBwLih87Rnoith4vrgGZlvJEyQUJVqrdNUaULOmRp0U6a8uUMssNo\/BDYBqHDnKlppt21qDTxwQ7vGhywbkbrxBrN1Bsny9DRbFcLxV6vdxad\/3C6UJyryvRrU7OgdfBjPYivcIHIkCYX79BSpZObLqYZkSq\/kicjaqZ04oMcrpS7SGRIzeJIy60JVDk6SZpcbRdDeRr5v2hyU6fbV\/l8VVlXm5lcX0wJsTveYpMVw14PzMOGNBQqE4h+3M8x5hti3UwH64S52y6D0YALA49Z6+P3hCXiDLH2fEsjgd+ZKr9wyRr\/A+UKAPezYlA8AAAAAElFTkSuQmCC","width":23}
%---
%[text:image:5af8]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[text:image:1c31]
%   data: {"align":"baseline","height":20,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAADUAAAAxCAYAAAB6d+FmAAAC0ElEQVR42u2aO4gTURSGs6Lugo1WW2ghgiyCr1VWbRSR9YEgKoKohcQmEDAviYhBIaVbbKEWYi22YidoobUItoqwjSui6wt119Wsj+\/onXAcJslMZpI7AxP4Sbh37pnz3TP3zJ2TyWQS9imVStvRK1G5XL5ZqVRWZpL8MUCf0G+lz+hYIoGIyDYPIEc\/i8ViLmkRGkMfWwA5WkD7EwHEutmCs+87ADl6zfHLm4MLhcIqGs7RcV0WoA1xCa3vIkL\/CTsX\/w7G2Bka5oIMjlo4M6GBmOTRABHSeirh3S0LzSYQugHHgAPEJG+l7UOXtr6LgQeqYQZdRVf6Jc5frdfriyKIkOgHQToi1+0XpxGD+ywnhc348a5bICboqLMYmx02784hgRYAOqEzjHWoSIHiABU5kG2osECMP9lqC2IFiqS0qSdAtqAM0Ey3QOhUp81iX6F6DtRvKM6xsedA\/YQKCdQgyx0PcrKeQ4WNkE4K+LhGb6usQOHQOnnOCb31+WdrNW1TQC22BoW9Ddh9i6bRfNDdNkCH1c59LW0vpc8qFDYfo\/tkvMFqtbqM3xdkffgAmseXQ44dM3ba6bcGlc1mh9yzbaK3k\/Y37YAYc9Dl47A+xhoU0dlh7A579I3qRx6lbwAd8PAxHlA4V5BF3ea8Z11Ac62e52IDhb1bZuZL+lFdRWtQpflZzj3exlZsIvVc2b7jdW8xiWSWVL2ng4\/2ofL5\/Ars\/XJdXudN9wC\/R4Ce5PurFH58RN0+FLb2et130D1VVJlCu3zasw9FFC67dwboialUnZadQcBJsg+F09ewd9tkwLFcLrckZOTjkSgi3pmkUClUCpVCpVApVAqVQqVQ0UDp6s5IHKFMeaz5doufYuYz9bf\/XXmXQaqgcZH4I34pqBd+Qluz\/LpBUF3qCEUol3LgwyQAEbFHUrDxW6OTyk7NFEsaMYNpGL9qfoH+AOOEPfJuI6OmAAAAAElFTkSuQmCC","width":22}
%---
%[text:image:25bf]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[text:image:4641]
%   data: {"align":"baseline","height":20,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAADUAAAAxCAYAAAB6d+FmAAAC0ElEQVR42u2aO4gTURSGs6Lugo1WW2ghgiyCr1VWbRSR9YEgKoKohcQmEDAviYhBIaVbbKEWYi22YidoobUItoqwjSui6wt119Wsj+\/onXAcJslMZpI7AxP4Sbh37pnz3TP3zJ2TyWQS9imVStvRK1G5XL5ZqVRWZpL8MUCf0G+lz+hYIoGIyDYPIEc\/i8ViLmkRGkMfWwA5WkD7EwHEutmCs+87ADl6zfHLm4MLhcIqGs7RcV0WoA1xCa3vIkL\/CTsX\/w7G2Bka5oIMjlo4M6GBmOTRABHSeirh3S0LzSYQugHHgAPEJG+l7UOXtr6LgQeqYQZdRVf6Jc5frdfriyKIkOgHQToi1+0XpxGD+ywnhc348a5bICboqLMYmx02784hgRYAOqEzjHWoSIHiABU5kG2osECMP9lqC2IFiqS0qSdAtqAM0Ey3QOhUp81iX6F6DtRvKM6xsedA\/YQKCdQgyx0PcrKeQ4WNkE4K+LhGb6usQOHQOnnOCb31+WdrNW1TQC22BoW9Ddh9i6bRfNDdNkCH1c59LW0vpc8qFDYfo\/tkvMFqtbqM3xdkffgAmseXQ44dM3ba6bcGlc1mh9yzbaK3k\/Y37YAYc9Dl47A+xhoU0dlh7A579I3qRx6lbwAd8PAxHlA4V5BF3ea8Z11Ac62e52IDhb1bZuZL+lFdRWtQpflZzj3exlZsIvVc2b7jdW8xiWSWVL2ng4\/2ofL5\/Ars\/XJdXudN9wC\/R4Ce5PurFH58RN0+FLb2et130D1VVJlCu3zasw9FFC67dwboialUnZadQcBJsg+F09ewd9tkwLFcLrckZOTjkSgi3pmkUClUCpVCpVApVAqVQqVQ0UDp6s5IHKFMeaz5doufYuYz9bf\/XXmXQaqgcZH4I34pqBd+Qluz\/LpBUF3qCEUol3LgwyQAEbFHUrDxW6OTyk7NFEsaMYNpGL9qfoH+AOOEPfJuI6OmAAAAAElFTkSuQmCC","width":22}
%---
%[text:image:5474]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:button:210a]
%   data: {"label":"View Example Features","run":"Section"}
%---
%[text:image:9caf]
%   data: {"align":"baseline","height":20,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAADUAAAAxCAYAAAB6d+FmAAAC0ElEQVR42u2aO4gTURSGs6Lugo1WW2ghgiyCr1VWbRSR9YEgKoKohcQmEDAviYhBIaVbbKEWYi22YidoobUItoqwjSui6wt119Wsj+\/onXAcJslMZpI7AxP4Sbh37pnz3TP3zJ2TyWQS9imVStvRK1G5XL5ZqVRWZpL8MUCf0G+lz+hYIoGIyDYPIEc\/i8ViLmkRGkMfWwA5WkD7EwHEutmCs+87ADl6zfHLm4MLhcIqGs7RcV0WoA1xCa3vIkL\/CTsX\/w7G2Bka5oIMjlo4M6GBmOTRABHSeirh3S0LzSYQugHHgAPEJG+l7UOXtr6LgQeqYQZdRVf6Jc5frdfriyKIkOgHQToi1+0XpxGD+ywnhc348a5bICboqLMYmx02784hgRYAOqEzjHWoSIHiABU5kG2osECMP9lqC2IFiqS0qSdAtqAM0Ey3QOhUp81iX6F6DtRvKM6xsedA\/YQKCdQgyx0PcrKeQ4WNkE4K+LhGb6usQOHQOnnOCb31+WdrNW1TQC22BoW9Ddh9i6bRfNDdNkCH1c59LW0vpc8qFDYfo\/tkvMFqtbqM3xdkffgAmseXQ44dM3ba6bcGlc1mh9yzbaK3k\/Y37YAYc9Dl47A+xhoU0dlh7A579I3qRx6lbwAd8PAxHlA4V5BF3ea8Z11Ac62e52IDhb1bZuZL+lFdRWtQpflZzj3exlZsIvVc2b7jdW8xiWSWVL2ng4\/2ofL5\/Ars\/XJdXudN9wC\/R4Ce5PurFH58RN0+FLb2et130D1VVJlCu3zasw9FFC67dwboialUnZadQcBJsg+F09ewd9tkwLFcLrckZOTjkSgi3pmkUClUCpVCpVApVAqVQqVQ0UDp6s5IHKFMeaz5doufYuYz9bf\/XXmXQaqgcZH4I34pqBd+Qluz\/LpBUF3qCEUol3LgwyQAEbFHUrDxW6OTyk7NFEsaMYNpGL9qfoH+AOOEPfJuI6OmAAAAAElFTkSuQmCC","width":22}
%---
%[control:dropdown:2af3]
%   data: {"defaultValue":"\"Select\"","itemLabels":["Select","a.","b.","c.","d."],"items":["\"Select\"","\"a.\"","\"b.\"","\"c.\"","\"d.\""],"label":"Select an answer.","run":"Section"}
%---
%[text:image:880c]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:dropdown:a001]
%   data: {"defaultValue":"\"Periodic signal\"","itemLabels":["Periodic signal","Quadratic trend","Cubic trend","Mixed nonlinear signal"],"items":["\"Periodic signal\"","\"Quadratic trend\"","\"Cubic trend\"","\"Mixed nonlinear signal\""],"label":"Select a dataset.","run":"SectionAndStaleSectionsAbove"}
%---
%[control:button:a002]
%   data: {"label":"Plot Selected Dataset","run":"Section"}
%---
%[text:image:5753]
%   data: {"align":"baseline","height":20,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB8AAAAcCAYAAACZOmSXAAACP0lEQVR42mNgoCLIy8vzys\/Pf15QUNDNQE9QWFioBLT4CxD\/B2GgA5LoZjnQwi0wi6H4TVlZGS89LA5FsxiGK2hqcW5urijQkidAfA+L5S\/S0tJYaWU3I9CCjUC8GYg\/YfM9MBH60yq4G6GW1OEIdhBeT1VLQUEJNLQDavg2IJ6Kx\/IfwJQvQLGlDQ0NbECDsoEGXoEa\/BUYrDpA+gMey0FBH0+RxdnZ2fJAg26gGVwKdEwBPouheCslFgsDDbiDZuC2kpISbiD9lAjLfwILISFyE9YKNMPugwxDSnDE4GSiLQwNDWUGxSfUcjkgPgU15DMQ6xUVFamBEhMJlu8nqowGWtoCLThAmqYlJCRwAAsTdmD0zgTy\/UBsIH2GBItB+C\/IExgWggwHSkQB8V4g\/odF4zmgg1Rh6oGOmESixdiLW6BBlUDBdwQ0\/QCGiC80CnLItBiEr6JYXlxcLAItInFp+AbE7lCHBgDZfyiw\/D8wygwxymho4fENTfFnoLgDksU\/KbEYivtxtURApdVlqKK7QFfqQ4M6HIh\/UcFicD0PSmNYHQBNfMWZmZmCUB8XQFMqqZaAsmQNKFsCPWUFpBciJeYogtkuKyuLB2h3EFDzJhItfgZMoLo42nigqvcgSfU20BGLSLBYCU\/jQx9UJAPVmBBte3l5OT8RWfIrMYbm5OQogqKE1DK+FV8JBsoRxJqFM9HhsVwciL\/jsLyQHi3V+VgsrmGgBwAGrRFyHJNUVVLJATuBli4FYnVKzAEAi4Bewge+mbwAAAAASUVORK5CYII=","width":23}
%---
%[text:image:9c8f]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:dropdown:a003]
%   data: {"defaultValue":"FeatureItems(1)","itemLabels":["Square","Cube","Square Root","Logarithm","Exponential","Sine","Cosine","Reciprocal"],"items":["FeatureItems(1)","FeatureItems(2)","FeatureItems(3)","FeatureItems(4)","FeatureItems(5)","FeatureItems(6)","FeatureItems(7)","FeatureItems(8)"],"itemsVariable":"FeatureItems","label":"Select a feature vector.","run":"SectionAndStaleSectionsAbove"}
%---
%[control:dropdown:8575]
%   data: {"defaultValue":"PeriodItems(4)","itemLabels":["0.5","1","2","2*pi","4*pi"],"items":["PeriodItems(1)","PeriodItems(2)","PeriodItems(3)","PeriodItems(4)","PeriodItems(5)"],"itemsVariable":"PeriodItems","label":"Select a period for sine\/cosine.","run":"SectionAndStaleSectionsAbove"}
%---
%[control:button:a004]
%   data: {"label":"Test Selected Transformation","run":"Section"}
%---
%[text:image:8caf]
%   data: {"align":"baseline","height":20,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAADUAAAAxCAYAAAB6d+FmAAAC0ElEQVR42u2aO4gTURSGs6Lugo1WW2ghgiyCr1VWbRSR9YEgKoKohcQmEDAviYhBIaVbbKEWYi22YidoobUItoqwjSui6wt119Wsj+\/onXAcJslMZpI7AxP4Sbh37pnz3TP3zJ2TyWQS9imVStvRK1G5XL5ZqVRWZpL8MUCf0G+lz+hYIoGIyDYPIEc\/i8ViLmkRGkMfWwA5WkD7EwHEutmCs+87ADl6zfHLm4MLhcIqGs7RcV0WoA1xCa3vIkL\/CTsX\/w7G2Bka5oIMjlo4M6GBmOTRABHSeirh3S0LzSYQugHHgAPEJG+l7UOXtr6LgQeqYQZdRVf6Jc5frdfriyKIkOgHQToi1+0XpxGD+ywnhc348a5bICboqLMYmx02784hgRYAOqEzjHWoSIHiABU5kG2osECMP9lqC2IFiqS0qSdAtqAM0Ey3QOhUp81iX6F6DtRvKM6xsedA\/YQKCdQgyx0PcrKeQ4WNkE4K+LhGb6usQOHQOnnOCb31+WdrNW1TQC22BoW9Ddh9i6bRfNDdNkCH1c59LW0vpc8qFDYfo\/tkvMFqtbqM3xdkffgAmseXQ44dM3ba6bcGlc1mh9yzbaK3k\/Y37YAYc9Dl47A+xhoU0dlh7A579I3qRx6lbwAd8PAxHlA4V5BF3ea8Z11Ac62e52IDhb1bZuZL+lFdRWtQpflZzj3exlZsIvVc2b7jdW8xiWSWVL2ng4\/2ofL5\/Ars\/XJdXudN9wC\/R4Ce5PurFH58RN0+FLb2et130D1VVJlCu3zasw9FFC67dwboialUnZadQcBJsg+F09ewd9tkwLFcLrckZOTjkSgi3pmkUClUCpVCpVApVAqVQqVQ0UDp6s5IHKFMeaz5doufYuYz9bf\/XXmXQaqgcZH4I34pqBd+Qluz\/LpBUF3qCEUol3LgwyQAEbFHUrDxW6OTyk7NFEsaMYNpGL9qfoH+AOOEPfJuI6OmAAAAAElFTkSuQmCC","width":22}
%---
%[control:dropdown:58ad]
%   data: {"defaultValue":"\"Select\"","itemLabels":["Select","a.","b.","c.","d."],"items":["\"Select\"","\"a.\"","\"b.\"","\"c.\"","\"d.\""],"label":"Select an answer.","run":"Section"}
%---
%[text:image:2800]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:dropdown:a005]
%   data: {"defaultValue":"\"Logarithmic growth\"","itemLabels":["Exponential growth","Logarithmic growth","Sinusoidal pattern"],"items":["\"Exponential growth\"","\"Logarithmic growth\"","\"Sinusoidal pattern\""],"label":"Select a dataset.","run":"SectionAndStaleSectionsAbove"}
%---
%[control:button:a006]
%   data: {"label":"Plot Dataset","run":"Section"}
%---
%[text:image:5632]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:button:a007]
%   data: {"label":"Evaluate Models","run":"Section"}
%---
%[text:image:0ec3]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:button:a008]
%   data: {"label":"Visualize Best Transformation","run":"Section"}
%---
%[text:image:9ff5]
%   data: {"align":"baseline","height":20,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAADUAAAAxCAYAAAB6d+FmAAAC0ElEQVR42u2aO4gTURSGs6Lugo1WW2ghgiyCr1VWbRSR9YEgKoKohcQmEDAviYhBIaVbbKEWYi22YidoobUItoqwjSui6wt119Wsj+\/onXAcJslMZpI7AxP4Sbh37pnz3TP3zJ2TyWQS9imVStvRK1G5XL5ZqVRWZpL8MUCf0G+lz+hYIoGIyDYPIEc\/i8ViLmkRGkMfWwA5WkD7EwHEutmCs+87ADl6zfHLm4MLhcIqGs7RcV0WoA1xCa3vIkL\/CTsX\/w7G2Bka5oIMjlo4M6GBmOTRABHSeirh3S0LzSYQugHHgAPEJG+l7UOXtr6LgQeqYQZdRVf6Jc5frdfriyKIkOgHQToi1+0XpxGD+ywnhc348a5bICboqLMYmx02784hgRYAOqEzjHWoSIHiABU5kG2osECMP9lqC2IFiqS0qSdAtqAM0Ey3QOhUp81iX6F6DtRvKM6xsedA\/YQKCdQgyx0PcrKeQ4WNkE4K+LhGb6usQOHQOnnOCb31+WdrNW1TQC22BoW9Ddh9i6bRfNDdNkCH1c59LW0vpc8qFDYfo\/tkvMFqtbqM3xdkffgAmseXQ44dM3ba6bcGlc1mh9yzbaK3k\/Y37YAYc9Dl47A+xhoU0dlh7A579I3qRx6lbwAd8PAxHlA4V5BF3ea8Z11Ac62e52IDhb1bZuZL+lFdRWtQpflZzj3exlZsIvVc2b7jdW8xiWSWVL2ng4\/2ofL5\/Ars\/XJdXudN9wC\/R4Ce5PurFH58RN0+FLb2et130D1VVJlCu3zasw9FFC67dwboialUnZadQcBJsg+F09ewd9tkwLFcLrckZOTjkSgi3pmkUClUCpVCpVApVAqVQqVQ0UDp6s5IHKFMeaz5doufYuYz9bf\/XXmXQaqgcZH4I34pqBd+Qluz\/LpBUF3qCEUol3LgwyQAEbFHUrDxW6OTyk7NFEsaMYNpGL9qfoH+AOOEPfJuI6OmAAAAAElFTkSuQmCC","width":22}
%---
%[control:dropdown:51b5]
%   data: {"defaultValue":"\"Select\"","itemLabels":["Select","a.","b.","c.","d."],"items":["\"Select\"","\"a.\"","\"b.\"","\"c.\"","\"d.\""],"label":"Select an answer.","run":"Section"}
%---
%[text:image:5a72]
%   data: {"align":"baseline","height":20,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB8AAAAcCAYAAACZOmSXAAACP0lEQVR42mNgoCLIy8vzys\/Pf15QUNDNQE9QWFioBLT4CxD\/B2GgA5LoZjnQwi0wi6H4TVlZGS89LA5FsxiGK2hqcW5urijQkidAfA+L5S\/S0tJYaWU3I9CCjUC8GYg\/YfM9MBH60yq4G6GW1OEIdhBeT1VLQUEJNLQDavg2IJ6Kx\/IfwJQvQLGlDQ0NbECDsoEGXoEa\/BUYrDpA+gMey0FBH0+RxdnZ2fJAg26gGVwKdEwBPouheCslFgsDDbiDZuC2kpISbiD9lAjLfwILISFyE9YKNMPugwxDSnDE4GSiLQwNDWUGxSfUcjkgPgU15DMQ6xUVFamBEhMJlu8nqowGWtoCLThAmqYlJCRwAAsTdmD0zgTy\/UBsIH2GBItB+C\/IExgWggwHSkQB8V4g\/odF4zmgg1Rh6oGOmESixdiLW6BBlUDBdwQ0\/QCGiC80CnLItBiEr6JYXlxcLAItInFp+AbE7lCHBgDZfyiw\/D8wygwxymho4fENTfFnoLgDksU\/KbEYivtxtURApdVlqKK7QFfqQ4M6HIh\/UcFicD0PSmNYHQBNfMWZmZmCUB8XQFMqqZaAsmQNKFsCPWUFpBciJeYogtkuKyuLB2h3EFDzJhItfgZMoLo42nigqvcgSfU20BGLSLBYCU\/jQx9UJAPVmBBte3l5OT8RWfIrMYbm5OQogqKE1DK+FV8JBsoRxJqFM9HhsVwciL\/jsLyQHi3V+VgsrmGgBwAGrRFyHJNUVVLJATuBli4FYnVKzAEAi4Bewge+mbwAAAAASUVORK5CYII=","width":23}
%---
%[text:image:321b]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:button:9b34]
%   data: {"label":"Generate Data with Hidden Structure","run":"Section"}
%---
%[text:image:10e3]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:button:97db]
%   data: {"label":"Run Baseline Model (Raw Features)","run":"Section"}
%---
%[text:image:97ec]
%   data: {"align":"baseline","height":20,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB8AAAAcCAYAAACZOmSXAAACP0lEQVR42mNgoCLIy8vzys\/Pf15QUNDNQE9QWFioBLT4CxD\/B2GgA5LoZjnQwi0wi6H4TVlZGS89LA5FsxiGK2hqcW5urijQkidAfA+L5S\/S0tJYaWU3I9CCjUC8GYg\/YfM9MBH60yq4G6GW1OEIdhBeT1VLQUEJNLQDavg2IJ6Kx\/IfwJQvQLGlDQ0NbECDsoEGXoEa\/BUYrDpA+gMey0FBH0+RxdnZ2fJAg26gGVwKdEwBPouheCslFgsDDbiDZuC2kpISbiD9lAjLfwILISFyE9YKNMPugwxDSnDE4GSiLQwNDWUGxSfUcjkgPgU15DMQ6xUVFamBEhMJlu8nqowGWtoCLThAmqYlJCRwAAsTdmD0zgTy\/UBsIH2GBItB+C\/IExgWggwHSkQB8V4g\/odF4zmgg1Rh6oGOmESixdiLW6BBlUDBdwQ0\/QCGiC80CnLItBiEr6JYXlxcLAItInFp+AbE7lCHBgDZfyiw\/D8wygwxymho4fENTfFnoLgDksU\/KbEYivtxtURApdVlqKK7QFfqQ4M6HIh\/UcFicD0PSmNYHQBNfMWZmZmCUB8XQFMqqZaAsmQNKFsCPWUFpBciJeYogtkuKyuLB2h3EFDzJhItfgZMoLo42nigqvcgSfU20BGLSLBYCU\/jQx9UJAPVmBBte3l5OT8RWfIrMYbm5OQogqKE1DK+FV8JBsoRxJqFM9HhsVwciL\/jsLyQHi3V+VgsrmGgBwAGrRFyHJNUVVLJATuBli4FYnVKzAEAi4Bewge+mbwAAAAASUVORK5CYII=","width":23}
%---
%[text:image:0f62]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:button:7428]
%   data: {"label":"Create Engineered Features","run":"Section"}
%---
%[text:image:8b32]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:button:76b7]
%   data: {"label":"Compare Feature Sets","run":"Section"}
%---
%[text:image:25a1]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:button:7985]
%   data: {"label":"Visualize Best Model","run":"Section"}
%---
%[text:image:071d]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:button:81a1]
%   data: {"label":"Run Stepwise Model","run":"Section"}
%---
%[text:image:4d0a]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:button:6abb]
%   data: {"label":"Show Paths","run":"Section"}
%---
%[text:image:40c5]
%   data: {"align":"bottom","height":24,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAsCAYAAAAXb\/p7AAADlklEQVR42u1YS0hUYRQejR4UvR+SvaCyWiS2DIoCKWjVYzG2SsYWQ+a8HRwXFkOgqdGLSoSeqyBaJUGLCKGkNpGtgiyScnpYBpaU5au+E+eH03Wu93rvP2OEFw46955z\/u8\/7\/\/3eDQ+4XD4Eui65199AK4d1DEJcBLgfw0wGo2ujkQi1yoqKlY5AFgDqnWw5lpaMxaLrbBkDgaDm7HIEKjTCcjxPqFQqABrdYEGsHaRXaESCAyCXpNFMwwuReDw\/77xusurQGJna0ysPR2K94CnGdQKesnUyu92J5PJaelk4c51Chzcu9dp0O9nkO3yvd\/vnwqlEbzvAf2yoB5sIkwyBt0doJ+0Qbdu2AXyC8UrOVuNQH5Q3IJegfrTfH8ikwC\/A9hjsdaYCQQCG6D4vVj0DShB7+HKXMGaQ\/EFADEGrPhJdn1GAhoZvRDKX4jFTvt8vhlWchSD4D0OGiE5AH9eXl4+PxNF+IoCB8sccyBfreQB8qJWcAC0CYqHeYE2cqEDNTmQvcc6hlC+CnXWq\/PCtTtdeGGr0HNWFz7aeTcr\/eT1eqe41PVWJYxd62zkovwXqQ6Cv8vErm9r8MZNEctLVf9Ph4GwecSOjPSQu8V28e6chmRrFPq28btHJhhSBKDIBH0B726HEDilAWCtsGCx6MmjMNgaHqBkiygPl3UmHE1OrjOEiqoqsqDHGizYxrqGAXCOriL9jJUOoq3lO9UDQItpQGD3PtXZRapFHB51oSchwiWsDWA8Hl8Cpb2svA+WWO4AXJ7Q0Z1IJObq7sUBN\/UQLr0hrHfANSCaQihrobiBf+dC+QOxSNk4MrdEyN1VvRy6T+DdVbOp2wpcCyutN8yDahjtVZ3A4sS2ALwflYxhaK1n0C22QfL8dkuNRYZBlKxxRLj6gg3XNgj+w8beLOriHcv50gocJ8wsfP\/ASgfMDlRs8XzwfGPeThMr2QcpEqFprJmPSoSwSvMYfCcFX6nFlNPEfAGrUuC1GkhxQpspTnTfKysrFxl5qqqqZouy0mU81ZmApB6cp2vKlrFVk+Z7TGRuPOsXRZSNfGYmEO\/ofoXmOiKKS3Ga6wPYeRNxk9Vo49BONAIL1mUdIBa9bxPgn+zMOkAqIXDdQbp1sKAy6uWeyWd0Cyuk5LDh3pTtez\/NSVJqNwbh5kNZB8htkTrP1zHA9dM1nZ07nExmc50ZQGA7M+GxyLden9MA\/OLm\/KKe34xPoKAD7jPkAAAAAElFTkSuQmCC","width":22}
%---
%[text:image:796a]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:button:1dd9]
%   data: {"label":"Compare Models","run":"Section"}
%---
%[text:image:1327]
%   data: {"align":"bottom","height":24,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAsCAYAAAAXb\/p7AAADlklEQVR42u1YS0hUYRQejR4UvR+SvaCyWiS2DIoCKWjVYzG2SsYWQ+a8HRwXFkOgqdGLSoSeqyBaJUGLCKGkNpGtgiyScnpYBpaU5au+E+eH03Wu93rvP2OEFw46955z\/u8\/7\/\/3eDQ+4XD4Eui65199AK4d1DEJcBLgfw0wGo2ujkQi1yoqKlY5AFgDqnWw5lpaMxaLrbBkDgaDm7HIEKjTCcjxPqFQqABrdYEGsHaRXaESCAyCXpNFMwwuReDw\/77xusurQGJna0ysPR2K94CnGdQKesnUyu92J5PJaelk4c51Chzcu9dp0O9nkO3yvd\/vnwqlEbzvAf2yoB5sIkwyBt0doJ+0Qbdu2AXyC8UrOVuNQH5Q3IJegfrTfH8ikwC\/A9hjsdaYCQQCG6D4vVj0DShB7+HKXMGaQ\/EFADEGrPhJdn1GAhoZvRDKX4jFTvt8vhlWchSD4D0OGiE5AH9eXl4+PxNF+IoCB8sccyBfreQB8qJWcAC0CYqHeYE2cqEDNTmQvcc6hlC+CnXWq\/PCtTtdeGGr0HNWFz7aeTcr\/eT1eqe41PVWJYxd62zkovwXqQ6Cv8vErm9r8MZNEctLVf9Ph4GwecSOjPSQu8V28e6chmRrFPq28btHJhhSBKDIBH0B726HEDilAWCtsGCx6MmjMNgaHqBkiygPl3UmHE1OrjOEiqoqsqDHGizYxrqGAXCOriL9jJUOoq3lO9UDQItpQGD3PtXZRapFHB51oSchwiWsDWA8Hl8Cpb2svA+WWO4AXJ7Q0Z1IJObq7sUBN\/UQLr0hrHfANSCaQihrobiBf+dC+QOxSNk4MrdEyN1VvRy6T+DdVbOp2wpcCyutN8yDahjtVZ3A4sS2ALwflYxhaK1n0C22QfL8dkuNRYZBlKxxRLj6gg3XNgj+w8beLOriHcv50gocJ8wsfP\/ASgfMDlRs8XzwfGPeThMr2QcpEqFprJmPSoSwSvMYfCcFX6nFlNPEfAGrUuC1GkhxQpspTnTfKysrFxl5qqqqZouy0mU81ZmApB6cp2vKlrFVk+Z7TGRuPOsXRZSNfGYmEO\/ofoXmOiKKS3Ga6wPYeRNxk9Vo49BONAIL1mUdIBa9bxPgn+zMOkAqIXDdQbp1sKAy6uWeyWd0Cyuk5LDh3pTtez\/NSVJqNwbh5kNZB8htkTrP1zHA9dM1nZ07nExmc50ZQGA7M+GxyLden9MA\/OLm\/KKe34xPoKAD7jPkAAAAAElFTkSuQmCC","width":22}
%---
%[text:image:3198]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:button:5eae]
%   data: {"label":"Compare Fits","run":"Section"}
%---
