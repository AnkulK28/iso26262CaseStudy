[scenario, assessment] = scenario_LF_01_Straight_RightLane();
% modelName = 'HighwayLaneFollowingControllerAssessment';
% % Configure model before assigning workspace variables
modelName = 'HighwayLaneFollowingControllerAssessment';
load_system(modelName);
blkSim3DConfig = [modelName '/Simulation3DScenario/Simulation3DSceneConfiguration'];
% 
% % Configure the scene config block 
setSim3DSceneDesc(blkSim3DConfig, scenario)

vehSim3D=  vehicleSim3DParams(scenario);
egoVehDyn = egoVehicleDynamicsParams(scenario);
v_set=  egoVehDyn.VLong0;