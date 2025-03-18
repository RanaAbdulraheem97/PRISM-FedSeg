
close all
clear all
 load 'PRISM-fedseg' % loading the layers for FRED-Net
% lgraph= layerGraph(net);
% figure,plot(lgraph)
% 
% lgraph = removeLayers(lgraph,'inputImage'); % Removing input image layer to change the image size
% inputImage = imageInputLayer([640 640 3],'Name','inputImage'); % new input image layer
% lgraph = addLayers(lgraph, inputImage); % adding new layer with weights
% lgraph = connectLayers(lgraph,'inputImage','conv1_1'); 
 
Folder = 'D:\PhD\breast\JPG';% Main directory to all images
 
train_img_dir = fullfile(Folder,'img');%Training image directory
imds = imageDatastore(train_img_dir); 
 
classes = ["Tumor","nonTumor"]; %% Class names
labelIDs   = [1 0]; % Class id


train_label_dir = fullfile(Folder,'gt');  %% Training label directory
pxds = pixelLabelDatastore(train_label_dir,classes,labelIDs);

tbl = countEachLabel(pxds); % occurance of iris and non-iris pixels


frequency = tbl.PixelCount/sum(tbl.PixelCount); % frequency of each class

imageFreq = tbl.PixelCount ./ tbl.ImagePixelCount;
classWeights = median(imageFreq) ./ imageFreq;    % frequency balancing median 

pxLayer = pixelClassificationLayer('Name','labels','ClassNames',tbl.Name,'ClassWeights',classWeights); % adding weights tp pixel classification layer

% lgraph = removeLayers(lgraph,'labels'); % deleting previous layer
% lgraph = addLayers(lgraph, pxLayer); % adding new layer with weights
% lgraph = connectLayers(lgraph,'softmax','labels');% retreiving the connection

checkpointPath = pwd
%%% Training options %%%%%

opts = trainingOptions('adam', ...
    'ExecutionEnvironment','gpu',...
    'SquaredGradientDecayFactor',0.95, ...
    'GradientThreshold',4, ...
    'GradientThresholdMethod','global-l2norm', ...
    'Epsilon',1e-6, ...
    'InitialLearnRate',1e-4, ...
    'L2Regularization',0.0005, ...
    'MaxEpochs',100, ...  
    'MiniBatchSize',4., ...
    'CheckpointPath',tempdir, ...
    'Shuffle','every-epoch', ...
   'VerboseFrequency',2,...
    'Plots','training-progress');
augment_data = imageDataAugmenter('RandXTranslation',[-10 10],'RandYTranslation',[-10 10]); % optional data augmentation

training_data = pixelLabelImageDatastore(imds,pxds,...
    'DataAugmentation',augment_data); %% complete image+label data
%     load('net_checkpoint__2840__2021_04_04__14_05_45','net');
% % options = trainingOptions('sgdm', ...
%     'Momentum',0.9, ...
%     'InitialLearnRate',1e-3, ...
%     'L2Regularization',0.0005, ...
%     'MaxEpochs',25, ...  
%     'MiniBatchSize',4, ...
%     'Shuffle','every-epoch', ...
%     'CheckpointPath', tempdir, ...
%     'Verbose',false, ...
%     'Plots','training-progress');
%        net = trainNetwork(training_data,layerGraph(net),options);
 [trainnet, info] = trainNetwork(training_data,lgraph,opts);% Train the network

% 
%  load('net_checkpoint__16800__2020_02_01__00_38_04','net');
% % options = trainingOptions('sgdm', ...
% %       'ExecutionEnvironment','multi-gpu',...
% %     'Momentum',0.9, ...
% %     'InitialLearnRate',5e-3, ...
% %     'L2Regularization',0.0005, ...
% %     'MaxEpochs',3, ...  
% %     'MiniBatchSize',2, ...
% %     'CheckpointPath',tempdir, ...
% %     'Shuffle','every-epoch', ...
% %     'VerboseFrequency',2,...
% %     'CheckpointPath', checkpointPath, ...
% %     'Plots','training-progress');
% % 
% % 
%  net2 = trainNetwork(training_data,layerGraph(net),options);
