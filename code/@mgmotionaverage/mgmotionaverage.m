classdef mgmotionaverage
    %MGMOTIONAVERAGE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        file
        
    end
    
    methods
        function obj = mgmotionaverage(f,varargin)
            %MGMOTIONAVERAGE Construct an instance of this class
            %   Detailed explanation goes here
            %obj.Property1 = inputArg1 + inputArg2;
            obj.file = f;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            %outputArg = obj.Property1 + inputArg;
        end
        
        [outputArg1,outputArg2] = average(obj,varargin)
        
    end
end

