function genReqReport(reqSetName, varargin)
%genReqReport Generate a requirement report from requirement set
%   Generate a requirement report from the requirement set.
%
%   genReqReport(ReqSetName)
%   genReqReport(ReqSetName, AuthorNames)
%   genReqReport(ReqSetName, AuthorNames, 'CI')
%   genReqReport(ReqSetName, [], 'CI')

%   Copyright 2021-2022 The MathWorks, Inc.

if ~iec.internal.license('test','Requirements Toolbox')
    MSLDiagnostic('certqualkit:engine:SLREQMissLicense').reportAsError;
end

% Close all requirement and link sets.
slreq.clear();

% Close all models.
if iec.internal.license('test', 'Simulink')
    bdclose('all');
end

% Close all test files and test results.
if iec.internal.license('test','Simulink Test')
    sltest.testmanager.clear();
    sltest.testmanager.clearResults();
end

% Make report generation robust wrt. having and not having slreqx extension
[~, reqSetName] = fileparts(reqSetName);
if ~exist([reqSetName, '.slreqx'], 'file')
    error(['Requirement set ''', reqSetName, ''' not found.']);
end

% Open the requirement set.
reqSet = slreq.open(reqSetName);

% Wait for scanning and loading of link sets to complete.
slreq.refreshLinkDependencies();

% Load all linked models, test files, and test results.
linkSets = slreq.find('type', 'LinkSet');
for i = 1:length(linkSets)
    if strcmpi(linkSets(i).Domain, 'linktype_rmi_simulink')
        load_system(linkSets(i).Artifact);
    elseif strcmpi(linkSets(i).Domain, 'linktype_rmi_testmgr')
        if iec.internal.license('test','Simulink Test')
            sltest.testmanager.load(linkSets(i).Artifact);
            [~, testFileName, testFileExt] = fileparts(linkSets(i).Artifact);
            if exist([testFileName, '_Results', testFileExt], 'file')
                sltest.testmanager.importResults([testFileName, '_Results', testFileExt]);
            end
        end
    end
end

% Update implmentation status.
reqSet.updateImplementationStatus;

% Update verification status.
reqSet.updateVerificationStatus;

% Create a configuration for requirement report generation.
rptCfg = slreq.getReportOptions();
rptCfg.reportPath = ProjArtifacts.getReqReport(reqSetName);
if nargin > 2 && ~isempty(varargin{2})
    rptCfg.openReport = false;
else
    rptCfg.openReport = true;
end
rptCfg.titleText = [reqSetName, ' Report'];
if nargin > 1 && ~isempty(varargin{1})
    rptCfg.authors = varargin{1};
else
    % Leave it at default.
end
rptCfg.includes.toc = true;
rptCfg.includes.publishedDate = true;
rptCfg.includes.revision = true;
rptCfg.includes.properties = true;
rptCfg.includes.links = true;
rptCfg.includes.changeInformation = true;
rptCfg.includes.groupLinksBy = 'Artifact';
rptCfg.includes.keywords = true;
rptCfg.includes.comments = true;
rptCfg.includes.implementationStatus = true;
rptCfg.includes.verificationStatus = true;
rptCfg.includes.emptySections = false;
rptCfg.includes.rationale = true;
rptCfg.includes.customAttributes = true;

% Generate the report.
slreq.generateReport(reqSet, rptCfg);

% Close the requirement set.
disp(['Closing requirement set ', reqSetName, '.']);
if iec.internal.license('test','Simulink Test')
    sltest.testmanager.clear();
    sltest.testmanager.clearResults();
end
slreq.clear();

if iec.internal.license('test', 'Simulink')
    bdclose('all');
end

end
