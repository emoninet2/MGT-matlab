classdef musicalgesture < mgobject
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = musicalgesture(f, varargin)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            %obj.Property1 = inputArg1 + inputArg2;
            obj=obj@mgobject(f,varargin);
            %obj=obj@mgmotion(f,varargin);
            %obj=obj@mghistory(f,varargin);
            %obj=obj@mgaverage(f,varargin);
            
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
            
        end
        
        function out = foo(self,arg1, arg2)
            out =  arg2 + arg1;
        end

    
        
        
    end
end

