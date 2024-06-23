function addSWCompToProject(modelName, asil, varargin)
%addSWCompToProject Create an empty software component in project
%   Create a new model folder containing an empty design model and empty
%   data dictionary associated with it and folders for its verification.
%   SW components are placed in the SW integration folder.
%   ASIL can be either 'QM'|'ASILA'|'ASILB'|'ASILC'|'ASILD'.
%   A thrid argument can be passed to specify if the model is
%   multi-instantiable.
%
%   addSWCompToProject(ModelName)
%   addSWCompToProject(ModelName, ASIL)
%   addSWCompToProject(ModelName, ASIL , 'Nonreusable')

%   Copyright 2021-2022 The MathWorks, Inc.

% Set slddLink to true to link model to data dictionary instead of using
% base workspace. Otherwise, set slddLink to false.
slddLink = true;
defaultASIL = 'ASILD';
if nargin < 1
    % Query for the model name if none is provided.
    modelName = char(inputdlg('Enter model name.', 'Model Name', [1 50]));
    if isempty(modelName)
        return;
    end
end

if nargin<2
    % Query the ASIL Level of the model
    asil = char(inputdlg('Enter ASIL Level', 'ASIL', [1 50], {defaultASIL}));
    if isempty(modelName)
        return;
    end
end

if nargin<3
    % Query if the model is multi-instantiable.
    reuse = strcmpi(questdlg('Is the model multi-instantiable?', 'Reusability', 'Yes', 'No', 'Yes'), 'Yes');
end

% Check if the model name is valid.
if ~isvarname(modelName)
    errordlg('Invalid model name.');
    return;
end

% Check if asil is a valid asil
asil = validateASIL(asil);

try
    % Close the model and data dictionary that may still linger in memory.
    bdclose(modelName);
    Simulink.data.dictionary.closeAll(['DD_', modelName, '.sldd'], '-discard');
catch
end

% Check if the model folder already exists.
if exist(modelName, 'dir')
    error(['Model folder ''', modelName, ''' already exists.']);
end

% Create design and verification folders.
addSWCompDesignFolder(modelName, reuse, slddLink, asil);
addSWCompVerifySpecsFolder(modelName, asil);
addSWCompVerifyResFolder(modelName, asil);

disp(['Added SW Component folders for  ''', ...
        modelName, ''' to project.']);
