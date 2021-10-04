function ret = robustNMF_excludeWHS_Breg(X3D,vars)
% || X - W * H - S||^2 +    lambda1 * ||S||_1 + 
%                           lambda2 * <S,W*H> + 

 
var_plot =  vars(1); % Plot
r =         vars(2); % Rank
iter =      vars(3); % Iterations
lambda1 =   vars(4); % Sparsity
lambda2 =   vars(5); % Thresholding 

%% Variables


% Reshape Video
X = reshape(X3D,[size(X3D,1) * size(X3D,2), size(X3D,3)]);

% Initialize W,H,S,M
[W,H] = nnmf(X,r);
S = max(X - W * H,0);


% Parameter S
u = S(:);

% Stepsize S
sigmaS = 0.9;

% Energy and Plot
E = [];
if var_plot == true
    fig = figure('Name','RNMF WH not S');
end


% Energy
Energy =@(W,H,S,WH,p) norm(X-W*H-S,'fro').^2 + lambda1 * norm(S,1) + lambda2 * S(:)' * WH(:);
                    
X = gpuArray(X);
W = gpuArray(W);
H = gpuArray(H);
S = gpuArray(S);
%% Run Algorithm

p =0 * X;

for i = 1:iter

    % Calc S
    S = X - W * H + lambda1*p - lambda2 * W * H; 
    ind = S > lambda1;
    S( ind ) = S( ind ) - lambda1;
    
    S( ~ind ) = 0;
    p = p + 1/lambda1 * (X-W*H-S-(lambda2 * W*H));
    
   
    EnergyOld = Energy(W,H,S,W*H,p);
    
    % Update W and H
    S_X = S - X + 0.5 * lambda2 * S;
    
    W( W < 1e-10 ) = 1e-10;
    H( H < 1e-10 ) = 1e-10;
    W =(( abs(S_X * H') - (S_X * H') ) ./(2 * (W * (H * H')))) .* W;
    H =(( abs(W' * S_X) - (W' * S_X) )./ (2 * (W' * W * H)) ) .* H;
    
    % Norm
    tmp = sqrt(sum(W.^2));
    if sum(tmp) > 0
        W = W ./ tmp;
        H = H .* tmp';
    end
   
    
    % Energy
    WH = W * H;
    EnergyNew = Energy(W,H,S,WH,p);
    res = X - WH - S;
    %disp(EnergyNew-EnergyOld)
        
    E = [E,EnergyNew];
        
    % Plot
    if var_plot == true
        set(0, 'currentfigure', fig)

        subplot(2,2,1)
        plot(E);
        title('Energy');
        
        subplot(2,2,2);
        W_1 = reshape(W(:,1),size(X3D,1), size(X3D,2));
        imagesc(W_1);colorbar;
        title('W');
        
        subplot(2,2,4);
        W_1 = reshape(W*H, size(X3D,1), size(X3D,2), size(X3D,3));
        imagesc(W_1(:,:,1));colorbar;
        title('W * H');
        
        subplot(2,2,3);
        S_1 = reshape(S(:,1), size(X3D,1), size(X3D,2));
        imagesc(S_1);colorbar;
        title('S');

        
        drawnow;
    end
    
end

W = gather(W);
H = gather(H);
S = gather(S);

%% Return Values


% Create Return
ret = struct('W',W,'H',H,'S',reshapeas(S,X3D),'Energy', E);

end




