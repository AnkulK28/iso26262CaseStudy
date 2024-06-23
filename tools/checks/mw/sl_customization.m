% Copyright 2021 The MathWorks, Inc.
function sl_customization(cm)

    % Register custom checks
    cm.addModelAdvisorCheckFcn(@defineModelAdvisorChecks);
    cm.addModelAdvisorTaskFcn(@defineTaskAdvisor);

    % Define custom checks
    function defineModelAdvisorChecks
        
        mdladvRoot = ModelAdvisor.Root;
        
        % hisl_0003: Usage of Square Root blocks
        rec = ModelAdvisor.Check('mathworks.example.hisl_0003');
        rec.Title = 'Check usage of Square Root blocks';
        setCallbackFcn(rec, @hisl_0003, 'None', 'StyleOne');
        % Note that converter.deriveMinMax() requires the model to be in
        % compiled state to return useful data. While it does not compile
        % the model, it does terminate the model upon return. This leads to
        % an error when Model Advisor attempts to terminate the model. To
        % avaoid the error, let the check handles the compile state
        % instead.
%         rec.CallbackContext = 'PostCompile';
        mdladvRoot.register(rec);
               
        % hisl_0028: Usage of Reciprocal Square Root blocks
        rec = ModelAdvisor.Check('mathworks.example.hisl_0028');
        rec.Title = 'Check usage of Reciprocal Square Root blocks';
        setCallbackFcn(rec, @hisl_0028, 'None', 'StyleOne');
        % Note that converter.deriveMinMax() requires the model to be in
        % compiled state to return useful data. While it does not compile
        % the model, it does terminate the model upon return. This leads to
        % an error when Model Advisor attempts to terminate the model. To
        % avaoid the error, let the check handles the compile state
        % instead.
%         rec.CallbackContext = 'PostCompile';
        mdladvRoot.register(rec);
        
    end

    % Define custom tasks
    function defineTaskAdvisor
        
        mdladvRoot = ModelAdvisor.Root;
        
        rec = ModelAdvisor.FactoryGroup('mathworks.do178');
        rec.DisplayName = 'High-Integrity Modeling Guidelines';
        rec.Description = 'Additional checks for High-Integrity Modeling Guidelines';
        rec.addCheck('mathworks.example.hisl_0003');
        rec.addCheck('mathworks.example.hisl_0028');
        mdladvRoot.publish(rec);
        
    end

end