classdef Env < handle
    properties
        succeed
        info
    end
    properties (Access =  {?Score,?Observation})
        map  % global map
        agentInfo % ini for agent
        sysInfo  % ini for system
        collide % check if agent collides
        t  % current time
        smartAgentNumber %number of smart agent
        collideWithSmartAgent % check if agent collides with smart agent
    end
    properties   (Access =  {?Observation})
        scanMap  % the map that sensor sensed
        score    % current score
        startPos  % the start point for agent
        endPos   % the target point for agent
    end
    properties (Access = private)
        render_st
        mainAgent
  %      pfmap % potential field map for the smart agents to avoid obstacles
        id
        obj_idx
        objs
        viewer  % render
        st % step time
        collisionMap % for all agents collision with obstacles
        collisionMapAgent % for collision between main agent and other agents
        collisionMapMainAgent; % for collision between main agent and other agents and obstacles together
        mapInfo % ini for map
        sensorInfo % ini for sensor(RangerFinder)
        gameover  % status for the game
        w % width
        h % height
        obv        % observation
        movieWriter
    end
    methods
        
        function a=getMainAgent(self)
            a=self.mainAgent;
        end
        
        function self = Env(file)
            if exist(file,'file')
                self.loadIni(file);
                self.succeed=1;
            else
                self.succeed=0;
                return;
            end
            
            self.w = self.mapInfo.w;
            self.h = self.mapInfo.h;
            self.map=Map(self.w,self.h);
            if ~self.mapInfo.random
                self.map.load(self.mapInfo.name)
            else
                self.map.randomMap();
            end
            self.obj_idx=0;
            
            self.render_st=self.sysInfo.render_st;
            self.scanMap=zeros(self.h,self.w);
            self.collisionMap=zeros(self.h,self.w);
            self.collisionMapAgent=zeros(self.h,self.w);
            self.collisionMapMainAgent=zeros(self.h,self.w);
     %       self.pfmap=PotentialField(self.map.occupyMap());
            self.obv=Observation();
            agent=Agent(self.startPos.x,self.startPos.y,self.startPos.heading,...
                self.sensorInfo.scanRange,self.sensorInfo.scanAngle,self.obj_idx+1);
            agent.setSatLevel([self.agentInfo.usat,self.agentInfo.vsat]);
            viewer=Viewer(self.w,self.h);
            %self.objs=Agent.empty(20,0);
            self.mainAgent=agent;
            self.addObject(agent);
            self.smartAgentNumber=self.sysInfo.smartAgent
            for i=1:self.smartAgentNumber
                self.generateSmartAgent();
            end
            self.addViewer(viewer);
            self.startRecord();
            self.reset();
        end
        
        function generateSmartAgent(self)
            agent='';
            while 1
                pos= self.map.generatePos();
                
                agent=SmartAgent(pos(1),pos(2),(rand(1)-0.5)*2*pi,[self.agentInfo.usat,self.agentInfo.vsat],self.obj_idx+1);
               % agent=SmartAgent(6,6,(rand(1)-0.5)*2*pi,[self.agentInfo.usat,self.agentInfo.vsat],self.obj_idx+1);
                agentCoords=agent.updateOccupyMap();
        %%%change start
                collideState=self.collisionWithDilatedObstacles(agentCoords,agent.id);
        %%%change end
                if ~collideState
                    break;
                end
            end
            self.generateTargetPosForAgent(agent)
            self.addObject(agent);
        end

        %%%change start
        function map=dilate(~,map0)
            map1=map0;
            for i=1:size(map0,1)
                for j=1:size(map0,2)
                    if(map0(i,j)==1)
                        flag=1;
                        min=1;
                        max=50;
                        if j-1>=min
                            map1(i,j-1)=flag;
                        end
                        if j+1<=max
                            map1(i,j+1)=flag;
                        end
                        if i-1>=min
                            map1(i-1,j)=flag;
                        end
                        if i-1>=min&&j-1>=min
                            map1(i-1,j-1)=flag;
                        end
                        if i-1>=min&&j+1<=max
                            map1(i-1,j+1)=flag;
                        end
                        if i+1<=max
                            map1(i+1,j)=flag;
                        end
                        if i+1<=max&&j-1>=min
                            map1(i+1,j-1)=flag;
                        end
                        if i+1<=max&&j+1<=max
                            map1(i+1,j+1)=flag;
                        end                            
                    end
                end
            end
            map=map1;
        end
        function map=dilate2(~,map0)
            map1=map0;
            for i=1:size(map0,1)
                for j=1:size(map0,2)
                    if(map0(i,j)==1)
                        flag=1;
                        min=1;
                        max=50;
                        if j-1>=min
                            map1(i,j-1)=flag;
                        end
                        if j+1<=max
                            map1(i,j+1)=flag;
                        end
                        if i-1>=min
                            map1(i-1,j)=flag;
                        end
                        if i+1<=max
                            map1(i+1,j)=flag;
                        end                           
                    end
                end
            end
            map=map1;
        end
        function map=dilate3(~,map0)
            map1=map0;
            for i=1:size(map0,1)
                max=size(map0,1);
                map1(max,i)=1;
                map1(1,i)=1;
                map1(i,max)=1;
                map1(i,1)=1;
                map1(max-1,i)=1;
                map1(2,i)=1;
                map1(i,max-1)=1;
                map1(i,2)=1;
            end
            map=map1;
        end
        function collide=collisionWithDilatedObstacles(self,agentCoords,agentID)
            %'Collision'
            agentCoords=self.clipCoord(agentCoords);
            obmap=self.map.occupyMap();
            obmap=self.dilate2(obmap);
            obmap=self.dilate2(obmap);
            obmap=self.dilate2(obmap);
            obmap=self.dilate3(obmap);
            len=size(agentCoords,2);
            collide=0;
            for i=1:len
                  %  agentCoords(2,i)
                 %   agentID
                if obmap(agentCoords(2,i),agentCoords(1,i))==1
                    self.collisionMap(agentCoords(2,i),agentCoords(1,i))=agentID;
                    collide=1;
                end
            end
        end
        %%%change end

        function generateTargetPosForAgent(self, agent)
            sp=[agent.x agent.y agent.h];
            while 1
                targetPos= self.map.generatePos();
                agent.setAgent(targetPos(1),targetPos(2),sp(3));
                agentCoords=agent.updateOccupyMap();
        %%%change start
                collideState=self.collisionWithDilatedObstacles(agentCoords,agent.id);
        %%%change end
                if ~collideState
                    break;
                end
            end
            
           % astar=AStar(sp(1:2)',targetPos,self.map);
            agent.setAgent(sp(1),sp(2),sp(3));
            agent.setTarget(targetPos);
   %         agent.setPFMap(self.pfmap);
        end
        
        function observation=reset(self)
            self.gameover=0;
            self.collide=0;
            self.t=0;
            self.st=self.sysInfo.st;
            self.score=Score(self);
            self.getMainAgent().setAgent(self.startPos.x,self.startPos.y,self.startPos.heading);
            self.obv.setObservation(self,self.sysInfo.globalview);
            observation=self.obv;
            self.info='';
        end


        
        function [observation,done,info]=step(self,action)
            tspan=[self.t self.t+self.st];
            self.initCollisionMatrix();
            for i=1:self.obj_idx
                if i==1
                    self.objs{i}.step(tspan,action);
                else
                    mapForSmartAgent=self.map.occupyMap();
                    mapForSmartAgent=mapForSmartAgent';
                    self.objs{i}.step(tspan,mapForSmartAgent);
                end
                agentCoords=self.objs{i}.occupyMap();
                
                % check agent collision with obstacle
                collideState=self.collisionWithObstacles(agentCoords,self.objs{i}.id);
                if collideState
                    self.objs{i}.retreat();
                end
                self.objs{i}.setCollision(collideState);
                if i==1
                    scanCoords=self.objs{i}.scanMap();
                    self.checkScan(scanCoords);
                end
            end
            self.t=self.t+self.st;
            
            % check collision among agents
            
            self.collisionMapAgent=zeros(self.h,self.w);
            self.collisionAmongAgents();
            self.checkCollision();
            self.checkGame();
            
            %reset the target pose for smart agent
            for i=2:self.obj_idx
                if self.objs{i}.targetReached==1
                    targetPos= self.map.generatePos();
                    self.generateTargetPosForAgent(self.objs{i});
                end
            end
            
            
            self.obv.setObservation(self,self.sysInfo.globalview);
            observation=self.obv;
            done= self.gameover;
            if(self.t>self.sysInfo.tend)
                done=1;
            end
            self.score.assess(self);
            self.updateInfo();
            info=self.info;
            if done
                self.done();
            end
        end
        
        function checkCollision(self)
            tempMap=(self.collisionMap==1);
            self.collisionMapMainAgent=max(self.collisionMapAgent,tempMap);
            self.collide=sum(sum( self.collisionMapMainAgent));
            self.collideWithSmartAgent=sum(sum( self.collisionMapAgent));
        end
        function done(self)
            self.stopRecord();
        end
        
        function collide=collisionAmongAgents(self)
            % tempMap to indicate which agent occupies the grid.
            tempMap=self.collisionMapAgent;
            for i=2:self.obj_idx
                agentCoords=self.objs{i}.occupyMap();
                agentCoords=self.clipCoord(agentCoords);
                len=size(agentCoords,2);
                for j=1:len
                    tempMap(agentCoords(2,j),agentCoords(1,j))=self.objs{i}.id;
                end
            end
            
            mainAgentCoords=self.mainAgent.occupyMap();
            mainAgentCoords=self.clipCoord(mainAgentCoords);
            collide=0;
            for i=1:size(mainAgentCoords,2)
                % if the grid that is occupied by main agent is also
                % occupied by other agent, then  
                if tempMap(mainAgentCoords(2,i),mainAgentCoords(1,i))>0
                    self.collisionMapAgent(mainAgentCoords(2,i),mainAgentCoords(1,i))=tempMap(mainAgentCoords(2,i),mainAgentCoords(1,i));
                    collide=collide+1;
                end
            end
            collide=collide>0;
            
        end
        
        function render(self)
            persistent render_idx
            if isempty(render_idx)
                render_idx=0;
            end
            brender=0;
            if(self.t>=render_idx*self.render_st)
                render_idx=render_idx+1;
                brender=1;
            else
                brender=0;
            end
            
            
            if brender==1
                if self.sysInfo.showViewer || self.sysInfo.record
                    if(self.sysInfo.showViewer)
                        self.viewer.show(1);
                    else
                        self.viewer.show(0);
                    end
                    
                    self.viewer.reInitAxe(self.t);
                    self.map.plot(self.viewer.ax);
                    for i=1:self.obj_idx
                        self.objs{i}.plot(self.viewer.ax);
                    end
                    self.plotInfo();
                    self.plotEndPos(self.viewer.ax);
                    self.record();
                else
                    self.viewer.show(0);
                end
            end
            
        end
    end
    methods (Access = private)
        
        function map=getMap(self)
            map=self.map.occupyMap();
        end
        function loadIni(self,file)
            I = INI('File',file);
            INI file reading;
            I.read();
            sec = I.get('Sections');
            for i=1:length(sec)
                switch sec{i}
                    case 'StartPos'
                        self.startPos=I.get('StartPos');
                    case 'EndPos'
                        self.endPos=I.get('EndPos');
                    case 'Map'
                        self.mapInfo=I.get('Map');
                    case 'RangeFinder'
                        self.sensorInfo=I.get('RangeFinder');
                    case 'Agent'
                        self.agentInfo=I.get('Agent');
                    case 'System'
                        self.sysInfo=I.get('System');
                end
            end
        end
        
        function addObject(self,obj)
            self.obj_idx=self.obj_idx+1;
            self.objs{self.obj_idx}=obj;
        end
        
        function addViewer(self,v)
            self.viewer=v;
        end
        
        function checkScan(self,scanCoords)
            %'Scan'
            scanCoords=self.clipCoord(scanCoords);
            obmap=self.map.occupyMap();
            len=size(scanCoords,2);
            self.scanMap(:,:)=0;
            for i=1:len
                if obmap(scanCoords(2,i),scanCoords(1,i))==1
                    self.scanMap(scanCoords(2,i),scanCoords(1,i))=1;
                end
            end
            
            %sum(sum(self.scanMap));
        end
        
        function coords=clipCoord(self,coords)
            coords(coords<1)=1;
            coords(1,coords(1,:)>self.w)=self.w;
            coords(2,coords(2,:)>self.h)=self.h;
        end
        
        function startRecord(self)
            if(self.sysInfo.record)
                filename=strcat('movies/',self.sysInfo.recordfile,'.avi');
                self.movieWriter= VideoWriter(filename); % Name it.
                self.movieWriter.FrameRate = self.sysInfo.frameRate; % How many frames per second.
                open(self.movieWriter);
            end
        end
        function record(self)
            if self.sysInfo.record
                drawnow;
                writeVideo(self.movieWriter, getframe(self.viewer.getHandle()));
            end
        end
        function stopRecord(self)
            if self.sysInfo.record
                close(self.movieWriter);
            end
        end
        
        function initCollisionMatrix(self)
            self.collisionMap(:,:)=0;
            self.collisionMapAgent(:,:)=0;
            self.collisionMapMainAgent(:,:)=0;
            
        end
        function collide=collisionWithObstacles(self,agentCoords,agentID)
            %'Collision'
            agentCoords=self.clipCoord(agentCoords);
            obmap=self.map.occupyMap();
            len=size(agentCoords,2);
            collide=0;
            for i=1:len
                  %  agentCoords(2,i)
                 %   agentID
                if obmap(agentCoords(2,i),agentCoords(1,i))==1
                    self.collisionMap(agentCoords(2,i),agentCoords(1,i))=agentID;
                    collide=1;
                end
            end
        end
        
        function updateInfo(self)
            self.info='Current Running Time: '+string(self.t)+' s, Current Score: '+string(self.score.score);
        end
        
        function plotEndPos(self,handle)
            persistent hPlot;
            
            X=[self.endPos.x self.endPos.x+1 self.endPos.x+1 self.endPos.x self.endPos.x];
            Y=[self.endPos.y self.endPos.y self.endPos.y+1 self.endPos.y+1 self.endPos.y];
            
            X=[X self.endPos.x self.endPos.x+1 ];
            Y=[Y self.endPos.y self.endPos.y+1];
            
            X=[X self.endPos.x+1 self.endPos.x];
            Y=[Y self.endPos.y self.endPos.y+1];
            if isempty(hPlot)
                hPlot=plot(handle,X,Y,'r-','linewidth',3);
            else
                set(hPlot,'XData',X,'YData',Y);
            end
        end
        
        function plotInfo(self)
            self.viewer.title(self.info);
        end
        
        function checkGame(self)
            agent=self.getMainAgent();
            if abs(agent.x-self.endPos.x)<1 && abs(agent.y-self.endPos.y)<1
                self.gameover=1;
            end
        end
    end
    
end