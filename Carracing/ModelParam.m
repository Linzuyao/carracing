classdef ModelParam < handle
    properties
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
    end
    methods
        
        function self = ModelParam(m,Iz,lf,lr,Cm1,Cm2,Cr0,Cr2,Br,Cr,Dr,Bf,Cf,Df)
            self.m=m;
            self.Iz = Iz;
            self.lf = lf;
            self.lr = lr;
            self.Cm1=Cm1;
            self.Cm2=Cm2;
            self.Cr0=Cr0;
            self.Cr2=Cr2;
            self.Br=Br;
            self.Cr=Cr;
            self.Dr=Dr;
            self.Bf=Bf;
            self.Cf=Cf;
            self.Df=Df;
        end
    end
end