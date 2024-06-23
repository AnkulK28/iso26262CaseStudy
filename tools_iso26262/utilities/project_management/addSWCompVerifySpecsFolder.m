function addSWCompVerifySpecsFolder(modelName, asil)
%addSWCompVerifySpecsFolder Create empty test suite for verification specs 
%   Create empty test files for verfification specification in project for 
%   a software component and place these in the corresponding verification
%   specification folders.
%   ASIL can be either 'QM'|'ASILA'|'ASILB'|'ASILC'|'ASILD'.
%
%   addSWCompVerifySpecsFolder(ModelName, ASIL)

%   Copyright 2021 The MathWorks, Inc.

testCasesDir = ProjArtifacts.getCompVerSpecPath(modelName);

if ~isfolder(testCasesDir)
    mkdir(testCasesDir);
end

createTestSuiteForModel(modelName, asil, false);  %the component is not atomic 

prj = simulinkproject;
try
    prj.addFolderIncludingChildFiles(testCasesDir);
    prj.addPath(testCasesDir);
    subFolder = prj.findFile(testCasesDir);
    subFolder.addLabel('ASIL', asil);
catch
    error(['Unable to add verification specs folder for  ''', ...
        modelName, ''' to project.']);
end