load_system('baseModelConfiguration');
% get the new Simulink.ConfigSet object from the model:
configSet = getConfigSet('baseModelConfiguration', 'Configuration');
% export the new Simulink.ConfigSet object to iso26262Config.m, overwriting
% the existing settings in the file:
configSet.saveAs('iso26262Config');

% update the data dictionary that holds the model configuration for 
% reusable (multi-instantiable) models:
dd = Simulink.data.dictionary.open('csMultiInstance.sldd');
cfg = dd.getSection('Configurations');
cfg.importFromFile('reusableModelConfig.m', 'existingVarsAction', 'overwrite');
dd.saveChanges();

% update the data dictionary that holds the model configuration for
% nonreusable (not multi-instantiable) models:
dd = Simulink.data.dictionary.open('csSingleInstance.sldd');
cfg = dd.getSection('Configurations');
cfg.importFromFile('nonreusableModelConfig.m', 'existingVarsAction', 'overwrite');
dd.saveChanges();
