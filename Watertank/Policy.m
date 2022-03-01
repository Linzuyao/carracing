classdef Policy < handle
    properties
    end

    methods
        
        function self = Policy()
            
        end
        
        function action=action(self,observation)
            sys=observation.agent;
            u=3*sin(observation.t);
        	action=[u];
        end
        
        
    end
end