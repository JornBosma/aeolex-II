function AeolusInit

% define global variables
global basePath;

% set base path. All subdirectories are branches from the base path.
basePath = strrep(which('AeolusInit'),'AeolusInit.m','');

% add paths
addpath(basePath);
addpath(genpath([basePath '../data']));
addpath(genpath([basePath '../results']));

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