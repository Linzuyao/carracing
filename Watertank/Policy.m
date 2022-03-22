classdef Policy < handle
    properties
    end

    methods
        
        function self = Policy()
            
        end
        
        function action=action(self,observation)
            sys=observation.agent;
            
            u=5;
        	action=[u];
        end
        
        
    end
end