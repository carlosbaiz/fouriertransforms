classdef FT_tutorial_source_m < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        Fourier_Transform    matlab.ui.Figure
        Panel                matlab.ui.container.Panel
        GridLayout           matlab.ui.container.GridLayout
        ZoominButton         matlab.ui.control.Button
        ZoomoutButton        matlab.ui.control.Button
        ResetviewButton      matlab.ui.control.Button
        LighterButton        matlab.ui.control.Button
        DarkerButton         matlab.ui.control.Button
        GrayscaleLabel       matlab.ui.control.Label
        StartButton          matlab.ui.control.Button
        StopButton           matlab.ui.control.Button
        FramessSpinnerLabel  matlab.ui.control.Label
        FramessSpinner       matlab.ui.control.Spinner
        UIAxes2              matlab.ui.control.UIAxes
        UIAxes               matlab.ui.control.UIAxes
        Panel_2              matlab.ui.container.Panel
        GridLayout2          matlab.ui.container.GridLayout
        QuitButton           matlab.ui.control.Button
        Panel_3              matlab.ui.container.Panel
        RealtimeFourierTransformTutorialLabel  matlab.ui.control.Label
    end

    
    properties (Access = private)
        widthpix % Description
        framespersec % Description
        colorscalerange % Description
        stopState % Description
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            img = zeros(720);
            img_gray = mat2gray(img,[0 1]);
            app.widthpix=100;
            app.colorscalerange=5;
            
            imagesc(app.UIAxes, img_gray)
            colormap(app.UIAxes,"gray")
            
            
            app.UIAxes.XLim = [1 size(img,2)];
            app.UIAxes.YLim = [1 size(img,1)];
            colormap(app.UIAxes,flipud(bone));
            h  = colorbar(app.UIAxes);
            ylabel(h, 'Intensity (arb)', 'FontSize', 12);
            box(app.UIAxes, "on")
            
            %set the plot limits
            centerx=fix(size(img,2)/2);
            centery=fix(size(img,1)/2);
            
            %subtract the mean before FT
            
            fftimg = abs(fft2(sum(img,3)-mean(mean(sum(img,3)))));
            fftimg = fftimg./max(max(fftimg));
            imagesc(app.UIAxes2, fftshift(fftimg))
            app.UIAxes2.XLim = [centerx-app.widthpix centerx+app.widthpix];
            app.UIAxes2.YLim = [centery-app.widthpix centery+app.widthpix];
            app.UIAxes2.CLim = [0 1/app.colorscalerange];
            colormap(app.UIAxes2,flipud(bone))
            h = colorbar(app.UIAxes2);
            ylabel(h, 'Intensity (arb)', 'FontSize', 12);
            box(app.UIAxes2, "on")
            drawnow
            
            
        end

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
            cam = webcam(1);
            app.stopState=true;
            
            while(app.stopState)
                
                img = snapshot(cam);
                img_gray = rgb2gray(img);
                
                
                imagesc(app.UIAxes, img_gray)
                colormap(app.UIAxes,'gray')
                box(app.UIAxes, "on")
                
                app.UIAxes.XLim = [1 size(img,2)];
                app.UIAxes.YLim = [1 size(img,1)];
                
                %set the plot limits
                centerx=fix(size(img,2)/2);
                centery=fix(size(img,1)/2);
                
                %subtract the mean before FT
                
                
                fftimg = abs(fft2(sum(img,3)-mean(mean(sum(img,3)))));
                fftimg = fftimg./max(max(fftimg));
                imagesc(app.UIAxes2, fftshift(fftimg))
                
                app.UIAxes2.XLim = [centerx-app.widthpix centerx+app.widthpix];
                app.UIAxes2.YLim = [centery-app.widthpix centery+app.widthpix];
                app.UIAxes2.CLim = [0 1/app.colorscalerange];
                colormap(app.UIAxes2,flipud(bone))
                box(app.UIAxes2, "on")
                
                drawnow
                pause(double(1./app.framespersec));
                
                exitflag = get(app.StartButton, 'UserData');
                if ~isempty(exitflag) && strcmp(exitflag, 'stop')
                    break;
                end
            end
            
            
        end

        % Button pushed function: StopButton
        function StopButtonPushed(app, event)
            app.stopState=false;
        end

        % Button pushed function: ZoominButton
        function ZoominButtonPushed(app, event)
            app.widthpix=fix(app.widthpix*0.9);
        end

        % Button pushed function: ZoomoutButton
        function ZoomoutButtonPushed(app, event)
            app.widthpix=fix(app.widthpix*1.1);
        end

        % Button pushed function: ResetviewButton
        function ResetviewButtonPushed(app, event)
            app.widthpix=100;
        end

        % Callback function
        function FramespersecondEditFieldValueChanged(app, event)
            value = app.FramespersecondEditField.Value;
            app.framespersec=value;
        end

        % Button pushed function: QuitButton
        function QuitButtonPushed(app, event)
            closereq
        end

        % Button pushed function: DarkerButton
        function DarkerButtonPushed(app, event)
            app.colorscalerange=1.1*app.colorscalerange;
        end

        % Button pushed function: LighterButton
        function LighterButtonPushed(app, event)
            app.colorscalerange=0.9*app.colorscalerange;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create Fourier_Transform and hide until all components are created
            app.Fourier_Transform = uifigure('Visible', 'off');
            app.Fourier_Transform.Position = [100 100 1006 610];
            app.Fourier_Transform.Name = 'Fourier Transform Tutorial';

            % Create Panel
            app.Panel = uipanel(app.Fourier_Transform);
            app.Panel.BorderType = 'none';
            app.Panel.Position = [2 477 994 88];

            % Create GridLayout
            app.GridLayout = uigridlayout(app.Panel);
            app.GridLayout.ColumnWidth = {'1x', '1x', '1x', '2x', '1x', '1x', '1x', '1x'};
            app.GridLayout.Padding = [5 5 5 5];

            % Create ZoominButton
            app.ZoominButton = uibutton(app.GridLayout, 'push');
            app.ZoominButton.ButtonPushedFcn = createCallbackFcn(app, @ZoominButtonPushed, true);
            app.ZoominButton.FontSize = 16;
            app.ZoominButton.Layout.Row = 1;
            app.ZoominButton.Layout.Column = 5;
            app.ZoominButton.Text = 'Zoom in';

            % Create ZoomoutButton
            app.ZoomoutButton = uibutton(app.GridLayout, 'push');
            app.ZoomoutButton.ButtonPushedFcn = createCallbackFcn(app, @ZoomoutButtonPushed, true);
            app.ZoomoutButton.FontSize = 16;
            app.ZoomoutButton.Layout.Row = 1;
            app.ZoomoutButton.Layout.Column = 6;
            app.ZoomoutButton.Text = 'Zoom out';

            % Create ResetviewButton
            app.ResetviewButton = uibutton(app.GridLayout, 'push');
            app.ResetviewButton.ButtonPushedFcn = createCallbackFcn(app, @ResetviewButtonPushed, true);
            app.ResetviewButton.FontSize = 16;
            app.ResetviewButton.Layout.Row = 1;
            app.ResetviewButton.Layout.Column = 7;
            app.ResetviewButton.Text = 'Reset view';

            % Create LighterButton
            app.LighterButton = uibutton(app.GridLayout, 'push');
            app.LighterButton.ButtonPushedFcn = createCallbackFcn(app, @LighterButtonPushed, true);
            app.LighterButton.FontSize = 16;
            app.LighterButton.Layout.Row = 2;
            app.LighterButton.Layout.Column = 7;
            app.LighterButton.Text = 'Lighter';

            % Create DarkerButton
            app.DarkerButton = uibutton(app.GridLayout, 'push');
            app.DarkerButton.ButtonPushedFcn = createCallbackFcn(app, @DarkerButtonPushed, true);
            app.DarkerButton.FontSize = 16;
            app.DarkerButton.Layout.Row = 2;
            app.DarkerButton.Layout.Column = 6;
            app.DarkerButton.Text = 'Darker';

            % Create GrayscaleLabel
            app.GrayscaleLabel = uilabel(app.GridLayout);
            app.GrayscaleLabel.FontSize = 16;
            app.GrayscaleLabel.Layout.Row = 2;
            app.GrayscaleLabel.Layout.Column = 5;
            app.GrayscaleLabel.Text = 'Grayscale:';

            % Create StartButton
            app.StartButton = uibutton(app.GridLayout, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.FontSize = 16;
            app.StartButton.Layout.Row = 1;
            app.StartButton.Layout.Column = 2;
            app.StartButton.Text = 'Start';

            % Create StopButton
            app.StopButton = uibutton(app.GridLayout, 'push');
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);
            app.StopButton.FontSize = 16;
            app.StopButton.Layout.Row = 1;
            app.StopButton.Layout.Column = 3;
            app.StopButton.Text = 'Stop';

            % Create FramessSpinnerLabel
            app.FramessSpinnerLabel = uilabel(app.GridLayout);
            app.FramessSpinnerLabel.HorizontalAlignment = 'center';
            app.FramessSpinnerLabel.FontSize = 16;
            app.FramessSpinnerLabel.Layout.Row = 2;
            app.FramessSpinnerLabel.Layout.Column = 2;
            app.FramessSpinnerLabel.Text = 'Frames/s:';

            % Create FramessSpinner
            app.FramessSpinner = uispinner(app.GridLayout);
            app.FramessSpinner.Limits = [0 Inf];
            app.FramessSpinner.RoundFractionalValues = 'on';
            app.FramessSpinner.FontSize = 16;
            app.FramessSpinner.Layout.Row = 2;
            app.FramessSpinner.Layout.Column = 3;
            app.FramessSpinner.Value = 10;

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.Fourier_Transform);
            title(app.UIAxes2, 'Reciprocal (Fourier) Space')
            xlabel(app.UIAxes2, 'q_x (inverse pixels)')
            ylabel(app.UIAxes2, 'q_y (inverse pixels)')
            app.UIAxes2.FontSize = 16;
            app.UIAxes2.Box = 'on';
            app.UIAxes2.XTick = [];
            app.UIAxes2.YTick = [];
            app.UIAxes2.Position = [499 68 475 385];

            % Create UIAxes
            app.UIAxes = uiaxes(app.Fourier_Transform);
            title(app.UIAxes, 'Real Space')
            xlabel(app.UIAxes, 'x (pixels)')
            ylabel(app.UIAxes, 'y (pixels)')
            app.UIAxes.FontSize = 16;
            app.UIAxes.Box = 'on';
            app.UIAxes.XTick = [];
            app.UIAxes.YTick = [];
            app.UIAxes.Position = [7 68 475 385];

            % Create Panel_2
            app.Panel_2 = uipanel(app.Fourier_Transform);
            app.Panel_2.BorderType = 'none';
            app.Panel_2.Position = [70 4 866 58];

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.Panel_2);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '1x', '2x', '1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {'1x'};
            app.GridLayout2.ColumnSpacing = 1;

            % Create QuitButton
            app.QuitButton = uibutton(app.GridLayout2, 'push');
            app.QuitButton.ButtonPushedFcn = createCallbackFcn(app, @QuitButtonPushed, true);
            app.QuitButton.FontSize = 18;
            app.QuitButton.FontColor = [1 0 0];
            app.QuitButton.Layout.Row = 1;
            app.QuitButton.Layout.Column = 4;
            app.QuitButton.Text = 'Quit';

            % Create Panel_3
            app.Panel_3 = uipanel(app.Fourier_Transform);
            app.Panel_3.BorderType = 'none';
            app.Panel_3.Position = [1 564 1002 47];

            % Create RealtimeFourierTransformTutorialLabel
            app.RealtimeFourierTransformTutorialLabel = uilabel(app.Panel_3);
            app.RealtimeFourierTransformTutorialLabel.HorizontalAlignment = 'center';
            app.RealtimeFourierTransformTutorialLabel.FontSize = 26;
            app.RealtimeFourierTransformTutorialLabel.Position = [7 2 994 44];
            app.RealtimeFourierTransformTutorialLabel.Text = 'Real-time Fourier-Transform Tutorial';

            % Show the figure after all components are created
            app.Fourier_Transform.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = FT_tutorial_source

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.Fourier_Transform)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.Fourier_Transform)
        end
    end
end