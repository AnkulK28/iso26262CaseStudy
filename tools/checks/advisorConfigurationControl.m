function configFile = advisorConfigurationControl(method, configFile)
%advisorConfigurationControl Manage default Model Advisor configuration
%   Manage the default Model Advisor configuration.

%   Copyright 2021 The MathWorks, Inc.

switch lower(method)
    case 'get'
        % Get the default Model Advisor configuration file from user
        % preferences.
        configFile = '';
        prefFile = fullfile(prefdir, 'mdladvprefs.mat');
        if exist(prefFile, 'file')
            preferences = load(prefFile);
            if isfield(preferences, 'ConfigPrefs') && isfield(preferences.ConfigPrefs, 'FilePath')
                configFile = preferences.ConfigPrefs.FilePath;
            end
        end
    case 'set'
        % Set the default Model Advisor configuration file to user
        % preferences.
        configFile = setConfig(configFile);
    case 'reset'
        % Clear the default Model Advisor configuration file from user
        % preferences.
        configFile = setConfig('');
    otherwise
        % Do nothing.
end

end

function configFile = setConfig(configFile)
if ~contains(configFile, filesep)
    configFile = which(configFile);
end
prefFile = fullfile(prefdir, 'mdladvprefs.mat');
if exist(prefFile, 'file')
    load(prefFile, 'ConfigPrefs');
end
ConfigPrefs.FilePath = configFile;
if exist(prefFile, 'file')
    save(prefFile, 'ConfigPrefs', '-append');
else
    save(prefFile, 'ConfigPrefs');
end

end
