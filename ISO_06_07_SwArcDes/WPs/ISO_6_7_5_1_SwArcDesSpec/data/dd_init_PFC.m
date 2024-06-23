    %% delete file if already existing
dd_file = 'DD_PFC_Configuration.sldd';
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


%% %% Path following controller parameters  
addEntry(dDataSectObj,'tau',             double(0.5));     % Time constant for longitudinal dynamics 1/s/(tau*s+1)
addEntry(dDataSectObj,'time_gap',        double(1.5));     % Time gap               (s)
addEntry(dDataSectObj,'default_spacing', double(10));      % Default spacing        (m)
addEntry(dDataSectObj,'max_ac',          double(2));       % Maximum acceleration   (m/s^2)
addEntry(dDataSectObj,'min_ac',          double(-3));      % Minimum acceleration   (m/s^2)
addEntry(dDataSectObj,'max_steer',       double(0.26));    % Maximum steering       (rad)
addEntry(dDataSectObj,'min_steer',       double(-0.26));   % Minimum steering       (rad) 

%addEntry(dDataSectObj,'v0_ego', egoVehDyn.VLong0); % Initial longitudinal velocity (m/s)

addEntry(dDataSectObj,'tau2',            double(0.07));               % Longitudinal time constant (brake)             (N/A)
addEntry(dDataSectObj,'max_dc',          double(-10));        % Maximum deceleration   (m/s^2)


%% %% Path following controller Input Value Limits
addEntry(dDataSectObj,'mioIgnoreDistanceThreshold',  double(1000));        % Maximum deceleration   (m/s^2)
addEntry(dDataSectObj,'mioIgnoreRelDistance',        double(200));         % Maximum deceleration   (m/s^2)
addEntry(dDataSectObj,'mioIgnoreVelocity',           double(0));           % Maximum deceleration   (m/s^2)
addEntry(dDataSectObj,'longVelUlimit',               double(100));              % Upper limit for Long velocity   (m/s)
addEntry(dDataSectObj,'longVelLlimit',               double(0.00001));              % Lower limit for Long velocity   (m/s)


%% Save changes and close
saveChanges(dd_obj);
close(dd_obj);