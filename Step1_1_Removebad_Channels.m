%% Remove bad channels

clear all; close all; clc;

%% Parameters
Groups = {'Older', 'Young'};
Subjects1 =  [70];% 55 58:62 64:66 68:69];%[ 55 57 58 67];% %[50 51 54 59:66 68:70]; %older adults, normal labels
Subjects2 = [26];%:9 14:22 24:26];%:9 14:22 24:26]; %younger adults, normal labels
InDir = 'D:\Expectation\Step1\Trial1';
OutDir ='D:\Expectation\Step1_1\Trial5'; % Output directory for .set files
Conds ={'SKHL1','SKHL2','SU1', 'SU2', 'SU3', 'SU4'};
load('Chanlocs64');
c={'P3'};

%% Setup
for G = 2%:length(Groups)
    eval(sprintf('Subjects = Subjects%d;',G));
    for S = 1%:length(Subjects)
        for C = 1:length(Conds)
            
            Cond = Conds{C};
            infile = sprintf('%d_%s.set', Subjects(S), Cond);
            inpath = sprintf('%s\\%s\\%d', InDir, Groups{G}, Subjects(S));
            EEG = pop_loadset('filename',infile,'filepath',inpath);
            
        
            %% Remove bad channels
            
            EEG.urchanlocs = locs;
            EEG.chanlocs = locs;
%
%             EEG=clean_rawdata(EEG,-1,-1,.85,4,-1,.25);
% 
% %             
%             %% Find the bad Channel
%           
%            
%           for i=1:EEG.nbchan
%             a{1,i}=EEG.chanlocs(i).labels;
%           end
%           
%           for i=1:64
%             b{1,i}=originalEEG.chanlocs(i).labels;
%           end  
%           
%           c=setdiff(b,a);         
          
              %% Interpolation

              labels = {EEG.chanlocs.labels};
            for e = 1:length(c)
                indx = strmatch(c{e},labels,'exact');
                EEG = pop_interp(EEG,indx,'spherical');
            end
            
            
            %% Rereference
            
            EEG = pop_reref(EEG,[]);
            
            %% Savedataset
            
            subject_outdir = sprintf('%s\\%s\\%d', OutDir,Groups{G}, Subjects(S));
            outfile = sprintf('%d_%s.set', Subjects(S),Conds{C});
            outfile_old=sprintf('%d_%s_original.set', Subjects(S),Conds{C});
            if ~exist(subject_outdir,'dir')
                mkdir(subject_outdir);
            else
                if exist(sprintf('%s\\%s', subject_outdir, outfile),'file')
                    % error('This data file has already been preprocessed');
                end
            end
            
            EEG = pop_saveset(EEG,'filename',outfile,'filepath',subject_outdir,'savemode','onefile');
        end
    end
end
