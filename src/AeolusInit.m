function AeolusInit

% define global variables
global basePath;

% set base path. All subdirectories are branches from the base path.
basePath = strrep(which('AeolusInit'),'AeolusInit.m','');

% add paths
addpath(basePath);
% addpath(genpath([basePath 'code']));
% addpath(genpath([basePath 'GerbenCode']));
% addpath(genpath([basePath 'db']));
addpath(genpath([basePath '../data']));
addpath(genpath([basePath '../results']));

% addpath(genpath('/Users/jwb/Documents/MATLAB/Add-Ons/'));

% set default settings
set(groot,'defaultTextInterpreter','latex');
set(groot,'defaultAxesTickLabelInterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');
set(groot,'defaultAxesFontSize',36);
set(groot,'defaultLegendLocation','northwest');
set(groot,'defaultLegendBox','off');
set(groot,'defaultAxesBox','off');

% ready
return;