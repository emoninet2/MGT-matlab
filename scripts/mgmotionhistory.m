function mgOut = mgmotionhistory(varargin)
%function mgmotionhistory(vidfile,nframe,type,varargin)
% mgmotionhistory(vidfile,nframe,type,starttime,endtime)
% compute the motion history image.
%
% syntax:
% mgmotionhistory(vidfile) using defualt nframe = 5 to create grayscale motion
% history image
% mgmotionhistory(vidfile,nframe) using nframe to create grayscale motion
% image
% mgmotionhistory(vidfile,nframe,type,starttime,endtime)
%
% input:
% vidfile: video file name
% nframe: gives the number of frames to create motion history (default=20)
% type: 'gray' or 'color' (default='gray')
% starttime: starting time of the video to create motion history image
% endtime: end time of the video to create motion history image
%
% output: a history video written back to disk
%
% examples:
% mgmotionhistory(videofile,3,'gray',0,20)
% mgmotionhistory(videofile)
% mgmotionhistory(videofile,10,'color')

nargin = length(varargin);
if isempty(varargin)
    return;
end
f = varargin{1};

cmd = [];

if(ischar(f))
    disp('input is a file');

    [~,pr,ex] = fileparts(f);
    ex = lower(ex);
    if ismember(ex,{'.mp4';'.avi';'.mov';'.mpg';'.m4v'})
        mg = mgvideoreader(f);
        cmd.inputType = 'file';
    else
        disp('please input a video file!');
        return
    end

elseif isstruct(f) && isfield(f,'video')
    disp('input is mg struct');
    mg = f;
    cmd.inputType = 'struct';
else
    error('wrong input file, please check the format...');
end



cmd.starttime = mg.video.starttime;
cmd.endtime = mg.video.endtime;
cmd.nFrame = 20; %default fame number = 20;
cmd.color = 'off';
cmd.frameInterval = 1;

l = nargin;
for argi = 1:l
    if( ischar(varargin{argi}))
        if(argi == 1 ) %the file name is always the first element in the varargin
            if(argi + 1 <= l && isnumeric(varargin{argi + 1}))
                disp('starttime specified in argument');
                cmd.starttime = varargin{argi+1};
                if(argi + 2 <= l &&isnumeric(varargin{argi + 2}))
                    disp('stoptime specified in argument');
                    cmd.endtime = varargin{argi+2};
                end
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
            if(argi + 1 <= l &&  isnumeric(varargin{argi + 1}))
                cmd.frameInterval = varargin{argi+1};
            end
        end
    end
end


starttime = cmd.starttime;
endtime = cmd.endtime;
colorMode = cmd.color;
frameInterval = cmd.frameInterval;
nf = cmd.nFrame;

mg.video.obj.CurrentTime = starttime;
newfile = strcat(pr,'_history.avi');
v = VideoWriter(newfile);
v.FrameRate = mg.video.obj.FrameRate;
open(v);

if(strcmpi(cmd.color, 'on'))
    mg.video.obj.CurrentTime = starttime;
    temparray = zeros(mg.video.obj.Height,mg.video.obj.Width,3,nf-1,'uint8');
    %fr1 = readFrame(mg.video.obj);
    fr2 = readFrame(mg.video.obj);
    %diff = imsubtract(fr2,fr1);
    %temparray(:,:,:,1) = diff;
    %history = diff;
    %writeVideo(v,imadd(diff,fr2));

    disp('Creating motion history video:   ')
    numfr = mg.video.obj.FrameRate*(endtime-starttime)-nf;
    %while mg.video.obj.CurrentTime < endtime

    for indf = nf:frameInterval:numfr
        progmeter(indf,numfr)
        temparray = temparray(:,:,:,[2:end 1]);
        nextf = readFrame(mg.video.obj);
        temp = imsubtract(nextf,fr2);
        fr2 = nextf;
        temparray(:,:,:,end) = temp;
        history = uint8(sum(temparray,4));
        writeVideo(v,imadd(history,nextf));
        mg.video.obj.CurrentTime = (1/mg.video.obj.FrameRate)*indf;
    end

elseif(strcmpi(cmd.color, 'off'))
    mg.video.obj.CurrentTime = starttime;
    temparray = zeros(mg.video.obj.Height,mg.video.obj.Width,nf-1,'uint8');
    %fr1 = rgb2gray(readFrame(mg.video.obj));
    fr2 = rgb2gray(readFrame(mg.video.obj));
    %diff = imsubtract(fr2,fr1);
    %temparray(:,:,1) = diff;
    %history = diff;
    %writeVideo(v,imadd(diff,fr2));
    disp('Creating motion history video:   ')
    indf = nf;
    numfr = mg.video.obj.FrameRate*(endtime-starttime)-nf;
    %while mg.video.obj.CurrentTime < endtime

    for indf = nf:frameInterval:numfr
        progmeter(indf,numfr);
        temparray = temparray(:,:,[2:end 1]);
        nextf = rgb2gray(readFrame(mg.video.obj));
        temp = imsubtract(nextf,fr2);
        fr2 = nextf;
        temparray(:,:,end) = temp;
        history = uint8(sum(temparray,3));
        writeVideo(v,imadd(history,nextf));

        mg.video.obj.CurrentTime = (1/mg.video.obj.FrameRate)*indf;

    end
end



disp(' ')
disp(['The motion history video is created with name ',newfile]);
close(v)


return;

%
% if nargin == 1 && ischar(f) %if input is a file
%     file = vidfile;
%     [~,pr,ex] = fileparts(file);
%     ex = lower(ex);
%     if ismember(ex,{'.mp4';'.avi';'.mov';'.mpg';'.m4v'})
%         mg = mgvideoreader(file);
%     else
%         disp('please input a video file!');
%         return
%     end
%     nf = 20;
%     method = 'gray';
%     starttime = mg.video.starttime;
%     endtime = mg.video.endtime;
% elseif nargin == 2 && ischar(vidfile)
%     file = vidfile;
%     if ischar(nframe)
%         nf = 20;
%         method = nframe;
%     else
%         method = 'gray';
%         nf = nframe;
%     end
%     [~,pr,ex] = fileparts(file);
%     ex = lower(ex);
%     if ismember(ex,{'.mp4';'.avi';'.mov';'.mpg';'.m4v'})
%         mg = mgvideoreader(file);
%     else
%         disp('please input a video file!');
%         return
%     end
%     starttime = mg.video.starttime;
%     endtime = mg.video.endtime;
% elseif nargin == 3 && ischar(vidfile)
%     file = vidfile;
%     nf = nframe;
%     [~,pr,ex] = fileparts(file);
%     if ismember(ex,{'.mp4';'.avi';'.mov';'.mpg';'.m4v'})
%         mg = mgvideoreader(file);
%     else
%         disp('please input a video file!');
%         return
%     end
%     if ischar(type)
%         method = type;
%     else
%         disp('please input a proper type: gray or color');
%         return
%     end
%     starttime = mg.video.starttime;
%     endtime = mg.video.endtime;
% elseif nargin == 5 && ischar(vidfile)
%     file = vidfile;
%     nf = nframe;
%     [~,pr,ex] = fileparts(file);
%     if ismember(ex,{'.mp4';'.avi';'.mov';'.mpg';'.m4v'})
%         mg = mgvideoreader(file);
%     else
%         disp('please input a video file!');
%         return
%     end
%     if ischar(type)
%         method = type;
%     else
%         disp('please input a proper type: gray or color');
%         return
%     end
%     if length(varargin) == 1
%         starttime = varargin{1};
%         endtime = mg.video.endtime;
%     elseif length(varargin) == 2
%         starttime = varargin{1};
%         endtime = varargin{2};
%     end
% end
%
% mg.video.obj.CurrentTime = starttime;
% newfile = strcat(pr,'_history.avi');
% v = VideoWriter(newfile);
% v.FrameRate = mg.video.obj.FrameRate;
% open(v);
% if strcmpi(method,'gray')
%     temparray = zeros(mg.video.obj.Height,mg.video.obj.Width,nf-1,'uint8');
%     fr1 = rgb2gray(readFrame(mg.video.obj));
%     fr2 = rgb2gray(readFrame(mg.video.obj));
%     diff = imsubtract(fr2,fr1);
%     temparray(:,:,1) = diff;
%     history = diff;
%     writeVideo(v,imadd(diff,fr2));
%     for i = 1:nf-2
%         nextf = rgb2gray(readFrame(mg.video.obj));
%         temp = imsubtract(nextf,fr2);
%         fr2 = nextf;
%         temparray(:,:,i+1) = temp;
%         history = imadd(temp,history);
%         writeVideo(v,imadd(history,nextf));
%     end
%     disp('Creating motion history video: ')
%     while mg.video.obj.CurrentTime < endtime
% %        progmeter(indf,numfr)
%         temparray = temparray(:,:,[2:end 1]);
%         nextf = rgb2gray(readFrame(mg.video.obj));
%         temp = imsubtract(nextf,fr2);
%         fr2 = nextf;
%         temparray(:,:,end) = temp;
%         history = uint8(sum(temparray,3));
%         writeVideo(v,imadd(history,nextf));
%     end
% elseif strcmpi(method,'color')
%     temparray = zeros(mg.video.obj.Height,mg.video.obj.Width,3,nf-1,'uint8');
%     fr1 = readFrame(mg.video.obj);
%     fr2 = readFrame(mg.video.obj);
%     diff = imsubtract(fr2,fr1);
%     temparray(:,:,:,1) = diff;
%     history = diff;
%     writeVideo(v,imadd(diff,fr2));
%     for i = 1:nf-2
%         nextf = readFrame(mg.video.obj);
%         temp = imsubtract(nextf,fr2);
%         fr2 = nextf;
%         temparray(:,:,:,i+1) = temp;
%         history = imadd(temp,history);
%         writeVideo(v,imadd(history,nextf));
%     end
%     disp('Creating motion history video: ')
%     indf = 1;
%     numfr = mg.video.obj.FrameRate*(endtime-starttime)-nf;
%     while mg.video.obj.CurrentTime < endtime
%         progmeter(indf,numfr)
%         temparray = temparray(:,:,:,[2:end 1]);
%         nextf = readFrame(mg.video.obj);
%         temp = imsubtract(nextf,fr2);
%         fr2 = nextf;
%         temparray(:,:,:,end) = temp;
%         history = uint8(sum(temparray,4));
%         writeVideo(v,imadd(history,nextf));
%         indf = indf + 1;
%     end
% end
% disp(' ')
% disp(['The motion history video is created with name ',newfile]);
% close(v)