/**************************************************************************************
Apex Class Name:  EER_EmergencyBackupCareForm_CTRL
Version     : 1.0 
Function    : Controller class to the visual force page : "EER_EmergencyBackupCareForm" 

* Developer            Date                   Description
* ----------------------------------------------------------------------------                 
* Abhisek             10-03-2018             Original Version
*************************************************************************************/

public class EER_EmergencyBackupCareForm_CTRL  
{
    /*Variable Declaration - START By one Key option from the sublime Text 3 */
    public boolean isValidRequest{get; set;}
    public boolean isValidExpense{get; set;}	
    public boolean isBackupDayCare {get; set;}
    public boolean isSubmitted{get; set;}
    
    public integer currentPage {get; set;}
    public integer currentPanel {get; set;}
    public integer validationStatus{get; set;}
    public integer[] pagePanels{get; set;}
    
    public Contact loggedContact;
    public string emailId {get; set;}
    public string FirstName {get; set;}
    public string LastName {get; set;}
    public string Name {get; set;}
    public Decimal PersonId {get;set;}
     public string PlanFlag{get;set;}
    /*The validationStatus possbile values are : 
0 : EV_START    : Yet to Validate.
1 : EV_SUCCESS  : Validated.  
2 : EV_1_FAILED : First Validation Failure.
3 : EV_2_FAILED : Secound Validation Failure.
*/
    public final integer EV_START{get; set;}
    public final integer EV_SUCCESS{get; set;}
    public final integer EV_1_FAILED{get; set;}
    public final integer EV_2_FAILED{get; set;}
    
    /* To collect values from FRom*/
    public CER_Expense_Reimbursement__c expenseRequest{get; set;}
    public CER_Expense_Line_Item__c tempExpenseLineItem{get; set;}
    // public CER_Expense_Line_Item__c tempScholarshipsGrantsLineItem{get; set;}
    
    public List<CER_Expense_Line_Item__c> expenseLineItems{get; set;}
    
    //public integer isValidRecCord {get; set;}
    
    /*Variable Declaration --END*/
    
    /*
* Method name  : EER_GSAPSummerAssociateIntakeForm_CTRL
* Description  : Construstor.
* Return Type  : NA
* Parameter    : nil
*/
    public EER_EmergencyBackupCareForm_CTRL()
    {
        /*Intialization*/
        validationStatus=0;
        currentPage=0;
        currentPanel=0;
        
        EV_START=0;
        EV_SUCCESS=1;
        EV_1_FAILED=2;
        EV_2_FAILED=3;
        
        pagePanels=new List<Integer>{0, 1, 1, 3, 4};
        expenseRequest= new CER_Expense_Reimbursement__c();
        tempExpenseLineItem= new CER_Expense_Line_Item__c();
        // tempScholarshipsGrantsLineItem = new CER_Expense_Line_Item__c();
        //expenseRequest.CER_Is_US_Address__c=true;
        expenseLineItems = new List<CER_Expense_Line_Item__c>();       
        isValidRequest=true;
        isValidExpense=false;
        isBackupDayCare = false;
        isSubmitted=false;        
       
    }
    
    /*
* Method name  : getContactInfo
* Description  : To get the Contact details
* Return Type  : NA
* Parameter    : nil
*/
    public void getContactInfo()
    {
        if(loggedContact!=null)
        {
            emailId=loggedContact.AR_Deloitte_Email__c;
            FirstName=loggedContact.FirstName;
            LastName=loggedContact.LastName;
            Name=loggedContact.Name;
            PersonId=loggedContact.WCT_Personnel_Number__c;
            PlanFlag=loggedContact.WCT_Alternate_Career_Model_Flag__c;
        }
    }
    
    public PageReference nextPanel()
    {
        integer noOfPanel= pagePanels[currentPage];
        
        System.debug('nextPanel: noOfPanel:pagePanels[currentPage] :: '+noOfPanel+' '+currentPage+' '+pagePanels[currentPage]);
        
        if(currentPanel>=noOfPanel)
        {
            currentPage++;
            currentPanel=1; 
        }else
        {
            currentPanel++;          
        }
        
        System.debug('nextPanel: currentPage:currentPanel::'+currentPage+' '+currentPanel);
        
        return null;
    }
    
    /*
* Method name  : emailValidate
* Description  : To check if the email (Deloitte Email) entered on the form is of Employee
* Return Type  : Null
* Parameter    : nil
*/
    public pageReference emailValidate()
    {
        System.debug('emailValidate: emailId :: '+emailId);
        
        if(emailId!='')
        {
                        
            List<Contact> contacts= [SELECT Id,Name,WCT_Personnel_Number__c,Email,AR_Deloitte_Email__c,FirstName,LastName,RecordType.Name,AR_Personal_Email__c, RecordTypeId,WCT_Alternate_Career_Model_Flag__c FROM Contact WHERE AR_Deloitte_Email__c =: emailId ORDER BY WCT_Type__c Desc];
            system.debug(''+contacts);
            if(contacts.size()>0)
            {
                validationStatus=EV_SUCCESS;
                /* Enhancement 10/11/2015 : If more than one contact : possible {Employee and Candidate} which one to select.*/
                
                loggedContact=getCorrectRecord(contacts);
                getContactInfo();
                expenseRequest.EER_EmployeeName__c = loggedContact.Id;
                
                nextPanel();
                isBackupDayCare = true;
            }
            else
            {
                /*If error for first time update status to "EV_1_FAILED", If the error is secound time update status for : EV_2_FAILED  */
                validationStatus=(validationStatus==EV_1_FAILED)?EV_2_FAILED:EV_1_FAILED;
            }
        }
        return null; 
    }
    
    /*
* Method name  : getCorrectRecord
* Description  : To identify correct Contact if more than one contact found in the System : possible {Employee and Candidate} - Select Employee
* Return Type  : contact
* Parameter    : List of Contacts
*/
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
                tempContact=contacts[0];
            }
            else
            {
                tempContact=contacts[1];
            }
        }
        return tempContact;
    }
    
    //Reason for expenses picklist values
    public List<SelectOption> getReasonforExpenses() {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = CER_Expense_Line_Item__c.EER_BC_ReasonforExpense__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        options.add(new SelectOption('', '--NONE--'));
        for( Schema.PicklistEntry f : ple)
        {
			options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
   
    /*
* Method name  : expenseType
* Description  : To submit expenses
* Return Type  : Null
* Parameter    : Nil
*/
    public PageReference expenseType()
    {
        system.debug('expenseType : tempExpenseLineItem :: '+tempExpenseLineItem);
        
       // if(tempExpenseLineItem.CER_Expense_Type__c != null)
        //{
            expenseLineItems.add(tempExpenseLineItem);
       // }
        
        system.debug('expenseType : expenseLineItems :: '+expenseLineItems);
        
        tempExpenseLineItem=new CER_Expense_Line_Item__c();
        
        isValidExpense=true;
        return null;
    }
    
    /*
* Method name  : getTotalExpense
* Description  : Get Sum of all the Primary Tuition expenses
* Return Type  : Decimal - returns Total Sum of all the Primary Tuition expenses
* Parameter    : Nil
*/
    public Decimal getTotalExpense()
    {
        system.debug('expenseLineItems :: '+expenseLineItems);
        
        Decimal total=0.00;
        
        if(expenseLineItems.size() > 0)
        {
            for(CER_Expense_Line_Item__c expenseLineItem : expenseLineItems)
            {	
                if(expenseLineItem.CER_Expense_Amount__c != null)
                {
                    total=total+expenseLineItem.CER_Expense_Amount__c;
                }
            }
        }
        
       // system.debug('getTotalExpense : total :: '+total);
        
        return total;
    }
    
    /*
* Method name  : getExpenseLineItems
* Description  : To get the list of Expense Line Items of type Primary Tuition
* Return Type  : returns List of Expense Line Items of type Primary Tuition
* Parameter    : Nil
*/
    public List<CER_Expense_Line_Item__c> getExpenseLineItems()
    {
        system.debug('ExpenseLineItems :: '+expenseLineItems);
        
        List<CER_Expense_Line_Item__c> tutionExpenseLineItems = new List<CER_Expense_Line_Item__c>();
        
        if(expenseLineItems.size() > 0)
        {
            for(CER_Expense_Line_Item__c expenseLineItem : expenseLineItems)
            {	
                if(expenseLineItem.CER_Expense_Type__c == 'Primary Tuition')
                {
                    tutionExpenseLineItems.add(expenseLineItem);
                }
            }
        }
        
        system.debug('getExpenseLineItems : tutionExpenseLineItems :: '+tutionExpenseLineItems);
        
        return tutionExpenseLineItems;
    }  
    
    /*
* Method name  : removeExpenseType
* Description  : to remove the deleted tuition & fee expense from the entered expenses
* Return Type  : Nil
* Parameter    : Nil
*/
    public void removeExpenseType()
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
      //  system.debug('removeExpenseType : expenseLineItems:deleteExpenseIndex :: '+expenseLineItems + ' '+deleteExpenseIndex);
    }	
    
    
    /*
* Method name  : prev
* Description  : to move to previous screen
* Return Type  : Null 
* Parameter    : Nil
*/
    public pageReference prev()
    {
        if(currentPage>1)
        {
            currentPage--;
        }
        return null;
    }
    
    /*
* Method name  : next
* Description  : to move to next screen
* Return Type  : Null 
* Parameter    : Nil
*/
    public pageReference next()
    {
        System.debug('next: currentPage ::' +currentPage + ' validationStatus ::'+validationStatus);
        if(currentPage>=1)
        {
            currentPage++;
            validationStatus++;
        }
        return null;
    }
    
    /*
* Method name  : submitForm
* Description  : to submit the entered expenses 
* Return Type  : Null 
* Parameter    : Nil
*/
    public PageReference submitForm()
    {   
        System.debug('submitForm: expenseRequest :: '+expenseRequest);
        System.debug('submitForm: expenseLineItems :: '+expenseLineItems);
        expenseRequest.EER_ReimbursementsGroup__c = 'Employees';
        //expenseRequest.CER_Request_Status__c='Submitted by Employee';
        expenseRequest.RecordTypeId = Schema.SObjectType.CER_Expense_Reimbursement__c.getRecordTypeInfosByName().get('EER Backup Care').getRecordTypeId();
        expenseRequest.EER_BC_TotalExpenseAmountSubmitted__c = getTotalExpense();
        
        insert expenseRequest;
        
        /*Querying the Expense Reuest to get the expense Reimbursement Name (auto number )*/
        List<CER_Expense_Reimbursement__c> request= [SELECT id,CER_Expense_Reimbursement__c.Name,CER_Requester_Name__c, CER_Expense_Group__c, CER_No_Receipts__c  FROM CER_Expense_Reimbursement__c Where id=:expenseRequest.id];
        if(request.size()>0)
        {
            expenseRequest=request[0];
        }
        
        /*Update Expenses*/
        for(CER_Expense_Line_Item__c tempExpenseLineItem : expenseLineItems)
        {
            tempExpenseLineItem.RelatedTo__c=expenseRequest.id;
            tempExpenseLineItem.RecordTypeId=Schema.SObjectType.CER_Expense_Line_Item__c.getRecordTypeInfosByName().get('EER Backup Care').getRecordTypeId();
        	tempExpenseLineItem.CER_Expense_Type__c='Emergency Back-up Care';
        }
        insert expenseLineItems;            
        
        nextPanel();
        isSubmitted=true;        
        return null;
    }
    
    
    /*
* Method name  : getExpenseTypes
* Description  : to display the Expense Type picklist values
* Return Type  : Return the Expense Type List picklist values
* Parameter    : Nil
*/
    public List<SelectOption> getExpenseTypes()
    {
        List<SelectOption> options = new List<SelectOption>();  
        
        
        if(isBackupDayCare)
        {
            options.add(new SelectOption('Emergency Backup Care', 'Emergency Backup Care'));
            
        }
        else
        {
            options.add(new SelectOption('', '--NONE--'));
        }
        
        return options;
    }    
    
}