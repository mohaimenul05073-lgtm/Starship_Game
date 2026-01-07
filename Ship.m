classdef Ship
    properties
        Handle
        Size
        Color
        Axes
        XPos_Center
        YPos_Center
        ZPos_Center
        Xvel
        Yvel
        Alive
        ExplosionIndex
    end
    methods
        %% Initialization
        function obj = init(obj)
            obj.Alive = 1;
            obj.ExplosionIndex = 0;
            obj.Size = 0.25;
            
            obj.Xvel = 0;
            obj.Yvel = 0;
            
            %Points of Spaceship
            Points = [-0.3, 3, 0.2;
                -0.3, 3, -0.2;
                0.3, 3, 0.2;
                0.3, 3, -0.2;
                -0.5, 2, 0.5;
                -0.5, 2, -0.5;
                0.5, 2, 0.5;
                0.5, 2, -0.5;
                -0.5, 1.5, 0;
                -0.5, 1.5, -0.5;
                0.5, 1.5, 0;
                0.5, 1.5, -0.5;
                -0.5, 0, 0.5;
                -0.5, 0, 0;
                -0.5, 0, -0.5;
                0.5, 0, 0.5;
                0.5, 0, 0;
                0.5, 0, -0.5;
                -2, 1.5, 0;
                -2, 1.5, -0.5;
                -2.5, 1, 0;
                -2.5, 1, -0.5;
                -2.5, 0, 0;
                -2.5, 0, -0.5;
                2, 1.5, 0;
                2, 1.5, -0.5;
                2.5, 1, 0;
                2.5, 1, -0.5;
                2.5, 0, 0;
                2.5, 0, -0.5];
            k = boundary(Points(:,1), Points(:,2), Points(:,3),0.8);
            h = trisurf(k,Points(:,1), Points(:,2), Points(:,3),'FaceColor',[0.4 0.4 0.8],'FaceAlpha',1);
            obj.Color = [0.4 0.4 0.8];
            
            obj.Handle = h;
            obj.Axes = gca;
            
            VertPos = get(obj.Handle,'Vertices');
            X = VertPos(:,1);
            Y = VertPos(:,2);
            Z = VertPos(:,3);
            set(obj.Handle,'Vertices',[obj.Size*X + 3, -obj.Size*Y + 4, obj.Size*Z]);
        end
        
        %% Movement Commands
        function obj = moveHorizontal(obj, dist)
            Move = obj.CheckBoundaries(dist,'Horizontal');
            
            if Move
                VertPos = get(obj.Handle,'Vertices');
                X = VertPos(:,1);
                Y = VertPos(:,2);
                Z = VertPos(:,3);
                set(obj.Handle,'Vertices',[X + dist, Y, Z]);
                obj.XPos_Center = obj.XPos_Center + dist;
            else
                obj.Xvel = 0;
            end
        end
        
        function obj = moveVertical(obj, dist)
            if obj.Alive
                Move = obj.CheckBoundaries(dist,'Vertical');
                
                if Move
                    VertPos = get(obj.Handle,'Vertices');
                    X = VertPos(:,1);
                    Y = VertPos(:,2);
                    Z = VertPos(:,3);
                    set(obj.Handle,'Vertices',[X, Y + dist, Z]);
                    obj.YPos_Center = obj.YPos_Center + dist;
                else
                    obj.Yvel = 0;
                end
            else
                obj = obj.ExplosionProtocal(obj);
            end
        end
        
        function obj = accelHorizontal(obj, acc)
            obj.Xvel = obj.Xvel + acc;
        end
        
        function obj = accelVertical(obj, acc)
            obj.Yvel = obj.Yvel + acc;
        end
        
        function obj = CoastPosition(obj)
            Xdist = obj.Xvel*0.05;
            Ydist = obj.Yvel*0.05;
            
            obj = obj.moveHorizontal(Xdist);
            obj = obj.moveVertical(Ydist);
        end
        
        function obj = CoastVelocity(obj)
            obj.Xvel = 0.96*obj.Xvel;
            obj.Yvel = 0.96*obj.Yvel;
        end

        function obj = GetCenterPosition(obj)
            VertPos = get(obj.Handle,'Vertices');
            X = VertPos(:,1);
            Y = VertPos(:,2);
            Z = VertPos(:,3);
            
            obj.XPos_Center = mean([min(X), max(X)]);
            obj.YPos_Center = mean([min(Y), max(Y)]);
            obj.ZPos_Center = mean([min(Z), max(Z)]);
        end
        
        function Move = CheckBoundaries(obj, dist, Direction)
            VertPos = get(obj.Handle,'Vertices');
            X = VertPos(:,1);
            Y = VertPos(:,2);
            
            if strcmp(Direction,'Horizontal')
                Xlims = xlim;
                Move = all(dist + X >= Xlims(1)) & all(dist + X <= Xlims(2));
            end
            if strcmp(Direction,'Vertical')
                Ylims = ylim;
                Move = all(dist + Y >= Ylims(1)) & all(dist + Y <= Ylims(2));
            end
        end
        
        %% Weapon Systems
        function laser = FireLaser(obj)
            BeamX = obj.XPos_Center;
            BeamY = obj.YPos_Center;
            BeamZ = obj.ZPos_Center+0.5;
            beamWidth = 0.01;
            beamDuration = 5;
            
            [xbeam, ybeam] = obj.circle_SP(BeamX, BeamY, beamWidth);
            laser = LaserBeam;
            laser = laser.init(xbeam, ybeam, BeamZ, beamWidth, beamDuration);
        end
        
        %% This is the end (Explosion of class)
        function obj = ExplosionProtocal(obj)
            VertPos = get(obj.Handle,'Vertices');
            X = VertPos(:,1);
            Y = VertPos(:,2);
            Z = VertPos(:,3);
            
            ITER = 1000;
            if obj.ExplosionIndex < ITER
                FA = get(obj.Handle,'FaceAlpha');
                if FA > 0
                    set(obj.Handle,'FaceAlpha',FA-0.01)
                end
                X = X + randn(size(X))*2;
                Y = Y + randn(size(Y))*2;
                Z = Z + randn(size(Z))*2;
                set(obj.Handle,'Vertices',[X, Y, Z]);
                obj.ExplosionIndex = obj.ExplosionIndex + 1;
            end
        end
    end
    methods(Static)
        function [xunit, yunit] = circle_SP(x,y,r)
            th = 0:pi/50:2*pi;
            xunit = r * cos(th) + x;
            yunit = r * sin(th) + y;
        end
    end
end

