drop table interstate_billing_rates;

create table INTERSTATE_BILLING_RATES  (
   LATA                 varchar2(4),
   CLASS1               number(9,6),
   CLASS2               number(9,6),
   CLASS3               number(9,6),
   CLASS4               number(9,6),
   CLASS5               number(9,6),
   CLASS6               number(9,6),
   CLASS0               number(9,6)
);



/*==============================================================*/
/* Table : INTRASTATE_BILLING_RATES                             */
/*==============================================================*/


drop table intrastate_billing_rates;

create table INTRASTATE_BILLING_RATES  (
   LATA                 varchar2(2),
   CLASS1               number(9,6),
   CLASS2               number(9,6),
   CLASS3               number(9,6),
   CLASS4               number(9,6),
   CLASS5               number(9,6),
   CLASS6               number(9,6)
);
           
