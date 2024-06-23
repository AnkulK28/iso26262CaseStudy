function varargout = checkModelStds(modelName, varargin)
%checkModelStds Check model against model standards
%   Check the model against model standards, and then generate the Model
%   Advisor report. Units and composite software components use different
%   model advisor checks. This can be controlled by passing
%   'CompositeComponent' as a fourth argument.
%
%   checkModelStds(ModelName)
%   checkModelStds(ModelName, 'TreatAsTopMdl')
%   checkModelStds(ModelName, 'TreatAsTopMdl', 'CI')
%   checkModelStds(ModelName, 'TreatAsTopMdl', 'CI','CompositeComponent')
%   checkModelStds(ModelName, [], 'CI')
%   checkModelStds(ModelName, [], 'DEV')

%   Copyright 2021-2022 The MathWorks, Inc.

if ~iec.internal.license('test','Simulink Check')
    MSLDiagnostic('certqualkit:engine:SLCHKMissLicense').reportAsError;
end

% Close all models.
bdclose('all');

% Check if a composite comonent or atomic unit
isAtomicUnit = true;
if nargin>3 && strcmpi(varargin{3},'CompositeComponent')
    isAtomicUnit = false;
end

% Delete the old report if it exists.
if isAtomicUnit
    modelAdvisorConfigFile = ProjArtifacts.maUnitChecksJson;
    htmlFile = ProjArtifacts.getUnitMStdChksHTML(modelName);
else
    modelAdvisorConfigFile = ProjArtifacts.maIntegrationChecksJson;
    htmlFile = ProjArtifacts.getCompMStdChksHTML(modelName);
end

if exist(htmlFile, 'file')
    delete(htmlFile);
end
[modelStdChecksDir,~]= fileparts(htmlFile);

if ~exist(modelStdChecksDir,'dir')
    mkdir(modelStdChecksDir);
end

% Check for prerequisites.
if ~exist(['open_', modelName], 'file')
    error(['Model startup script ''open_', modelName, ''' not found.']);
end

% Open the model.
disp(['Opening Simulink model ', modelName, '.']);
evalin('base', ['open_', modelName]);

% Inspect the model against enabled checks in the Model Advisor configuration.
if nargin > 1 && ~isempty(varargin{1})
    checkResult = ModelAdvisor.run(modelName, 'Configuration', ...
        modelAdvisorConfigFile, 'Force', 'on', 'TreatAsMdlRef', 'off');
else
    checkResult = ModelAdvisor.run(modelName, 'Configuration', ...
        modelAdvisorConfigFile, 'Force', 'on', 'TreatAsMdlRef', 'on');
end

% Generate Model Advisor report
maH = Simulink.ModelAdvisor.getModelAdvisor(modelName);
if maH.reportExists(modelName)
    maH.exportReport(htmlFile);
end

if nargin > 2 && ~isempty(varargin{2}) && ~strcmpi(varargin{2}, 'DEV')
    result.Method = 'checkModelStds';
    result.Component = modelName;
    result.NumTotal = 0;
    result.NumPass = 0;
    result.NumWarn = 0;
    result.NumFail = 0;
    result.Results = [];
    for i = 1:length(checkResult)
        if strcmpi(checkResult{i}.system, modelName)
            result.NumTotal = checkResult{i}.geninfo.allCt;
            result.NumPass = checkResult{i}.geninfo.passCt;
            result.NumWarn = checkResult{i}.geninfo.warnCt;
            result.NumFail = checkResult{i}.geninfo.failCt;
            if result.NumFail > 0
                result.Outcome = -1;
            elseif result.NumWarn > 0
                result.Outcome = 0;
            else
                result.Outcome = 1;
            end
            result.Results = checkResult{i};
            break;
        end
    end
    varargout{1} = result;
else
    open(htmlFile);
end

% Close the model.
disp(['Closing Simulink model ', modelName, '.']);
close_system(modelName, 0);

end
