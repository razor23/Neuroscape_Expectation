%% Calculate ERP data

clear all; close all; clc;

%% Parameters
Groups = {'Older','Young'};%, 'Younger'};
Subjects1 = [50:51 55 57:62 64:69];%[51 55 57 59:60 64:66 68:69];%:51 55 57:62 64:69]; %62 %older adults - dunno 52 (3 SKHLs, 1 SKLL...)50:51 53:55 57:70 %errr on ,61,70 SKLL2
Subjects2 = [3:9 14:22 24:26];% [3:7 9 14:22 24 26]; %younger adults 
Conds = {'SU','SKHL'};%,'SKLL'};
Cycles = 5;
Freqs = [6:30];
Downsample = 10; %how many timepoints to downsample
InDir = 'D:\Expectation\Step5\Trial5'; 
OutDir = 'D:\Expectation\Step6\Trial5\ERP'; 
EpochLabels = {'Faces'}; %labels for the markers, number of labels must match number of markers -- encode = stim 1
load('reject_trials.mat'); %reject trials matrix
load('count_trials.mat'); %total trials matrix

%% Load data
for G = 2%:length(Groups)
    if G==1
      AllRej{G}(:,2)=[];%removing SKLL trials
      AllCount{G}(:,2)=[];%removing SKLL trials
    end
    eval(sprintf('Subjects = Subjects%d;',G));
    for S = 1:length(Subjects)
        for C = 1:length(Conds)
            Cond = Conds{C};
            for type = 1:length(EpochLabels)
                fprintf('Processing subject %d, condition: %s, type: %s\n',Subjects(S), Cond, EpochLabels{type})
                infile = sprintf('%d_%s_%s.set', Subjects(S), Cond, EpochLabels{type});
                inpath = sprintf('%s\\%s\\%d', InDir, Groups{G}, Subjects(S));
                EEG = pop_loadset('filename',infile,'filepath',inpath);
                
                %% Calculate ERP                       
                   ERP.data=mean(EEG.data,3);
                   ERP.times = (EEG.xmin:1/EEG.srate:EEG.xmax)*1000;
                   ERP.labels = {EEG.chanlocs.labels};
                         
                %% Save data
                fprintf('\n\tSaving ERP data...')              
                subject_outdir = sprintf('%s/%s/%d', OutDir, Groups{G}, Subjects(S));
                outfile = sprintf('%d_%s_%s.mat', Subjects(S), Conds{C}, EpochLabels{type});
                if ~exist(subject_outdir,'dir')
                    mkdir(subject_outdir);
                end                
                save(sprintf('%s/%s',subject_outdir,outfile),'ERP','-v7.3');
                fprintf('done\n\n');
                clear EEG ERP
            end % EpochLabels
        end % Conds
    end %Subjects
end %Groups
