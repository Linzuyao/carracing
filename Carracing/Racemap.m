classdef Racemap < handle
    properties
         
    end
    properties (Access = private)
      
    end
    
    
    methods
    
        function self = Racemap()  
 %% test
            addpath('tracks');
            load Tracks/track2.mat
            % use RCP track
            % load Tracks/trackMobil.mat
            safteyScaling = 1.5;
            [track,track2] = borderAdjustment(track2,3,28,safteyScaling);
            [m,n]=size(track.inner);
            for i=1:n
                track.outer(:,i)=track.outer(:,i)+[40;52];
                track.inner(:,i)=track.inner(:,i)+[40;52];
            end
            figure(1);
            plot(track.outer(1,:),track.outer(2,:),'r');
            hold on
            plot(track.inner(1,:),track.inner(2,:),'r');        
        end
 
    end
end