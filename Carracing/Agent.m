%%see https://github.com/alexliniger/MPCC/tree/master

classdef Agent < handle
    properties
        x % x coordinate
        y % y coordinate
        h % heading
        vx % longitudinal velocity
        vy % lateral velocity
        omega % the yaw rate
        pg %  augmented state approximating the progress

        %% parameters for the model
        m % mass
        Iz % inertia
        lf %
        lr %
        Cm1
        Cm2
        Cr0
        Cr2
        Br
        Cr
        Dr
        Bf
        Cf
        Df
        
        
        satLevel %satuation Level
        id
        
        collide % indicate collision
        w % width
        ht %height
        
        
    end
    
    properties (Access = protected)
        occupy_map
        bodycolor
        action
        scanBox
        sensor
        lastState% last state;
        
        headOffset
        bHandle;
        lwHandle;
        rwHandle;
        headHandle;
    end
    
    methods
        
        function self = Agent(x ,y ,h, vx,vy,w,mp,scanRange,scanAngle,id)
            self.x = x;
            self.y = y;
            self.h = h;
            self.vx=vx;
            self.vy=vy;
            self.omega=w;
            self.pg=0;
            self.m=mp.m;
            self.Iz = mp.Iz;
            self.lf =  mp.lf;
            self.lr =  mp.lr;
            self.Cm1= mp.Cm1;
            self.Cm2= mp.Cm2;
            self.Cr0= mp.Cr0;
            self.Cr2= mp.Cr2;
            self.Br= mp.Br;
            self.Cr= mp.Cr;
            self.Dr= mp.Dr;
            self.Bf= mp.Bf;
            self.Cf= mp.Cf;
            self.Df= mp.Df;
            self.size(3,2);
            self.id=id;
            self.headOffset=[self.w*1.5/4;0];
            self.sensor=RangeFinder(0.3,scanRange,scanAngle,self.headOffset);
            self.sensor.updateScan(self.TF());
            self.collide=0;
            self.bodycolor='g';
        end

        function setAgent(self,x ,y ,h)
            self.x = x;
            self.y = y;
            self.h = h;
            self.vx=0;
            self.vy=0;
            self.omega=0;
            self.pg=0;
            if ~isempty(self.sensor)
                self.sensor.updateScan(self.TF());
            end
        end
        
        
        function size(self,w,ht)
            self.w=w;
            self.ht=ht;
        end
        
        function retreat(self)
            self.x =self.lastState(1);
            self.y = self.lastState(2);
            self.h = self.lastState(3);
            self.vx=self.lastState(4);
            self.vy=self.lastState(5);
            self.omega=self.lastState(6);
            self.pg=self.lastState(7);
            if ~isempty(self.sensor)
                self.sensor.updateScan(self.TF());
            end
        end
        
        function step(self,tspan,action)
            self.lastState=[self.x,self.y,self.h,self.vx,self.vy,self.omega,self.pg];
            sat=utils('sat');
            self.action=sat(action,self.satLevel);
            [t, state] = ode45(@(t, state)self.dynamics(t, state), tspan, self.lastState);
            self.x=state(end,1);
            self.y=state(end,2);
            self.h=state(end,3);
            self.vx=state(end,4);
            self.vy=state(end,5);
            self.omega=state(end,6);
            self.pg=state(end,7);
            self.sensor.updateScan(self.TF());
            self.updateOccupyMap();
            %action 1 is for velocity, aciton 2 is for angular velocity
        end
        function tf=TF(self)
            tf= [self.x,self.y,self.h];
        end
        
        function setCollision(self,collide)
            self.collide=collide;
        end
        function setSatLevel(self,level)
            self.satLevel=level;
        end
        function ds = dynamics(self,t,state)
            h=state(3); vx=state(4);
            vy=state(5);w=state(6);
            
            d=self.action(1);
            delta=self.action(2);
            vtheta=self.action(3);
            if(vx < 0.5)
                vx = vx;
                vy = 0;
                w = 0;
                delta = 0;
                if(vx < 0.3)
                    vx = 0.3;
                end
            end
            
            [Ffy,Fry,Frx]=NModel(self,vx,vy,w,d,delta);
            
            dx=vx*cos(h)-vy*sin(h);
            dy=vx*sin(h)+vy*cos(h);
            dh=w;
            dvx=1/self.m*(Frx-Ffy*sin(delta)+self.m*vy*w);
            dvy=1/self.m*(Fry-Ffy*sin(delta)-self.m*vx*w);
            dw=1/self.Iz*(Ffy*self.lf*cos(delta)-Fry*self.lr);
            dpg=vtheta;
            
            ds=[dx;dy;dh;dvx;dvy;dw;dpg];
        end
        
        function in=insideScan(self, point)
            in= self.sensor.insideScan(point);
        end
        
        function [Ffy,Fry,Frx]=NModel(self,vx,vy,w,d,delta)
            af=-atan2(w*self.lf+vy,vx)+delta;
            ar=atan2(w*self.lr-vy,vx);
            Ffy=self.Df*sin(self.Cf*atan(self.Bf*af));
            Fry=self.Dr*sin(self.Cr*atan(self.Br*ar));
            Frx=(self.Cm1-self.Cm2*vx)*d-self.Cr0-self.Cr2*vx^2;
        end
            
        
        function plot(self,handle)
            rotMat2=utils('rotMat2');
            rm=rotMat2(self.h);
            corners=[-self.w/2,-self.ht/2;
                -self.w/2,self.ht/2;
                self.w/2,self.ht/2;
                self.w/2,-self.ht/2;];
            body_corners=[self.x;self.y]+rm*corners';
            if isempty(self.bHandle)
                self.bHandle=fill(handle,body_corners(1,:),body_corners(2,:),self.bodycolor);
            else
               set(self.bHandle,'XData',body_corners(1,:),'YData',body_corners(2,:));
            end
            
            
            wheel_h=0.2;
            wheel_y=self.ht*0.8/2;
            corners=[-self.w/4,-wheel_y;
                self.w/4,-wheel_y;
                self.w/4,-wheel_y+wheel_h;
                -self.w/4,-wheel_y+wheel_h; ];
            rwheel_corners=[self.x;self.y]+rm*corners';
            if isempty(self.lwHandle)
                self.lwHandle=fill(handle,rwheel_corners(1,:),rwheel_corners(2,:),'b');
            else
               set(self.lwHandle,'XData',rwheel_corners(1,:),'YData',rwheel_corners(2,:));
            end
            
            corners=[-self.w/4,wheel_y;
                self.w/4,wheel_y;
                self.w/4,wheel_y-wheel_h;
                -self.w/4,wheel_y-wheel_h; ];
            lwheel_corners=[self.x;self.y]+rm*corners';
            if isempty(self.rwHandle)
                self.rwHandle=fill(handle,lwheel_corners(1,:),lwheel_corners(2,:),'b');  
            else
               set(self.rwHandle,'XData',lwheel_corners(1,:),'YData',lwheel_corners(2,:));
            end
            
            
             
             
             head=self.headOffset;
             offset=self.ht/8;
             head_courners=[head(1) head(1)-offset  head(1)-offset head(1);
                          head(2) head(2)+offset head(2)-offset head(2)];           
             head_courners=[self.x;self.y]+rm*head_courners;                   
            if isempty(self.headHandle)
                self.headHandle=plot(head_courners(1,:),head_courners(2,:),'k-');
            else
               set(self.headHandle,'XData',head_courners(1,:),'YData',head_courners(2,:));
            end
            
            if ~isempty(self.sensor)
                self.sensor.plot(handle,self.TF());
            end
        end
        
            
        function coords=updateOccupyMap(self) 
            rotMat2=utils('rotMat2');
            rm=rotMat2(self.h);
            
            [X,Y]=meshgrid(-self.w/2:1:self.w/2, ... 
                -self.ht/2:1:self.ht/2);
            X=reshape(X,1,numel(X));
            Y=reshape(Y,1,numel(X));
            coords=[X;Y];
            coords=rm*coords;
            coords=coords+[self.x;self.y];
            coords=ceil(coords);
            coords=unique(coords','rows');
            coords=coords';
           self.occupy_map=coords;
        end
        
        function coords=scanMap(self)
            coords=self.sensor.occupyMap(self.TF());
        end
        
        function coords=occupyMap(self) 
            coords=self.occupy_map;
        end
        
    end
    
end