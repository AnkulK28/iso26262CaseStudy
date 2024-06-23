function prjCleanup()
%prjCleanup Clean up environment
%   Restore the environment before exiting the current project. This
%   function is set to run at Shutdown.
%
%   prjCleanup()

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
    rmiReset();
end

% Close all test files and test results.
if iec.internal.license('test', 'Simulink Test')
    sltest.testmanager.clear();
    sltest.testmanager.clearResults();
    sltest.testmanager.close();
end

% Clear all coverage data.
if iec.internal.license('test', 'Simulink Coverage')
    cvexit();
end


% Restore default Model Advisor configuration
if iec.internal.license('test', 'Simulink Check')
    configFile = advisorConfigurationControl('get');
    if strcmp(configFile, ProjArtifacts.maUnitChecksJson) || ...
            strcmp(configFile, ProjArtifacts.maIntegrationChecksJson)
        advisorConfigurationControl('reset');
    end
end


if iec.internal.license('test', 'Simulink')
    % Reset the CacheFolder and CodeGenFolder back to the default.
    Simulink.fileGenControl('reset');
    % close all data dictionaries and discard changes made
    Simulink.data.dictionary.closeAll('-discard');
end

% Close the demo live script.
matlab.desktop.editor.findOpenDocument(which('runDemo.mlx')).closeNoPrompt();

% Clear the the MATLAB Command Window.
home();

end
