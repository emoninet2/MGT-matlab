function mg = mgvideofilter(varargin)
% mg = mgvideofilter(varargin)
% mgvideofilter performs a spatial filtering of the video
%
% syntax: mg = mgvideofilter(filename,type,med,h);
% mg = mgvideofilter(mg,type,med,h);
%
% input:
% filename: video file
% mg: input mg containing the video data;
% type: 'Spatial';
% med: 'Median', 'Average';
% h: element structure (pixels)
%
% output:
% mg: filtered video
%
% example:
% mg = mgvideofilter(videofile,’Spatial’,’Average’,[3,3]);
%
% todo:
% implement temporal filter
%
% also see:
% mgmotionaverage

if isempty(varargin)
    return;
end
l = length(varargin);
if l == 1
    type = 'Spatial';
    med = 'Median';
    value = [3 3];
elseif l >=4
    type = varargin{2};
    med = varargin{3};
    value = varargin{4};
end
if ischar(varargin{1})
    file = varargin{1};
    [~,pr,ex] = fileparts(file);
    if ismember(ex,{'.mp4';'.avi';'mpg';'mov';'m4v'})
        mg = mgvideoreader(file);
    else
        error('unknown video format,please the video format');
    end
elseif isstruct(varargin{1}) && isfield(varargin{1},'video')
    mg = varargin{1};
end
numf = floor(mg.video.obj.FrameRate*mg.video.obj.Duration);
newfile = strcat(pr,'filtervideo.avi');
if strcmpi(type,'Spatial')
    if strcmpi(med,'Median')
        v = VideoWriter(newfile);
        v.FrameRate = mg.video.obj.FrameRate;
        open(v);
        i = 1;
        while mg.video.obj.CurrentTime < mg.video.endtime
            progmeter(i,numf);
            tmp = readFrame(mg.video.obj);
            tmp(:,:,1) = medfilt2(tmp(:,:,1),value);
            tmp(:,:,2) = medfilt2(tmp(:,:,2),value);
            tmp(:,:,3) = medfilt2(tmp(:,:,3),value);
            writeVideo(v,tmp);
            i = i + 1;
        end
        close(v);
        s = mgvideoreader(newfile);
        mg.video.obj = s.video.obj;
        mg.type = 'mg data';
        mg.createtime = datestr(datetime('today'));
    elseif strcmpi(med,'Average')
        v = VideoWriter(newfile);
        v.FrameRate = mg.video.obj.FrameRate;
        open(v);
        i = 1;
        value = fspecial('average',value);
        while mg.video.obj.CurrentTime < mg.video.endtime
            progmeter(i,numf);
            tmp = readFrame(mg.video.obj);
            tmp = imfilter(tmp,value,'replicate');
            writeVideo(v,tmp);
            i = i + 1;
        end
        close(v);
        s = mgvideoreader(newfile);
        mg.video.obj = s.video.obj;
        mg.type = 'mg data';
        mg.createtime = datestr(datetime('today'));
    end
end
