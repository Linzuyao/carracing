classdef WaterTank < handle
    properties
        H             % water level
        targetHeight
        satLevel    %satuation Level
    end
    
    properties (Access = protected)
        action
        lastState% last state;
        
        tank_w    % tank width
        tank_h    % tank height
        a            % input rate
        b            % output rate
        x
        y
        waterHandle;
        tankHandle;
        targetHandle;
    end
    
    methods
        
        function setTargetHeight(self,h)
            self.targetHeight=h;
        end
        function self = WaterTank(startPos,h)
            self.H=h;
            self.setAgent(startPos);
            self.size(10,30);
            self.b=3;
            self.a=2;
        end
        

        function setAgent(self,startPos)
            self.x = startPos.x;
            self.y = startPos.y;
        end
        
        
        function size(self,w,h)
            self.tank_w=w;
            self.tank_h=h;
        end
        
        
        function step(self,tspan,action)
            self.lastState=self.H;
            sat=utils('sat');
            self.action=sat(action,self.satLevel);
            [t, state] = ode45(@(t, state)self.dynamics(t, state), tspan, self.lastState);
            self.H=state(end,1);
            %action is for applied force
        end
        
        function setSatLevel(self,level)
            self.satLevel=level;
        end
        
        % refer to the article https://zhuanlan.zhihu.com/p/54071212
        function ds = dynamics(self,t,state)
            xh=state(1);
            if xh<=0
                dH=0;
            else
                dH=self.b*self.action-self.a*sqrt(xh);
            end
            
            ds=dH;
        end
        
        
        
        function plot(self,handle)
            tank_corners=[self.x,self.y;
                self.x+self.tank_w,self.y;
                self.x+self.tank_w,self.y+self.tank_h;
                self.x,self.y+self.tank_h; self.x,self.y;]';
            if isempty(self.tankHandle)
                self.tankHandle=plot(handle,tank_corners(1,:),tank_corners(2,:),'g');
            else
               set(self.tankHandle,'XData',tank_corners(1,:),'YData',tank_corners(2,:));
            end
            

            
            water_corners=[self.x,self.y;
                self.x+self.tank_w,self.y;
                self.x+self.tank_w,self.y+self.H;
                self.x,self.y+self.H;]';
                  
            
            if isempty(self.waterHandle)
                self.waterHandle=fill(handle,water_corners(1,:),water_corners(2,:),'b');
            else
               set(self.waterHandle,'XData',water_corners(1,:),'YData',water_corners(2,:));
            end
            
            target_line=[self.x-2,self.y+self.targetHeight;
                self.x+self.tank_w+2,self.y+self.targetHeight;]';
            if isempty(self.targetHandle)
                self.targetHandle=plot(handle,target_line(1,:),target_line(2,:),'r');
            else
               set(self.targetHandle,'XData',target_line(1,:),'YData',target_line(2,:));
            end
        end
        
        
    end
    
end