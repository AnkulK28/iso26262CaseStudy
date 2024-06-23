function varargout = verifyObjCode2Reqs(modelName, mode, cov, top, varargin)
%verifySrcCode2Reqs Verify generated code against requirements
%   Verify if the generated code complies with the high-level software
%   requirements, and then perform code coverage analysis. All tests
%   exercise the compiled code on either the host computer via SIL
%   simulations or the target computer via PIL simulations.
%
%   verifyObjCode2Reqs(ModelName, 'SIL')
%   verifyObjCode2Reqs(ModelName, 'PIL')
%   verifyObjCode2Reqs(ModelName, 'SIL', 'DisableCoverage')
%   verifyObjCode2Reqs(ModelName, 'PIL', 'DisableCoverage')
%   verifyObjCode2Reqs(ModelName, 'SIL', 'DisableCoverage', 'TreatAsTopMdl')
%   verifyObjCode2Reqs(ModelName, 'PIL', 'DisableCoverage', 'TreatAsTopMdl')
%   verifyObjCode2Reqs(ModelName, 'SIL', 'DisableCoverage', 'TreatAsTopMdl', AuthorNames)
%   verifyObjCode2Reqs(ModelName, 'PIL', 'DisableCoverage', 'TreatAsTopMdl', AuthorNames)
%   verifyObjCode2Reqs(ModelName, 'SIL', 'DisableCoverage', 'TreatAsTopMdl', AuthorNames, 'CI')
%   verifyObjCode2Reqs(ModelName, 'PIL', 'DisableCoverage', 'TreatAsTopMdl', AuthorNames, 'CI')
%   verifyObjCode2Reqs(ModelName, 'SIL', 'DisableCoverage', 'TreatAsTopMdl', [], 'CI')
%   verifyObjCode2Reqs(ModelName, 'PIL', 'DisableCoverage', 'TreatAsTopMdl', [], 'CI')
%   verifyObjCode2Reqs(ModelName, 'SIL', 'DisableCoverage', [], AuthorNames, 'CI')
%   verifyObjCode2Reqs(ModelName, 'PIL', 'DisableCoverage', [], AuthorNames, 'CI')
%   verifyObjCode2Reqs(ModelName, 'SIL', [], 'TreatAsTopMdl', AuthorNames, 'CI')
%   verifyObjCode2Reqs(ModelName, 'PIL', [], 'TreatAsTopMdl', AuthorNames, 'CI')
%   verifyObjCode2Reqs(ModelName, 'SIL', [], [], AuthorNames, 'CI')
%   verifyObjCode2Reqs(ModelName, 'PIL', [], [], AuthorNames, 'CI')
%   verifyObjCode2Reqs(ModelName, 'SIL', [], [], [], 'CI')
%   verifyObjCode2Reqs(ModelName, 'PIL', [], [], [], 'CI')

%   Copyright 2021-2022 The MathWorks, Inc.

if ~iec.internal.license('test','Simulink Test')
    MSLDiagnostic('certqualkit:engine:SLTESTMissLicense').reportAsError;
end
if ~iec.internal.license('test','Simulink Coverage')
    MSLDiagnostic('certqualkit:engine:SLCOVMissLicense').reportAsError;
end
if ~iec.internal.license('test', 'Embedded Coder')
    MSLDiagnostic('certqualkit:engine:ECMissLicense').reportAsError;
end

% Close all models.
if iec.internal.license('test', 'Simulink')
    bdclose('all');
end

% Clear all coverage data.
cvexit();

% Administer options.
if nargin < 2
    error('Simulation mode not specified.');
else
    if strcmpi(mode, 'SIL')
        mode = 'SIL';
        target = 'Software-in-the-Loop (SIL)';
    elseif strcmpi(mode, 'PIL')
        mode = 'PIL';
        target = 'Processor-in-the-Loop (PIL)';
    else
        error('Simulation mode must be either SIL or PIL.');
    end
end
if nargin > 2 && ~isempty(cov)
    % Suppress coverage via override.
    disableCoverage = true;
else
    disableCoverage = false;
end
if nargin > 3 && ~isempty(top)
    isTop = true;
else
    isTop = false;
end

% Check for prerequisites.
modelTestFile = ProjArtifacts.getUnitRBTTestFile(modelName);
if ~exist(modelTestFile, 'file')
    error(['Test file ''', modelTestFile, ' not found.']);
end

% Get model information.
% If any of the test case in the test file needs to perform a load_system
% on the test harness, querying the checksum after loading the test file
% leads to an error. To avoid the potential error, get the checksum
% information before loading the test file.
load_system(modelName);
modelVersion = get_param(modelName, 'ModelVersion');
modifiedDate = get_param(modelName, 'LastModifiedDate');
if isTop
    modelChecksum = getModelChecksum(modelName, 'TreatAsTopMdl');
else
    modelChecksum = getModelChecksum(modelName);
end

% Verify the generated code against HLR test cases in the test file.
disp(['Running ', mode, ' tests on generated code of Simulink model ', modelName, '.']);
sltest.testmanager.clear();
sltest.testmanager.clearResults();
testFile = sltest.testmanager.load(modelTestFile);

% change test environment to SIL or PIL
for testSuite = testFile.getTestSuites
    testCases = testSuite.getTestCases;
    for caseIdx = 1:length(testCases)
        testCases(caseIdx).setProperty('SimulationMode', target);
        if isTop
            callback = testCases(caseIdx).getProperty('PostloadCallback');
            callback = [callback, sprintf('\nmodelBlk = find_system(sltest_bdroot,''MatchFilter'',@Simulink.match.activeVariants, ''BlockType'', ''ModelReference'', ''Name'', sltest_sut);')];
            callback = [callback, sprintf('\nset_param(modelBlk{1}, ''CodeInterface'', ''Top model'');\n')];
            testCases(caseIdx).setProperty('PostloadCallback', callback);
        end
    end
end
if disableCoverage
    testFile.getCoverageSettings.MdlRefCoverage = false;
end
testResult = testFile.run;

% Attach model and code checksum information to test results.
if isTop
    checksumStr = sprintf(['Model Version: ', modelVersion, '\n\n', ...
        'Model Last Modified On: ', datestr(modifiedDate(5:end), 'dd-mmm-yyyy HH:MM:SS'), '\n\n', ...
        'Checksum when Compiled as Top Model: ', num2str(modelChecksum'), '\n\n', ...
        'Verified Code Files Checksum: ', strjoin(getCodeFileChecksum(modelName, 'TreatAsTopMdl')')]);
else
    checksumStr = sprintf(['Model Version: ', modelVersion, '\n\n', ...
        'Model Last Modified On: ', datestr(modifiedDate(5:end), 'dd-mmm-yyyy HH:MM:SS'), '\n\n', ...
        'Checksum when Compiled as Referenced Model: ', num2str(modelChecksum'), '\n\n', ...
        'Verified Code Files Checksum: ', strjoin(getCodeFileChecksum(modelName)')]);
end
testResult.getTestFileResults.Description = checksumStr;

% Check if code is instrumented for coverage analysis.
if ~isempty(testResult.CoverageResults)
    instr = ' INSTR';
    isInstrumented = true;
else
    instr = '';
    isInstrumented = false;
end

% Capture useful folder/file paths and names.

resultFile = ProjArtifacts.getUnitSPILRBTResFile(modelName, mode, isInstrumented);
rptFile = ProjArtifacts.getUnitSPILRBTResPDF(modelName, mode, isInstrumented);
cvtFile = ProjArtifacts.getUnitRBTCCovCvt(modelName, mode);
htmlFile = ProjArtifacts.getUnitRBTCCovHTML(modelName, mode);

testResultDir = fileparts(resultFile); 
covDir = fileparts(cvtFile);

% Delete the old result folders if they exist, then recreate the folders.
if exist(testResultDir, 'dir')
    rmdir(testResultDir, 's');
end
mkdir(testResultDir);
if ~isempty(testResult.CoverageResults)
    if exist(covDir, 'dir')
        rmdir(covDir, 's');
    end
    mkdir(covDir);
end

% Save test results.
sltest.testmanager.exportResults(testResult, resultFile);

% Save coverage results.
if ~isempty(testResult.CoverageResults)
    cvsave(cvtFile, cv.cvdatagroup(testResult.CoverageResults));
end

if nargin > 4 && ~isempty(varargin{1})
    authors = varargin{1};
else
    authors = '';
end
if nargin > 5 && ~isempty(varargin{2})
    LaunchReport = false;
    cvhtmlOption = '-sRT=0';
    result.Method = 'verifyObjCode2Reqs';
    result.Component = modelName;
    result.NumTotal = testResult.getTestFileResults().NumTotal;
    result.NumPass = testResult.getTestFileResults().NumPassed;
    result.NumWarn = testResult.getTestFileResults().NumIncomplete;
    result.NumFail = testResult.getTestFileResults().NumFailed;
    if result.NumFail > 0
        result.Outcome = -1;
    elseif result.NumWarn > 0
        result.Outcome = 0;
    else
        result.Outcome = 1;
    end
    if ~isempty(testResult.CoverageResults)
        cov = cv.cvdatagroup(testResult.CoverageResults);
        result.ExecutionCov = executioninfo(cov, modelName);
        result.DecisionCov = decisioninfo(cov, modelName);
        result.ConditionCov = conditioninfo(cov, modelName);
        result.MCDCCov = mcdcinfo(cov, modelName);
    end
    result.Results = testResult.getTestFileResults();
    varargout{1} = result;
else
    LaunchReport = true;
    cvhtmlOption = '-sRT=1';
end
% Generate the test report.
sltest.testmanager.report(testResult, rptFile, ...
    'Author', authors, ...
    'Title',[modelName, instr, ' ', mode, ' REQ-Based Tests'], ...
    'IncludeMLVersion', true, ...
    'IncludeTestRequirement', true, ...
    'IncludeSimulationSignalPlots', true, ...
    'IncludeComparisonSignalPlots', false, ...
    'IncludeErrorMessages', true, ...
    'IncludeTestResults', 0, ...
    'IncludeCoverageResult', true, ...
    'IncludeSimulationMetadata', true, ...
    'LaunchReport', LaunchReport);

% Generate the coverage report.
if ~isempty(testResult.CoverageResults)
    cvhtml(htmlFile, testResult.CoverageResults, cvhtmlOption);
end

% set test environment back to MIL
for testSuite = testFile.getTestSuites
    testCases = testSuite.getTestCases;
    for caseIdx = 1:length(testCases)
        testCases(caseIdx).Description = strrep(testCases(caseIdx).Description, [mode, ' test'],'Simulation test');
        testCases(caseIdx).setProperty('SimulationMode', '');
    end
end

end
