# IC_Challenge

## 简介
IC_Challenge是华中科技大学人工智能与自动化学院本科生《智能控制》课程设置的一个课程设计挑战，主要鼓励采用《智能控制》课程教授的知识，解决相关应用中的问题。

## Arena比赛挑战

### Arena Challenge简介
Arena Challenge是一个由Matlab代码编写的仿真环境。主要要求挑战者编写Matlab代码控制小车在一个地图环境中从起点运行至终点，地图中随机放置着障碍物(见下图）。小车是一个unicycle的动力系统（见下文解释），并装有“雷达”探测器，可探测前方障碍物情况。最终的成绩由小车到达终点的时间以及小车是否撞上障碍物等情况综合评估而得。

挑战者提交其设计的控制策略，我们将测试控制策略在随机地图和不同配置下的得分情况，得到策略的最终得分。

![](arena/pics/arena_preview.png)

### 1. 小车动力学模型
小车的动力学模型，如下公式所示

![](arena\pics\unicycle.png)

其中，[x,y,$\theta$]分别是小车当前的空间位置和朝向。[u,v]是小车的控制量，u相当于小车的“油门”踏板，控制小车的前车速度；v是小车的“方向盘”，控制小车的转动速度。这是挑战者在编写代码时，唯一可以控制小车的两个物理量。

另外仿真环境对小车设置了“饱和”机制（如下图所示），即挑战者传递给仿真器的小车两个控制量，将会被限制在一定范围内。

![](arena\pics\saturation.png)


### 2. 雷达探测器
小车前方有一个前向的雷达传感器，可探测前方是否有障碍物，如有障碍物将，将会把障碍物信息告知挑战者。

### 3. Observation（当前环境信息）

仿真环境每隔一段时间，将会把仿真环境的信息以Observation类的形式告知挑战者，它的成员变量包含  
```
agent		%当前小车信息  
scanMap	%当前雷达探测器探测到的信息  
t            	%当前所用时间  
collide    	%当前是否发生碰撞  
score      	%当前挑战者的分数  
startPos   	%小车起始位置  
endPos     	%小车目标位置  
map         	%全局地图  
```

### 4. 得分
在挑战开始时，挑战者将有一个基本分数，如挑战者控制小车与障碍物发生碰撞则会相应地扣分，如挑战者控制小车驶离地图范围会相应地扣分（扣分权重很大），如挑战者控制小车未在规定时间内到达终点，则超出时间每秒都会相应地扣分。

### 5. 设计控制策略
挑战者需要设计并提交一个Policy类文件，主要完成action函数。action函数传入参数为observation，传出action。仿真器会在特点的时间间隔调用action，依据挑战者设计的策略得到action，即控制量[u,v]，从而控制小车。
```
classdef Policy < handle        function action=action(self,observation)            if observation.collide                action=[-10,rand(1)-0.5];            else                action=[10,rand(1)-0.5];            end        end
```

### 6. Main函数
以下是Main函数的基本代码，main读取系统配置文件对仿真环境进行配置，之后进入仿真循环。在循环中，仿真器对Arena Challenge进行物理仿真，计算出小车位置和状态，是否发生碰撞等信息。并且每一次都用挑战者设计控制策略，然后把控制策略作用于小车的控制中。
```
env = Env('sys.ini');   %读取系统配置文件policy=Policy();if (env.succeed)    observation = env.reset();    while 1        env.render();        action=policy.action(observation); %调用挑战者的控制策略        [observation,done,info]=env.step(action); %物理仿真        disp(info);        if(done)            break;        end        wait(100);    endend```

### 7. 仿真配置文件sys.ini
为了方便挑战者进行测试，挑战者可以通过仿真配置文件sys.ini，进行相应配置。例如配置小车的起始和终止点，小车控制饱和范围，是否录制游戏运行过程等。具体见该文件。


## 代码提交网站
http://www.rayliable.net/manage/account/login

## Leader Board(排名榜)![](data:image/jpeg;base64,IyBJQ19DaGFsbGVuZ2UKCiMjIOeugOS7iwpJQ19DaGFsbGVuZ2XmmK/ljY7kuK3np5HmioDlpKflrabkurrlt6Xmmbrog73kuI7oh6rliqjljJblrabpmaLmnKznp5HnlJ/jgIrmmbrog73mjqfliLbjgIvor77nqIvorr7nva7nmoTkuIDkuKror77nqIvorr7orqHmjJHmiJjvvIzkuLvopoHpvJPlirHph4fnlKjjgIrmmbrog73mjqfliLbjgIvor77nqIvmlZnmjojnmoTnn6Xor4bvvIzop6PlhrPnm7jlhbPlupTnlKjkuK3nmoTpl67popjjgIIKCiMjIEFyZW5h5q+U6LWb5oyR5oiYCgojIyMgQXJlbmEgQ2hhbGxlbmdl566A5LuLCkFyZW5hIENoYWxsZW5nZeaYr+S4gOS4queUsU1hdGxhYuS7o+eggee8luWGmeeahOS7v+ecn+eOr+Wig+OAguS4u+imgeimgeaxguaMkeaImOiAhee8luWGmU1hdGxhYuS7o+eggeaOp+WItuWwj+i9puWcqOS4gOS4quWcsOWbvueOr+Wig+S4reS7jui1t+eCuei/kOihjOiHs+e7iOeCue+8jOWcsOWbvuS4remaj+acuuaUvue9ruedgOmanOeijeeJqSjop4HkuIvlm77vvInjgILlsI/ovabmmK/kuIDkuKp1bmljeWNsZeeahOWKqOWKm+ezu+e7n++8iOingeS4i+aWh+ino+mHiu+8ie+8jOW5tuijheacieKAnOmbt+i+vuKAneaOoua1i+WZqO+8jOWPr+aOoua1i+WJjeaWuemanOeijeeJqeaDheWGteOAguacgOe7iOeahOaIkOe7qeeUseWwj+i9puWIsOi+vue7iOeCueeahOaXtumXtOS7peWPiuWwj+i9puaYr+WQpuaSnuS4iumanOeijeeJqeetieaDheWGtee7vOWQiOivhOS8sOiAjOW+l+OAggoK5oyR5oiY6ICF5o+Q5Lqk5YW26K6+6K6h55qE5o6n5Yi2562W55Wl77yM5oiR5Lus5bCG5rWL6K+V5o6n5Yi2562W55Wl5Zyo6ZqP5py65Zyw5Zu+5ZKM5LiN5ZCM6YWN572u5LiL55qE5b6X5YiG5oOF5Ya177yM5b6X5Yiw562W55Wl55qE5pyA57uI5b6X5YiG44CCCgohW10oYXJlbmEvcGljcy9hcmVuYV9wcmV2aWV3LnBuZykKCiMjIyAxLiDlsI/ovabliqjlipvlrabmqKHlnosK5bCP6L2m55qE5Yqo5Yqb5a2m5qih5Z6L77yM5aaC5LiL5YWs5byP5omA56S6CgohW10oYXJlbmFccGljc1x1bmljeWNsZS5wbmcpCgrlhbbkuK3vvIxbeCx5LCRcdGhldGEkXeWIhuWIq+aYr+Wwj+i9puW9k+WJjeeahOepuumXtOS9jee9ruWSjOacneWQkeOAglt1LHZd5piv5bCP6L2m55qE5o6n5Yi26YeP77yMdeebuOW9k+S6juWwj+i9pueahOKAnOayuemXqOKAnei4j+adv++8jOaOp+WItuWwj+i9pueahOWJjei9pumAn+W6pu+8m3bmmK/lsI/ovabnmoTigJzmlrnlkJHnm5jigJ3vvIzmjqfliLblsI/ovabnmoTovazliqjpgJ/luqbjgILov5nmmK/mjJHmiJjogIXlnKjnvJblhpnku6PnoIHml7bvvIzllK/kuIDlj6/ku6XmjqfliLblsI/ovabnmoTkuKTkuKrniannkIbph4/jgIIKCuWPpuWkluS7v+ecn+eOr+Wig+WvueWwj+i9puiuvue9ruS6huKAnOmlseWSjOKAneacuuWItu+8iOWmguS4i+WbvuaJgOekuu+8ie+8jOWNs+aMkeaImOiAheS8oOmAkue7meS7v+ecn+WZqOeahOWwj+i9puS4pOS4quaOp+WItumHj++8jOWwhuS8muiiq+mZkOWItuWcqOS4gOWumuiMg+WbtOWGheOAggoKIVtdKGFyZW5hXHBpY3Ncc2F0dXJhdGlvbi5wbmcpCgoKIyMjIDIuIOmbt+i+vuaOoua1i+WZqArlsI/ovabliY3mlrnmnInkuIDkuKrliY3lkJHnmoTpm7fovr7kvKDmhJ/lmajvvIzlj6/mjqLmtYvliY3mlrnmmK/lkKbmnInpmpznoo3nianvvIzlpoLmnInpmpznoo3nianlsIbvvIzlsIbkvJrmiorpmpznoo3niankv6Hmga/lkYrnn6XmjJHmiJjogIXjgIIKCiMjIyAzLiBPYnNlcnZhdGlvbu+8iOW9k+WJjeeOr+Wig+S/oeaBr++8iQoK5Lu/55yf546v5aKD5q+P6ZqU5LiA5q615pe26Ze077yM5bCG5Lya5oqK5Lu/55yf546v5aKD55qE5L+h5oGv5LulT2JzZXJ2YXRpb27nsbvnmoTlvaLlvI/lkYrnn6XmjJHmiJjogIXvvIzlroPnmoTmiJDlkZjlj5jph4/ljIXlkKsgIApgYGAKYWdlbnQJCSXlvZPliY3lsI/ovabkv6Hmga8gIApzY2FuTWFwCSXlvZPliY3pm7fovr7mjqLmtYvlmajmjqLmtYvliLDnmoTkv6Hmga8gIAp0ICAgICAgICAgICAgCSXlvZPliY3miYDnlKjml7bpl7QgIApjb2xsaWRlICAgIAkl5b2T5YmN5piv5ZCm5Y+R55Sf56Kw5pKeICAKc2NvcmUgICAgICAJJeW9k+WJjeaMkeaImOiAheeahOWIhuaVsCAgCnN0YXJ0UG9zICAgCSXlsI/ovabotbflp4vkvY3nva4gIAplbmRQb3MgICAgIAkl5bCP6L2m55uu5qCH5L2N572uICAKbWFwICAgICAgICAgCSXlhajlsYDlnLDlm74gIApgYGAKCiMjIyA0LiDlvpfliIYK5Zyo5oyR5oiY5byA5aeL5pe277yM5oyR5oiY6ICF5bCG5pyJ5LiA5Liq5Z+65pys5YiG5pWw77yM5aaC5oyR5oiY6ICF5o6n5Yi25bCP6L2m5LiO6Zqc56KN54mp5Y+R55Sf56Kw5pKe5YiZ5Lya55u45bqU5Zyw5omj5YiG77yM5aaC5oyR5oiY6ICF5o6n5Yi25bCP6L2m6am256a75Zyw5Zu+6IyD5Zu05Lya55u45bqU5Zyw5omj5YiG77yI5omj5YiG5p2D6YeN5b6I5aSn77yJ77yM5aaC5oyR5oiY6ICF5o6n5Yi25bCP6L2m5pyq5Zyo6KeE5a6a5pe26Ze05YaF5Yiw6L6+57uI54K577yM5YiZ6LaF5Ye65pe26Ze05q+P56eS6YO95Lya55u45bqU5Zyw5omj5YiG44CCCgojIyMgNS4g6K6+6K6h5o6n5Yi2562W55WlCuaMkeaImOiAhemcgOimgeiuvuiuoeW5tuaPkOS6pOS4gOS4qlBvbGljeeexu+aWh+S7tu+8jOS4u+imgeWujOaIkGFjdGlvbuWHveaVsOOAgmFjdGlvbuWHveaVsOS8oOWFpeWPguaVsOS4um9ic2VydmF0aW9u77yM5Lyg5Ye6YWN0aW9u44CC5Lu/55yf5Zmo5Lya5Zyo54m554K555qE5pe26Ze06Ze06ZqU6LCD55SoYWN0aW9u77yM5L6d5o2u5oyR5oiY6ICF6K6+6K6h55qE562W55Wl5b6X5YiwYWN0aW9u77yM5Y2z5o6n5Yi26YePW3Usdl3vvIzku47ogIzmjqfliLblsI/ovabjgIIKYGBgCmNsYXNzZGVmIFBvbGljeSA8IGhhbmRsZQ0gICAgICAgIGZ1bmN0aW9uIGFjdGlvbj1hY3Rpb24oc2VsZixvYnNlcnZhdGlvbikNICAgICAgICAgICAgaWYgb2JzZXJ2YXRpb24uY29sbGlkZQ0gICAgICAgICAgICAgICAgYWN0aW9uPVstMTAscmFuZCgxKS0wLjVdOw0gICAgICAgICAgICBlbHNlDSAgICAgICAgICAgICAgICBhY3Rpb249WzEwLHJhbmQoMSktMC41XTsNICAgICAgICAgICAgZW5kDSAgICAgICAgZW5kCmBgYAoKIyMjIDYuIE1haW7lh73mlbAK5Lul5LiL5pivTWFpbuWHveaVsOeahOWfuuacrOS7o+egge+8jG1haW7or7vlj5bns7vnu5/phY3nva7mlofku7blr7nku7/nnJ/njq/looPov5vooYzphY3nva7vvIzkuYvlkI7ov5vlhaXku7/nnJ/lvqrnjq/jgILlnKjlvqrnjq/kuK3vvIzku7/nnJ/lmajlr7lBcmVuYSBDaGFsbGVuZ2Xov5vooYzniannkIbku7/nnJ/vvIzorqHnrpflh7rlsI/ovabkvY3nva7lkoznirbmgIHvvIzmmK/lkKblj5HnlJ/norDmkp7nrYnkv6Hmga/jgILlubbkuJTmr4/kuIDmrKHpg73nlKjmjJHmiJjogIXorr7orqHmjqfliLbnrZbnlaXvvIznhLblkI7miormjqfliLbnrZbnlaXkvZznlKjkuo7lsI/ovabnmoTmjqfliLbkuK3jgIIKYGBgCmVudiA9IEVudignc3lzLmluaScpOyAgICXor7vlj5bns7vnu5/phY3nva7mlofku7YNcG9saWN5PVBvbGljeSgpOw1pZiAoZW52LnN1Y2NlZWQpDSAgICBvYnNlcnZhdGlvbiA9IGVudi5yZXNldCgpOw0gICAgd2hpbGUgMQ0gICAgICAgIGVudi5yZW5kZXIoKTsNICAgICAgICBhY3Rpb249cG9saWN5LmFjdGlvbihvYnNlcnZhdGlvbik7ICXosIPnlKjmjJHmiJjogIXnmoTmjqfliLbnrZbnlaUNICAgICAgICBbb2JzZXJ2YXRpb24sZG9uZSxpbmZvXT1lbnYuc3RlcChhY3Rpb24pOyAl54mp55CG5Lu/55yfDSAgICAgICAgZGlzcChpbmZvKTsNICAgICAgICBpZihkb25lKQ0gICAgICAgICAgICBicmVhazsNICAgICAgICBlbmQNICAgICAgICB3YWl0KDEwMCk7DSAgICBlbmQNZW5kDWBgYA0KCiMjIyA3LiDku7/nnJ/phY3nva7mlofku7ZzeXMuaW5pCuS4uuS6huaWueS+v+aMkeaImOiAhei/m+ihjOa1i+ivle+8jOaMkeaImOiAheWPr+S7pemAmui/h+S7v+ecn+mFjee9ruaWh+S7tnN5cy5pbmnvvIzov5vooYznm7jlupTphY3nva7jgILkvovlpoLphY3nva7lsI/ovabnmoTotbflp4vlkoznu4jmraLngrnvvIzlsI/ovabmjqfliLbppbHlkozojIPlm7TvvIzmmK/lkKblvZXliLbmuLjmiI/ov5DooYzov4fnqIvnrYnjgILlhbfkvZPop4Hor6Xmlofku7bjgIIKCgojIyDku6PnoIHmj5DkuqTnvZHnq5kKaHR0cDovL3d3dy5yYXlsaWFibGUubmV0L21hbmFnZS9hY2NvdW50L2xvZ2luCgojIyBMZWFkZXIgQm9hcmQo5o6S5ZCN5qacKQoKIyDlj4LkuI7otKHnjK4KCjEuICBGb3JrIOacrOS7k+W6kwoyLiAg5paw5bu6IEZlYXRfeHh4IOWIhuaUrwozLiAg5o+Q5Lqk5Luj56CBCjQuICDmlrDlu7ogUHVsbCBSZXF1ZXN0CgoK)

# 参与贡献

1.  Fork 本仓库
2.  新建 Feat_xxx 分支
3.  提交代码
4.  新建 Pull Request


