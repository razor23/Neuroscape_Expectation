% Removes ICA components based on user input

clear all; close all; clc;

%% Parameters
InDir = 'D:\Expectation\Step4\Trial5';
OutDir = 'D:\Expectation\Step5\Trial5';
Groups = {'Older','Young'};%, 'Younger'};
Subjects1 = [50];% 51 55 57:62 64:69]; %62 %older adults - dunno 52 (3 SKHLs, 1 SKLL...)50:51 53:55 57:70 %errr on ,61,70 SKLL2
Subjects2 = [25];%:9 14:22 24:26]; %younger adults
Conds = {'SKHL','SU'};%'SKHL','SU'};
EpochLabels = {'Faces'};
InterpElecs={'PO3'};
load ('ChanLocs64.mat');



%% Load Data
for G=1%:length(Groups)
    eval(sprintf('Subjects = Subjects%d;',G));
    for s =1:length(Subjects)
        inpath = sprintf('%s\\%s\\%d', InDir, Groups{G}, Subjects(s));
        
        for c = 1:length(Conds)
            for type = 1:length(EpochLabels)
                EpochLabel = EpochLabels{type};
                infile = sprintf('%d_%s.set', Subjects(s), Conds{c});
                inpath = sprintf('%s\\%s\\%d', InDir, Groups{G}, Subjects(s));
                EEG = pop_loadset('filename',infile,'filepath',inpath);    
                EEG.urchanlocs = locs;
                EEG.chanlocs = locs;

               
            
%                             %% Rereference
%             EEG = pop_reref(EEG,[]);
%             
%                 %% Interpolation
%             load ('ChanLocs64.mat');
%             EEG.urchanlocs = locs;
%             EEG.chanlocs = locs;
%             labels = {EEG.chanlocs.labels};
%             for e = 1:length(InterpElecs)
%                 indx = strmatch(InterpElecs{e},labels,'exact');
%                 EEG = pop_interp(EEG,indx,'spherical');
%             end
            clear indx
            
            %% Get user input
            indx = inputdlg({'ICA components to reject:'},'Do Something!');
            indx = cell2mat(indx);
            
            %% Remove components
            acts = reshape(EEG.activations,[EEG.nbchan EEG.pnts*EEG.trials]);          
            EEG.icawinv(:,indx) = [];
            EEG.icaweights(indx,:) = [];
            acts(indx,:) = [];
            
            %% Export data
          
            % EEG.icachansind(indx) = [];
            EEG.icaact = acts;
            EEG.icaremoved = indx;
            EEG.data = EEG.icawinv*acts;
            subject_outdir = sprintf('%s/%s/%d', OutDir, Groups{G}, Subjects(s));
            outfile = sprintf('%d_%s_%s.set', Subjects(s), Conds{c}, EpochLabels{type});
            if ~exist(subject_outdir,'dir')
                mkdir(subject_outdir);
            end
        

            %% save dataset
  
            EEG = pop_saveset(EEG,'filename',outfile,'filepath',subject_outdir,'savemode','onefile');
            
       end %for epoch
    end %for cond
end % for subject
end % group
