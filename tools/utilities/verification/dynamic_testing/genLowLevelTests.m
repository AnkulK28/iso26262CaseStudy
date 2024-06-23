function fullCovAlreadyAcheived = genLowLevelTests(modelName, varargin)
%genLowLevelTests Generate low-level test for model
%   Generate low-level tests for the model based on existing coverage data,
%   and then generate the Design Verifier report.
%
%   fullCovAlreadyAcheived = genLowLevelTests(ModelName)
%   fullCovAlreadyAcheived = genLowLevelTests(ModelName, 'ModelCoverageObjectives', 'Decision')
%   fullCovAlreadyAcheived = genLowLevelTests(ModelName, 'ModelCoverageObjectives', 'ConditionDecision')
%   fullCovAlreadyAcheived = genLowLevelTests(ModelName, 'ModelCoverageObjectives', 'MCDC')
%   fullCovAlreadyAcheived = genLowLevelTests(ModelName, 'ModelCoverageObjectives', 'MCDC', 'TestSuiteOptimization', 'Auto')
%   fullCovAlreadyAcheived = genLowLevelTests(ModelName, 'ModelCoverageObjectives', 'MCDC', 'TestSuiteOptimization', 'IndividualObjectives')
%   fullCovAlreadyAcheived = genLowLevelTests(ModelName, 'ModelCoverageObjectives', 'MCDC', 'TestSuiteOptimization', 'LongTestCases')
%   fullCovAlreadyAcheived = genLowLevelTests(ModelName, 'ModelCoverageObjectives', 'MCDC', 'TestSuiteOptimization', 'LargeModel (Nonlinear Extended)')
%   fullCovAlreadyAcheived = genLowLevelTests(ModelName, 'ModelCoverageObjectives', 'MCDC', 'TestSuiteOptimization', 'IndividualObjectives', 'AbsTol', 1e-6, 'RelTol', 1e-3)
%   fullCovAlreadyAcheived = genLowLevelTests(ModelName, 'ModelCoverageObjectives', 'MCDC', 'TestSuiteOptimization', 'IndividualObjectives', 'AbsTol', 1e-6, 'RelTol', 1e-3, 'MaxProcessTime', 300)
%   fullCovAlreadyAcheived = genLowLevelTests(ModelName, 'ModelCoverageObjectives', 'MCDC', 'TestSuiteOptimization', 'IndividualObjectives', 'AbsTol', 1e-6, 'RelTol', 1e-3, 'MaxProcessTime', 300, 'CI', true)
%   fullCovAlreadyAcheived = genLowLevelTests(ModelName, 'ModelCoverageObjectives', 'MCDC', 'TestSuiteOptimization', 'IndividualObjectives', 'AbsTol', 1e-6, 'RelTol', 1e-3, 'CI', true)
%   fullCovAlreadyAcheived = genLowLevelTests(ModelName, 'ModelCoverageObjectives', 'MCDC', 'TestSuiteOptimization', 'IndividualObjectives', 'MaxProcessTime', 300, 'CI', true)
%   fullCovAlreadyAcheived = genLowLevelTests(ModelName, 'ModelCoverageObjectives', 'MCDC', 'AbsTol', 1e-6, 'RelTol', 1e-3, 'MaxProcessTime', 300, 'CI', true)
%   fullCovAlreadyAcheived = genLowLevelTests(ModelName, 'TestSuiteOptimization', 'IndividualObjectives', 'AbsTol', 1e-6, 'RelTol', 1e-3, 'MaxProcessTime', 300, 'CI', true)
%   fullCovAlreadyAcheived = genLowLevelTests(ModelName, 'TestSuiteOptimization', 'IndividualObjectives', 'AbsTol', 1e-6, 'RelTol', 1e-3, 'MaxProcessTime', 300)
%   fullCovAlreadyAcheived = genLowLevelTests(ModelName, 'TestSuiteOptimization', 'IndividualObjectives', 'AbsTol', 1e-6, 'RelTol', 1e-3)
%   fullCovAlreadyAcheived = genLowLevelTests(ModelName, 'TestSuiteOptimization', 'IndividualObjectives')
%   fullCovAlreadyAcheived = genLowLevelTests(ModelName, 'AbsTol', 1e-6, 'RelTol', 1e-3)
%   fullCovAlreadyAcheived = genLowLevelTests(ModelName, 'MaxProcessTime', 300)
%   fullCovAlreadyAcheived = genLowLevelTests(ModelName, 'CI', true)

%   Copyright 2021-2024 The MathWorks, Inc.

if ~iec.internal.license('test','Simulink Design Verifier')
    MSLDiagnostic('certqualkit:engine:SLDVMissLicense').reportAsError;
end
if ~iec.internal.license('test','Simulink Test')
    MSLDiagnostic('certqualkit:engine:SLTESTMissLicense').reportAsError;
end
if ~iec.internal.license('test','Simulink Coverage')
    MSLDiagnostic('certqualkit:engine:SLCOVMissLicense').reportAsError;
end


% Close all models.
if iec.internal.license('test', 'Simulink')
    bdclose('all');
end

% Clear all coverage data.
cvexit();

% Administer options.
ci = false;
maxProcessTime = 300;
modelCoverageObjectives = 'MCDC';
testSuiteOptimization = 'IndividualObjectives';
absTol = 1e-6;
relTol = 1e-3;
if nargin > 1
    options = varargin(1:end);
    numOptions = numel(options)/2;
    for k = 1:numOptions
        opt = options{2*k-1};
        val = options{2*k};
        if strcmpi(opt, 'ModelCoverageObjectives') && isa(val, 'char')
            if strcmpi(val, 'Decision') || strcmpi(val, 'ConditionDecision') || strcmpi(val, 'MCDC')
                modelCoverageObjectives = val;
            else
                error('Incorrect ModelCoverageObjectives setting.');
            end
        elseif strcmpi(opt, 'TestSuiteOptimization') && isa(val, 'char')
            if strcmpi(val, 'Auto') || strcmpi(val, 'IndividualObjectives') || strcmpi(val, 'LongTestCases') || strcmpi(val, 'LargeModel (Nonlinear Extended)')
                testSuiteOptimization = val;
            else
                error('Incorrect TestSuiteOptimization setting.');
            end
        elseif strcmpi(opt, 'AbsTol') && isa(val, 'double') && isscalar(val)
            absTol = val;
        elseif strcmpi(opt, 'RelTol') && isa(val, 'double') && isscalar(val)
            relTol = val;
        elseif strcmpi(opt, 'MaxProcessTime') && isa(val, 'double') && isscalar(val)
            maxProcessTime = val;
        elseif strcmpi(opt, 'CI') && islogical(val) && isscalar(val)
            ci = val;
        else
            error('Incorrect option-value pair.');
        end
    end
end

% Capture useful folder/file paths and names.
rptFile = ProjArtifacts.getUnitSLDVTestGenReport(modelName);
cvtFile = ProjArtifacts.getUnitMCovHLRCvt(modelName);
sldvHarness = ProjArtifacts.getUnitSLDVTestHarness(modelName);
sldvBslDir = ProjArtifacts.getUnitSLDVTestBaselineDir(modelName);
sldvTestFile = ProjArtifacts.getUnitSLDVTestFile(modelName);

% get file names only
[rptDir,rptFileName] = fileparts(rptFile); 
[~,testFileName] = fileparts(sldvTestFile);
[harnessPath,harnessName] = fileparts(sldvHarness);


% Delete the old test file and baseline data if they exist.
if exist(sldvTestFile, 'file')
    delete(sldvTestFile);
end

if exist(sldvBslDir, 'dir')
    rmdir(sldvBslDir, 's');
end

if exist(rptFile,'file')
    delete(rptFile);
end

%% remove test generation report files (pdf or html) 
rptGenPDFFiles = ProjArtifacts.getUnitSLDVTestGenReportPDFFiles(modelName);
if exist(rptGenPDFFiles, 'dir')
    rmdir(rptGenPDFFiles, 's');
end
rptGenHTMLFiles = ProjArtifacts.getUnitSLDVTestGenReportHTMLFiles(modelName);
if exist(rptGenHTMLFiles, 'dir')
    rmdir(rptGenHTMLFiles, 's');
end

%% 
% Check for prerequisites.
if ~exist(['open_', modelName], 'file')
    error(['Model startup script ''open_', modelName, ''' not found.']);
end

% Open the model.
disp(['Opening Simulink model ', modelName, '.']);
evalin('base', ['open_', modelName]);

% Remove the old SLDV harness if it exists.
if ~isempty(sltest.harness.find(modelName, 'Name', harnessName))
    sltest.harness.delete(modelName, harnessName);
end

% If there is no external harness existing for model, then create a dummy 
% external harness to force SLDV to create harness externally
tempExtHarness = [modelName '_tempHarness'];
if isempty(sltest.harness.find(modelName, 'Name', [modelName '_Harness']))
    if ~isempty(sltest.harness.find(modelName, 'Name', tempExtHarness))
        sltest.harness.delete(modelName, tempExtHarness);
    end
    sltest.harness.create(modelName ,'Name', tempExtHarness, ...
        'SaveExternally', true, ...
        'HarnessPath',harnessPath );
    % Close the model and reopen, otherwise SLDV will complain
    close_system(modelName);
    % ReOpen the model.
    disp(['Opening Simulink model ', modelName, '.']);
    evalin('base', ['open_', modelName]);
end

% Create a configuration for Design Verifier Test Generation.
sldvCfg = sldvoptions;
sldvCfg.Mode = 'TestGeneration';
sldvCfg.MaxProcessTime = maxProcessTime;
sldvCfg.DisplayUnsatisfiableObjectives = 'on';
sldvCfg.OutputDir = rptDir;
sldvCfg.MakeOutputFilesUnique = 'off';
sldvCfg.ModelCoverageObjectives = modelCoverageObjectives;
sldvCfg.TestConditions = 'UseLocalSettings';
sldvCfg.TestObjectives = 'UseLocalSettings';
sldvCfg.MaxTestCaseSteps = 10000;
sldvCfg.TestSuiteOptimization = testSuiteOptimization;
sldvCfg.ExtendExistingTests = 'off';
sldvCfg.ExistingTestFile = '';
sldvCfg.IgnoreExistTestSatisfied = 'on';
if exist(cvtFile, 'file')
    % Existing coverage data is available.
    sldvCfg.IgnoreCovSatisfied = 'on';
    sldvCfg.CoverageDataFile = cvtFile;
else
    % Existing coverage data is not available.
    sldvCfg.IgnoreCovSatisfied = 'off';
    sldvCfg.CoverageDataFile = '';
end
sldvCfg.CovFilter = 'off';
sldvCfg.CovFilterFileName = '';
sldvCfg.IncludeRelationalBoundary = 'on';
sldvCfg.AbsoluteTolerance = 1e-05;
sldvCfg.RelativeTolerance = 0.01;
sldvCfg.SaveExpectedOutput = 'on';
sldvCfg.SlTestFileName = testFileName;
sldvCfg.SlTestHarnessName = harnessName;
sldvCfg.SaveReport = 'on';
sldvCfg.ReportPDFFormat = 'on';
sldvCfg.ReportFileName = rptFileName;
sldvCfg.DisplayReport = 'off';

% Generate tests from the model based on coverage objectives in the Design Verifier configuration.
[status,files,~,~, fullCovAlreadyAcheived] = sldvrun(modelName, sldvCfg);  

% If results exist, export results to a test file with a new test harness.
% Results exist if the analysis either completes normally (status = 1) or
% exceeds the maximum processing time (status = -1).
if status && ~fullCovAlreadyAcheived
    % Note that if the analysis completes normally, no test case is
    % generated if there is no satisfied objective. Obviously if the
    % analysis exceeds the maximum processing time, there is no guarantee
    % that any test case is generated at all. Therefore, we must check if
    % sldvData in the result data file contains a TestCases field. If not,
    % the result does not produce any test case.
    load(files.DataFile,'sldvData');
    if isfield(sldvData, 'TestCases') && ~isempty(sldvData.TestCases)
        sltest.testmanager.clear();
        sltest.testmanager.clearResults();
        [~, newHarness] = sltest.import.sldvData(files.DataFile, ...
            'CreateHarness', true, ...
            'TestHarnessName', harnessName, ...
            'TestFileName', sldvTestFile);
        

        load_system(newHarness);

        set_param(newHarness, 'Description', 'Test harness for SLDV generated test cases.');
        set_param(newHarness, 'CovEnable', 'off');
        save_system(newHarness, []);
        movefile(which(newHarness), sldvHarness);
        

        % Resolve G1467475 (R2016b).
        sldvTestFile = sltest.testmanager.TestFile(sldvTestFile, false);
        testSuite = sldvTestFile.getTestSuites();
        testCase = testSuite.getTestCases();
        bslCriteria = testCase.getBaselineCriteria();
        for bslIdx = 1:length(bslCriteria)
            bslCriteria(bslIdx).remove();
        end

        bslFiles = dir(fullfile(sldvBslDir, '*.mat'));
        for bslIdx = 1:length(bslFiles)
            testCase.addBaselineCriteria(fullfile(sldvBslDir, bslFiles(bslIdx).name));
        end

        
        % Rename the test suite.
        testSuite.Name = 'SLDV-Based Test';
        
        % Rename the test case.
        testCase.Name = 'LLR_SLDV';
        
        % Modify DESCRIPTION of the test case.
        testCase.Description = 'Simulation test for LLR from SLDV.';
        
        % Modify CALLBACKS of the test case.
        if isempty(get_param(modelName, 'DataDictionary')) && exist(['DD_', modelName], 'file')
            % Insert command to load data into base workspace if data is
            % defined using MATLAB data file instead of Simulink data
            % dictionary file.
            callback = testCase.getProperty('PreloadCallback');
            callback = [callback, sprintf(['\nDD_', modelName, ';\n'])];
            testCase.setProperty('PreloadCallback', callback);
        end
        
        % Modify BASELINE CRITERIA of the test case.
        bslCriteria = testCase.getBaselineCriteria();
        for bslIdx = 1:length(bslCriteria)
            bslCriteria(bslIdx).AbsTol = absTol;
            bslCriteria(bslIdx).RelTol = relTol;
        end
        
        % Modify ITERATIONS of the test case.
        testCase.setProperty('FastRestart', true);
        
        % Modify COVERAGE SETTINGS of the test case.
        covSettings = sldvTestFile.getCoverageSettings();
        covSettings.RecordCoverage = false;
        covSettings.MdlRefCoverage = true;
        covSettings.MetricSettings = 'dcmtroib';
        
        % Write changes back to test file.
        sldvTestFile.saveToFile();
    end
end

if ~ci && ~isempty(files.PDFReport)
    % Open the report.
    open(files.PDFReport);
end

% Delete the temporary folder for internal use.
if exist('rtwgen_tlc', 'dir')
    rmdir('rtwgen_tlc', 's');
end

%% remove test generation report files (pdf or html) 
rptGenPDFFiles = ProjArtifacts.getUnitSLDVTestGenReportPDFFiles(modelName);
if exist(rptGenPDFFiles, 'dir')
    rmdir(rptGenPDFFiles, 's');
end
rptGenHTMLFiles = ProjArtifacts.getUnitSLDVTestGenReportHTMLFiles(modelName);
if exist(rptGenHTMLFiles, 'dir')
    rmdir(rptGenHTMLFiles, 's');
end


% Close the model.
disp(['Closing Simulink model ', modelName, '.']);
close_system(modelName, 0);

% Delete the dummy harness.
load_system(modelName);
if ~isempty(sltest.harness.find(modelName, 'Name', tempExtHarness))
    sltest.harness.delete(modelName, tempExtHarness);
end
close_system(modelName, 0);
end
