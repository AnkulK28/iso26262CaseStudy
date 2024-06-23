function rmiSetup()
%rmiSetup   Set up RMI
%   Configure the RMI settings for the current project.
%
%   rmiSetup()

%   Copyright 2021 The MathWorks, Inc.

% Store current RMI settings
prev_rmipref.BiDirectionalLinking       = rmipref('BiDirectionalLinking');
prev_rmipref.CustomSettings             = rmipref('CustomSettings');
prev_rmipref.DocumentPathReference      = rmipref('DocumentPathReference');
prev_rmipref.DuplicateOnCopy            = rmipref('DuplicateOnCopy');
prev_rmipref.FilterEnable               = rmipref('FilterEnable');
prev_rmipref.FilterRequireTags          = rmipref('FilterRequireTags');
prev_rmipref.FilterExcludeTags          = rmipref('FilterExcludeTags');
prev_rmipref.FilterMenusByTags          = rmipref('FilterMenusByTags');
prev_rmipref.FilterConsistencyChecking  = rmipref('FilterConsistencyChecking');
prev_rmipref.LinkIconFilePath           = rmipref('LinkIconFilePath');
prev_rmipref.ModelPathReference         = rmipref('ModelPathReference');
prev_rmipref.ReqDocPathBase             = rmipref('ReqDocPathBase');
prev_rmipref.OslcServerAddress          = rmipref('OslcServerAddress');
prev_rmipref.OslcServerUser             = rmipref('OslcServerUser');
prev_rmipref.OslcLabelTemplate          = rmipref('OslcLabelTemplate');
prev_rmipref.OslcServerVersion          = rmipref('OslcServerVersion');
prev_rmipref.OslcServerContextParamName = rmipref('OslcServerContextParamName');
prev_rmipref.ReportFollowLibraryLinks   = rmipref('ReportFollowLibraryLinks');
prev_rmipref.ReportHighlightSnapshots   = rmipref('ReportHighlightSnapshots');
prev_rmipref.ReportNoLinkItems          = rmipref('ReportNoLinkItems');
prev_rmipref.ReportUseDocIndex          = rmipref('ReportUseDocIndex');
prev_rmipref.ReportIncludeTags          = rmipref('ReportIncludeTags');
prev_rmipref.ReportDocDetails           = rmipref('ReportDocDetails');
prev_rmipref.ReportLinkToObjects        = rmipref('ReportLinkToObjects');
prev_rmipref.ReportNavUseMatlab         = rmipref('ReportNavUseMatlab');
prev_rmipref.ReportUseRelativePath      = rmipref('ReportUseRelativePath');
prev_rmipref.ResourcePathBase           = rmipref('ResourcePathBase');
prev_rmipref.SelectionLinkWord          = rmipref('SelectionLinkWord');
prev_rmipref.SelectionLinkExcel         = rmipref('SelectionLinkExcel');
prev_rmipref.SelectionLinkDoors         = rmipref('SelectionLinkDoors');
prev_rmipref.SelectionLinkTag           = rmipref('SelectionLinkTag');
prev_rmipref.ShowDetailsWhenHighlighted = rmipref('ShowDetailsWhenHighlighted');
prev_rmipref.StoreDataExternally        = rmipref('StoreDataExternally');
prev_rmipref.UnsecureHttpRequests       = rmipref('UnsecureHttpRequests');
prev_rmipref.UseActiveXButtons          = rmipref('UseActiveXButtons');
prev_rmipref.OslcServerStripDefaultPort = rmipref('OslcServerStripDefaultPort');
prev_rmipref.OslcMatchBrowserContext    = rmipref('OslcMatchBrowserContext');
prev_rmipref.PolarionServerAddress      = rmipref('PolarionServerAddress');
prev_rmipref.PolarionProjectId          = rmipref('PolarionProjectId');
prev_rmipref.DoorsModuleID              = rmipref('DoorsModuleID');
prev_rmipref.filterSettings             = rmi.settings_mgr('get', 'filterSettings');

save(ProjArtifacts.prevRMIPrefs, 'prev_rmipref');

% Set the Storage tab.
rmipref('StoreDataExternally', true);
rmipref('DuplicateOnCopy', false);

% Enable Navigation between PDF reports and models
rmipref('UnsecureHttpRequests', true);
rmipref('ReportNavUseMatlab', true);

% Set the Selection Linking tab.
rmipref('SelectionLinkWord', true);
rmipref('SelectionLinkExcel', true);
rmipref('SelectionLinkDoors', true);
rmipref('DocumentPathReference', 'none');
rmipref('SelectionLinkTag','');
rmipref('BiDirectionalLinking', false);

% Set the Filters tab.
rmipref('FilterEnable', false);
% Set Disable synchronization item links.
filterSettings = rmi.settings_mgr('get', 'filterSettings');
filterSettings.filterSurrogateLinks = false;
rmi.settings_mgr('set', 'filterSettings', filterSettings);

end
