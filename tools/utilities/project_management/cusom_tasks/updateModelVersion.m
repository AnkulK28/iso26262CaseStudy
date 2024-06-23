function result = updateModelVersion(file)
%updateModelVersion This function saves the model with the current Simulink
%version

[~, model, ext] = fileparts(file);
if ismember(ext, {'.mdl','.slx'})
    
    % Get current installed Simulink version
    product_info = ver('simulink');
    product_sl_ver_num = str2double(product_info.Version);
    
    % Get the Version when the model was saved
    info = Simulink.MDLInfo(model);
    model_sl_ver_num = str2double(info.SimulinkVersion);
    
    if (model_sl_ver_num < product_sl_ver_num)
        if ~bdIsLoaded(model)
            load_system(model);
        end
        model_type = get_param(model,'BlockDiagramType');
        if strcmp( model_type, 'library' )
            if(strcmp(get_param(model,'Lock'),'on'))
                set_param(model,'Lock','off');
            end
        end
        % Get write access
        fileattrib(file,'+w','','s');
        
        % Save the model
        save_system(model);
        result = ['Saved ' model ' with Simulink version ' product_info.Version];
    else
        result = [model ' is at Simulink version ' info.SimulinkVersion];
    end
else
    result = [];
end
