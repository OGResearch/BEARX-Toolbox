%% Automatically generated BEARX Toolbox script 
%
% This script was generated based on the user input from the BEARX Toolbox
% Graphical User Interface. Feel free to edit and adapt it furthere to your
% needs.
%
% Generated ?TIMESTAMP?
%


%% Clear workspace 

% Clear all variables
clear

% Close all figures
close all

% Rehash Matlab search path
rehash path

% Import the correct module
import ?MODULE?.*


%% Define convenience functions for future use 

% User choice of percentiles
percentiles = ?PERCENTILES?;

% Create a percentiles function used to condense and report results
prctilesFunc = @(x) prctile(x, percentiles, 2);


%% Prepare output folder 

outputFolder = fullfile(".", ?OUTPUT_FOLDER?);
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end


%% Set up print functions 

printInfo = ?PRINT_INFO?;
printTable = ?PRINT_TABLE?;
printObject = ?PRINT_OBJECT?;


%% Prepare empty array of dummies 

dummyObjects = {};

