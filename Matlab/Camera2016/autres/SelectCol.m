function varargout = SelectCol(varargin)
% SELECTCOL M-file for SelectCol.fig
%      SELECTCOL, by itself, creates a new SELECTCOL or raises the existing
%      singleton*.
%
%      H = SELECTCOL returns the handle to a new SELECTCOL or the handle to
%      the existing singleton*.
%
%      SELECTCOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTCOL.M with the given input arguments.
%
%      SELECTCOL('Property','Value',...) creates a new SELECTCOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SelectCol_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SelectCol_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SelectCol

% Last Modified by GUIDE v2.5 19-Feb-2012 22:23:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SelectCol_OpeningFcn, ...
                   'gui_OutputFcn',  @SelectCol_OutputFcn, ...
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


% --- Executes just before SelectCol is made visible.
function SelectCol_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SelectCol (see VARARGIN)

% Choose default command line output for SelectCol
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SelectCol wait for user response (see UIRESUME)
% uiwait(handles.figure1);
%/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
% IN:  File   nom du fichier image à ouvrir
%      comp   vecteur indiquant l'ordre de test des 3 composantes (1:R, 2:G, 3:B)
%             ex: [2 1 3] pour tester G puis R puis B
%             Pour peu dépendre de la luminance, en chaque pixel,
%             les 2e et 3e composantes testées sont d'abord
%             *128/première testée avant comparaison à mn et mx
%      mn     vecteur des minima à détecter de même dim que comp
%             valeurs entre 0 et 255
%      mx     vecteur des maxima à détecter de même dim que comp
%             valeurs entre 0 et 255
%     
if isempty(varargin)
   [fname1,pname1]=uigetfile('*.*','Sélection de l''image');
   %cd(pname1) % rendre son chemin le chemin courant
   U.Im = imread([pname1 fname1]);
   set(handles.figure1, 'Name', fname1)
elseif isstring(varargin{1}) % Si c'est un nom de fichier image
   U.Im = imread(varargin{1});
   set(handles.figure1, 'Name', varargin{1})
elseif (length(size(varargin{1}))==3) && (size(varargin{1},3)==3) % Si c'est une image
   U.Im = varargin{1};
end
U.IM = {U.Im(:,:,1) U.Im(:,:,2) U.Im(:,:,3)}; % Image en 3 cells
if length(varargin)<2
   U.comp = input('Ordre des composantes à tester, ex: BRG (def: RGB pour Rouge dominant) ? ', 'S');
   if isempty(U.comp)
      U.comp = [1 2 3]; % tester R (principale) puis G puis B
   else
      switch strrep(strrep(upper(U.comp), ' ', ''), 'V', 'G')
         case {'RGB' '123'}
            U.comp = [1 2 3];
         case {'RBG' '132'}
            U.comp = [1 3 2];
         case {'GRB' '213'}
            U.comp = [2 1 3];
         case {'GBR' '231'}
            U.comp = [2 3 1];
         case {'BRG' '312'}
            U.comp = [3 1 2];
         case {'BGR' '321'}
            U.comp = [3 2 1];
         otherwise
            disp('Error: donner un ordre tel que RGB BRV GRB VBR, ...')
            brol
      end
   end
else
   U.comp = varargin{2};
end
if length(varargin)<3
   U.mn = [0 0 0];
else
   U.mn = varargin{3};
end
if length(varargin)<4
   U.mx = [255 255 255]; % La première composante est supposée virtuellement ramenée à 128, 64 indique la moitié pour les 2e et 3e par rapport à la 1ère
else
   U.mx = varargin{4};
end
% Couleurs des slider suivant ordre des composantes
ColMax = [1 .3 .3; 0 1   0; .3 .3 1];
ColMin = [1 0  0 ; 0 .75 0; 0  0  1];
set(handles.slider1max, 'BackgroundColor', ColMax(U.comp(1),:))
set(handles.slider1max, 'Value', U.mx(1))
set(handles.slider1min, 'BackgroundColor', ColMin(U.comp(1),:))
set(handles.slider1min, 'Value', U.mn(1))
set(handles.slider2max, 'BackgroundColor', ColMax(U.comp(2),:))
set(handles.slider2max, 'Value', U.mx(2))
set(handles.slider2min, 'BackgroundColor', ColMin(U.comp(2),:))
set(handles.slider2min, 'Value', U.mn(2))
set(handles.slider3max, 'BackgroundColor', ColMax(U.comp(3),:))
set(handles.slider3max, 'Value', U.mx(3))
set(handles.slider3min, 'BackgroundColor', ColMin(U.comp(3),:))
set(handles.slider3min, 'Value', U.mn(3))

colOK = detectcolor(U.Im, U.comp, U.mn, U.mx);
% Affichage image
axes(handles.axes1)
image(U.Im)
set(gca,'DataAspectRatio', [1 1 1])
% Affichage image avec détection
U.ColFond = [255 255 255]; % Couleur où non détection (0-255)
ImOut = U.Im;
for k = 3:-1:1
   ImOutk = ones(size(U.IM{1})) * U.ColFond(k);
   ImOutk(colOK>0) = U.IM{k}(colOK>0);
   ImOut(:,:,k) = ImOutk;
end
axes(handles.axes2)
U.hImOut = image(ImOut);
set(gca,'DataAspectRatio', [1 1 1])
set(handles.figure1, 'UserData', U) % Sauver image et ses paramètres
%\____________________________________________________________________________________/

% --- Outputs from this function are returned to the command line.
function varargout = SelectCol_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1min_Callback(hObject, eventdata, handles)
% hObject    handle to slider1min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
m = round(get(hObject, 'Value'));
set(hObject, 'Value', m);
set(handles.text1min, 'String', num2str(m))
U = get(handles.figure1, 'UserData'); % Récupérer image et ses paramètres
U.mn(1) = m;
set(handles.figure1, 'UserData', U) % Sauver image et ses paramètres
refreshDetect(U, handles)
%\____________________________________________________________________________________/


% --- Executes during object creation, after setting all properties.
function slider1min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider1max_Callback(hObject, eventdata, handles)
% hObject    handle to slider1max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
m = round(get(hObject, 'Value'));
set(hObject, 'Value', m);
set(handles.text1max, 'String', num2str(m))
U = get(handles.figure1, 'UserData'); % Récupérer image et ses paramètres
U.mx(1) = m;
set(handles.figure1, 'UserData', U) % Sauver image et ses paramètres
refreshDetect(U, handles)
%\____________________________________________________________________________________/

% --- Executes during object creation, after setting all properties.
function slider1max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2min_Callback(hObject, eventdata, handles)
% hObject    handle to slider2min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
m = round(get(hObject, 'Value'));
set(hObject, 'Value', m);
set(handles.text2min, 'String', num2str(m))
U = get(handles.figure1, 'UserData'); % Récupérer image et ses paramètres
U.mn(2) = m;
set(handles.figure1, 'UserData', U) % Sauver image et ses paramètres
refreshDetect(U, handles)
%\____________________________________________________________________________________/


% --- Executes during object creation, after setting all properties.
function slider2min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2max_Callback(hObject, eventdata, handles)
% hObject    handle to slider2max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
m = round(get(hObject, 'Value'));
set(hObject, 'Value', m);
set(handles.text2max, 'String', num2str(m))
U = get(handles.figure1, 'UserData'); % Récupérer image et ses paramètres
U.mx(2) = m;
set(handles.figure1, 'UserData', U) % Sauver image et ses paramètres
refreshDetect(U, handles)
%\____________________________________________________________________________________/


% --- Executes during object creation, after setting all properties.
function slider2max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider3min_Callback(hObject, eventdata, handles)
% hObject    handle to slider3min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
m = round(get(hObject, 'Value'));
set(hObject, 'Value', m);
set(handles.text3min, 'String', num2str(m))
U = get(handles.figure1, 'UserData'); % Récupérer image et ses paramètres
U.mn(3) = m;
set(handles.figure1, 'UserData', U) % Sauver image et ses paramètres
refreshDetect(U, handles)
%\____________________________________________________________________________________/


% --- Executes during object creation, after setting all properties.
function slider3min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider3max_Callback(hObject, eventdata, handles)
% hObject    handle to slider3max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
m = round(get(hObject, 'Value'));
set(hObject, 'Value', m);
set(handles.text3max, 'String', num2str(m))
U = get(handles.figure1, 'UserData'); % Récupérer image et ses paramètres
U.mx(3) = m;
set(handles.figure1, 'UserData', U) % Sauver image et ses paramètres
refreshDetect(U, handles)
%\____________________________________________________________________________________/


% --- Executes during object creation, after setting all properties.
function slider3max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
%/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
U = get(handles.figure1, 'UserData'); % Récupérer image et ses paramètres
U.ColFond = [255 255 255]; % BLANC Couleur où non détection (0-255)
set(handles.figure1, 'UserData', U) % Sauver image et ses paramètres
refreshDetect(U, handles)
%\____________________________________________________________________________________/


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
%/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
U = get(handles.figure1, 'UserData'); % Récupérer image et ses paramètres
U.ColFond = [0 0 0]; % NOIR Couleur où non détection (0-255)
set(handles.figure1, 'UserData', U) % Sauver image et ses paramètres
refreshDetect(U, handles)
%\____________________________________________________________________________________/


% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3
%/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
U = get(handles.figure1, 'UserData'); % Récupérer image et ses paramètres
U.ColFond = [128 20 180]; % VIOLET Couleur où non détection (0-255)
set(handles.figure1, 'UserData', U) % Sauver image et ses paramètres
refreshDetect(U, handles)
%\____________________________________________________________________________________/


% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton4
%/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
U = get(handles.figure1, 'UserData'); % Récupérer image et ses paramètres
U.ColFond = [102 102 102]; % GRIS Couleur où non détection (0-255)
set(handles.figure1, 'UserData', U) % Sauver image et ses paramètres
refreshDetect(U, handles)
%\____________________________________________________________________________________/


%######################################################################################
function refreshDetect(U, handles)
% Mise à jour de l'affichage de couleur détectée
colOK = detectcolor(U.Im, U.comp, U.mn, U.mx);
ImOut = U.Im;
for k = 3:-1:1 % Pour chaque plan de couleur
   ImOutk = ones(size(U.IM{1})) * U.ColFond(k); % Image avec couleur de fond partout
   ImOutk(colOK>0) = U.IM{k}(colOK>0); % Dessin des objets où détection de couleur OK
   ImOut(:,:,k) = ImOutk;
end
set(U.hImOut, 'CData', ImOut)

