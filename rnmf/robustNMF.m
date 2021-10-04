function ret = robustNMF2(X3D,vars)

%% Get Parameters

var_plot = vars(1);
r = vars(2);
iter = vars(3);
lambda = vars(4);




%% Run Algorithm


% Reshape Video
X = reshape(X3D,[size(X3D,1) * size(X3D,2), size(X3D,3)]);


% Precalculate W and H
[W,H] = nnmf(X,r);
E = [];

W = (W);
H = (H);

Energy =@(W,H,S) norm(X-W*H-S,'fro').^2+ lambda * norm(S,1);


if(var_plot)
    fig = figure('Name', 'Energy RNMF');
end

for i = 1:iter

    % Calc S
    S = X - W * H; 
    ind = S > lambda;
    S( ind ) = S( ind ) - lambda;
    S( ~ind ) = 0;

    % Update
    S_X = S - X;
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
    E = [E,Energy(W,H,S) ];
    
    % Plot
    if var_plot == true
        set(0, 'currentfigure', fig)
        

    
        subplot(2,2,1)
        plot(E);

        subplot(2,2,2);
        W_1 = reshape(W(:,1),size(X3D,1), size(X3D,2));
        imagesc(W_1);colorbar;
        title('W1');

        
        subplot(2,2,4);
        S_5 = reshape(S(:,5), size(X3D,1), size(X3D,2));
        imagesc(S_5);colorbar;
        title('S');
        
        drawnow;
    end
    
end

%% Return Values


ret = struct('W',W,'H',H,'S',reshapeas(S,X3D),'Energy', E);


