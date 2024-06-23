function prjSetup()
%prjSetup Set up environment
%   Customize the environment for the current project. This function is set
%   to run at Startup.
%
%   prjSetup()

%   Copyright 2021-2023 The MathWorks, Inc.

% Clear the workspace.
evalin('base', 'clear;');

% Close all figures.
close('all');

% Close all models.
if iec.internal.license('test', 'Simulink')
    bdclose('all');
end

% Close all requirement and link sets.
if iec.internal.license('test', 'Requirements Toolbox')
    slreq.clear();
end

% Close all test files and test results.
if iec.internal.license('test', 'Simulink Test')
    sltest.testmanager.clear();
    sltest.testmanager.clearResults();
end

% Clear all coverage data.
if iec.internal.license('test', 'Simulink Coverage')
    cvexit();
end

% Set slddLink to true to link model to data dictionary instead of using
% base workspace. Otherwise, set slddLink to false.
slddLink = true;

% Specify the folders where simulation and code generation artifacts are
% placed. Simulation and code generation artifacts are placed in
% CacheFolder and CodeGenFolder, respectively. For convenience, set
% CacheFolder to the working directory.

if ~exist(ProjArtifacts.cachePath, 'dir')
    mkdir(ProjArtifacts.cachePath);
end
if ~exist(ProjArtifacts.workPath, 'dir')
    mkdir(ProjArtifacts.workPath);
end

Simulink.fileGenControl('set', ...
    'CacheFolder', ProjArtifacts.cachePath, ...
    'CodeGenFolder', ProjArtifacts.unitCodeGenPath, ...
    'createDir',true );

% CD to the working directory if not running in batch mode.
if ~batchStartupOptionUsed
    cd(ProjArtifacts.workPath);
end

if ~slddLink
    % Load model configurations into base worksapce if model configurations
    % are defined using MATLAB data files instead of Simulink data
    % dictionary files.
    evalin('base', 'nonreusableModelConfig;');
    evalin('base', 'reusableModelConfig;');
end

% Set up RMI.
if iec.internal.license('test', 'Requirements Toolbox')
    rmiSetup();
end

% Add custom Model Advisor checks.
if iec.internal.license('test', 'Simulink Check')
    Advisor.Manager.refresh_customizations;
end

% Refresh all customizations
sl_refresh_customizations();
end
