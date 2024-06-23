function addSWCompVerifyResFolder(modelName, asil)
%addSWCompVerifyResFolder Create empty folders for verification results 
%   Create empty verification results folders in project for a software
%   Component. These cover static and dynamic verification steps.
%   ASIL can be either 'QM'|'ASILA'|'ASILB'|'ASILC'|'ASILD'.
%
%   addSWCompToProject(ModelName, ASIL)
%   addSWCompToProject(ModelName, ASIL , 'Nonreusable')

%   Copyright 2021 The MathWorks, Inc.
resultDirs = getASILVerifyResDirs();

% Add code verification results folders for the new model.
modelVerifyResDirName = ProjArtifacts.getCompVerResultsPath(modelName);
for dirIdx = 1:length(resultDirs)
    temp = resultDirs{dirIdx};
    resultDirs{dirIdx} = fullfile(modelVerifyResDirName, ...
        temp);
    mkdir(resultDirs{dirIdx});
    createReadmeFile(resultDirs{dirIdx}, temp);
end

prj = simulinkproject;

try
    for dirIdx = 1:length(resultDirs)
        prj.addFolderIncludingChildFiles(resultDirs{dirIdx});
        prj.addFile(fullfile(resultDirs{dirIdx},'readme.txt'));
    end
   
    
    % Add new folders to project path.
    modelPaths = genpath(modelVerifyResDirName);
    resultDirs = regexp(modelPaths, pathsep, 'split');
    for dirIdx = 1:length(resultDirs)
        if isfolder(resultDirs{dirIdx})
            prj.addPath(resultDirs{dirIdx});
        end
    end
    
    prj.addPath(modelVerifyResDirName);
    
    for dirIdx = 1:length(resultDirs)
        if isfolder(resultDirs{dirIdx})
            subFolder = prj.findFile(resultDirs{dirIdx});
            subFolder.addLabel('ASIL', asil);
        end
    end
    subFolder = prj.findFile(modelVerifyResDirName);
    subFolder.addLabel('ASIL', asil);
catch
        error(['Unable to add verification results folder for  ''', ...
        modelName, ''' to project.']);
end