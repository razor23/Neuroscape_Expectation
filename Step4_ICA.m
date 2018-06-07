%% Running ICA 
                                                                                                                                                                                    
clear all; clc; close all;

%% Parameters

Groups={'Older','Young'};
Subjects1 = [50];%; 51 55 57 59:61 64:66 68:69];% 55 57 58:62 64:69];
Subjects2 = [8];% 3:9 14:22 24:26];
Conds = {'SU'};%,'SKHL','SKLL'};% {'SKHL', 'SKLL', 'SU'};%  'SKLL2', 'SU1', 'SU2', 'SU3', 'SU4'};

InDir = 'D:\Expectation\Step3\Trial5'; % Raw setfile data
OutDir = 'D:\Expectation\Step4\Trial5'; % Output directory for .set files
ElecLoc = 'Z:\TanyaPadgaonkar\ANT\Scripts\ModifiedScripts\ChanLocs64.mat';  %since these are network drives, need to make sure the letter name of the drive is correct, otherwise permissions errors!

for G = 1%:length(Groups)
    eval(sprintf('Subjects = Subjects%d;',G));
    
    for S = 1:length(Subjects)
        subject_outdir = sprintf('%s\\%s\\%d', OutDir,Groups{G}, Subjects(S));
        for c = 1:length(Conds)
            
            outfile = sprintf('%d_%s.set', Subjects(S),Conds{c});
            if ~exist(subject_outdir,'dir')
                mkdir(subject_outdir);
            else
                if exist(sprintf('%s\\%s', subject_outdir, outfile),'file')
                    %             error('This data file has already been preprocessed');
                end
            end
                

%% Load data
     fprintf('Processing subject %d, condition: %s,\n',Subjects(S), Conds{c})
     inpath = sprintf('%s\\%s\\%d', InDir,Groups{G},Subjects(S));
     infile=dir(sprintf('%s\\*%s*.set',inpath,Conds{c}));
     EEG=pop_loadset(infile.name,inpath);
     
     %% Run ICA

    
                dim = size(EEG.data);
                temp = reshape(EEG.data,dim(1),dim(2)*dim(3));
                %temp3 = temp(:,4712:end);    %50_SU:4712;
                [Zica, W, T, mu] = fastICA(temp,64); 
                %to get original data= Zr=T\W'*Zica+repmat(mu,1,size(temp,2))                
                %[EEG.icaweights, EEG.icasphere, EEG.compvars, EEG.bias, EEG.signs, EEG.lrates, EEG.activations] = runica(temp);               
                temp2=reshape(temp,dim);
                EEG.data=temp2; 
                EEG.W=W;
                EEG.Zica=Zica;
                EEG.T=T;
                EEG.mu=mu;             

 
    %% Save data
   EEG = pop_saveset(EEG,'filename',outfile,'filepath',subject_outdir,'savemode','onefile');
   clear exindx EEG labels indx_out indx_in 
end %conditions

end %Subjects
end %Groups