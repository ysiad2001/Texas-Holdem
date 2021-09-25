function varargout = main_interface(varargin)
% Pre-generated setup code
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name', mfilename, ...
    'gui_Singleton', gui_Singleton, ...
    'gui_OpeningFcn', @main_interface_OpeningFcn, ...
    'gui_OutputFcn', @main_interface_OutputFcn, ...
    'gui_LayoutFcn', [], ...
    'gui_Callback', []);
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

% --- Executes just before main_interface is made visible.
function main_interface_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for main_interface
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

while true
    % Setup the port connection
    handles.txtSend = " ";
    prompt = {'Enter the port', 'Enter your name:'};
    dlgtitle = 'Input';
    answer = inputdlg(prompt, dlgtitle);
    port = str2double(answer(1));
    handles.port = port;
    userName = string(answer(2));
    % Save the userData in the handle structure
    handles.userData(port-30000).userName = userName;
    handles.userData(port-30000).axe1 = handles.ownHandAxe1;
    handles.userData(port-30000).axe2 = handles.ownHandAxe2;
    handles.userData(port-30000).chipsText = handles.ownChipsText;
    handles.userData(port-30000).nameText = handles.ownNameText;
    set(handles.ownNameText,'String',userName);
    tcpipClient = tcpip('0.0.0.0', port, 'NetworkRole', 'client');
    tcpipClient.InputBuffersize = 100000;
    tcpipClient.OutputBuffersize = 100000;
    tcpipClient.Timeout = 5;
    fprintf("connecting at port %d...\n", port);
    try
        fopen(tcpipClient);
        break
    catch
        warning('wrong TCPIP port');
        continue
    end
end

pause(1);
fprintf(tcpipClient, userName);
counter = 0;
% Try to read data from server
while true
    if tcpipClient.BytesAvailable > 0
        stringRecved = (string(fscanf(tcpipClient)));
        strings = split(stringRecved);
        if strings(1) == "Player"
            if strings(3) == "userName" % Player [index] userName is [userName]
                %Assign the UIControl objects to the corresponding users
                thisUser = str2double(strings(2));
                meUser = handles.port - 30000;
                handles.userData(thisUser).userName = strings(5);
                if thisUser - meUser == 1 || thisUser - meUser == -4
                    counter = counter + 1;
                    handles.userData(thisUser).axe1 = handles.oneHandAxe1;
                    handles.userData(thisUser).axe2 = handles.oneHandAxe2;
                    handles.userData(thisUser).chipsText = handles.oneChipsText;
                    handles.userData(thisUser).nameText = handles.oneNameText;
                    set(handles.userData(thisUser).nameText,'String',handles.userData(thisUser).userName);
                elseif thisUser - meUser == 2 || thisUser - meUser == -3
                    counter = counter + 1;
                    handles.userData(thisUser).axe1 = handles.twoHandAxe1;
                    handles.userData(thisUser).axe2 = handles.twoHandAxe2;
                    handles.userData(thisUser).chipsText = handles.twoChipsText;
                    handles.userData(thisUser).nameText = handles.twoNameText;
                    set(handles.userData(thisUser).nameText,'String',handles.userData(thisUser).userName);
                elseif thisUser - meUser == 3 || thisUser - meUser == -2
                    counter = counter + 1;
                    handles.userData(thisUser).axe1 = handles.threeHandAxe1;
                    handles.userData(thisUser).axe2 = handles.threeHandAxe2;
                    handles.userData(thisUser).chipsText = handles.threeChipsText;
                    handles.userData(thisUser).nameText = handles.threeNameText;
                    set(handles.userData(thisUser).nameText,'String',handles.userData(thisUser).userName);
                elseif thisUser - meUser == 4 || thisUser - meUser == -1
                    counter = counter + 1;
                    handles.userData(thisUser).axe1 = handles.fourHandAxe1;
                    handles.userData(thisUser).axe2 = handles.fourHandAxe2;
                    handles.userData(thisUser).chipsText = handles.fourChipsText;
                    handles.userData(thisUser).nameText = handles.fourNameText;
                    set(handles.userData(thisUser).nameText,'String',handles.userData(thisUser).userName);
                end
            end
        end
    end
    if counter == 4
        break
    end
end
set(handles.potText, 'String', "0");
for i = 1:5
    imshow("cardback.png", 'Parent', handles.userData(i).axe1);
    imshow("cardback.png", 'Parent', handles.userData(i).axe2);
end
imshow("cardback.png", 'Parent', handles.tableOneAxe);
imshow("cardback.png", 'Parent', handles.tableTwoAxe);
imshow("cardback.png", 'Parent', handles.tableThreeAxe);
imshow("cardback.png", 'Parent', handles.tableFourAxe);
imshow("cardback.png", 'Parent', handles.tableFiveAxe);
t = timer;
t.TimerFcn = @(~, ~)clientCallBack(tcpipClient, handles);
t.ExecutionMode = 'fixedSpacing';
t.Period = 1;
start(t);
end

function varargout = main_interface_OutputFcn(hObject, eventdata, handles)
% --- Outputs from this function are returned to the command line.
varargout{1} = handles.output;
end

function callButton_Callback(hObject, eventdata, handles)
% --- Executes on button press in callButton.
set(handles.responseText, 'String', ("call"));
end


function foldButton_Callback(hObject, eventdata, handles)
% --- Executes on button press in foldButton.
set(handles.responseText, 'String', ("fold"));
end


function betButton_Callback(hObject, eventdata, handles)
% --- Executes on button press in betButton.
betChips = string(get(handles.betChipsText, 'String'));
set(handles.responseText, 'String', ("bet " +betChips));
end


function slider1_Callback(hObject, eventdata, handles)
% --- Executes on slider movement.
value = get(handles.slider1, 'Value');
chips = str2double(get(handles.ownChipsText, 'String'));
value = floor(value*chips);
set(handles.betChipsText, 'String', num2str(value));
end

function slider1_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', [.9, .9, .9]);
end
end

function clientCallBack(tcpipClient, handles)
% Try to read from tcpip port
if tcpipClient.BytesAvailable > 0
    stringRecv = strip(string(fscanf(tcpipClient)));
    if stringRecv == "getResponse"
        set(handles.interactiveText, 'String', "Your turn!");
        pause(8);
        txtSend = get(handles.responseText, 'String');
        fprintf(tcpipClient, txtSend);
        set(handles.betChipsText, 'String', "0");
        set(handles.responseText, 'String', "bet");
        set(handles.slider1, 'Value',0);
    else
        
        texts = split(stringRecv);
        if texts(1) == "Player"
            if texts(4) == "eliminated!" % Player [index] is eliminated!
                set(handles.interactiveText, 'String', stringRecv);
            elseif texts(3) == "folds"
                % Player [index] folds Now player [index] has [chips] chips
                set(handles.interactiveText, 'String', stringRecv);
                thisPlayer = str2double(texts(2));
                chips = (texts(8));
                set(handles.userData(thisPlayer).chipsText, 'String', chips);
            elseif texts(3) == "calls"
                % Player [index] calls Now player [index] has [chips] chips
                set(handles.interactiveText, 'String', stringRecv);
                thisPlayer = str2double(texts(2));
                chips = (texts(8));
                set(handles.userData(thisPlayer).chipsText, 'String', chips);
            elseif texts(3) == "allin"% Player [index] allin
                set(handles.interactiveText, 'String', stringRecv);
                thisPlayer = str2double(texts(2));
                chips = "0";
                set(handles.userData(thisPlayer).chipsText, 'String', chips);
            elseif texts(3) == "raises"
                % Player [index] raises to [chips] Now player [index] has [chips] chips
                set(handles.interactiveText, 'String', stringRecv);
                thisPlayer = str2double(texts(2));
                chips = (texts(10));
                set(handles.userData(thisPlayer).chipsText, 'String', chips);
            elseif texts(3) == "hand"
                outputText = "Player " + texts(2) + " hand " + "is " ...
                    + num2card(str2double(texts(5)))+" "+ num2card(str2double(texts(6)));
                set(handles.interactiveText, 'String', outputText);
                thisPlayer = str2double(texts(2));
                fileName = texts(5) + ".jpg";
                imshow(fileName, 'Parent', (handles.userData(thisPlayer).axe1));
                fileName = texts(6) + ".jpg";
                imshow(fileName, 'Parent', (handles.userData(thisPlayer).axe2));
            elseif texts(3) == "now" % Player [index] now has [chips] chips
                set(handles.interactiveText, 'String', stringRecv);
                thisPlayer = str2double(texts(2));
                chips = (texts(5));
                set(handles.userData(thisPlayer).chipsText, 'String', chips);
            end
        elseif texts(1) == "The" %The [round] round
            set(handles.interactiveText, 'String', stringRecv);
            if texts(2) == "preflop"
            elseif texts(2) == "flop"
                fileName = texts(9) + ".jpg";
                imshow(fileName, 'Parent', handles.tableOneAxe);
                fileName = texts(10) + ".jpg";
                imshow(fileName, 'Parent', handles.tableTwoAxe);
                fileName = texts(11) + ".jpg";
                imshow(fileName, 'Parent', handles.tableThreeAxe);
            elseif texts(2) == "turn"
                fileName = texts(8) + ".jpg";
                imshow(fileName, 'Parent', handles.tableFourAxe);
            elseif texts(2) == "river"
                fileName = texts(8) + ".jpg";
                imshow(fileName, 'Parent', handles.tableFiveAxe);
            end
        elseif texts(1) == "STARTING" % STARTING GAME [num]
            set(handles.interactiveText, 'String', stringRecv);
            set(handles.potText, 'String', "0");
            for i = 1:5
                imshow("cardback.png", 'Parent', handles.userData(i).axe1);
                imshow("cardback.png", 'Parent', handles.userData(i).axe2);
            end
            imshow("cardback.png", 'Parent', handles.tableOneAxe);
            imshow("cardback.png", 'Parent', handles.tableTwoAxe);
            imshow("cardback.png", 'Parent', handles.tableThreeAxe);
            imshow("cardback.png", 'Parent', handles.tableFourAxe);
            imshow("cardback.png", 'Parent', handles.tableFiveAxe);
        elseif texts(1) == "Your" % Your hand is [card] [card]
             outputText = "Your hand is " + num2card(str2double(texts(4)))...
                 +" "+ num2card(str2double(texts(5)));
                set(handles.interactiveText, 'String', outputText);
            fileName = texts(4) + ".jpg";
            imshow(fileName, 'Parent', handles.ownHandAxe1);
            fileName = texts(5) + ".jpg";
            imshow(fileName, 'Parent', handles.ownHandAxe2);
        elseif texts(1) == "Not" % Not enough bet!
            set(handles.interactiveText, 'String', stringRecv);
        end
    pot = 5000;
    for i = 1:5
        pot = pot - str2double(get(handles.userData(i).chipsText, 'String'));
    end
    set(handles.potText,'String',num2str(pot));
end
end
end
