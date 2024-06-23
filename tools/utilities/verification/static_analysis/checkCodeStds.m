function varargout = checkCodeStds(modelName, varargin)
%checkCodeStds Check generated code against code standards
%   Check the generated code against code standards, and then generate the
%   Bug Finder PDF report.
%
%   checkCodeStds(ModelName)
%   checkCodeStds(ModelName, 'TreatAsTopMdl')
%   checkCodeStds(ModelName, 'TreatAsTopMdl', 'CI')
%   checkCodeStds(ModelName, [], 'CI')

%   Copyright 2021-2022 The MathWorks, Inc.

if isempty(ver('psbugfinder')) && isempty(ver('psbugfinderserver'))
    error('Link to either Polyspace Bug Finder or Polyspace Bug Finder Server is not available. See "Integrate Polyspace with MATLAB and Simulink" for more information.');
end

% Close all models.
if iec.internal.license('test', 'Simulink')
    bdclose('all');
end

% Capture useful polyspace paths
tmplDir = fullfile(polyspaceroot, 'toolbox', 'polyspace', 'psrptgen', 'templates', 'bug_finder');

% Capture useful folder/file paths and names.
psprjDir = fileparts(ProjArtifacts.getUnitCStdChksSummaryPDF(modelName));
resultDir = fullfile(psprjDir, modelName);


% Create model specific folder if it does not exist.
if ~exist(psprjDir, 'dir')
    mkdir(psprjDir);
end

% Check for prerequisites.
if ~exist(['open_', modelName], 'file')
    error(['Model startup script ''open_', modelName, ''' not found.']);
end
% Bug Finder automatically checks if the generated code exist.

% Open the model.
disp(['Opening Simulink model ', modelName, '.']);
evalin('base', ['open_', modelName]);

% Create a configuration for Bug Finder (Coding Standards only).
disp(['Analyzing code of Simulink model ', modelName, '.']);
psCfg = pslinkoptions(modelName);
psCfg.VerificationMode = 'BugFinder';
psCfg.VerificationSettings = 'PrjConfig';
psCfg.CxxVerificationSettings = 'PrjConfig';
psCfg.EnableAdditionalFileList = false;
psCfg.AdditionalFileList = {};
psCfg.AutoStubLUT = true;
psCfg.InputRangeMode = 'DesignMinMax';
psCfg.ParamRangeMode = 'None';
psCfg.OutputRangeMode = 'None';
psCfg.ModelRefVerifDepth = 'Current model only';
psCfg.ModelRefByModelRefVerif = false;
psCfg.AddSuffixToResultDir = false;
psCfg.AddToSimulinkProject = false;
psCfg.OpenProjectManager = false;
psCfg.CheckconfigBeforeAnalysis = 'OnWarn';

isModelRef = true;
if nargin > 1 && ~isempty(varargin{1})
    isModelRef = false;
end

    
tempDir = ProjArtifacts.getUnitCStdChksTempPSproj(modelName, isModelRef);
psCfg.ResultDir = fullfile(tempDir);
psprjCfg = polyspace.ModelLinkOptions(modelName, psCfg, isModelRef);


if contains(get_param(modelName, 'TargetLangStandard'), 'C90')
    psprjCfg.TargetCompiler.NoLanguageExtensions = true; % Respect C90 standard if true.
else
    psprjCfg.TargetCompiler.NoLanguageExtensions = false; % Otherwise default to C99.
end

psprjCfg.InputsStubbing.GenerateResultsFor='all-headers';

psprjCfg.BugFinderAnalysis.EnableCheckers = false;
psprjCfg.CodingRulesCodeMetrics.CodeMetrics = false;
psprjCfg.CodingRulesCodeMetrics.EnableMisraC3 = true;
psprjCfg.CodingRulesCodeMetrics.Misra3AgcMode = true;
psprjCfg.CodingRulesCodeMetrics.MisraC3Subset = 'from-file';
psprjCfg.CodingRulesCodeMetrics.CheckersSelectionByFile = ProjArtifacts.misraCfg;
psprjCfg.CodingRulesCodeMetrics.EnableCheckersSelectionByFile = true;
psprjCfg.CodingRulesCodeMetrics.BooleanTypes = {'boolean_T'};

psprjCfg.Macros.DefinedMacros = {'main=main_rtwec', '__restrict__='};
% psprjCfg.Advanced.Additional = '-stub-embedded-coder-lookup-table-functions';
psprjCfg.ResultsDir = resultDir;
psprjCfg.generateProject(ProjArtifacts.getUnitCStdChksPSproj(modelName));
psprjCfg.Prog = 'PolyspaceProject';
psprjCfg.Author = 'MathWorks';
% Inspect the generated code against enabled checks in the Bug Finder configuration.
psprj = polyspace.Project();
psprj.Configuration = psprjCfg;
psprj.run('bugFinder');

if nargin > 2 && ~isempty(varargin{2})
    openReport = false;
    result.Method = 'checkCodeStds';
    result.Component = modelName;
    resObj = psprj.Results;
    misraC2012Summary = resObj.getSummary('misraC2012');
    if ~isempty(misraC2012Summary)
        result.NumPurple = sum(misraC2012Summary.Total);
    else
        result.NumPurple = 0;
    end
    if result.NumPurple > 0
        result.Outcome = 0;
    else
        result.Outcome = 1;
    end
    result.Results.MisraC2012 = misraC2012Summary;
    varargout{1} = result;
else
    openReport = true;
end

%  Generate summary and coding standards reports
tmplFiles = {fullfile(tmplDir, 'BugFinderSummary.rpt'), fullfile(tmplDir, 'CodingStandards.rpt')};
polyspace_report( '-template', tmplFiles, '-format', 'PDF', '-output-name', psprjDir, '-results-dir', resultDir, '-noview');

% rename Summary Report
tmpRpt1 = fullfile(psprjDir, 'PolyspaceProject_BugFinderSummary.pdf');
rptFile = ProjArtifacts.getUnitCStdChksSummaryPDF(modelName);
if exist(tmpRpt1,'file')
    movefile(tmpRpt1, rptFile,'f');
end

if openReport && exist(rptFile,'file')
    open(rptFile);
end

% rename coding standards report
tmpRpt2 = fullfile(psprjDir, 'PolyspaceProject_CodingStandards.pdf');
rptFile = ProjArtifacts.getUnitCStdChksPDF(modelName);
if exist(tmpRpt2,'file')
    movefile(tmpRpt2, rptFile,'f');
end 

if openReport && exist(rptFile,'file')
    open(rptFile);
end

% Clean temp folders
if exist(resultDir, 'dir')
    rmdir(resultDir, 's');
end


if exist(ProjArtifacts.getUnitCStdChksPSproj(modelName), 'file')
    delete(ProjArtifacts.getUnitCStdChksPSproj(modelName));
end


% Close the model.
disp(['Closing Simulink model ', modelName, '.']);
close_system(modelName, 0);

end
