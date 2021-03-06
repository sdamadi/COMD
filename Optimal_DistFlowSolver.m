function [c,P, Q,l,vms,y2,y4,q_g] = Optimal_DistFlowSolver(nbr,n,PV_n,r,x,p_c,q_c,p_g,q_g,children,injection_matrix,parent,PV_matrix,PQ_matrix,PQ_n,eps1,eps2,var)
cvx_begin quiet

variables  P(nbr) Q(nbr) l(nbr) vms(n) q_g(PV_n)  
dual variables y1 y2 y3 y4 y5 y6{nbr} y7
      
c=r'*l;
      minimize c
      
        y1 :      P    == children*P + diag(r)*l    +  injection_matrix*( var*eps1 + p_c - p_g )
        
                %       P_12 == P_23       + r(1)*l_12    +  p_c_2
                %       P_23 ==              r(2)*l_23    +  p_c_3
      
        y2 :      Q    == children*Q + diag(x)*l    +  injection_matrix*( var*eps2 + q_c - PV_matrix*q_g ) %
          
        y3 :    vms(1) == 1
            
        y4 : injection_matrix*vms == parent*vms - 2*( diag(r)*P + diag(x)*Q ) + ( diag(r.^2) + diag(x.^2) )*l     
              
%       y5 : PV_matrix'*vms == ones(PV_n,1)

for i=1:nbr

    norm ( [ 2*P(i) 2*Q(i) ( l(i) - vms(i) ) ] ) - ( l(i) + vms(i) ) <= 0 : y6{i}
    
end



%         y7: (1-0.05)^2*ones(PQ_n,1)<=PQ_matrix*vms<=(1+0.05)^2*ones(PQ_n,1)
%            -q_g_max<=q_g<=q_g_max
 
 cvx_end