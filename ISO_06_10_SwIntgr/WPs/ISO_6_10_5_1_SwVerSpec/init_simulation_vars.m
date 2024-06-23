%% init simulation parameters
Ts = 0.1;

% Vehicle Dynamics
lf = 1.513;
lr = 1.305;
m = 1575;
Cf = 19000;
Cr = 33000;
Iz = 2875;

% Simple DriveLine and Brakes
tau = 0.5;
tau2 = 0.07;
max_ac = double(2);
max_dc = double(-10);


%% required data types and buses
dataTypesDD = Simulink.data.dictionary.open('DD_HLF_DataTypes.sldd');
dDataSectObj = getSection(dataTypesDD,'Design Data');
LaneSensor = getValue(dDataSectObj.getEntry('LaneSensor'));
LaneSensorBoundaries = getValue(dDataSectObj.getEntry('LaneSensorBoundaries'));
BusMultiObjectTracker = getValue(dDataSectObj.getEntry('BusMultiObjectTracker'));
BusMultiObjectTrackerTracks = getValue(dDataSectObj.getEntry('BusMultiObjectTrackerTracks'));
BusVehiclePose = getValue(dDataSectObj.getEntry('BusVehiclePose'));
BusRadarDetectionsObjectAttributes = getValue(dDataSectObj.getEntry('BusRadarDetectionsObjectAttributes'));

Simulink.data.dictionary.closeAll('-discard');

%% CreateBusActors
BusActors = Simulink.Bus;
BusActors.Description = '';
BusActors.DataScope = 'Auto';
BusActors.HeaderFile = '';
BusActors.Alignment = -1;
saveVarsTmp{1} = Simulink.BusElement;
saveVarsTmp{1}.Name = 'NumActors';
saveVarsTmp{1}.Complexity = 'real';
saveVarsTmp{1}.Dimensions = [1 1];
saveVarsTmp{1}.DataType = 'double';
saveVarsTmp{1}.Min = [];
saveVarsTmp{1}.Max = [];
saveVarsTmp{1}.DimensionsMode = 'Fixed';
saveVarsTmp{1}.SamplingMode = 'Sample based';
saveVarsTmp{1}.DocUnits = '';
saveVarsTmp{1}.Description = '';
saveVarsTmp{1}(2, 1) = Simulink.BusElement;
saveVarsTmp{1}(2, 1).Name = 'Time';
saveVarsTmp{1}(2, 1).Complexity = 'real';
saveVarsTmp{1}(2, 1).Dimensions = [1 1];
saveVarsTmp{1}(2, 1).DataType = 'double';
saveVarsTmp{1}(2, 1).Min = [];
saveVarsTmp{1}(2, 1).Max = [];
saveVarsTmp{1}(2, 1).DimensionsMode = 'Fixed';
saveVarsTmp{1}(2, 1).SamplingMode = 'Sample based';
saveVarsTmp{1}(2, 1).DocUnits = '';
saveVarsTmp{1}(2, 1).Description = '';
saveVarsTmp{1}(3, 1) = Simulink.BusElement;
saveVarsTmp{1}(3, 1).Name = 'Actors';
saveVarsTmp{1}(3, 1).Complexity = 'real';
saveVarsTmp{1}(3, 1).Dimensions = [5 1];
saveVarsTmp{1}(3, 1).DataType = 'Bus: BusVehiclePose';
saveVarsTmp{1}(3, 1).Min = [];
saveVarsTmp{1}(3, 1).Max = [];
saveVarsTmp{1}(3, 1).DimensionsMode = 'Fixed';
saveVarsTmp{1}(3, 1).SamplingMode = 'Sample based';
saveVarsTmp{1}(3, 1).DocUnits = '';
saveVarsTmp{1}(3, 1).Description = '';
BusActors.Elements = saveVarsTmp{1};
clear saveVarsTmp;
%% initialize structs so they can be populated during simulation
lanes=Simulink.Bus.createMATLABStruct('LaneSensor');
vehicleTracks=Simulink.Bus.createMATLABStruct('BusMultiObjectTracker');
Simulink.data.dictionary.closeAll('-discard');

clear dataTypesDD dDataSectObj
