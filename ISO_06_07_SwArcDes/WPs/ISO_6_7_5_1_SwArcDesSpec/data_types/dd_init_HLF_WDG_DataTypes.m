%% delete file if already existing
dd_file = 'DD_HLF_WDG_DataTypes.sldd';
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

%% TTC typing 
addEntry(dDataSectObj,'TTC_DType', 'double'); 
addEntry(dDataSectObj,'TTC_Min', []); 
addEntry(dDataSectObj,'TTC_Max', []); 
addEntry(dDataSectObj,'TTC_Dimensions', 1); 
addEntry(dDataSectObj,'TTC_Complexity', 'real'); 
addEntry(dDataSectObj,'TTC_Unit', 's'); 


%% Stopping Time Typing 
addEntry(dDataSectObj,'StopTime_DType', 'double'); 
addEntry(dDataSectObj,'StopTime_Min', 0);  %already stopped
addEntry(dDataSectObj,'StopTime_Max', 40); %assume velocity 0-140 m/s (or 500 kmh), deceleration 3.8-10 m/s^2   
addEntry(dDataSectObj,'StopTime_Dimensions', 1); 
addEntry(dDataSectObj,'StopTime_Complexity', 'real'); 
addEntry(dDataSectObj,'StopTime_Unit', 's');


addEntry(dDataSectObj,'BrStatus_DType', 'Enum: BrStatus'); 
addEntry(dDataSectObj,'BrStatus_Dimensions', 1); 
addEntry(dDataSectObj,'BrStatus_Complexity', 'real'); 
addEntry(dDataSectObj,'BrStatus_Unit', '');

%% Save changes and close
saveChanges(dd_obj);
close(dd_obj);

clear dd_file dd_obj dDataSectObj saveVarsTmp
