classdef Policy < handle
    properties
    end

    methods
        
        function self = Policy()
            
        end
        
        function action=action(self,observation)
            if observation.collide
                action=[rand(1),rand(1)-0.5,1]*0.05;
            else
                action=[rand(1),rand(1)-0.5,1]*0.05;
            end
        end
        
        
    end
end