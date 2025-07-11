% Activity Matricies

%% Wearable Systems
% John Endris

% Each action was performed for about 30 seconds with 3 seconds of (attempted) stillness. After these 3 secs. the next action was performed.
% Actions in Order; Sit, stand, walk, (simulate) run, stand, sit on the floor, tilt left, tilt right, tilt front, lying down

% Format for acceleromter data matrix:
% 1st column = epoch
% 2nd col = Absolute time and date
% 3rd col = Running time starting at 0
% 4rth column = x-acc.
% 5th col = y-acc.
% 6th col = z-acc.
clear
clf
clc

activityNames=["Sitting","Standing1","Walking","Running","Standing2","Sitting","Lean_Left","Lean_Right","Lean_Forward","Lie_Down"];
wrst=readmatrix('Wrist.csv');
wst=readmatrix('Waist.csv');

%% Parsing Data
% Parsing wrist data columns into separate arrays
wrstT=wrst(:,3);
wrstX=wrst(:,4);
wrstY=wrst(:,5);
wrstZ=wrst(:,6);

% Parsing waist data columns into separate arrays
wstT=wst(:,3);
wstX=wst(:,4);
wstY=wst(:,5);
wstZ=wst(:,6);

%% Create Parsed Matrix for each sensor position
wrstX=wrstX';
wrstY=wrstY';
wrstZ=wrstZ';
wstX=wstX';
wstY=wstY';
wstZ=wstZ';

%Wrst
wrstMatX=get30SecWindowsWrst(wrstX);
wrstMatY=get30SecWindowsWrst(wrstY);
wrstMatZ=get30SecWindowsWrst(wrstZ);

%Waist
wstMatX=get30SecWindowsWst(wstX);
wstMatY=get30SecWindowsWst(wstY);
wstMatZ=get30SecWindowsWst(wstZ);


%% I made the matrix rows 1 element too long so I am deleting them bc it is
%
% % faster than manually changing them
% chstMatX=chstMatX(:,1:1450);
% chstMatY=chstMatY(:,1:1450);
% chstMatZ=chstMatZ(:,1:1450);
%
% wrstMatX=wrstMatX(:,1:1450);
% wrstMatY=wrstMatY(:,1:1450);
% wrstMatZ=wrstMatZ(:,1:1450);
%
% wstMatX=wstMatX(:,1:1450);
% wstMatY=wstMatY(:,1:1450);
% wstMatZ=wstMatZ(:,1:1450);
%
%
% anklMatX=anklMatX(:,1:1450);
% anklMatY=anklMatY(:,1:1450);
% anklMatZ=anklMatZ(:,1:1450);




%% Make Struct of Data
data.wrst.X=wrstMatX;
data.wrst.Y=wrstMatY;
data.wrst.Z=wrstMatZ;

data.wst.X=wstMatX;
data.wst.Y=wstMatY;
data.wst.Z=wstMatZ;

%% Calculations
for i=1:10 % loop through each activity
    %% Mean
    % Wrist
    Means.(activityNames(i)).wrist.wrstMeanX=mean(getDataOverlap(data.wrst.X(i,:)),2);
    Means.(activityNames(i)).wrist.wrstMeanY=mean(getDataOverlap(data.wrst.Y(i,:)),2);
    Means.(activityNames(i)).wrist.wrstMeanZ=mean(getDataOverlap(data.wrst.Z(i,:)),2);

    % Waist
    Means.(activityNames(i)).waist.wstMeanX=mean(getDataOverlap(data.wst.X(i,:)),2);
    Means.(activityNames(i)).waist.wstMeanY=mean(getDataOverlap(data.wst.Y(i,:)),2);
    Means.(activityNames(i)).waist.wstMeanZ=mean(getDataOverlap(data.wst.Z(i,:)),2);


    %% Variance
    % Wrist
    Vars.(activityNames(i)).wrist.wrstVarX=var(getDataOverlap(data.wrst.X(i,:)),0,2);
    Vars.(activityNames(i)).wrist.wrstVarY=var(getDataOverlap(data.wrst.Y(i,:)),0,2);
    Vars.(activityNames(i)).wrist.wrstVarZ=var(getDataOverlap(data.wrst.Z(i,:)),0,2);

    % Waist
    Vars.(activityNames(i)).waist.wstVarX=var(getDataOverlap(data.wst.X(i,:)),0,2);
    Vars.(activityNames(i)).waist.wstVarY=var(getDataOverlap(data.wst.Y(i,:)),0,2);
    Vars.(activityNames(i)).waist.wstVarZ=var(getDataOverlap(data.wst.Z(i,:)),0,2);

    %% Zero Crosses
     a=getDataOverlap(data.wrst.X(i,:));
     b=getDataOverlap(data.wrst.Y(i,:));
     c=getDataOverlap(data.wrst.Z(i,:));

     d=getDataOverlap(data.wst.X(i,:));
     e=getDataOverlap(data.wst.Y(i,:));
     f=getDataOverlap(data.wst.Z(i,:));
for i2=1:30 %Loop through zero crossing rows
    % Wrist
    [~,temp] = zerocrossrate(a(i2,:));
    Zero.(activityNames(i)).wrist.zeroWrstX(i2,1)=temp-.5;
   
    [~,temp] = zerocrossrate(b(i2,:));
    Zero.(activityNames(i)).wrist.zeroWrstY(i2,1)=temp-.5;
    
    [~,temp] = zerocrossrate(c(i2,:));
    Zero.(activityNames(i)).wrist.zeroWrstZ(i2,1)=temp-.5;



    % Waist
    [~,temp] = zerocrossrate(d(i2,:));
    Zero.(activityNames(i)).waist.zeroWstX(i2,1)=temp-.5;
   
    [~,temp] = zerocrossrate(e(i2,:));
    Zero.(activityNames(i)).waist.zeroWstY(i2,1)=temp-.5;
    
    [~,temp] = zerocrossrate(f(i2,:));
    Zero.(activityNames(i)).waist.zeroWstZ(i2,1)=temp-.5;

end
end

%% Power bands
% Wrist
x=readmatrix('Wrist.csv');
y=detrend(x);

NFFT=100;   % number of FFT points
Fs=50;      % sampling frequency
len = length(y(:,1));

window = 100; %window size
overlap = 0.5*window; %50percent overlap
for i=1:overlap:len-window
    xbp1(ceil(i/overlap))=sum(abs(specgram(y(i:i+window-41,4))).^2); % pwr
    xbp2(ceil(i/overlap))=sum(abs(specgram(y(i:i+window-31,4))).^2); % pwr
    xbp3(ceil(i/overlap))=sum(abs(specgram(y(i:i+window-21,4))).^2); % pwr
    xbp4(ceil(i/overlap))=sum(abs(specgram(y(i:i+window-11,4))).^2); % pwr
    xbp5(ceil(i/overlap))=sum(abs(specgram(y(i:i+window-1,4))).^2); % pwr

    ybp1(ceil(i/overlap))=sum(abs(specgram(y(i:i+window-41,5))).^2); % pwr
    ybp2(ceil(i/overlap))=sum(abs(specgram(y(i:i+window-31,5))).^2); % pwr
    ybp3(ceil(i/overlap))=sum(abs(specgram(y(i:i+window-21,5))).^2); % pwr
    ybp4(ceil(i/overlap))=sum(abs(specgram(y(i:i+window-11,5))).^2); % pwr
    ybp5(ceil(i/overlap))=sum(abs(specgram(y(i:i+window-1,5))).^2); % pwr

    zbp1(ceil(i/overlap))=sum(abs(specgram(y(i:i+window-41,6))).^2); % pwr
    zbp2(ceil(i/overlap))=sum(abs(specgram(y(i:i+window-31,6))).^2); % pwr
    zbp3(ceil(i/overlap))=sum(abs(specgram(y(i:i+window-21,6))).^2); % pwr
    zbp4(ceil(i/overlap))=sum(abs(specgram(y(i:i+window-11,6))).^2); % pwr
    zbp5(ceil(i/overlap))=sum(abs(specgram(y(i:i+window-1,6))).^2); % pwr
end

% Waist
xwa=readmatrix('Waist.csv');
ywa=detrend(xwa);

NFFT=100;   % number of FFT points
Fs=50;      % sampling frequency
len = length(ywa(:,1));

window = 100; %window size
overlap = 0.5*window; %50percent overlap
for i=1:overlap:len-window
    xbp1wa(ceil(i/overlap))=sum(abs(specgram(ywa(i:i+window-41,4))).^2); % pwr
    xbp2wa(ceil(i/overlap))=sum(abs(specgram(ywa(i:i+window-31,4))).^2); % pwr
    xbp3wa(ceil(i/overlap))=sum(abs(specgram(ywa(i:i+window-21,4))).^2); % pwr
    xbp4wa(ceil(i/overlap))=sum(abs(specgram(ywa(i:i+window-11,4))).^2); % pwr
    xbp5wa(ceil(i/overlap))=sum(abs(specgram(ywa(i:i+window-1,4))).^2); % pwr

    ybp1wa(ceil(i/overlap))=sum(abs(specgram(ywa(i:i+window-41,5))).^2); % pwr
    ybp2wa(ceil(i/overlap))=sum(abs(specgram(ywa(i:i+window-31,5))).^2); % pwr
    ybp3wa(ceil(i/overlap))=sum(abs(specgram(ywa(i:i+window-21,5))).^2); % pwr
    ybp4wa(ceil(i/overlap))=sum(abs(specgram(ywa(i:i+window-11,5))).^2); % pwr
    ybp5wa(ceil(i/overlap))=sum(abs(specgram(ywa(i:i+window-1,5))).^2); % pwr

    zbp1wa(ceil(i/overlap))=sum(abs(specgram(ywa(i:i+window-41,6))).^2); % pwr
    zbp2wa(ceil(i/overlap))=sum(abs(specgram(ywa(i:i+window-31,6))).^2); % pwr
    zbp3wa(ceil(i/overlap))=sum(abs(specgram(ywa(i:i+window-21,6))).^2); % pwr
    zbp4wa(ceil(i/overlap))=sum(abs(specgram(ywa(i:i+window-11,6))).^2); % pwr
    zbp5wa(ceil(i/overlap))=sum(abs(specgram(ywa(i:i+window-1,6))).^2); % pwr

end

% Readjusting lengths
xbp1(301:303)=[];xbp2(301:303)=[];xbp3(301:303)=[];xbp4(301:303)=[];xbp5(301:303)=[];
ybp1(301:303)=[];ybp2(301:303)=[];ybp3(301:303)=[];ybp4(301:303)=[];ybp5(301:303)=[];
zbp1(301:303)=[];zbp2(301:303)=[];zbp3(301:303)=[];zbp4(301:303)=[];zbp5(301:303)=[];


xbp1wa(301:318)=[];xbp2wa(301:318)=[];xbp3wa(301:318)=[];xbp4wa(301:318)=[];xbp5wa(301:318)=[];
ybp1wa(301:318)=[];ybp2wa(301:318)=[];ybp3wa(301:318)=[];ybp4wa(301:318)=[];ybp5wa(301:318)=[];
zbp1wa(301:318)=[];zbp2wa(301:318)=[];zbp3wa(301:318)=[];zbp4wa(301:318)=[];zbp5wa(301:318)=[];

%% Create Activity Matrix Waist
%WaistActMat=zeros(300,25);

%% Waist
WaistActMat=[];

WstMeanMatX=[];
WstMeanMatY=[];
WstMeanMatZ=[];

WstVarMatX=[];
WstVarMatY=[];
WstVarMatZ=[];

WstZeroMatX=[];
WstZeroMatY=[];
WstZeroMatZ=[];


temp=[];

for i=1:10
    %wristFields=fieldnames(Means.(activityNames(i)).wrist);

    WstMeanMatX=[WstMeanMatX;Means.(activityNames(i)).waist.wstMeanX];% Add 30 rows of means which correspond to the current activity (1 of 10)
    WstMeanMatY=[WstMeanMatY;Means.(activityNames(i)).waist.wstMeanY];
    WstMeanMatZ=[WstMeanMatZ;Means.(activityNames(i)).waist.wstMeanZ];

    WstVarMatX=[WstVarMatX;Vars.(activityNames(i)).waist.wstVarX];% Add 30 rows of means which correspond to the current activity (1 of 10)
    WstVarMatY=[WstVarMatY;Vars.(activityNames(i)).waist.wstVarY];
    WstVarMatZ=[WstVarMatZ;Vars.(activityNames(i)).waist.wstVarZ];

    WstZeroMatX=[WstZeroMatX;Zero.(activityNames(i)).waist.zeroWstX];
    WstZeroMatY=[WstZeroMatY;Zero.(activityNames(i)).waist.zeroWstY];
    WstZeroMatZ=[WstZeroMatZ;Zero.(activityNames(i)).waist.zeroWstZ];

end
WaistActMat=[WstMeanMatX,WstVarMatX,WstZeroMatX,WstMeanMatY,WstVarMatY,WstZeroMatY,WstMeanMatZ,WstVarMatZ,WstZeroMatZ,xbp1',xbp2',xbp3',xbp4',xbp5',ybp1',ybp2',ybp3',ybp4',ybp5',zbp1',zbp2',zbp3',zbp4',zbp5'];
labels=[];

for i=1:10
    temp=[];
    for i2=1:30
        temp(i2)=i;
    end
    labels=[labels;temp'];
end
WaistActMat=[WaistActMat,labels];

%% Wrist
WristActMat=[];

WrstMeanMatX=[];
WrstMeanMatY=[];
WrstMeanMatZ=[];

WrstVarMatX=[];
WrstVarMatY=[];
WrstVarMatZ=[];

WrstZeroMatX=[];
WrstZeroMatY=[];
WrstZeroMatZ=[];


temp=[];

for i=1:10
    %wristFields=fieldnames(Means.(activityNames(i)).wrist);

    WrstMeanMatX=[WrstMeanMatX;Means.(activityNames(i)).wrist.wrstMeanX];% Add 30 rows of means which correspond to the current activity (1 of 10)
    WrstMeanMatY=[WrstMeanMatY;Means.(activityNames(i)).wrist.wrstMeanY];
    WrstMeanMatZ=[WrstMeanMatZ;Means.(activityNames(i)).wrist.wrstMeanZ];

    WrstVarMatX=[WrstVarMatX;Vars.(activityNames(i)).wrist.wrstVarX];% Add 30 rows of means which correspond to the current activity (1 of 10)
    WrstVarMatY=[WrstVarMatY;Vars.(activityNames(i)).wrist.wrstVarY];
    WrstVarMatZ=[WrstVarMatZ;Vars.(activityNames(i)).wrist.wrstVarZ];

    WrstZeroMatX=[WrstZeroMatX;Zero.(activityNames(i)).wrist.zeroWrstX];
    WrstZeroMatY=[WrstZeroMatY;Zero.(activityNames(i)).wrist.zeroWrstY];
    WrstZeroMatZ=[WrstZeroMatZ;Zero.(activityNames(i)).wrist.zeroWrstZ];

end
WristActMat=[WrstMeanMatX,WrstVarMatX,WrstZeroMatX,WrstMeanMatY,WrstVarMatY,WrstZeroMatY,WrstMeanMatZ,WrstVarMatZ,WrstZeroMatZ,xbp1wa',xbp2wa',xbp3wa',xbp4wa',xbp5wa',ybp1wa',ybp2wa',ybp3wa',ybp4wa',ybp5wa',zbp1wa',zbp2wa',zbp3wa',zbp4wa',zbp5wa'];
labels=[];

for i=1:10
    temp=[];
    for i2=1:30
        temp(i2)=i;
    end
    labels=[labels;temp'];
end
WristActMat=[WristActMat,labels];

writematrix(WaistActMat,'WaistMat.csv')
writematrix(WristActMat,'WristMat.csv')
disp('Done')

%% Functions
%% Windows
% Each 30 second interval is different for each sensor position
function mat=get30SecWindowsWrst(place)
mat=[place(1*50:30*50);...
    place(34*50:63*50);...
    place(65*50:94*50);...
    place(99*50:128*50);...
    place(130*50:159*50);...
    place(160*50:189*50);...
    place(170*50:199*50);...
    place(200*50:229*50);...
    place(232*50:261*50);...
    place(270*50:299*50)];
end

function mat=get30SecWindowsWst(place)
mat=[...
    place(1*50:30*50);...
    place(30*50:59*50);...
    place(63*50:92*50);...
    place(95*50:124*50);...
    place(127*50:156*50);...
    place(158*50:187*50);...
    place(188*50:217*50);...
    place(219*50:248*50);...
    place(251*50:280*50);...
    place(283*50:312*50)];

end



%% Data Overlap
function overlappedArray=getDataOverlap(bites)
% The purpose of this function is to create an array of 2 second bites of
% data overlapping by 1 second
% Activities are rows 1:10 from data.position.XYZ

overlappedArray=zeros(30,101);

windowNum=1;
for i=1:50:length(bites)
    if i<1401
        overlappedArray(windowNum,:)=bites(i:i+100);
    end
    if i==1401
        overlappedArray(windowNum,:)=bites(i-50:i+50);
    end
    if i==1451
        overlappedArray(windowNum,:)=bites(i-100:i);
    end
    windowNum=windowNum+1;
    if windowNum>30
        break
    end
end
end

%% Band Power Function
function bandData=getBandPower(bite)
for i=1:height(bite)
    bandData(i)=bandpower(bite(i,:)); % Gets the band power of all 10 activites and puts it into a 1x10 array
end

end
