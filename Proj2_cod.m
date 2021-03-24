#Este programa calcula para um tranformador:
#1. Os parametros do circuito equivalente
#2. O rendimento e as perdas
#3. A regulacao de tensão

#grandezas nominais
V_AT=2400; V_BT=240; S_base=150e3;

#grandezas impostas nos ensaios do femm
Ica1=20.71;		Ica2=5.4;
Vcc1=48;			Vcc2=162;
Icc1_AT=20.5;		Icc2_AT=20.5;
Icc1_BT=205.2;		Icc2_BT=205.2;

#grandezas obtidas dos ensaios no femm
Pcc1=1850.87;		Pcc2= 9607.96;
Pca1=14361.7;		Pca2=567.012;

#alimentador
Z_pu=0.3+1.6i;    Z_base=V_AT*V_AT/S_base/3;
Z=Z_pu*Z_base;

#Carga grupo 4
t=(0:24);
Pot=[1.2; 1.1; 1.08; 0.9; 0.6;...
         0.4; 0.35; 0.3; 0.28; 0.24;...
         0.2; 0.15; 0.1; 0.1; 0.1;...
         0.1; 0.1; 0.1; 0.2; 0.4;...
         0.6; 0.95; 1; 1.1; 1.2];
fp = 0.8; #ind

#figure; bae(Pot);

#1. Parametros do circuito equivalente
#...ensaio de curto circuito
Zeq=@(Vcc,Icc) [Vcc/Icc];
Req=@(Pcc,Icc) [Pcc/(Icc*Icc)];
Xeq=@(Zeq,Req) [sqrt(abs(abs(Zeq*Zeq)-abs(Req*Req)))];

#..ensaio de circuito aberto
Rc=@(Vca,Pca) [Vca*Vca/Pca];
Zphi=@(Vca,Ica) [Vca/Ica];
Xm=@(Zphi,Rc) [1/sqrt(abs(abs(1/Zphi/Zphi)-abs(1/Rc/Rc)))];

#2. Rendimento e perdas
#...a plena carga
I_AT=@(S_pu) [S_pu*S_base/V_AT/3]; #vetor
P_saida=@(S_pu) [S_pu.*S_base*fp];
P_perdas=@(I_AT,Req,Pca) [Pca+I_AT.*I_AT*Req]; #nucleo + enrolameno

Rendimento=@(P_saida,P_perdas) [P_saida./(P_saida+P_perdas)];

#3. Regulacao de tensao
fase=@(ang) [exp(ang*i*pi/100)];
I_AT_=@(S_pu) [S_pu.*S_base*fase(acos(fp))/V_AT/3];

#Para trafo1
Zeq1=Zeq(Vcc1,Icc1_AT)
Req1=Req(Pcc1,Icc1_AT)
Xeq1=Xeq(Zeq1,Req1)
Rc1=Rc(V_BT,Pca1)
Zphi1=Zphi(V_BT,Ica1)
Xm1=Xm(Zphi1,Rc1)

I_AT1=I_AT(Pot);
P_saida1=P_saida(Pot);
P_perdas1=P_perdas(I_AT1,Req1,Pca1)

Rendimento1=Rendimento(P_saida1, P_perdas1)

I_AT_1=I_AT_(Pot);
V1_AT_1=I_AT_1.*(Req1+Xeq1*i).+V_AT;
V1_AT1=abs(V1_AT_1);

V2_1=abs(V_AT-I_AT_1.*(Z+Req1+i*Xeq1));
Regulacao1=(V1_AT1.-V2_1)./V2_1

#Para o trafo2
Zeq2=Zeq(Vcc2,Icc2_AT)
Req2=Req(Pcc2,Icc2_AT)
Xeq2=Xeq(Zeq2,Req2)
Rc2=Rc(V_BT,Pca2)
Zphi2=Zphi(V_BT,Ica2)
Xm2=Xm(Zphi2,Rc2)

I_AT2=I_AT(Pot);
P_saida2=P_saida(Pot);
P_perdas2=P_perdas(I_AT2,Req2,Pca2)

Rendimento2=Rendimento(P_saida2, P_perdas2)

I_AT_2=I_AT_(Pot);
V1_AT_2=I_AT_2.*(Req2+Xeq2*i).+V_AT;
V1_AT2=abs(V1_AT_2);

V2_2=abs(V_AT-I_AT_2.*(Z+Req2+i*Xeq2));
Regulacao2=(V1_AT2.-V2_2)./V2_2

#Dados para o simulink
Zcarga1= V2_1.*V2_1./(Pot*S_base*fase(acos(fp)))
Zcarga2= V2_1.*V2_2./(Pot*S_base*fase(acos(fp)))
