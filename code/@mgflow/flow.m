function [retval,videoOut] = flow(obj,varargin)
%FLOW Summary of this function goes here
%   Detailed explanation goes here

disp('this is the flow function');


arg = [];

%default parameters
arg.mg = [];
arg.fileList = [];
arg.filterflag = 0;
arg.filtertype = 'Regular';
arg.thresh = 0.1;
arg.color = 'off';
arg.invert = 'off';
arg.frameInterval = obj.frameInterval;
arg.fileCount = length(obj.video);

if(arg.fileCount <= 1)
    arg.startTime = obj.startTime;
    arg.stopTime = obj.stopTime;
end

for argi = 1:nargin-1

    if (strcmpi(varargin{argi},'Color'))
        disp('color mode on is specified in argument');
        arg.color = 'on'
        if(argi + 1 <= nargin-1)
            if (strcmpi(varargin{argi+1},'off'))
                arg.color = 'off'
            elseif (strcmpi(varargin{argi+1},'on'))
                arg.color = 'on'
            end
        else
            arg.color = 'on'
        end
    elseif (strcmpi(varargin{argi},'Gray'))
        disp('color mode on is specified in argument');
        arg.color = 'off'
    elseif (strcmpi(varargin{argi},'invert'))
        disp('invert mode on is specified in argument');
        arg.invert = 'on'
    elseif (strcmpi(varargin{argi},'Interval'))
        if(argi + 1 <= nargin-1 &&  isnumeric(varargin{argi + 1}))
            arg.frameInterval = varargin{argi+1};
        end
    end
end

filterflag = [];
colorflag = [];
invertflag = [];

if(strcmpi(arg.color, 'on'))
    colorflag = true;
else
    colorflag = false;
end


if(strcmpi(arg.invert, 'on'))
    invertflag = true;
else
    invertflag = false;
end





if(arg.fileCount <= 1)
    
    obj.mg.video.gram.y = [];
    obj.mg.video.gram.x = [];
    obj.mg.video.qom = [];
    obj.mg.video.com = [];
    obj.mg.video.aom = [];
    obj.mg.video.wom = [];
    obj.mg.video.hom = [];

    
    [filepath,filename,ext] = fileparts(obj.video.Name);
    newfile = strcat(filename,'_flow.avi');
    v = VideoWriter(newfile);
    v.FrameRate = obj.video.FrameRate;
    open(v);
    
    fh = figure('visible','off');
    fr1 = rgb2gray(readFrame(obj.video));
    
    obj.video.CurrentTime = arg.startTime;
    numfr = obj.video.FrameRate*(arg.stopTime-arg.startTime);
    %obj.video.
    ii = 0;
    for i = 1:arg.frameInterval:numfr-1
        
        
        fr2 = rgb2gray(readFrame(obj.video));
        flow = mgopticalflow(fr2,fr1);
        magnitude = flow.Magnitude;
        if filterflag
            magnitude = mgmotionfilter(magnitude,filtertype,thresh);
        end
        qom = sum(sum(magnitude));
        [m,n] = size(magnitude);
        x = 1:n;
        y = 1:m;
        meanx = mean(magnitude);
        comx = x*meanx'/sum(meanx);
        meany = mean(magnitude,2);
        comy = y*meany/sum(meany);
        com = [comx,comy];
        gramx = mean(magnitude);
        gramy = mean(magnitude,2);
        
        obj.mg.video.gram.y = [obj.mg.video.gram.y;gramx];
        obj.mg.video.gram.x = [obj.mg.video.gram.x,gramy];
        obj.mg.video.qom = [obj.mg.video.qom;qom];
        obj.mg.video.com = [obj.mg.video.com;com];
        imshow(fr1),hold on;
        plot(flow,'DecimationFactor',[20 20],'ScaleFactor',10);
        hold off;
        writeVideo(v,getframe(fh));
        fr1 = fr2;
        progmeter(obj.video.CurrentTime,obj.stopTime);
        
        obj.video.CurrentTime = arg.startTime + (1/obj.video.FrameRate)*i;
    end
    close(v);
    disp(['The motion video is created with name ',newfile]);
    
    
else
    for fileIndex = 1:arg.fileCount
        obj.mg{fileIndex}.video.gram.y = [];
        obj.mg{fileIndex}.video.gram.x = [];
        obj.mg{fileIndex}.video.qom = [];
        obj.mg{fileIndex}.video.com = [];
        obj.mg{fileIndex}.video.aom = [];
        obj.mg{fileIndex}.video.wom = [];
        obj.mg{fileIndex}.video.hom = [];
        
        
        [filepath,filename,ext] = fileparts(obj.video{fileIndex}.Name);
        newfile = strcat(filename,'_flow.avi');
        v = VideoWriter(newfile);
        v.FrameRate = obj.video{fileIndex}.FrameRate;
        open(v);

        fh = figure('visible','off');
        fr1 = rgb2gray(readFrame(obj.video{fileIndex}));

        obj.video{fileIndex}.CurrentTime = obj.startTime{fileIndex};
        numfr = obj.video{fileIndex}.FrameRate*(obj.stopTime{fileIndex}-obj.startTime{fileIndex});
        %obj.video.
        ii = 0;
        for i = 1:arg.frameInterval:numfr-1


            fr2 = rgb2gray(readFrame(obj.video{fileIndex}));
            flow = mgopticalflow(fr2,fr1);
            magnitude = flow.Magnitude;
            if filterflag
                magnitude = mgmotionfilter(magnitude,filtertype,thresh);
            end
            qom = sum(sum(magnitude));
            [m,n] = size(magnitude);
            x = 1:n;
            y = 1:m;
            meanx = mean(magnitude);
            comx = x*meanx'/sum(meanx);
            meany = mean(magnitude,2);
            comy = y*meany/sum(meany);
            com = [comx,comy];
            gramx = mean(magnitude);
            gramy = mean(magnitude,2);

            obj.mg{fileIndex}.video.gram.y = [obj.mg{fileIndex}.video.gram.y;gramx];
            obj.mg{fileIndex}.video.gram.x = [obj.mg{fileIndex}.video.gram.x,gramy];
            obj.mg{fileIndex}.video.qom = [obj.mg{fileIndex}.video.qom;qom];
            obj.mg{fileIndex}.video.com = [obj.mg{fileIndex}.video.com;com];
            imshow(fr1),hold on;
            plot(flow,'DecimationFactor',[20 20],'ScaleFactor',10);
            hold off;
            writeVideo(v,getframe(fh));
            fr1 = fr2;
            progmeter(obj.video{fileIndex}.CurrentTime,obj.stopTime{fileIndex});

            obj.video{fileIndex}.CurrentTime = obj.startTime{fileIndex} + (1/obj.video{fileIndex}.FrameRate)*i;
        end
        close(v);
        disp(['The motion video is created with name ',newfile]);

    end
end



disp(arg);


end

