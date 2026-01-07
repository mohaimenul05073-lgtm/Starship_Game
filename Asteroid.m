classdef Asteroid
    properties
        Handle
        Size
        Color
        XPos_Center
        YPos_Center
        ZPos_Center
        Zvel
        Exist
        Alive
        ExplosionIndex
    end
    methods
        function obj = init(obj)
            obj.Alive = 1;
            obj.Exist = 1;
            obj.ExplosionIndex = 0;
            obj.Size = 2*rand(1,1);
            
            X = obj.Size*rand(25,1);
            Y = obj.Size*rand(25,1);
            Z = obj.Size*rand(25,1);
            
            obj.Zvel = -0.5*rand(1,1) - 0.5;
            
            k = boundary(X,Y,Z,0.8);
            h = trisurf(k,X,Y,Z, 'Facecolor',[0.5 0.5 0.5],'FaceAlpha',0.8);
            obj.Color = [0.5 0.5 0.5];
            obj.Handle = h;
            
            obj.moveXposition((10 - obj.Size)*rand(1,1));
            obj.moveYposition((10 - obj.Size)*rand(1,1));
            obj.moveZposition(100);
            
            VertPos = get(obj.Handle,'Vertices');
            obj.XPos_Center = mean(VertPos(:,1));
            obj.YPos_Center = mean(VertPos(:,2));
        end
        
        function obj = moveXposition(obj, dist)
            VertPos = get(obj.Handle,'Vertices');
            set(obj.Handle,'Vertices',[VertPos(:,1) + dist, VertPos(:,2:3)]);
        end
        
        function obj = moveYposition(obj, dist)
            VertPos = get(obj.Handle,'Vertices');
            set(obj.Handle,'Vertices',[VertPos(:,1), VertPos(:,2) + dist, VertPos(:,3)]);
        end
        
        function obj = moveZposition(obj, dist)
            VertPos = get(obj.Handle,'Vertices');
            set(obj.Handle,'Vertices',[VertPos(:,1:2), VertPos(:,3) + dist]);
            obj.ZPos_Center = mean(VertPos(:,3) + dist);
            
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
            
            if any(VertPos(:,3) > Zlims(1))
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
            
            ITER = 10;
            if obj.ExplosionIndex < ITER
                X = X + randn(size(X))*0.1;
                Y = Y + randn(size(Y))*0.1;
                Z = Z + randn(size(Z))*0.1;
                set(obj.Handle,'Vertices',[X, Y, Z]);
                obj.ExplosionIndex = obj.ExplosionIndex + 1;
                set(obj.Handle,'Facecolor',obj.Color*0.8);
                obj.Color = obj.Color*0.85;
            else
                obj.Exist = 0;
            end
        end
    end
    methods(Static)
    end
end