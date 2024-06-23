function varargout = detectDesignErrs(modelName, varargin)
%detectDesignErrs Detect design errors or dead logic in model
%   Detect design errors or dead logic in the model, and then generate the
%   Design Verifier report.
%
%   detectDesignErrs(ModelName)
%   detectDesignErrs(ModelName, 'DetectActiveLogic')
%   detectDesignErrs(ModelName, 'DetectActiveLogic', 300)
%   detectDesignErrs(ModelName, 'DetectActiveLogic', 300, 'CI')
%   detectDesignErrs(ModelName, 'DetectActiveLogic', [], 'CI', 'CompositeComponent')
%   detectDesignErrs(ModelName, [], 300, 'CI')
%   detectDesignErrs(ModelName, [], [], 'CI')
%   detectDesignErrs(ModelName, [], [], 'DEV')

%   Copyright 2021-2022 The MathWorks, Inc.
varargout{1} = [];
if ~iec.internal.license('test','Simulink Design Verifier')
    MSLDiagnostic('certqualkit:engine:SLDVMissLicense').reportAsError;
end

% Close all models.
if iec.internal.license('test', 'Simulink')
    bdclose('all');
end

% Check if composite component or not
isCompositeComponent = false;
if nargin > 4 && strcmpi(varargin{4},'CompositeComponent')
    isCompositeComponent = true;
end

% Capture useful folder/file paths and names.
if isCompositeComponent
    rptFileName_pdf = ProjArtifacts.getCompDesErrsPDF(modelName);
    rptFileName_html = ProjArtifacts.getCompDesErrsHTML(modelName);
else
    rptFileName_pdf = ProjArtifacts.getUnitDesErrsPDF(modelName);
    rptFileName_html = ProjArtifacts.getUnitDesErrsHTML(modelName);
end

[rptsFolder,rptFileName] = fileparts(rptFileName_html);

if ~exist(rptsFolder, 'dir')
    mkdir(rptsFolder);
end
if exist(rptFileName_pdf, 'file')
    delete(rptFileName_pdf);
end
if exist(rptFileName_html, 'file')
    delete(rptFileName_html);
end
    
% Check for prerequisites.
if ~exist(['open_', modelName], 'file')
    error(['Model startup script ''open_', modelName, ''' not found.']);
end

% Open the model.
disp(['Opening Simulink model ', modelName, '.']);
evalin('base', ['open_', modelName]);

% Create a configuration for Design Verifier Design Error Detection.
sldvCfg = sldvoptions;
sldvCfg.Mode = 'DesignErrorDetection';
if nargin > 2 && ~isempty(varargin{2})
    sldvCfg.MaxProcessTime = varargin{2};
end
sldvCfg.OutputDir = rptsFolder;
sldvCfg.MakeOutputFilesUnique = 'off';
sldvCfg.DetectDeadLogic = 'on';
if nargin > 1 && ~isempty(varargin{1})
    % DetectActiveLogic is enabled.
    sldvCfg.DetectActiveLogic = 'on';
else
    % DetectActiveLogic is disabled.
    sldvCfg.DetectActiveLogic = 'off';
end
sldvCfg.DetectOutOfBounds = 'on';
sldvCfg.DetectDivisionByZero = 'on';
sldvCfg.DetectIntegerOverflow = 'on';
% sldvCfg.DetectInfNaN = 'on'; % Disabled (not qualified).
% sldvCfg.DetectSubnormal = 'on'; % Disabled (not qualified).
sldvCfg.DesignMinMaxCheck = 'on';
% sldvCfg.DetectDSMAccessViolations = 'on'; % Disabled (not qualified).
sldvCfg.SaveReport = 'on';
sldvCfg.ReportPDFFormat = 'on';
sldvCfg.ReportFileName = rptFileName;
sldvCfg.DisplayReport = 'off';

% Inspect the model against enabled analysis in the Design Verifier configuration.
[status, files] = sldvrun(modelName, sldvCfg);

if nargin > 3 && ~isempty(varargin{3}) && ~strcmpi(varargin{3}, 'DEV')
    result.Method = 'checkModelStds';
    result.Component = modelName;
    result.NumTotal = 0;
    result.NumPass = 0;
    result.NumWarn = 0;
    result.NumFail = 0;
    result.Results = [];
    % Results exist if the analysis either completes normally (status = 1) or
    % exceeds the maximum processing time (status = -1).
    if status
        load(files.DataFile, 'sldvData');
        if isfield(sldvData, 'Objectives')
            for i = 1:length(sldvData.Objectives)
                if ~strcmpi(sldvData.Objectives(i).type, 'Range')
                    result.NumTotal = result.NumTotal + 1;
                    switch sldvData.Objectives(i).status
                        case {'Valid', ...
                                'Valid within bound', ...
                                'Satisfied', ...
                                'Active Logic', ...
                                'Active Logic - needs simulation', ...
                                'Satisfied - No Test Case'}
                            result.NumPass = result.NumPass + 1;
                        case {'Undecided', ...
                                'Undecided due to stubbing', ...
                                'Undecided due to nonlinearities', ...
                                'Undecided due to division by zero', ...
                                'Valid under approximation', ...
                                'Unsatisfiable under approximation', ...
                                'Undecided due to approximations', ...
                                'Satisfied - needs simulation', ...
                                'Undecided with testcase', ...
                                'Undecided with counterexample', ...
                                'Undecided due to runtime error', ...
                                'Undecided due to array out of bounds', ...
                                'Produced error'}
                            result.NumWarn = result.NumWarn + 1;
                        case {'Falsified', ...
                                'Falsified - needs simulation', ...
                                'Falsified - No Counterexample', ...
                                'Unsatisfiable', ...
                                'Dead Logic', ...
                                'Dead Logic under approximation'}
                            result.NumFail = result.NumFail + 1;
                        otherwise
                            % Unknown status.
                    end
                end
                if result.NumFail > 0
                    result.Outcome = -1;
                elseif result.NumWarn > 0
                    result.Outcome = 0;
                else
                    result.Outcome = 1;
                end
                result.Results = sldvData;
            end
        end
    end
    varargout{1} = result;
elseif nargin > 3 && ~isempty(varargin{3}) && strcmpi(varargin{3}, 'DEV')
    % Open the report (HTML).
    open(files.Report);
else
    % Open the report (PDF).
    open(files.PDFReport);
end

% Delete the temporary folder for internal use.
if exist('rtwgen_tlc', 'dir')
    rmdir('rtwgen_tlc', 's');
end
% Close the model.
disp(['Closing Simulink model ', modelName, '.']);
close_system(modelName, 0);

end
