% HelperStereoVisualSLAMSystem Stereo visual SLAM algorithm
%
%   This is an example helper function that is subject to change or removal 
%   in future releases.

%   Copyright 2021-2022 The MathWorks, Inc.

classdef HelperStereoVisualSLAMSystem < matlab.System

    % Public, non-tunable properties
    properties(Nontunable)
        %FocalLength Camera focal length
        FocalLength    = [1109 1109]

        %PrincipalPoint Camera focal center
        PrincipalPoint = [640 360]

        %ImageSize Image size
        ImageSize      = [720 1280]

        %Baseline Base line
        Baseline       = 0.5
    end

    % Pre-computed constants
    properties(Access = private)
        VslamObj
    end

    methods
        % Constructor
        function obj = HelperStereoVisualSLAMSystem(varargin)
            % Support name-value pair arguments when constructing object
            setProperties(obj,nargin,varargin{:})
        end
    end

    methods(Access = protected)
        %% Common functions
        function setupImpl(obj)
            % Perform one-time calculations, such as computing constants
            intrinsics = cameraIntrinsics(obj.FocalLength, obj.PrincipalPoint, obj.ImageSize);
           
            obj.VslamObj = stereovslam(intrinsics,obj.Baseline,DisparityRange=[0,32],...
                LoopClosureThreshold=150,MaxNumPoints=800,SkipMaxFrames=10,TrackFeatureRange=[30,120]);
        end

        function isTrackingLost = stepImpl(obj, ILeft, IRight)
            % Implement algorithm. Calculate y as a function of input u and
            % discrete states.

            addFrame(obj.VslamObj,ILeft, IRight);

            if hasNewKeyFrame(obj.VslamObj)
                plot(obj.VslamObj);
            end

            isTrackingLost=~checkStatus(obj.VslamObj);
        end

        function resetImpl(obj)
            % Initialize / reset discrete-state properties
        end

        %% Backup/restore functions
        function s = saveObjectImpl(obj)
            % Set properties in structure s to values in object obj

            % Set public properties and states
            s = saveObjectImpl@matlab.System(obj);

            % Set private and protected properties
            %s.myproperty = obj.myproperty;
        end

        function loadObjectImpl(obj,s,wasLocked)
            % Set properties in object obj to values in structure s

            % Set private and protected properties
            % obj.myproperty = s.myproperty;

            % Set public properties and states
            loadObjectImpl@matlab.System(obj,s,wasLocked);
        end
       
        %% Simulink functions
        function ds = getDiscreteStateImpl(obj)
            % Return structure of properties with DiscreteState attribute
            ds = struct([]);
        end

        function flag = isInputSizeMutableImpl(obj,index)
            % Return false if input size cannot change
            % between calls to the System object
            flag = false;
        end

        function [out1] = getOutputSizeImpl(obj)
            % Return size for each output port
            out1= [1 1];
        end

        function [out1] = getOutputDataTypeImpl(obj)
            % Return data type for each output port
            out1 = "boolean";
        end

        function [out1] = isOutputComplexImpl(obj)
            % Return true for each output port with complex data
            out1 = false;
        end

        function [out1] = isOutputFixedSizeImpl(obj)
            % Return true for each output port with fixed size
            out1 = true;
        end

        function icon = getIconImpl(obj)
            % Define icon for System block
            icon = ["Helper","Stereo Visual", "SLAM System"]; % Use class name
        end

        function [name1,name2] = getInputNamesImpl(obj)
            % Return input port names for System block
            name1 = 'ILeft';
            name2 = 'IRight';
        end

        function [name1] = getOutputNamesImpl(obj)
            % Return output port names for System block
            name1 = 'Tracking Lost';
        end
    end

    methods(Static, Access = protected)
        %% Simulink customization functions
        function header = getHeaderImpl
            % Define header panel for System block dialog
            header = matlab.system.display.Header(mfilename("class"));
        end

        function group = getPropertyGroupsImpl
            % Define property section(s) for System block dialog
            group = matlab.system.display.Section(mfilename("class"));
        end

        function flag = showSimulateUsingImpl
            % Return false if simulation mode hidden in System block dialog
            flag = false;
        end
    end
end
