classdef Policy < handle
    properties
    end

    methods
        
        function self = Policy()
            
        end
        
        function action=action(self,observation)
            if observation.collide
                action=[-10,rand(1)-0.5];
            else
                action=[10,rand(1)-0.5];
            end
        end
        
        
    end
end