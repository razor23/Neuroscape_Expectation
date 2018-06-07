%% Removes fastICA components

clear all; close all; clc;

%% Parameters
InDir = 'D:\Expectation\Step4\Trial5';
OutDir = 'D:\Expectation\Step5\Trial5';
Groups = {'Older','Young'};
Subjects1 =  [50:51 55 57:62 64:69];% 51 55 57:62 64:69]; 
Subjects2 = [3:9 14:22 24:26];%19:22 24 26];%:9 14:22 24:26];
Conds = {'SU','SKHL'};
EpochLabels = {'Faces'};
load ('ChanLocs64.mat');


%% Load Data
for G=2%:length(Groups)
    eval(sprintf('Subjects = Subjects%d;',G));
    for s =1:length(Subjects)
        inpath = sprintf('%s\\%s\\%d', InDir, Groups{G}, Subjects(s));
        
        for C = 1:length(Conds)
            for type = 1:length(EpochLabels)
                EpochLabel = EpochLabels{type};
                infile = sprintf('%d_%s.set', Subjects(s), Conds{C});
                inpath = sprintf('%s\\%s\\%d', InDir, Groups{G}, Subjects(s));
                EEG = pop_loadset('filename',infile,'filepath',inpath);    

                
            %% Remove components
          
            winv = EEG.T\EEG.W';
            dim = size(EEG.data);
            temp = reshape(EEG.data,dim(1),dim(2)*dim(3));
          
            for c = 1:64
                z = winv(:,c)*EEG.Zica(c,:);
                pvaf(c) = 100-100*mean(var(temp-z,[],2),1)./mean(var(temp,[],2),1);
            end
            
            [x indx] = sort(pvaf,2,'descend');
            
           %% Confirming bad component
           
            figure; 
            pnums1 = 1:2:19;
            pnums2 = 2:2:20;
            for p = 1:10
                subplot(10,2,pnums1(p))
                topoplot(EEG.W(indx(p),:),locs);
                title(sprintf('Comp.: %d',p) )
                subplot(10,2,pnums2(p))
                plot(EEG.Zica(indx(p),1:30000))
            end
            
            
            drawnow;
             figure; 
            pnums3 = 1:2:19;
            pnums4 = 2:2:20
            
               for p = 1:10
                subplot(10,2,pnums3(p))
                topoplot(EEG.W(indx(p+10),:),locs);
                title(sprintf('Comp.: %d',p+10) )
                subplot(10,2,pnums4(p))
                plot(EEG.Zica(indx(p+10),1:30000))
               end
             drawnow;
            
             
             
            pause;
            RejComp = str2num(cell2mat(inputdlg('Reject Component: ')));
            j=indx(RejComp);
            
            
           %% Exporting component
            
            winv(:,j)=[];
            EEG.Zica(j,:)=[];
            z = winv*EEG.Zica+repmat(EEG.mu,1,size(temp,2));
            temp=reshape(z,dim); 
            EEG.data=temp;
            clear temp RejComp j x indx
            
           %% Save dataset
          
            subject_outdir = sprintf('%s/%s/%d', OutDir, Groups{G}, Subjects(s));
            outfile = sprintf('%d_%s_%s.set', Subjects(s), Conds{C}, EpochLabels{type});
            if ~exist(subject_outdir,'dir')
                mkdir(subject_outdir);
            end
            
  
            EEG = pop_saveset(EEG,'filename',outfile,'filepath',subject_outdir,'savemode','onefile');
            
       end %for epoch
    end %for cond
end % for subject
end % group
