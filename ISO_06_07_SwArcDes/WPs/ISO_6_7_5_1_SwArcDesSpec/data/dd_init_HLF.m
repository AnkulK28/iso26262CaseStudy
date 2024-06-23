%% delete file if already existing
dd_file = 'DD_HLF_Configuration.sldd';
if isfile(dd_file)
    dd_obj=Simulink.data.dictionary.open(dd_file);
    saveChanges(dd_obj);
    Simulink.data.dictionary.closeAll
    delete(dd_file);
end

LaneWidth = single(3.6); 
HalfLaneWidth = single(LaneWidth/2);
LaneCurveParams_Max = single([0.06 0.15 0.6 0.5]);
LaneCurveParams_Min = -1*LaneCurveParams_Max;

%% crate DD and populate Configuration data
dd_obj = ...
Simulink.data.dictionary.create(dd_file);
dDataSectObj = getSection(dd_obj,'Design Data');


%% define variables
Ts = double(0.1);
PredictionHorizon = single(30);
PredictionTimeSteps = (0:Ts:PredictionHorizon*Ts)';
PredictionNumSteps = length(PredictionTimeSteps);


%% General model parameters
addEntry(dDataSectObj,'Ts',Ts);                   % Algorithm sample time  (s)
addEntry(dDataSectObj,'LaneWidth', LaneWidth);              % Lane Width (m) 
addEntry(dDataSectObj,'HalfLaneWidth', HalfLaneWidth);      % Half lane width (m)

%% Predictoin Horizon
addEntry(dDataSectObj,'PredictionHorizon',PredictionHorizon);    % Prediction horizon 
addEntry(dDataSectObj,'PredictionTimeSteps',PredictionTimeSteps);    % Prediction timesteps
addEntry(dDataSectObj,'PredictionNumSteps',PredictionNumSteps);    % Prediction timesteps

%% selectors
addEntry(dDataSectObj,'posSelector', double([1,0,0,0,0,0; 0,0,1,0,0,0])); % Position selector   (N/A)
addEntry(dDataSectObj,'velSelector', double([0,1,0,0,0,0; 0,0,0,1,0,0])); % Velocity selector   (N/A)

%% Lane Polynomials
addEntry(dDataSectObj,'LaneCurveParams_Max', LaneCurveParams_Max);      % Curve parametrization (max values)
addEntry(dDataSectObj,'LaneCurveParams_Min', LaneCurveParams_Min);      % Curve parametrization (min values)

%% Save changes and close
saveChanges(dd_obj);
close(dd_obj);

clear dd_file dd_obj dDataSectObj LaneWidth HalfLaneWidth