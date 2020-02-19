/**
* ********************************************************************************************************************
* Class Name :- API_Batch_DeleteApiLogs
* Created By :- IBM 
* Developer  :- Nowshad
* Created Date :-22-Sep-2016
* Desc       :- This is a batch class that will delete API Logs from the system once they reach the
                maximum age for logs as defined by a custom setting in "General Settings". 
                The default age if a custom setting is not available is 7 days.i.e Logs will be deleted from
                the system if the records have been in the system for 7 or more days at the time the batch job runs.
                The key "MAX_API_LOG_AGE_IN_DAYS" should be used in the name of the custom setting and a valid integer 
                should be provided for the value. Any value <= 0 in the custom setting will result in all logs being 
                deleted.Postive values will leave as many days worth of logs in the system as the Integer value.
* Revision History:
* Modify by            Date                       Desc

********************************************************************************************************************** 
*/

global class API_Batch_DeleteApiLogs implements Database.Batchable<sObject> {
    private Integer maxLogAgeInDays = 7;
    public static final String MAX_API_LOG_AGE_IN_DAYS_KEY = 'MAX_API_LOG_AGE_IN_DAYS';
    
    /** 
     * ************************************************************************************************
     * This method is responsible for deleting the  API Logs from the system once they reach the
     * maximum age for logs as defined by a custom setting 'MAX_API_LOG_AGE_IN_DAYS_KEY' in "General Settings"
     * The default age if a custom setting is not available is 7 days.i.e Logs will be deleted from
     * the system if the records have been in the system for 7 or more days at the time the batch job runs.
     * ************************************************************************************************
     */  
    global API_Batch_DeleteApiLogs(){
        //update max log age based on Custom setting
        General_Settings__c maxAgeSetting = General_Settings__c.getValues(MAX_API_LOG_AGE_IN_DAYS_KEY);
        if(maxAgeSetting != null){
            try{
                maxLogAgeInDays = Integer.valueOf(maxAgeSetting.Value__c);  
            }catch (Exception ex){              
                //do noting, use default age
                System.debug('Custom setting for MAX_AGE_IN_DAYS_KEY in Gener Settings is not a valid Integer');
            }
        }
        
    }

    /** 
     * ************************************************************************************************
     * This method is responsible for the start of the batch
     * ************************************************************************************************
     */      
    global Database.QueryLocator start(Database.BatchableContext bc){
        Datetime now = DateTime.now();
        DateTime cutOfDateTime = now.addDays(-1*maxLogAgeInDays);  
        
        return Database.getQueryLocator('Select Id from API_Log__c where Createddate <: cutOfDateTime');
    }
    
    /** 
     * ************************************************************************************************
     * This method is responsible for the execution of the batch
     * ************************************************************************************************
     */     
    global void execute(Database.BatchableContext bc,List<sObject> scope){
        List<API_Log__c> logsToDelete = (List<API_Log__c>)scope;
        delete logsToDelete;
        
    }
    
    /** 
     * ************************************************************************************************
     * This method is responsible for the finish of the batch
     * ************************************************************************************************
     */     
    global void finish(Database.BatchableContext bc){
        System.debug('Completed API Log Cleanup...');
    }
}