classdef Policy < handle
    properties
    end

    methods
        
        function self = Policy()
            
        end
        
        function action=action(self,observation)
            sys=observation.agent;
            % LQR policy
            Q = sys.Cs'*sys.Cs;
            Q(1,1) = 1;
            Q(3,3) = 100;
            R = 1;
            K = lqr(sys.As,sys.Bs,Q,R);
            sys.theta
            %[sys.x-sys.x;sys.dx;(sys.theta-pi);sys.dtheta]
            u=-K*[0;sys.dx;(sys.theta-pi);sys.dtheta]
            Ac = (sys.As-sys.Bs*K);
        	action=[u];
        end
        
        
    end
end