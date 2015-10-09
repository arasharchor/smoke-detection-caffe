clear all;
addpath(genpath('libs'));

url = 'https://esdr.cmucreatelab.org/oauth/token';
auth = fileread('auth_esdr.json');
response = webwrite(url,auth);