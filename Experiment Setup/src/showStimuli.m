function [data shade] = showStimuli(hObject, variables, handles)
%%% ---- Support Functions for RunExperiment.m ---- %%

% Initializes trigger through National Instrument's USB-6009 port ao1
try
  s = daq.createSession('ni');
  addAnalogOutputChannel(s,'Dev1','ao1','Voltage');
  Triggered = 1;
catch
  Triggered = 0;
end


fois = variables(1);        % Number of times stimulus is presented
typ = variables(2);         % Type of stimulus presented
num = variables(3);         % Length of display area in case of squares

height  = handles.height;   % Height of image
width = handles.width;      % Width of image
buff = handles.buffer;      % Offset from bottom of screen
ssiz = handles.ssiz;        % Size of display area
radius = handles.circleRadius;  % Radius of a circle
lag1 = handles.lag1;        % Length of stimulus
lag2 = handles.lag2;        % Length of pause


% Initializes black screen and flash
Black = zeros(height,width);
flash = ones(height,width);

% flash(:,:,2) = 0;

GreyValue = 0.25;
PlusMinusDifference = 0.25;
Grey = flash*GreyValue;

%%%% Temporary
Sign = -1;

% Initializes figure (maximize window after it appears)
fig = figure('NumberTitle','off','MenuBar','none','toolbar','none','color',[0 0 0],'DockControls','off');


% Generates images to be presented to reduce computation time alter
switch typ

case 1  % Random squares

  % Set stimulus-specific functions and variables
  num = num^2;
  number2data = @(vars) vars{1};
  vars = {0};
  conversion = @(i,num) i;
  randomFunction = @randomOrder;
  Background = Black;

  % Load stimuli into matrix
  for i = 1:num
    I(:,:,i) = square({i, ssiz, sqrt(num), height, width, buff});
  end

  % I = repmat(I,[1 1 1 3]);
  % I(:,:,:,2) = 0;
  % I = permute(I,[1 2 4 3]);

case 2  % Circle of specified shade and radius

  % Set stimulus-specific functions and variables
  number2data = @(vars) vars{3} + log((vars{1}-1)/vars{2}*(exp(1-vars{3})-1)+1);
  vars = {0,num,GreyValue};
  conversion = @(i,num) i+1;
  randomFunction = @randomOrder;
  Background = Black;

  % Load stimuli into matrix
  for i = 1:num+1
    vars{1} = i;
    y = number2data(vars);
    I(:,:,i) = circle({y,width,height,ssiz,buff,radius,Background});
  end

case 3  % Displays bar in specified direction and width

  % Set stimulus-specific functions and variables
  Background = Black;
  I = loadLUT(variables(4), variables(5), variables(6), height,width);
  randomFunction = @(a,b,c) null(1);

case 4 % Display Brightness Levels

  radius = 1000;

  % Set stimulus-specific functions and variables
  number2data = @(vars) vars{3} + log((vars{1}-1)/vars{2}*(exp(1-vars{3})-1)+1);
  vars = {0,num,GreyValue};
  conversion = @(i,num) i+1;
  randomFunction = @randomOrder;
  Background = Black;

  % Load stimuli into matrix
  for i = 1:num+1
    vars{1} = i;
    y = number2data(vars);
    I(:,:,i) = circle({y,width,height,ssiz,buff,radius,Background});
  end


case 5  % Displays dark/light squares on black background

  % Set stimulus-specific functions and variables
  num = num^2;
  number2data = @(vars) vars{1};
  vars = {0};
  conversion = @(i,num) i+num+1;
  randomFunction = @randomOrder2;
  Background = Grey;

  % Load stimuli into matrix
  for i = -num:num
    I(:,:,i+num+1) = balancedSquare({abs(i), ssiz, sqrt(num), height, width, buff, sign(i), GreyValue, PlusMinusDifference});
  end

case 6  % Display three at a time: not implemented in current structure

  % Set stimulus-specific functions and variables
  num = num^2;
  number2data = @(vars) vars{1};
  vars = {0};
  conversion = @(i,num) i;
  randomFunction = @randomOrder;
  Background = Grey;

  % Load stimuli into matrix
  for i = 1:num
    I(:,:,i) = balancedSquare({abs(i), ssiz, sqrt(num), height, width, buff, Sign, GreyValue, PlusMinusDifference});
  end 

  PlusMinusDifference = Sign;


  % ran = randomOrder3(num^2,fois,1);

  % PlusMinusDifference = 0.3;

  % Grey = ones(height,width)*GreyBackground;

  % [a b] = size(ran);

  % for i = 1:a
  %   data(end+1,1) = i;
  %   data(end,2) = toc(start);
  %   data(end,3) = ran(i,1);
  %   data(end,4) = ran(i,2);
  %   data(end,5) = ran(i,3);

  %   if(rand(i,1) == 0)
  %     pause(lag1)
  %   else
  %     figure(fig),imshow(balancedSquares({abs(ran(i,:)), ssiz, num, height, width, buff, sign(ran(i,:)), GreyBackground, PlusMinusDifference}),'border','tight','parent',gca);
  %     pause(lag1);
  %   end

  %   figure(fig), imshow(Grey,'border','tight','parent',gca);
  %   pause(lag2);
  % end


case 7  % Circle of specific shade on grey background

  % Set stimulus-specific functions and variables
  levels = PlusMinusDifference/num;
  number2data = @(vars) vars{1}*vars{2};
  vars = {0, levels};
  conversion = @(i,num) i+num+1;
  randomFunction = @randomOrder2;
  Background = Grey;

  % Load stimuli into matrix
  for i = -num:num
    I(:,:,i+num+1) = circle({levels*i+GreyValue,width,height,ssiz,buff,radius,Grey(:,:,1)});
  end

  % I = repmat(I,[1 1 1 3]);
  % I(:,:,:,2) = 0;
  % I = permute(I,[1 2 4 3]);

case 8   % Circles of different radii

  % Set stimulus-specific functions and variables
  number2data = @(vars) vars{3}/sqrt(2)*-log((vars{1}+1)/(vars{2}+1))/log(vars{2});
  vars = {0, num, ssiz};
  conversion = @(i,num) i;
  randomFunction = @randomOrder;
  Background = Grey;

  % Load stimuli into matrix
  for i = 1:num+1
    vars{1} = i;
    y = number2data(vars);
    I(:,:,i) = circle({0,width,height,ssiz,buff,y, Grey});
  end

end 

% Display blank background
figure(fig), imshow(Background,'border','tight','Parent',gca);
shade = Background(1,1);


% Generate random order for stimuli
ran = randomFunction(num, fois, 1);

% Wait for user to click continue
if(~Execution)
  data = 0;
  close;
  return;
end

% Outputs a 5V trigger if devices is connected
if(Triggered)
  outputSingleScan(s,5);
end
start = tic;
pause(1);
if(Triggered)
  outputSingleScan(s,0);
end
Props(1,:) = [length(ran)/fois fois, typ, lag1, lag2, PlusMinusDifference];
Props(2,:) = [num, height, width, buff,ssiz, GreyValue];

Pos = get(gcf,'Position');
set(gcf,'Position',Pos + [0 0 0 25]);

if(typ == 3)
  data = [variables(5) variables(6) lag1];
  data = barsLUT(I, fig, [data], data);
else

% Pause 10 (1+9) seconds to set baseline
pause(9);

% Loop through each stimulus
for i = 1:length(ran)
  vars{1} = ran(i);
  data(i,1) = i;
  data(i,2) = toc(start);
  data(i,3) = number2data(vars);  % Convert stimulus number into discriptive number

  % Presentation background as control
  if(ran(i) == 0)
    pause(lag1);
    data(i,3) = 0;
  else
    tic;
    imshow(I(:,:,conversion(ran(i),num)),'border','tight','Parent',gca); % Show stimulus and convert stimulus number into matrix index
    pause(max(lag1-toc,0)); % Accounts for image presentation time in lag 
  end
  tic;
  imshow(Background,'border','tight','Parent',gca);
  pause(max(lag2-toc,0)); % Accounts for image presentation time in lag 
end

end


%% Saves Data as StimulusTimes.txt and properties as StimulusConfig.txt

file = fullfile(handles.folder,'StimulusTimes.txt');
file2 = fullfile(handles.folder,'StimulusConfig.txt');

i = 2;
while(exist(file))
  file = fullfile(handles.folder,['StimulusTimes(' int2str(i) ').txt']);
  file2 = fullfile(handles.folder,['StimulusConfig(' int2str(i) ').txt']);
  i = i + 1;
end

dlmwrite(file,data,'precision','%.3f');
dlmwrite(file2,Props,'precision','%.3f');



%% --- Random ordering of {0,1,....,num*fois}
function ran = randomOrder(num, fois,d)

ran = datasample(repmat([0:num],[1 fois]),(num+1)*fois,'Replace',false);
ran = transpose(ran);


%% --- Random ordering of {-num*fois, ... , -1, 0, 1, ..., num*fois}
function ran = randomOrder2(num, fois,d)

ran = datasample(repmat([-num:num],[1 fois]),(2*num+1)*fois,'Replace',false);
ran = transpose(ran);


%% --- Three column random order with no repeats per row.
function ran = randomOrder3(num, fois,d)
  
ran = randomOrder2(num,fois,d);
for i = 1:length(ran)
  if(ran(i,1) == 0)
    ran(i,2) = 0; ran(i,3) = 0;
  else
    ran(i,2) = datasample(setdiff([-num:num],[0 ran(i,1) -ran(i,1)]),1);
    ran(i,3) = datasample(setdiff([-num:num],[0 ran(i,1) -ran(i,1) ran(i,2) -ran(i,2)]),1);
  end
 end

