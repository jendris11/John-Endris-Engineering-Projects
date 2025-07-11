%% Final Project

clear;
clc;
data=readmatrix('finalTest1.csv');

timeStamps=[2 60 85 165 186 258 289 370 420 690 696 849];
parsedActTimes=timeParse(data,timeStamps);

[final,indexStamps]=labelActivities(parsedActTimes,timeStamps);
%%
NFFT=100;   % number of FFT points
Fs=50;      % sampling frequency
previous=1;

window = 100; %window size
overlap = 0.5*window; %50percent overlap
labels=[];
count=1;
actCount=1;
MatX=[];
MatY=[];
MatZ=[];
MeanMatX=[];
MeanMatY=[];
MeanMatZ=[];
VarMatX=[];
VarMatY=[];
VarMatZ=[];
Pwr_X=[];
Pwr_Y=[];
Pwr_Z=[];


PwrMatXA1=[];
PwrMatYA1=[];
PwrMatZA1=[];

PwrMatXA2=[];
PwrMatYA2=[];
PwrMatZA2=[];

PwrMatXA3=[];
PwrMatYA3=[];
PwrMatZA3=[];

PwrMatXA4=[];
PwrMatYA4=[];
PwrMatZA4=[];

PwrMatXA5=[];
PwrMatYA5=[];
PwrMatZA5=[];

for i1=1:2:length(indexStamps) % Loops through each set of data
    len = indexStamps(i1+1)-indexStamps(i1); %This is where i2 grab the single activity data

    parsedData=[];

    parsedData(:,1) = data(indexStamps(i1):indexStamps(i1+1),4);
    parsedData(:,2) = data(indexStamps(i1):indexStamps(i1+1),5);
    parsedData(:,3) = data(indexStamps(i1):indexStamps(i1+1),6);

    [b,a]=butter(1,0.0001,'high');
    parsedDataAFilt=filtfilt(b,a,parsedData(:,1:3));

    cut=0;
    for i2=1:overlap:len-window % Find means loop (calculations loop)

        idxNew = ceil(i2/overlap);
        idxOld = i2+window;
        idxBand = i2+1000;

        MeanX(idxNew)=mean(parsedData(i2:idxOld,1));   % mean of 1nd column
        MeanY(idxNew)=mean(parsedData(i2:idxOld,2));   % mean of 2rd column
        MeanZ(idxNew)=mean(parsedData(i2:idxOld,3));   % mean of 3th column


        VarX(idxNew)= var(parsedData(i2:idxOld,1));
        VarY(idxNew)= var(parsedData(i2:idxOld,2));
        VarZ(idxNew)= var(parsedData(i2:idxOld,3));




        %% Power
        Temp_Pwr_x1=abs(specgram(parsedDataAFilt(i2:idxOld-81,1))).^2; % pwr
        Temp_Pwr_y1=abs(specgram(parsedDataAFilt(i2:idxOld-81,2))).^2;
        Temp_Pwr_z1=abs(specgram(parsedDataAFilt(i2:idxOld-81,3))).^2;

        Temp_Pwr_x2=abs(specgram(parsedDataAFilt(i2:idxOld-61,1))).^2; % pwr
        Temp_Pwr_y2=abs(specgram(parsedDataAFilt(i2:idxOld-61,2))).^2;
        Temp_Pwr_z2=abs(specgram(parsedDataAFilt(i2:idxOld-61,3))).^2;

        Temp_Pwr_x3=abs(specgram(parsedDataAFilt(i2:idxOld-41,1))).^2; % pwr
        Temp_Pwr_y3=abs(specgram(parsedDataAFilt(i2:idxOld-41,2))).^2;
        Temp_Pwr_z3=abs(specgram(parsedDataAFilt(i2:idxOld-41,3))).^2;

        Temp_Pwr_x4=abs(specgram(parsedDataAFilt(i2:idxOld-21,1))).^2; % pwr
        Temp_Pwr_y4=abs(specgram(parsedDataAFilt(i2:idxOld-21,2))).^2;
        Temp_Pwr_z4=abs(specgram(parsedDataAFilt(i2:idxOld-21,3))).^2;

        Temp_Pwr_x5=abs(specgram(parsedDataAFilt(i2:idxOld-1,1))).^2; % pwr
        Temp_Pwr_y5=abs(specgram(parsedDataAFilt(i2:idxOld-1,2))).^2;
        Temp_Pwr_z5=abs(specgram(parsedDataAFilt(i2:idxOld-1,3))).^2;


        Pwr_x1(ceil(i2/overlap))=sum(Temp_Pwr_x1); % pwr
        Pwr_y1(ceil(i2/overlap))=sum(Temp_Pwr_y1);
        Pwr_z1(ceil(i2/overlap))=sum(Temp_Pwr_z1);

        Pwr_x2(ceil(i2/overlap))=sum(Temp_Pwr_x2); % pwr
        Pwr_y2(ceil(i2/overlap))=sum(Temp_Pwr_y2);
        Pwr_z2(ceil(i2/overlap))=sum(Temp_Pwr_z2);

        Pwr_x3(ceil(i2/overlap))=sum(Temp_Pwr_x3); % pwr
        Pwr_y3(ceil(i2/overlap))=sum(Temp_Pwr_y3);
        Pwr_z3(ceil(i2/overlap))=sum(Temp_Pwr_z3);

        Pwr_x4(ceil(i2/overlap))=sum(Temp_Pwr_x4); % pwr
        Pwr_y4(ceil(i2/overlap))=sum(Temp_Pwr_y4);
        Pwr_z4(ceil(i2/overlap))=sum(Temp_Pwr_z4);

        Pwr_x5(ceil(i2/overlap))=sum(Temp_Pwr_x5); % pwr
        Pwr_y5(ceil(i2/overlap))=sum(Temp_Pwr_y5);
        Pwr_z5(ceil(i2/overlap))=sum(Temp_Pwr_z5);



    end
    %% Compile Temporary
    MeanMatX=[MeanMatX,MeanX];
    MeanMatY=[MeanMatY,MeanY];
    MeanMatZ=[MeanMatZ,MeanZ];



    VarMatX=[VarMatX,VarX];
    VarMatY=[VarMatY,VarY];
    VarMatZ=[VarMatZ,VarZ];


    %% PWR bands
    PwrMatXA1=[PwrMatXA1,Pwr_x1];
    PwrMatYA1=[PwrMatYA1,Pwr_y1];
    PwrMatZA1=[PwrMatZA1,Pwr_z1];

    PwrMatXA2=[PwrMatXA2,Pwr_x2];
    PwrMatYA2=[PwrMatYA2,Pwr_y2];
    PwrMatZA2=[PwrMatZA2,Pwr_z2];

    PwrMatXA3=[PwrMatXA3,Pwr_x3];
    PwrMatYA3=[PwrMatYA3,Pwr_y3];
    PwrMatZA3=[PwrMatZA3,Pwr_z3];

    PwrMatXA4=[PwrMatXA4,Pwr_x4];
    PwrMatYA4=[PwrMatYA4,Pwr_y4];
    PwrMatZA4=[PwrMatZA4,Pwr_z4];

    PwrMatXA5=[PwrMatXA5,Pwr_x5];
    PwrMatYA5=[PwrMatYA5,Pwr_y5];
    PwrMatZA5=[PwrMatZA5,Pwr_z5];


    if i1==1
        new=length(MeanX)-1;
    else
        new=length(MeanX);
    end


    labels(previous:previous+new)=actCount;
    actCount=actCount+1;
    previous=previous+new;
end

ActMat=[MeanMatX',MeanMatY',MeanMatZ',...
    VarMatX',VarMatY',VarMatZ',...
    PwrMatXA1',PwrMatYA1',PwrMatZA1',PwrMatXA2',PwrMatYA2',PwrMatZA2',...
    PwrMatXA3',PwrMatYA3',PwrMatZA3',...
    PwrMatXA4',PwrMatYA4',PwrMatZA4',PwrMatXA5',PwrMatYA5',PwrMatZA5',...
    labels'];

disp('Done');
