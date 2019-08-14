/**************************************************************************************
Apex class       : EER_NTAP_Test
Version          : 1.0 
Created Date     : April 2019
Function         : Test class for the Controller EER_NTAPApplicationCTRL
Developer        : Hemanth Yeleswarapu
**************************************************************************************/
@isTest
public class EER_NTAP_Test {
    
    @isTest
    public static void testNTAPApplicationCtrl(){
        User testUser = WCT_UtilTestDataCreation.createUser('testNTAPApplicationCtrl@deloitte.com','System Administrator','CTS Out of Scope - Vendor Relationship Management','CVMLast','CVMFirst','cvmcvm','testNTAPApplicationCtrl@deloitte.com');   
        insert testUser;
        
        Contact testContact = WCT_UtilTestDataCreation.createContact('Deloitte US Offices','testuser','Employee','testNTAPApplicationCtrl@deloitte.com');
        testContact.AR_Deloitte_Email__c = 'testNTAPApplicationCtrl@deloitte.com';
        testContact.ConnectMe__User__c = testUser.id;
        testContact.WCT_Function__c='TAX';
        testContact.WCT_Service_Line__c='DTT';
        testContact.WCT_Employee_Group__c='External';
        testContact.WCT_Original_Hire_Date__c=Date.newInstance(2015, 11, 16);
        insert testContact;
        
        System.runas(testUser) {
            Test.startTest();
            
            CER_Expense_Reimbursement__c expenseRec = new CER_Expense_Reimbursement__c();
            
            EER_NTAPApplicationCTRL expenseCtrl = new EER_NTAPApplicationCTRL();
            
            expenseCtrl.expenseRequest = expenseRec;
            expenseCtrl.emailId = testContact.AR_Deloitte_Email__c;
            expenseCtrl.BLemail = testContact.AR_Deloitte_Email__c;
            expenseCtrl.OLemail = testContact.AR_Deloitte_Email__c;
            
            expenseCtrl.emailValidate();
            expenseCtrl.nextPanel();
            expenseCtrl.prev();
            expenseCtrl.next();
            expenseCtrl.extendedTaxHandler();
            
            expenseCtrl.extendedTax=true;
            expenseCtrl.extendedTaxHandler();
            
            testContact.WCT_Employee_Group__c='Employee';
            update testContact;
            expenseCtrl.updateBLandOLdetails();
            
            expenseCtrl.submitForm();
            
            expenseCtrl.empFunction = 'RISK AND FINANCIAL ADVISORY';
            expenseCtrl.mappingRecordTypeId();
            
            expenseCtrl.empFunction = 'AUDIT & ASSURANCE';
            expenseCtrl.mappingRecordTypeId();
            
            expenseCtrl.empFunction = 'CONSULTING';
            expenseCtrl.mappingRecordTypeId();
            
            expenseCtrl.empFunction = 'Services';
            expenseCtrl.mappingRecordTypeId();
            
            expenseCtrl.empFunction = 'TAX';
            expenseCtrl.extendedTax=true;
            expenseCtrl.mappingRecordTypeId();
            
            
            Test.stopTest();
            
        }
    }
    
    @isTest
    public static void testNTAPReimbursementCtrl(){
        User testUser = WCT_UtilTestDataCreation.createUser('testNTAPReimbursementCtrl@deloitte.com','System Administrator','CTS Out of Scope - Vendor Relationship Management','CVMLast','CVMFirst','cvmcvm','testNTAPReimbursementCtrl@deloitte.com');   
        insert testUser;
        
        Contact testContact = WCT_UtilTestDataCreation.createContact('Deloitte US Offices','testuser','Employee','testNTAPReimbursementCtrl@deloitte.com');
        testContact.AR_Deloitte_Email__c = 'testNTAPReimbursementCtrl@deloitte.com';
        testContact.ConnectMe__User__c = testUser.id;
        testContact.WCT_Function__c='TAX';
        testContact.WCT_Service_Line__c='DTTL';
        testContact.WCT_Employee_Group__c='External';
        testContact.WCT_Original_Hire_Date__c=Date.newInstance(2015, 11, 16);
        insert testContact;
        
        System.runas(testUser) {
            Test.startTest();
            
            CER_Expense_Reimbursement__c expenseRec = new CER_Expense_Reimbursement__c();
            expenseRec.EER_EmployeeName__c = testContact.id;
            expenseRec.RecordTypeId = Schema.SObjectType.CER_Expense_Reimbursement__c.getRecordTypeInfosByName().get('EER NTAP Advisory').getRecordTypeId();
            insert expenseRec;
            
            CER_Expense_Line_Item__c lineItem = new CER_Expense_Line_Item__c();
            lineItem.CER_Expense_Type__c='Fees';
            lineItem.RelatedTo__c = expenseRec.id;
            lineItem.CER_Expense_Amount__c = 1000;
            
            System.currentPageReference().getParameters().put('requestId',expenseRec.id);
            EER_NTAPReimbursementCTRL reimburseCtrl = new EER_NTAPReimbursementCTRL();
            
            reimburseCtrl.tempExpenseLineItem = lineItem;
            
            reimburseCtrl.nextPanel();
            reimburseCtrl.next();
            reimburseCtrl.prev();
            reimburseCtrl.expenseType();
            reimburseCtrl.getExpenseTypes();
            
            System.currentPageReference().getParameters().put('index','1');
            reimburseCtrl.removeExpenseType();
            
            reimburseCtrl.submitForm();
            
            Test.stopTest();
            
        }
    }

}