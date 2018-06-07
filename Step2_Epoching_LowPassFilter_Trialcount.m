%% Epoch data & lowpass filter & trial count(epoching at twin 200 msec before stim 1 for both CNV and alpha analysis)

clear all; close all; clc;

%% Parameters
Groups = {'Older', 'Young'};
Subjects1 = [50];%50 51 55 57 59:61 64:66 68:69];%62 64:69];%51 55 58:62 64:66 68:69];%[ 55 57 58 67];% %[50 51 54 59:66 68:70]; %older adults, normal labels
Subjects2 = [8];%3:9 14:22 24:26];%:9 14:22 24:26]; %younger adults, normal labels

Conds ={'SU1','SU2','SU3','SU4'};%,'SKLL1','SKLL2','SU1','SU2','SU3','SU4'}; %SKHL/LL only have faces 
CondName = 'SU'; %MUST MATCH CONDS
InDir = 'D:\Expectation\Step1_1\Trial5'; 
OutDir ='D:\Expectation\Step2\Trial5'; % Output directory for .set files

EpochMarkers = 12; % USE ONLY ONE AT A TIME!! markers to epoch data around - this is just "encode" or stim 1 (12 = faces; 13 = scenes) 
%EpochMarkers = [32780]; % 32781]; %markers to epoch data around - (32780 =
%faces; 32781 = scenes) % people with these markers: 53, 55, 57, 58, 67 & 2
%younger

EpochLabel = 'Faces'; %USE ONLY ONE AT A TIME!! ,'Scenes'}; %labels for the markers, number of labels must match number of markers -- encode = stim 1
EpochWin = [-4000 600]; % epoch window: -200 for CNV/alpha to 800 (based on Zanto 2011)

%% Load data
for G = 1%:length(Groups)
    eval(sprintf('Subjects = Subjects%d;',G));
    for S = 1:length(Subjects)
        for C = 1:length(Conds)
            
            Cond = Conds{C};
            infile = sprintf('%d_%s.set', Subjects(S), Cond);
            inpath = sprintf('%s\\%s\\%d', InDir, Groups{G}, Subjects(S));
            EEG = pop_loadset('filename',infile,'filepath',inpath);
    
            %% Epoch 
            
            markers = mod(cell2mat({EEG.event.type}),2^15); %mod converts 32780 to 12, 32781 to 13, etc.
            PtsWin = round(EpochWin*EEG.srate/1000);
            twin = PtsWin/EEG.srate;
            EEG.xmin = twin(1);
            EEG.xmax = twin(2);
            EEG.times = (EEG.xmin:1/EEG.srate:EEG.xmax).*1000;
            EEG.pnts = length(EEG.times);
            
     
            indx = find(markers == EpochMarkers);
            try
            for t = 1:length(indx)
                onset = EEG.event(indx(t)).latency;         
            if  onset < abs(PtsWin(1))+1    %sometimes onset values are too low which gives a negative timepoint for temp
                
                onset=EEG.event(indx(t+1)).latency;  
                data(:,:,t) = EEG.data(:,onset+PtsWin(1):onset+PtsWin(2));
            else
                data(:,:,t) = EEG.data(:,onset+PtsWin(1):onset+PtsWin(2));
            end
        end
        
        eval(sprintf('data%d = data;',C));
        clear data indx
        end %conds
        end
        %% Save trialwise data
        EEG.data=[];
        for C = 1:length(Conds)
            eval(sprintf('EEG.data = cat(3,EEG.data,data%d);',C));
        end
        subject_outdir = sprintf('%s\\%s\\%d', OutDir, Groups{G},Subjects(S));
        outfile = sprintf('%d_%s_%s.set', Subjects(S), CondName, EpochLabel);
        if ~exist(subject_outdir,'dir')
            mkdir(subject_outdir);
        end
        EEG.trials = size(EEG.data,3);
        for e = 1:length(EEG.event)
            EEG.event(e).epoch = [];
        end
        EEG = pop_saveset(EEG,'filename',outfile,'filepath',subject_outdir,'savemode','onefile');
    end %Subjects
end %Groups
