function deleteSWUnitFoldersFromFS(modelName)
%deleteSWUnitFoldersFromFS Delete all folders for a software unit from the file system.
%
%   deleteSWUnitFoldersFromFS(ModelName)

%   Copyright 2021-2022 The MathWorks, Inc.

if nargin < 1
    % Query for the model name if none is provided.
    modelName = char(inputdlg('Enter model name.', 'Model Name', [1 50]));
end
% Check if the model name is valid.
if ~isvarname(modelName)
    errordlg('Invalid model name.');
    return;
end

try
    % Close the model and data dictionary that may still linger in memory.
    bdclose(modelName);
    Simulink.data.dictionary.closeAll(['DD_', modelName, '.sldd'], '-discard');
catch
end


% Get the model folders.
verifyResDirs = getASILVerifyResDirs();

% Get model directory
if exist(ProjArtifacts.getUnitDesignPath(modelName), 'dir')
    modelDir = ProjArtifacts.getUnitDesignPath(modelName);
    modelVerifySpecsDir = ProjArtifacts.getUnitVerSpecPath(modelName);
    modelVerifyResDir = ProjArtifacts.getUnitVerResultsPath(modelName);
elseif exist(ProjArtifacts.getCompDesignPath(modelName), 'dir')
    modelDir = ProjArtifacts.getCompDesignPath(modelName);
    modelVerifySpecsDir = ProjArtifacts.getCompVerSpecPath(modelName);
    modelVerifyResDir = ProjArtifacts.getCompVerResultsPath(modelName);
else
    error(['Unable to find ''', modelName, ''' in FS.']);
end

% Add code verification results folders for the new model.
for dirIdx = 1:length(verifyResDirs)
    verifyResDirs{dirIdx} = fullfile(modelVerifyResDir,...
        verifyResDirs{dirIdx});
end

try
    % Delete folders from project.
    if exist(modelDir, 'dir')
        rmdir(modelDir, 's');
    end
    
    for dirIdx = 1:length(verifyResDirs)
        if exist(verifyResDirs{dirIdx}, 'dir')
            rmdir(verifyResDirs{dirIdx}, 's');
        end
    end
    if exist(modelVerifyResDir, 'dir')
        rmdir(modelVerifyResDir, 's');
    end
    
    if exist(modelVerifySpecsDir, 'dir')
        rmdir(modelVerifySpecsDir, 's');
    end   
catch
    error(['Unable to delete ''', modelDir, ''' from project.']);
end

end
