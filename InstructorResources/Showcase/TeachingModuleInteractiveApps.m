classdef TeachingModuleInteractiveApps < handle
    properties (Access = private)
        UIFigure matlab.ui.Figure
        TabGroup matlab.ui.container.TabGroup

        ContentsTab matlab.ui.container.Tab
        Gradient2DTab matlab.ui.container.Tab
        Gradient3DTab matlab.ui.container.Tab
        RegularizationTab matlab.ui.container.Tab
        EnsembleTab matlab.ui.container.Tab
        DecisionTab matlab.ui.container.Tab
        DiagnosisTab matlab.ui.container.Tab

        Gradient2DAlphaSlider matlab.ui.control.Slider
        Gradient2DStepSpinner matlab.ui.control.Spinner
        Gradient2DSeedLabel matlab.ui.control.Label
        Gradient2DSummaryLabel matlab.ui.control.Label
        Gradient2DAxes matlab.ui.control.UIAxes
        Gradient2DHistoryAxes matlab.ui.control.UIAxes
        Gradient2DScenario (1,1) struct

        Gradient3DAlphaSlider matlab.ui.control.Slider
        Gradient3DStepSpinner matlab.ui.control.Spinner
        Gradient3DSeedLabel matlab.ui.control.Label
        Gradient3DSummaryLabel matlab.ui.control.Label
        Gradient3DSurfaceAxes matlab.ui.control.UIAxes
        Gradient3DContourAxes matlab.ui.control.UIAxes
        Gradient3DFitAxes matlab.ui.control.UIAxes
        Gradient3DProgressAxes matlab.ui.control.UIAxes
        Gradient3DScenario (1,1) struct

        RegularizationLambdaSlider matlab.ui.control.Slider
        RegularizationSeedLabel matlab.ui.control.Label
        RegularizationSummaryLabel matlab.ui.control.Label
        RegularizationPathAxes matlab.ui.control.UIAxes
        RegularizationCoefficientAxes matlab.ui.control.UIAxes
        RegularizationSliceAxes matlab.ui.control.UIAxes
        RegularizationAnalysis (1,1) struct

        EnsembleTreesSlider matlab.ui.control.Slider
        EnsembleSplitsSlider matlab.ui.control.Slider
        EnsembleSeedLabel matlab.ui.control.Label
        EnsembleSummaryLabel matlab.ui.control.Label
        EnsembleFitAxes matlab.ui.control.UIAxes
        EnsembleTrendAxes matlab.ui.control.UIAxes
        EnsembleData (1,1) struct

        DecisionHourSlider matlab.ui.control.Slider
        DecisionTemperatureSlider matlab.ui.control.Slider
        DecisionSeedLabel matlab.ui.control.Label
        DecisionSummaryLabel matlab.ui.control.Label
        DecisionAxes matlab.ui.control.UIAxes
        DecisionSpec (1,1) struct

        DiagnosisPatternDropDown matlab.ui.control.DropDown
        DiagnosisNoiseSlider matlab.ui.control.Slider
        DiagnosisSeedLabel matlab.ui.control.Label
        DiagnosisSummaryLabel matlab.ui.control.Label
        DiagnosisFitAxes matlab.ui.control.UIAxes
        DiagnosisResidualAxes matlab.ui.control.UIAxes
        DiagnosisSummaryAxes matlab.ui.control.UIAxes
        DiagnosisSeed (1,1) double = 0

        Gradient2DInitialized (1,1) logical = false
        Gradient3DInitialized (1,1) logical = false
        RegularizationInitialized (1,1) logical = false
        EnsembleInitialized (1,1) logical = false
        DecisionInitialized (1,1) logical = false
        DiagnosisInitialized (1,1) logical = false
    end

    methods
        function app = TeachingModuleInteractiveApps(initialTab)
            arguments
                initialTab (1,1) string = "Contents"
            end

            buildUI(app)
            selectTab(app,initialTab)
            initializeSelectedTab(app)

            if nargout == 0
                clear app
            end
        end

        function delete(app)
            if ~isempty(app.UIFigure) && isvalid(app.UIFigure)
                delete(app.UIFigure)
            end
        end
    end

    methods (Access = private)
        function buildUI(app)
            app.UIFigure = uifigure( ...
                "Name","Machine Learning Interactive Apps",...
                "Position",[40 40 1540 940]);

            app.TabGroup = uitabgroup(app.UIFigure,"Position",[12 12 1516 916]);
            app.TabGroup.SelectionChangedFcn = @(~,evt) handleTabChanged(app,evt.NewValue);

            buildContentsTab(app)
            buildGradient2DTab(app)
            buildGradient3DTab(app)
            buildRegularizationTab(app)
            buildEnsembleTab(app)
            buildDecisionTab(app)
            buildDiagnosisTab(app)
            app.TabGroup.SelectedTab = app.ContentsTab;
        end

        function buildContentsTab(app)
            app.ContentsTab = uitab(app.TabGroup,"Title","Contents");
            grid = uigridlayout(app.ContentsTab,[2 2]);
            grid.RowHeight = {"fit","1x"};
            grid.ColumnWidth = {360,"1x"};
            grid.Padding = [12 12 12 12];
            grid.RowSpacing = 10;
            grid.ColumnSpacing = 10;

            addTabHeader(app,grid,...
                "Interactive Apps Table of Contents",...
                "This standalone app collects six interactive demos for regression modeling, optimization, and model diagnosis. Start anywhere from the contents page and use the live controls inside each tab to explore the concept.");

            overviewPanel = uipanel(grid,...
                "Title","Overview");
            overviewPanel.Layout.Row = 2;
            overviewPanel.Layout.Column = 1;
            overviewGrid = uigridlayout(overviewPanel,[11 1]);
            overviewGrid.RowHeight = {"fit","fit","fit","fit","fit","fit","fit","fit","fit","fit","1x"};
            overviewGrid.Padding = [12 12 12 12];
            overviewGrid.RowSpacing = 8;

            uilabel(overviewGrid,...
                "Text","Machine Learning Interactive Apps",...
                "FontWeight","bold",...
                "FontSize",16,...
                "FontColor",seriesColor(app,1));

            uilabel(overviewGrid,...
                "Text","Through interactive demos, this app introduces the machine learning workflow for regression, including baseline modeling, model improvement, tree-based methods, and hyperparameter optimization.",...
                "WordWrap","on",...
                "FontSize",11,...
                "Interpreter","none");
            uilabel(overviewGrid,...
                "Text","Each tab is self-contained and generates its own example data, so you do not need the teaching module showcase to use these demos.",...
                "WordWrap","on",...
                "FontSize",11,...
                "Interpreter","none");
            uilabel(overviewGrid,...
                "Text","Suggested flow: start with a baseline model, diagnose what it misses, then compare feature engineering, trees, ensembles, and optimization behavior.",...
                "WordWrap","on",...
                "FontSize",11,...
                "Interpreter","none");
            uilabel(overviewGrid,...
                "Text","Open related scripts if you want the longer narrative versions of these topics.",...
                "WordWrap","on",...
                "FontSize",11,...
                "Interpreter","none");

            uilabel(overviewGrid,...
                "Text","Related Scripts",...
                "FontWeight","bold",...
                "FontSize",13);
            uibutton(overviewGrid,"Text","Open Overview of Machine Learning for Regression",...
                "ButtonPushedFcn",@(~,~) openModuleScript(app,"MLOverview.m"));
            uibutton(overviewGrid,"Text","Open Optimization and Gradient Descent for Regression",...
                "ButtonPushedFcn",@(~,~) openModuleScript(app,"OptimizationandGradientDescentforRegression.m"));
            uibutton(overviewGrid,"Text","Open Feature Engineering and Regularization",...
                "ButtonPushedFcn",@(~,~) openModuleScript(app,"FeatureEngRegularization.m"));
            uibutton(overviewGrid,"Text","Open Decision Trees and Ensemble Methods",...
                "ButtonPushedFcn",@(~,~) openModuleScript(app,"DecisionTreesandEnsembleMethods.m"));
            uilabel(overviewGrid,"Text","","Visible","off");

            cardGrid = uigridlayout(grid,[3 2]);
            cardGrid.Layout.Row = 2;
            cardGrid.Layout.Column = 2;
            cardGrid.RowHeight = {"1x","1x","1x"};
            cardGrid.ColumnWidth = {"1x","1x"};
            cardGrid.RowSpacing = 10;
            cardGrid.ColumnSpacing = 10;
            cardGrid.Padding = [0 0 0 0];

            addContentsCard(app,cardGrid,1,1,...
                "2D Gradient Descent",...
                "Visualize how the learning rate changes convergence on a simple quadratic objective.",...
                "2D Gradient Descent");
            addContentsCard(app,cardGrid,1,2,...
                "3D Gradient Descent",...
                "Trace parameter updates across the MSE surface for linear regression.",...
                "3D Gradient Descent");
            addContentsCard(app,cardGrid,2,1,...
                "Lasso and Ridge",...
                "Compare coefficient shrinkage, sparsity, and prediction behavior as λ changes.",...
                "Regularization");
            addContentsCard(app,cardGrid,2,2,...
                "Ensemble of Trees",...
                "See how bagging and boosting change fit quality relative to a single tree.",...
                "Ensemble");
            addContentsCard(app,cardGrid,3,1,...
                "Decision Trees",...
                "Follow the path an example takes through local if-then splits.",...
                "Decision Trees");
            addContentsCard(app,cardGrid,3,2,...
                "When a Line Is Not Enough",...
                "Use residual structure and validation error to justify moving beyond a straight line.",...
                "When a Line Is Not Enough");
        end

        function buildGradient2DTab(app)
            app.Gradient2DTab = uitab(app.TabGroup,"Title","2D Gradient Descent");
            grid = uigridlayout(app.Gradient2DTab,[3 2]);
            grid.RowHeight = {"fit","fit","1x"};
            grid.ColumnWidth = {280,"1x"};
            grid.Padding = [12 12 12 12];
            grid.RowSpacing = 10;
            grid.ColumnSpacing = 10;

            addTabHeader(app,grid,"2D Gradient Descent","",true);

            controls = uipanel(grid,"Title","Controls");
            controls.Layout.Row = [2 3];
            controls.Layout.Column = 1;
            controlsGrid = uigridlayout(controls,[10 1]);
            controlsGrid.RowHeight = {"fit","fit","fit","fit","fit","fit","fit","fit","fit","1x"};
            controlsGrid.Padding = [10 10 10 10];

            addControlDescription(app,controlsGrid,...
                "Gradient descent updates x by subtracting α times the slope. On f(x) = x^2, the slope is large far from zero and shrinks as you approach the minimum." + newline + newline + ...
                "Try a small α for slow progress, a moderate α for stable convergence, and α near 1 to see the updates bounce across the valley.");

            uilabel(controlsGrid,"Text","Learning rate");
            app.Gradient2DAlphaSlider = uislider(controlsGrid,...
                "Limits",[0.01 1.2],...
                "Value",0.10,...
                "MajorTicks",[0.02 0.20 1.00],...
                "ValueChangedFcn",@(~,~) updateGradient2D(app));

            uilabel(controlsGrid,"Text","Max iterations");
            app.Gradient2DStepSpinner = uispinner(controlsGrid,...
                "Limits",[5 250],...
                "RoundFractionalValues","on",...
                "Value",40,...
                "ValueChangedFcn",@(~,~) updateGradient2D(app));

            app.Gradient2DSeedLabel = uilabel(controlsGrid,"Text","");
            app.Gradient2DSummaryLabel = uilabel(controlsGrid,...
                "Text","","WordWrap","on");

            uibutton(controlsGrid,"Text","Reset Example",...
                "ButtonPushedFcn",@(~,~) randomizeGradient2D(app));
            uibutton(controlsGrid,"Text","Run Again",...
                "ButtonPushedFcn",@(~,~) updateGradient2D(app));

            plotGrid = uigridlayout(grid,[1 2]);
            plotGrid.Layout.Row = [2 3];
            plotGrid.Layout.Column = 2;
            plotGrid.ColumnWidth = {"1x","1x"};
            plotGrid.Padding = [0 0 0 0];

            app.Gradient2DAxes = uiaxes(plotGrid);
            title(app.Gradient2DAxes,"Gradient Descent on $f(x)=x^2$",Interpreter="latex")
            xlabel(app.Gradient2DAxes,"$x$",Interpreter="latex")
            ylabel(app.Gradient2DAxes,"$f(x)$",Interpreter="latex")
            styleAxes(app,app.Gradient2DAxes)

            app.Gradient2DHistoryAxes = uiaxes(plotGrid);
            title(app.Gradient2DHistoryAxes,"Cost History",Interpreter="latex")
            xlabel(app.Gradient2DHistoryAxes,"Iteration",Interpreter="latex")
            ylabel(app.Gradient2DHistoryAxes,"$f(x)$",Interpreter="latex")
            styleAxes(app,app.Gradient2DHistoryAxes)
        end

        function buildGradient3DTab(app)
            app.Gradient3DTab = uitab(app.TabGroup,"Title","3D Gradient Descent");
            grid = uigridlayout(app.Gradient3DTab,[3 2]);
            grid.RowHeight = {"fit","fit","1x"};
            grid.ColumnWidth = {300,"1x"};
            grid.Padding = [12 12 12 12];
            grid.RowSpacing = 10;
            grid.ColumnSpacing = 10;

            addTabHeader(app,grid,"3D Gradient Descent on the MSE Surface","",true);

            controls = uipanel(grid,"Title","Controls");
            controls.Layout.Row = [2 3];
            controls.Layout.Column = 1;
            controlsGrid = uigridlayout(controls,[11 1]);
            controlsGrid.RowHeight = {"fit","fit","fit","fit","fit","fit","fit","fit","fit","fit","1x"};
            controlsGrid.Padding = [10 10 10 10];

            addControlDescription(app,controlsGrid,...
                "Linear regression chooses θ₁ and θ₀ to minimize mean-squared error. Each gradient step moves downhill on the cost surface while the fitted line and MSE plots update to show the same change from different views." + newline + newline + ...
                "Try increasing the learning rate to compare smooth convergence with overshooting or divergence.");

            uilabel(controlsGrid,"Text","Learning rate");
            app.Gradient3DAlphaSlider = uislider(controlsGrid,...
                "Limits",[0.005 0.25],...
                "Value",0.10,...
                "MajorTicks",[0.02 0.10 0.25],...
                "ValueChangedFcn",@(~,~) updateGradient3D(app));

            uilabel(controlsGrid,"Text","Animated steps");
            app.Gradient3DStepSpinner = uispinner(controlsGrid,...
                "Limits",[5 60],...
                "RoundFractionalValues","on",...
                "Value",25,...
                "ValueChangedFcn",@(~,~) updateGradient3D(app));

            app.Gradient3DSeedLabel = uilabel(controlsGrid,"Text","");
            app.Gradient3DSummaryLabel = uilabel(controlsGrid,"Text","","WordWrap","on");

            uibutton(controlsGrid,"Text","Change Scenario",...
                "ButtonPushedFcn",@(~,~) randomizeGradient3D(app));
            uibutton(controlsGrid,"Text","Animate",...
                "ButtonPushedFcn",@(~,~) updateGradient3D(app));

            plots = uigridlayout(grid,[2 2]);
            plots.Layout.Row = [2 3];
            plots.Layout.Column = 2;
            plots.Padding = [0 0 0 0];

            app.Gradient3DSurfaceAxes = uiaxes(plots);
            title(app.Gradient3DSurfaceAxes,"Cost Surface and Descent Path",Interpreter="latex")
            xlabel(app.Gradient3DSurfaceAxes,"$\theta_1$",Interpreter="latex")
            ylabel(app.Gradient3DSurfaceAxes,"$\theta_0$",Interpreter="latex")
            zlabel(app.Gradient3DSurfaceAxes,"MSE",Interpreter="latex")
            styleAxes(app,app.Gradient3DSurfaceAxes)

            app.Gradient3DContourAxes = uiaxes(plots);
            title(app.Gradient3DContourAxes,"Contour View of Parameter Updates",Interpreter="latex")
            xlabel(app.Gradient3DContourAxes,"$\theta_1$",Interpreter="latex")
            ylabel(app.Gradient3DContourAxes,"$\theta_0$",Interpreter="latex")
            styleAxes(app,app.Gradient3DContourAxes)

            app.Gradient3DFitAxes = uiaxes(plots);
            title(app.Gradient3DFitAxes,"Fit Updates",Interpreter="latex")
            xlabel(app.Gradient3DFitAxes,"$x$",Interpreter="latex")
            ylabel(app.Gradient3DFitAxes,"$y$",Interpreter="latex")
            styleAxes(app,app.Gradient3DFitAxes)

            app.Gradient3DProgressAxes = uiaxes(plots);
            title(app.Gradient3DProgressAxes,"Optimization Progress",Interpreter="latex")
            xlabel(app.Gradient3DProgressAxes,"Iteration",Interpreter="latex")
            ylabel(app.Gradient3DProgressAxes,"MSE",Interpreter="latex")
            styleAxes(app,app.Gradient3DProgressAxes)
        end

        function buildRegularizationTab(app)
            app.RegularizationTab = uitab(app.TabGroup,"Title","Lasso and Ridge");
            grid = uigridlayout(app.RegularizationTab,[3 2]);
            grid.RowHeight = {"fit","fit","1x"};
            grid.ColumnWidth = {300,"1x"};
            grid.Padding = [12 12 12 12];

            addTabHeader(app,grid,"Regularization with Lasso and Ridge Regression","",true);

            controls = uipanel(grid,"Title","Controls");
            controls.Layout.Row = [2 3];
            controls.Layout.Column = 1;
            controlsGrid = uigridlayout(controls,[9 1]);
            controlsGrid.RowHeight = {"fit","fit","fit","fit","fit","fit","fit","fit","1x"};
            controlsGrid.Padding = [10 10 10 10];

            addControlDescription(app,controlsGrid,...
                "Regularization adds a penalty to the loss so the model must balance fit quality against coefficient size. Ridge shrinks weights smoothly, while Lasso can drive weaker terms all the way to zero." + newline + newline + ...
                "Move through λ values to see when the model is flexible enough to fit structure and when the penalty starts removing useful signal.");

            uilabel(controlsGrid,"Text","Lambda index","Interpreter","latex");
            app.RegularizationLambdaSlider = uislider(controlsGrid,...
                "Limits",[1 50],...
                "Value",25,...
                "MajorTicks",[1 10 20 30 40 50],...
                "ValueChangedFcn",@(~,~) updateRegularization(app));

            app.RegularizationSeedLabel = uilabel(controlsGrid,"Text","Seed:","Interpreter","latex");
            app.RegularizationSummaryLabel = uilabel(controlsGrid,"Text","","WordWrap","on","Interpreter","latex");

            uibutton(controlsGrid,"Text","Randomize",...
                "ButtonPushedFcn",@(~,~) randomizeRegularization(app));
            uibutton(controlsGrid,"Text","Use Best Lasso",...
                "ButtonPushedFcn",@(~,~) jumpToBestLasso(app));
            uibutton(controlsGrid,"Text","Use Best Ridge",...
                "ButtonPushedFcn",@(~,~) jumpToBestRidge(app));

            plots = uigridlayout(grid,[2 2]);
            plots.Layout.Row = [2 3];
            plots.Layout.Column = 2;
            plots.RowHeight = {"1x","1x"};
            plots.ColumnWidth = {"1x","1x"};
            plots.Padding = [0 0 0 0];

            app.RegularizationPathAxes = uiaxes(plots);
            title(app.RegularizationPathAxes,"Coefficient Paths",Interpreter="latex")
            xlabel(app.RegularizationPathAxes,"$\\lambda$",Interpreter="latex")
            ylabel(app.RegularizationPathAxes,"Standardized Coefficient",Interpreter="latex")
            app.RegularizationPathAxes.XScale = "log";
            styleAxes(app,app.RegularizationPathAxes)

            app.RegularizationCoefficientAxes = uiaxes(plots);
            title(app.RegularizationCoefficientAxes,"Current Coefficients",Interpreter="latex")
            xlabel(app.RegularizationCoefficientAxes,"Coefficient",Interpreter="latex")
            ylabel(app.RegularizationCoefficientAxes,"Feature",Interpreter="latex")
            styleAxes(app,app.RegularizationCoefficientAxes)

            app.RegularizationSliceAxes = uiaxes(plots);
            app.RegularizationSliceAxes.Layout.Row = 2;
            app.RegularizationSliceAxes.Layout.Column = [1 2];
            title(app.RegularizationSliceAxes,"Representative Slice Fits",Interpreter="latex")
            xlabel(app.RegularizationSliceAxes,"$x$",Interpreter="latex")
            ylabel(app.RegularizationSliceAxes,"$y$",Interpreter="latex")
            styleAxes(app,app.RegularizationSliceAxes)
        end

        function buildEnsembleTab(app)
            app.EnsembleTab = uitab(app.TabGroup,"Title","Ensemble of Trees");
            grid = uigridlayout(app.EnsembleTab,[3 2]);
            grid.RowHeight = {"fit","fit","1x"};
            grid.ColumnWidth = {300,"1x"};
            grid.Padding = [12 12 12 12];

            addTabHeader(app,grid,"Ensemble of Trees","",true);

            controls = uipanel(grid,"Title","Controls");
            controls.Layout.Row = [2 3];
            controls.Layout.Column = 1;
            controlsGrid = uigridlayout(controls,[10 1]);
            controlsGrid.RowHeight = {"fit","fit","fit","fit","fit","fit","fit","fit","fit","1x"};
            controlsGrid.Padding = [10 10 10 10];

            addControlDescription(app,controlsGrid,...
                "A single tree makes piecewise decisions and can be sensitive to local variation in the data. Ensembles combine many trees so the overall predictor can reduce variance with bagging or reduce bias by sequentially correcting mistakes with boosting." + newline + newline + ...
                "Use the sliders to compare how tree count and tree complexity change the fit curve and the training-error trend.");

            uilabel(controlsGrid,"Text","Number of trees","Interpreter","latex");
            app.EnsembleTreesSlider = uislider(controlsGrid,...
                "Limits",[5 40],...
                "Value",18,...
                "MajorTicks",[5 10 20 30 40],...
                "ValueChangedFcn",@(~,~) updateEnsemble(app));

            uilabel(controlsGrid,"Text","Max splits per tree","Interpreter","latex");
            app.EnsembleSplitsSlider = uislider(controlsGrid,...
                "Limits",[1 8],...
                "Value",4,...
                "MajorTicks",1:8,...
                "ValueChangedFcn",@(~,~) updateEnsemble(app));

            app.EnsembleSeedLabel = uilabel(controlsGrid,"Text","Seed:","Interpreter","latex");
            app.EnsembleSummaryLabel = uilabel(controlsGrid,"Text","","WordWrap","on","Interpreter","latex");

            uibutton(controlsGrid,"Text","Randomize",...
                "ButtonPushedFcn",@(~,~) randomizeEnsemble(app));

            plots = uigridlayout(grid,[2 1]);
            plots.Layout.Row = [2 3];
            plots.Layout.Column = 2;
            plots.Padding = [0 0 0 0];

            app.EnsembleFitAxes = uiaxes(plots);
            title(app.EnsembleFitAxes,"Single Tree Versus Ensembles",Interpreter="latex")
            xlabel(app.EnsembleFitAxes,"Hour",Interpreter="latex")
            ylabel(app.EnsembleFitAxes,"Load",Interpreter="latex")
            styleAxes(app,app.EnsembleFitAxes)

            app.EnsembleTrendAxes = uiaxes(plots);
            title(app.EnsembleTrendAxes,"Training MSE by Number of Trees",Interpreter="latex")
            xlabel(app.EnsembleTrendAxes,"Trees",Interpreter="latex")
            ylabel(app.EnsembleTrendAxes,"Training MSE",Interpreter="latex")
            styleAxes(app,app.EnsembleTrendAxes)
        end

        function buildDecisionTab(app)
            app.DecisionTab = uitab(app.TabGroup,"Title","Decision Trees");
            grid = uigridlayout(app.DecisionTab,[3 2]);
            grid.RowHeight = {"fit","fit","1x"};
            grid.ColumnWidth = {300,"1x"};
            grid.Padding = [12 12 12 12];

            addTabHeader(app,grid,"Decision Trees","",true);

            controls = uipanel(grid,"Title","Controls");
            controls.Layout.Row = [2 3];
            controls.Layout.Column = 1;
            controlsGrid = uigridlayout(controls,[10 1]);
            controlsGrid.RowHeight = {"fit","fit","fit","fit","fit","fit","fit","fit","fit","1x"};
            controlsGrid.Padding = [10 10 10 10];

            addControlDescription(app,controlsGrid,...
                "Decision trees split the feature space into regions using a sequence of local if-then rules. Instead of one global formula, the model routes each example down a path and assigns the prediction stored at the terminal leaf." + newline + newline + ...
                "Adjust the input values to watch the active path change and see how small feature changes can move an example into a different region.");

            uilabel(controlsGrid,"Text","Hour","Interpreter","latex");
            app.DecisionHourSlider = uislider(controlsGrid,...
                "Limits",[0 23],...
                "Value",9,...
                "MajorTicks",0:3:23,...
                "ValueChangedFcn",@(~,~) updateDecisionPath(app));

            uilabel(controlsGrid,"Text","Temperature","Interpreter","latex");
            app.DecisionTemperatureSlider = uislider(controlsGrid,...
                "Limits",[45 95],...
                "Value",68,...
                "MajorTicks",45:10:95,...
                "ValueChangedFcn",@(~,~) updateDecisionPath(app));

            app.DecisionSeedLabel = uilabel(controlsGrid,"Text","Seed:","Interpreter","latex");
            app.DecisionSummaryLabel = uilabel(controlsGrid,"Text","","WordWrap","on","Interpreter","latex");

            uibutton(controlsGrid,"Text","Reset Example",...
                "ButtonPushedFcn",@(~,~) randomizeDecisionPath(app));

            app.DecisionAxes = uiaxes(grid);
            app.DecisionAxes.Layout.Row = [2 3];
            app.DecisionAxes.Layout.Column = 2;
            title(app.DecisionAxes,"Interactive Decision Tree",Interpreter="latex")
            axis(app.DecisionAxes,[0 1 0 1])
            app.DecisionAxes.Visible = "off";
            box(app.DecisionAxes,"on")
        end

        function buildDiagnosisTab(app)
            app.DiagnosisTab = uitab(app.TabGroup,"Title","When a Line Is Not Enough");
            grid = uigridlayout(app.DiagnosisTab,[3 2]);
            grid.RowHeight = {"fit","fit","1x"};
            grid.ColumnWidth = {300,"1x"};
            grid.Padding = [12 12 12 12];

            addTabHeader(app,grid,"Diagnosing When a Line Is No Longer Enough","",true);

            controls = uipanel(grid,"Title","Controls");
            controls.Layout.Row = [2 3];
            controls.Layout.Column = 1;
            controlsGrid = uigridlayout(controls,[10 1]);
            controlsGrid.RowHeight = {"fit","fit","fit","fit","fit","fit","fit","fit","fit","1x"};
            controlsGrid.Padding = [10 10 10 10];

            addControlDescription(app,controlsGrid,...
                "A straight-line model is often the right baseline, but residual patterns can reveal when it is missing structure that a more flexible model can capture. Comparing both the residual plot and validation error helps separate real signal from overfitting." + newline + newline + ...
                "Switch among pattern types and noise levels to practice deciding when the line is still adequate and when another model is justified.");

            uilabel(controlsGrid,"Text","Pattern","Interpreter","latex");
            app.DiagnosisPatternDropDown = uidropdown(controlsGrid,...
                "Items",["Smooth curve","Threshold rule","Mixed seasonal"],...
                "Value","Threshold rule",...
                "ValueChangedFcn",@(~,~) updateDiagnosis(app));

            uilabel(controlsGrid,"Text","Noise level","Interpreter","latex");
            app.DiagnosisNoiseSlider = uislider(controlsGrid,...
                "Limits",[0.15 1.2],...
                "Value",0.45,...
                "MajorTicks",[0.15 0.3 0.6 0.9 1.2],...
                "ValueChangedFcn",@(~,~) updateDiagnosis(app));

            app.DiagnosisSeedLabel = uilabel(controlsGrid,"Text","Seed:","Interpreter","latex");
            app.DiagnosisSummaryLabel = uilabel(controlsGrid,"Text","","WordWrap","on","Interpreter","latex");

            uibutton(controlsGrid,"Text","Randomize",...
                "ButtonPushedFcn",@(~,~) randomizeDiagnosis(app));

            plots = uigridlayout(grid,[2 2]);
            plots.Layout.Row = [2 3];
            plots.Layout.Column = 2;
            plots.Padding = [0 0 0 0];

            app.DiagnosisFitAxes = uiaxes(plots);
            title(app.DiagnosisFitAxes,"Linear Baseline Versus Better Fits",Interpreter="latex")
            xlabel(app.DiagnosisFitAxes,"$x$",Interpreter="latex")
            ylabel(app.DiagnosisFitAxes,"$y$",Interpreter="latex")
            styleAxes(app,app.DiagnosisFitAxes)

            app.DiagnosisResidualAxes = uiaxes(plots);
            title(app.DiagnosisResidualAxes,"Linear Residual Pattern",Interpreter="latex")
            xlabel(app.DiagnosisResidualAxes,"$x$",Interpreter="latex")
            ylabel(app.DiagnosisResidualAxes,"Residual",Interpreter="latex")
            styleAxes(app,app.DiagnosisResidualAxes)

            app.DiagnosisSummaryAxes = uiaxes(plots);
            app.DiagnosisSummaryAxes.Layout.Row = 2;
            app.DiagnosisSummaryAxes.Layout.Column = [1 2];
            title(app.DiagnosisSummaryAxes,"Validation RMSE Comparison",Interpreter="latex")
            xlabel(app.DiagnosisSummaryAxes,"Model",Interpreter="latex")
            ylabel(app.DiagnosisSummaryAxes,"Validation RMSE",Interpreter="latex")
            styleAxes(app,app.DiagnosisSummaryAxes)
        end

        function addTabHeader(app,grid,titleText,subtitleText,showContentsButton)
            if nargin < 4
                subtitleText = "";
            end
            if nargin < 5
                showContentsButton = false;
            end

            headerPanel = uipanel(grid,...
                "BorderType","line");
            headerPanel.Layout.Row = 1;
            headerPanel.Layout.Column = [1 2];

            headerGrid = uigridlayout(headerPanel,[2 2]);
            headerGrid.RowHeight = {"fit","fit"};
            headerGrid.ColumnWidth = {"1x","fit"};
            headerGrid.Padding = [10 10 10 10];
            headerGrid.RowSpacing = 4;
            headerGrid.ColumnSpacing = 10;

            titleLabel = uilabel(headerGrid,...
                "Text",titleText,...
                "FontWeight","bold",...
                "FontSize",18,...
                "Interpreter","none");
            titleLabel.Layout.Row = 1;
            titleLabel.Layout.Column = 1;
            if subtitleText ~= ""
                subtitleLabel = uilabel(headerGrid,...
                    "Text",subtitleText,...
                    "WordWrap","on",...
                    "FontSize",11,...
                    "Interpreter","none");
                subtitleLabel.Layout.Row = 2;
                subtitleLabel.Layout.Column = 1;
            else
                subtitleLabel = uilabel(headerGrid,"Text","","Visible","off");
                subtitleLabel.Layout.Row = 2;
                subtitleLabel.Layout.Column = 1;
            end

            if showContentsButton
                contentsButton = uibutton(headerGrid,...
                    "Text","Back to Contents",...
                    "ButtonPushedFcn",@(~,~) openTab(app,"Contents"));
                contentsButton.Layout.Row = [1 2];
                contentsButton.Layout.Column = 2;
            end
        end

        function addContentsCard(app,parent,rowIdx,colIdx,titleText,bodyText,targetTab)
            card = uipanel(parent,...
                "BorderType","line");
            card.Layout.Row = rowIdx;
            card.Layout.Column = colIdx;

            cardGrid = uigridlayout(card,[4 1]);
            cardGrid.RowHeight = {"fit",148,"fit","fit"};
            cardGrid.Padding = [10 10 10 10];
            cardGrid.RowSpacing = 8;

            uilabel(cardGrid,...
                "Text",titleText,...
                "FontWeight","bold",...
                "FontSize",18,...
                "HorizontalAlignment","center",...
                "BackgroundColor",seriesColor(app,1));
            previewHolder = uigridlayout(cardGrid,[1 3]);
            previewHolder.RowHeight = {"1x"};
            previewHolder.ColumnWidth = {"1x",148,"1x"};
            previewHolder.Padding = [0 0 0 0];
            previewHolder.ColumnSpacing = 0;
            previewHolder.RowSpacing = 0;
            previewAxes = uiaxes(previewHolder);
            previewAxes.Layout.Column = 2;
            previewAxes.Toolbar.Visible = "off";
            previewAxes.Interactions = [];
            drawContentsPreview(app,previewAxes,targetTab)
            uilabel(cardGrid,...
                "Text",bodyText,...
                "WordWrap","on",...
                "FontSize",11);
            uibutton(cardGrid,...
                "Text","Open App",...
                "ButtonPushedFcn",@(~,~) openTab(app,targetTab));
        end

        function drawContentsPreview(~,ax,targetTab)
            cla(ax)
            ax.Box = "on";
            ax.XGrid = "on";
            ax.YGrid = "on";
            ax.FontSize = 9;

            switch lower(char(targetTab))
                case '2d gradient descent'
                    x = linspace(-5,5,240);
                    y = x.^2;
                    xPath = [4.5 3.2 2.3 1.7 1.2 0.8 0.55];
                    yPath = xPath.^2;
                    plot(ax,x,y,"LineWidth",1.5,"SeriesIndex",1)
                    hold(ax,"on")
                    scatter(ax,xPath,yPath,28,"filled","SeriesIndex",2,DisplayName="Data")
                    plot(ax,xPath(end),yPath(end),"o",...
                        "MarkerSize",7,"MarkerFaceColor","auto","SeriesIndex",3)
                    hold(ax,"off")
                    xlabel(ax,"$x$",Interpreter="latex")
                    ylabel(ax,"$f(x)$",Interpreter="latex")
                    title(ax,"$f(x)$ versus $x$",Interpreter="latex",FontSize=10)

                case '3d gradient descent'
                    [theta1,theta0] = meshgrid(-2:0.2:4,-1:0.2:5);
                    cost = 0.25 * (theta1 - 1.2).^2 + 0.55 * (theta0 - 2.1).^2 + 0.08 * (theta1 - 1.2) .* (theta0 - 2.1);
                    surf(ax,theta1,theta0,cost,"EdgeColor","none","FaceAlpha",0.95)
                    hold(ax,"on")
                    t1Path = [3.5 2.8 2.1 1.7 1.4 1.25];
                    t0Path = [4.4 3.6 2.9 2.5 2.25 2.1];
                    cPath = 0.25 * (t1Path - 1.2).^2 + 0.55 * (t0Path - 2.1).^2 + 0.08 * (t1Path - 1.2) .* (t0Path - 2.1);
                    plot3(ax,t1Path,t0Path,cPath,"-","LineWidth",1.5,"SeriesIndex",1)
                    plot3(ax,t1Path(end),t0Path(end),cPath(end),"o",...
                        "MarkerSize",7,"MarkerFaceColor","auto","SeriesIndex",2)
                    hold(ax,"off")
                    view(ax,-70,25)
                    xlabel(ax,"$\theta_1$",Interpreter="latex")
                    ylabel(ax,"$\theta_0$",Interpreter="latex")
                    zlabel(ax,"MSE")
                    title(ax,"Cost Surface",FontSize=10)

                case 'regularization'
                    lambda = logspace(-3,2,80);
                    ridge1 = 1.1 ./ (1 + 0.4 * log10(lambda + 1e-3).^2);
                    ridge2 = -0.9 ./ (1 + 0.25 * (log10(lambda) + 1.8).^2);
                    lasso1 = max(0,1.05 - 0.24 * (log10(lambda) + 3));
                    lasso2 = min(0,-0.9 + 0.20 * (log10(lambda) + 3));
                    semilogx(ax,lambda,ridge1,"-","LineWidth",1.5,"SeriesIndex",1)
                    hold(ax,"on")
                    semilogx(ax,lambda,ridge2,"-","LineWidth",1.5,"SeriesIndex",2)
                    semilogx(ax,lambda,lasso1,"--","LineWidth",1.4,"SeriesIndex",3)
                    semilogx(ax,lambda,lasso2,"--","LineWidth",1.4,"SeriesIndex",4)
                    yline(ax,0,":","SeriesIndex",5)
                    hold(ax,"off")
                    xlabel(ax,"$\lambda$",Interpreter="latex")
                    ylabel(ax,"Coefficient")
                    title(ax,"Coefficient Paths",FontSize=10)

                case 'ensemble'
                    x = linspace(0,24,240);
                    singleTree = 1.4 + 0.25 * (x > 6) + 0.55 * (x > 11) - 0.30 * (x > 18);
                    ensembleFit = 1.35 + 0.55 ./ (1 + exp(-(x - 8))) + 0.35 * sin((x - 4) / 24 * 2 * pi);
                    plot(ax,x,singleTree,"-","LineWidth",1.6,"SeriesIndex",1)
                    hold(ax,"on")
                    plot(ax,x,ensembleFit,"-","LineWidth",1.8,"SeriesIndex",2)
                    hold(ax,"off")
                    xlabel(ax,"Hour")
                    ylabel(ax,"Load")
                    title(ax,"Single Tree vs Ensemble",FontSize=10)

                case 'decision trees'
                    positions = [0.50 0.82; 0.28 0.58; 0.72 0.58; 0.18 0.28; 0.38 0.28; 0.62 0.28; 0.82 0.28];
                    edges = [1 2; 1 3; 2 4; 2 5; 3 6; 3 7];
                    for idx = 1:size(edges,1)
                        p1 = positions(edges(idx,1),:);
                        p2 = positions(edges(idx,2),:);
                        plot(ax,[p1(1) p2(1)],[p1(2) p2(2)],"-","LineWidth",1.2,"SeriesIndex",1)
                        hold(ax,"on")
                    end
                    highlightNodes = [1 3 6];
                    for idx = 1:7
                        if any(highlightNodes == idx)
                            seriesIndex = 2;
                        else
                            seriesIndex = 1;
                        end
                        scatter(ax,positions(idx,1),positions(idx,2),1800,"s",...
                            "filled","MarkerFaceAlpha",0.25,"SeriesIndex",seriesIndex)
                    end
                    hold(ax,"off")
                    axis(ax,[0 1 0 1])
                    ax.XTick = [];
                    ax.YTick = [];
                    title(ax,"Interactive Decision Tree",Interpreter="latex",FontSize=10)

                otherwise
                    x = linspace(0,10,80);
                    yTrue = 1.5 + 0.35 * x + 0.9 * sin(0.8 * x);
                    yLine = 1.8 + 0.28 * x;
                    scatter(ax,x(1:6:end),yTrue(1:6:end) + 0.15 * sin(2 * x(1:6:end)),...
                        18,"filled","SeriesIndex",1,DisplayName="Data")
                    hold(ax,"on")
                    plot(ax,x,yLine,"--","LineWidth",1.4,"SeriesIndex",2)
                    plot(ax,x,yTrue,"-","LineWidth",1.8,"SeriesIndex",3)
                    hold(ax,"off")
                    xlabel(ax,"$x$",Interpreter="latex")
                    ylabel(ax,"$y$",Interpreter="latex")
                    title(ax,"Linear Baseline vs Better Fits",FontSize=10)
            end
        end

        function addControlDescription(~,controlsGrid,bodyText)
            uilabel(controlsGrid,...
                "Text",bodyText,...
                "WordWrap","on",...
                "FontSize",12);
        end

        function styleAxes(~,ax)
            ax.Box = "on";
            ax.XGrid = "on";
            ax.YGrid = "on";
            if isprop(ax,"ZGrid")
                ax.ZGrid = "on";
            end
        end

        function color = seriesColor(~,seriesIndex)
            colorOrder = get(groot,"FactoryAxesColorOrder");
            color = colorOrder(mod(seriesIndex - 1,size(colorOrder,1)) + 1,:);
        end

        function openTab(app,targetTab)
            selectTab(app,targetTab)
            initializeSelectedTab(app)
        end

        % function openModuleScript(app, scriptName)
        %     rootDir = fileparts(mfilename("fullpath"));
        %     scriptPath = fullfile(rootDir, scriptName);
        %     if isfile(scriptPath)
        %         open(scriptPath)
        %     else
        %         uialert(app.UIFigure, sprintf("Could not find %s.", scriptName), "Missing File");
        %     end
        % end
        function openModuleScript(app,scriptName)

            scriptPath = which(scriptName);

            if ~isempty(scriptPath)
                open(scriptPath)
            else
                uialert(app.UIFigure,...
                    sprintf("Could not find %s.",scriptName),...
                    "Missing File");
            end

        end
        function selectTab(app,initialTab)
            switch lower(strtrim(char(initialTab)))
                case {'contents','overview','table of contents'}
                    app.TabGroup.SelectedTab = app.ContentsTab;
                case {'2d gradient descent','gradient descent 2d'}
                    app.TabGroup.SelectedTab = app.Gradient2DTab;
                case {'3d gradient descent','gradient descent 3d'}
                    app.TabGroup.SelectedTab = app.Gradient3DTab;
                case {'regularization with lasso and ridge regression','lasso and ridge','regularization'}
                    app.TabGroup.SelectedTab = app.RegularizationTab;
                case {'ensemble of trees','ensemble'}
                    app.TabGroup.SelectedTab = app.EnsembleTab;
                case {'explore decision paths','decision paths','decision trees'}
                    app.TabGroup.SelectedTab = app.DecisionTab;
                case {'diagnosing when a line is no longer enough','when a line is not enough'}
                    app.TabGroup.SelectedTab = app.DiagnosisTab;
            end
        end

        function handleTabChanged(app,selectedTab)
            arguments
                app
                selectedTab matlab.ui.container.Tab
            end
            initializeTab(app,selectedTab)
        end

        function initializeSelectedTab(app)
            initializeTab(app,app.TabGroup.SelectedTab)
        end

        function initializeTab(app,tabHandle)
            if isequal(tabHandle,app.Gradient2DTab) && ~app.Gradient2DInitialized
                app.Gradient2DInitialized = true;
                randomizeGradient2D(app)
            elseif isequal(tabHandle,app.Gradient3DTab) && ~app.Gradient3DInitialized
                app.Gradient3DInitialized = true;
                randomizeGradient3D(app)
            elseif isequal(tabHandle,app.RegularizationTab) && ~app.RegularizationInitialized
                app.RegularizationInitialized = true;
                randomizeRegularization(app)
            elseif isequal(tabHandle,app.EnsembleTab) && ~app.EnsembleInitialized
                app.EnsembleInitialized = true;
                randomizeEnsemble(app)
            elseif isequal(tabHandle,app.DecisionTab) && ~app.DecisionInitialized
                app.DecisionInitialized = true;
                randomizeDecisionPath(app)
            elseif isequal(tabHandle,app.DiagnosisTab) && ~app.DiagnosisInitialized
                app.DiagnosisInitialized = true;
                randomizeDiagnosis(app)
            end
        end

        function randomizeGradient2D(app)
            app.Gradient2DScenario = TeachingModuleInteractiveSupport.makeGradient2DScenario(TeachingModuleInteractiveSupport.newSeed());
            updateGradient2D(app)
        end

        function updateGradient2D(app)
            result = TeachingModuleInteractiveSupport.runGradient2D( ...
                app.Gradient2DScenario,...
                app.Gradient2DAlphaSlider.Value,...
                round(app.Gradient2DStepSpinner.Value));

            cla(app.Gradient2DAxes)
            plot(app.Gradient2DAxes,app.Gradient2DScenario.XLine,app.Gradient2DScenario.YLine,...
                "LineWidth",1.5,"SeriesIndex",1)
            hold(app.Gradient2DAxes,"on")
            trail2D = scatter(app.Gradient2DAxes,result.XPath(1),result.YPath(1),...
                36,"filled","MarkerFaceAlpha",0.75,"SeriesIndex",2,DisplayName="Data");
            current2D = plot(app.Gradient2DAxes,result.XPath(1),result.YPath(1),"o",...
                "MarkerSize",8,"MarkerFaceColor","auto","SeriesIndex",3);
            plot(app.Gradient2DAxes,result.XPath(1),result.YPath(1),"o",...
                "MarkerSize",7,"MarkerFaceColor","auto","SeriesIndex",4);
            title(app.Gradient2DAxes,...
                sprintf("Iteration %d, $\\alpha = %.2f$",0,app.Gradient2DAlphaSlider.Value),...
                Interpreter="latex")

            cla(app.Gradient2DHistoryAxes)
            hold(app.Gradient2DHistoryAxes,"on")
            historyLine = plot(app.Gradient2DHistoryAxes,result.Iterations(1),result.YPath(1),...
                "-","LineWidth",1.6,"SeriesIndex",1);
            historyCurrent = plot(app.Gradient2DHistoryAxes,result.Iterations(1),result.YPath(1),"o",...
                "MarkerSize",8,"MarkerFaceColor","auto","SeriesIndex",2);
            app.Gradient2DHistoryAxes.YScale = "linear";
            title(app.Gradient2DHistoryAxes,"Cost History",Interpreter="latex")

            for idx = 2:numel(result.YPath)
                trail2D.XData = result.XPath(1:idx);
                trail2D.YData = result.YPath(1:idx);
                current2D.XData = result.XPath(idx);
                current2D.YData = result.YPath(idx);

                historyLine.XData = result.Iterations(1:idx);
                historyLine.YData = result.YPath(1:idx);
                historyCurrent.XData = result.Iterations(idx);
                historyCurrent.YData = result.YPath(idx);

                title(app.Gradient2DAxes,sprintf( ...
                    "Iteration %d, $\\alpha = %.2f$, $x = %.3f$, $f(x)=%.3f$",...
                    result.Iterations(idx),app.Gradient2DAlphaSlider.Value,...
                    result.XPath(idx),result.YPath(idx)),Interpreter="latex")
                drawnow limitrate
                pause(0.05)
            end

            current2D.SeriesIndex = 4;
            historyCurrent.SeriesIndex = 3;
            hold(app.Gradient2DAxes,"off")
            plot(app.Gradient2DHistoryAxes,result.Iterations(1),result.YPath(1),"o",...
                "MarkerSize",7,"MarkerFaceColor","auto","SeriesIndex",4,"HandleVisibility","off")
            hold(app.Gradient2DHistoryAxes,"off")
            box(app.Gradient2DAxes,"on")
            box(app.Gradient2DHistoryAxes,"on")

            app.Gradient2DSeedLabel.Text = "Objective: f(x) = x^2, start x0 = 5";
            app.Gradient2DSummaryLabel.Text = sprintf( ...
                "α = %.2f\nstatus: %s\nfinal x = %.3f\nfinal f(x) = %.4f",...
                app.Gradient2DAlphaSlider.Value,result.Status,result.FinalX,result.FinalValue);
        end

        function randomizeGradient3D(app)
            app.Gradient3DScenario = TeachingModuleInteractiveSupport.makeGradient3DScenario(TeachingModuleInteractiveSupport.newSeed());
            updateGradient3D(app)
        end

        function updateGradient3D(app)
            result = TeachingModuleInteractiveSupport.runGradient3D( ...
                app.Gradient3DScenario,...
                app.Gradient3DAlphaSlider.Value,...
                round(app.Gradient3DStepSpinner.Value));

            cla(app.Gradient3DSurfaceAxes)
            surf(app.Gradient3DSurfaceAxes,...
                app.Gradient3DScenario.Theta1Grid,...
                app.Gradient3DScenario.Theta0Grid,...
                app.Gradient3DScenario.CostSurface,...
                "EdgeColor","none","FaceAlpha",0.92)
            view(app.Gradient3DSurfaceAxes,-70,25)
            colormap(app.Gradient3DSurfaceAxes,parula(30))
            hold(app.Gradient3DSurfaceAxes,"on")

            cla(app.Gradient3DContourAxes)
            contour(app.Gradient3DContourAxes,...
                app.Gradient3DScenario.Theta1Grid,...
                app.Gradient3DScenario.Theta0Grid,...
                app.Gradient3DScenario.CostSurface,25,"LineWidth",1.0)
            hold(app.Gradient3DContourAxes,"on")

            cla(app.Gradient3DFitAxes)
            scatter(app.Gradient3DFitAxes,app.Gradient3DScenario.x,app.Gradient3DScenario.y,22,...
                "filled","MarkerFaceAlpha",0.7,"SeriesIndex",1,DisplayName="Data")
            hold(app.Gradient3DFitAxes,"on")
            plot(app.Gradient3DFitAxes,app.Gradient3DScenario.xGrid,result.StartFit,"--",...
                "LineWidth",1.2,"SeriesIndex",2)
            fitLine = plot(app.Gradient3DFitAxes,app.Gradient3DScenario.xGrid,result.StartFit,...
                "LineWidth",1.9,"SeriesIndex",3);
            plot(app.Gradient3DFitAxes,app.Gradient3DScenario.xGrid,result.DirectFit,...
                "LineWidth",1.2,"SeriesIndex",4)
            hold(app.Gradient3DFitAxes,"on")
            title(app.Gradient3DFitAxes,sprintf( ...
                "$\\theta_1 = %.3f$, $\\theta_0 = %.3f$, $\\mathrm{MSE}=%.4f$",...
                result.Theta1Path(1),result.Theta0Path(1),result.CostHistory(1)),Interpreter="latex")

            cla(app.Gradient3DProgressAxes)
            progressLine = plot(app.Gradient3DProgressAxes,result.Iterations(1),result.CostHistory(1),...
                "-","LineWidth",1.8,"SeriesIndex",1);
            hold(app.Gradient3DProgressAxes,"on")
            yline(app.Gradient3DProgressAxes,result.DirectMSE,"--","SeriesIndex",2)
            plot(app.Gradient3DProgressAxes,result.Iterations(1),result.CostHistory(1),"o",...
                "MarkerSize",7,"MarkerFaceColor","auto","SeriesIndex",3);
            progressCurrent = plot(app.Gradient3DProgressAxes,result.Iterations(1),result.CostHistory(1),"o",...
                "MarkerSize",7,"MarkerFaceColor","auto","SeriesIndex",4);
            app.Gradient3DProgressAxes.YScale = "log";

            path3 = plot3(app.Gradient3DSurfaceAxes,...
                result.Theta1Path(1),result.Theta0Path(1),result.CostHistory(1),...
                "-","LineWidth",1.6,"SeriesIndex",1);
            current3 = plot3(app.Gradient3DSurfaceAxes,...
                result.Theta1Path(1),result.Theta0Path(1),result.CostHistory(1),"o",...
                "MarkerSize",8,"MarkerFaceColor","auto","SeriesIndex",2);
            plot3(app.Gradient3DSurfaceAxes,...
                result.Theta1Path(1),result.Theta0Path(1),result.CostHistory(1),"o",...
                "MarkerSize",7,"MarkerFaceColor","auto","SeriesIndex",3);

            path2 = plot(app.Gradient3DContourAxes,...
                result.Theta1Path(1),result.Theta0Path(1),...
                "-","LineWidth",1.6,"SeriesIndex",1);
            current2 = plot(app.Gradient3DContourAxes,...
                result.Theta1Path(1),result.Theta0Path(1),"o",...
                "MarkerSize",8,"MarkerFaceColor","auto","SeriesIndex",2);
            plot(app.Gradient3DContourAxes,...
                result.Theta1Path(1),result.Theta0Path(1),"o",...
                "MarkerSize",7,"MarkerFaceColor","auto","SeriesIndex",3);

            for idx = 2:numel(result.CostHistory)
                path3.XData = result.Theta1Path(1:idx);
                path3.YData = result.Theta0Path(1:idx);
                path3.ZData = result.CostHistory(1:idx);
                current3.XData = result.Theta1Path(idx);
                current3.YData = result.Theta0Path(idx);
                current3.ZData = result.CostHistory(idx);

                path2.XData = result.Theta1Path(1:idx);
                path2.YData = result.Theta0Path(1:idx);
                current2.XData = result.Theta1Path(idx);
                current2.YData = result.Theta0Path(idx);

                fitLine.YData = result.Theta1Path(idx) * app.Gradient3DScenario.xGrid + result.Theta0Path(idx);
                progressLine.XData = result.Iterations(1:idx);
                progressLine.YData = result.CostHistory(1:idx);
                progressCurrent.XData = result.Iterations(idx);
                progressCurrent.YData = result.CostHistory(idx);
                title(app.Gradient3DFitAxes,sprintf( ...
                    "$\\theta_1 = %.3f$, $\\theta_0 = %.3f$, $\\mathrm{MSE}=%.4f$",...
                    result.Theta1Path(idx),result.Theta0Path(idx),result.CostHistory(idx)),Interpreter="latex")

                drawnow limitrate
                pause(0.05)
            end

            current3.SeriesIndex = 4;
            current2.SeriesIndex = 4;
            progressCurrent.SeriesIndex = 5;
            hold(app.Gradient3DSurfaceAxes,"off")
            hold(app.Gradient3DContourAxes,"off")
            hold(app.Gradient3DFitAxes,"off")
            hold(app.Gradient3DProgressAxes,"off")
            box(app.Gradient3DSurfaceAxes,"on")
            box(app.Gradient3DContourAxes,"on")
            box(app.Gradient3DFitAxes,"on")
            box(app.Gradient3DProgressAxes,"on")

            app.Gradient3DSeedLabel.Text = "Scenario: " + app.Gradient3DScenario.Label;
            app.Gradient3DSummaryLabel.Text = sprintf( ...
                "α = %.2f\nstatus: %s\nstart θ = [%.2f, %.2f]\nfinal θ = [%.2f, %.2f]\nfinal MSE = %.4f",...
                app.Gradient3DAlphaSlider.Value,result.Status,...
                app.Gradient3DScenario.StartTheta(1),app.Gradient3DScenario.StartTheta(2),...
                result.Theta1Path(end),result.Theta0Path(end),result.CostHistory(end));
        end

        function randomizeRegularization(app)
            app.RegularizationAnalysis = TeachingModuleInteractiveSupport.analyzeRegularization(TeachingModuleInteractiveSupport.newSeed());
            app.RegularizationLambdaSlider.Limits = [1 numel(app.RegularizationAnalysis.Lambdas)];
            app.RegularizationLambdaSlider.Value = app.RegularizationAnalysis.LassoBestIndex;
            app.RegularizationLambdaSlider.MajorTicks = unique(round(linspace(1,numel(app.RegularizationAnalysis.Lambdas),6)));
            updateRegularization(app)
        end

        function jumpToBestLasso(app)
            app.RegularizationLambdaSlider.Value = app.RegularizationAnalysis.LassoBestIndex;
            updateRegularization(app)
        end

        function jumpToBestRidge(app)
            app.RegularizationLambdaSlider.Value = app.RegularizationAnalysis.RidgeBestIndex;
            updateRegularization(app)
        end

        function updateRegularization(app)
            lambdaIndex = round(app.RegularizationLambdaSlider.Value);
            summary = TeachingModuleInteractiveSupport.summarizeRegularizationAtIndex(app.RegularizationAnalysis,lambdaIndex);

            cla(app.RegularizationPathAxes)
            semilogx(app.RegularizationPathAxes,app.RegularizationAnalysis.Lambdas,app.RegularizationAnalysis.LassoPath', ...
                "LineWidth",0.9)
            hold(app.RegularizationPathAxes,"on")
            semilogx(app.RegularizationPathAxes,app.RegularizationAnalysis.Lambdas,app.RegularizationAnalysis.RidgePath', ...
                "--","LineWidth",0.9)
            xline(app.RegularizationPathAxes,summary.Lambda,":","LineWidth",1.4,"SeriesIndex",1)
            hold(app.RegularizationPathAxes,"off")
            legend(app.RegularizationPathAxes,["Lasso paths","Ridge paths"],"Location","best")
            grid(app.RegularizationPathAxes,"on")
            box(app.RegularizationPathAxes,"on")

            cla(app.RegularizationCoefficientAxes)
            featureLabels = string(app.RegularizationAnalysis.FeatureNames);
            yPos = 1:numel(featureLabels);
            barh(app.RegularizationCoefficientAxes,yPos - 0.16,summary.LassoBeta,0.28,"SeriesIndex",1)
            hold(app.RegularizationCoefficientAxes,"on")
            barh(app.RegularizationCoefficientAxes,yPos + 0.16,summary.RidgeBeta,0.28,"SeriesIndex",2)
            hold(app.RegularizationCoefficientAxes,"off")
            app.RegularizationCoefficientAxes.YTick = yPos;
            app.RegularizationCoefficientAxes.YTickLabel = featureLabels;
            grid(app.RegularizationCoefficientAxes,"on")
            box(app.RegularizationCoefficientAxes,"on")

            cla(app.RegularizationSliceAxes)
            hold(app.RegularizationSliceAxes,"on")
            for idx = 1:numel(app.RegularizationAnalysis.PredictionSlices)
                slice = app.RegularizationAnalysis.PredictionSlices(idx);
                mask = app.RegularizationAnalysis.T.z >= slice.ZRange(1) & app.RegularizationAnalysis.T.z <= slice.ZRange(2);
                scatter(app.RegularizationSliceAxes,app.RegularizationAnalysis.T.x(mask),app.RegularizationAnalysis.T.y(mask),...
                    18,"filled","MarkerFaceAlpha",0.45,"SeriesIndex",1,"HandleVisibility","off",DisplayName="Data")
                plot(app.RegularizationSliceAxes,slice.XGrid,summary.LassoPredSlices{idx},...
                    "LineWidth",1.7,"SeriesIndex",2,...
                    "DisplayName","Lasso")
                plot(app.RegularizationSliceAxes,slice.XGrid,summary.RidgePredSlices{idx},"--",...
                    "LineWidth",1.7,"SeriesIndex",3,...
                    "DisplayName","Ridge")
            end
            hold(app.RegularizationSliceAxes,"off")
            grid(app.RegularizationSliceAxes,"on")
            box(app.RegularizationSliceAxes,"on")

            app.RegularizationSeedLabel.Text = "Seed: " + app.RegularizationAnalysis.Seed;
            app.RegularizationSummaryLabel.Text = sprintf( ...
                "Change lambda to see how Ridge keeps all features while Lasso can remove them.\nlambda = %.5f\nlasso val MSE = %.3f\nridge val MSE = %.3f\nselected lasso features = %d\nbest lasso index = %d\nbest ridge index = %d",...
                summary.Lambda,summary.LassoValidationMSE,summary.RidgeValidationMSE,...
                sum(summary.LassoSelectedMask),app.RegularizationAnalysis.LassoBestIndex,app.RegularizationAnalysis.RidgeBestIndex);
        end

        function randomizeEnsemble(app)
            app.EnsembleData = TeachingModuleInteractiveSupport.makeEnsembleScenario(TeachingModuleInteractiveSupport.newSeed());
            updateEnsemble(app)
        end

        function updateEnsemble(app)
            story = TeachingModuleInteractiveSupport.fitEnsembleModels( ...
                app.EnsembleData,...
                round(app.EnsembleTreesSlider.Value),...
                round(app.EnsembleSplitsSlider.Value));

            cla(app.EnsembleFitAxes)
            scatter(app.EnsembleFitAxes,app.EnsembleData.x,app.EnsembleData.y,14,...
                "filled","MarkerFaceAlpha",0.45,"SeriesIndex",1,DisplayName="Data")
            hold(app.EnsembleFitAxes,"on")
            plot(app.EnsembleFitAxes,app.EnsembleData.xGrid,story.TreeFit,...
                "--","LineWidth",1.5,"SeriesIndex",2,"DisplayName","Single tree")
            plot(app.EnsembleFitAxes,app.EnsembleData.xGrid,story.BagFit,...
                "LineWidth",1.8,"SeriesIndex",3,"DisplayName","Bagging")
            plot(app.EnsembleFitAxes,app.EnsembleData.xGrid,story.BoostFit,...
                "LineWidth",1.8,"SeriesIndex",4,"DisplayName","Boosting")
            hold(app.EnsembleFitAxes,"off")
            legend(app.EnsembleFitAxes,"Location","best")
            grid(app.EnsembleFitAxes,"on")
            box(app.EnsembleFitAxes,"on")

            cla(app.EnsembleTrendAxes)
            xTrees = 1:numel(story.BagTrainingPath);
            plot(app.EnsembleTrendAxes,xTrees,repmat(story.TreeTrainingMSE,size(xTrees)),"--",...
                "LineWidth",1.3,"SeriesIndex",1)
            hold(app.EnsembleTrendAxes,"on")
            plot(app.EnsembleTrendAxes,xTrees,story.BagTrainingPath,...
                "LineWidth",1.8,"SeriesIndex",2)
            plot(app.EnsembleTrendAxes,xTrees,story.BoostTrainingPath,...
                "LineWidth",1.8,"SeriesIndex",3)
            hold(app.EnsembleTrendAxes,"off")
            grid(app.EnsembleTrendAxes,"on")
            box(app.EnsembleTrendAxes,"on")

            app.EnsembleSeedLabel.Text = "Seed: " + app.EnsembleData.Seed;
            app.EnsembleSummaryLabel.Text = sprintf( ...
                "Increase trees to see when the fit stabilizes and compare bagging with boosting.\ntrees = %d\nmax splits = %d\nsingle-tree MSE = %.1f\nbagging gain = %.1f%%\nboosting gain = %.1f%%",...
                round(app.EnsembleTreesSlider.Value),round(app.EnsembleSplitsSlider.Value),...
                story.TreeTrainingMSE,story.BagGain,story.BoostGain);
        end

        function randomizeDecisionPath(app)
            app.DecisionSpec = TeachingModuleInteractiveSupport.makeDecisionPathSpec(TeachingModuleInteractiveSupport.newSeed());
            updateDecisionPath(app)
        end

        function updateDecisionPath(app)
            state = TeachingModuleInteractiveSupport.evaluateDecisionPath( ...
                app.DecisionSpec,...
                app.DecisionHourSlider.Value,...
                app.DecisionTemperatureSlider.Value);

            ax = app.DecisionAxes;
            cla(ax)
            hold(ax,"on")
            axis(ax,[0 1 0 1])
            axis(ax,"off")

            positions = [ ...
                0.50 0.86
                0.28 0.58
                0.72 0.58
                0.16 0.24
                0.40 0.24
                0.60 0.24
                0.84 0.24];
            edges = [1 2; 1 3; 2 4; 2 5; 3 6; 3 7];
            for idx = 1:size(edges,1)
                p1 = positions(edges(idx,1),:);
                p2 = positions(edges(idx,2),:);
                highlight = any(all(edges(idx,:) == [state.PathNodes(1) state.PathNodes(2)],2)) || ...
                    any(all(edges(idx,:) == [state.PathNodes(2) state.PathNodes(3)],2));
                if highlight
                    seriesIndex = 2;
                    width = 2.4;
                else
                    seriesIndex = 1;
                    width = 1.2;
                end
                plot(ax,[p1(1) p2(1)],[p1(2) p2(2)],"-","LineWidth",width,"SeriesIndex",seriesIndex)
            end

            labels = [ ...
                "$\mathrm{Hour} < " + app.DecisionSpec.HourSplit + "$"
                "$\mathrm{Temp} < " + app.DecisionSpec.CoolSplit + "$"
                "$\mathrm{Temp} < " + app.DecisionSpec.WarmSplit + "$"
                "$" + string(app.DecisionSpec.Leaves(1)) + "\ \mathrm{MW}$"
                "$" + string(app.DecisionSpec.Leaves(2)) + "\ \mathrm{MW}$"
                "$" + string(app.DecisionSpec.Leaves(3)) + "\ \mathrm{MW}$"
                "$" + string(app.DecisionSpec.Leaves(4)) + "\ \mathrm{MW}$"];
            for idx = 1:7
                if any(state.PathNodes == idx)
                    seriesIndex = 2;
                else
                    seriesIndex = 1;
                end
                scatter(ax,positions(idx,1),positions(idx,2),5200,"s",...
                    "filled","MarkerFaceAlpha",0.25,"SeriesIndex",seriesIndex)
                text(ax,positions(idx,1),positions(idx,2),labels(idx),...
                    "HorizontalAlignment","center","VerticalAlignment","middle","FontWeight","bold","FontSize",11,"Interpreter","latex")
            end
            hold(ax,"off")
            box(ax,"on")

            traceText = sprintf("%s\n%s\nPrediction = %.0f MW",...
                state.TraceLines(1),state.TraceLines(2),state.Prediction);
            app.DecisionSeedLabel.Text = "$\mathrm{Seed}:$ " + app.DecisionSpec.Seed;
            app.DecisionSummaryLabel.Text = "Change the inputs to route the example through a different branch." + newline + traceText;
        end

        function randomizeDiagnosis(app)
            app.DiagnosisSeed = TeachingModuleInteractiveSupport.newSeed();
            updateDiagnosis(app)
        end

        function updateDiagnosis(app)
            story = TeachingModuleInteractiveSupport.analyzeLineDiagnostics( ...
                app.DiagnosisSeed,...
                string(app.DiagnosisPatternDropDown.Value),...
                app.DiagnosisNoiseSlider.Value);

            cla(app.DiagnosisFitAxes)
            scatter(app.DiagnosisFitAxes,story.x,story.y,18,...
                "filled","MarkerFaceAlpha",0.5,"SeriesIndex",1,DisplayName="Data")
            hold(app.DiagnosisFitAxes,"on")
            plot(app.DiagnosisFitAxes,story.xGrid,story.LinearFit,"--",...
                "LineWidth",1.4,"SeriesIndex",2,"DisplayName","Linear")
            plot(app.DiagnosisFitAxes,story.xGrid,story.QuadraticFit,...
                "LineWidth",1.7,"SeriesIndex",3,"DisplayName","Quadratic")
            plot(app.DiagnosisFitAxes,story.xGrid,story.TreeFit,...
                "LineWidth",1.6,"SeriesIndex",4,"DisplayName","Tree")
            plot(app.DiagnosisFitAxes,story.xGrid,story.EnsembleFit,...
                "LineWidth",1.8,"SeriesIndex",5,"DisplayName","Ensemble")
            hold(app.DiagnosisFitAxes,"off")
            legend(app.DiagnosisFitAxes,"Location","best")
            grid(app.DiagnosisFitAxes,"on")
            box(app.DiagnosisFitAxes,"on")

            cla(app.DiagnosisResidualAxes)
            scatter(app.DiagnosisResidualAxes,story.x,story.LinearResiduals,18,...
                "filled","MarkerFaceAlpha",0.55,"SeriesIndex",1,DisplayName="Data")
            hold(app.DiagnosisResidualAxes,"on")
            yline(app.DiagnosisResidualAxes,0,"--","SeriesIndex",2)
            hold(app.DiagnosisResidualAxes,"off")
            grid(app.DiagnosisResidualAxes,"on")
            box(app.DiagnosisResidualAxes,"on")

            cla(app.DiagnosisSummaryAxes)
            hold(app.DiagnosisSummaryAxes,"on")
            for idx = 1:numel(story.Summary.ValidationRMSE)
                bar(app.DiagnosisSummaryAxes,idx,story.Summary.ValidationRMSE(idx),...
                    "SeriesIndex",idx)
            end
            hold(app.DiagnosisSummaryAxes,"off")
            app.DiagnosisSummaryAxes.XTickLabel = story.Summary.Model;
            grid(app.DiagnosisSummaryAxes,"on")
            box(app.DiagnosisSummaryAxes,"on")

            app.DiagnosisSeedLabel.Text = "Seed: " + app.DiagnosisSeed;
            app.DiagnosisSummaryLabel.Text = sprintf( ...
                "Use the residual plot to decide whether the line is missing structure.\npattern = %s\nnoise = %.2f\nbest model = %s\nlinear RMSE = %.3f\nensemble RMSE = %.3f",...
                story.PatternName,app.DiagnosisNoiseSlider.Value,story.BestModel,...
                story.Summary.ValidationRMSE(1),story.Summary.ValidationRMSE(4));
        end
    end
end
