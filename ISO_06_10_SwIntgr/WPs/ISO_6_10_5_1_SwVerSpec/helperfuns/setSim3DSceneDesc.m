function setSim3DSceneDesc(blkSim3DConfig, scenario)
% Set SceneDesc parameter of Simulation 3D Scene Configuration based on 
% road centers in scenario.

% Valid road centers that are can be used with this example
roadCentersValid = load('laneFollowingRoadCenters.mat',...
                        'roadCentersStraightRoad',...
                        'roadCentersCurvedRoadSegment',...
                        'roadCentersRRHighwayRoad');

% Check the scene used for the scenario based on road centers
if isequal(scenario.RoadCenters, roadCentersValid.roadCentersStraightRoad)
    sceneDesc = "Straight road";
    set_param(blkSim3DConfig, 'ProjectFormat', "Default Scenes");
    set_param(blkSim3DConfig, 'SceneDesc', sceneDesc);
elseif isequal(scenario.RoadCenters, roadCentersValid.roadCentersCurvedRoadSegment)
    sceneDesc = "Curved road";
    set_param(blkSim3DConfig, 'ProjectFormat', "Default Scenes");
    set_param(blkSim3DConfig, 'SceneDesc', sceneDesc);
elseif isequal(scenario.RoadCenters, roadCentersValid.roadCentersRRHighwayRoad)
    % Update sim3D scene config block for Road Runner game.
    pathToUnrealExe = fullfile( ...
        matlabshared.supportpkg.getSupportPackageRoot, ...
        "toolbox","shared","sim3dprojects","driving","RoadRunnerScenes",...
        "WindowsPackage", "RRScene.exe");
    
    % Set block parameters
    if exist(pathToUnrealExe, 'file')
        projectFormat = get_param(blkSim3DConfig, 'ProjectFormat');
        if projectFormat ~= "Unreal Executable"
            set_param(blkSim3DConfig, 'ProjectFormat', "Unreal Executable");
        end
        set_param(blkSim3DConfig, 'ProjectName', pathToUnrealExe);
        set_param(blkSim3DConfig, 'ScenePath', "/Game/Maps/RRHighway");
    end
else
    error("Road centers do not match supported road types.");
end
end