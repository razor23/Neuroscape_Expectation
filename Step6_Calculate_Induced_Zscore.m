%% Calculate induced power from morlet coefficients and zscore for normalization
%  normalization is calculated by concatenating all conditions and z-scoring over all time
clear all; close all; clc;

%% Parameters
Groups = {'Older','Young'};
Subjects1 = [50:51 55 57:62 64:69];% [51 55 57 59:60 64:66 68:69];%:51 55 57:62 64:69]; %62,66 included
Subjects2 = [3:9 14:22 24:26];% [3:7 9 14:22 24 26]; %younger adults 
Conds = {'SKHL','SU'};
InDir ='D:\Expectation\Step6\Trial5';  
OutDir = 'D:\Expectation\Step7\Trial5'; 
EpochLabel = 'Faces';
load('reject_trials.mat'); %reject trials matrix
load('count_trials.mat'); %total trials matrix
%% Load data
for G = 1%:length(Groups)
    if G ==1
        AllRej{G}(:,2)=[];%removing SKLL trials
        AllCount{G}(:,2)=[];%removing SKLL trials
        %           if G==1
        %               AllRej{G}([9 12],:)=[]; %removing subjects 62,66 from OA
        %               AllCount{G}([9 12],:)=[];
    end
    eval(sprintf('Subjects = Subjects%d;',G));
    for S = 1:length(Subjects)
        power = [];
        for C = 1:length(Conds)
            Cond = Conds{C};
            fprintf('Processing subject %d, condition: %s\n',Subjects(S), Cond)
            infile = sprintf('%d_%s_%s.mat', Subjects(S), Conds{C}, EpochLabel);
            inpath = sprintf('%s\\%s\\%d', InDir, Groups{G}, Subjects(S));
            load(sprintf('%s/%s',inpath,infile));
            
            %% Trial mismatch Caluclation
            
            Diff{G}(S,C)=AllCount{G}(S,C)-size(AllRej{G}{S,C}(1:end),2);
            Trial{G}(S,C)=size(Coefs.Data,4);
            %% Reject bad trials
            
                      %Coefs.Data(:,:,:,AllRej{G}{S,C}(1:end))=[];
            %% Calculate induced power
                         power = cat(2,power,mean(abs(Coefs.Data).^2,4));
        end
        %% Normalize data
        power = zscore(power,[],2);
        
        %% Save data
        fprintf('\n\tSaving data...')
        Induced = Coefs;
                Induced.Info = 'Frequency x Time x Electrode';
                for C = 1:length(Conds)
                    Induced.Data = power(:,1:length(Coefs.Times),:);
                    power(:,1:length(Coefs.Times),:) = [];
                    subject_outdir = sprintf('%s/%s/%d', OutDir, Groups{G}, Subjects(S));
                    outfile = sprintf('%d_%s_%s.mat', Subjects(S), Conds{C}, EpochLabel);
                    if ~exist(subject_outdir,'dir')
                        mkdir(subject_outdir);
                    end
                    save(sprintf('%s/%s',subject_outdir,outfile),'Induced','-v7.3');
                end %for cond
                clear Coefs Induced power
        fprintf('done\n\n');
    end %Subjects
end %Groups
