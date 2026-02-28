poly_regress();

function poly_regress()

    %Load & read the data in
    selectdir=uigetdir(pwd,'Select directory containing theoretical .dat file');
    cd(selectdir);
    filepattern=fullfile(selectdir,'*.dat');
    [File]=uigetfile(filepattern,'Select theoretical .dat file');
    filename=char(File);
    fid=fopen(filename,'r');
    skiplines=0;
    while true
        pos=ftell(fid);
        line=fgetl(fid);
        if line(1)=='#'
            skiplines=skiplines+1;
        else
            fseek(fid,pos,'bof');
            break;
        end
    end
    data=textscan(fid,'%f %f');
    fclose(fid);
    x=data{1};
    y=data{2};
    m=length(x);

    %begin regression *****************************************************

    %find q's
    q=zeros(m,m);
    q(:,1)=1;
    alpha=dot(x.*q(:,1),q(:,1))/dot(q(:,1),q(:,1));
    q(:,2)=x-alpha;
    for n=3:m
        alpha=dot(x.*q(:,n-1),q(:,n-1))/dot(q(:,n-1),q(:,n-1));
        beta=dot(x.*q(:,n-1),q(:,n-2))/dot(q(:,n-2),q(:,n-2));
        q(:,n)=x.*q(:,n-1)-alpha*q(:,n-1)-beta*q(:,n-2);
    end

    %find c's
    c=zeros(m,1);
    for j=1:m
        c(j)=dot(y,q(:,j))/dot(q(:,j),q(:,j));
    end

    %test different degrees
    selectdir=uigetdir(pwd,'Select directory to save output .dat files');
    cd(selectdir);
    output_id=fopen('variance.dat','w');
    sigmas=zeros(m,1);
    for n=0:m-1
        p_n_vals=q(:,1:n+1)*c(1:n+1);
        sigmas(n+1)=(1/(m-n))*sum((y-p_n_vals).^2);
        if isnan(sigmas(n+1))
            break;
        end
        fprintf(output_id,'%d %.6e\n', n, sigmas(n+1));
    end
    fclose(output_id);
    for n=1:m-2
        ratio=sigmas(n+1)/sigmas(n);
        if ratio>0.999999
            N=n-1;    
            break;
        end
        N=n;  
    end
    fprintf('Optimal degree: N = %d\n', N);

    % Now generate the polynomial coefficients in standard form
    q_coeffs=cell(1,m);
    q_coeffs{1}=1;
    alpha_vec=zeros(m-1, 1); 
    beta_vec=zeros(m-1, 1);   
    alpha_vec(1)=dot(x.*q(:,1),q(:,1))/dot(q(:,1),q(:,1));
    q_coeffs{2}=[1,-alpha_vec(1)];
    for k=3:m
        alpha_vec(k-1)=dot(x.*q(:,k-1),q(:,k-1))/dot(q(:,k-1),q(:,k-1));
        beta_vec(k-2)=dot(x.*q(:,k-1),q(:,k-2))/dot(q(:,k-2),q(:,k-2));
        prev_poly=q_coeffs{k-1};
        term1=conv([1,-alpha_vec(k-1)],prev_poly);
        term2=beta_vec(k-2)*[zeros(1,k-length(q_coeffs{k-2})-1),q_coeffs{k-2}];
        max_len=max(length(term1),length(term2));
        term1=[zeros(1,max_len-length(term1)),term1];
        term2=[zeros(1,max_len-length(term2)),term2];
        q_coeffs{k}=term1-term2;
    end
    final_poly=zeros(1, N+1);

    for k=0:N
        qk_poly=q_coeffs{k+1};
        scaled=c(k+1)*qk_poly;
        qk_len=length(scaled);
        start_idx=N+1-(qk_len-1);
        for j=1:qk_len
            idx=start_idx+(j-1);
            if idx<=N+1 && idx >= 1
                final_poly(idx) = final_poly(idx) + scaled(j);
            end
        end
    end
    coeff_file=fopen('polynomial_coeffs.dat','w');
    fprintf(coeff_file,'# Optimal degree: N = %d\n',N);
    fprintf(coeff_file,'# Polynomial coefficients (highest degree first):\n');
    for i=1:length(final_poly)
        fprintf(coeff_file,'%.12e\n',final_poly(i));
    end
    fclose(coeff_file);
    p_N_final=q(:,1:N+1)*c(1:N+1);
    fit_file=fopen('fitted_values.dat','w');
    fprintf(fit_file,'# x_original y_original y_fitted\n');
    for i=1:m
        fprintf(fit_file,'%.6f %.6e %.6e\n',x(i),y(i),p_N_final(i));
    end
    fclose(fit_file);
    fprintf('\nResults saved to:\n');
    fprintf('  - variance.dat (variance vs degree)\n');
    fprintf('  - polynomial_coeffs.dat (polynomial coefficients)\n');
    fprintf('  - fitted_values.dat (original and fitted values)\n');
    
end