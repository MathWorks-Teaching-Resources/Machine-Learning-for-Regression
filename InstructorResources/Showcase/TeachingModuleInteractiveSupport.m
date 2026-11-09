classdef TeachingModuleInteractiveSupport
    methods (Static)
        function seed = newSeed()
            seed = randi([10^4 10^6 - 1], 1, 1);
        end

        function scenario = makeGradient2DScenario(seed)
            scenario = struct( ...
                "Seed", seed, ...
                "StartX", 5, ...
                "XLine", linspace(-6, 6, 240)', ...
                "YLine", linspace(-6, 6, 240)'.^2);
        end

        function result = runGradient2D(scenario, alpha, maxSteps)
            arguments
                scenario (1,1) struct
                alpha (1,1) double {mustBePositive}
                maxSteps (1,1) double {mustBeInteger, mustBePositive}
            end

            xCurrent = scenario.StartX;
            xPath = zeros(maxSteps + 1, 1);
            yPath = zeros(maxSteps + 1, 1);
            xPath(1) = xCurrent;
            yPath(1) = TeachingModuleInteractiveSupport.gradient2DObjective(scenario, xCurrent);

            status = "Running";
            lastStep = maxSteps;
            tolerance = 1e-3;
            for idx = 1:maxSteps
                grad = TeachingModuleInteractiveSupport.gradient2DGradient(scenario, xCurrent);
                if abs(grad) < tolerance
                    status = "Converged";
                    lastStep = idx;
                    break
                end

                xCurrent = xCurrent - alpha * grad;
                xPath(idx + 1) = xCurrent;
                yPath(idx + 1) = TeachingModuleInteractiveSupport.gradient2DObjective(scenario, xCurrent);

                if abs(alpha - 1) < eps(1) && idx >= min(maxSteps, 20)
                    status = "Oscillating";
                    lastStep = idx;
                    break
                end

                if abs(xCurrent) > 40 || yPath(idx + 1) > 1e4
                    status = "Diverged";
                    lastStep = idx;
                    break
                end
            end

            xPath = xPath(1:lastStep + 1);
            yPath = yPath(1:lastStep + 1);
            iterations = (0:lastStep)';

            result = struct( ...
                "XPath", xPath, ...
                "YPath", yPath, ...
                "Iterations", iterations, ...
                "Status", status, ...
                "FinalX", xPath(end), ...
                "FinalValue", yPath(end));
        end

        function value = gradient2DObjective(~, xValue)
            value = xValue.^2;
        end

        function grad = gradient2DGradient(~, xValue)
            grad = 2 * xValue;
        end

        function scenario = makeGradient3DScenario(seed)
            choices = ["Moderate noise", "Steeper slope", "Noisier response", "Offset intercept"];
            choiceIndex = mod(seed - 1, numel(choices)) + 1;
            data = TeachingModuleInteractiveSupport.makeOptimizationScenario(choices(choiceIndex));
            [theta1Grid, theta0Grid] = meshgrid(-10:0.1:10, -10:0.1:10);
            costSurface = arrayfun( ...
                @(m, b) TeachingModuleInteractiveSupport.linearMSE(m, b, data.x, data.y), ...
                theta1Grid, theta0Grid);
            directFit = polyfit(data.x, data.y, 1);

            scenario = struct( ...
                "Seed", seed, ...
                "Choice", choices(choiceIndex), ...
                "Label", data.Label, ...
                "TeachingNote", data.TeachingNote, ...
                "x", data.x, ...
                "y", data.y, ...
                "xGrid", data.xGrid, ...
                "StartTheta", [7; 7], ...
                "DirectTheta", directFit(:), ...
                "Theta1Grid", theta1Grid, ...
                "Theta0Grid", theta0Grid, ...
                "CostSurface", costSurface);
        end

        function result = runGradient3D(scenario, alpha, maxSteps)
            arguments
                scenario (1,1) struct
                alpha (1,1) double {mustBePositive}
                maxSteps (1,1) double {mustBeInteger, mustBePositive}
            end

            theta1 = scenario.StartTheta(1);
            theta0 = scenario.StartTheta(2);
            n = numel(scenario.y);

            theta1Path = zeros(maxSteps + 1, 1);
            theta0Path = zeros(maxSteps + 1, 1);
            costHistory = zeros(maxSteps + 1, 1);
            theta1Path(1) = theta1;
            theta0Path(1) = theta0;
            costHistory(1) = TeachingModuleInteractiveSupport.linearMSE(theta1, theta0, scenario.x, scenario.y);

            status = "Stable";
            lastStep = maxSteps;
            tolerance = 1e-5;
            for idx = 1:maxSteps
                residual = theta1 * scenario.x + theta0 - scenario.y;
                grad1 = (2 / n) * sum(residual .* scenario.x);
                grad0 = (2 / n) * sum(residual);

                theta1 = theta1 - alpha * grad1;
                theta0 = theta0 - alpha * grad0;

                theta1Path(idx + 1) = theta1;
                theta0Path(idx + 1) = theta0;
                costHistory(idx + 1) = TeachingModuleInteractiveSupport.linearMSE(theta1, theta0, scenario.x, scenario.y);

                if norm([grad1 grad0]) < tolerance
                    status = "Converged";
                    lastStep = idx;
                    break
                end

                if ~isfinite(costHistory(idx + 1)) || costHistory(idx + 1) > 1e5
                    status = "Diverged";
                    lastStep = idx;
                    break
                end
            end

            theta1Path = theta1Path(1:lastStep + 1);
            theta0Path = theta0Path(1:lastStep + 1);
            costHistory = costHistory(1:lastStep + 1);

            result = struct( ...
                "Theta1Path", theta1Path, ...
                "Theta0Path", theta0Path, ...
                "CostHistory", costHistory, ...
                "Iterations", (0:lastStep)', ...
                "Status", status, ...
                "FinalFit", theta1Path(end) * scenario.xGrid + theta0Path(end), ...
                "StartFit", scenario.StartTheta(1) * scenario.xGrid + scenario.StartTheta(2), ...
                "DirectFit", polyval(scenario.DirectTheta', scenario.xGrid), ...
                "DirectMSE", TeachingModuleInteractiveSupport.linearMSE( ...
                    scenario.DirectTheta(1), scenario.DirectTheta(2), scenario.x, scenario.y));
        end

        function mse = linearMSE(theta1, theta0, x, y)
            yHat = theta1 * x + theta0;
            mse = mean((y - yHat).^2);
        end

        function data = makeOptimizationScenario(choice)
            arguments
                choice (1,1) string {mustBeMember(choice, ["Moderate noise", "Steeper slope", "Noisier response", "Offset intercept"])}
            end

            rng(79, "twister")
            x = linspace(-1, 1, 25)';
            switch choice
                case "Moderate noise"
                    y = 1.5 + 2.2 * x + 0.20 * randn(size(x));
                    label = "Moderate noise";
                    note = "A balanced default for showing slow versus fast convergence without distracting noise.";
                case "Steeper slope"
                    y = -0.4 + 4.0 * x + 0.20 * randn(size(x));
                    label = "Steeper slope";
                    note = "Useful when a stronger slope makes the fit-update panel easier to read.";
                case "Noisier response"
                    y = 1.5 + 2.2 * x + 0.45 * randn(size(x));
                    label = "Noisier response";
                    note = "This scenario helps separate optimization behavior from data noise.";
                otherwise
                    y = 3.0 - 1.5 * x + 0.20 * randn(size(x));
                    label = "Offset intercept";
                    note = "This scenario changes the intercept and slope sign without changing the optimization story.";
            end

            data = struct( ...
                "x", x, ...
                "y", y, ...
                "xGrid", linspace(min(x), max(x), 240)', ...
                "Label", label, ...
                "TeachingNote", note);
        end

        function analysis = analyzeRegularization(seed)
            rng(seed, "twister")

            n = 150;
            x = linspace(0, 10, n)';
            z = 0.35 * x + 0.75 * randn(n, 1);
            sinAmp = 1.1 + 0.5 * rand();
            trend = 0.45 + 0.25 * rand();
            interactionAmp = 0.18 + 0.08 * rand();
            y = 1.4 + trend * x + sinAmp * sin(x + 0.5 * rand()) + interactionAmp * (x .* z) + 0.55 * randn(n, 1);

            T = table(x, z, y);
            T = TeachingModuleInteractiveSupport.addEngineeredFeatures(T);
            slices = TeachingModuleInteractiveSupport.makePredictionSlices(table(x, z, y));

            rng(seed + 17, "twister")
            cv = cvpartition(height(T), "HoldOut", 0.3);
            Ttr = T(training(cv), :);
            Tva = T(test(cv), :);

            featureNames = ["x", "z", "x2", "x3", "sinx", "cosx", "x_z", "logx", "sqrtx"];
            Xtr = Ttr{:, cellstr(featureNames)};
            Xva = Tva{:, cellstr(featureNames)};
            yTr = Ttr.y;
            yVa = Tva.y;

            [XtrS, muX, sigmaX] = zscore(Xtr);
            sigmaX(sigmaX == 0) = 1;
            XvaS = (Xva - muX) ./ sigmaX;

            lambdas = logspace(-4, 2.5, 50);
            rng(seed + 29, "twister")
            [lassoPath, fitInfo] = lasso(XtrS, yTr, "Lambda", lambdas, "CV", 5, "Standardize", false);
            lassoBestIdx = fitInfo.IndexMinMSE;

            ridgePath = zeros(numel(featureNames), numel(lambdas));
            ridgeValidationMSE = zeros(numel(lambdas), 1);
            ridgeTrainMSE = zeros(numel(lambdas), 1);
            ridgeModels = cell(numel(lambdas), 1);
            for idx = 1:numel(lambdas)
                ridgeModels{idx} = fitrlinear( ...
                    XtrS, yTr, ...
                    "Learner", "leastsquares", ...
                    "Regularization", "ridge", ...
                    "Lambda", lambdas(idx), ...
                    "Solver", "lbfgs");
                ridgePath(:, idx) = ridgeModels{idx}.Beta;
                ridgeTrainPred = predict(ridgeModels{idx}, XtrS);
                ridgeValPred = predict(ridgeModels{idx}, XvaS);
                ridgeTrainMSE(idx) = mean((yTr - ridgeTrainPred).^2);
                ridgeValidationMSE(idx) = mean((yVa - ridgeValPred).^2);
            end

            [~, ridgeBestIdx] = min(ridgeValidationMSE);
            lassoValidationMSE = zeros(numel(lambdas), 1);
            lassoTrainMSE = zeros(numel(lambdas), 1);
            for idx = 1:numel(lambdas)
                beta = lassoPath(:, idx);
                intercept = fitInfo.Intercept(idx);
                lassoTrainPred = XtrS * beta + intercept;
                lassoValPred = XvaS * beta + intercept;
                lassoTrainMSE(idx) = mean((yTr - lassoTrainPred).^2);
                lassoValidationMSE(idx) = mean((yVa - lassoValPred).^2);
            end

            analysis = struct( ...
                "Seed", seed, ...
                "T", T, ...
                "Ttr", Ttr, ...
                "Tva", Tva, ...
                "PredictionSlices", slices, ...
                "FeatureNames", featureNames, ...
                "Lambdas", lambdas, ...
                "MuX", muX, ...
                "SigmaX", sigmaX, ...
                "XtrS", XtrS, ...
                "XvaS", XvaS, ...
                "Ytr", yTr, ...
                "Yva", yVa, ...
                "LassoPath", lassoPath, ...
                "LassoFitInfo", fitInfo, ...
                "LassoBestIndex", lassoBestIdx, ...
                "LassoTrainMSE", lassoTrainMSE, ...
                "LassoValidationMSE", lassoValidationMSE, ...
                "RidgePath", ridgePath, ...
                "RidgeModels", {ridgeModels}, ...
                "RidgeBestIndex", ridgeBestIdx, ...
                "RidgeTrainMSE", ridgeTrainMSE, ...
                "RidgeValidationMSE", ridgeValidationMSE);
        end

        function summary = summarizeRegularizationAtIndex(analysis, lambdaIndex)
            lambdaIndex = max(1, min(lambdaIndex, numel(analysis.Lambdas)));

            lassoBeta = analysis.LassoPath(:, lambdaIndex);
            ridgeBeta = analysis.RidgePath(:, lambdaIndex);
            lassoIntercept = analysis.LassoFitInfo.Intercept(lambdaIndex);
            ridgeModel = analysis.RidgeModels{lambdaIndex};

            lassoPredSlices = cell(numel(analysis.PredictionSlices), 1);
            ridgePredSlices = cell(numel(analysis.PredictionSlices), 1);
            for idx = 1:numel(analysis.PredictionSlices)
                XSlice = analysis.PredictionSlices(idx).Table{:, cellstr(analysis.FeatureNames)};
                XSliceS = (XSlice - analysis.MuX) ./ analysis.SigmaX;
                lassoPredSlices{idx} = XSliceS * lassoBeta + lassoIntercept;
                ridgePredSlices{idx} = predict(ridgeModel, XSliceS);
            end

            summary = struct( ...
                "LambdaIndex", lambdaIndex, ...
                "Lambda", analysis.Lambdas(lambdaIndex), ...
                "LassoBeta", lassoBeta, ...
                "RidgeBeta", ridgeBeta, ...
                "LassoSelectedMask", lassoBeta ~= 0, ...
                "LassoTrainMSE", analysis.LassoTrainMSE(lambdaIndex), ...
                "LassoValidationMSE", analysis.LassoValidationMSE(lambdaIndex), ...
                "RidgeTrainMSE", analysis.RidgeTrainMSE(lambdaIndex), ...
                "RidgeValidationMSE", analysis.RidgeValidationMSE(lambdaIndex), ...
                "LassoPredSlices", {lassoPredSlices}, ...
                "RidgePredSlices", {ridgePredSlices});
        end

        function data = makeEnsembleScenario(seed)
            rng(seed, "twister")

            x = linspace(0, 24, 160)';
            morningBump = (550 + 180 * rand()) * exp(-0.5 * ((x - (7 + rand())) / 1.8).^2);
            eveningBump = (780 + 180 * rand()) * exp(-0.5 * ((x - (18 + rand())) / 2.3).^2);
            baseLoad = 3700 + 250 * rand();
            thresholdJump = (420 + 120 * rand()) * (x > (11 + rand()));
            yTrue = baseLoad + morningBump + eveningBump + thresholdJump + 140 * sin(2 * pi * (x - 2) / 24);
            y = yTrue + (90 + 40 * rand()) * randn(size(x));
            xGrid = linspace(0, 24, 260)';

            data = struct( ...
                "Seed", seed, ...
                "x", x, ...
                "y", y, ...
                "xGrid", xGrid, ...
                "TrueCurve", yTrue);
        end

        function story = fitEnsembleModels(data, numTrees, maxSplits)
            arguments
                data (1,1) struct
                numTrees (1,1) double {mustBeInteger, mustBePositive}
                maxSplits (1,1) double {mustBeInteger, mustBePositive}
            end

            learner = templateTree("MaxNumSplits", maxSplits, "MinLeafSize", 6);
            linearModel = fitlm(data.x, data.y);
            treeModel = fitrtree(data.x, data.y, "MaxNumSplits", maxSplits, "MinLeafSize", 6);
            bagModel = fitrensemble(data.x, data.y, "Method", "Bag", "NumLearningCycles", numTrees, "Learners", learner);
            boostModel = fitrensemble(data.x, data.y, "Method", "LSBoost", "NumLearningCycles", numTrees, "Learners", learner);

            bagPath = zeros(numTrees, 1);
            boostPath = zeros(numTrees, 1);
            for idx = 1:numTrees
                bagStage = fitrensemble(data.x, data.y, "Method", "Bag", "NumLearningCycles", idx, "Learners", learner);
                boostStage = fitrensemble(data.x, data.y, "Method", "LSBoost", "NumLearningCycles", idx, "Learners", learner);
                bagPath(idx) = mean((data.y - predict(bagStage, data.x)).^2);
                boostPath(idx) = mean((data.y - predict(boostStage, data.x)).^2);
            end

            treeMSE = mean((data.y - predict(treeModel, data.x)).^2);
            story = struct( ...
                "LinearFit", predict(linearModel, data.xGrid), ...
                "TreeFit", predict(treeModel, data.xGrid), ...
                "BagFit", predict(bagModel, data.xGrid), ...
                "BoostFit", predict(boostModel, data.xGrid), ...
                "TreeTrainingMSE", treeMSE, ...
                "BagTrainingPath", bagPath, ...
                "BoostTrainingPath", boostPath, ...
                "BagGain", 100 * (treeMSE - bagPath(end)) / treeMSE, ...
                "BoostGain", 100 * (treeMSE - boostPath(end)) / treeMSE);
        end

        function spec = makeDecisionPathSpec(seed)
            rng(seed,"twister")

            spec = struct( ...
                "Seed", seed, ...
                "HourSplit", randi([9 13],1,1), ...
                "CoolSplit", randi([58 68],1,1), ...
                "WarmSplit", randi([74 86],1,1), ...
                "Leaves", [ ...
                    3800 + randi([0 350],1,1), ...
                    4800 + randi([0 350],1,1), ...
                    5400 + randi([0 400],1,1), ...
                    6200 + randi([0 400],1,1)]);
        end

        function state = evaluateDecisionPath(spec, hourValue, temperatureValue)
            if hourValue < spec.HourSplit
                if temperatureValue < spec.CoolSplit
                    leafIndex = 1;
                    pathNodes = [1 2 4];
                    decisions = [
                        "Hour < " + spec.HourSplit + " is true"
                        "Temperature < " + spec.CoolSplit + " is true"];
                else
                    leafIndex = 2;
                    pathNodes = [1 2 5];
                    decisions = [
                        "Hour < " + spec.HourSplit + " is true"
                        "Temperature < " + spec.CoolSplit + " is false"];
                end
            else
                if temperatureValue < spec.WarmSplit
                    leafIndex = 3;
                    pathNodes = [1 3 6];
                    decisions = [
                        "Hour < " + spec.HourSplit + " is false"
                        "Temperature < " + spec.WarmSplit + " is true"];
                else
                    leafIndex = 4;
                    pathNodes = [1 3 7];
                    decisions = [
                        "Hour < " + spec.HourSplit + " is false"
                        "Temperature < " + spec.WarmSplit + " is false"];
                end
            end

            state = struct( ...
                "LeafIndex", leafIndex, ...
                "PathNodes", pathNodes, ...
                "Prediction", spec.Leaves(leafIndex), ...
                "TraceLines", decisions);
        end

        function story = analyzeLineDiagnostics(seed, patternName, noiseScale)
            arguments
                seed (1,1) double {mustBeInteger, mustBePositive}
                patternName (1,1) string {mustBeMember(patternName, ["Smooth curve", "Threshold rule", "Mixed seasonal"])}
                noiseScale (1,1) double {mustBePositive}
            end

            rng(seed, "twister")
            x = linspace(0, 10, 130)';
            switch patternName
                case "Smooth curve"
                    yTrue = 1.5 + (0.4 + 0.1 * rand()) * x + (0.18 + 0.05 * rand()) * (x - 5).^2;
                case "Threshold rule"
                    yTrue = 2.0 + 0.5 * x + 1.7 * (x > (4.2 + 0.9 * rand())) + 1.2 * (x > (7.0 + 0.6 * rand()));
                case "Mixed seasonal"
                    yTrue = 1.8 + 0.35 * x + 0.9 * sin(1.2 * x + rand()) + 0.4 * cos(2.1 * x);
            end
            y = yTrue + noiseScale * randn(size(x));
            xGrid = linspace(min(x), max(x), 250)';

            rng(seed + 11, "twister")
            cv = cvpartition(numel(x), "HoldOut", 0.3);
            tr = training(cv);
            va = test(cv);
            xTr = x(tr);
            yTr = y(tr);
            xVa = x(va);
            yVa = y(va);

            Ttr = table(xTr, xTr.^2, yTr, 'VariableNames', {'x', 'x2', 'y'});
            Tva = table(xVa, xVa.^2, yVa, 'VariableNames', {'x', 'x2', 'y'});

            linearModel = fitlm(xTr, yTr);
            quadraticModel = fitlm(Ttr, "y ~ x + x2");
            treeModel = fitrtree(xTr, yTr, "MaxNumSplits", 4, "MinLeafSize", 8);
            ensembleModel = fitrensemble(xTr, yTr, "Method", "LSBoost", "NumLearningCycles", 30, ...
                "Learners", templateTree("MaxNumSplits", 4, "MinLeafSize", 8));

            rmseLinear = sqrt(mean((yVa - predict(linearModel, xVa)).^2));
            rmseQuadratic = sqrt(mean((yVa - predict(quadraticModel, Tva(:, ["x", "x2"]))).^2));
            rmseTree = sqrt(mean((yVa - predict(treeModel, xVa)).^2));
            rmseEnsemble = sqrt(mean((yVa - predict(ensembleModel, xVa)).^2));
            rmseValues = [rmseLinear; rmseQuadratic; rmseTree; rmseEnsemble];
            modelNames = ["Linear"; "Quadratic"; "Tree"; "Ensemble"];
            [~, bestIdx] = min(rmseValues);

            linearResiduals = y - predict(linearModel, x);
            xGridTable = table(xGrid, xGrid.^2, 'VariableNames', {'x', 'x2'});
            story = struct( ...
                "Seed", seed, ...
                "PatternName", patternName, ...
                "x", x, ...
                "y", y, ...
                "xGrid", xGrid, ...
                "YTrue", yTrue, ...
                "LinearFit", predict(linearModel, xGrid), ...
                "QuadraticFit", predict(quadraticModel, xGridTable), ...
                "TreeFit", predict(treeModel, xGrid), ...
                "EnsembleFit", predict(ensembleModel, xGrid), ...
                "LinearResiduals", linearResiduals, ...
                "Summary", table(modelNames, rmseValues, 'VariableNames', {'Model', 'ValidationRMSE'}), ...
                "BestModel", modelNames(bestIdx));
        end

        function T = addEngineeredFeatures(T)
            T.x2 = T.x.^2;
            T.x3 = T.x.^3;
            T.sinx = sin(T.x);
            T.cosx = cos(T.x);
            T.x_z = T.x .* T.z;
            T.logx = log(T.x + 1e-6);
            T.sqrtx = sqrt(T.x);
        end

        function slices = makePredictionSlices(Traw)
            labels = ["Low z band", "Middle z band", "High z band"];
            zEdges = quantile(Traw.z, [0 1/3 2/3 1]);
            slices(1, 3) = struct("Label", "", "ZValue", NaN, "ZRange", [0 0], "XGrid", zeros(0, 1), "Table", table());
            for idx = 1:3
                if idx < 3
                    mask = Traw.z >= zEdges(idx) & Traw.z < zEdges(idx + 1);
                else
                    mask = Traw.z >= zEdges(idx) & Traw.z <= zEdges(idx + 1);
                end

                xBand = Traw.x(mask);
                zBand = Traw.z(mask);
                zValue = median(zBand);
                xGrid = linspace(min(xBand), max(xBand), 180)';
                Tslice = table(xGrid, repmat(zValue, size(xGrid)), zeros(size(xGrid)), 'VariableNames', {'x', 'z', 'y'});
                Tslice = TeachingModuleInteractiveSupport.addEngineeredFeatures(Tslice);

                slices(idx) = struct( ...
                    "Label", labels(idx), ...
                    "ZValue", zValue, ...
                    "ZRange", [min(zBand) max(zBand)], ...
                    "XGrid", xGrid, ...
                    "Table", Tslice);
            end
        end
    end
end
