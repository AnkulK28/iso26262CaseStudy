function createTestSuiteForModel(modelName, asil, isAtomicComp)
%createTestSuiteForModel Create a test suite for a software unit or
%component
%   Create empty test suite for ModelName that contains test cases covering
%   highly recommended verification methods imposed by ISO 26262.
%   ASIL can be either 'QM'|'ASILA'|'ASILB'|'ASILC'|'ASILD'.
%   isAtomicComp specifies if model corresponds to a software unit or an
%   integration software component (default is unit).
%
%   createTestSuiteForModel(ModelName, ASIL, isAtomicComp)

%   Copyright 2021 The MathWorks, Inc.

if nargin<3
    isAtomicComp = true;
end


verifyMethods = getASILVerifyMethods(asil);
coverMethods = getASILStructuralCoverage(asil);


% verifyMethods{end+1} = 'MIL-SIL back2back tests';
% verifyMethods{end+1} = 'MIL-PIL back2back tests';

if isAtomicComp
    testFile = ProjArtifacts.getUnitRBTTestFile(modelName);
else
    testFile = ProjArtifacts.getCompRBTTestFile(modelName);
end
tf = sltest.testmanager.TestFile(testFile);
cov = getCoverageSettings(tf);
cov.RecordCoverage = true;
cov.MdlRefCoverage=true;

%d: Decision
%c: Condition
%m: MCDC
%t: lookup table
%r: signal range
%z: signal size
%o: simulink design verifier
%i: Saturation on integer overflow
%b: Relational Boundary

%range values coverage
cov.MetricSettings = 'r';
if ismember('MCDC_coverage',coverMethods)
    cov.MetricSettings = strcat(cov.MetricSettings,'m');
end

if ismember('Branch_coverage',coverMethods)
    cov.MetricSettings = strcat(cov.MetricSettings,'d'); %decision coverage
end

for m = 1:length(verifyMethods)
    ts = createTestSuite(tf, verifyMethods{m});
    tc = createTestCase(ts,'baseline','TC1');
    
    % Assign the system under test to the test case
    setProperty(tc,'Model',modelName);
end

% Remove the default test suite
tsDel = getTestSuiteByName(tf,'New Test Suite 1');
remove(tsDel);
saveToFile(tf);
clearTestManager();