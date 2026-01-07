classdef LaserBeam
    properties
        Handle
        Color
        beamWidth
        beamDuration
        Xpos
        Ypos
        Zpos
        Zvel
        Exist
        Alive
        ExplosionIndex
    end
    methods 
        function obj = init(obj,xbeam, ybeam, zbeam, beamWidth, beamDuration)
            obj.Alive = 1;
            obj.Exist = 1;
            obj.ExplosionIndex = 0;
            
            xbeamFull = [xbeam'; xbeam'];
            ybeamFull = [ybeam'; ybeam'];
            zbeamFull = [repmat(zbeam,length(xbeam),1); repmat(zbeam+beamDuration,length(xbeam),1)];
            k = boundary(xbeamFull, ybeamFull, zbeamFull, 0.8);
            h = trisurf(k,xbeamFull, ybeamFull, zbeamFull, 'FaceColor',[1 0.1 0.1],'FaceAlpha',0.5,'EdgeColor',[1 0.1 0.1]);
            
            obj.Handle = h;
            obj.Color = [1 0.1 0.1];
            obj.Xpos = mean(xbeamFull);
            obj.Ypos = mean(ybeamFull);
            obj.Zvel = 5;
            obj.beamWidth = beamWidth;
            obj.beamDuration = beamDuration;
            
        end
        function obj = moveZposition(obj, dist)
            VertPos = get(obj.Handle,'Vertices');
            set(obj.Handle,'Vertices',[VertPos(:,1:2), VertPos(:,3) + dist]);
            
            obj.Exist = obj.checkExistance;
        end
        
        function obj = moveOverTime(obj)
            if obj.Alive
                obj = obj.moveZposition(obj.Zvel);
            else
                obj = obj.ExplosionProtocal;
            end
        end
        
        function exist = checkExistance(obj)
            VertPos = get(obj.Handle,'Vertices');
            Zlims = zlim;
            
            if any(VertPos(:,3) > Zlims(1)) && any(VertPos(:,3) < Zlims(2))
                exist = 1;
            else
                exist = 0;
            end
        end
        
        %% This is the end (Explosion of class)
        function obj = ExplosionProtocal(obj)
            VertPos = get(obj.Handle,'Vertices');
            X = VertPos(:,1);
            Y = VertPos(:,2);
            Z = VertPos(:,3);
            
            ITER = 5;
            if obj.ExplosionIndex < ITER
                X = X + randn(size(X))*0.1;
                Y = Y + randn(size(Y))*0.1;
                Z = Z + randn(size(Z))*0.1;
                set(obj.Handle,'Vertices',[X, Y, Z]);
                obj.ExplosionIndex = obj.ExplosionIndex + 1;
            else
                obj.Exist = 0;
            end
        end
    end
    methods(Static)
    end
end