function addSWUnitDesignFolder(modelName,reuse,slddLink, asil)
%addSWUnitDesignFolder Create an empty design folder for a software unit in
%project
%   Create a design folder for a new software unit containing empty design model,
%   and empty data dictionary.
%   reuse and slddLink can be either true|false
%   asil can be either 'QM'|'ASILA'|'ASILB'|'ASILC'|'ASILD'.
%
%   addSWUnitDesignFolder(ModelName, Reuse, slddLink, ASIL)


%   Copyright 2021 The MathWorks, Inc.


dstDirName = ProjArtifacts.getUnitDesignPath(modelName);
mkdir(dstDirName);

% Create a new model.
model = Simulink.createFromTemplate(ProjArtifacts.modelTemplate, 'Name', modelName);
coder.mapping.defaults.set(model,'SharedUtility','FunctionCustomizationTemplate',asil)
save_system(model, fullfile(dstDirName, modelName));


% Create a MATLAB data file for defining model data in model workspace if
% the model is multi-instantiable.
status = mkdir(fullfile(dstDirName, 'data'));
if reuse
    fid = fopen(fullfile(dstDirName, 'data', ['localDD_', modelName, '.m']), 'w');
    fprintf(fid, '%% Define data to be loaded into model workspace here.\n');
    fclose(fid);
end

if slddLink
    % Create a Simulink data dictionary file for defining model data if the
    % model is not multi-instantiable. This dictionary must include the
    % dictionary that contains the proper model configuration.
    dataDictionary = Simulink.data.dictionary.create(fullfile(dstDirName, 'data', ['DD_', modelName, '.sldd']));
    if reuse
        dataDictionary.addDataSource('csMultiInstance.sldd');
    else
        dataDictionary.addDataSource('csSingleInstance.sldd');
    end
    dataDictionary.saveChanges;
else
    % Create a MATLAB data file for defining model data in base workspace
    % if the model is not multi-instantiable.
    if ~reuse
        fid = fopen(fullfile(dstDirName, 'data', ['DD_', modelName, '.m']), 'w');
        fprintf(fid, 'if ~exist(''%s__'', ''var'')\n', ['DD_', modelName]);
        fprintf(fid, '    %s__ = true;\n', ['DD_', modelName]);
        fprintf(fid, '    %% Define data to be loaded into base workspace here.\n');
        fprintf(fid, 'end\n');
        fclose(fid);
    end
end

% Create a script for opening the model.
fid = fopen(fullfile(dstDirName, ['open_', modelName, '.m']), 'w');
if reuse
    fprintf(fid, '%% Data is automatically loaded into model workspace.\n');
else
    fprintf(fid, '%% Uncomment the next line to load data into base worksapce if data is\n');
    fprintf(fid, '%% defined using MATLAB data file instead of Simulink data dictionary file.\n');
    if slddLink
        fprintf(fid, '%% ');
    end
    fprintf(fid, '%s;\n', ['DD_', modelName]);
end
fprintf(fid, '%s;\n',  modelName);
fclose(fid);

prj = simulinkproject;

try
    % Add new folders to project.
    
    modelPaths = genpath(dstDirName);
    designDirs = regexp(modelPaths, pathsep, 'split');
    designDirs = designDirs(~cellfun('isempty', designDirs));
    for dirIdx = 1:length(designDirs)
        if isfolder(designDirs{dirIdx})
            prj.addPath(designDirs{dirIdx});
        end
    end
    
    prj.addFolderIncludingChildFiles(dstDirName);
    
    
    
    % Add Control Category and Life Cycle Data labels.
    for dirIdx = 1:length(designDirs)
        subFolder = prj.findFile(designDirs{dirIdx});
        subFolder.addLabel('ASIL', asil);
    end
catch
    error(['Unable to add ''', dstDirName, ''' to project.']);
end

% Load data into model workspace from data source if the model is
% multi-instantiable.
if reuse
    ws = get_param(model, 'ModelWorkspace');
    ws.DataSource = 'MATLAB Code';
    ws.MATLABCode = ['localDD_', modelName, ';'];
    ws.reload();
end

if slddLink
    % Link the model to data dictionary.
    set_param(model, 'DataDictionary', ['DD_', modelName, '.sldd']);
    set_param(model, 'EnableAccessToBaseWorkspace', 'off');
end

% Create a model configuration reference of the proper model configuration
% and attach it to the model.
Reference = Simulink.ConfigSetRef;
if reuse
    Reference.SourceName = 'csMultiInstance';
else
    Reference.SourceName = 'csSingleInstance';
end
attachConfigSet(modelName, Reference);
setActiveConfigSet(modelName, 'Reference');

% Resave the model.
save_system(model);


end
