%% delete file if already existing
dd_file = 'DD_WDGC_Configuration.sldd';
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

%% Watchdog Braking controller parameters
addEntry(dDataSectObj, 'Default_decel',   double(0.0));      %Default deceleration (m/s^2)
addEntry(dDataSectObj, 'PB1_decel',       double(3.8));      %1st stage Partial Braking deceleration (m/s^2)
addEntry(dDataSectObj, 'PB2_decel',       double(5.3));      % 2nd stage Partial Braking deceleration (m/s^2)
addEntry(dDataSectObj, 'FB_decel',        double(9.8));      % Full Braking deceleration              (m/s^2)
addEntry(dDataSectObj, 'headwayOffset',   double(3.7));      % headway offset                         (m)
addEntry(dDataSectObj, 'timeMargin',      double(0));
addEntry(dDataSectObj, 'timeToReact',     double(1.2));      % driver reaction time                   (sec)
addEntry(dDataSectObj, 'driver_decel',    double(4.0));      % driver braking deceleration            (m/s^2)

addEntry(dDataSectObj, 'TimeFactor',             double(1.2));
addEntry(dDataSectObj, 'stopVelThreshold',       double(0.1)); %consider vehicle is halting when below this threshold.


%% Save changes and close
saveChanges(dd_obj);
close(dd_obj);
clear dd_file dd_obj dDataSectObj