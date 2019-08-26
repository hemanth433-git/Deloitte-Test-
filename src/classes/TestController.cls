public class TestController  
{
    /*Varianble Declaration - START By one Key option from the sublime Text 3 */
    public boolean isValidRequest{get; set;}
    public boolean ismissingReceiptsRequest{get; set;}
    public integer currentPage {get; set;}
    public integer currentPanel {get; set;}
    public Contact loggedContact;
    public string emailId {get; set;}
    public string FirstName {get; set;}
    public string CondidateType{get;set;}
    public boolean JobLevel{get;set;}
    public string LastName {get; set;}
    public string Name {get; set;}
    public string alternativeEmail {get; set;}
    
    public string REQUEST_GROUP_PDAT{get; set;}
    public string REQUEST_GROUP_FEDERAL{get; set;}
    public string REQUEST_GROUP_PDAT_FEDERAL{get; set;}
        /*The validationStatus possbile values are : 
        0 : EV_START    : Yet to Validate.
        1 : EV_SUCCESS  : Validated.  
        2 : EV_1_FAILED : First Validation Failure.
        3 : EV_2_FAILED : Secound Validation Failure.
       */
    public integer validationStatus{get; set;}
    public final integer EV_START{get; set;}
    public final integer EV_SUCCESS{get; set;}
    public final integer EV_1_FAILED{get; set;}
    public final integer EV_2_FAILED{get; set;}
    public integer[] pagePanels{get; set;}
    public string paymentType{get; set;}
    public boolean isValidExpense{get; set;}
    public List<SelectOption> expenseTypeList{get; set;}
    public Map<Integer, Decimal> federalRates{get; set;}
    public Decimal interviewYearFederalRate{get; set;}
    public boolean isSubmitted{get; set;}
    public boolean isFormerIntern{get; set;}
    
    public CER_Expense_Reimbursement__c expenseRequest{get; set;}
    public List<CER_Expense_Line_Item__c> expenseLineItems{get; set;}
    public CER_Expense_Line_Item__c tempExpenseLineItem{get; set;}
    
    /*Document */
      public GBL_Attachments attachmentHelper{get; set;}
    
   // public Document doc {get; set;}
   // public List<Id> docIdList{get; set;}
   // public List<AttachmentsWrapper> UploadedDocumentList{get; set;}
   // public string deleteDocId {get;set;}
    public integer isValidRecCord {get; set;}
    
   
    //public integer deleteExpenseIndex {get; set;}
    
        
    /*Varianble Declaration --END*/
    
    /*
     * Method name  : CEXP_ReimbursementRequestForm_CTRL
     * Description  : Construstor.
     * Return Type  : NA
     * Parameter    : nil
     */
    public TestController()
    {
         /*Intialization*/
        validationStatus=0;
        currentPage=0;
        currentPanel=0;
        isValidRequest=true;
        attachmentHelper= new GBL_Attachments();
        
        /*Rquestor Type */
         REQUEST_GROUP_PDAT='PDAT';
         REQUEST_GROUP_FEDERAL='Federal';
         REQUEST_GROUP_PDAT_FEDERAL='Federal PDAT';
        
        EV_START=0;
        EV_SUCCESS=1;
        EV_1_FAILED=2;
        EV_2_FAILED=3;
        isFormerIntern=True;
        paymentType='';
        pagePanels=new List<Integer>{0, 2, 1, 2, 2, 3};
        expenseRequest= new CER_Expense_Reimbursement__c();
            expenseRequest.CER_Is_US_Address__c=true;
        expenseLineItems = new List<CER_Expense_Line_Item__c>();
        tempExpenseLineItem= new CER_Expense_Line_Item__c();
        isValidExpense=false;
        federalRates= new Map<Integer, Decimal>();
        interviewYearFederalRate=0.0;
        isSubmitted=false;
       
        ismissingReceiptsRequest=false;
        isValidRecCord=0;
        expenseTypeList= new List<SelectOption>();
        
        
        /*Check if missing receipt request is present.*/
        string requestId= ApexPages.currentPage().getParameters().get('requestId');
        if(!string.isEmpty(requestId))
        {
                List<CER_Expense_Reimbursement__c> request= [SELECT id,CER_Expense_Reimbursement__c.Name,CER_Rec_Coordinator_Email__c, CER_Alternate_Email__c, CER_Telephone_Number__c, CER_Payment_Method__c, CER_Name_for_Check__c, CER_Check_Address_Street_1__c, CER_Check_Address_Street_2__c, CER_Check_Address_City__c, CER_Check_Address_State__c, CER_Bank_Name__c, CER_Bank_Account_Number__c, CER_Bank_Account_Type__c, CER_Bank_Routing_Number__c, CER_Travel_To_City_State__c, CER_Travel_From_City_State__c, CER_Travel_Departure_Date__c, CER_Travel_Return_Date__c, CER_Missing_Receipt_Explanation__c, CER_Are_you_missing_any_receipts__c, CER_Expense_Group__c, CER_Request_Status__c, CER_WBS_Element__c, CER_Rejected_by_AP_Reason__c, CER_Approved_by_A_M__c, CER_Hard_copy_receipts_received__c, CER_Check_Address_Zip__c, CER_Expense_Grand_Total__c, CER_Requester_Name__c, CER_No_Receipts__c FROM CER_Expense_Reimbursement__c Where id=:requestId];
            if(request.size()>0)
            {
                 expenseRequest=request[0];
                 List<Contact> relatedTo=[Select id, name, FirstName, LastName,RecordType.Name, Email,AR_Personal_Email__c  From Contact Where id=:expenseRequest.CER_Requester_Name__c ];
                if(relatedTo.size()>0)
                {
                 loggedContact=relatedTo[0];
                 
                 getContactInfo();
                 ismissingReceiptsRequest=true;
                 currentPage=4;
                 currentPanel=1;
                 validationStatus=EV_SUCCESS;
                   expenseRequest.CER_Request_Status__c='Additional Documentation Received';
                }
                else
               {
                  isValidRequest=false; 
               }
            }
            else
            {
                isValidRequest=false;
            }
                
        }
        
    }
    
    public void getContactInfo()
    {
        if(loggedContact!=null)
        {
            emailId=loggedContact.email;
            FirstName=loggedContact.FirstName;
            LastName=loggedContact.LastName;
            Name=loggedContact.Name;
           
        }
    }
    
  
    public PageReference nextPanel()
    {
        integer noOfPanel= pagePanels[currentPage];
        system.debug('##'+noOfPanel+' '+pagePanels[currentPage]);
        if(currentPanel>=noOfPanel)
        {
            currentPage++;
            currentPanel=1; 
        }else
        {
             currentPanel++;          
        }
        return null;
    }
    
    public PageReference validateRecCord()
    {
       // isValidRecCord=0;
        system.debug('#######33'+expenseRequest.CER_Rec_Coordinator_Email__c);
       if(expenseRequest.CER_Rec_Coordinator_Email__c!='')
       {
           List<User> users= [Select id, email From User Where email=:expenseRequest.CER_Rec_Coordinator_Email__c and isActive=true];
           if(users.size()>0)
           {
               
              isValidRecCord=0;
               expenseRequest.CER_Recruiter_Coordinator__c=users[0].id;
               nextPanel();
           }
           else
           {
                ++isValidRecCord;
           }
           
       }
        return null;
    }
    
    
    public pageReference emailValidate()
    {
        //validationStatus=10;
        system.debug('emailId :: '+emailId);
        paymentType=emailId;
        if(emailId!='')
        {
            /*Update the query after discussing with danielle. 
             * Need Following fieds in the name. 
             * Name
             * Email 
             * Alternative Email
             * 
             * Where Condition: 
             */
            
            List<Contact> contacts= [Select id, Email, Name,  FirstName, LastName, RecordType.Name,AR_Personal_Email__c, RecordTypeId, CER_Has_Federal_Opportunity_Org_1__c,Former_Intern__c From Contact Where Email= :emailId order by CreatedDate Desc ];
            system.debug(''+contacts);
            if(contacts.size()>0)
            {
                
                /* Enhancement 10/11/2015 : If more than one contact : possible {Employee and Condidate } which one to select.*/
                
                loggedContact=getCorrectRecord(contacts);
                CondidateType = loggedContact.RecordType.Name;
                JobLevel=loggedContact.Former_Intern__c;
                if(!JobLevel)
                {
                	isFormerIntern=False;
                }
                
                else
                {
                
                validationStatus=EV_SUCCESS;    
                system.debug(''+loggedContact);
                system.debug('CondidateType---' + CondidateType);
                getContactInfo();
                expenseRequest.CER_Alternate_Email__c=loggedContact.AR_Personal_Email__c;
                expenseRequest.CER_Requester_Name__c=loggedContact.Id;
                
                getExpenseTypes();
                    
                /*Get Federal Rate */
               Map<String , CER_Federal_Mileage_Rate__c> allFederalRates=CER_Federal_Mileage_Rate__c.getAll();
               for(String  name: allFederalRates.keySet())
               {
                   if(allFederalRates.get(name).CER_Year__c!=0)
                   {
                       federalRates.put((integer)allFederalRates.get(name).CER_Year__c, allFederalRates.get(name).CER_Federal_Rate__c);
                   }

               }
                
                
                nextPanel();
                }
            }
            else
            {
                /*If error for first time update status to "EV_1_FAILED", If the error is secound time update status for : EV_2_FAILED  */
                validationStatus=(validationStatus==EV_1_FAILED)?EV_2_FAILED:EV_1_FAILED;
            }
        }
       return null; 
    }
    public boolean isFederalCandidate(string loggedInContactId)
    {
        List<WCT_Candidate_Requisition__c>  federalCandidates=[Select id from WCT_Candidate_Requisition__c where WCT_Contact__c=:loggedInContactId and WCT_Requisition__c in (Select id from WCT_Requisition__c where WCT_Commercial_Federal__c='Federal')];
        if(federalCandidates.size()>0)
        {
            return true;
        }
        return false;
    }
    
    public contact getCorrectRecord(List<Contact>  contacts)
    {
        Contact tempContact=null;
        
        /*If only one contact then choose the one returned*/
        if(contacts.size()==1)
        {
            tempContact=contacts[0];
        }
        else
        {
            /*Multiple contact scenario, where the contacts has to be choosen from list of contacts.
                1. Choose the latest created except the Employee.
            */
            Contact temp=contacts[0];
            if(temp.recordTypeId==Label.Employee_Record_Type_ID)
            {
                tempContact=contacts[1];
            }
            else
            {
                tempContact=contacts[0];
            }
        }
        return tempContact;
    }
    
    
    public boolean getIsPDAT(){
        
        return (expenseRequest.CER_Expense_Group__c==REQUEST_GROUP_PDAT ||  expenseRequest.CER_Expense_Group__c==REQUEST_GROUP_PDAT_FEDERAL );
     }
    public boolean getIsFED(){
        
        return (expenseRequest.CER_Expense_Group__c==REQUEST_GROUP_FEDERAL ||  expenseRequest.CER_Expense_Group__c==REQUEST_GROUP_PDAT_FEDERAL );
     }
    public PageReference expenseType()
    {
        system.debug('### pre '+tempExpenseLineItem);
        if(tempExpenseLineItem.CER_Expense_Type__c=='Mileage')
        {
            calculateMileage();
        }
        
        expenseLineItems.add(tempExpenseLineItem);
        tempExpenseLineItem= new CER_Expense_Line_Item__c();
        system.debug('### all'+expenseLineItems);
        isValidExpense=true;
        expenseRequest.CER_No_Receipts__c=false;
        
        return null;
    }
    
    public PageReference showExpense()
    {
        if(expenseRequest.CER_Travel_Departure_Date__c!=null)
        {
           integer year= expenseRequest.CER_Travel_Departure_Date__c.year(); 
           system.debug('##'+year);
           if(federalRates.get(year)!=null)
           {
               interviewYearFederalRate=federalRates.get(year);
           }
           nextPanel();
        }
        return null;
    }
    public Decimal getTotalExpense()
    {
        Decimal total=0;
        for(CER_Expense_Line_Item__c expenseType : expenseLineItems)
        {
            total=total+expenseType.CER_Expense_Amount__c;
        }
        return total;
    }
    
    public void  removeExpenseType()
    {
        integer deleteExpenseIndex = Integer.valueOf(Apexpages.currentPage().getParameters().get('index'));
        if(deleteExpenseIndex!=null)
        {
            Integer j = 0;
                while (j < expenseLineItems.size())
                {
                  if(j==deleteExpenseIndex)
                  {
                    expenseLineItems.remove(j);
                      break;
                  }
                  j++;
                }
            
        }
        system.debug('###'+expenseLineItems+' ::'+deleteExpenseIndex);
       // return null;
    }

    
    public PageReference calculateMileage()
    {
        
                tempExpenseLineItem.CER_Expense_Amount__c=tempExpenseLineItem.CER_Total_Miles_Travelled__c*interviewYearFederalRate;
        if(tempExpenseLineItem.CER_Expense_Amount__c!=null)
        {
            tempExpenseLineItem.CER_Expense_Amount__c=tempExpenseLineItem.CER_Expense_Amount__c.setScale(2);
        }
        return null;
    }
    
    public integer getMoreNumOfQuery()
    {
        return Limits.getLimitQueryRows()-Limits.getQueryRows();
    }
    
    public pageReference prev()
    {
        if(currentPage>1)
        {
          currentPage--;
        }
        return null;
    }
    
    public pageReference next()
    {
        /*Sample Tweet*/
        
        if(currentPage>=1)
        {
          currentPage++;
            validationStatus++;
        }
        return null;
    }
    
       
   
    public PageReference submitForm()
    {
       
        if(!ismissingReceiptsRequest)
        {
            expenseRequest.EER_ReimbursementsGroup__c = 'Candidates';
            expenseRequest.RecordTypeId = Schema.SObjectType.CER_Expense_Reimbursement__c.getRecordTypeInfosByName().get('CER Ambassador Program').getRecordTypeId();
            
            insert expenseRequest;
            /*Querying the Expense Reuest to get the expense Reimbursement Name (auto number )*/
            List<CER_Expense_Reimbursement__c> request= [SELECT id,CER_Expense_Reimbursement__c.Name,CER_Requester_Name__c, CER_Expense_Group__c, CER_No_Receipts__c,EER_ReimbursementsGroup__c  FROM CER_Expense_Reimbursement__c Where id=:expenseRequest.id];
            if(request.size()>0)
            {
                expenseRequest=request[0];
            }
            /*Update Attachments */
                attachmentHelper.uploadRelatedAttachment(expenseRequest.id);
            /*Update Expenses*/
            for(CER_Expense_Line_Item__c tempExpenseType : expenseLineItems)
            {
                tempExpenseType.RelatedTo__c=expenseRequest.id;
            }
            for(CER_Expense_Line_Item__c tempExpenseType : expenseLineItems){
                tempExpenseType.RecordTypeId =Schema.SObjectType.CER_Expense_Line_Item__c.getRecordTypeInfosByName().get('CER Candidate Expense').getRecordTypeId();
            }
            insert expenseLineItems;
            //system.debug('expense Line Item '+expenseLineItems);
            
            if(getIsPDAT())
            {
                Contact tempContact = new Contact();
                tempContact.id=expenseRequest.CER_Requester_Name__c;
                tempContact.CER_Is_Expense_Reimbursement_Requested__c=true;
                update tempContact;
            }
            nextPanel();
            isSubmitted=true;
        }
        return null;
    }
     public PageReference submitMissingExpense()
    {
        attachmentHelper.uploadRelatedAttachment(expenseRequest.id);
        update expenseRequest;
        currentPage=5;
        currentPanel=3;
        isSubmitted=true;
        return null;
    }
    
    
    /*Return the Expense Type List values based on if Request is for PDAT Or not. 
     * 
     * 
     */
    public List<SelectOption> getExpenseTypes()
    {
          List<SelectOption> options = new List<SelectOption>();
                
           Schema.DescribeFieldResult fieldResult =CER_Expense_Line_Item__c.CER_Expense_Type__c.getDescribe();
           List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                
           options.add(new SelectOption('', '--NONE--'));
           for( Schema.PicklistEntry f : ple)
           {
               //system.debug('picklist value '+f.getLabel()+' :: '+(f.getLabel()=='Car Service'));
              /* if(! ((f.getLabel()=='Car Service' && isNONPDAT) || (f.getLabel()=='Dual Degree Eligible Fees' || f.getLabel()=='Primary Tuition' || f.getLabel()=='Primary Eligible Fees' || f.getLabel()=='Dual Degree Tuition' || f.getLabel()=='Emergency Back-up Care')) )
               {
                        options.add(new SelectOption(f.getLabel(), f.getValue()));
               }*/
               
               if((f.getLabel()=='Meals') || (f.getLabel()=='Mileage') || (f.getLabel()=='Other') || (f.getLabel()=='Parking') ){
                options.add(new SelectOption(f.getLabel(), f.getValue()));
               }
           }       
           return options;
    }


}