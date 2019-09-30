classdef FT_tutorial_source_m < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        Fourier_Transform               matlab.ui.Figure
        UIAxes2                         matlab.ui.control.UIAxes
        UIAxes                          matlab.ui.control.UIAxes
        UIAxes3                         matlab.ui.control.UIAxes
        UIAxes4                         matlab.ui.control.UIAxes
        ControlsPanel                   matlab.ui.container.Panel
        GridLayout2                     matlab.ui.container.GridLayout
        StartButton                     matlab.ui.control.Button
        StopButton                      matlab.ui.control.Button
        FramecaptureLabel               matlab.ui.control.Label
        FramessSpinner                  matlab.ui.control.Spinner
        FramessSpinnerLabel             matlab.ui.control.Label
        FourierfilterLabel              matlab.ui.control.Label
        FilterRadiusLabel               matlab.ui.control.Label
        FilterRadius                    matlab.ui.control.Spinner
        LowpassButton                   matlab.ui.control.Button
        HighpassButton                  matlab.ui.control.Button
        FourierdisplayLabel             matlab.ui.control.Label
        ZoominButton                    matlab.ui.control.Button
        ZoomoutButton                   matlab.ui.control.Button
        DarkerButton                    matlab.ui.control.Button
        LighterButton                   matlab.ui.control.Button
        ResetviewButton                 matlab.ui.control.Button
        QuitButton                      matlab.ui.control.Button
        GaussianButton                  matlab.ui.control.Button
        BoxcarButton                    matlab.ui.control.Button
        FilterAxisDropDownLabel         matlab.ui.control.Label
        FilterAxisDropDown              matlab.ui.control.DropDown
        RealtimeFourierTransformsLabel  matlab.ui.control.Label
    end

    
    properties (Access = private)
        widthpix % Pixel size of the FT plot
        framespersec % Frames per second
        colorscalerange % Grayscale axis for the FT Plot
        stopState % Stop/Pause the program
        filtradius% Radius of the fourier filter
        lowpass% high pass or low pass filter
        GaussWindow %gaussian or boxcar window
        xfilter
        yfilter
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.widthpix=100;
            app.colorscalerange = 5;
            app.filtradius = 10;
            app.lowpass = true;
            app.GaussWindow = true;
            app.xfilter = true;
            app.yfilter = true;
            
            img_gray = zeros(720);
            
            %initialize the plots
            imagesc(app.UIAxes, img_gray)
            colormap(app.UIAxes,'gray')
            %set the plot limits
            app.UIAxes.XLim = [1 size(img_gray,2)];
            app.UIAxes.YLim = [1 size(img_gray,1)];
            
            box(app.UIAxes, "on")
            imagesc(app.UIAxes2, img_gray)
            colormap(app.UIAxes2,'gray')
            %set the plot limits
            app.UIAxes2.XLim = [1 size(img_gray,2)];
            app.UIAxes2.YLim = [1 size(img_gray,1)];
            box(app.UIAxes2, "on")
            
            box(app.UIAxes3, "on")
            imagesc(app.UIAxes3, img_gray)
            colormap(app.UIAxes3,'gray')
            %set the plot limits
            app.UIAxes3.XLim = [1 size(img_gray,2)];
            app.UIAxes3.YLim = [1 size(img_gray,1)];
            box(app.UIAxes3, "on")
            
            box(app.UIAxes4, "on")
            imagesc(app.UIAxes4, img_gray)
            colormap(app.UIAxes4,'gray')
            %set the plot limits
            app.UIAxes4.XLim = [1 size(img_gray,2)];
            app.UIAxes4.YLim = [1 size(img_gray,1)];
            box(app.UIAxes4, "on")
            
        end

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
            cam = webcam(1);
            app.stopState=true;
            
            while(app.stopState)
                
                %capture the snapshot
                img = snapshot(cam);
                
                %convert the snapshot to grayscale by combining the
                %channels
                img_gray1 = rgb2gray(img);
                maxpix = fix(min(size(img_gray1))/2)-1;
                imgcenter = fix(size(img_gray1)/2);
                
                %make the image square
                img_gray = img_gray1(imgcenter(1)-maxpix:imgcenter(1)+maxpix,imgcenter(2)-maxpix:imgcenter(2)+maxpix);
                
                %sum pixels in image, and crop image for FT
                tofftimg = sum(img,3);
                tofftimg2 = tofftimg(imgcenter(1)-maxpix:imgcenter(1)+maxpix,imgcenter(2)-maxpix:imgcenter(2)+maxpix);
                
                centerx=fix(size(img_gray,2)/2);
                centery=fix(size(img_gray,1)/2);
                [ImgColumns, ImgRows] = meshgrid(1:size(img_gray,2), 1:size(img_gray,1));
                % Next create the circle in the image.
                
                %subtract the mean before FT
                fftimg = abs(fft2(tofftimg2-mean(mean(tofftimg2))));
                fftimg = fftimg./max(max(fftimg));
                
                if ~app.GaussWindow
                    if app.xfilter&&app.yfilter
                        BandPassFiltTemp = (ImgRows - centerx).^2 + (ImgColumns - centery).^2 <= app.filtradius.^2;
                    elseif app.xfilter&&~app.yfilter
                        BandPassFiltTemp = (ImgColumns - centery).^2 <= app.filtradius.^2;
                        
                    elseif ~app.xfilter&&app.yfilter
                        BandPassFiltTemp = (ImgRows - centerx).^2  <= app.filtradius.^2;
                        
                    end
                else
                    if app.xfilter&&app.yfilter
                        BandPassFiltTemp = exp(-((ImgRows-centerx)/app.filtradius).^2).*exp(-((ImgColumns-centery)/app.filtradius).^2);
                    elseif app.xfilter&&~app.yfilter
                        BandPassFiltTemp = exp(-((ImgColumns-centery)/app.filtradius).^2);
                        
                    elseif ~app.xfilter&&app.yfilter
                        BandPassFiltTemp = exp(-((ImgRows-centerx)/app.filtradius).^2);%.*exp(-((ImgColumns-centery)/app.filtradius).^2);
                        
                    end
                end
                
                if app.lowpass
                    BandPassFilt= BandPassFiltTemp;
                else
                    BandPassFilt = (1-BandPassFiltTemp);
                end
                
                shiftedFilt = fftshift(double((BandPassFilt)));
                
                reconstructFFT = real(ifft2(shiftedFilt.*fft2(tofftimg2)));
                
                %%PLOTTING CODE
                imagesc(app.UIAxes, img_gray)
                colormap(app.UIAxes,'gray')
                box(app.UIAxes, "on")
                app.UIAxes.XLim = [1 size(img_gray,2)];
                app.UIAxes.YLim = [1 size(img_gray,1)];
                
                imagesc(app.UIAxes2, fftshift(fftimg))
                app.UIAxes2.XLim = [centerx-app.widthpix centerx+app.widthpix];
                app.UIAxes2.YLim = [centery-app.widthpix centery+app.widthpix];
                app.UIAxes2.CLim = [0 1/app.colorscalerange];
                colormap(app.UIAxes2,flipud(bone))
                box(app.UIAxes2, "on")
                
                imagesc(app.UIAxes4, fftshift(fftimg).*double(BandPassFilt))
                app.UIAxes4.XLim = [centerx-app.widthpix centerx+app.widthpix];
                app.UIAxes4.YLim = [centery-app.widthpix centery+app.widthpix];
                app.UIAxes4.CLim = [0 1/app.colorscalerange];
                colormap(app.UIAxes4,flipud(bone))
                box(app.UIAxes4, "on")
                
                imagesc(app.UIAxes3, reconstructFFT)
                app.UIAxes3.XLim = [1 size(img_gray,2)];
                app.UIAxes3.YLim = [1 size(img_gray,1)];
                colormap(app.UIAxes3,gray)
                box(app.UIAxes3, "on")
                
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

        % Value changed function: FilterRadius
        function FilterRadiusValueChanged(app, event)
            value = app.FilterRadius.Value;
            app.filtradius = value;
        end

        % Button pushed function: LowpassButton
        function LowpassButtonPushed(app, event)
            app.lowpass = true;
        end

        % Button pushed function: HighpassButton
        function HighpassButtonPushed(app, event)
            app.lowpass = false;
        end

        % Button pushed function: BoxcarButton
        function BoxcarButtonPushed(app, event)
            app.GaussWindow = false;
        end

        % Button pushed function: GaussianButton
        function GaussianButtonPushed(app, event)
            app.GaussWindow = true;
        end

        % Value changed function: FilterAxisDropDown
        function FilterAxisDropDownValueChanged(app, event)
            value = app.FilterAxisDropDown.Value;
            if strcmp(value,'Both')
                app.xfilter = true;
                app.yfilter = true;
            elseif strcmp(value,'Horizontal')
                app.xfilter = true;
                app.yfilter = false;
            elseif strcmp(value,'Vertical')
                app.xfilter = false;
                app.yfilter = true;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create Fourier_Transform and hide until all components are created
            app.Fourier_Transform = uifigure('Visible', 'off');
            app.Fourier_Transform.Position = [100 100 1285 888];
            app.Fourier_Transform.Name = 'Fourier Transform Tutorial';

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.Fourier_Transform);
            title(app.UIAxes2, 'Reciprocal (Fourier) Space')
            xlabel(app.UIAxes2, 'q_x (inv. pixels)')
            ylabel(app.UIAxes2, 'q_y (inv. pixels)')
            app.UIAxes2.FontSize = 16;
            app.UIAxes2.Box = 'on';
            app.UIAxes2.XTick = [];
            app.UIAxes2.YTick = [];
            app.UIAxes2.Position = [829 418 412 385];

            % Create UIAxes
            app.UIAxes = uiaxes(app.Fourier_Transform);
            title(app.UIAxes, 'Real Space')
            xlabel(app.UIAxes, 'x (pixels)')
            ylabel(app.UIAxes, 'y (pixels)')
            app.UIAxes.FontSize = 16;
            app.UIAxes.Box = 'on';
            app.UIAxes.XTick = [];
            app.UIAxes.YTick = [];
            app.UIAxes.Position = [343 418 412 385];

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.Fourier_Transform);
            title(app.UIAxes3, 'Reconstructed Real Space')
            xlabel(app.UIAxes3, 'x (pixels)')
            ylabel(app.UIAxes3, 'y (pixels)')
            app.UIAxes3.FontSize = 16;
            app.UIAxes3.Box = 'on';
            app.UIAxes3.XTick = [];
            app.UIAxes3.YTick = [];
            app.UIAxes3.Position = [343 24 412 385];

            % Create UIAxes4
            app.UIAxes4 = uiaxes(app.Fourier_Transform);
            title(app.UIAxes4, 'Filtered Fourier Space')
            xlabel(app.UIAxes4, 'q_x (inv. pixels)')
            ylabel(app.UIAxes4, 'q_y (inv. pixels)')
            app.UIAxes4.FontSize = 16;
            app.UIAxes4.Box = 'on';
            app.UIAxes4.XTick = [];
            app.UIAxes4.YTick = [];
            app.UIAxes4.Position = [829 24 412 385];

            % Create ControlsPanel
            app.ControlsPanel = uipanel(app.Fourier_Transform);
            app.ControlsPanel.TitlePosition = 'centertop';
            app.ControlsPanel.Title = 'Controls';
            app.ControlsPanel.FontSize = 20;
            app.ControlsPanel.Position = [49 42 266 743];

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.ControlsPanel);
            app.GridLayout2.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};

            % Create StartButton
            app.StartButton = uibutton(app.GridLayout2, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.FontSize = 20;
            app.StartButton.Layout.Row = 2;
            app.StartButton.Layout.Column = 1;
            app.StartButton.Text = 'Start';

            % Create StopButton
            app.StopButton = uibutton(app.GridLayout2, 'push');
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);
            app.StopButton.FontSize = 20;
            app.StopButton.Layout.Row = 2;
            app.StopButton.Layout.Column = 2;
            app.StopButton.Text = 'Stop';

            % Create FramecaptureLabel
            app.FramecaptureLabel = uilabel(app.GridLayout2);
            app.FramecaptureLabel.HorizontalAlignment = 'center';
            app.FramecaptureLabel.FontSize = 24;
            app.FramecaptureLabel.Layout.Row = 1;
            app.FramecaptureLabel.Layout.Column = [1 2];
            app.FramecaptureLabel.Text = 'Frame capture';

            % Create FramessSpinner
            app.FramessSpinner = uispinner(app.GridLayout2);
            app.FramessSpinner.Limits = [0 Inf];
            app.FramessSpinner.RoundFractionalValues = 'on';
            app.FramessSpinner.FontSize = 22;
            app.FramessSpinner.Layout.Row = 3;
            app.FramessSpinner.Layout.Column = 2;
            app.FramessSpinner.Value = 10;

            % Create FramessSpinnerLabel
            app.FramessSpinnerLabel = uilabel(app.GridLayout2);
            app.FramessSpinnerLabel.HorizontalAlignment = 'center';
            app.FramessSpinnerLabel.FontSize = 20;
            app.FramessSpinnerLabel.Layout.Row = 3;
            app.FramessSpinnerLabel.Layout.Column = 1;
            app.FramessSpinnerLabel.Text = 'Frames/s:';

            % Create FourierfilterLabel
            app.FourierfilterLabel = uilabel(app.GridLayout2);
            app.FourierfilterLabel.HorizontalAlignment = 'center';
            app.FourierfilterLabel.FontSize = 24;
            app.FourierfilterLabel.Layout.Row = 4;
            app.FourierfilterLabel.Layout.Column = [1 2];
            app.FourierfilterLabel.Text = 'Fourier filter';

            % Create FilterRadiusLabel
            app.FilterRadiusLabel = uilabel(app.GridLayout2);
            app.FilterRadiusLabel.HorizontalAlignment = 'center';
            app.FilterRadiusLabel.FontSize = 20;
            app.FilterRadiusLabel.Layout.Row = 7;
            app.FilterRadiusLabel.Layout.Column = 1;
            app.FilterRadiusLabel.Text = 'Filter Radius';

            % Create FilterRadius
            app.FilterRadius = uispinner(app.GridLayout2);
            app.FilterRadius.Limits = [0 Inf];
            app.FilterRadius.RoundFractionalValues = 'on';
            app.FilterRadius.ValueChangedFcn = createCallbackFcn(app, @FilterRadiusValueChanged, true);
            app.FilterRadius.FontSize = 22;
            app.FilterRadius.Layout.Row = 7;
            app.FilterRadius.Layout.Column = 2;
            app.FilterRadius.Value = 10;

            % Create LowpassButton
            app.LowpassButton = uibutton(app.GridLayout2, 'push');
            app.LowpassButton.ButtonPushedFcn = createCallbackFcn(app, @LowpassButtonPushed, true);
            app.LowpassButton.FontSize = 20;
            app.LowpassButton.Layout.Row = 6;
            app.LowpassButton.Layout.Column = 1;
            app.LowpassButton.Text = 'Low pass';

            % Create HighpassButton
            app.HighpassButton = uibutton(app.GridLayout2, 'push');
            app.HighpassButton.ButtonPushedFcn = createCallbackFcn(app, @HighpassButtonPushed, true);
            app.HighpassButton.FontSize = 20;
            app.HighpassButton.Layout.Row = 6;
            app.HighpassButton.Layout.Column = 2;
            app.HighpassButton.Text = 'High pass';

            % Create FourierdisplayLabel
            app.FourierdisplayLabel = uilabel(app.GridLayout2);
            app.FourierdisplayLabel.HorizontalAlignment = 'center';
            app.FourierdisplayLabel.FontSize = 24;
            app.FourierdisplayLabel.Layout.Row = 9;
            app.FourierdisplayLabel.Layout.Column = [1 2];
            app.FourierdisplayLabel.Text = 'Fourier display';

            % Create ZoominButton
            app.ZoominButton = uibutton(app.GridLayout2, 'push');
            app.ZoominButton.ButtonPushedFcn = createCallbackFcn(app, @ZoominButtonPushed, true);
            app.ZoominButton.FontSize = 20;
            app.ZoominButton.Layout.Row = 10;
            app.ZoominButton.Layout.Column = 1;
            app.ZoominButton.Text = 'Zoom in';

            % Create ZoomoutButton
            app.ZoomoutButton = uibutton(app.GridLayout2, 'push');
            app.ZoomoutButton.ButtonPushedFcn = createCallbackFcn(app, @ZoomoutButtonPushed, true);
            app.ZoomoutButton.FontSize = 20;
            app.ZoomoutButton.Layout.Row = 10;
            app.ZoomoutButton.Layout.Column = 2;
            app.ZoomoutButton.Text = 'Zoom out';

            % Create DarkerButton
            app.DarkerButton = uibutton(app.GridLayout2, 'push');
            app.DarkerButton.ButtonPushedFcn = createCallbackFcn(app, @DarkerButtonPushed, true);
            app.DarkerButton.FontSize = 20;
            app.DarkerButton.Layout.Row = 11;
            app.DarkerButton.Layout.Column = 1;
            app.DarkerButton.Text = 'Darker';

            % Create LighterButton
            app.LighterButton = uibutton(app.GridLayout2, 'push');
            app.LighterButton.ButtonPushedFcn = createCallbackFcn(app, @LighterButtonPushed, true);
            app.LighterButton.FontSize = 20;
            app.LighterButton.Layout.Row = 11;
            app.LighterButton.Layout.Column = 2;
            app.LighterButton.Text = 'Lighter';

            % Create ResetviewButton
            app.ResetviewButton = uibutton(app.GridLayout2, 'push');
            app.ResetviewButton.ButtonPushedFcn = createCallbackFcn(app, @ResetviewButtonPushed, true);
            app.ResetviewButton.FontSize = 20;
            app.ResetviewButton.Layout.Row = 12;
            app.ResetviewButton.Layout.Column = 1;
            app.ResetviewButton.Text = 'Reset view';

            % Create QuitButton
            app.QuitButton = uibutton(app.GridLayout2, 'push');
            app.QuitButton.ButtonPushedFcn = createCallbackFcn(app, @QuitButtonPushed, true);
            app.QuitButton.FontSize = 20;
            app.QuitButton.FontColor = [1 0 0];
            app.QuitButton.Layout.Row = 12;
            app.QuitButton.Layout.Column = 2;
            app.QuitButton.Text = 'Quit';

            % Create GaussianButton
            app.GaussianButton = uibutton(app.GridLayout2, 'push');
            app.GaussianButton.ButtonPushedFcn = createCallbackFcn(app, @GaussianButtonPushed, true);
            app.GaussianButton.FontSize = 20;
            app.GaussianButton.Layout.Row = 5;
            app.GaussianButton.Layout.Column = 2;
            app.GaussianButton.Text = 'Gaussian';

            % Create BoxcarButton
            app.BoxcarButton = uibutton(app.GridLayout2, 'push');
            app.BoxcarButton.ButtonPushedFcn = createCallbackFcn(app, @BoxcarButtonPushed, true);
            app.BoxcarButton.FontSize = 20;
            app.BoxcarButton.Layout.Row = 5;
            app.BoxcarButton.Layout.Column = 1;
            app.BoxcarButton.Text = 'Boxcar';

            % Create FilterAxisDropDownLabel
            app.FilterAxisDropDownLabel = uilabel(app.GridLayout2);
            app.FilterAxisDropDownLabel.HorizontalAlignment = 'right';
            app.FilterAxisDropDownLabel.FontSize = 18;
            app.FilterAxisDropDownLabel.Layout.Row = 8;
            app.FilterAxisDropDownLabel.Layout.Column = 1;
            app.FilterAxisDropDownLabel.Text = 'Filter Axis';

            % Create FilterAxisDropDown
            app.FilterAxisDropDown = uidropdown(app.GridLayout2);
            app.FilterAxisDropDown.Items = {'Both', 'Horizontal', 'Vertical'};
            app.FilterAxisDropDown.ValueChangedFcn = createCallbackFcn(app, @FilterAxisDropDownValueChanged, true);
            app.FilterAxisDropDown.FontSize = 18;
            app.FilterAxisDropDown.Layout.Row = 8;
            app.FilterAxisDropDown.Layout.Column = 2;
            app.FilterAxisDropDown.Value = 'Both';

            % Create RealtimeFourierTransformsLabel
            app.RealtimeFourierTransformsLabel = uilabel(app.Fourier_Transform);
            app.RealtimeFourierTransformsLabel.HorizontalAlignment = 'center';
            app.RealtimeFourierTransformsLabel.FontSize = 26;
            app.RealtimeFourierTransformsLabel.Position = [37 814 1204 38];
            app.RealtimeFourierTransformsLabel.Text = 'Real-time Fourier-Transforms';

            % Show the figure after all components are created
            app.Fourier_Transform.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = FT_tutorial_source_m

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