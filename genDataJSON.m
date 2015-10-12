tic
clear all;
addpath(genpath('libs'));
addpath(genpath('util'));

date_start = '2015-05-01';
date_end = '2015-05-09';
date_start = datetime(date_start,'Format','yyyy-MM-dd');
date_end = datetime(date_end,'Format','yyyy-MM-dd');
date_all = date_start:date_end;
data = struct();
data.channel_names = cell(1,2);
data.channel_names{1} = 'smoke_level';
data.channel_names{2} = '';
target_dir = 'frames';
smoke = [];

for idx=1:numel(date_all)
    date_str = datestr(date_all(idx),'yyyy-mm-dd');
    fprintf('Processing date %s\n',date_str);
    
    % set data source
    date_path = [date_str,'.timemachine/'];
    dataset_path = 'crf26-12fps-1424x800/';
    tile_path = '1/2/2.mp4';
    path = fullfile(target_dir,date_path,dataset_path,tile_path);
    
    % load info and prediction
    load(fullfile(path,'info.mat'));
    load(fullfile(path,'response.mat'));
    load(fullfile(path,'sun_frame.mat'));
    datetime_all = posixtime(datetime(tm_json.capture_times));
    datetime_all = datetime_all';
    datetime_all = datetime_all(sunrise_frame:sunset_frame);
    response = response(sunrise_frame:sunset_frame);
    format longG
    smoke = cat(1,smoke,cat(2,datetime_all,response));
end

data.data = smoke;
savejson('',data,'json/data.json');

fprintf('Done\n');
toc