clear all;
addpath(genpath('libs'));
addpath(genpath('util'));

% date = {'2015-05-01','2015-05-02','2015-05-03'};
% date = {'2015-05-04','2015-05-05','2015-05-06','2015-05-07','2015-05-08','2015-05-09'};
date = {'2015-01-26','2015-02-10','2015-03-06','2015-04-02','2015-05-27','2015-06-11','2015-07-08','2015-08-13','2015-09-09'};
% date = {'2015-01-30','2015-02-26','2015-03-17','2015-04-22','2015-05-22','2015-06-23','2015-07-27','2015-08-25','2015-09-20'};

for idx=1:numel(date)
    % set data source
    url_path = 'http://tiles.cmucreatelab.org/ecam/timemachines/shenango1/';
    date_path = [date{idx},'.timemachine/'];
    dataset_path = 'crf26-12fps-1424x800/';
    tile_path = '1/2/2.mp4';

    % download video and related information
    fprintf('Downloading video\n');
    tilename = [date{idx},'-tile.mp4'];
    urlwrite(strcat(url_path,date_path,dataset_path,tile_path),tilename);
    tm_json = JSON.parse(urlread(strcat(url_path,date_path,'tm.json')));
    r_json = JSON.parse(urlread(strcat(url_path,date_path,dataset_path,'r.json')));

    % read video and create directory
    tile = VideoReader(tilename);
    target_dir = 'frames';
    path = fullfile(target_dir,date_path,dataset_path,tile_path);
    if ~exist(path,'dir')
        mkdir(path);
    end

    % compute first frame
    img_scale = 0.25;
    fprintf('Processing frame 1 of %s\n',date{idx});
    img = imresize(readFrame(tile),img_scale);
    img_height = size(img,1);
    img_width = size(img,2);
    data = zeros(img_height,img_width,3,r_json.frames,'uint8');
    label = false(img_height,img_width,1,r_json.frames);
    has_label = false(1,r_json.frames);
    label_simple = false(1,r_json.frames);
    label_simple = uint8(label_simple);
    data(:,:,:,1) = img;
    %imwrite(img,fullfile(path,strcat(num2str(i),'.png')),'png');

    % separate video into frames
    for i=2:r_json.frames
        fprintf('Processing frame %d of %s\n',i,date{idx});
        data(:,:,:,i) = imresize(readFrame(tile),img_scale);
        %imwrite(img,fullfile(path,strcat(num2str(i),'.png')),'png');
    end

    % delete video
    delete(tilename);
    
    % save files
    fprintf('Saving data.mat\n');
    save(fullfile(path,'data.mat'),'data','-v7.3');
%     fprintf('Saving label.mat\n');
%     save(fullfile(path,'label.mat'),'label','-v7.3');
%     fprintf('Saving has_label.mat\n');
%     save(fullfile(path,'has_label.mat'),'has_label','-v7.3');
    fprintf('Saving label_simple.mat\n');
    save(fullfile(path,'label_simple.mat'),'label_simple','-v7.3');
    fprintf('Saving file info.mat\n');
    save(fullfile(path,'info.mat'),'tm_json','r_json','url_path','dataset_path','tile_path','img_height','img_width');
    fprintf('Done\n');
end