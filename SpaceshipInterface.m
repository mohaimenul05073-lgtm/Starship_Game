function varargout = SpaceshipInterface(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SpaceshipInterface_OpeningFcn, ...
                   'gui_OutputFcn',  @SpaceshipInterface_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end


% --- Executes just before SpaceshipInterface is made visible.
function SpaceshipInterface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SpaceshipInterface (see VARARGIN)

% Choose default command line output for SpaceshipInterface
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SpaceshipInterface wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = SpaceshipInterface_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


% --- Executes on button press in StartButton.
function StartButton_Callback(hObject, eventdata, handles)
% hObject    handle to StartButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
current_ax = gca;
AllChil = get(current_ax,'Children');
for chil = 1:length(AllChil)
    delete(AllChil(chil))
end

global run
run = 1;

%% Setup Space
% hfig = figure();
hfig = handles.figure1;
hold all;
grid on
afig = gca;

axis manual
set(afig,'Color',[0.01, 0.01, 0.01])

set(afig,'xtick',[])
set(afig,'xticklabel',[])
set(afig,'ytick',[])
set(afig,'yticklabel',[])
set(afig,'ztick',[])
set(afig,'zticklabel',[])

grid off
% view(0,-89)
camproj('perspective')
% camlight('left')
camlight(210,150,'local')
view(0,-86)

% Star Background
nStars = 500;
XS = 15*rand(nStars,1) - 2.5;
YS = 15*rand(nStars,1) - 2.5;
ZS = 100*ones(nStars,1);
S = rand(nStars,1);
C = repmat([1 1 1],numel(XS),1);
scatter3(XS, YS, ZS, S(:), C,'filled')

%% Insert Ship
global ship
ship = Ship;
ship = ship.init;
ship = ship.GetCenterPosition;

global laserLib
laserLib = LaserBeam;

set(afig,'Xlim',[0 10])
set(afig,'Ylim',[0 10])
set(afig,'Zlim',[0 100])

ship = ship.moveHorizontal(1);
ship = ship.moveVertical(1);

%% Run Game
set(gcf,'KeyPressFcn',@pressmybutton)
SpawnThresh = 0.1;
asteroidLib = Asteroid;
while run
    drawnow
    if run == 0
        return
    end 
    
    %Spawning of Asteroids
    SpawnRoll = rand(1,1);
    if SpawnRoll <= SpawnThresh
        if isempty(asteroidLib(1).Handle)
            asteroidLib(1) = Asteroid;
            asteroidLib(1) = asteroidLib(1).init;
        else
            asteroidLib(end+1) = Asteroid;
            asteroidLib(end) = asteroidLib(end).init;
        end
    end
    
    
    %Update Object Positions
    ship = ship.CoastPosition;
    ship = ship.CoastVelocity;
    
    if ~isempty(asteroidLib(1).Handle)
        for mvAst = 1:length(asteroidLib)
            asteroidLib(mvAst) = asteroidLib(mvAst).moveOverTime;
        end
    end
    
    if ~isempty(laserLib(1).Handle)
        for mvLas = 1:length(laserLib)
            laserLib(mvLas) = laserLib(mvLas).moveOverTime;
        end
    end
        
        
    %Intersection tests
    if ~isempty(asteroidLib(1).Handle)
        %Test Ship vs. Asteroids
        AliveAst = arrayfun(@(x) asteroidLib(x).Alive == 1, 1:length(asteroidLib));
        asteroidLib_Alive = asteroidLib(AliveAst);
        
        for astTest = 1:length(asteroidLib_Alive)
            [~, t2] = SurfaceIntersection(ship.Handle, asteroidLib_Alive(astTest).Handle);
            if ~isempty(t2.vertices) || ~isempty(t2.faces) || ~isempty(t2.edges)
                run = 0;
                
                %Game Over Text
                GameOverText = {'GAME','OVER'};
                text(4.3,5,0,GameOverText,'Color',[1 0 0],'FontSize',50,'FontWeight','Bold','FontName','Rockwell')
            end
        end
        
        %Test Asteroid vs. Asteroids
        
        %Test Laser vs. Asteroids
        if ~isempty(laserLib(1).Handle)
            AliveLas = arrayfun(@(x) laserLib(x).Alive == 1, 1:length(laserLib));
            AliveLas_idx = find(AliveLas == 1);
            AliveAst = arrayfun(@(x) asteroidLib(x).Alive == 1, 1:length(asteroidLib));
            AliveAst_idx = find(AliveAst == 1);
            
            laserLib_Alive = laserLib(AliveLas);
            asteroidLib_Alive = asteroidLib(AliveAst);
            
            LaserAsteroidComb = combvec(1:length(laserLib_Alive), 1:length(asteroidLib_Alive));
            
            
            TestX = arrayfun(@(x) ...
                laserLib_Alive(LaserAsteroidComb(1,x)).Xpos > asteroidLib(LaserAsteroidComb(2,x)).XPos_Center - asteroidLib(LaserAsteroidComb(2,x)).Size/2 &&...
                laserLib_Alive(LaserAsteroidComb(1,x)).Xpos < asteroidLib(LaserAsteroidComb(2,x)).XPos_Center + asteroidLib(LaserAsteroidComb(2,x)).Size/2,...
                1:size(LaserAsteroidComb,2));
            TestY = arrayfun(@(x)...
                laserLib_Alive(LaserAsteroidComb(1,x)).Ypos > asteroidLib(LaserAsteroidComb(2,x)).YPos_Center - asteroidLib(LaserAsteroidComb(2,x)).Size/2 &&...
                laserLib_Alive(LaserAsteroidComb(1,x)).Ypos < asteroidLib(LaserAsteroidComb(2,x)).YPos_Center + asteroidLib(LaserAsteroidComb(2,x)).Size/2,...
                1:size(LaserAsteroidComb,2));
            XYPlaneTest = TestX & TestY;
            LaserAsteroidComb = LaserAsteroidComb(:,XYPlaneTest);
            
            for LAC_idx = 1:size(LaserAsteroidComb,2)
                [~, t2] = SurfaceIntersection(laserLib_Alive(LaserAsteroidComb(1,LAC_idx)).Handle,...
                    asteroidLib_Alive(LaserAsteroidComb(2,LAC_idx)).Handle);
                if ~isempty(t2.vertices) || ~isempty(t2.faces) || ~isempty(t2.edges)
                    %Begin Explosion Protocol of both surfaces
                    laserLib(AliveLas_idx(LaserAsteroidComb(1,LAC_idx))).Alive = 0;
                    asteroidLib(AliveAst_idx(LaserAsteroidComb(2,LAC_idx))).Alive = 0;
                end
            end
        end
    end
    
    
    %Clean up Object Libraries by checking existance
    if ~isempty(asteroidLib(1).Handle)
        ExistResults = arrayfun(@(x) asteroidLib(x).Exist, 1:length(asteroidLib));
        AsteroidKeep = find(ExistResults == 1);
        AsteroidRemoval = find(ExistResults == 0);
        if ~isempty(AsteroidRemoval)
            arrayfun(@(x) delete(asteroidLib(x).Handle), AsteroidRemoval)
            asteroidLib = asteroidLib(AsteroidKeep);
            if isempty(asteroidLib)
                asteroidLib = Asteroid;
            end
        end
    end
    
    if ~isempty(laserLib(1).Handle)
        ExistResults = arrayfun(@(x) laserLib(x).Exist, 1:length(laserLib));
        LaserKeep = find(ExistResults == 1);
        LaserRemoval = find(ExistResults == 0);
        if ~isempty(LaserRemoval)
            arrayfun(@(x) delete(laserLib(x).Handle), LaserRemoval)
            laserLib = laserLib(LaserKeep);
            if isempty(laserLib)
                laserLib = LaserBeam;
            end
        end
    end
    
end
% close all
end

function pressmybutton(hobject, event)
global run
if strcmp(event.Key, 'escape')
    run = 0;
elseif strfind(event.Key, 'arrow') ~= 0
    eval(['Command_',event.Key])
elseif strfind(event.Key, 'control') ~= 0
    eval(['Command_',event.Key])
end
end

function Command_uparrow
global ship
ship = ship.moveVertical(-0.3);
ship = ship.accelVertical(-0.3);
end

function Command_downarrow
global ship
ship = ship.moveVertical(0.3);
ship = ship.accelVertical(0.3);
end

function Command_rightarrow
global ship
ship = ship.moveHorizontal(0.3);
ship = ship.accelHorizontal(0.3);
end

function Command_leftarrow
global ship
ship = ship.moveHorizontal(-0.3);
ship = ship.accelHorizontal(-0.3);
end

function Command_control
global ship
global laserLib
if isempty(laserLib(1).Handle)
    laserLib(1) = ship.FireLaser;
else
    laserLib(end+1) = ship.FireLaser;
end
end




% --- Executes on button press in ExitButton.
function ExitButton_Callback(hObject, eventdata, handles)
% hObject    handle to ExitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global run

run = 0;

current_ax = gca;
AllChil = get(current_ax,'Children');
for chil = 1:length(AllChil)
    delete(AllChil(chil))
end
end
