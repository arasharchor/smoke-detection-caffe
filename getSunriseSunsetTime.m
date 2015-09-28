tic
clear all;
addpath(genpath('libs'));

date_start = '2014-10-01';
date_end = '2016-12-31';
date_start = datetime(date_start,'Format','yyyy-MM-dd');
date_end = datetime(date_end,'Format','yyyy-MM-dd');
date_all = date_start:date_end;
url_path = 'http://api.sunrise-sunset.org/json?lat=40.505911&lng=-80.06967&date=';

sun = containers.Map;
for i=1:numel(date_all)
    date = date_all(i);
    fprintf('Processing date %s\n',datestr(date));
    json = JSON.parse(urlread([url_path,datestr(date)]));
    sunrise = datestr(json.results.sunrise,'HH:MM:SS');
    sunset = datestr(json.results.sunset,'HH:MM:SS');
    obj.sunrise = sunrise;
    obj.sunset = sunset;
    sun(datestr(date,'yyyy-mm-dd')) = obj;
end

target_dir = 'frames';
save(fullfile(target_dir,'sun.mat'),'sun','-v7.3');

toc
