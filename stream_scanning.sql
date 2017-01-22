CREATE OR REPLACE FUNCTION TEST_AIR.stream_scanning (p_TypeDoc IN VARCHAR2,
                            p_Cur IN VARCHAR2,
                            p_Airport IN VARCHAR2,
                            p_Hangar IN VARCHAR2,
                            p_Hangar_Number IN VARCHAR2,
                            p_BenAirport IN VARCHAR2,
                            p_BenHangar IN VARCHAR2,
                            p_BenHangar_Number IN VARCHAR2) RETURN cursType
IS
    curs cursType;
    checkBranch     VARCHAR2(1000);
    checkAccAirport VARCHAR2(1000);
    checkBudget     VARCHAR2(1000);
    tmpPilot        VARCHAR2(1000);
    tmpUser1        VARCHAR2(1000);
    tmpUser2        VARCHAR2(1000);
    byrId           NUMBER;
    tmp             NUMBER;

    
    ptValue         VARCHAR(20);
    signValue       VARCHAR(20);
    payerValue      VARCHAR(20);
    accValue        VARCHAR(20);
    billValue       VARCHAR(20);
    bpayerValue     VARCHAR(20);
    baccValue       VARCHAR(20);
    bbillValue      VARCHAR(20);
    userValue       VARCHAR(20);
     
    ptError         VARCHAR2(1000);
    signError       VARCHAR2(1000);
    payerError      VARCHAR2(1000);
    accError        VARCHAR2(1000);
    billError       VARCHAR2(1000);
    bpayerError     VARCHAR2(1000);
    baccError       VARCHAR2(1000);
    bbillError      VARCHAR2(1000);
    userError       VARCHAR2(1000);
BEGIN
    
    ptValue         := p_TypeDoc;
    signValue       := 'N';
    payerValue      := 'N';
    accValue        := 'N';
    billValue       := 'N';
    bpayerValue     := 'N';
    baccValue       := 'N';
    bbillValue      := 'N';
    userValue       := 'N';
     
    ptError         := '';
    signError       := '';
    payerError      := '';
    accError        := '';
    billError       := '';
    bpayerError     := '';
    baccError       := '';
    bbillError      := '';
    userError       := '';
    
    checkBranch     := '';
    checkAccAirport := '';
    checkBudget     := '';
    tmpPilot        := '';
    tmpUser1        := '';
    tmpUser2        := '';
    tmp             := 0;
    
  select nvl(max(c2.value),'0') into checkBranch from consts c1, consts c2
  where c1.group_val = 'Y' and c2.group_val is null and c2.parent_id = c1.id;
 
  select nvl(max(c2.value),'0') into checkAccAirport from consts c1, consts c2
  where c1.group_val = 'Y' and c2.group_val is null and c2.parent_id = c1.id;
 
  select nvl(max(c2.value),'0') into checkBudget from consts c1, consts c2
  where c1.group_val = 'Y' and c2.group_val is null and c2.parent_id = c1.id;
 
  select max(dim.id) into byrId from dimension dim 
  where dim.DIMCODE = 'BYR';
    
  select nvl(max(a.code),' ') as acc, nvl(max(ac1.value),0) as user_id into tmpPilot, tmpUser1
  from (select max(dimension1.id) as ID from dimension1, acct where dimension1.name = '123' and acct.id = dimension1.acc_id) dimension11,
  (select max(dimension1.id) as ID from dimension1, acct where dimension1.name = '124' and acct.id = dimension1.acc_id) dimension12,
  account a,
  dimension2 ac1,
  dimension2 ac2
  where a.code = p_Hangar
    and a.cur_id = byrId
    and ac1.account_id = a.id
    and ac1.element_id = dimension11.id
    and not exists (select 1 from dimension2 acs where ac1.account_id = acs.account_id and ac1.id < acs.id)
    and ac2.account_id = a.id
    and ac2.element_id = dimension12.id
    and not exists (select 1 from dimension2 acs where ac2.element_id = acs.account_id and ac2.id < acs.id)
  ;
  userValue := to_char(tmpUser1);
 
  -- Field checking 1 --
  select nvl(max(dim.id),0) into tmp from dimension dim 
  where dim.DIMCODE = p_Airport and dim.parent_id is not null;
 
  case
    when trim(p_Airport) is null then
      payerError := 'The airport is absent';
    when length(trim(p_Airport)) != 10 then
      payerError := 'The code is not adequate';
    else payerValue := 'Y';
  end case;
 
  -- Field checking 2 --
  case
    when trim(p_Hangar) is null then
      accError := 'The hangar is absent';
    when length(trim(p_Hangar)) != 10 then
      accError := 'The code is not adequate';
    else accValue := 'Y';
  end case;
    
  -- Field checking 3 --
  case
    when trim(p_Hangar_Number) is null then
      billError := 'The hangar number is absent';
    else billValue := 'Y';
  end case;
 
  -- Field checking 4 --
  tmp := 0;
  select nvl(max(dim.id),0) into tmp from dimension dim 
  where dim.DIMCODE = p_BenAirport and dim.parent_id is not null;
 
  case
    when trim(p_BenAirport) is null then
      bpayerError := 'The ben airport is absent';
    when length(trim(p_BenAirport)) != 10 then
      bpayerError := 'The code is not adequate';
    else bpayerValue := 'Y';
  end case;
 
  -- Field checking 5 --
  select nvl(max(a.code),' ') as acc, nvl(max(ac1.value),0) as user_id into tmpPilot, tmpUser2
  from (select max(dimension1.id) as ID from dimension1, acct where dimension1.name = '123' and acct.id = dimension1.acc_id) dimension11,
  (select max(dimension1.id) as ID from dimension1, acct where dimension1.name = '124' and acct.id = dimension1.acc_id) dimension12,
  account a,
  dimension2 ac1,
  dimension2 ac2
  where a.code = p_BenHangar
    and a.cur_id = byrId
    and ac1.account_id = a.id
    and ac1.element_id = dimension11.id
    and not exists (select 1 from dimension2 acs where ac1.account_id = acs.account_id and ac1.id < acs.id)
    and ac2.account_id = a.id
    and ac2.element_id = dimension12.id
    and not exists (select 1 from dimension2 acs where ac2.element_id = acs.account_id and ac2.id < acs.id)
  ;
 
  case
    when trim(p_BenHangar) is null then
      baccError := 'The ben hangar is absent';
    when length(trim(p_BenHangar)) != 10 then
      baccError := 'The code is not adequate';
    else baccValue := 'Y';
  end case;
    
    - Field checking 6 --
  case
    when trim(p_BenHangar_Number) is null then
      bbillError := 'The ben hangar number is absent';
    when checkBudget = '1' and baccValue = 'Y' and (trim(p_BenHangar_Number) is null or length(trim(p_BenHangar_Number)) > 10) then
      bbillError := 'The code is not adequate';
    else bbillValue := 'Y';
  end case;
 
  -- Field checking 7 --
  if userValue = '0' then
    userValue := null;
  end if;
 
  open curs for
    select 'Payment type' as name, ptValue as value, ptError as error from dual
    union all
    select 'Significance' as name, signValue as value, signError as error from dual
    union all
    select 'Payer' as name, payerValue as value, payerError as error from dual
    union all
    select 'Account' as name, accValue as value, accError as error from dual
    union all
    select 'Bill' as name, billValue as value, billError as error from dual
    union all
    select 'BenPayer' as name, bpayerValue as value, bpayerError as error from dual
    union all
    select 'BenAccount' as name, baccValue as value, baccError as error from dual
    union all
    select 'BenBill' as name, bbillValue as value, bbillError as error from dual
    union all
    select 'Administrator' as name, userValue as value, userError as error from dual
  ;
  RETURN curs;
END;