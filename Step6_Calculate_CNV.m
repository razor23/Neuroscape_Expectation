%% Calculate CNV

clear all; close all; clc;

%% Parameters
Groups = {'Older','Young'};
Subjects1 = [50:51 55 57:62 64:69];% [51 55 57 59:60 64:66 68:69];%:51 55 57:62 64:69]; %62,66 included
Subjects2 = [3:9 14:22 24:26];% [3:7 9 14:22 24 26]; %younger adults
Conds = {'SKHL','SU'};
InDir ='D:\Expectation\Step6\Trial5\ERP';
OutDir = 'D:\Expectation\Step7\Trial5';
EpochLabel = 'Faces';
clustEOIs= {'CP1','CP2','CP4','CP6','P2','P7','P8','PO3','P10','PO4','PO8','TP7','TP8'};
PostROI= {'CPz','Pz','POz','P1','P2'};  
AntROI={'AFz','Fz','FCz','F1','F2'};
indx=[];

%% Load data
for G = 1:length(Groups)
    eval(sprintf('Subjects = Subjects%d;',G));
    for S = 1:length(Subjects)
        power = [];
        for C = 1:length(Conds)
            Cond = Conds{C};
            fprintf('Processing subject %d, condition: %s\n',Subjects(S), Cond)
            infile = sprintf('%d_%s_%s.mat', Subjects(S), Conds{C}, EpochLabel);
            inpath = sprintf('%s\\%s\\%d', InDir, Groups{G}, Subjects(S));
            load(sprintf('%s/%s',inpath,infile));
            
            %% Calculate CNV 
            
             tindx = find(ERP.times >= twin(1)& ERP.times <= twin(2));
            
            for e = 1:length(AntROI) %ANT electrodes
                indx(e)=strmatch(AntROI(e),ERP.labels,'exact')
            end   
            
            CNVANT{G}(S,C)=mean(mean(ERP.data(indx,tindx)));
            
                 for e = 1:length(PostROI) %POST electrodes
                indx(e)=strmatch(PostROI(e),ERP.labels,'exact')
                 end            
            
            CNVPOST{G}(S,C)=mean(mean(ERP.data(indx,tindx)));
            
            
        end %conds        
    end %Subjects
end %Groups
