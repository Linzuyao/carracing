clear all;
clc;

%% test
% addpath('tracks');
% load Tracks/track2.mat
% % use RCP track
% % load Tracks/trackMobil.mat
% safteyScaling = 1.2;
% [track,track2] = borderAdjustment(track2,3,28,safteyScaling);
% figure(1);
% plot(track.outer(1,:),track.outer(2,:),'r');
% hold on
% plot(track.inner(1,:),track.inner(2,:),'r');
% figure;
% [m,n]=size(track2.inner);
% for i=1:n
%     track2.outer(:,i)=track2.outer(:,i)+[40;52];
%     track2.inner(:,i)=track2.inner(:,i)+[40;52];
% end
% hold on;
% plot(track2.outer(1,:),track2.outer(2,:),'r');
% plot(track2.inner(1,:),track2.inner(2,:),'r');


abspath=utils('abspath');
env = Env(abspath('sys.ini'));
policy=Policy();
if (env.succeed)
    observation = env.reset();
    while 1
        env.render();
        action=policy.action(observation);
        
        [observation,done,info]=env.step(action);
        
        disp(info);
        if(done)
            break;
        end
        wait(10);
    end
end



function wait (ms)
time=ms/1000;
% tic
pause(time)
% toc
end

