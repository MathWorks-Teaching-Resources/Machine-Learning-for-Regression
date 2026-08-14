%[text] # Optimization and Gradient Descent for Regression
%[text] [⇦ Main Menu](file:MainMenu.m)
%[text] This live script treats regression as an optimization problem and uses gradient descent as the main example of how machine learning models are trained iteratively.
%[text]{"align":"center"} ![Optimization by gradient descent](text:image:4dae)
%[text:tableOfContents]{"heading":"Table of Contents"}
%[text] **Before you get started:**
%[text] %[text:anchor:H_BF646A47] This live script is intended to be used with the code hidden. On the **View** tab of the MATLAB toolstrip, in the **View** section, select **Hide Code**.  Alternately, select **Hide Code** using the icon ![live script code hidden icon](text:image:7219) at the top right of the Live Editor pane.
%[text] ![Lightbulb mark](text:image:315f) Although the code is hidden, some interactivity requires familiarity with MATLAB. If you need more instruction, consider taking [MATLAB Onramp](https://matlabacademy.mathworks.com/details/matlab-onramp/gettingstarted), a free 2 hour online tutorial that teaches the essentials of MATLAB.
%[text] %[text:anchor:H_8F8A032D] ![Warning symbol](text:image:3854)   For an optimal experience, follow the instructions and steps in the given sequence. Proceed to a new section only after completing the preceding one. Some sections depend on variables created in prior sections and will generate errors if run out of order.
%[text] The ![Try this icon](text:image:31dc)  and  ![Exercise icon](text:image:5066) icons refer to two different types of interactive activities that you will find in this script. The ![Try this icon](text:image:9073)  usually indicates an interaction where you will explore the visualization of some concept introduced in this script. The ![Exercise icon](text:image:8e99) interactions are designed to challenge your understanding of those concepts and may be used for grading and completion checks by your professor.
DefaultStyle = DefaultPlotStyle();
ApplyDefaultStyle(DefaultStyle);
%%
%[text] ## Optimization in the Machine Learning Workflow
%[text] In a common machine learning process, we define the prediction goal, prepare data, train a model, evaluate it, and then decide what to improve next. Optimization is the part of that process that updates model parameters to reduce error.
%[text] This process builds on a familiar idea from regression. When we fit a regression model, we are already solving an optimization problem: choosing parameter values, such as slope and intercept, that minimize prediction error. For simple models, this can often be done directly in a single calculation.
%[text] As models become more flexible and involve more parameters, that direct approach becomes less practical. Instead, we improve the model step by step, using the current error to guide updates to the parameters. This is where optimization becomes the engine inside training, and gradient descent becomes a useful example of iterative improvement.
%[text] In this context:
%[text] - **Optimization** determines how parameters are updated to reduce error.
%[text] - **Iteration** uses training and evaluation results to decide what to do next. \
%[text] This lesson focuses on regression as an optimization problem and on gradient descent as a standard way to improve model parameters step by step.
%[text]  ![Exercise icon](text:image:0a8e) **Exercise 1.** Why is training a regression model an optimization problem?
%[text]         a.  Because regression never uses residuals. 
%[text]         b. Because training only plots the regression line.
%[text]         c. Because training chooses parameter values that minimize prediction error.
%[text]         d. Because model parameters stay fixed during training.
CheckAnswer("Exercise1","Select")  %[control:dropdown:25bc]{"position":[25,33]}
%%
%[text] ## Regression as an Optimization Problem
%[text] A regression model first produces a residual for each sample: the difference between the observed response and the prediction.
%[text]{"align":"center"} $ e\_i = y\_i - \\hat{y}\_i ${"altText":" e\_i = y\_i - \hat{y}\_i "}
%[text] To turn many residuals into a single quantity that can be minimized, we square them and combine them. The total squared error is the sum of squared errors (SSE):
%[text]{"align":"center"} $ SSE = \\sum\_{i=1}^{n}(y\_i - \\hat{y}\_i)^2 ${"altText":" SSE = \sum\_{i=1}^{n}(y\_i - \hat{y}\_i)^2 "}
%[text] The average squared residual is the mean squared error (MSE):
%[text]{"align":"center"} $MSE=\\frac{1}{n}\\sum\_{i=1}^{n}(y\_i-\\hat{y}\_i)^2${"altText":"MSE=\frac{1}{n}\sum\_{i=1}^{n}(y\_i-\hat{y}\_i)^2"}
%[text] where,
%[text] - $y\_i${"altText":"y\_i"} is the actual response for the $i^{th}${"altText":"i^{th}"} sample
%[text] - $\\hat{y}\_i${"altText":"\hat{y}\_i"} is the predicted response for the $i^{th}${"altText":"i^{th}"} sample
%[text] - $n${"altText":"n"} is the number of samples \
%[text] For a fixed dataset, minimizing SSE and minimizing MSE give the same best-fit parameters because MSE is just SSE divided by the constant $n${"altText":"n"}. In this lesson, we use MSE as the cost function because it stays on a per-observation scale and is easier to compare across datasets.
%[text] For a straight-line model, the predictions are:
%[text]{"align":"center"} $ \\hat{y}\_i = \\theta\_1 x\_i + \\theta\_0 ${"altText":" \hat{y}\_i = \theta\_1 x\_i + \theta\_0 "}
%[text] Substituting this model into the MSE formula makes the cost depend directly on the parameters $\\theta=(\\theta\_1,\\theta\_0)${"altText":"\theta=(\theta\_1,\theta\_0)"}:
%[text]{"align":"center"} $ MSE(\\theta\_1,\\theta\_0) = \\frac{1}{n}\\sum\_{i=1}^{n}(y\_i - (\\theta\_1 x\_i + \\theta\_0))^2 ${"altText":" MSE(\theta\_1,\theta\_0) = \frac{1}{n}\sum\_{i=1}^{n}(y\_i - (\theta\_1 x\_i + \theta\_0))^2 "}
%[text] The optimization question is now explicit: which slope and intercept make this cost as small as possible? For simple linear regression, ordinary least squares can often answer that question directly. For more complex models, however, the parameters must be updated gradually by an iterative method such as gradient descent.
%%
%[text] ## Compare SSE and MSE
%[text] Before exploring how optimization works, it is helpful to compare two common error measures.
%[text]{"align":"center"} ![](text:image:68e7)
%[text] The sum of squared errors (**SSE**) adds all squared residuals together, so it increases both when errors are larger and when there are more data points. The mean squared error (**MSE**) divides this total by the number of samples, measuring the average squared error per observation. Because it is normalized by dataset size, **MSE** provides a more consistent basis for comparing model performance across datasets.
%[text] For example, suppose a house price model has an **SSE** of 4,000,000 when evaluated on 100 homes. The corresponding **MSE** is 40,000. If the same model is evaluated on 1,000 homes, the **SSE** might increase to 20,000,000 simply because there are more observations. Dividing by the number of homes gives an **MSE** of 20,000, showing that the average squared error per prediction is actually lower. **MSE** therefore provides a fairer basis for comparing models and datasets of different sizes. In summary, **SSE** measures the total squared error across all observations, while MSE measures the average squared error per observation, making it easier to compare model performance across datasets of different sizes.
%[text] One limitation of **MSE** is that it is expressed in squared units, which can make it harder to interpret directly.
%[text:table]
%[text] | **Metric** | **Measures** | **Why Use it** |
%[text] | --- | --- | --- |
%[text] | SSE | Total squared error | Shows overall error |
%[text] | MSE | Average squared error | Enables comparison across datasets |
%[text:table]
%[text] 
%[text] In the next activity, keep one comparison in mind: if the overall noise level stays similar but the dataset gets larger, **SSE** usually grows because more squared residuals are being added, while **MSE** stays on an average-error scale.
%[text] ![Try this icon](text:image:277f) **Try**. Use the Noise Level spinner and click **Compare SSE and MSE** to view differences between a small dataset and a large dataset.
DefaultStyle = DefaultPlotStyle();
ApplyDefaultStyle(DefaultStyle);

ErrorScale = 4; %[control:spinner:8808]{"position":[14,15]}
  %[control:button:7a05]{"position":[1,2]}
Comparison = MakeSSEComparison(ErrorScale);
disp(Comparison.Metrics)
tiledlayout(1,2,Padding="compact",TileSpacing="compact")
AxSmall = nexttile;
scatter(AxSmall,Comparison.XSmall,Comparison.YSmall,DefaultStyle.DataMarkerSize,"filled",MarkerFaceAlpha=DefaultStyle.DataMarkerFaceAlpha,SeriesIndex=DefaultStyle.DataSeriesIndex)
hold(AxSmall,"on")
plot(AxSmall,Comparison.XSmallLine,Comparison.YSmallFitLine,LineWidth=DefaultStyle.PrimaryLineWidth,SeriesIndex=DefaultStyle.FitSeriesIndex)
hold(AxSmall,"off")
xlabel(AxSmall,"$x$",Interpreter=DefaultStyle.Interpreter)
ylabel(AxSmall,"$y$",Interpreter=DefaultStyle.Interpreter)
title(AxSmall,"Small Dataset",Interpreter=DefaultStyle.Interpreter)
text(AxSmall,min(Comparison.XSmall),max(Comparison.YSmall)+DefaultStyle.AnnotationOffset,{sprintf("N = %d",Comparison.NSmall),sprintf("SSE = %.2f",Comparison.SSESmall),sprintf("MSE = %.2f",Comparison.MSESmall)},Interpreter=DefaultStyle.Interpreter,VerticalAlignment="top")
ApplyDefaultAxesStyle(AxSmall,DefaultStyle)

AxLarge = nexttile;
scatter(AxLarge,Comparison.XLarge,Comparison.YLarge,DefaultStyle.DataMarkerSize,"filled",MarkerFaceAlpha=DefaultStyle.DataMarkerFaceAlpha,SeriesIndex=DefaultStyle.DataSeriesIndex)
hold(AxLarge,"on")
plot(AxLarge,Comparison.XLargeLine,Comparison.YLargeFitLine,LineWidth=DefaultStyle.PrimaryLineWidth,SeriesIndex=DefaultStyle.FitSeriesIndex)
hold(AxLarge,"off")
xlabel(AxLarge,"$x$",Interpreter=DefaultStyle.Interpreter)
ylabel(AxLarge,"$y$",Interpreter=DefaultStyle.Interpreter)
title(AxLarge,"Large Dataset",Interpreter=DefaultStyle.Interpreter)
text(AxLarge,min(Comparison.XLarge),max(Comparison.YLarge)+DefaultStyle.AnnotationOffset,{sprintf("N = %d",Comparison.NLarge),sprintf("SSE = %.2f",Comparison.SSELarge),sprintf("MSE = %.2f",Comparison.MSELarge)},Interpreter=DefaultStyle.Interpreter,VerticalAlignment="top")
ApplyDefaultAxesStyle(AxLarge,DefaultStyle)
sgtitle("Comparing SSE and MSE",Interpreter=DefaultStyle.Interpreter)
%[text] ![Lightbulb mark](text:image:042e) **Reflect**. Which metric changes more strongly with dataset size: SSE or MSE?
%%
%[text] ## Direct Solution vs. Manual Improvement
%[text] Now that regression has been framed as an optimization problem, the next question is how that problem is solved.
%[text] For a straight-line model with one predictor, the optimal parameter values can often be computed directly using ordinary least squares. In MATLAB, functions such as `polyfit` perform this calculation in a single step. This does not remove optimization from the problem. It means that, for this simple model, the best solution can be found immediately without intermediate updates.
%[text] To better understand what this solution represents, it is helpful to start by looking at the observed data alone. We can then add different slope and intercept choices and see how those parameter choices affect model performance.
%[text] This manual approach makes the optimization process visible: different parameter values lead to different prediction errors, and better parameters produce lower error. However, even for this simple model, finding better parameters by trial and error is slow and inefficient.
%[text] ![Try this icon](text:image:76c6) **Try**. Click **Display Data** to display a plot of $y${"altText":"y"} vs. $x${"altText":"x"}.
DefaultStyle = DefaultPlotStyle();
ApplyDefaultStyle(DefaultStyle);

Data = MakeSimpleLinearData();
scatter(Data.X,Data.Y,DefaultStyle.EmphasisMarkerSize,"filled",MarkerFaceAlpha=DefaultStyle.DataMarkerFaceAlpha,SeriesIndex=DefaultStyle.DataSeriesIndex);
xlabel("$x$",Interpreter=DefaultStyle.Interpreter)
ylabel("$y$",Interpreter=DefaultStyle.Interpreter)
title("Observed Data",Interpreter=DefaultStyle.Interpreter)
ApplyDefaultAxesStyle(gca,DefaultStyle)
  %[control:button:252b]{"position":[1,2]}
%%
%[text] ![Try this icon](text:image:5964) **Try**. Use the **Theta 1** and **Theta 0** sliders to choose a slope and intercept, then click **Compare Manual and Direct Fit** to compare the manual guess with the direct least-squares solution.
DefaultStyle = DefaultPlotStyle();
ApplyDefaultStyle(DefaultStyle);
if exist("Data","var")
Theta1 = 1; %[control:slider:1c28]{"position":[10,11]}
Theta0 = 1; %[control:slider:4feb]{"position":[10,11]}
  %[control:button:028d]{"position":[1,2]}
Guess = [Theta1 Theta0];
FitSummary = CompareDirectFit(Data.X,Data.Y,Guess);
MSEGuess = FitSummary.Metrics.MSE(1);
MSEDirect = FitSummary.Metrics.MSE(2);
[XSorted,SortIndex] = sort(Data.X);
YGuessSorted = FitSummary.YGuess(SortIndex);
YDirectSorted = FitSummary.YDirect(SortIndex);
XLimits = [min(Data.X) max(Data.X)];
YLimits = [min(Data.Y)-DefaultStyle.FitYPadding max(Data.Y)+DefaultStyle.FitYPadding];

tiledlayout(1,2,Padding="compact",TileSpacing="compact")
nexttile
DataScatter = scatter(Data.X,Data.Y,DefaultStyle.EmphasisMarkerSize,"filled",MarkerFaceAlpha=DefaultStyle.DataMarkerFaceAlpha,SeriesIndex=DefaultStyle.DataSeriesIndex);
hold("on")
GuessLine = plot(XSorted,YGuessSorted,"--",LineWidth=DefaultStyle.PrimaryLineWidth,SeriesIndex=DefaultStyle.GuessSeriesIndex);
DirectLine = plot(XSorted,YDirectSorted,LineWidth=DefaultStyle.PrimaryLineWidth,SeriesIndex=DefaultStyle.DirectFitSeriesIndex);
hold("off")
xlim(XLimits)
ylim(YLimits)
xlabel("$x$",Interpreter=DefaultStyle.Interpreter)
ylabel("$y$",Interpreter=DefaultStyle.Interpreter)
title("Add Candidate Fits",Interpreter=DefaultStyle.Interpreter)
legend([DataScatter GuessLine DirectLine],["Data","Manual guess","Direct fit"],Location="best",Interpreter=DefaultStyle.Interpreter)
ApplyDefaultAxesStyle(gca,DefaultStyle)

AxErrorComparison = nexttile;
MSEBars = bar(AxErrorComparison,[MSEGuess MSEDirect]);
MSEBars.SeriesIndex = DefaultStyle.ComparisonSeriesIndex;
xticks(AxErrorComparison,[1 2])
xticklabels(AxErrorComparison,["Manual guess","Direct fit"])
ylabel(AxErrorComparison,"MSE",Interpreter=DefaultStyle.Interpreter)
title(AxErrorComparison,"Error Comparison",Interpreter=DefaultStyle.Interpreter)
ApplyDefaultAxesStyle(AxErrorComparison,DefaultStyle)
axis(AxErrorComparison,"padded")
text(AxErrorComparison,1,MSEGuess,sprintf("%.2f",MSEGuess),Interpreter=DefaultStyle.Interpreter,HorizontalAlignment="center",VerticalAlignment="bottom")
text(AxErrorComparison,2,MSEDirect,sprintf("%.2f",MSEDirect),Interpreter=DefaultStyle.Interpreter,HorizontalAlignment="center",VerticalAlignment="bottom")

disp("The direct-fit line is the parameter pair that minimizes prediction error for this model.")
else
    warning("Display data above.")
    return
end
%%
%[text] ## Why Machine Learning Needs Iterative Optimization
%[text] Direct solutions are convenient in simple cases, but they become impractical as models grow more complex. Machine learning models often include many parameters, nonlinear relationships, and high-dimensional inputs, making closed-form solutions difficult or impossible. In these cases, manually guessing parameter values is no longer effective.
%[text] Instead, machine learning relies on iterative optimization. Starting from an initial guess, the model repeatedly calculates the error and adjusts its parameters to reduce it. This iterative process gradually improves the model's predictions, and gradient descent is one of the most common algorithms used to guide these updates.
%[text] This distinction is important: optimization improves parameter values within a fixed model, while the broader iterate stage uses training and evaluation results to decide what to try next. Based on those results, we may adjust hyperparameters such as the learning rate or number of iterations, engineer new features, or even choose a different model.
%[text]  ![Exercise icon](text:image:91df) **Exercise 2.** Why do machine learning models often use iterative methods?
%[text]         a. Because more parameters always guarantee a closed-form solution.
%[text]         b. Because complex models often make a direct solution impractical, so parameters are improved step by step. 
%[text]         c. Because iterative methods remove the need for evaluation.
%[text]         d. Because machine learning ignores cost functions.
CheckAnswer("Exercise2","Select") %[control:dropdown:i00e]{"position":[25,33]}
%%
%[text] ## Gradient Descent
%[text] Gradient descent is a standard method for optimizing model parameters through iterative updates. Instead of solving the optimization problem in a single step, it gradually reduces prediction error by refining the parameters over time.
%[text] We begin with the same MSE cost used above, but now we write it in a way that makes the derivatives easier to read. For each sample, define the prediction error as:
%[text]{"align":"center"} $ e\_i(\\theta\_1,\\theta\_0)=\\hat{y}\_i-y\_i=\\theta\_1 x\_i + \\theta\_0 - y\_i ${"altText":" e\_i(\theta\_1,\theta\_0)=\hat{y}\_i-y\_i=\theta\_1 x\_i + \theta\_0 - y\_i "}
%[text] so the regression cost becomes
%[text]{"align":"center"} $ J(\\theta\_1,\\theta\_0) = \\frac{1}{n}\\sum\_{i=1}^{n} e\_i(\\theta\_1,\\theta\_0)^2 ${"altText":" J(\theta\_1,\theta\_0) = \frac{1}{n}\sum\_{i=1}^{n} e\_i(\theta\_1,\theta\_0)^2 "}
%[text] The gradient tells us how rapidly $J${"altText":"J"} changes when we change one parameter while holding the other fixed. Differentiating the squared-error term gives:
%[text]{"align":"center"} $ \\frac{\\partial J}{\\partial \\theta\_1} = \\frac{2}{n}\\sum\_{i=1}^{n} e\_i(\\theta\_1,\\theta\_0)x\_i = \\frac{2}{n}\\sum\_{i=1}^{n}(\\theta\_1 x\_i + \\theta\_0 - y\_i)x\_i ${"altText":" \frac{\partial J}{\partial \theta\_1} = \frac{2}{n}\sum\_{i=1}^{n} e\_i(\theta\_1,\theta\_0)x\_i = \frac{2}{n}\sum\_{i=1}^{n}(\theta\_1 x\_i + \theta\_0 - y\_i)x\_i "}
%[text]{"align":"center"} $ \\frac{\\partial J}{\\partial \\theta\_0} = \\frac{2}{n}\\sum\_{i=1}^{n} e\_i(\\theta\_1,\\theta\_0) = \\frac{2}{n}\\sum\_{i=1}^{n}(\\theta\_1 x\_i + \\theta\_0 - y\_i) ${"altText":" \frac{\partial J}{\partial \theta\_0} = \frac{2}{n}\sum\_{i=1}^{n} e\_i(\theta\_1,\theta\_0) = \frac{2}{n}\sum\_{i=1}^{n}(\theta\_1 x\_i + \theta\_0 - y\_i) "}
%[text] These derivatives show how slope and intercept each contribute to the current error. Gradient descent then updates both parameters in the negative-gradient direction:
%[text]{"align":"center"} $ \\theta\_1^{new} = \\theta\_1^{old} - \\alpha \\frac{\\partial J}{\\partial \\theta\_1}, \\qquad \\theta\_0^{new} = \\theta\_0^{old} - \\alpha \\frac{\\partial J}{\\partial \\theta\_0} ${"altText":" \theta\_1^{new} = \theta\_1^{old} - \alpha \frac{\partial J}{\partial \theta\_1}, \qquad \theta\_0^{new} = \theta\_0^{old} - \alpha \frac{\partial J}{\partial \theta\_0} "}
%[text] The size of each update is controlled by the **learning rate** ($\\alpha${"altText":"\alpha"}). If the learning rate is too small, progress is slow. If it is too large, the updates can overshoot the minimum or become unstable. Each iteration recomputes the gradient at the current parameter values and takes another step downhill on the cost surface.
%[text]  ![Exercise icon](text:image:019d) **Exercise 3.** What does gradient descent do at each step?
%[text]         a. It moves parameters opposite the gradient to reduce cost.
%[text]         b. It moves parameters in the direction of larger error.
%[text]         c. It stops after one update no matter what happens.
%[text]         d. It changes the data instead of the parameters.
CheckAnswer("Exercise3","Select"); %[control:dropdown:0801]{"position":[25,33]}
%%
%[text] ### Visualize the Gradient in 2D
%[text] A one-variable function makes it easier to focus on the role of the learning rate.
%[text] The learning rate controls how far gradient descent moves at each step. A small learning rate makes slow, steady progress toward the minimum. A moderate rate usually converges quickly and smoothly. However, a large learning rate can overshoot the minimum and cause the algorithm to oscillate back and forth, preventing it from settling. In this example, we will visualize how the learning rate affects both convergence speed and stability when minimizing $f(x)=x^2${"altText":"f(x)=x^2"}.
%[text] ![Try this icon](text:image:98a4) **Try**. Use the **Learning Rate Preset** slider to switch among the slow, stable, and oscillatory learning-rate choices, then click **Run 2D Gradient Descent** to explore how the learning rate influences convergence to the local minimum. 
DefaultStyle = DefaultPlotStyle();
ApplyDefaultStyle(DefaultStyle);
LearningRateChoice2D = 0; %[control:slider:8904]{"position":[24,25]}
  %[control:button:i008]{"position":[1,2]}
LearningRate2D = Resolve2DLearningRateChoice(LearningRateChoice2D);
disp("Selected learning rate: " + num2str(LearningRate2D,"%.2f"))
NumberOfIterations = AnimateGradientDescent(LearningRate2D,DefaultStyle);
if LearningRate2D < 1
    disp("Number of iterations until convergence: " + NumberOfIterations)
end
%[text] ![Lightbulb mark](text:image:09bd) **Reflect**. What happens when the learning rate is too low? What happens when it is too large?
%%
%[text] ### Visualize Gradient Descent on a Cost Surface
%[text] The previous example showed gradient descent on a simple one-variable function. In regression, the objective depends on two parameters: the slope $\\theta\_1${"altText":"\theta\_1"} and intercept $\\theta\_0${"altText":"\theta\_0"}. This creates a cost surface, where each point represents a possible parameter pair and the height corresponds to the mean squared error (MSE).
%[text] Gradient descent moves across this surface from an initial guess, updating the parameters to reduce error. As the algorithm progresses, it traces a path downhill, showing how the model improves step by step rather than jumping directly to the optimal solution.
%[text] The visualization brings this process to life through three connected views. The 3D surface plot shows the overall shape of the error landscape and highlights each iteration as a point moving downhill. The contour plot provides a top-down view of the same surface, where curves represent equal error levels and make the path toward the minimum easier to follow. At the same time, the data plot shows how the regression line updates with each step, gradually improving its fit to the data. Together, these views link parameter updates, error reduction, and model improvement.
%[text] ![Try this icon](text:image:85ba) **Try**. Choose a **Learning Rate** and a **Number of Steps** with the sliders, then click **Visualize Gradient Descent** to trace gradient descent across the MSE surface.
%[text] **Expected Learning Rate Results**
%[text] - **Efficient:** Parameters move steadily toward the minimum, and MSE decreases consistently.
%[text] - **Too small:** Parameters update slowly, so MSE decreases gradually and convergence takes longer.
%[text] - **Too large:** Parameters overshoot the minimum, causing oscillations and unstable MSE values. \
DefaultStyle = DefaultPlotStyle();
ApplyDefaultStyle(DefaultStyle);
OptimizationData = LoadOptimizationData();
X = OptimizationData.X;
Y = OptimizationData.Y;
LearningRate = 0.1; %[control:slider:7991]{"position":[16,19]}
NumSteps = 1; %[control:slider:1a10]{"position":[12,13]}
  %[control:button:3816]{"position":[1,2]}
GradientDescent(X,Y,NumSteps,LearningRate,DefaultStyle);
%[text] ![Lightbulb mark](text:image:2051) **Reflect**. How does the learning rate affect the parameter path and MSE trend? Which rates lead to efficient convergence, slow progress, or unstable behavior?
%%
%[text] ## Optimization in the Iterate Stage
%[text] Optimization does not happen in isolation. Reducing training cost is important, but it is only one part of the broader *iterate* stage in the machine learning workflow. Optimization improves parameter values within a fixed model by minimizing the cost function. In contrast, the *iterate* stage uses training and validation results to decide what to try next.
%[text] Based on those results, we may retrain the model with a different learning rate or number of iterations, engineer new features, or switch to an entirely different model. Optimization improves the current parameter values, while iteration determines whether the current approach itself should be refined or replaced.
%[text]  ![Exercise icon](text:image:6b2a) **Exercise 4.** What does the full iterate stage add beyond optimization?
%[text]         a.  It only means lowering the training cost once.
%[text]         b. It repeats gradient descent until the model is perfect.
%[text]         c. It removes the need to compare models or features.
%[text]         d. It adds evaluation and decisions about what to change next, not just parameter updates.
CheckAnswer("Exercise4","Select") %[control:dropdown:1221]{"position":[25,33]}
%%
%[text] ## Summary
%[text] In this lesson, we reframed regression training as an optimization problem and used gradient descent to show how iterative training improves model parameters step by step.
%[text] **Key Takeaways**
%[text] - SSE adds the squared residuals, while MSE divides that total by the number of samples.
%[text] - For a fixed dataset, minimizing SSE or MSE gives the same best-fit parameters.
%[text] - Simple linear regression can often be solved directly by least squares.
%[text] - Machine learning models often need iterative optimization because direct solutions are not practical.
%[text] - Gradient descent uses repeated negative-gradient updates to move toward lower-cost parameter values.
%[text] - The full iterate stage includes evaluation and decisions about what to change next, not just parameter updates. \
%%
%[text] ## Further Exploration
%[text] Review the [Additional Resources](file:../InstructorResources/AdditionalResources.m:M_6138) section to find more materials for further learning.
%%
%[text] [⇦ Return to Main Menu](file:MainMenu.m)
%%
%[text] ## Local Helper Functions
%[text] If you wish to see the implementation details, switch to **Output Inline** from the **View** tab.
function Data = MakeSimpleLinearData()
arguments
end
rng(7,"twister")
X = linspace(0,10,24)';
Y = 3 + 2*X + 1.4*randn(size(X));
Data = struct("X",X,"Y",Y);
end
%%
function Comparison = MakeSSEComparison(ErrorScale)
arguments
    ErrorScale (1,1) double {mustBePositive}
end
rng(21,"twister")
NSmall = 10;
NLarge = 100;
TrueSlope = 2;
TrueIntercept = 3;
XSmall = 10*rand(NSmall,1);
XLarge = 10*rand(NLarge,1);
YSmall = TrueIntercept + TrueSlope*XSmall + ErrorScale*randn(NSmall,1);
YLarge = TrueIntercept + TrueSlope*XLarge + ErrorScale*randn(NLarge,1);
[PSmall,SSmall,MuSmall] = polyfit(XSmall,YSmall,1);
[PLarge,SLarge,MuLarge] = polyfit(XLarge,YLarge,1);
XSmallLine = sort(XSmall);
XLargeLine = sort(XLarge);
YSmallFitLine = polyval(PSmall,XSmallLine,SSmall,MuSmall);
YLargeFitLine = polyval(PLarge,XLargeLine,SLarge,MuLarge);
YSmallFit = polyval(PSmall,XSmall,SSmall,MuSmall);
YLargeFit = polyval(PLarge,XLarge,SLarge,MuLarge);
ResidualSmall = YSmall - YSmallFit;
ResidualLarge = YLarge - YLargeFit;
SSESmall = sum(ResidualSmall.^2);
MSESmall = mean(ResidualSmall.^2);
SSELarge = sum(ResidualLarge.^2);
MSELarge = mean(ResidualLarge.^2);
Metrics = table(["Small dataset";"Large dataset"],[NSmall;NLarge],[SSESmall;SSELarge],[MSESmall;MSELarge],VariableNames=["Dataset","N","SSE","MSE"]);
Comparison = struct("XSmall",XSmall,"YSmall",YSmall,"XSmallLine",XSmallLine,"YSmallFitLine",YSmallFitLine,"XLarge",XLarge,"YLarge",YLarge,"XLargeLine",XLargeLine,"YLargeFitLine",YLargeFitLine,"NSmall",NSmall,"NLarge",NLarge,"SSESmall",SSESmall,"MSESmall",MSESmall,"SSELarge",SSELarge,"MSELarge",MSELarge,"Metrics",Metrics);
end
%%
function Result = CompareDirectFit(X,Y,Guess)
arguments
    X (:,1) double
    Y (:,1) double
    Guess (1,2) double
end
PDirect = polyfit(X,Y,1);
YDirect = polyval(PDirect,X);
YGuess = Guess(1)*X + Guess(2);
Metrics = table(["Initial guess";"Direct fit"],[Guess(1);PDirect(1)],[Guess(2);PDirect(2)],[mean((Y - YGuess).^2);mean((Y - YDirect).^2)],VariableNames=["Model","Slope","Intercept","MSE"]);
Result = struct("YGuess",YGuess,"YDirect",YDirect,"Metrics",Metrics);
end
%%
function NumberOfIterations = AnimateGradientDescent(LearningRate,Style)
arguments
    LearningRate (1,1) double {mustBePositive}
    Style (1,1) struct = DefaultPlotStyle()
end
ApplyDefaultStyle(Style)
Objective = struct("Function",@(XValue) XValue.^2,"Gradient",@(XValue) 2*XValue);
State = struct("Tolerance",1e-3,"CurrentX",5,"MaxIterations",250,"XPath",5,"YPath",Objective.Function(5),"NumberOfIterations",0);
OscillationLearningRate = 1;
OscillationIterationLimit = 20;
FigureData = struct();
FigureData.XLine = linspace(-6,6,240);
FigureData.Handle = PrepareGradientFigure("OptimizationGradientDescentFigure","Gradient Descent Visualizations",Style);
FigureData.Layout = tiledlayout(FigureData.Handle,1,1,Padding="compact",TileSpacing="compact");
FigureData.Axes = nexttile(FigureData.Layout);
plot(FigureData.Axes,FigureData.XLine,Objective.Function(FigureData.XLine),LineWidth=Style.SecondaryLineWidth,SeriesIndex=Style.ReferenceSeriesIndex)
hold(FigureData.Axes,"on")
PlotHandles = struct();
PlotHandles.Trail = scatter(FigureData.Axes,State.XPath,State.YPath,Style.TrailMarkerArea,"filled",MarkerFaceAlpha=Style.TrailMarkerFaceAlpha,SeriesIndex=Style.PathSeriesIndex);
PlotHandles.CurrentPoint = scatter(FigureData.Axes,State.CurrentX,Objective.Function(State.CurrentX),Style.CurrentMarkerArea,"filled",SeriesIndex=Style.CurrentPointSeriesIndex);
hold(FigureData.Axes,"off")
xlabel(FigureData.Axes,"$x$",Interpreter=Style.Interpreter)
ylabel(FigureData.Axes,"$f(x)$",Interpreter=Style.Interpreter)
title(FigureData.Axes,"Gradient Descent on $f(x)=x^2$",Interpreter=Style.Interpreter)
ApplyDefaultAxesStyle(FigureData.Axes,Style)
while State.NumberOfIterations < State.MaxIterations
    State.Gradient = Objective.Gradient(State.CurrentX);
    if abs(State.Gradient) < State.Tolerance
        break
    end
    State.NextX = State.CurrentX - LearningRate*State.Gradient;
    State.NumberOfIterations = State.NumberOfIterations + 1;
    State.XPath(end+1) = State.NextX;
    State.YPath(end+1) = Objective.Function(State.NextX);
    PlotHandles.Trail.XData = State.XPath;
    PlotHandles.Trail.YData = State.YPath;
    PlotHandles.CurrentPoint.XData = State.NextX;
    PlotHandles.CurrentPoint.YData = Objective.Function(State.NextX);
    title(FigureData.Axes,sprintf("Iteration %d, $\\alpha = %.2f$",State.NumberOfIterations,LearningRate),Interpreter=Style.Interpreter)
    drawnow
    pause(Style.AnimationPause2D)
    if abs(LearningRate - OscillationLearningRate) < eps(OscillationLearningRate) && State.NumberOfIterations >= OscillationIterationLimit
        warning("Gradient descent stopped after 20 iterations because the learning rate alpha = 1 causes oscillation and will not settle.")
        break
    end
    State.CurrentX = State.NextX;
end
NumberOfIterations = State.NumberOfIterations;
end
%%
function LearningRate = Resolve2DLearningRateChoice(ChoiceIndex)
arguments
    ChoiceIndex (1,1) double {mustBeFinite}
end
LearningRatePresets = [0.02 0.10 1.00];
PresetIndex = round(ChoiceIndex);
PresetIndex = min(max(PresetIndex,1),numel(LearningRatePresets));
LearningRate = LearningRatePresets(PresetIndex);
end
%%
function [Theta1,Theta0,MSE] = GradientDescent(X,Y,NumSteps,LearningRate,Style)
arguments
    X (:,1) double
    Y (:,1) double
    NumSteps (1,1) double {mustBeInteger,mustBePositive}
    LearningRate (1,1) double {mustBePositive}
    Style (1,1) struct = DefaultPlotStyle()
end
ApplyDefaultStyle(Style)
SurfaceData = struct();
[SurfaceData.Theta1Grid,SurfaceData.Theta0Grid] = meshgrid(-10:0.1:10,-10:0.1:10);
SurfaceData.CostSurface = arrayfun(@(Theta1Value,Theta0Value) CostFunc(Theta1Value,Theta0Value,X,Y),SurfaceData.Theta1Grid,SurfaceData.Theta0Grid);
State = struct("Theta1",7,"Theta0",7,"SampleCount",numel(X));
State.MSE = CostFunc(State.Theta1,State.Theta0,X,Y);
State.Path = struct("Theta1",State.Theta1,"Theta0",State.Theta0,"MSE",State.MSE);
FigureData = struct();
FigureData.Handle = PrepareGradientFigure("OptimizationGradientDescentFigure","Gradient Descent Visualizations",Style);
FigureData.Layout = tiledlayout(FigureData.Handle,2,2,TileSpacing="compact",Padding="compact");
title(FigureData.Layout,"Gradient Descent",Interpreter=Style.Interpreter)
FigureData.Axes = struct();
FigureData.Axes.Surface = nexttile(FigureData.Layout,1);
PlotHandles = struct();
PlotHandles.Surface = surf(FigureData.Axes.Surface,SurfaceData.Theta1Grid,SurfaceData.Theta0Grid,SurfaceData.CostSurface);
ApplySeriesIndexIfSupported(PlotHandles.Surface,Style.SurfaceSeriesIndex)
PlotHandles.Surface.EdgeColor = "none";
PlotHandles.Surface.FaceAlpha = Style.SurfaceFaceAlpha;
colormap(FigureData.Axes.Surface,Style.SurfaceColormap)
hold(FigureData.Axes.Surface,"on")
PlotHandles.SurfacePath = scatter3(FigureData.Axes.Surface,State.Path.Theta1,State.Path.Theta0,State.Path.MSE,Style.PathMarkerArea,"filled",MarkerFaceAlpha=Style.TrailMarkerFaceAlpha,SeriesIndex=Style.PathSeriesIndex);
PlotHandles.SurfaceCurrent = scatter3(FigureData.Axes.Surface,State.Theta1,State.Theta0,State.MSE,Style.CurrentMarkerArea,"filled",SeriesIndex=Style.CurrentPointSeriesIndex);
hold(FigureData.Axes.Surface,"off")
view(FigureData.Axes.Surface,Style.SurfaceView)
xlabel(FigureData.Axes.Surface,"$\theta_1$",Interpreter=Style.Interpreter)
ylabel(FigureData.Axes.Surface,"$\theta_0$",Interpreter=Style.Interpreter)
zlabel(FigureData.Axes.Surface,"MSE",Interpreter=Style.Interpreter)
title(FigureData.Axes.Surface,"Cost Surface",Interpreter=Style.Interpreter)
ApplyDefaultAxesStyle(FigureData.Axes.Surface,Style)
FigureData.RotateHandle = rotate3d(FigureData.Axes.Surface);
FigureData.RotateHandle.Enable = 'on';
FigureData.Axes.Contour = nexttile(FigureData.Layout,2);
contour(FigureData.Axes.Contour,SurfaceData.Theta1Grid,SurfaceData.Theta0Grid,SurfaceData.CostSurface,Style.ContourLevelCount,LineWidth=Style.SecondaryLineWidth)
hold(FigureData.Axes.Contour,"on")
PlotHandles.ContourPath = scatter(FigureData.Axes.Contour,State.Path.Theta1,State.Path.Theta0,Style.PathMarkerArea,"filled",MarkerFaceAlpha=Style.TrailMarkerFaceAlpha,SeriesIndex=Style.PathSeriesIndex);
PlotHandles.ContourCurrent = scatter(FigureData.Axes.Contour,State.Theta1,State.Theta0,Style.CurrentMarkerArea,"filled",SeriesIndex=Style.CurrentPointSeriesIndex);
hold(FigureData.Axes.Contour,"off")
xlabel(FigureData.Axes.Contour,"$\theta_1$",Interpreter=Style.Interpreter)
ylabel(FigureData.Axes.Contour,"$\theta_0$",Interpreter=Style.Interpreter)
title(FigureData.Axes.Contour,"Contour Plot",Interpreter=Style.Interpreter)
ApplyDefaultAxesStyle(FigureData.Axes.Contour,Style)
FigureData.Axes.Fit = nexttile(FigureData.Layout,[1 2]);
scatter(FigureData.Axes.Fit,X,Y,Style.RegressionMarkerArea,"filled",MarkerFaceAlpha=Style.DataMarkerFaceAlpha,SeriesIndex=Style.DataSeriesIndex)
hold(FigureData.Axes.Fit,"on")
FigureData.FitXLimits = [min(X) max(X)];
PlotHandles.FitLine = plot(FigureData.Axes.Fit,FigureData.FitXLimits,State.Theta1.*FigureData.FitXLimits + State.Theta0,LineWidth=Style.PrimaryLineWidth,SeriesIndex=Style.FitSeriesIndex);
hold(FigureData.Axes.Fit,"off")
ylim(FigureData.Axes.Fit,[min(Y)-Style.FitYPadding max(Y)+Style.FitYPadding])
xlabel(FigureData.Axes.Fit,"$x$",Interpreter=Style.Interpreter)
ylabel(FigureData.Axes.Fit,"$y$",Interpreter=Style.Interpreter)
title(FigureData.Axes.Fit,FormatGradientFitTitle(State.Theta1,State.Theta0,State.MSE),Interpreter=Style.Interpreter)
ApplyDefaultAxesStyle(FigureData.Axes.Fit,Style)
for StepIndex = 1:NumSteps
    Predictions = State.Theta1.*X + State.Theta0;
    Residuals = Predictions - Y;
    Gradient = struct("Theta1",(2/State.SampleCount)*sum(Residuals.*X),"Theta0",(2/State.SampleCount)*sum(Residuals));
    State.Theta1 = State.Theta1 - LearningRate*Gradient.Theta1;
    State.Theta0 = State.Theta0 - LearningRate*Gradient.Theta0;
    State.MSE = CostFunc(State.Theta1,State.Theta0,X,Y);
    if ~isfinite(State.MSE) || State.MSE > 1e8
        warning("Gradient descent diverged. Try a smaller learning rate.")
        break
    end
    State.Path.Theta1(end+1) = State.Theta1;
    State.Path.Theta0(end+1) = State.Theta0;
    State.Path.MSE(end+1) = State.MSE;
    PlotHandles.SurfacePath.XData = State.Path.Theta1;
    PlotHandles.SurfacePath.YData = State.Path.Theta0;
    PlotHandles.SurfacePath.ZData = State.Path.MSE;
    PlotHandles.SurfaceCurrent.XData = State.Theta1;
    PlotHandles.SurfaceCurrent.YData = State.Theta0;
    PlotHandles.SurfaceCurrent.ZData = State.MSE;
    PlotHandles.ContourPath.XData = State.Path.Theta1;
    PlotHandles.ContourPath.YData = State.Path.Theta0;
    PlotHandles.ContourCurrent.XData = State.Theta1;
    PlotHandles.ContourCurrent.YData = State.Theta0;
    PlotHandles.FitLine.YData = State.Theta1.*FigureData.FitXLimits + State.Theta0;
    title(FigureData.Axes.Fit,FormatGradientFitTitle(State.Theta1,State.Theta0,State.MSE),Interpreter=Style.Interpreter)
    drawnow
    pause(Style.AnimationPauseSurface)
end
Theta1 = State.Theta1;
Theta0 = State.Theta0;
MSE = State.MSE;
end
%%
function FigureHandle = PrepareGradientFigure(FigureTag,FigureName,Style)
arguments
    FigureTag (1,1) string
    FigureName (1,1) string
    Style (1,1) struct = DefaultPlotStyle()
end
FigureHandle = findobj(groot,Type="figure",Tag=FigureTag);
if isempty(FigureHandle) || ~isvalid(FigureHandle(1))
    FigureHandle = figure(Name=FigureName,NumberTitle="off",Color=Style.FigureColor,Tag=FigureTag);
else
    FigureHandle = FigureHandle(1);
    figure(FigureHandle)
    FigureHandle.Name = FigureName;
    FigureHandle.NumberTitle = "off";
    FigureHandle.Color = Style.FigureColor;
end
clf(FigureHandle,"reset")
FigureHandle.Tag = FigureTag;
FigureHandle.Name = FigureName;
FigureHandle.NumberTitle = "off";
FigureHandle.Color = Style.FigureColor;
end
%%
function MSE = CostFunc(Theta1,Theta0,X,Y)
Predictions = Theta1.*X + Theta0;
MSE = mean((Predictions - Y).^2);
end
%%
function Data = LoadOptimizationData()

S = load("LinearData2.mat","x","y");
Data = struct("X",S.x,"Y",S.y);

end
%%
function Style = DefaultPlotStyle()
Style = struct();
Style.Interpreter = "latex";
Style.Grid = "on";
Style.Box = "on";
Style.GuessSeriesIndex = 1;
Style.DirectFitSeriesIndex = 2;
Style.DataSeriesIndex = 3;
Style.ComparisonSeriesIndex = 4;
Style.PathSeriesIndex = 5;
Style.CurrentPointSeriesIndex = 6;
Style.SurfaceSeriesIndex = 7;
Style.FitSeriesIndex = 1;
Style.ReferenceSeriesIndex = 2;
Style.DataMarkerSize = 36;
Style.EmphasisMarkerSize = 42;
Style.RegressionMarkerArea = 60;
Style.TrailMarkerArea = 28;
Style.PathMarkerArea = 42;
Style.TrailMarkerFaceAlpha = 0.65;
Style.CurrentMarkerArea = 80;
Style.DataMarkerFaceAlpha = 0.7;
Style.PrimaryLineWidth = 2;
Style.SecondaryLineWidth = 1.5;
Style.AnnotationOffset = 0.5;
Style.ContourLevelCount = 30;
Style.SurfaceView = [-16 33];
Style.SurfaceFaceAlpha = 0.9;
Style.SurfaceColormap = parula(256);
Style.AnimationPause2D = 0.08;
Style.AnimationPauseSurface = 0.12;
Style.FigureColor = "w";
Style.FitYPadding = 2;
end
%%
function ApplyDefaultStyle(Style)
groot.DefaultAxesTickLabelInterpreter = Style.Interpreter;
groot.DefaultTextInterpreter = Style.Interpreter;
groot.DefaultLegendInterpreter = Style.Interpreter; %#ok<STRNU>
end
%%
function ApplyDefaultAxesStyle(Ax,Style)
Ax.TickLabelInterpreter = Style.Interpreter;
grid(Ax,Style.Grid)
box(Ax,Style.Box)
end
%%
function ApplySeriesIndexIfSupported(GraphicsObject,SeriesIndex)

arguments
    GraphicsObject
    SeriesIndex (1,1) double
end

if isprop(GraphicsObject,"SeriesIndex")
    GraphicsObject.SeriesIndex = SeriesIndex;
end

end
%%
function TitleText = FormatGradientFitTitle(Theta1,Theta0,MSE)
TitleText = sprintf("$\\theta_1 = %.4f,\\quad \\theta_0 = %.4f$, MSE = %.4f",Theta1,Theta0,MSE);
end
%%
function CheckAnswer(ExerciseID,Option)
arguments
    ExerciseID (1,1) string
    Option (1,1) string
end
Exercises = struct();
Exercises.Exercise1 = struct("Answer","c.","Hint","Focus on what is being adjusted during training.");
Exercises.Exercise2 = struct("Answer","c.","Hint","Think about what makes a direct solve possible here.");
Exercises.Exercise3 = struct("Answer","a.","Hint","What direction does the update use relative to the gradient?");
Exercises.Exercise4 = struct("Answer","d.","Hint","What happens after training when you decide whether to keep or revise the model?");
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

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"hidecode"}
%---
%[text:image:4dae]
%   data: {"align":"baseline","height":144,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAJYAAACWCAYAAAA8AXHiAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAVFUlEQVR4nO2dd3xT1fvHP81oOtM2bbooLUgZrYAI2LLK0MoQRMCvMn6ylyJTGV9RUVkuHPhFUfZUUMDFEFCkTEHFMkRakEIpaZs0XelImjT5\/XGpMu65TdrkJvf2vF+vvuTV59xzHl98OPfc5zznOV5wAbE+ioR2gQGPRHjLm6jk8miVXBYVKpdFq+TyaF+JJMAVY1IYDJZqvd5szi20WDR6s0VTaDbn3jRWZf5aathbbLFo+fLDy1kdJfr7dUkKChyQpAzs39TXp62z+qU4j3Nl5YdPlRh2ny4x7M4xmTJcOVa9hTUkPOyFJ9Sh08O95XHOcIjCD5fKK07t1BYsO1ZcusMV\/ddZWKmq4NFDI9UvxSgULZ3pEIVf\/jCUHdyWp1t6rqz8sDP7dVhYScrA\/sMi1fMT\/P26ONMRintJKyrZtiVX+7qzXpEOCWtYhHr+6OiIJc4YmOJ5GK3W8nev54w6UVy6q7592S2smbGN1vYJDRnnSOch7drDLyYGCrUaijA1FGo1vINDHPeSYic2GHU6mHQ6mAqY\/xoyM1CWddWhXtbczJuzU1uwrD6e1CqsMLk8Zk6TmM1tA\/x71t6bF8JTekCd0h3qlB7wCQ+vj28UJ2G4nAnd0SPQHk1D8dl0u57ZU1C4csUNzZS6jskprDC5PObt5k1\/jlZ4x9fWUezQ4Wg2fiIUYeq6+kLhgeLz53B13Wpo0w7X2vZEcenXi7Kyh9RlHCmX8bVmcd\/G+\/m252oT1bcfHlj6DmIGDoLMz78uPlB4xCciAlF9H0NQYmtU5mpgzM8jtm3so0jwl0qCfjeU7Xd0HKKwZsY2WtM1WMmp1jYLl6D5c1OhUIU6Oi7FzfjHxSFm0BBYq8woSj9DbJfg79e5tLq6ILOi8ldH+mcV1rAI9fwnI8Jmkx7ybdQIHZZ\/jPDuPR0Zi+KBhCZ3gk94BLRHDhPbPKQMfCyjovK0xlR1xd5+7xFWkjKw\/8y4RmuJjiR1QoflHyOgWTN7x6B4OMqERIS07wDd0TRYTSbWNu2VAY8eLCzaYLLaKuzp8x5hvRgXs0HtLW\/M1rhmplKo6QJdbPg1ikFgfDxy9+1ltftIJP5SLy\/ZGUPZAXv6u0NYqarg0QPVodNIjTssX4GAZrV+IFIEin9sHORBwSg4fozVnuDv1zmtqGRbaXW1vra+7hDWS00bb1fKZGFsDdssXELXVA2A4NZtYDEYUHz+HKvdTyoNPFlS+k1t\/Uhq\/jAkPOwF0oZyVN9+aDRgYJ2dpQiLVrPnwTe6EastVRU8OtGOfeJ\/hPWEOnQ6qdF94ybWyUGKcGk2nvx3PkCter625yUAk6RHyqeKHTocgfHN6+wgRZjEDH4SQYn3s9qSlcoBtT0vAYCkoED2hl5enMqliBvSm8pPKlF2VAb243qWEZYysD+bMTylB937a8BEPPwI5IGBrLbkIHbN1CCJ9VEkkHLU1SndneAeRcioU3qw\/j5JSXjL3ULSLjAg1dFOKQ0H0uQS7i2P4zo0I4kgLNpD2rWn+VQUhHNMLlwHaCQquTyazeAXE+MEtyhCR+rnB9+oKFabSi5nNwCQqOQyViPdD6TUoAhjf3OFymWskxIASEhG+jVIqYE0yahk7JMSwPEqpDMWpQaSFkIJ2gEACamWAj1NQ6nBOziY9fc+UnIdDgnJQKHUByosikugwqK4BCosikugwqK4BCosikugwqK4BCosikugwqK4BBnR8u5iICkZuL8tkNQZoPUZGhZZfwO\/nwb+ugCkpTn8OFlY2jxg\/x7mRyoFOnUD+j8BdEgCvJxWbJniSZhMwKEDwN5vgYy\/\/v29kf3YPRdkYd1OdTVwPI35iYwCHnsC6DcQCApyeECKB3L9GvDdDuCnA0BFuVO6tE9Yt5OXC6z7lPl5uDfwzFggJtYpzlB45tRx4IvNwMXzTu\/acWHdzqEDwM8\/Ar1SgVHjgWiadSoIfjsFbFkHXLzgsiHqJywAsFkZgR06ADzSBxg5jgrMU0n\/HdiwyqWCqoEcbmjcBJA4GI34aT8wfgTzmjSb6+cZxXkU6oFX5wBzpzsuKoUP0MjxiYKsnOmzge27gWenA\/EOXD5RXQ1s2wxMGAFcOOuwQxQnYrMB3+4Exg4DTp2w\/zmpFEjuAry8CNj1A7OWdhDuV2FQEDBkKPOTcwM4sIeZlXR2XCKVqwFefB7oOwCYNBXwp5d+8Ur2NeCdRUDmJfufadEKSO3LLGkClfUa3v41VkxjYNyzzM\/PB4HNaxmxcWGzAfu+B345DkyZBfR4uF7OUuxk4xpg63r723dMBkaOBxLYi4DUhbot3ns9CvR8hPki3LIeyMnmbl9UCCx5FfjtF2DWfx1fu1Hso7gImP8CcCXTvvbtHwJGT3SqoGqo+1ehl4R59\/ZMZWawLeuBm7XMYPv3MK\/IhW8DtCa8c7l2FXhpFqAvqL3tgx2BMZNcIqga6j91SCTMO3nNVmDUBEBWi1bP\/QFMGQfk59Z7aMotTp8Epk2sXVRBwcAbbwNvL3epqABnZjdIpUwUfuUGIK4pd1tNDvDcWJdEfBscX24FXp0LmIzc7XqmAuu+ADp348Ut5y924poy4ho5nnv2KjMAs6cBF9iLqFLsYPM6YM0nTJCaRM0sNf+Nen\/pOYJrVtEyGROBX7YCCGAv3AUAsJiBl1+0f7FJ+ZcDe5kvcy7iWwCrt\/A2S92Oaz\/PEtsAK9dzb\/FUVgD\/nQlobrrUFVFx9DDw3pvcbbqkAB9+BrjpRLvrv\/sjooBP1gFtHyS3KS0B5k5jwhIUbs7+ASxdwP36GzEaeP0twNubP7\/ugp+Akp8\/8M5HQB+OspXafGDeDKCsjBeXBMnVK8Ars5ltMzZkcuCVRUwowc3wF6mUSIAX5wNPDiO3uXYVWDCHN5cERX4eMGca99ffG28B3T1jd4P\/EPjkaUzknsSFc0x2BOVfbFZg8auAoZTd7uUFvLoEeKgTv35x4J69lXkLgOSuZPv2LUwglcKweR2QcZFsnzYbSOnJmzv24B5hSSTAa0uABwgLepsNWPoaE+tq6GRcBLZuJNtHjgMGDOLPHztx326wTA4sfJfJmmCjUF\/7J7XYqawAFr1C\/gJ8uDcTiPZA3Jtm4OvLRISlhKupj6cBaT\/x65MnsXI587XMRmQUMHMev\/44gPvzV+JbAmMnk+0rlzP\/chsalzOAH3az26RSYMFSwMeHX58cwP3CAoCnRpADqIV6YMNqfv1xN1YrcxKdxMjxzHaNB+MZwvLyYl6JpH3Fb3cwR74bCt98xcT02GiVCAwfya8\/dcAzhAUwtSEmE66jtlqB95by64+7KNQDGwkztEwGvPQGk2Tp4XiWh336Ay0T2G2Zl4C93\/Hrjzv45EOgspLd9vQzQBSxtLpH4VnCApiceFLRkbUrAWMtCW1C5uJ54Mghdps6HPi\/Mby6Ux88T1j3xTNVbdgwlAJfcAQLhc6KD8i2KTMBuZw\/X+qJ5wkLAMY9BwQQziHu3CbO9Jojh4ArGey2B9oDXYV1d6RnCisgABhNSP2oqgLWf8avP67GagVWf8Ju85IAM+by648T8ExhAcDjg5noMhv799Z+llFIfLeLfGqpb3\/ytpcH47nCkkiACVPYbTYr8Nn\/+PXHVRiN5Nx1b2\/uXQkPxnOFBTBJay1asdtOnRDHCZ9tm8h5Vv8Z7rac9fri2cICgGdnkG2fLufPD1dQXATs+ILdFqgEho3i1x8n4vnCat2WnBSYeQk45nhFX49h0xrmY4SNkeM8epO5NjxfWAAweSp5G2PjKiYxUGjotOSdhIgoYMBgfv1xMsIQVkws0Ocxdtv1a+RotSezeS0TZmBjwnO118DwcIQhLIA50iQjRJ7Xr+I+Z+dp6LTMSWY24pp4zEmb+iAcYalCmZgOG5ocplaXUNiwijxbjZ4kigsahCMsABg6kpzGvGmtMGatXA3w4352W1wToGt3Xt1xFcISVkQk0PdxdpsmBzj4A7\/+1IWNq8n\/AEZNFMVsBQhNWAAwjGvWWkM+fu4J3LhOfmXHNQG6CWujmQvhCYtr1tLmkxfFnsDmdRyz1QTRzFaAEIUFcM9an2\/wzFlLkwOkEcIicU2Abj359MblCFNYEZHkyjX5ecDBffz6Yw9cHxcjx4tqtgKEKiwAGDGGbPt8A19e2EdONnPXEBuxTUQRt7ob4QorPAJ4bCC7LS\/Xs9ZaWziK+T8zlj8\/eES4wgKA4aPJa63NHhLX4greRkWL9rYOYQsrIhLoTdhDzM8jByL5hOtLcOxkQZwRrAvC\/78aMYZ71iJtnfBBzg3g0EF2W+M4pva6SBG+sLhmrbxc4Puv+fXndlav4IhbeWb5IWchfGEB3LPWpjUOH3LVFpXh7OVcHD97HSfPZ+NilhaGcgdvcr94Hjh5jN3WOA7o8Yhj\/QkMYSf91BARyXwhss1OhlLgq8+ZjEwOvvrxPPadzMCJc9eRX8heuTk+JhQpDzbF4ymt0KtDM26fuA6fjhPmAQlHEIewAOCZccwmtJGl7sGXW5nT1arQe0z\/+\/IEPv7qJFFMt3MlR48rOXqs\/\/43tGsRjRlDu2BQT5bLjtI4Dp\/GtxTc4dO6II5XIQCEqJg6W2yYjMDKD+\/41a8Xc9DrudVY8NlBu0R1N+mZGoxdtAPjF+9EkeE2MZtM94x1B1NnOTyWEBGPsABGWCEqdlvaIeBP5rjY9oPn0HvaWqRnauo95K6fL+DRqWtx9vKtA6db1zOliNjo0p25BqYBIC5h+fgwr0QS77+FTXt+x7NvOfdL8e8cPYbM3Ywzx86Sj3NxHcAVIeISFsCspZqyL6z3ZVdgxvuEup71pLC0EqMX78RNC2HZOugpQR6VryviE1bN1Sp3ZQvkQoFpVtfeKppjlmKmNfFeQ1i4YI\/K1xXxCQtgjuXfdS7vNWsL6OH627B+tIVhlS32zl9OfQFQKFw+tichTmEBzNm8W+GFk7YQfGUjVK5xAcus96Eat2bMjsnM3YENDPEKy9cPeHkhIJFgvY3jIk4XoIM3NthiGGHPW8Dr2J6CeIUFAG3aoWLcFOzkcbaqYReigMXLmDuZGyDiFhaAtJj2cEd+wwlrMEoiY2tvKFJEL6w\/nBAErSvpmYQqfQ0A0Qsr62aR+8bWiLAIr52IXlj6knK3jV1Y2gAvl7qF6IVltrgvg9SdY7sb0QvLR+G+zCAfb\/FkJTmK6IUVoSJcRMAD4W4c292IXljNG4e5cex7EwsbCqIXVsdEfqPuNSi8ZejQyj1jewKiF1bXtnFQh\/jzPm7v5OZiK8fgEBzCEmAlYgJDU9vyPubTqSLKFK2DFCQGSzVrHq1Rp6uvOx7DhEFJvI73YMtoDOhGuNBTgJgK2LVgsFQTI8ASvdnMuu9gEpGw4iKDMecZ\/mp7zh0prlM4Rp2W9feFZjNxv0xSaLGwGkkqFSrzx\/ZC8v2uTw2ePDgZfTt79g3zjkKaZPRmdu0AgIRkFNOMVcPHc5+ASunnsv5Tk+Lx1tS+LuvfXZAmmUKzhbjLLikkvAoNmYQDlwKmWUwoti8dDpXS1+l9d2vXBJtef9rp\/bqbylwNTAUFrDY916vwprEqk81QlnUVhsusJkHTMSEG378\/Bq2bRTqtzyG97sc3746Cr0I4dzbbi+7oEaJNY6q6TLJJfi01EEvfcXUqZBKbhuPQJxMxbmDHevUjlUqw6NneWPvKfyCViDNopTvKfrvalYrKM3lVVVmk5yTFFov2XFn5YTajltCpGJDLJHhvRn\/s+3AsHk9xLDSgkMswaXAS0rdMx9SnOrvIQ\/djKSuD7jh7xZzTpYY9XM\/KAOBUiWF32wD\/nncbi8+mo\/j8OQS34T\/AyBed2sSiU5tY3MgvwQ8nM3DyfDb+ytLipq4UhgqmdJFK6Ye4yGC0iY9ESrsm6N+tlShfe3eT8903RNvpEgPnyV8vAIhRKFquTmx+ia1BeI+eaP+BSO5fpthNtdGItP59UFV0bww0r6oqa+yfmfdxPS8BgByTKeNSecUptgbatMOiXWtRyFxdt4ZVVABwori01uIX\/+wV7tQWLCM1+nvd6jo5RxEmxvw8XCX8nVtttuqvtXqOqnIM\/9RXzDaaLt4f4Nc1SuF9T0UNY34erFVmhCZ3qpfDFGGQPm82Km5ks9q+yNct+aXE8G1tfdxRuFNXZb7xaGjIGLaGReln4BMeAWUCS9ELimi4+OZi5O5nvzKm2GLRLs7KfrLaBktt\/dwhrPwq87XGPopWTXx9WrM11h45jJD2HeDXqOEmsImZrM0bcXUtedmzUZP\/8p\/lFcft6eueUsPXKk0XeoeGjJV5ebGWZtEdTUNgfDz8Y+Psdpji+WRt3oiMD4jLbPxZVnHsoxsau2sx3SOs0upqfY7JdKl7SNBQtgesJhNy9+2FPCgYwa1FlMzWgLn45mLOmUpvNmteu5o9oLy6utjePlmLo98wmv4yWq3l7ZUBvUkPFhw\/BovBgLAu3ewdi+JhGPPzkD5vNnFNVcOirOzBf1ca\/3Ckb0LVfeCv8ooTIXJZRAs\/34dIbYrPn8PN77+DzNeXLuoFRLXRiL9XfYr0ObOIX381LM++OelYcekOR8cgCgtg9oPu8\/V5oLGPgriZZjEYoD3CBFG9g0MQ0JQzIEtxI5byMmTv+BLps2eh4MQxwMadzP55nnbhLq3+vbqMZdeW\/KRGke8PDg+zq0C5PDAQ6pQeUKd0R3hKD0j9XJdYR6mdylwNdEePQHc0jbihzMZH2Tcn7dMX1Tkybneux+Nq1fNTYqJXODqAb1QUFGHhUKjVUKjV8A5umIXIeMHGZHsadVqYdDqYCnTEJD0SerNFs+x6zqh0Q9lP9XHFoSSijsrAfi\/GNdoQLJOF12dQimfyZ1nFsXev54zK58izshfONdbdaExVVw4WFm2QennJEvz9xJuI1MAotli0GzX5L390QzPZkZACF3VOe4xRKFoOjVS\/lKoKHu0MRyj8Y7XZqrfl65Zuz9ctrbLaHLt7rxbqnU+b6O\/XZYBa9XyyUjnATypROsMpimvJq6rKOlFc+vXXWv0HBWZzjivGcGqidkdlYL\/koMD+ScrAAeHecrrn40Fcqag8c7rUsOd0iWF3RkXlaVeP57ITAE19fdqGe8vjVHJ5VKhcFq2SyaJC5fJoH6mk4RaN4gGDpbqw0GzW6M0WTaHZkqs3mzUaU9VlroMPFAqFQqFQKBQKhUKhOJf\/Bxz0YtbB8qphAAAAAElFTkSuQmCC","width":144}
%---
%[text:image:7219]
%   data: {"align":"middle","height":24,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAArElEQVR42mP4\/\/8\/AwgnJiYapKamfgfS\/ynBUDMMYOYywBggiYcPH\/6nFIDMAJmFYQHIdmoBqFm4LZjrYPd\/gpoyGIPYVLeA5j4gbEASHJNlwZYtW\/93dHTixDCDQTRMDKRn8FhATBDNmTOH\/CAiBI4cOQI2HETTLBW9fv2a\/FRUtPXVf\/WeuyRhkB6iLQBp2HLvP0kYpGfUglELhpMFNM9oNKlw6FHp06TZAgAoeVix9Bg9oQAAAABJRU5ErkJggg==","width":24}
%---
%[text:image:315f]
%   data: {"align":"baseline","height":24,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAsCAYAAAAXb\/p7AAADlklEQVR42u1YS0hUYRQejR4UvR+SvaCyWiS2DIoCKWjVYzG2SsYWQ+a8HRwXFkOgqdGLSoSeqyBaJUGLCKGkNpGtgiyScnpYBpaU5au+E+eH03Wu93rvP2OEFw46955z\/u8\/7\/\/3eDQ+4XD4Eui65199AK4d1DEJcBLgfw0wGo2ujkQi1yoqKlY5AFgDqnWw5lpaMxaLrbBkDgaDm7HIEKjTCcjxPqFQqABrdYEGsHaRXaESCAyCXpNFMwwuReDw\/77xusurQGJna0ysPR2K94CnGdQKesnUyu92J5PJaelk4c51Chzcu9dp0O9nkO3yvd\/vnwqlEbzvAf2yoB5sIkwyBt0doJ+0Qbdu2AXyC8UrOVuNQH5Q3IJegfrTfH8ikwC\/A9hjsdaYCQQCG6D4vVj0DShB7+HKXMGaQ\/EFADEGrPhJdn1GAhoZvRDKX4jFTvt8vhlWchSD4D0OGiE5AH9eXl4+PxNF+IoCB8sccyBfreQB8qJWcAC0CYqHeYE2cqEDNTmQvcc6hlC+CnXWq\/PCtTtdeGGr0HNWFz7aeTcr\/eT1eqe41PVWJYxd62zkovwXqQ6Cv8vErm9r8MZNEctLVf9Ph4GwecSOjPSQu8V28e6chmRrFPq28btHJhhSBKDIBH0B726HEDilAWCtsGCx6MmjMNgaHqBkiygPl3UmHE1OrjOEiqoqsqDHGizYxrqGAXCOriL9jJUOoq3lO9UDQItpQGD3PtXZRapFHB51oSchwiWsDWA8Hl8Cpb2svA+WWO4AXJ7Q0Z1IJObq7sUBN\/UQLr0hrHfANSCaQihrobiBf+dC+QOxSNk4MrdEyN1VvRy6T+DdVbOp2wpcCyutN8yDahjtVZ3A4sS2ALwflYxhaK1n0C22QfL8dkuNRYZBlKxxRLj6gg3XNgj+w8beLOriHcv50gocJ8wsfP\/ASgfMDlRs8XzwfGPeThMr2QcpEqFprJmPSoSwSvMYfCcFX6nFlNPEfAGrUuC1GkhxQpspTnTfKysrFxl5qqqqZouy0mU81ZmApB6cp2vKlrFVk+Z7TGRuPOsXRZSNfGYmEO\/ofoXmOiKKS3Ga6wPYeRNxk9Vo49BONAIL1mUdIBa9bxPgn+zMOkAqIXDdQbp1sKAy6uWeyWd0Cyuk5LDh3pTtez\/NSVJqNwbh5kNZB8htkTrP1zHA9dM1nZ07nExmc50ZQGA7M+GxyLden9MA\/OLm\/KKe34xPoKAD7jPkAAAAAElFTkSuQmCC","width":22}
%---
%[text:image:3854]
%   data: {"align":"baseline","height":23,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAADoAAAA6CAYAAADhu0ooAAAEp0lEQVR42t2a208TQRTG67OJxvv9fiGoD6LGgPiCGo1G\/wljTKDl1pL00RuKIKCIIiKg6ItB8IJ38K4Panz13RcfSBBBQQHRek4ys\/kYpu1uu2132+Sku6eb6X7zmzlz5ux6PEn6lJaWbi0uLu4mGyLrJWvMz8+f4UmnjxA5QhZS7HNZWdnUdNE5hQR9EsLGioqKWuj7kRRbUlJSmS40D4Co4yD+rfAPEdW5rhdKQj4KQQM4J0n0DhjCVW4XuR9oHlV\/J98rSZVsnmuF0nz8oNIsLCxcFQwGp4vf86AjzrhV5D4dTTq+Tr8d0VD95fP5Frpx2L4XAgYlTQpMq+n8DxKm4+0wV6tdJZIo7YWbPwbi26QfqdL5S+H\/7SqqdMPvJE2iOFPOTUEzpM5bpEodUOMWkXs06yb7r6qZEc5dOn\/hKqqQCESiOYkqic4Ff62jRZKg3XCzJ0B8q0akjupzSZU6aZGTl5Q34kZ\/BgKB2ezzer3LOMcNJ5SpSvJIlY7POTWn3QUBpRzEt0QQqYvMzxxNlW7staRJQ3gO0Bw1IdSYz9Qx28Bf57QhuxNu7iSIbzYhclKEpvZ6HElVR5OOl5qkGZEqdcB5p9DMC0OzyYJIXaTuFr4R6rzFTkj3jK1WHDRDarSmdnPAX59qkbkQaU+B\/7IqglM7+g4qVqu5rhzaeeoIqpC2RaVJN52pGfYbdFRlW0iVrr2QcppkFSC+MUxUNSt0AlU6f5JSqpCuGcUtv9+\/JExZ05JQpErf2eC\/mOxIi4v6aRDfEGGdtCJUjeCPhW+Uk5BkCu2xQjNGoQZVWl+30Pk\/4W9I1tzM0RWfeVhFyXysCp0QyaHoPUZtLU\/G3OxWadIfL+Dilt1CMZrTtZuB6qVE7zezdUVnDv0mctlYhKpUHyaFKoR6SzTjEYr\/pVBtTDhNLDZz0m1ydxKrUHWdfiCp+ny+FYmgKUP8sHx8YJamDUK1VDnVtHs5wSFTDeLrLOw34xGqrtf3E0IVgoBRiiwoKJhvlqZNQjEubIKOb7Jr3TQaxeIyF6+sbMFsEKqu2\/ZShQZVmsPJFhqOKrVzxTaaWFTW7SNNCD3IlUI08h2KYXOO63eXpErtrYwnCHWpNDniWqVpsxlUacnLAhDNsa6bWTqaolIQSrFVwei6FxdVGlZ3baY5SNav2KCdVLlYblXkRqB5FnqvOlYKNgWjUJjsTEIZpzbXWIm0d9QCMlfneI\/oFKFKhoZgWs0GIP7zv+qDHu7BeOZVAoSqWZqEM+73+9eaodlpN80ECjXiBwLih87Rnoith4vrgGZlvJEyQUJVqrdNUaULOmRp0U6a8uUMssNo\/BDYBqHDnKlppt21qDTxwQ7vGhywbkbrxBrN1Bsny9DRbFcLxV6vdxad\/3C6UJyryvRrU7OgdfBjPYivcIHIkCYX79BSpZObLqYZkSq\/kicjaqZ04oMcrpS7SGRIzeJIy60JVDk6SZpcbRdDeRr5v2hyU6fbV\/l8VVlXm5lcX0wJsTveYpMVw14PzMOGNBQqE4h+3M8x5hti3UwH64S52y6D0YALA49Z6+P3hCXiDLH2fEsjgd+ZKr9wyRr\/A+UKAPezYlA8AAAAAElFTkSuQmCC","width":23}
%---
%[text:image:31dc]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[text:image:5066]
%   data: {"align":"baseline","height":20,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAADUAAAAxCAYAAAB6d+FmAAAC0ElEQVR42u2aO4gTURSGs6Lugo1WW2ghgiyCr1VWbRSR9YEgKoKohcQmEDAviYhBIaVbbKEWYi22YidoobUItoqwjSui6wt119Wsj+\/onXAcJslMZpI7AxP4Sbh37pnz3TP3zJ2TyWQS9imVStvRK1G5XL5ZqVRWZpL8MUCf0G+lz+hYIoGIyDYPIEc\/i8ViLmkRGkMfWwA5WkD7EwHEutmCs+87ADl6zfHLm4MLhcIqGs7RcV0WoA1xCa3vIkL\/CTsX\/w7G2Bka5oIMjlo4M6GBmOTRABHSeirh3S0LzSYQugHHgAPEJG+l7UOXtr6LgQeqYQZdRVf6Jc5frdfriyKIkOgHQToi1+0XpxGD+ywnhc348a5bICboqLMYmx02784hgRYAOqEzjHWoSIHiABU5kG2osECMP9lqC2IFiqS0qSdAtqAM0Ey3QOhUp81iX6F6DtRvKM6xsedA\/YQKCdQgyx0PcrKeQ4WNkE4K+LhGb6usQOHQOnnOCb31+WdrNW1TQC22BoW9Ddh9i6bRfNDdNkCH1c59LW0vpc8qFDYfo\/tkvMFqtbqM3xdkffgAmseXQ44dM3ba6bcGlc1mh9yzbaK3k\/Y37YAYc9Dl47A+xhoU0dlh7A579I3qRx6lbwAd8PAxHlA4V5BF3ea8Z11Ac62e52IDhb1bZuZL+lFdRWtQpflZzj3exlZsIvVc2b7jdW8xiWSWVL2ng4\/2ofL5\/Ars\/XJdXudN9wC\/R4Ce5PurFH58RN0+FLb2et130D1VVJlCu3zasw9FFC67dwboialUnZadQcBJsg+F09ewd9tkwLFcLrckZOTjkSgi3pmkUClUCpVCpVApVAqVQqVQ0UDp6s5IHKFMeaz5doufYuYz9bf\/XXmXQaqgcZH4I34pqBd+Qluz\/LpBUF3qCEUol3LgwyQAEbFHUrDxW6OTyk7NFEsaMYNpGL9qfoH+AOOEPfJuI6OmAAAAAElFTkSuQmCC","width":22}
%---
%[text:image:9073]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[text:image:8e99]
%   data: {"align":"baseline","height":20,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAADUAAAAxCAYAAAB6d+FmAAAC0ElEQVR42u2aO4gTURSGs6Lugo1WW2ghgiyCr1VWbRSR9YEgKoKohcQmEDAviYhBIaVbbKEWYi22YidoobUItoqwjSui6wt119Wsj+\/onXAcJslMZpI7AxP4Sbh37pnz3TP3zJ2TyWQS9imVStvRK1G5XL5ZqVRWZpL8MUCf0G+lz+hYIoGIyDYPIEc\/i8ViLmkRGkMfWwA5WkD7EwHEutmCs+87ADl6zfHLm4MLhcIqGs7RcV0WoA1xCa3vIkL\/CTsX\/w7G2Bka5oIMjlo4M6GBmOTRABHSeirh3S0LzSYQugHHgAPEJG+l7UOXtr6LgQeqYQZdRVf6Jc5frdfriyKIkOgHQToi1+0XpxGD+ywnhc348a5bICboqLMYmx02784hgRYAOqEzjHWoSIHiABU5kG2osECMP9lqC2IFiqS0qSdAtqAM0Ey3QOhUp81iX6F6DtRvKM6xsedA\/YQKCdQgyx0PcrKeQ4WNkE4K+LhGb6usQOHQOnnOCb31+WdrNW1TQC22BoW9Ddh9i6bRfNDdNkCH1c59LW0vpc8qFDYfo\/tkvMFqtbqM3xdkffgAmseXQ44dM3ba6bcGlc1mh9yzbaK3k\/Y37YAYc9Dl47A+xhoU0dlh7A579I3qRx6lbwAd8PAxHlA4V5BF3ea8Z11Ac62e52IDhb1bZuZL+lFdRWtQpflZzj3exlZsIvVc2b7jdW8xiWSWVL2ng4\/2ofL5\/Ars\/XJdXudN9wC\/R4Ce5PurFH58RN0+FLb2et130D1VVJlCu3zasw9FFC67dwboialUnZadQcBJsg+F09ewd9tkwLFcLrckZOTjkSgi3pmkUClUCpVCpVApVAqVQqVQ0UDp6s5IHKFMeaz5doufYuYz9bf\/XXmXQaqgcZH4I34pqBd+Qluz\/LpBUF3qCEUol3LgwyQAEbFHUrDxW6OTyk7NFEsaMYNpGL9qfoH+AOOEPfJuI6OmAAAAAElFTkSuQmCC","width":22}
%---
%[text:image:0a8e]
%   data: {"align":"baseline","height":20,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAADUAAAAxCAYAAAB6d+FmAAAC0ElEQVR42u2aO4gTURSGs6Lugo1WW2ghgiyCr1VWbRSR9YEgKoKohcQmEDAviYhBIaVbbKEWYi22YidoobUItoqwjSui6wt119Wsj+\/onXAcJslMZpI7AxP4Sbh37pnz3TP3zJ2TyWQS9imVStvRK1G5XL5ZqVRWZpL8MUCf0G+lz+hYIoGIyDYPIEc\/i8ViLmkRGkMfWwA5WkD7EwHEutmCs+87ADl6zfHLm4MLhcIqGs7RcV0WoA1xCa3vIkL\/CTsX\/w7G2Bka5oIMjlo4M6GBmOTRABHSeirh3S0LzSYQugHHgAPEJG+l7UOXtr6LgQeqYQZdRVf6Jc5frdfriyKIkOgHQToi1+0XpxGD+ywnhc348a5bICboqLMYmx02784hgRYAOqEzjHWoSIHiABU5kG2osECMP9lqC2IFiqS0qSdAtqAM0Ey3QOhUp81iX6F6DtRvKM6xsedA\/YQKCdQgyx0PcrKeQ4WNkE4K+LhGb6usQOHQOnnOCb31+WdrNW1TQC22BoW9Ddh9i6bRfNDdNkCH1c59LW0vpc8qFDYfo\/tkvMFqtbqM3xdkffgAmseXQ44dM3ba6bcGlc1mh9yzbaK3k\/Y37YAYc9Dl47A+xhoU0dlh7A579I3qRx6lbwAd8PAxHlA4V5BF3ea8Z11Ac62e52IDhb1bZuZL+lFdRWtQpflZzj3exlZsIvVc2b7jdW8xiWSWVL2ng4\/2ofL5\/Ars\/XJdXudN9wC\/R4Ce5PurFH58RN0+FLb2et130D1VVJlCu3zasw9FFC67dwboialUnZadQcBJsg+F09ewd9tkwLFcLrckZOTjkSgi3pmkUClUCpVCpVApVAqVQqVQ0UDp6s5IHKFMeaz5doufYuYz9bf\/XXmXQaqgcZH4I34pqBd+Qluz\/LpBUF3qCEUol3LgwyQAEbFHUrDxW6OTyk7NFEsaMYNpGL9qfoH+AOOEPfJuI6OmAAAAAElFTkSuQmCC","width":22}
%---
%[control:dropdown:25bc]
%   data: {"defaultValue":"\"Select\"","itemLabels":["Select","a.","b.","c.","d."],"items":["\"Select\"","\"a.\"","\"b.\"","\"c.\"","\"d.\""],"label":"Select an answer.","run":"SectionAndStaleSectionsAbove"}
%---
%[text:image:68e7]
%   data: {"align":"baseline","height":83,"src":"data:image\/svg+xml;base64,PHN2ZyB3aWR0aD0iMTQyIiBoZWlnaHQ9IjgzIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB4bWw6c3BhY2U9InByZXNlcnZlIiBvdmVyZmxvdz0iaGlkZGVuIj48ZyB0cmFuc2Zvcm09InRyYW5zbGF0ZSgtNDUyIC0yMzEpIj48cGF0aCBkPSJNNTA0LjUgMjM0LjVDNTA0LjUgMjM1LjYwNSA1MTMuNDU0IDIzNi41IDUyNC41IDIzNi41IDUzNS41NDYgMjM2LjUgNTQ0LjUgMjM1LjYwNSA1NDQuNSAyMzQuNUw1NDQuNSAyNDYuNUM1NDQuNSAyNDcuNjA1IDUzNS41NDYgMjQ4LjUgNTI0LjUgMjQ4LjUgNTEzLjQ1NCAyNDguNSA1MDQuNSAyNDcuNjA1IDUwNC41IDI0Ni41WiIgZmlsbD0iI0U0QzcxQSIgZmlsbC1ydWxlPSJldmVub2RkIi8+PHBhdGggZD0iTTUwNC41IDIzNC41QzUwNC41IDIzMy4zOTUgNTEzLjQ1NCAyMzIuNSA1MjQuNSAyMzIuNSA1MzUuNTQ2IDIzMi41IDU0NC41IDIzMy4zOTUgNTQ0LjUgMjM0LjUgNTQ0LjUgMjM1LjYwNSA1MzUuNTQ2IDIzNi41IDUyNC41IDIzNi41IDUxMy40NTQgMjM2LjUgNTA0LjUgMjM1LjYwNSA1MDQuNSAyMzQuNVoiIGZpbGw9IiNFRkRENzYiIGZpbGwtcnVsZT0iZXZlbm9kZCIvPjxwYXRoIGQ9Ik01NDQuNSAyMzQuNUM1NDQuNSAyMzUuNjA1IDUzNS41NDYgMjM2LjUgNTI0LjUgMjM2LjUgNTEzLjQ1NCAyMzYuNSA1MDQuNSAyMzUuNjA1IDUwNC41IDIzNC41IDUwNC41IDIzMy4zOTUgNTEzLjQ1NCAyMzIuNSA1MjQuNSAyMzIuNSA1MzUuNTQ2IDIzMi41IDU0NC41IDIzMy4zOTUgNTQ0LjUgMjM0LjVMNTQ0LjUgMjQ2LjVDNTQ0LjUgMjQ3LjYwNSA1MzUuNTQ2IDI0OC41IDUyNC41IDI0OC41IDUxMy40NTQgMjQ4LjUgNTA0LjUgMjQ3LjYwNSA1MDQuNSAyNDYuNUw1MDQuNSAyMzQuNSIgc3Ryb2tlPSIjRTRDNzFBIiBzdHJva2Utd2lkdGg9IjIuNjY2NjciIHN0cm9rZS1saW5lam9pbj0icm91bmQiIHN0cm9rZS1taXRlcmxpbWl0PSIxMCIgZmlsbD0ibm9uZSIgZmlsbC1ydWxlPSJldmVub2RkIi8+PHBhdGggZD0iTTUwNC41IDI1MC41QzUwNC41IDI1MS42MDUgNTEzLjQ1NCAyNTIuNSA1MjQuNSAyNTIuNSA1MzUuNTQ2IDI1Mi41IDU0NC41IDI1MS42MDUgNTQ0LjUgMjUwLjVMNTQ0LjUgMjYyLjVDNTQ0LjUgMjYzLjYwNSA1MzUuNTQ2IDI2NC41IDUyNC41IDI2NC41IDUxMy40NTQgMjY0LjUgNTA0LjUgMjYzLjYwNSA1MDQuNSAyNjIuNVoiIGZpbGw9IiNFNEM3MUEiIGZpbGwtcnVsZT0iZXZlbm9kZCIvPjxwYXRoIGQ9Ik01MDQuNSAyNTAuNUM1MDQuNSAyNDkuMzk1IDUxMy40NTQgMjQ4LjUgNTI0LjUgMjQ4LjUgNTM1LjU0NiAyNDguNSA1NDQuNSAyNDkuMzk1IDU0NC41IDI1MC41IDU0NC41IDI1MS42MDUgNTM1LjU0NiAyNTIuNSA1MjQuNSAyNTIuNSA1MTMuNDU0IDI1Mi41IDUwNC41IDI1MS42MDUgNTA0LjUgMjUwLjVaIiBmaWxsPSIjRUZERDc2IiBmaWxsLXJ1bGU9ImV2ZW5vZGQiLz48cGF0aCBkPSJNNTQ0LjUgMjUwLjVDNTQ0LjUgMjUxLjYwNSA1MzUuNTQ2IDI1Mi41IDUyNC41IDI1Mi41IDUxMy40NTQgMjUyLjUgNTA0LjUgMjUxLjYwNSA1MDQuNSAyNTAuNSA1MDQuNSAyNDkuMzk1IDUxMy40NTQgMjQ4LjUgNTI0LjUgMjQ4LjUgNTM1LjU0NiAyNDguNSA1NDQuNSAyNDkuMzk1IDU0NC41IDI1MC41TDU0NC41IDI2Mi41QzU0NC41IDI2My42MDUgNTM1LjU0NiAyNjQuNSA1MjQuNSAyNjQuNSA1MTMuNDU0IDI2NC41IDUwNC41IDI2My42MDUgNTA0LjUgMjYyLjVMNTA0LjUgMjUwLjUiIHN0cm9rZT0iI0U0QzcxQSIgc3Ryb2tlLXdpZHRoPSIyLjY2NjY3IiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBzdHJva2UtbWl0ZXJsaW1pdD0iMTAiIGZpbGw9Im5vbmUiIGZpbGwtcnVsZT0iZXZlbm9kZCIvPjxwYXRoIGQ9Ik01MDQuNSAyNjYuNUM1MDQuNSAyNjcuNjA1IDUxMy40NTQgMjY4LjUgNTI0LjUgMjY4LjUgNTM1LjU0NiAyNjguNSA1NDQuNSAyNjcuNjA1IDU0NC41IDI2Ni41TDU0NC41IDI3OC41QzU0NC41IDI3OS42MDUgNTM1LjU0NiAyODAuNSA1MjQuNSAyODAuNSA1MTMuNDU0IDI4MC41IDUwNC41IDI3OS42MDUgNTA0LjUgMjc4LjVaIiBmaWxsPSIjRTRDNzFBIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiLz48cGF0aCBkPSJNNTA0LjUgMjY2LjVDNTA0LjUgMjY1LjM5NSA1MTMuNDU0IDI2NC41IDUyNC41IDI2NC41IDUzNS41NDYgMjY0LjUgNTQ0LjUgMjY1LjM5NSA1NDQuNSAyNjYuNSA1NDQuNSAyNjcuNjA1IDUzNS41NDYgMjY4LjUgNTI0LjUgMjY4LjUgNTEzLjQ1NCAyNjguNSA1MDQuNSAyNjcuNjA1IDUwNC41IDI2Ni41WiIgZmlsbD0iI0VGREQ3NiIgZmlsbC1ydWxlPSJldmVub2RkIi8+PHBhdGggZD0iTTU0NC41IDI2Ni41QzU0NC41IDI2Ny42MDUgNTM1LjU0NiAyNjguNSA1MjQuNSAyNjguNSA1MTMuNDU0IDI2OC41IDUwNC41IDI2Ny42MDUgNTA0LjUgMjY2LjUgNTA0LjUgMjY1LjM5NSA1MTMuNDU0IDI2NC41IDUyNC41IDI2NC41IDUzNS41NDYgMjY0LjUgNTQ0LjUgMjY1LjM5NSA1NDQuNSAyNjYuNUw1NDQuNSAyNzguNUM1NDQuNSAyNzkuNjA1IDUzNS41NDYgMjgwLjUgNTI0LjUgMjgwLjUgNTEzLjQ1NCAyODAuNSA1MDQuNSAyNzkuNjA1IDUwNC41IDI3OC41TDUwNC41IDI2Ni41IiBzdHJva2U9IiNFNEM3MUEiIHN0cm9rZS13aWR0aD0iMi42NjY2NyIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgc3Ryb2tlLW1pdGVybGltaXQ9IjEwIiBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiLz48cGF0aCBkPSJNNTA0LjUgMjgyLjVDNTA0LjUgMjgzLjYwNSA1MTMuNDU0IDI4NC41IDUyNC41IDI4NC41IDUzNS41NDYgMjg0LjUgNTQ0LjUgMjgzLjYwNSA1NDQuNSAyODIuNUw1NDQuNSAyOTQuNUM1NDQuNSAyOTUuNjA1IDUzNS41NDYgMjk2LjUgNTI0LjUgMjk2LjUgNTEzLjQ1NCAyOTYuNSA1MDQuNSAyOTUuNjA1IDUwNC41IDI5NC41WiIgZmlsbD0iI0U0QzcxQSIgZmlsbC1ydWxlPSJldmVub2RkIi8+PHBhdGggZD0iTTUwNC41IDI4Mi41QzUwNC41IDI4MS4zOTUgNTEzLjQ1NCAyODAuNSA1MjQuNSAyODAuNSA1MzUuNTQ2IDI4MC41IDU0NC41IDI4MS4zOTUgNTQ0LjUgMjgyLjUgNTQ0LjUgMjgzLjYwNSA1MzUuNTQ2IDI4NC41IDUyNC41IDI4NC41IDUxMy40NTQgMjg0LjUgNTA0LjUgMjgzLjYwNSA1MDQuNSAyODIuNVoiIGZpbGw9IiNFRkRENzYiIGZpbGwtcnVsZT0iZXZlbm9kZCIvPjxwYXRoIGQ9Ik01NDQuNSAyODIuNUM1NDQuNSAyODMuNjA1IDUzNS41NDYgMjg0LjUgNTI0LjUgMjg0LjUgNTEzLjQ1NCAyODQuNSA1MDQuNSAyODMuNjA1IDUwNC41IDI4Mi41IDUwNC41IDI4MS4zOTUgNTEzLjQ1NCAyODAuNSA1MjQuNSAyODAuNSA1MzUuNTQ2IDI4MC41IDU0NC41IDI4MS4zOTUgNTQ0LjUgMjgyLjVMNTQ0LjUgMjk0LjVDNTQ0LjUgMjk1LjYwNSA1MzUuNTQ2IDI5Ni41IDUyNC41IDI5Ni41IDUxMy40NTQgMjk2LjUgNTA0LjUgMjk1LjYwNSA1MDQuNSAyOTQuNUw1MDQuNSAyODIuNSIgc3Ryb2tlPSIjRTRDNzFBIiBzdHJva2Utd2lkdGg9IjIuNjY2NjciIHN0cm9rZS1saW5lam9pbj0icm91bmQiIHN0cm9rZS1taXRlcmxpbWl0PSIxMCIgZmlsbD0ibm9uZSIgZmlsbC1ydWxlPSJldmVub2RkIi8+PHBhdGggZD0iTTUwNC41IDI5OC41QzUwNC41IDI5OS42MDUgNTEzLjQ1NCAzMDAuNSA1MjQuNSAzMDAuNSA1MzUuNTQ2IDMwMC41IDU0NC41IDI5OS42MDUgNTQ0LjUgMjk4LjVMNTQ0LjUgMzEwLjVDNTQ0LjUgMzExLjYwNSA1MzUuNTQ2IDMxMi41IDUyNC41IDMxMi41IDUxMy40NTQgMzEyLjUgNTA0LjUgMzExLjYwNSA1MDQuNSAzMTAuNVoiIGZpbGw9IiNFNEM3MUEiIGZpbGwtcnVsZT0iZXZlbm9kZCIvPjxwYXRoIGQ9Ik01MDQuNSAyOTguNUM1MDQuNSAyOTcuMzk1IDUxMy40NTQgMjk2LjUgNTI0LjUgMjk2LjUgNTM1LjU0NiAyOTYuNSA1NDQuNSAyOTcuMzk1IDU0NC41IDI5OC41IDU0NC41IDI5OS42MDUgNTM1LjU0NiAzMDAuNSA1MjQuNSAzMDAuNSA1MTMuNDU0IDMwMC41IDUwNC41IDI5OS42MDUgNTA0LjUgMjk4LjVaIiBmaWxsPSIjRUZERDc2IiBmaWxsLXJ1bGU9ImV2ZW5vZGQiLz48cGF0aCBkPSJNNTQ0LjUgMjk4LjVDNTQ0LjUgMjk5LjYwNSA1MzUuNTQ2IDMwMC41IDUyNC41IDMwMC41IDUxMy40NTQgMzAwLjUgNTA0LjUgMjk5LjYwNSA1MDQuNSAyOTguNSA1MDQuNSAyOTcuMzk1IDUxMy40NTQgMjk2LjUgNTI0LjUgMjk2LjUgNTM1LjU0NiAyOTYuNSA1NDQuNSAyOTcuMzk1IDU0NC41IDI5OC41TDU0NC41IDMxMC41QzU0NC41IDMxMS42MDUgNTM1LjU0NiAzMTIuNSA1MjQuNSAzMTIuNSA1MTMuNDU0IDMxMi41IDUwNC41IDMxMS42MDUgNTA0LjUgMzEwLjVMNTA0LjUgMjk4LjUiIHN0cm9rZT0iI0U0QzcxQSIgc3Ryb2tlLXdpZHRoPSIyLjY2NjY3IiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBzdHJva2UtbWl0ZXJsaW1pdD0iMTAiIGZpbGw9Im5vbmUiIGZpbGwtcnVsZT0iZXZlbm9kZCIvPjxwYXRoIGQ9Ik00NTMuNSAyNjYuNUM0NTMuNSAyNjcuNjA1IDQ2Mi40NTQgMjY4LjUgNDczLjUgMjY4LjUgNDg0LjU0NiAyNjguNSA0OTMuNSAyNjcuNjA1IDQ5My41IDI2Ni41TDQ5My41IDI3OC41QzQ5My41IDI3OS42MDUgNDg0LjU0NiAyODAuNSA0NzMuNSAyODAuNSA0NjIuNDU0IDI4MC41IDQ1My41IDI3OS42MDUgNDUzLjUgMjc4LjVaIiBmaWxsPSIjRTRDNzFBIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiLz48cGF0aCBkPSJNNDUzLjUgMjY2LjVDNDUzLjUgMjY1LjM5NSA0NjIuNDU0IDI2NC41IDQ3My41IDI2NC41IDQ4NC41NDYgMjY0LjUgNDkzLjUgMjY1LjM5NSA0OTMuNSAyNjYuNSA0OTMuNSAyNjcuNjA1IDQ4NC41NDYgMjY4LjUgNDczLjUgMjY4LjUgNDYyLjQ1NCAyNjguNSA0NTMuNSAyNjcuNjA1IDQ1My41IDI2Ni41WiIgZmlsbD0iI0VGREQ3NiIgZmlsbC1ydWxlPSJldmVub2RkIi8+PHBhdGggZD0iTTQ5My41IDI2Ni41QzQ5My41IDI2Ny42MDUgNDg0LjU0NiAyNjguNSA0NzMuNSAyNjguNSA0NjIuNDU0IDI2OC41IDQ1My41IDI2Ny42MDUgNDUzLjUgMjY2LjUgNDUzLjUgMjY1LjM5NSA0NjIuNDU0IDI2NC41IDQ3My41IDI2NC41IDQ4NC41NDYgMjY0LjUgNDkzLjUgMjY1LjM5NSA0OTMuNSAyNjYuNUw0OTMuNSAyNzguNUM0OTMuNSAyNzkuNjA1IDQ4NC41NDYgMjgwLjUgNDczLjUgMjgwLjUgNDYyLjQ1NCAyODAuNSA0NTMuNSAyNzkuNjA1IDQ1My41IDI3OC41TDQ1My41IDI2Ni41IiBzdHJva2U9IiNFNEM3MUEiIHN0cm9rZS13aWR0aD0iMi42NjY2NyIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgc3Ryb2tlLW1pdGVybGltaXQ9IjEwIiBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiLz48cGF0aCBkPSJNNDUzLjUgMjgyLjVDNDUzLjUgMjgzLjYwNSA0NjIuNDU0IDI4NC41IDQ3My41IDI4NC41IDQ4NC41NDYgMjg0LjUgNDkzLjUgMjgzLjYwNSA0OTMuNSAyODIuNUw0OTMuNSAyOTQuNUM0OTMuNSAyOTUuNjA1IDQ4NC41NDYgMjk2LjUgNDczLjUgMjk2LjUgNDYyLjQ1NCAyOTYuNSA0NTMuNSAyOTUuNjA1IDQ1My41IDI5NC41WiIgZmlsbD0iI0U0QzcxQSIgZmlsbC1ydWxlPSJldmVub2RkIi8+PHBhdGggZD0iTTQ1My41IDI4Mi41QzQ1My41IDI4MS4zOTUgNDYyLjQ1NCAyODAuNSA0NzMuNSAyODAuNSA0ODQuNTQ2IDI4MC41IDQ5My41IDI4MS4zOTUgNDkzLjUgMjgyLjUgNDkzLjUgMjgzLjYwNSA0ODQuNTQ2IDI4NC41IDQ3My41IDI4NC41IDQ2Mi40NTQgMjg0LjUgNDUzLjUgMjgzLjYwNSA0NTMuNSAyODIuNVoiIGZpbGw9IiNFRkRENzYiIGZpbGwtcnVsZT0iZXZlbm9kZCIvPjxwYXRoIGQ9Ik00OTMuNSAyODIuNUM0OTMuNSAyODMuNjA1IDQ4NC41NDYgMjg0LjUgNDczLjUgMjg0LjUgNDYyLjQ1NCAyODQuNSA0NTMuNSAyODMuNjA1IDQ1My41IDI4Mi41IDQ1My41IDI4MS4zOTUgNDYyLjQ1NCAyODAuNSA0NzMuNSAyODAuNSA0ODQuNTQ2IDI4MC41IDQ5My41IDI4MS4zOTUgNDkzLjUgMjgyLjVMNDkzLjUgMjk0LjVDNDkzLjUgMjk1LjYwNSA0ODQuNTQ2IDI5Ni41IDQ3My41IDI5Ni41IDQ2Mi40NTQgMjk2LjUgNDUzLjUgMjk1LjYwNSA0NTMuNSAyOTQuNUw0NTMuNSAyODIuNSIgc3Ryb2tlPSIjRTRDNzFBIiBzdHJva2Utd2lkdGg9IjIuNjY2NjciIHN0cm9rZS1saW5lam9pbj0icm91bmQiIHN0cm9rZS1taXRlcmxpbWl0PSIxMCIgZmlsbD0ibm9uZSIgZmlsbC1ydWxlPSJldmVub2RkIi8+PHBhdGggZD0iTTQ1My41IDI5OC41QzQ1My41IDI5OS42MDUgNDYyLjQ1NCAzMDAuNSA0NzMuNSAzMDAuNSA0ODQuNTQ2IDMwMC41IDQ5My41IDI5OS42MDUgNDkzLjUgMjk4LjVMNDkzLjUgMzEwLjVDNDkzLjUgMzExLjYwNSA0ODQuNTQ2IDMxMi41IDQ3My41IDMxMi41IDQ2Mi40NTQgMzEyLjUgNDUzLjUgMzExLjYwNSA0NTMuNSAzMTAuNVoiIGZpbGw9IiNFNEM3MUEiIGZpbGwtcnVsZT0iZXZlbm9kZCIvPjxwYXRoIGQ9Ik00NTMuNSAyOTguNUM0NTMuNSAyOTcuMzk1IDQ2Mi40NTQgMjk2LjUgNDczLjUgMjk2LjUgNDg0LjU0NiAyOTYuNSA0OTMuNSAyOTcuMzk1IDQ5My41IDI5OC41IDQ5My41IDI5OS42MDUgNDg0LjU0NiAzMDAuNSA0NzMuNSAzMDAuNSA0NjIuNDU0IDMwMC41IDQ1My41IDI5OS42MDUgNDUzLjUgMjk4LjVaIiBmaWxsPSIjRUZERDc2IiBmaWxsLXJ1bGU9ImV2ZW5vZGQiLz48cGF0aCBkPSJNNDkzLjUgMjk4LjVDNDkzLjUgMjk5LjYwNSA0ODQuNTQ2IDMwMC41IDQ3My41IDMwMC41IDQ2Mi40NTQgMzAwLjUgNDUzLjUgMjk5LjYwNSA0NTMuNSAyOTguNSA0NTMuNSAyOTcuMzk1IDQ2Mi40NTQgMjk2LjUgNDczLjUgMjk2LjUgNDg0LjU0NiAyOTYuNSA0OTMuNSAyOTcuMzk1IDQ5My41IDI5OC41TDQ5My41IDMxMC41QzQ5My41IDMxMS42MDUgNDg0LjU0NiAzMTIuNSA0NzMuNSAzMTIuNSA0NjIuNDU0IDMxMi41IDQ1My41IDMxMS42MDUgNDUzLjUgMzEwLjVMNDUzLjUgMjk4LjUiIHN0cm9rZT0iI0U0QzcxQSIgc3Ryb2tlLXdpZHRoPSIyLjY2NjY3IiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBzdHJva2UtbWl0ZXJsaW1pdD0iMTAiIGZpbGw9Im5vbmUiIGZpbGwtcnVsZT0iZXZlbm9kZCIvPjxwYXRoIGQ9Ik01NTIuNSAyNjUuNUM1NTIuNSAyNjYuNjA1IDU2MS40NTQgMjY3LjUgNTcyLjUgMjY3LjUgNTgzLjU0NiAyNjcuNSA1OTIuNSAyNjYuNjA1IDU5Mi41IDI2NS41TDU5Mi41IDI3Ny41QzU5Mi41IDI3OC42MDUgNTgzLjU0NiAyNzkuNSA1NzIuNSAyNzkuNSA1NjEuNDU0IDI3OS41IDU1Mi41IDI3OC42MDUgNTUyLjUgMjc3LjVaIiBmaWxsPSIjRTRDNzFBIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiLz48cGF0aCBkPSJNNTUyLjUgMjY1LjVDNTUyLjUgMjY0LjM5NSA1NjEuNDU0IDI2My41IDU3Mi41IDI2My41IDU4My41NDYgMjYzLjUgNTkyLjUgMjY0LjM5NSA1OTIuNSAyNjUuNSA1OTIuNSAyNjYuNjA1IDU4My41NDYgMjY3LjUgNTcyLjUgMjY3LjUgNTYxLjQ1NCAyNjcuNSA1NTIuNSAyNjYuNjA1IDU1Mi41IDI2NS41WiIgZmlsbD0iI0VGREQ3NiIgZmlsbC1ydWxlPSJldmVub2RkIi8+PHBhdGggZD0iTTU5Mi41IDI2NS41QzU5Mi41IDI2Ni42MDUgNTgzLjU0NiAyNjcuNSA1NzIuNSAyNjcuNSA1NjEuNDU0IDI2Ny41IDU1Mi41IDI2Ni42MDUgNTUyLjUgMjY1LjUgNTUyLjUgMjY0LjM5NSA1NjEuNDU0IDI2My41IDU3Mi41IDI2My41IDU4My41NDYgMjYzLjUgNTkyLjUgMjY0LjM5NSA1OTIuNSAyNjUuNUw1OTIuNSAyNzcuNUM1OTIuNSAyNzguNjA1IDU4My41NDYgMjc5LjUgNTcyLjUgMjc5LjUgNTYxLjQ1NCAyNzkuNSA1NTIuNSAyNzguNjA1IDU1Mi41IDI3Ny41TDU1Mi41IDI2NS41IiBzdHJva2U9IiNFNEM3MUEiIHN0cm9rZS13aWR0aD0iMi42NjY2NyIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgc3Ryb2tlLW1pdGVybGltaXQ9IjEwIiBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiLz48cGF0aCBkPSJNNTUyLjUgMjgxLjVDNTUyLjUgMjgyLjYwNSA1NjEuNDU0IDI4My41IDU3Mi41IDI4My41IDU4My41NDYgMjgzLjUgNTkyLjUgMjgyLjYwNSA1OTIuNSAyODEuNUw1OTIuNSAyOTMuNUM1OTIuNSAyOTQuNjA1IDU4My41NDYgMjk1LjUgNTcyLjUgMjk1LjUgNTYxLjQ1NCAyOTUuNSA1NTIuNSAyOTQuNjA1IDU1Mi41IDI5My41WiIgZmlsbD0iI0U0QzcxQSIgZmlsbC1ydWxlPSJldmVub2RkIi8+PHBhdGggZD0iTTU1Mi41IDI4MS41QzU1Mi41IDI4MC4zOTUgNTYxLjQ1NCAyNzkuNSA1NzIuNSAyNzkuNSA1ODMuNTQ2IDI3OS41IDU5Mi41IDI4MC4zOTUgNTkyLjUgMjgxLjUgNTkyLjUgMjgyLjYwNSA1ODMuNTQ2IDI4My41IDU3Mi41IDI4My41IDU2MS40NTQgMjgzLjUgNTUyLjUgMjgyLjYwNSA1NTIuNSAyODEuNVoiIGZpbGw9IiNFRkRENzYiIGZpbGwtcnVsZT0iZXZlbm9kZCIvPjxwYXRoIGQ9Ik01OTIuNSAyODEuNUM1OTIuNSAyODIuNjA1IDU4My41NDYgMjgzLjUgNTcyLjUgMjgzLjUgNTYxLjQ1NCAyODMuNSA1NTIuNSAyODIuNjA1IDU1Mi41IDI4MS41IDU1Mi41IDI4MC4zOTUgNTYxLjQ1NCAyNzkuNSA1NzIuNSAyNzkuNSA1ODMuNTQ2IDI3OS41IDU5Mi41IDI4MC4zOTUgNTkyLjUgMjgxLjVMNTkyLjUgMjkzLjVDNTkyLjUgMjk0LjYwNSA1ODMuNTQ2IDI5NS41IDU3Mi41IDI5NS41IDU2MS40NTQgMjk1LjUgNTUyLjUgMjk0LjYwNSA1NTIuNSAyOTMuNUw1NTIuNSAyODEuNSIgc3Ryb2tlPSIjRTRDNzFBIiBzdHJva2Utd2lkdGg9IjIuNjY2NjciIHN0cm9rZS1saW5lam9pbj0icm91bmQiIHN0cm9rZS1taXRlcmxpbWl0PSIxMCIgZmlsbD0ibm9uZSIgZmlsbC1ydWxlPSJldmVub2RkIi8+PHBhdGggZD0iTTU1Mi41IDI5Ny41QzU1Mi41IDI5OC42MDUgNTYxLjQ1NCAyOTkuNSA1NzIuNSAyOTkuNSA1ODMuNTQ2IDI5OS41IDU5Mi41IDI5OC42MDUgNTkyLjUgMjk3LjVMNTkyLjUgMzA5LjVDNTkyLjUgMzEwLjYwNSA1ODMuNTQ2IDMxMS41IDU3Mi41IDMxMS41IDU2MS40NTQgMzExLjUgNTUyLjUgMzEwLjYwNSA1NTIuNSAzMDkuNVoiIGZpbGw9IiNFNEM3MUEiIGZpbGwtcnVsZT0iZXZlbm9kZCIvPjxwYXRoIGQ9Ik01NTIuNSAyOTcuNUM1NTIuNSAyOTYuMzk1IDU2MS40NTQgMjk1LjUgNTcyLjUgMjk1LjUgNTgzLjU0NiAyOTUuNSA1OTIuNSAyOTYuMzk1IDU5Mi41IDI5Ny41IDU5Mi41IDI5OC42MDUgNTgzLjU0NiAyOTkuNSA1NzIuNSAyOTkuNSA1NjEuNDU0IDI5OS41IDU1Mi41IDI5OC42MDUgNTUyLjUgMjk3LjVaIiBmaWxsPSIjRUZERDc2IiBmaWxsLXJ1bGU9ImV2ZW5vZGQiLz48cGF0aCBkPSJNNTkyLjUgMjk3LjVDNTkyLjUgMjk4LjYwNSA1ODMuNTQ2IDI5OS41IDU3Mi41IDI5OS41IDU2MS40NTQgMjk5LjUgNTUyLjUgMjk4LjYwNSA1NTIuNSAyOTcuNSA1NTIuNSAyOTYuMzk1IDU2MS40NTQgMjk1LjUgNTcyLjUgMjk1LjUgNTgzLjU0NiAyOTUuNSA1OTIuNSAyOTYuMzk1IDU5Mi41IDI5Ny41TDU5Mi41IDMwOS41QzU5Mi41IDMxMC42MDUgNTgzLjU0NiAzMTEuNSA1NzIuNSAzMTEuNSA1NjEuNDU0IDMxMS41IDU1Mi41IDMxMC42MDUgNTUyLjUgMzA5LjVMNTUyLjUgMjk3LjUiIHN0cm9rZT0iI0U0QzcxQSIgc3Ryb2tlLXdpZHRoPSIyLjY2NjY3IiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBzdHJva2UtbWl0ZXJsaW1pdD0iMTAiIGZpbGw9Im5vbmUiIGZpbGwtcnVsZT0iZXZlbm9kZCIvPjxwYXRoIGQ9Ik01NTIuNSAyNDkuNUM1NTIuNSAyNTAuNjA1IDU2MS40NTQgMjUxLjUgNTcyLjUgMjUxLjUgNTgzLjU0NiAyNTEuNSA1OTIuNSAyNTAuNjA1IDU5Mi41IDI0OS41TDU5Mi41IDI2MS41QzU5Mi41IDI2Mi42MDUgNTgzLjU0NiAyNjMuNSA1NzIuNSAyNjMuNSA1NjEuNDU0IDI2My41IDU1Mi41IDI2Mi42MDUgNTUyLjUgMjYxLjVaIiBmaWxsPSIjRTRDNzFBIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiLz48cGF0aCBkPSJNNTUyLjUgMjQ5LjVDNTUyLjUgMjQ4LjM5NSA1NjEuNDU0IDI0Ny41IDU3Mi41IDI0Ny41IDU4My41NDYgMjQ3LjUgNTkyLjUgMjQ4LjM5NSA1OTIuNSAyNDkuNSA1OTIuNSAyNTAuNjA1IDU4My41NDYgMjUxLjUgNTcyLjUgMjUxLjUgNTYxLjQ1NCAyNTEuNSA1NTIuNSAyNTAuNjA1IDU1Mi41IDI0OS41WiIgZmlsbD0iI0VGREQ3NiIgZmlsbC1ydWxlPSJldmVub2RkIi8+PHBhdGggZD0iTTU5Mi41IDI0OS41QzU5Mi41IDI1MC42MDUgNTgzLjU0NiAyNTEuNSA1NzIuNSAyNTEuNSA1NjEuNDU0IDI1MS41IDU1Mi41IDI1MC42MDUgNTUyLjUgMjQ5LjUgNTUyLjUgMjQ4LjM5NSA1NjEuNDU0IDI0Ny41IDU3Mi41IDI0Ny41IDU4My41NDYgMjQ3LjUgNTkyLjUgMjQ4LjM5NSA1OTIuNSAyNDkuNUw1OTIuNSAyNjEuNUM1OTIuNSAyNjIuNjA1IDU4My41NDYgMjYzLjUgNTcyLjUgMjYzLjUgNTYxLjQ1NCAyNjMuNSA1NTIuNSAyNjIuNjA1IDU1Mi41IDI2MS41TDU1Mi41IDI0OS41IiBzdHJva2U9IiNFNEM3MUEiIHN0cm9rZS13aWR0aD0iMi42NjY2NyIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgc3Ryb2tlLW1pdGVybGltaXQ9IjEwIiBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiLz48L2c+PC9zdmc+","width":142}
%---
%[text:image:277f]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:spinner:8808]
%   data: {"defaultValue":4,"label":"Noise Level:","max":5,"min":1,"run":"Section","runOn":"ValueChanging","step":1}
%---
%[control:button:7a05]
%   data: {"label":"Compare SSE and MSE","run":"SectionAndStaleSectionsAbove"}
%---
%[text:image:042e]
%   data: {"align":"baseline","height":24,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAsCAYAAAAXb\/p7AAADlklEQVR42u1YS0hUYRQejR4UvR+SvaCyWiS2DIoCKWjVYzG2SsYWQ+a8HRwXFkOgqdGLSoSeqyBaJUGLCKGkNpGtgiyScnpYBpaU5au+E+eH03Wu93rvP2OEFw46955z\/u8\/7\/\/3eDQ+4XD4Eui65199AK4d1DEJcBLgfw0wGo2ujkQi1yoqKlY5AFgDqnWw5lpaMxaLrbBkDgaDm7HIEKjTCcjxPqFQqABrdYEGsHaRXaESCAyCXpNFMwwuReDw\/77xusurQGJna0ysPR2K94CnGdQKesnUyu92J5PJaelk4c51Chzcu9dp0O9nkO3yvd\/vnwqlEbzvAf2yoB5sIkwyBt0doJ+0Qbdu2AXyC8UrOVuNQH5Q3IJegfrTfH8ikwC\/A9hjsdaYCQQCG6D4vVj0DShB7+HKXMGaQ\/EFADEGrPhJdn1GAhoZvRDKX4jFTvt8vhlWchSD4D0OGiE5AH9eXl4+PxNF+IoCB8sccyBfreQB8qJWcAC0CYqHeYE2cqEDNTmQvcc6hlC+CnXWq\/PCtTtdeGGr0HNWFz7aeTcr\/eT1eqe41PVWJYxd62zkovwXqQ6Cv8vErm9r8MZNEctLVf9Ph4GwecSOjPSQu8V28e6chmRrFPq28btHJhhSBKDIBH0B726HEDilAWCtsGCx6MmjMNgaHqBkiygPl3UmHE1OrjOEiqoqsqDHGizYxrqGAXCOriL9jJUOoq3lO9UDQItpQGD3PtXZRapFHB51oSchwiWsDWA8Hl8Cpb2svA+WWO4AXJ7Q0Z1IJObq7sUBN\/UQLr0hrHfANSCaQihrobiBf+dC+QOxSNk4MrdEyN1VvRy6T+DdVbOp2wpcCyutN8yDahjtVZ3A4sS2ALwflYxhaK1n0C22QfL8dkuNRYZBlKxxRLj6gg3XNgj+w8beLOriHcv50gocJ8wsfP\/ASgfMDlRs8XzwfGPeThMr2QcpEqFprJmPSoSwSvMYfCcFX6nFlNPEfAGrUuC1GkhxQpspTnTfKysrFxl5qqqqZouy0mU81ZmApB6cp2vKlrFVk+Z7TGRuPOsXRZSNfGYmEO\/ofoXmOiKKS3Ga6wPYeRNxk9Vo49BONAIL1mUdIBa9bxPgn+zMOkAqIXDdQbp1sKAy6uWeyWd0Cyuk5LDh3pTtez\/NSVJqNwbh5kNZB8htkTrP1zHA9dM1nZ07nExmc50ZQGA7M+GxyLden9MA\/OLm\/KKe34xPoKAD7jPkAAAAAElFTkSuQmCC","width":22}
%---
%[text:image:76c6]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:button:252b]
%   data: {"label":"Display Data","run":"Section"}
%---
%[text:image:5964]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:slider:1c28]
%   data: {"defaultValue":1,"label":"Theta 1:","max":4,"min":0,"run":"Section","runOn":"ValueChanging","step":0.5}
%---
%[control:slider:4feb]
%   data: {"defaultValue":1,"label":"Theta 0:","max":4,"min":0,"run":"Section","runOn":"ValueChanging","step":0.5}
%---
%[control:button:028d]
%   data: {"label":"Compare Manual and Direct Fit","run":"Section"}
%---
%[text:image:91df]
%   data: {"align":"baseline","height":20,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAADUAAAAxCAYAAAB6d+FmAAAC0ElEQVR42u2aO4gTURSGs6Lugo1WW2ghgiyCr1VWbRSR9YEgKoKohcQmEDAviYhBIaVbbKEWYi22YidoobUItoqwjSui6wt119Wsj+\/onXAcJslMZpI7AxP4Sbh37pnz3TP3zJ2TyWQS9imVStvRK1G5XL5ZqVRWZpL8MUCf0G+lz+hYIoGIyDYPIEc\/i8ViLmkRGkMfWwA5WkD7EwHEutmCs+87ADl6zfHLm4MLhcIqGs7RcV0WoA1xCa3vIkL\/CTsX\/w7G2Bka5oIMjlo4M6GBmOTRABHSeirh3S0LzSYQugHHgAPEJG+l7UOXtr6LgQeqYQZdRVf6Jc5frdfriyKIkOgHQToi1+0XpxGD+ywnhc348a5bICboqLMYmx02784hgRYAOqEzjHWoSIHiABU5kG2osECMP9lqC2IFiqS0qSdAtqAM0Ey3QOhUp81iX6F6DtRvKM6xsedA\/YQKCdQgyx0PcrKeQ4WNkE4K+LhGb6usQOHQOnnOCb31+WdrNW1TQC22BoW9Ddh9i6bRfNDdNkCH1c59LW0vpc8qFDYfo\/tkvMFqtbqM3xdkffgAmseXQ44dM3ba6bcGlc1mh9yzbaK3k\/Y37YAYc9Dl47A+xhoU0dlh7A579I3qRx6lbwAd8PAxHlA4V5BF3ea8Z11Ac62e52IDhb1bZuZL+lFdRWtQpflZzj3exlZsIvVc2b7jdW8xiWSWVL2ng4\/2ofL5\/Ars\/XJdXudN9wC\/R4Ce5PurFH58RN0+FLb2et130D1VVJlCu3zasw9FFC67dwboialUnZadQcBJsg+F09ewd9tkwLFcLrckZOTjkSgi3pmkUClUCpVCpVApVAqVQqVQ0UDp6s5IHKFMeaz5doufYuYz9bf\/XXmXQaqgcZH4I34pqBd+Qluz\/LpBUF3qCEUol3LgwyQAEbFHUrDxW6OTyk7NFEsaMYNpGL9qfoH+AOOEPfJuI6OmAAAAAElFTkSuQmCC","width":22}
%---
%[control:dropdown:i00e]
%   data: {"defaultValue":"\"Select\"","itemLabels":["Select","a.","b.","c.","d."],"items":["\"Select\"","\"a.\"","\"b.\"","\"c.\"","\"d.\""],"label":"Select an answer.","run":"Section"}
%---
%[text:image:019d]
%   data: {"align":"baseline","height":20,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAADUAAAAxCAYAAAB6d+FmAAAC0ElEQVR42u2aO4gTURSGs6Lugo1WW2ghgiyCr1VWbRSR9YEgKoKohcQmEDAviYhBIaVbbKEWYi22YidoobUItoqwjSui6wt119Wsj+\/onXAcJslMZpI7AxP4Sbh37pnz3TP3zJ2TyWQS9imVStvRK1G5XL5ZqVRWZpL8MUCf0G+lz+hYIoGIyDYPIEc\/i8ViLmkRGkMfWwA5WkD7EwHEutmCs+87ADl6zfHLm4MLhcIqGs7RcV0WoA1xCa3vIkL\/CTsX\/w7G2Bka5oIMjlo4M6GBmOTRABHSeirh3S0LzSYQugHHgAPEJG+l7UOXtr6LgQeqYQZdRVf6Jc5frdfriyKIkOgHQToi1+0XpxGD+ywnhc348a5bICboqLMYmx02784hgRYAOqEzjHWoSIHiABU5kG2osECMP9lqC2IFiqS0qSdAtqAM0Ey3QOhUp81iX6F6DtRvKM6xsedA\/YQKCdQgyx0PcrKeQ4WNkE4K+LhGb6usQOHQOnnOCb31+WdrNW1TQC22BoW9Ddh9i6bRfNDdNkCH1c59LW0vpc8qFDYfo\/tkvMFqtbqM3xdkffgAmseXQ44dM3ba6bcGlc1mh9yzbaK3k\/Y37YAYc9Dl47A+xhoU0dlh7A579I3qRx6lbwAd8PAxHlA4V5BF3ea8Z11Ac62e52IDhb1bZuZL+lFdRWtQpflZzj3exlZsIvVc2b7jdW8xiWSWVL2ng4\/2ofL5\/Ars\/XJdXudN9wC\/R4Ce5PurFH58RN0+FLb2et130D1VVJlCu3zasw9FFC67dwboialUnZadQcBJsg+F09ewd9tkwLFcLrckZOTjkSgi3pmkUClUCpVCpVApVAqVQqVQ0UDp6s5IHKFMeaz5doufYuYz9bf\/XXmXQaqgcZH4I34pqBd+Qluz\/LpBUF3qCEUol3LgwyQAEbFHUrDxW6OTyk7NFEsaMYNpGL9qfoH+AOOEPfJuI6OmAAAAAElFTkSuQmCC","width":22}
%---
%[control:dropdown:0801]
%   data: {"defaultValue":"\"Select\"","itemLabels":["Select","a.","b.","c.","d."],"items":["\"Select\"","\"a.\"","\"b.\"","\"c.\"","\"d.\""],"label":"Select an answer.","run":"Section"}
%---
%[text:image:98a4]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:slider:8904]
%   data: {"defaultValue":0,"label":"LearningRateChoice2D","max":3,"min":0,"run":"Section","runOn":"ValueChanging","step":0.5}
%---
%[control:button:i008]
%   data: {"label":"Run 2D Gradient Descent","run":"Section"}
%---
%[text:image:09bd]
%   data: {"align":"baseline","height":24,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAsCAYAAAAXb\/p7AAADlklEQVR42u1YS0hUYRQejR4UvR+SvaCyWiS2DIoCKWjVYzG2SsYWQ+a8HRwXFkOgqdGLSoSeqyBaJUGLCKGkNpGtgiyScnpYBpaU5au+E+eH03Wu93rvP2OEFw46955z\/u8\/7\/\/3eDQ+4XD4Eui65199AK4d1DEJcBLgfw0wGo2ujkQi1yoqKlY5AFgDqnWw5lpaMxaLrbBkDgaDm7HIEKjTCcjxPqFQqABrdYEGsHaRXaESCAyCXpNFMwwuReDw\/77xusurQGJna0ysPR2K94CnGdQKesnUyu92J5PJaelk4c51Chzcu9dp0O9nkO3yvd\/vnwqlEbzvAf2yoB5sIkwyBt0doJ+0Qbdu2AXyC8UrOVuNQH5Q3IJegfrTfH8ikwC\/A9hjsdaYCQQCG6D4vVj0DShB7+HKXMGaQ\/EFADEGrPhJdn1GAhoZvRDKX4jFTvt8vhlWchSD4D0OGiE5AH9eXl4+PxNF+IoCB8sccyBfreQB8qJWcAC0CYqHeYE2cqEDNTmQvcc6hlC+CnXWq\/PCtTtdeGGr0HNWFz7aeTcr\/eT1eqe41PVWJYxd62zkovwXqQ6Cv8vErm9r8MZNEctLVf9Ph4GwecSOjPSQu8V28e6chmRrFPq28btHJhhSBKDIBH0B726HEDilAWCtsGCx6MmjMNgaHqBkiygPl3UmHE1OrjOEiqoqsqDHGizYxrqGAXCOriL9jJUOoq3lO9UDQItpQGD3PtXZRapFHB51oSchwiWsDWA8Hl8Cpb2svA+WWO4AXJ7Q0Z1IJObq7sUBN\/UQLr0hrHfANSCaQihrobiBf+dC+QOxSNk4MrdEyN1VvRy6T+DdVbOp2wpcCyutN8yDahjtVZ3A4sS2ALwflYxhaK1n0C22QfL8dkuNRYZBlKxxRLj6gg3XNgj+w8beLOriHcv50gocJ8wsfP\/ASgfMDlRs8XzwfGPeThMr2QcpEqFprJmPSoSwSvMYfCcFX6nFlNPEfAGrUuC1GkhxQpspTnTfKysrFxl5qqqqZouy0mU81ZmApB6cp2vKlrFVk+Z7TGRuPOsXRZSNfGYmEO\/ofoXmOiKKS3Ga6wPYeRNxk9Vo49BONAIL1mUdIBa9bxPgn+zMOkAqIXDdQbp1sKAy6uWeyWd0Cyuk5LDh3pTtez\/NSVJqNwbh5kNZB8htkTrP1zHA9dM1nZ07nExmc50ZQGA7M+GxyLden9MA\/OLm\/KKe34xPoKAD7jPkAAAAAElFTkSuQmCC","width":22}
%---
%[text:image:85ba]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:slider:7991]
%   data: {"defaultValue":0.1,"label":"Learning Rate:","max":0.4,"min":0.1,"run":"Nothing","runOn":"ValueChanged","step":0.01}
%---
%[control:slider:1a10]
%   data: {"defaultValue":1,"label":"Number of Steps:","max":140,"min":0,"run":"Nothing","runOn":"ValueChanging","step":10}
%---
%[control:button:3816]
%   data: {"label":"Visualize Gradient Descent","run":"Section"}
%---
%[text:image:2051]
%   data: {"align":"baseline","height":24,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAsCAYAAAAXb\/p7AAADlklEQVR42u1YS0hUYRQejR4UvR+SvaCyWiS2DIoCKWjVYzG2SsYWQ+a8HRwXFkOgqdGLSoSeqyBaJUGLCKGkNpGtgiyScnpYBpaU5au+E+eH03Wu93rvP2OEFw46955z\/u8\/7\/\/3eDQ+4XD4Eui65199AK4d1DEJcBLgfw0wGo2ujkQi1yoqKlY5AFgDqnWw5lpaMxaLrbBkDgaDm7HIEKjTCcjxPqFQqABrdYEGsHaRXaESCAyCXpNFMwwuReDw\/77xusurQGJna0ysPR2K94CnGdQKesnUyu92J5PJaelk4c51Chzcu9dp0O9nkO3yvd\/vnwqlEbzvAf2yoB5sIkwyBt0doJ+0Qbdu2AXyC8UrOVuNQH5Q3IJegfrTfH8ikwC\/A9hjsdaYCQQCG6D4vVj0DShB7+HKXMGaQ\/EFADEGrPhJdn1GAhoZvRDKX4jFTvt8vhlWchSD4D0OGiE5AH9eXl4+PxNF+IoCB8sccyBfreQB8qJWcAC0CYqHeYE2cqEDNTmQvcc6hlC+CnXWq\/PCtTtdeGGr0HNWFz7aeTcr\/eT1eqe41PVWJYxd62zkovwXqQ6Cv8vErm9r8MZNEctLVf9Ph4GwecSOjPSQu8V28e6chmRrFPq28btHJhhSBKDIBH0B726HEDilAWCtsGCx6MmjMNgaHqBkiygPl3UmHE1OrjOEiqoqsqDHGizYxrqGAXCOriL9jJUOoq3lO9UDQItpQGD3PtXZRapFHB51oSchwiWsDWA8Hl8Cpb2svA+WWO4AXJ7Q0Z1IJObq7sUBN\/UQLr0hrHfANSCaQihrobiBf+dC+QOxSNk4MrdEyN1VvRy6T+DdVbOp2wpcCyutN8yDahjtVZ3A4sS2ALwflYxhaK1n0C22QfL8dkuNRYZBlKxxRLj6gg3XNgj+w8beLOriHcv50gocJ8wsfP\/ASgfMDlRs8XzwfGPeThMr2QcpEqFprJmPSoSwSvMYfCcFX6nFlNPEfAGrUuC1GkhxQpspTnTfKysrFxl5qqqqZouy0mU81ZmApB6cp2vKlrFVk+Z7TGRuPOsXRZSNfGYmEO\/ofoXmOiKKS3Ga6wPYeRNxk9Vo49BONAIL1mUdIBa9bxPgn+zMOkAqIXDdQbp1sKAy6uWeyWd0Cyuk5LDh3pTtez\/NSVJqNwbh5kNZB8htkTrP1zHA9dM1nZ07nExmc50ZQGA7M+GxyLden9MA\/OLm\/KKe34xPoKAD7jPkAAAAAElFTkSuQmCC","width":22}
%---
%[text:image:6b2a]
%   data: {"align":"baseline","height":20,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAADUAAAAxCAYAAAB6d+FmAAAC0ElEQVR42u2aO4gTURSGs6Lugo1WW2ghgiyCr1VWbRSR9YEgKoKohcQmEDAviYhBIaVbbKEWYi22YidoobUItoqwjSui6wt119Wsj+\/onXAcJslMZpI7AxP4Sbh37pnz3TP3zJ2TyWQS9imVStvRK1G5XL5ZqVRWZpL8MUCf0G+lz+hYIoGIyDYPIEc\/i8ViLmkRGkMfWwA5WkD7EwHEutmCs+87ADl6zfHLm4MLhcIqGs7RcV0WoA1xCa3vIkL\/CTsX\/w7G2Bka5oIMjlo4M6GBmOTRABHSeirh3S0LzSYQugHHgAPEJG+l7UOXtr6LgQeqYQZdRVf6Jc5frdfriyKIkOgHQToi1+0XpxGD+ywnhc348a5bICboqLMYmx02784hgRYAOqEzjHWoSIHiABU5kG2osECMP9lqC2IFiqS0qSdAtqAM0Ey3QOhUp81iX6F6DtRvKM6xsedA\/YQKCdQgyx0PcrKeQ4WNkE4K+LhGb6usQOHQOnnOCb31+WdrNW1TQC22BoW9Ddh9i6bRfNDdNkCH1c59LW0vpc8qFDYfo\/tkvMFqtbqM3xdkffgAmseXQ44dM3ba6bcGlc1mh9yzbaK3k\/Y37YAYc9Dl47A+xhoU0dlh7A579I3qRx6lbwAd8PAxHlA4V5BF3ea8Z11Ac62e52IDhb1bZuZL+lFdRWtQpflZzj3exlZsIvVc2b7jdW8xiWSWVL2ng4\/2ofL5\/Ars\/XJdXudN9wC\/R4Ce5PurFH58RN0+FLb2et130D1VVJlCu3zasw9FFC67dwboialUnZadQcBJsg+F09ewd9tkwLFcLrckZOTjkSgi3pmkUClUCpVCpVApVAqVQqVQ0UDp6s5IHKFMeaz5doufYuYz9bf\/XXmXQaqgcZH4I34pqBd+Qluz\/LpBUF3qCEUol3LgwyQAEbFHUrDxW6OTyk7NFEsaMYNpGL9qfoH+AOOEPfJuI6OmAAAAAElFTkSuQmCC","width":22}
%---
%[control:dropdown:1221]
%   data: {"defaultValue":"\"Select\"","itemLabels":["Select","a.","b.","c.","d."],"items":["\"Select\"","\"a.\"","\"b.\"","\"c.\"","\"d.\""],"label":"Select an answer.","run":"Section"}
%---
