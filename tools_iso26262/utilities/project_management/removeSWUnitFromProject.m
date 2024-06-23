function removeSWUnitFromProject(modelName)
%removeSWUnitFromProject Remove folders for a software unit from project
%   Remove all design and verification models and folders for a software 
%   unit from project.
%
%   removeSWUnitFromProject(ModelName)

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

% Get the model folder.
prj = simulinkproject;

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
    error(['Unable to find ''', modelName, ''' in project.']);
end


% Add code verification results folders for the new model.

for dirIdx = 1:length(verifyResDirs)
    verifyResDirs{dirIdx} = fullfile(modelVerifyResDir,...
        verifyResDirs{dirIdx});
end

try
    % Remove folders from project path.
    modelRecDirStr = genpath(modelDir);
    modelRecDirs = regexp(modelRecDirStr, pathsep, 'split');
    modelRecDirs = modelRecDirs(~cellfun('isempty', modelRecDirs));
    for recDirIdx = 1:length(modelRecDirs)
        if isfolder(modelRecDirs{recDirIdx})
            prj.removePath(modelRecDirs{recDirIdx});
        end
    end
    
    testRecDirStr = genpath(modelVerifySpecsDir);
    testRecDirs = regexp(testRecDirStr, pathsep, 'split');
    testRecDirs = testRecDirs(~cellfun('isempty', testRecDirs));
    for recDirIdx = 1:length(testRecDirs)
        if isfolder(testRecDirs{recDirIdx})
            prj.removePath(testRecDirs{recDirIdx});
        end
    end
    
    for dirIdx = 1:length(verifyResDirs)
        codeRecDirStr = genpath(verifyResDirs{dirIdx});
        codeRecDirs = regexp(codeRecDirStr, pathsep, 'split');
        codeRecDirs = codeRecDirs(~cellfun('isempty', codeRecDirs));
        for recDirIdx = 1:length(codeRecDirs)
            if isfolder(codeRecDirs{recDirIdx})
                prj.removePath(codeRecDirs{recDirIdx});
            end
        end
    end
    
    if isfolder(modelDir)
        prj.removeFile(modelDir);
    end
    
    if isfolder(modelVerifySpecsDir)
        prj.removeFile(modelVerifySpecsDir);
    end
    
    for dirIdx = 1:length(verifyResDirs)
        if isfolder(verifyResDirs{dirIdx})
            prj.removeFile(verifyResDirs{dirIdx});
        end
    end
    prj.removeFile(modelVerifyResDir);
    
catch
    error(['Unable to remove ''', modelDir, ''' from project.']);
end

end
