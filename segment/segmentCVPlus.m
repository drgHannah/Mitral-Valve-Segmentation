function ret = segmentCVPlus(Res,vars)
% lambda1 * <t-S,M> 
% + lambda2 * TVxy(M)
% + lambda3 * TVz(M)
% + lambda4 * <W*H,M>
% + lambda5 * <1,M>

  
var_plot =  vars(1); % Plot
iter =      vars(2); % Iterations
lambda1 =   vars(3); % Thresholding S
lambda2 =   vars(4); % TVxy(M)
lambda3 =   vars(5); % TVz(M)
lambda4 =   vars(6); % Thresholding WH
lambda5 =   vars(7); % Area
t =   vars(8);       % t

%% Variables


% Reshape Video
X3D = Res.S; %3D



% Initialize W,H,S,M
W = Res.W;
S = Res.S;
H = Res.H;
M = S(:);
X = reshape(X3D,[size(X3D,1) * size(X3D,2), size(X3D,3)]);
W = reshape(W,[size(X3D,1) * size(X3D,2), numel(W) / (size(X3D,1) * size(X3D,2))]);
S = reshape(S,[size(X3D,1) * size(X3D,2), size(X3D,3)]);
H = reshape(H,[numel(W) / (size(X3D,1) * size(X3D,2)), size(X3D,3)]);




% Calculate Derivative
[D,D1,D2,DT] = getDerivativeXYZ(size(X3D,1),size(X3D,2),size(X3D,3));
DXY = cat(1, D1, D2);

% Stepsize
tauM =  0.8 / normest(D);
sigmaM = tauM;

% Energy and Plot
E = [];
if var_plot == true
    fig = figure('Name','Mask by Chan&Vese');
end


% Dual Parameter
p1 = 0;
p2 = 0;
M_ = M;

WH = W * H; WH = WH(:);
Energy =@(M)    lambda1 * (t - S(:))' * M + ...
                lambda2 * sum(sqrt((D1 * M).^2 + (D2 * M).^2)) + ...
                lambda3 * sum(sum(abs(DT * M))) + ...
                lambda4 *  M' * WH(:)+ ...
                lambda5 * sum(M(:));

%% Run Algorithm
for i = 1:iter
    
    
    S = S(:);


    % Update M
    for j = 1:5
        p1 = p1 + sigmaM * DXY * M_;
        p1 = convConj_L2(lambda2,p1,2);
        p2 = min(max(p2 + sigmaM * DT * M_,-lambda3),lambda3);
        
        M_old = M;
        M = M - tauM * DXY' * p1 - tauM * DT' * p2 - tauM * lambda1 * (t - S) - tauM * lambda4 * WH  - tauM * lambda5 * 1;
        M = min(max(M,0),1);
        M_ = 2 * M - M_old;
    end
    

  
    % Reshape S back
    S = reshape(S, size(X,1), size(X,2));

        
    E = [E,Energy(M)];
        
    % Plot
    if var_plot == true
        set(0, 'currentfigure', fig)

        subplot(1,2,1)
        plot(E);
        title('Energy');
        
        subplot(1,2,2);
        MR = reshape(M, size(S,1), size(S,2));
        M_5 = reshape(MR(:,5), size(X3D,1), size(X3D,2));
        imagesc(M_5);colorbar;
        title('M_5');
        
        drawnow;
    else
        disp(i)
    end
    
end

%% Binarize Mask

MRes(M > 0.5) = 1;
MRes(M <= 0.5) = 0;
MR = reshape(MRes, size(S,1), size(S,2));
MR = reshape(MR,size(X3D,1), size(X3D,2), size(X3D,3)); 
MR = max(min(MR,1),0);

%% Return Values


% Create Return
%ret = struct('W',W,'H',H,'S',reshapeas(S,X3D),'M',MR,'Energy', E);
ret = struct('M',MR,'Energy', E);

end





