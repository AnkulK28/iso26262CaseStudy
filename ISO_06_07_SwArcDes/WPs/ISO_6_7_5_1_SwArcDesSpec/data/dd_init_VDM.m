%% delete file if already existing
dd_file = 'DD_VDM_Configuration.sldd';
if isfile(dd_file)
    dd_obj=Simulink.data.dictionary.open(dd_file);
    saveChanges(dd_obj);
    Simulink.data.dictionary.closeAll
    delete(dd_file);
end


%% crate DD and populate Configuration data
dd_obj = ...
Simulink.data.dictionary.create(dd_file);
dDataSectObj = getSection(dd_obj,'Design Data');

%% Dynamics modeling parameters
addEntry(dDataSectObj,'m',  double(1575));                    % Total mass of vehicle                          (kg)
addEntry(dDataSectObj,'Iz', double(2875));                    % Yaw moment of inertia of vehicle               (m*N*s^2)
addEntry(dDataSectObj,'Cf', double(19000));                   % Cornering stiffness of front tires             (N/rad)
addEntry(dDataSectObj,'Cr', double(33000));                   % Cornering stiffness of rear tires              (N/rad)
%addEntry(dDataSectObj,'lf', egoVehDyn.CGToFrontAxle); % Longitudinal distance from c.g. to front tires (m)
%addEntry(dDataSectObj,'lr', egoVehDyn.CGToRearAxle);  % Longitudinal distance from c.g. to rear tires  (m)
addEntry(dDataSectObj,'lf', double(1.5130)); % Longitudinal distance from c.g. to front tires (m)
addEntry(dDataSectObj,'lr', double(1.3050));  % Longitudinal distance from c.g. to rear tires  (m)
addEntry(dDataSectObj,'v0_ego', double(14.0));  % Longitudinal distance from c.g. to rear tires  (m)


%% Save changes and close
saveChanges(dd_obj);
close(dd_obj);