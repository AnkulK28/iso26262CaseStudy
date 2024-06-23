classdef BrStatus < Simulink.IntEnumType
    enumeration
        NoBrake(0),
        PB1Brake(1),
        PB2Brake(2),
        FBrake(3)
    end
    
    methods (Static)
        function retVal = getDefaultValue()
            retVal = BrStatus.NoBrake;
        end
        
        function retVal = getDataScope()
            retVal = 'Exported';
        end
        function retVal = getHeaderFile()
            retVal = 'BrStatus.h';
        end
    end
    
    
end