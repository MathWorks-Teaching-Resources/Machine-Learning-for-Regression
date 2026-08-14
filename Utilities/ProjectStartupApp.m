classdef ProjectStartupApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        StartUpAppUIFigure  matlab.ui.Figure
        FeedBackPanel       matlab.ui.container.Panel
        FeedBackGrid        matlab.ui.container.GridLayout
        ReviewTitle         matlab.ui.control.Label
        ReviewText          matlab.ui.control.Label
        OtherButton         matlab.ui.control.Button
        StudentButton       matlab.ui.control.Button
        FacultyButton       matlab.ui.control.Button
        Q1                  matlab.ui.control.Label
        WelcomePanel        matlab.ui.container.Panel
        WelcomeGrid         matlab.ui.container.GridLayout
        WelcomeTitle        matlab.ui.control.Label
        CoverImage          matlab.ui.control.Image
        ReviewUsButton      matlab.ui.control.Button
        READMEButton        matlab.ui.control.Button
        MainMenuButton      matlab.ui.control.Button
    end

    
    properties (Access = private)
        GitHubOrganization = "MathWorks-Teaching-Resources"; % Description
        GitHubRepository = "XXXX";
        InitPosition;
    end
%% How to customize the app?    
%{
    
    This StartUp app is designed to be customized to your module. It
    requires a minimum number of customization:
    
    1. Change "Module Template" in app.WelcomeTitle by your module name
    2. Change "Module Template" in app.ReviewTitle by your module name
    3. Change the GitHubRepository (line 25) to the correct value
    4. Change image in app.CoverImage by the cover image you would like for your
       module. This image should be located in rootFolder/Images
    5. Create your MS Form:
        a. Make a copy of the Faculty and the Student Template surveys
        b. Customize the name of the survey to match the name of your
           survey
        c. Click on "Collect responses", select "Anyone can respond" and
        copy the form link to SetupAppLinks (see step 6).
    5. Create your MS Sway:
        a. Go to MS Sway
        b. Create a blank sway
        c. Add the name of your module to the title box
        d. Click "Share", Select "Anyone with a link", Select "View"
        e. Copy the sway link to SetupAppLinks (see step 6).
    6. Add the Survey and Sway link to Utilities/SurveyLinks using
    SetupAppLinks.mlx in InternalFiles/RequiredFunctions/StartUpFcn
    7. Save > Export to .m file and save the result as
    Utilities/ProjectStartupApp.m

%}

    methods (Access = private, Static)

        function pingSway(app)
            try
                if ~ispref("MCCTEAM")
                    load Utilities\SurveyLinks.mat SwayLink
                    webread(SwayLink);
                end
            catch
            end
        end
        
        function openStudentForm(app)
            try
                load Utilities\SurveyLinks.mat StudentFormLink
                web(StudentFormLink);
            catch
            end
        end

        function openFacultyForm(app)
            try
                load Utilities\SurveyLinks.mat FacultyFormLink
                web(FacultyFormLink);
            catch
            end
        end

        function saveSettings(isReviewed,numLoad)
            try
                save(fullfile("Utilities","ProjectSettings.mat"),"isReviewed","numLoad");
            catch
            end
        end

    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            
            % Copy title
            app.ReviewTitle.Text = app.WelcomeTitle.Text;

            % Switch tab to review if has not been reviewed yet
            if isfile(fullfile("Utilities","ProjectSettings.mat"))
                load(fullfile("Utilities","ProjectSettings.mat"),"isReviewed","numLoad");
                numLoad = numLoad + 1; % Increment counter
            else
                isReviewed = false;
                numLoad = 1; % Initialize counter
            end

            % Select tab to display
            if ~isReviewed && numLoad > 2
                isReviewed = true;
                app.FeedBackGrid.Parent = app.StartUpAppUIFigure; 
            else
                app.WelcomeGrid.Parent = app.StartUpAppUIFigure;
            end
            app.InitPosition = app.StartUpAppUIFigure.Position;

            % Save new settings
            app.saveSettings(isReviewed,numLoad)

            % Download links to survey (should only work when module goes
            % public on GitHub)
            try
                import matlab.net.*
                import matlab.net.http.*
                
                Request = RequestMessage;
                Request.Method = 'GET';
                Address = URI("http://api.github.com/repos/"+app.GitHubOrganization+...
                    "/"+app.GitHubRepository+"/contents/Utilities/SurveyLinks.mat");
                Request.Header    = HeaderField("X-GitHub-Api-Version","2022-11-28");
                Request.Header(2) = HeaderField("Accept","application/vnd.github+json");
                [Answer,~,~] = send(Request,Address);
                websave(fullfile("Utilities/SurveyLinks.mat"),Answer.Body.Data.download_url);
            catch
            end
        end

        % Close request function: StartUpAppUIFigure
        function StartUpAppUIFigureCloseRequest(app, event)
            if event.Source == app.READMEButton
                open README.mlx
            elseif event.Source == app.MainMenuButton
                open MainMenu.mlx
            elseif event.Source == app.FacultyButton
                open MainMenu.mlx            
            elseif event.Source == app.StudentButton
                open MainMenu.mlx
            elseif event.Source == app.OtherButton
                open MainMenu.mlx
            else
                disp("Thank you for your time.")
            end
            delete(app)
        end

        % Button pushed function: MainMenuButton
        function MainMenuButtonPushed(app, event)
            StartUpAppUIFigureCloseRequest(app,event)
        end

        % Button pushed function: FacultyButton
        function FacultyButtonPushed(app, event)
            app.pingSway;
            app.openFacultyForm;
            StartUpAppUIFigureCloseRequest(app,event)
        end

        % Button pushed function: StudentButton
        function StudentButtonPushed(app, event)
            app.pingSway;
            app.openStudentForm;
            StartUpAppUIFigureCloseRequest(app,event)
        end

        % Button pushed function: OtherButton
        function OtherButtonPushed(app, event)
            app.pingSway;
            app.openStudentForm;
            StartUpAppUIFigureCloseRequest(app,event)
        end

        % Button pushed function: ReviewUsButton
        function ReviewUsButtonPushed(app, event)
            app.WelcomeGrid.Parent = app.WelcomePanel;
            app.FeedBackGrid.Parent = app.StartUpAppUIFigure;
        end

        % Button pushed function: READMEButton
        function READMEButtonPushed(app, event)
            StartUpAppUIFigureCloseRequest(app,event)
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create StartUpAppUIFigure and hide until all components are created
            app.StartUpAppUIFigure = uifigure('Visible', 'off');
            app.StartUpAppUIFigure.AutoResizeChildren = 'off';
            app.StartUpAppUIFigure.Position = [100 100 276 430];
            app.StartUpAppUIFigure.Name = 'StartUp App';
            app.StartUpAppUIFigure.CloseRequestFcn = createCallbackFcn(app, @StartUpAppUIFigureCloseRequest, true);

            % Create WelcomePanel
            app.WelcomePanel = uipanel(app.StartUpAppUIFigure);
            app.WelcomePanel.AutoResizeChildren = 'off';
            app.WelcomePanel.Position = [-551 33 244 410];

            % Create WelcomeGrid
            app.WelcomeGrid = uigridlayout(app.WelcomePanel);
            app.WelcomeGrid.ColumnWidth = {'1x', '8x', '1x'};
            app.WelcomeGrid.RowHeight = {'2x', '5x', '1x', '1x', '1x'};

            % Create MainMenuButton
            app.MainMenuButton = uibutton(app.WelcomeGrid, 'push');
            app.MainMenuButton.ButtonPushedFcn = createCallbackFcn(app, @MainMenuButtonPushed, true);
            app.MainMenuButton.FontSize = 18;
            app.MainMenuButton.Layout.Row = 3;
            app.MainMenuButton.Layout.Column = 2;
            app.MainMenuButton.Text = 'Main Menu';

            % Create READMEButton
            app.READMEButton = uibutton(app.WelcomeGrid, 'push');
            app.READMEButton.ButtonPushedFcn = createCallbackFcn(app, @READMEButtonPushed, true);
            app.READMEButton.FontSize = 18;
            app.READMEButton.Layout.Row = 4;
            app.READMEButton.Layout.Column = 2;
            app.READMEButton.Text = 'README';

            % Create ReviewUsButton
            app.ReviewUsButton = uibutton(app.WelcomeGrid, 'push');
            app.ReviewUsButton.ButtonPushedFcn = createCallbackFcn(app, @ReviewUsButtonPushed, true);
            app.ReviewUsButton.FontSize = 18;
            app.ReviewUsButton.Layout.Row = 5;
            app.ReviewUsButton.Layout.Column = 2;
            app.ReviewUsButton.Text = 'Review Us';

            % Create CoverImage
            app.CoverImage = uiimage(app.WelcomeGrid);
            app.CoverImage.Layout.Row = 2;
            app.CoverImage.Layout.Column = [1 3];
            app.CoverImage.ImageSource = 'ML.gif';

            % Create WelcomeTitle
            app.WelcomeTitle = uilabel(app.WelcomeGrid);
            app.WelcomeTitle.HorizontalAlignment = 'center';
            app.WelcomeTitle.VerticalAlignment = 'top';
            app.WelcomeTitle.WordWrap = 'on';
            app.WelcomeTitle.FontSize = 18;
            app.WelcomeTitle.FontWeight = 'bold';
            app.WelcomeTitle.Layout.Row = 1;
            app.WelcomeTitle.Layout.Column = [1 3];
            app.WelcomeTitle.Text = 'Welcome to Machine Learning Methods: Regression';

            % Create FeedBackPanel
            app.FeedBackPanel = uipanel(app.StartUpAppUIFigure);
            app.FeedBackPanel.AutoResizeChildren = 'off';
            app.FeedBackPanel.Position = [-291 33 236 409];

            % Create FeedBackGrid
            app.FeedBackGrid = uigridlayout(app.FeedBackPanel);
            app.FeedBackGrid.ColumnWidth = {'1x', '8x', '1x'};
            app.FeedBackGrid.RowHeight = {'2x', '3x', '2x', '1x', '1x', '1x'};

            % Create Q1
            app.Q1 = uilabel(app.FeedBackGrid);
            app.Q1.HorizontalAlignment = 'center';
            app.Q1.WordWrap = 'on';
            app.Q1.FontSize = 18;
            app.Q1.FontWeight = 'bold';
            app.Q1.Layout.Row = 3;
            app.Q1.Layout.Column = [1 3];
            app.Q1.Text = 'What describes you best?';

            % Create FacultyButton
            app.FacultyButton = uibutton(app.FeedBackGrid, 'push');
            app.FacultyButton.ButtonPushedFcn = createCallbackFcn(app, @FacultyButtonPushed, true);
            app.FacultyButton.FontSize = 18;
            app.FacultyButton.Layout.Row = 4;
            app.FacultyButton.Layout.Column = 2;
            app.FacultyButton.Text = 'Faculty';

            % Create StudentButton
            app.StudentButton = uibutton(app.FeedBackGrid, 'push');
            app.StudentButton.ButtonPushedFcn = createCallbackFcn(app, @StudentButtonPushed, true);
            app.StudentButton.FontSize = 18;
            app.StudentButton.Layout.Row = 5;
            app.StudentButton.Layout.Column = 2;
            app.StudentButton.Text = 'Student';

            % Create OtherButton
            app.OtherButton = uibutton(app.FeedBackGrid, 'push');
            app.OtherButton.ButtonPushedFcn = createCallbackFcn(app, @OtherButtonPushed, true);
            app.OtherButton.FontSize = 18;
            app.OtherButton.Layout.Row = 6;
            app.OtherButton.Layout.Column = 2;
            app.OtherButton.Text = 'Other';

            % Create ReviewText
            app.ReviewText = uilabel(app.FeedBackGrid);
            app.ReviewText.HorizontalAlignment = 'center';
            app.ReviewText.WordWrap = 'on';
            app.ReviewText.FontSize = 14;
            app.ReviewText.Layout.Row = 2;
            app.ReviewText.Layout.Column = [1 3];
            app.ReviewText.Text = 'Please help us improve your experience by answering a few questions.';

            % Create ReviewTitle
            app.ReviewTitle = uilabel(app.FeedBackGrid);
            app.ReviewTitle.HorizontalAlignment = 'center';
            app.ReviewTitle.VerticalAlignment = 'top';
            app.ReviewTitle.WordWrap = 'on';
            app.ReviewTitle.FontSize = 24;
            app.ReviewTitle.FontWeight = 'bold';
            app.ReviewTitle.Layout.Row = 1;
            app.ReviewTitle.Layout.Column = [1 3];
            app.ReviewTitle.Text = '';

            % Show the figure after all components are created
            app.StartUpAppUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ProjectStartupApp

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.StartUpAppUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.StartUpAppUIFigure)
        end
    end
end