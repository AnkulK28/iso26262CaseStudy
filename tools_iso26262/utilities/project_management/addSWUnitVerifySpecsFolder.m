function addSWUnitVerifySpecsFolder(modelName, asil)
%addSWUnitVerifySpecsFolder Create empty test suite for verification specs 
%   Create empty test files for verfification specification in project 
%   for a software unit and place these in the corresponding verification
%   specification folders.
%   asil can be either 'QM'|'ASILA'|'ASILB'|'ASILC'|'ASILD'.
%
%   addSWUnitVerifySpecsFolder(ModelName, ASIL)

%   Copyright 2021 The MathWorks, Inc.

testCasesDir = ProjArtifacts.getUnitVerSpecPath(modelName);

if ~isfolder(testCasesDir)
    mkdir(testCasesDir);
end

createTestSuiteForModel(modelName, asil);

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