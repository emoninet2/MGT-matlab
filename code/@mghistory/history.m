function [retval,videoOut] = history(obj, varargin)
%HISTORY Summary of this function goes here
%   Detailed explanation goes here


cmd = [];
cmd.nFrame = 20; %default fame number = 20;
cmd.color = 'off';
cmd.frameInterval = 1;
cmd.fileCount = length(obj.video);
cmd.startTime = [];
cmd.stopTime = [];
cmd.fileCount = length(obj.video);



if(cmd.fileCount <= 1)
    cmd.startTime = 0;
    cmd.stopTime = obj.video.Duration;
else
    
    
end



for argi = 1:nargin-1
    
    if( ischar(varargin{argi}))
        if (strcmpi(varargin{argi},'startTime'))
            if(cmd.fileCount <= 1)
                disp('start time specified');
                cmd.startTime = varargin{argi+1};
            end
        elseif (strcmpi(varargin{argi},'stopTime'))
            if(cmd.fileCount <= 1)
                disp('stop time specified');
                cmd.stopTime = varargin{argi+1};
            end
        elseif (strcmpi(varargin{argi},'nFrame'))
            disp('nframe specified');
            cmd.nFrame = varargin{argi+1};
        elseif (strcmpi(varargin{argi},'Color'))
            disp('color mode on is specified in argument');
            cmd.color = 'on'
        elseif (strcmpi(varargin{argi},'Gray'))
            disp('color mode on is specified in argument');
            cmd.color = 'off'
        elseif (strcmpi(varargin{argi},'Interval'))
            if(argi + 1 <= nargin &&  isnumeric(varargin{argi + 1}))
                cmd.frameInterval = varargin{argi+1};
            end
        end
    end
end




if(cmd.fileCount <= 1)
    
    [~,pr,ex] = fileparts(obj.video.Name);
    newfile = strcat(pr,'_history.avi');
    v = VideoWriter(newfile);
    v.FrameRate = obj.video.FrameRate;
    open(v);
    
    obj.video.CurrentTime = cmd.startTime;
    
    
    if(strcmpi(cmd.color, 'on'))
        temparray = zeros(obj.video.Height,obj.video.Width,3,cmd.nFrame-1,'uint8');
        prevFrame = readFrame(obj.video);
        numfr = obj.video.FrameRate*(cmd.stopTime-cmd.startTime)-cmd.nFrame;
        progmeter(0);
        for indf = 1:cmd.frameInterval:numfr-1
            progmeter(indf,numfr)
            temparray = temparray(:,:,:,[2:end 1]);
            currentFrame = readFrame(obj.video);
            temp = imsubtract(currentFrame,prevFrame);
            prevFrame = currentFrame;
            temparray(:,:,:,end) = temp;
            history = uint8(sum(temparray,4));
            writeVideo(v,imadd(history,currentFrame));
            obj.video.CurrentTime = cmd.startTime + (1/obj.video.FrameRate)*indf;
            
        end
        
    else
        temparray = zeros(obj.video.Height,obj.video.Width,cmd.nFrame-1,'uint8');
        prevFrame = rgb2gray(readFrame(obj.video));
        numfr = obj.video.FrameRate*(cmd.stopTime-cmd.startTime)-cmd.nFrame;
        progmeter(0);
        for indf = 1:cmd.frameInterval:numfr-1
            progmeter(indf,numfr)
            temparray = temparray(:,:,[2:end 1]);
            currentFrame = rgb2gray(readFrame(obj.video));
            temp = imsubtract(currentFrame,prevFrame);
            prevFrame = currentFrame;
            temparray(:,:,end) = temp;
            history = uint8(sum(temparray,3));
            writeVideo(v,imadd(history,currentFrame));
            obj.video.CurrentTime = cmd.startTime + (1/obj.video.FrameRate)*indf;
            
        end
    end
    
    
    close(v);
    %videoOut = VideoReader(newfile);
    retval = 0;
    
    
    
else
    
    
    for i=1:cmd.fileCount
        [~,pr,ex] = fileparts(obj.video{i}.Name);
        newfile = strcat(pr,'_history.avi');
        v = VideoWriter(newfile);
        v.FrameRate = obj.video{i}.FrameRate;
        open(v);
        
        obj.video{i}.CurrentTime = 0;
        cmd.startTime = 0;
        cmd.stopTime = obj.video{i}.Duration;
        
        if(strcmpi(cmd.color, 'on'))
            temparray = zeros(obj.video{i}.Height,obj.video{i}.Width,3,cmd.nFrame-1,'uint8');
            prevFrame = readFrame(obj.video{i});
            numfr = obj.video{i}.FrameRate*(cmd.stopTime-cmd.startTime)-cmd.nFrame;
            progmeter(0);
            for indf = 1:cmd.frameInterval:numfr-1
                progmeter(indf,numfr)
                temparray = temparray(:,:,:,[2:end 1]);
                currentFrame = readFrame(obj.video{i});
                temp = imsubtract(currentFrame,prevFrame);
                prevFrame = currentFrame;
                temparray(:,:,:,end) = temp;
                history = uint8(sum(temparray,4));
                writeVideo(v,imadd(history,currentFrame));
                obj.video{i}.CurrentTime = cmd.startTime + (1/obj.video{i}.FrameRate)*indf;
                
            end
        else
            
            temparray = zeros(obj.video{i}.Height,obj.video{i}.Width,cmd.nFrame-1,'uint8');
            prevFrame = rgb2gray(readFrame(obj.video{i}));
            numfr = obj.video{i}.FrameRate*(cmd.stopTime-cmd.startTime)-cmd.nFrame;
            progmeter(0);
            for indf = 1:cmd.frameInterval:numfr-1
                progmeter(indf,numfr)
                temparray = temparray(:,:,[2:end 1]);
                currentFrame = rgb2gray(readFrame(obj.video{i}));
                temp = imsubtract(currentFrame,prevFrame);
                prevFrame = currentFrame;
                temparray(:,:,end) = temp;
                history = uint8(sum(temparray,3));
                writeVideo(v,imadd(history,currentFrame));
                obj.video{i}.CurrentTime = cmd.startTime + (1/obj.video{i}.FrameRate)*indf;
                
            end
        end
        
    end
    
end





