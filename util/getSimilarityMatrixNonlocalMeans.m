function [simMatrix,opt] = getSimilarityMatrixNonlocalMeans(X, opt)
% Returns (sparse) nonlocal means similarity matrix of input matrix X.
% X has to be a 2D or 3D Matrix.
% Set options: opt has to be a struct.
%   opt.nrSim = number of compared input values. (Boundaries won't be added.)
%   opt.patchsizeXY = patchsize of nonlocal means in x and y direction.
%   opt.patchsizeZ = patchsize of nonlocal means in z direction.
%   opt.permutation -> first opt.nrSim of opt.permutation of X are compared with each other.
%   opt.method = dense or sparse
%   opt.alpha = 10 * std (noise)

% Timer
tic;

% Options:
opt = check_opt(X,opt);
nrSim = opt.nrSim;
alpha = opt.alpha;
patchsizeXY = opt.patchsizeXY;
patchsizeZ = opt.patchsizeZ;
permutation = opt.permutation;
simMatrix = 0;
type = opt.simType;
ensRank = opt.ensureRank;

% Print
fprintf('Calculate Similarity Matrix ...');

% Patchsize
radius = floor(patchsizeXY / 2);
lengthZ = floor(patchsizeZ / 2);






if strcmp(opt.method,'sparse')

    
    idxArray = zeros(1,nrSim*numel(X));
    resArray = idxArray;
    idxArray2 = idxArray;

    for i = 1:numel(X)
        
        
        indZ = floor(i / (size(X,1) * size(X,2))) + 1;
        indY = floor((i  - ((size(X,1) * size(X,2)) * (indZ - 1)))  / size(X,1)) + 1;
        indX = floor(i  - ((size(X,1) * size(X,2)) * (indZ - 1)) - size(X,1) * (indY-1));
        
        % Boundaries
        indX = min(max(indX,radius+1),size(X,1)-radius);
        indY = min(max(indY,radius+1),size(X,2)-radius);
        indZ = min(max(indZ,lengthZ+1),size(X,3)-lengthZ);

        % Get Patch1 and Index of Patch1
        patch1 = X(indX - radius : indX + radius, ...
            indY - radius : indY + radius, ...
            indZ - lengthZ : indZ + lengthZ);
        
        index1 = i;
        
        % Print Progress
%         printProgress(i,numel(X));
        
        indXB = round(rand(nrSim,1) * (size(X,1)-2*radius-1) + radius + 1);
        indYB = round(rand(nrSim,1) * (size(X,2)-2*radius-1) + radius + 1);
        indZB = round(rand(nrSim,1) * (size(X,3)-2*lengthZ-1) + lengthZ + 1);

            
        for j = 1:nrSim

            % Get Patch2 and Index of Patch2
            patch2 = X(indXB(j) - radius : indXB(j) + radius, ...
                     indYB(j) - radius : indYB(j) + radius, ...
                     indZB(j) - lengthZ : indZB(j) + lengthZ); 
                 
            index2 = size(X,1) * size(X,2) * (indZB(j)-1) + size(X,1) * (indYB(j)-1) + indXB(j);
            
            % Compare Patch1 and Patch2
            sim = getSimilarity(patch1(:), patch2(:), type)^2;
            exponent = - (1/alpha^2) * sim;
       

            idxArray2((i-1) * nrSim + j) = index2;
            idxArray((i-1) * nrSim + j) = index1;

            if strcmp(type,'euclidean') || strcmp(type,'manhattan')
                resArray((i-1) * nrSim + j) = exp(exponent);
            else
                resArray((i-1) * nrSim + j) = exponent;
            end
            
        end
        

        
    end
    
    % Built Similaritymatrix
    simMatrix = sparse(idxArray,idxArray2,resArray,numel(X),numel(X));
    simMatrix = min(simMatrix + speye(size(simMatrix,1)),1);
    simMatrix = (simMatrix' + simMatrix)/2;
    fprintf(['(',num2str(nnz(simMatrix)),' of ',num2str(numel(simMatrix)),' nonzero entries.)']);
    
elseif strcmp(opt.method,'dense') %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

    % Permutation
    if ensRank
        permutation = ensureRank(X,permutation,nrSim,radius,lengthZ);
    end
    opt.permutation = permutation;
    [indXB,indYB,indZB] =  findpermutatedIdx(X,radius,lengthZ,permutation);

    simMatrixXX = zeros(nrSim,nrSim);
    simMatrixXY = zeros(nrSim,numel(X) - nrSim);
    
    % XX
    for i = 1:nrSim
        

        % Get Patch1 and Index of Patch1
        patch1 = getPatch(X,indXB(i),indYB(i),indZB(i),radius,lengthZ);
        
        % XX
        for j = 1:nrSim
            % Get Patch2 and Index of Patch2
            patch2 = getPatch(X,indXB(j),indYB(j),indZB(j),radius,lengthZ);

            % Compare Patch1 and Patch2
            sim = getSimilarity(patch1(:), patch2(:), type);
            exponent = - (1/alpha^2) * sim;

            
            % Built Similaritymatrix
            if strcmp(type,'euclidean') || strcmp(type,'manhattan')
                simMatrixXX(i,j) = exp(exponent);
            else
                simMatrixXX(i,j) = exponent;
            end
            
        end
        
        % Print Progress
%         printProgress(i,nrSim);
        
        %XY
        for j = (nrSim+1):numel(X)
            % Get Patch2 and Index of Patch2
            patch2 = X(indXB(j) - radius : indXB(j) + radius, ...
                     indYB(j) - radius : indYB(j) + radius, ...
                     indZB(j) - lengthZ : indZB(j) + lengthZ); 

            % Compare Patch1 and Patch2
            sim = getSimilarity(patch1(:), patch2(:), type);
            exponent = - (1/alpha^2) * sim;

            % Built Similaritymatrix
            if strcmp(type,'euclidean') || strcmp(type,'manhattan')
                simMatrixXY(i,j-nrSim) = exp(exponent);
            else
                simMatrixXY(i,j-nrSim) = exponent;
            end
            
        end
    end
    
    simMatrix = {};
    simMatrix.XX = simMatrixXX;
    simMatrix.XY = simMatrixXY;

    
end

time = toc;
fprintf([' in ', num2str(time),' seconds.\n'])




function opt = check_opt(X,opt)
warning('off','backtrace')

    % Struct opt
    if(~isstruct(opt))
        opt = {};
        warning('Options have to be s struct. Set options to struct: opt = {}.');
    end
    % Number Similarities
    if(~isfield(opt, 'nrSim'))
        if numel(X) < 100
            opt.nrSim =  numel(X);
            warning(['Did not set similarities. Number is set to ', num2str(numel(X)),'.']);
        else
            opt.nrSim =  10;
            warning('Did not set similarities. Number is set to 10.');
        end
    elseif(opt.nrSim > numel(X))
        opt.nrSim = numel(X);
        warning(['Set too many similarities. Number is set to ', num2str(numel(X)),'.']);
    end
    
    % PatchsizeXY
    if(~isfield(opt,'patchsizeXY'))
        opt.patchsizeXY = 1; 
        warning('Did not set patchsizeXY. PatchsizeXY is set to 1.');
    elseif opt.patchsizeXY > min([size(X,1),size(X,2)])
        opt.patchsizeXY = min([size(X,1),size(X,2)]); 
        warning(['PatchsizeXY too big. PatchsizeXY is set to ', num2str(opt.patchsizeXY),'.']);
    end
    
    % PatchsizeZ
    if(~isfield(opt,'patchsizeZ'))
        opt.patchsizeZ = 1; 
        warning('Did not set patchsizeZ. PatchsizeZ is set to 1.');
    elseif opt.patchsizeZ > size(X,3)
        opt.patchsizeZ = size(X,3);
        warning(['PatchsizeZ too big. PatchsizeZ is set to ', num2str(opt.patchsizeZ),'.']);
    end

    
    % Method    
    if(~isfield(opt,'method'))
        opt.method = 'sparse';
        warning('No method selected. Method is set to sparse.');
    elseif ~strcmp(opt.method,'dense') && ~strcmp(opt.method,'sparse')
       opt.method = 'sparse';
       warning('Method has to be dense or sparse. Method is set to sparse.');
    end
    
    % ensureRank    
    if(~isfield(opt,'ensureRank'))
        opt.ensureRank = 0;
        warning('Method is not ensures Rank.');
    elseif opt.ensureRank ~= 0 && opt.ensureRank ~= 1
        opt.ensureRank = 0;
        warning('Method is not ensures Rank.');
    end
    
	% simType    
    if(~isfield(opt,'simType'))
        opt.simType = 'euclidean';
        warning('No simType selected. SimType is set to euclidean.');
    elseif ~strcmp(opt.simType,'euclidean') && ~strcmp(opt.simType,'manhattan') && ~strcmp(opt.simType,'cosine') && ~isnumeric(opt.simType)
       opt.simType = 'euclidean';
       warning('SimType has to be euclidean, manhattan or cosine. SimType is set to euclidean.');
    end
    if isnumeric(opt.simType)
        similarityTypes = {'euclidean','manhattan','cosine'};
        if opt.simType < numel(similarityTypes)
            opt.simType = similarityTypes{opt.simType};
        else
             opt.simType = 'euclidean';
             warning('SimType does not exists. Id is too high. SimType is set to euclidean.');
        end
    end
    
    % Alpha    
    if(~isfield(opt,'alpha'))
        opt.alpha =1;
        warning('No alpha selected. Alpha is set to 1.');
    end
        
    % Permutation
    if strcmp(opt.method,'dense')
        if(~isfield(opt,'permutation'))
            opt.permutation= randperm(numel(X));
            %warning('No permutation selected. Permutation is set randomly.');
        elseif numel(opt.permutation) ~= numel(X)
            opt.permutation= randperm(numel(X));
            warning('Wrong size of permutation. Permutation is set randomly.');
        end
    else
        if(isfield(opt,'permutation'))
            warning('Permutation set in sparse matrix.');
        end
        if(~isfield(opt,'permutation'))
            opt.permutation= 1:numel(X);
        elseif numel(opt.permutation) ~= numel(X)
            opt.permutation= 1:numel(X);
            warning('Wrong size of permutation. No permutation set.');
        end
    end
    
    
    warning('on','backtrace')


    
    
function perm = ensureRank(X,perm,nrSim,radius,lengthZ)
    i = 2;
    badpos = numel(perm);
    [indXB,indYB,indZB] =  findpermutatedIdx(X,radius,lengthZ,perm);
    while i < nrSim
        ret = compare(X,i,indXB,indYB,indZB,radius,lengthZ); % Compare ith entry with al previous ones
        if ret == false
            perm = swap(i, badpos, perm);
            [indXB,indYB,indZB] =  findpermutatedIdx(X,radius,lengthZ,perm);
            badpos = badpos - 1;
            if badpos - 1 == nrSim
                warning('Couldnt create Sim Matrix');
                return;
            end
        else
            i = i + 1;
        end
    end

    



    
function ret = compare(X,i,indXB,indYB,indZB,radius,lengthZ)

for j = 1:(i-1)
    patchA = getPatch(X,indXB(i),indYB(i),indZB(i),radius,lengthZ); % New Entrie
    patchB = getPatch(X,indXB(j),indYB(j),indZB(j),radius,lengthZ); % Old Entries
    thenorm = norm(patchA(:) - patchB(:),2)^2;
    
    if thenorm < 0.01 %!!!
        ret = false;
        return;
    end
end
ret = true;
    
    
function patch = getPatch(X,indXB,indYB,indZB,radius,lengthZ)
    patch = X(indXB - radius  : indXB + radius, ...
              indYB - radius  : indYB + radius, ...
              indZB - lengthZ : indZB + lengthZ);
             
function perm = swap(posA, posB, perm)
    A = perm(posA);
    B = perm(posB);
    perm(posA) = B;
    perm(posB) = A;

    
function [indXB,indYB,indZB] =  findpermutatedIdx(X,radius,lengthZ,permutation)
        % Permutation
        indZ = floor(permutation / (size(X,1) * size(X,2))) + 1;
        indY = floor((permutation  - ((size(X,1) * size(X,2)) * (indZ - 1)))  / size(X,1)) + 1;
        indX = floor(permutation  - ((size(X,1) * size(X,2)) * (indZ - 1)) - size(X,1) * (indY-1));

        % Boundaries
        indXB = min(max(indX,radius+1),size(X,1)-radius);
        indYB = min(max(indY,radius+1),size(X,2)-radius);
        indZB = min(max(indZ,lengthZ+1),size(X,3)-lengthZ);
        
function printProgress(i,nrSim)
        % Print
        if i > 1
            fprintf(repmat('\b', 1, 43));
        else
            fprintf('\n');
        end
        percent = round(i / nrSim * 100);
        if percent < 10
            fprintf(['Progress calculating Similarity Matrix: 0',num2str(percent),'%%']);
        else   
            fprintf(['Progress calculating Similarity Matrix: ',num2str(percent),'%%']);
        end
        if i == nrSim
            fprintf(repmat('\b', 1, 45));
        end
        