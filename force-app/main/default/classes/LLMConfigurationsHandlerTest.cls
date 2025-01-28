@isTest
public with Sharing class LLMConfigurationsHandlerTest {



    static testMethod void testInsertConfigurationData() {
        
        // Create test data
         LLM_utility_Configurations__c record = new LLM_utility_Configurations__c(Name = 'Case', isTestRecord__c = true);
        
        
        insert record;
        
        LLM_utility_Configurations__c record2 = new LLM_utility_Configurations__c(Name = 'Account', isTestRecord__c = true);
        
        
        insert record2;
        String testData = '[{"objectName":"Case","descFieldObj":[{"fieldName":"Asset Warranty ID","fieldvalue":"AssetWarrantyId","description":"test"}],"childObjects":[{"objectName":"AIInsightValue","descFieldObj":[{"fieldName":"Name","fieldvalue":"Name","description":"test"}]}]}]';
        String testData2 = '[{"objectName":"AIInsightValue","descFieldObj":[{"fieldName":"Name","fieldvalue":"Name","description":"test"}]}]'; 
         String testData3 = '[{"objectName":"AIInsightValu33e","descFieldObj":[{"fieldName":"Name","fieldvalue":"Name","description":"test"}]}]';
        String customSettingsJSON = '[{"label":"Name","value":"dad"},{"label":"Additional Emails","value":"sdda"},{"label":"Api limit per day","value":"123"},{"label":"Api limit per hour","value":"3213"},{"label":"Api limit per Minute","value":"3213"},{"label":"Case Additional Emails","value":"dasd"},{"label":"LLM API Key","value":"123"},{"label":"Token Limit per hour","value":"1232"},{"label":"Token limit per Minute","value":"3123"},{"label":"Total Api Limit","value":"213"},{"label":"Admin Email","value":"sdaa"},{"label":"Threshold","value":"12321"}]';
        String caseFields = '[{"label":"Case ID","value":"Id","type":"ID"},{"label":"Deleted","value":"IsDeleted","type":"BOOLEAN"},{"label":"Case Type","value":"Type","type":"PICKLIST"},{"label":"Status","value":"Status","type":"PICKLIST"}]';
        // Call the method to insert data
        Test.startTest();
        LLMConfigurationsHandler.insertConfigurationData(testData);
        LLMConfigurationsHandler.insertConfigurationData(testData2);
         LLMConfigurationsHandler.getChildObjects('Case');
        LLMConfigurationsHandler.getSObjects();
        LLMConfigurationsHandler.getfields('Case');
        LLMConfigurationsHandler.fetchRelatedChildObjects('Case');
        LLMConfigurationsHandler.returnConfigurableObjects();
         LLMConfigurationsHandler.insertConfigurationData(testData);
        LLMConfigurationsHandler.getCustomSettingFieldNames();
         LLMConfigurationsHandler.insertCustomSettingRecord(customSettingsJSON);
         LLMConfigurationsHandler.getCasePicklistFields();
         LLMConfigurationsHandler.saveCaseFields(caseFields);
        
        Test.stopTest();
       
        
        
        // Add more assertions if needed
    }
    
    // Prepare test data for deletion
    @isTest
    static void prepareTestDataForDeletion() {
        
        
        // Create test data
         LLM_utility_Configurations__c record = new LLM_utility_Configurations__c(Name = 'Case', isTestRecord__c = true);
        
        
        insert record;
        
        LLM_utility_Configurations__c record1 = new LLM_utility_Configurations__c(Name = 'Case', isTestRecord__c = true);
        
        
        insert record1;
        
        LLM_utility_Configurations__c record2 = new LLM_utility_Configurations__c(Name = 'AccountId', isTestRecord__c = true,Related_Objects_or_Fields__c = record1.id);
        
        // Add more test data if needed
        
        insert record2;
    }

    static testMethod void testDeleteConfigurationRecords() {
       
        
        
        string deletionData2 = '[{"label":"AccountId","objectName":"Case"},{"label":"AccountId","objectName":"Case"}]';
        // Call the method to delete records
        Test.startTest();
        Boolean success = LLMConfigurationsHandler.deleteConfigurationRecords(deletionData2);
        Test.stopTest();
        
       
        
        // Add more assertions if needed
    }

    // Add other test methods and data preparation methods as needed
}