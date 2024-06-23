function rmiReset()
%rmiReset   Reset RMI preference settings
%   Restore the RMI settings for the current project.
%
%   rmiReset()

%   Copyright 2021 The MathWorks, Inc.

% Get the ProjectManager.
prev_rmipref_data_file = ProjArtifacts.prevRMIPrefs;

% restore RMI preference settings
if exist(prev_rmipref_data_file,'file')
    load(prev_rmipref_data_file,'prev_rmipref');
    rmipref('BiDirectionalLinking',         prev_rmipref.BiDirectionalLinking);
    rmipref('CustomSettings',               prev_rmipref.CustomSettings);
    rmipref('DocumentPathReference',        prev_rmipref.DocumentPathReference);
    rmipref('DuplicateOnCopy',              prev_rmipref.DuplicateOnCopy);
    rmipref('FilterEnable',                 prev_rmipref.FilterEnable);
    rmipref('FilterRequireTags',            prev_rmipref.FilterRequireTags);
    rmipref('FilterExcludeTags',            prev_rmipref.FilterExcludeTags);
    rmipref('FilterMenusByTags',            prev_rmipref.FilterMenusByTags);
    rmipref('FilterConsistencyChecking',    prev_rmipref.FilterConsistencyChecking);
    rmipref('LinkIconFilePath',             prev_rmipref.LinkIconFilePath);
    rmipref('ModelPathReference',           prev_rmipref.ModelPathReference);
    rmipref('ReqDocPathBase',               prev_rmipref.ReqDocPathBase);
    rmipref('OslcServerAddress',            prev_rmipref.OslcServerAddress);
    rmipref('OslcServerUser',               prev_rmipref.OslcServerUser);
    rmipref('OslcLabelTemplate',            prev_rmipref.OslcLabelTemplate);
    rmipref('OslcServerVersion',            prev_rmipref.OslcServerVersion);
    rmipref('OslcServerContextParamName',   prev_rmipref.OslcServerContextParamName);
    rmipref('ReportFollowLibraryLinks',     prev_rmipref.ReportFollowLibraryLinks);
    rmipref('ReportHighlightSnapshots',     prev_rmipref.ReportHighlightSnapshots);
    rmipref('ReportNoLinkItems',            prev_rmipref.ReportNoLinkItems);
    rmipref('ReportUseDocIndex',            prev_rmipref.ReportUseDocIndex);
    rmipref('ReportIncludeTags',            prev_rmipref.ReportIncludeTags);
    rmipref('ReportDocDetails',             prev_rmipref.ReportDocDetails);
    rmipref('ReportLinkToObjects',          prev_rmipref.ReportLinkToObjects);
    rmipref('ReportNavUseMatlab',           prev_rmipref.ReportNavUseMatlab);
    rmipref('ReportUseRelativePath',        prev_rmipref.ReportUseRelativePath);
    rmipref('ResourcePathBase',             prev_rmipref.ResourcePathBase);
    rmipref('SelectionLinkWord',            prev_rmipref.SelectionLinkWord);
    rmipref('SelectionLinkExcel',           prev_rmipref.SelectionLinkExcel);
    rmipref('SelectionLinkDoors',           prev_rmipref.SelectionLinkDoors);
    rmipref('SelectionLinkTag',             prev_rmipref.SelectionLinkTag);
    rmipref('ShowDetailsWhenHighlighted',   prev_rmipref.ShowDetailsWhenHighlighted);
    rmipref('StoreDataExternally',          prev_rmipref.StoreDataExternally);
    rmipref('UnsecureHttpRequests',         prev_rmipref.UnsecureHttpRequests);
    rmipref('UseActiveXButtons',            prev_rmipref.UseActiveXButtons);
    rmipref('OslcServerStripDefaultPort',   prev_rmipref.OslcServerStripDefaultPort);
    rmipref('OslcMatchBrowserContext',      prev_rmipref.OslcMatchBrowserContext);
    rmipref('PolarionServerAddress',        prev_rmipref.PolarionServerAddress);
    rmipref('PolarionProjectId',            prev_rmipref.PolarionProjectId);
    rmipref('DoorsModuleID',                prev_rmipref.DoorsModuleID);
    rmi.settings_mgr('set', 'filterSettings', prev_rmipref.filterSettings);
    delete(prev_rmipref_data_file);
else
    rmi.settings_mgr('set', 'DEFAULTS');
end
end
