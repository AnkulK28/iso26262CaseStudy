function resetWorkspace()
%resetWorkspace Reset workspace to startup condition
%   Clear all variables in the workspace except the default model
%   configurations.
%
%   resetWorkspace()

%   Copyright 2019 The MathWorks, Inc.

% Set slddLink to true to link model to data dictionary instead of using
% base workspace. Otherwise, set slddLink to false.
slddLink = true;

% Clear the workspace.
evalin('base', 'clear;');

if ~slddLink
    % Load model configurations into base worksapce if model configurations
    % are defined using MATLAB data files instead of Simulink data
    % dictionary files.
    evalin('base', 'nonreusableModelConfig;');
    evalin('base', 'reusableModelConfig;');
end

end
