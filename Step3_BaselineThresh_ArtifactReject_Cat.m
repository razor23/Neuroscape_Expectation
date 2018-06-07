%% Baseline correct & artifact reject

clear all; close all; clc;

%% Parameters
Groups = {'Older', 'Young'};
Subjects1 = [50];% 51 55 57 59:61 64:66 68:69];%50 51 55 57 59:61 64:66 68:69];%50 51 55 57 58:62 64:69]; %older adults, weird labels
Subjects2 = [8];% 3:9 14:22 24:26]; %younger adults

Conds = {'SU'};


InDir = 'D:\Expectation\Step2\Trial5'; % Raw BDF data
OutDir = 'D:\Expectation\Step3\Trial5'; % Output directory for .set files

EpochLabels = {'Faces'}; %labels for the markers, number of labels must match number of markers -- encode = stim 1

BaseWin = [-4000 -3750]; % window to average for baseline (based on Ted's GoDD paper)
Thresh = 100; % amplitude in uV to reject data
ThreshWin = [-600 0]; % time window to identify artifacts
ThreshElec = 4; % number of electrodes to exceed Thresh for trial rejection
load('reject_trials.mat'); %reject trials matrix
load('count_trials.mat'); %total trials matrix
%% Load data
for G = 1%:length(Groups)
    eval(sprintf('Subjects = Subjects%d;',G));
    for S = 1:length(Subjects)
        for type = 1:length(EpochLabels)
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SKHL & SU
            for C = 1:length(Conds)
                Cond1 = Conds{C};
                EpochLabel = EpochLabels{type};
                infile= sprintf('%d_%s_%s.set', Subjects(S), Cond1, EpochLabel);
                inpath = sprintf('%s\\%s\\%d', InDir, Groups{G}, Subjects(S));
                EEG = pop_loadset('filename',infile,'filepath',inpath);
            
            
            %% Baseline correct
            tindx = find(EEG.times >= BaseWin(1) & EEG.times <= BaseWin(2));
            EEG.data = EEG.data - repmat(mean(EEG.data(:,tindx,:),2),[1,size(EEG.data,2),1]);
            EEG.Baseline = BaseWin;
            
            %% Artifact reject
            tindx = find(EEG.times >= ThreshWin(1) & EEG.times <= ThreshWin(2));
            BadEpoch = [];
            for t = 1:size(EEG.data,3)
                indx = find(max(abs(squeeze(EEG.data(:,tindx,t))'))>Thresh);
                if length(indx) >= ThreshElec
                    BadEpoch = [BadEpoch t];
                end
            end
            EEG.BadEpoch = BadEpoch;
                 %% Remove bad data     
                 
                if AllCount{G}(S,C) == size(EEG.data,3)
                    U=union(AllRej{G}{S,C},EEG.BadEpoch)
                    EEG.data(:,:,U) = [];
                else
                    EEG.data(:,:,EEG.BadEpoch) = [];
                end
                
            
            %% Throwing out >400uV trials

            test = find (squeeze(max(max((abs(EEG.data)))))>400);
            EEG.data(:,:,test)=[];
            
            %% Save data
            subject_outdir = sprintf('%s\\%s\\%d', OutDir, Groups{G}, Subjects(S));
            outfile = sprintf('%d_%s_%s.set', Subjects(S),Cond1, EpochLabels{type});
            if ~exist(subject_outdir,'dir')
                mkdir(subject_outdir);
            end
            EEG = pop_saveset(EEG,'filename',outfile,'filepath',subject_outdir,'savemode','onefile');
            clear EEG
            end  % Conds
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SKLL
%             for C = 1:length(Conds2)
%                 Cond2 = Conds2{C};
%                 EpochLabel = EpochLabels{type};
%                 infile{C} = sprintf('%d_%s_%s.set', Subjects(S), Cond2, EpochLabel);
%                 inpath = sprintf('%s\\%s\\%d', InDir, Groups{G}, Subjects(S));
%                 EEG{C} = pop_loadset('filename',infile{C},'filepath',inpath);
%             end % Conds
%             
%             EEG{1,1}.data = cat(3,EEG{1,1}.data,EEG{1,2}.data);
%             clear EEG{1,2};
%             
%             EEG = EEG{1,1};
%             
%             if isfield(EEG,'BadEpoch')
%                 Resp = questdlg('This subject has already been processed. Overwrite Bad Epochs?', ...
%                     'WARNING','Overwrite','Abort','Abort');
%                 switch Resp
%                     case 'Overwrite'
%                         fprintf('\n*** Once artifacts have been identified, EEG.BadEpochs will be overwritten. *** \n\n')
%                     case 'Abort'
%                         break
%                 end %Resp
%             end
%             
%             %% Baseline correct
%             tindx = find(EEG.times >= BaseWin(1) & EEG.times <= BaseWin(2));
%             EEG.data = EEG.data - repmat(mean(EEG.data(:,tindx,:),2),[1,size(EEG.data,2),1]);
%             EEG.Basline = BaseWin;
%             
%             %% Artifact reject
%             tindx = find(EEG.times >= ThreshWin(1) & EEG.times <= ThreshWin(2));
%             BadEpoch = [];
%             for t = 1:size(EEG.data,3)
%                 indx = find(max(abs(squeeze(EEG.data(:,tindx,t))'))>Thresh);
%                 if length(indx) >= ThreshElec
%                     BadEpoch = [BadEpoch t];
%                 end
%             end
%             EEG.BadEpoch = BadEpoch;
%             
%              %% Throwing out >400uV trials
% 
%             test = find (squeeze(max(max((abs(EEG.data)))))>400);
%             EEG.data(:,:,test)=[];
%             
%             %% Save data
%             subject_outdir = sprintf('%s\\%s\\%d', OutDir, Groups{G}, Subjects(S));
%             outfile = sprintf('%d_SKLL_%s.set', Subjects(S), EpochLabels{type});
%             if ~exist(subject_outdir,'dir')
%                 mkdir(subject_outdir);
%             end
%             EEG = pop_saveset(EEG,'filename',outfile,'filepath',subject_outdir,'savemode','onefile');
%             clear EEG
%             
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SU
%             for C = 1:length(Conds3)
%                 Cond3 = Conds3{C};
%                 EpochLabel = EpochLabels{type};
%                 infile{C} = sprintf('%d_%s_%s.set', Subjects(S), Cond3, EpochLabel);
%                 inpath = sprintf('%s\\%s\\%d', InDir, Groups{G}, Subjects(S));
%                 EEG{C} = pop_loadset('filename',infile{C},'filepath',inpath);
%             end % Conds
%             
%             EEG{1,1}.data = cat(3,EEG{1,1}.data,EEG{1,2}.data,EEG{1,3}.data,EEG{1,4}.data);
%             clear EEG{1,2} EEG{1,3} EEG{1,4};
%             
%             EEG = EEG{1,1};
%             
%             if isfield(EEG,'BadEpoch')
%                 Resp = questdlg('This subject has already been processed. Overwrite Bad Epochs?', ...
%                     'WARNING','Overwrite','Abort','Abort');
%                 switch Resp
%                     case 'Overwrite'
%                         fprintf('\n*** Once artifacts have been identified, EEG.BadEpochs will be overwritten. *** \n\n')
%                     case 'Abort'
%                         break
%                 end %Resp
%             end
%             
%             %% Baseline correct
%             tindx = find(EEG.times >= BaseWin(1) & EEG.times <= BaseWin(2));
%             EEG.data = EEG.data - repmat(mean(EEG.data(:,tindx,:),2),[1,size(EEG.data,2),1]);
%             EEG.Basline = BaseWin;
%             
%             %% Artifact reject
%             tindx = find(EEG.times >= ThreshWin(1) & EEG.times <= ThreshWin(2));
%             BadEpoch = [];
%             for t = 1:size(EEG.data,3)
%                 indx = find(max(abs(squeeze(EEG.data(:,tindx,t))'))>Thresh);
%                 if length(indx) >= ThreshElec
%                     BadEpoch = [BadEpoch t];
%                 end
%             end
%             EEG.BadEpoch = BadEpoch;
%              %% Throwing out >400uV trials
% 
%             test = find (squeeze(max(max((abs(EEG.data)))))>400);
%             EEG.data(:,:,test)=[];
%             
%             %% Save data
%             subject_outdir = sprintf('%s\\%s\\%d', OutDir, Groups{G}, Subjects(S));
%             outfile = sprintf('%d_SU_%s.set', Subjects(S), EpochLabels{type});
%             if ~exist(subject_outdir,'dir')
%                 mkdir(subject_outdir);
%             end
%             EEG = pop_saveset(EEG,'filename',outfile,'filepath',subject_outdir,'savemode','onefile');
%             clear EEG
        end %EpochLabels
    end %Subjects
end %Groups