public with sharing class LLMConfigurationsHandler {

    
    
    
    @AuraEnabled(cacheable=true)
    
    public static Map<String, String> getChildObjects(String strObjectName) {        
        Schema.DescribeSObjectResult R = Case.SObjectType.getDescribe();//Schema.getGlobalDescribe().get(strObjectName).getDescribe();
        for (Schema.ChildRelationship cr: R.getChildRelationships()) {
            if (cr.isRestrictedDelete()) {
                
            }
        }
        Map<String, String> sObjectNamebyLabel = new Map<String, String>();
        return sObjectNamebyLabel;
        
    }
    
    
    
    
    @AuraEnabled(cacheable=true)
    
    public static Map<String, String> getSObjects() {        
        Map<String, String> sObjectNamebyLabel = new Map<String, String>();
        
        for(SObjectType objectType : Schema.getGlobalDescribe().values()) {
            DescribeSObjectResult sObjectDescribe = objectType.getDescribe();
            
            
            
            if(sObjectDescribe.isAccessible() && sObjectDescribe.isQueryable()) {
                sObjectNamebyLabel.put(sObjectDescribe.getLabel(),sObjectDescribe.getName());
                //system.debug(sObjectDescribe.getName());
            }
        }        
        return sObjectNamebyLabel;
    }
    @AuraEnabled(cacheable=true)	
    public static Map<String,ObjectsForConfigWrapper> getFields(String strObjectName) {
      
        list<LLM_utility_Configurations__c> parentId;
        if(checkCruds())
        {
           parentId = [select id from LLM_utility_Configurations__c where name = :strObjectName and isTestRecord__c = true WITH Security_enforced];
        }
        
        Map<String, Schema.SObjectType> detail = Schema.getGlobalDescribe();
        //ObName=strObjectName;
        //fetchRecord(strObjectName);
        
        Map<String,ObjectsForConfigWrapper> mapOfFields = new  Map<String,ObjectsForConfigWrapper>();
        for(Schema.SObjectField fields :detail.get(strObjectName).getDescribe().fields.getMap().Values()) {
            //system.debug(fields);
            //If(fields.getDescribe().getType() == Schema.DisplayType.PICKLIST) { 

                ObjectsForConfigWrapper childWrapper = new ObjectsForConfigWrapper();
                childWrapper.label = fields.getDescribe().getLabel();
                childWrapper.checked = false;
                childWrapper.description = '';
            mapOfFields.put(fields.getDescribe().getName() , childWrapper);
            //}
        }
        
        if(checkCruds() && !parentId.isEmpty() )
        {
            List<LLM_utility_Configurations__c> fieldNames = new list<LLM_utility_Configurations__c>();

            for(LLM_utility_Configurations__c obj : [select id,name,Field_Description__c,label__c from LLM_utility_Configurations__c where Related_Objects_or_Fields__c = :parentId[0].id and type__c = 'Field' and isTestRecord__c = true  WITH SECURITY_ENFORCED])
            {
                fieldNames.add(obj);
            }
               
            for(LLM_utility_Configurations__c key: fieldNames)
            {
                if(mapOfFields.containsKey(key.name))
                {
                    string description = key.Field_Description__c;
                    mapOfFields.get(key.name).checked = true;                    
                    mapOfFields.get(key.name).description = key.Field_Description__c;
                    
                    
                }
            }
          
        }
       
        return mapOfFields;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static ObjectDataWrapper fetchRelatedChildObjects(String parentObjectName) {
        list<LLM_utility_Configurations__c> parentId;
        if(checkCruds())
        {
             parentId = [select id from LLM_utility_Configurations__c where name = :parentObjectName and isTestRecord__c = true  WITH SECURITY_ENFORCED];
        }
        

        Map<String, ObjectsForConfigWrapper> childObjectMap = new Map<String, ObjectsForConfigWrapper>();
        
        // Get the describe result for the parent object
        Schema.DescribeSObjectResult parentDescribe = Schema.getGlobalDescribe().get(parentObjectName).getDescribe();
        
        // Get all the child relationships for the parent object
        List<Schema.ChildRelationship> childRelationships = parentDescribe.getChildRelationships();


        List<string> savedObjects = new list<string>();
        
        //get inserted child records 
        if(checkCruds() && !parentId.isEmpty() )
        {
            for(LLM_utility_Configurations__c obj : [select id,name,label__c from LLM_utility_Configurations__c where Related_Objects_or_Fields__c  = :parentId[0].id and type__c ='Object' and isTestRecord__c = true  WITH SECURITY_ENFORCED])
        {
            savedObjects.add(obj.label__c);
        }
        System.debug('savedObjects'+savedObjects);
        }
        

        
        // Iterate through each child relationship
        for(Schema.ChildRelationship childRelationship : childRelationships) {
            // Get the child object's describe result
            Schema.DescribeSObjectResult childDescribe = childRelationship.getChildSObject().getDescribe();
            if(childDescribe.isAccessible() && childDescribe.isQueryable()) {
               
                
                // Add the child object name and plural label to the map
                //  childObjectMap.put(childObjectName, childObjectPluralLabel);
                //System.debug('childDescribe.getName()'+ childDescribe.getLabel());

                ObjectsForConfigWrapper childWrapper = new ObjectsForConfigWrapper();
                childWrapper.checked = false;
                childWrapper.label = childDescribe.getLabel();
                

                childObjectMap.put(childDescribe.getName(),childWrapper);
            }
        }

        // check if object is already insertted in the salesforce then mark it as selected 
        try{
            if(!savedObjects.isEmpty())
            {
                for(string name : savedObjects)
                {
                    if(childObjectMap.containsKey(name) )
                    {
                        childObjectMap.get(name).checked = true;
                    }
                }
            }
            
        }catch(Exception e){
            

        }
      
        
        
        ObjectDataWrapper odw = new ObjectDataWrapper();
        odw.childObjects = childObjectMap;
        odw.Fields = getFields(parentObjectName);
        
        system.debug('The child objects are ---');
        system.debug(childObjectMap);
        return odw;
    }
    
    
    
  
    
    
  
    
    //insert Records
    @AuraEnabled
    public static boolean insertConfigurationData(string jsonData)
    {
      
        Map<String, Map<String, List<Property>>> parentToObjectMap = new Map<String, Map<String, List<Property>>>();
        List<String> objectNames = new List<String>();
        List<List<Property>> descFieldObjList = new List<List<Property>>();
        List<List<Property>> childDescFieldObjList = new List<List<Property>>();
        List<String> childObjectNamesList = new List<String>(); // Separate list to store child object names
        Map<String, Object> objMap = new Map<String, Object>();
        list<LLM_utility_Configurations__c> existingChildObjects = new list<LLM_utility_Configurations__c>();
        
      
        
        
        // Parse JSON
        List<Object> data = (List<Object>)JSON.deserializeUntyped(jsonData);
             
        
        for (Object obj : data) {
            objMap = (Map<String, Object>)obj;
            
        }

         
            // Extract objectName
            if(!objMap.isEmpty())
            {
                String objectName = (String)objMap.get('objectName');
                objectNames.add(objectName);
                // Extract descFieldObj
                List<Object> descFieldObj = (List<Object>)objMap.get('descFieldObj');
                List<Property> descProperties = new List<Property>();
                system.debug('descFieldObj '+descFieldObj);
                for (Object descObj : descFieldObj) {
                    Map<String, Object> descMap = (Map<String, Object>)descObj;
                    String fieldName = (String)descMap.get('fieldName');
                    String description = (String)descMap.get('description');
                    String fieldValue = (String)descMap.get('fieldvalue');
    
                    descProperties.add(new Property(fieldName, description,fieldValue));
                }
              
                descFieldObjList.add(descProperties); 

                System.debug('descFieldObjList '+descFieldObjList);
            }
             //Getting childObjectNames From DB
          if(checkCruds() && !objMap.containsKey('childObjects'))
          {
             existingChildObjects = [select id,name from LLM_utility_Configurations__c where  name in :objectNames and isTestRecord__c = true WITH SECURITY_ENFORCED];
          }
            if(!existingChildObjects.isEmpty() )
            {
                list<LLM_utility_Configurations__c>childRecordsToUpdate = new List<LLM_utility_Configurations__c>();

                for (Integer i = 0; i < objectNames.size(); i++) {
                    List<Property> descProperties = descFieldObjList[i];
                    for(Property prop :descProperties )
                    {
                        LLM_utility_Configurations__c childFieldRecord = new LLM_utility_Configurations__c();
                        childFieldRecord.Name = prop.fieldValue;
                        childFieldRecord.isTestRecord__c = true;
                        childFieldRecord.Related_Objects_or_Fields__c = existingChildObjects[0].Id;
                        childFieldRecord.type__c = 'Field';
                        //childFieldRecord.Related_Field__c = true;
                        childFieldRecord.label__c =prop.fieldName;
                        childFieldRecord.IsFieldAvailable__c = true;
                        childFieldRecord.Field_Description__c = prop.description;
                        childRecordsToUpdate.add(childFieldRecord);
                    }
                    
                }
                
            
               
            if(checkCruds() && !childRecordsToUpdate.isEmpty())
            { 
                Boolean success = true;
                try{
                    insert childRecordsToUpdate;
                   
                     success = true;
                }
               catch(Exception e)
               {
                System.debug('error '+e.getMessage());
                success = false;
               }
               return success;
               
            }
        }
        
            
            
            // Extract childObjects
            // Extract childObjects
            // Extract childObjects 

            if(!objMap.isEmpty()){
                List<Object> childObjects = (List<Object>)objMap.get('childObjects');
                for (Object childObj : childObjects) {
                    
                    Map<String, Object> childMap = (Map<String, Object>)childObj;
                    String childObjectName = (String)childMap.get('objectName'); // Extract child object name
                    childObjectNamesList.add(childObjectName); // Store child object name
                    List<Object> childDescFieldObj = (List<Object>)childMap.get('descFieldObj');
                    
                    List<Property> childDescProperties = new List<Property>(); // Initialize outside the loop
                    for (Object childDescObj : childDescFieldObj) {
                        if (childDescObj instanceof Map<String, Object>) {
                            Map<String, Object> childDescMap = (Map<String, Object>)childDescObj;
                            
    
                            String fieldName = (String)childDescMap.get('fieldName');
                           
                            String description = (String)childDescMap.get('description');
                           
    
                            String fieldValue = (String)childDescMap.get('fieldvalue');
                           
                            childDescProperties.add(new Property(fieldName, description,fieldValue));
                            
                        }
                    }
                    // Add the properties list to childDescFieldObjList for the current child object
                    childDescFieldObjList.add(childDescProperties);
                    
                }

            }
          
            
            
        
        
        // Populate parentToObjectMap
        // System.debug('descFieldObjList '+descFieldObjList);
        // System.debug('childDescFieldObjList '+childDescFieldObjList);
        // System.debug('childObjectNamesList '+childObjectNamesList);
        // System.debug('objectNames '+objectNames);


        List<Property> childObjects = new List<Property>();
        String parentObjectName = objectNames[0];
        List<Property> descProperties = descFieldObjList[0];

        for (Integer i = 0; i < childObjectNamesList.size(); i++) {
          
            
            List<Property> childDescProperties = childDescFieldObjList[i];
            String childObjectName = childObjectNamesList[i];
            System.debug('descFieldObjList '+descFieldObjList[0]);
        System.debug('childDescFieldObjList '+childDescFieldObjList[i]);
        System.debug('childObjectNamesList '+childObjectNamesList[i]);
        System.debug('objectNames '+objectNames);
            
           // parentData.put('descProperties', descProperties);
            
            
            Property childObject = new Property(childObjectName, null, null);
            childObject.childObjects = childDescProperties;
            childObjects.add(childObject);
        }
        Map<String, List<Property>> parentData = new Map<String, List<Property>>();
        parentData.put('descProperties', descProperties);
            parentData.put('ChildObjects', childObjects);
            
            parentToObjectMap.put(parentObjectName, parentData);
            system.debug('parentToObjectMap '+parentToObjectMap);
            
        
        
        System.debug('parentToObjectMap '+parentToObjectMap);
         
        
        Boolean success = insertData(parentToObjectMap);
        //Boolean success = true;
        return success ;
        
        
        // Now you have lists of each property, you can use them as needed
        // For example, you can iterate over them to print or process further
        
        
        
    }
    @AuraEnabled
    public static boolean insertData(Map<String, Map<String, List<Property>>> parentToObjectMap) {
        boolean success = false;
        List<LLM_utility_Configurations__c> parentRecords = new List<LLM_utility_Configurations__c>();
        List<LLM_utility_Configurations__c> childRecords = new List<LLM_utility_Configurations__c>();
        
        Map<String, List<Property>> parentData = new Map<String, List<Property>>();
        List<Property> descProperties = new List<Property>();
        List<Property> childObjects = new List<Property>();
        
        LLM_utility_Configurations__c parentRecord = new LLM_utility_Configurations__c();
        
        List<LLM_utility_Configurations__c> existingParentRecords = [select id, name from LLM_utility_Configurations__c where name in : parentToObjectMap.keySet() and isTestRecord__c = true WITH SECURITY_ENFORCED];
       
    
        // Insert Parent Records (LLM Configuration)
        for (String parentObjectName : parentToObjectMap.keySet()) {
            parentData = parentToObjectMap.get(parentObjectName);
            descProperties = parentData.get('descProperties');
            childObjects = parentData.get('ChildObjects');
         
            
            // Create parent record
            parentRecord = new LLM_utility_Configurations__c();
            parentRecord.Name = parentObjectName;
            parentRecord.isTestRecord__c = true;
            parentRecord.type__c = 'Object';
            parentRecords.add(parentRecord);
        }
        try {
            //check if parent already exist then set existing record id as parent id 
            if(existingParentRecords.isEmpty())
            {
                insert parentRecords;
                    parentRecord.id = parentRecords[0].id;
            }
            for(LLM_utility_Configurations__c obj : existingParentRecords)
            {
                if(parentToObjectMap.containsKey(obj.name))
                {
                    
                    parentRecord.id = obj.id;
                }
                
            }
           
           // insertedParentRecords.addAll(parentRecords);
        } catch (DmlException e) {
           
            success = false;
        }
        
        
        // Insert parent record fields and descriptions
        List<LLM_utility_Configurations__c> parentFieldRecords = new List<LLM_utility_Configurations__c>();
        
        for (Property prop : descProperties)
         {
         
            LLM_utility_Configurations__c fieldRecord = new LLM_utility_Configurations__c();
            
            fieldRecord.Name = prop.fieldValue;
            fieldRecord.Related_Objects_or_Fields__c = parentRecord.Id;
            fieldRecord.isTestRecord__c = true;
            fieldRecord.type__c = 'Field';
           // fieldRecord.Related_Field__c = true;
            fieldRecord.label__c = prop.fieldName;
            //fieldRecord.IsFieldAvailable__c = true;
            fieldRecord.Field_Description__c = prop.description;
            parentFieldRecords.add(fieldRecord);
        }
        try{
             insert parentFieldRecords;
            
            success = true;
            
           
            
        }catch(dmlException e)
        {
           
            success = false;
        }

        Map<string,LLM_utility_Configurations__c> existingChildObjectMap = new Map<string,LLM_utility_Configurations__c>();
        for(LLM_utility_Configurations__c obj : [select id,name from LLM_utility_Configurations__c where  type__c = 'Object' and Related_Objects_or_Fields__c = :parentRecord.id and isTestRecord__c = true]){
            existingChildObjectMap.put(obj.name,obj);
        }
       
        
        // Step 1: Insert Child Records
        List<LLM_utility_Configurations__c> childRecordsToInsert = new List<LLM_utility_Configurations__c>();
        System.debug('childObjects '+childObjects);
        for (Property childObject : childObjects) {
            LLM_utility_Configurations__c childObjectRecord = new LLM_utility_Configurations__c();
            childObjectRecord.Name = childObject.fieldName;
            childObjectRecord.isTestRecord__c = true;
            childObjectRecord.type__c = 'Object';

           // childObjectRecord.Related_Child_object__c = true;
            childObjectRecord.label__c = childObject.fieldName;
            childObjectRecord.Related_Objects_or_Fields__c = parentRecord.Id;
            childRecordsToInsert.add(childObjectRecord);
        }
        
        
        try{
            for(LLM_Utility_Configurations__c obj : childRecordsToInsert)
            {
                if(existingChildObjectMap.containsKey(obj.name))
                {
                    obj.id = existingChildObjectMap.get(obj.name).id;
                }else{
                    system.debug('childRecordsToInsert '+childRecordsToInsert);
                  break;
                    
                }
            }
            if(checkCruds())
            {
                system.debug('inserted child records'+childRecordsToInsert);
                insert childRecordsToInsert;
            }else{
                
            }
            
            
            success = true;
            
         
            
        }catch(dmlException e)
        {
           
            success = false;
        }
        
        
        // Step 2: Update Parent Records with Child Record IDs
        List<LLM_utility_Configurations__c> childRecordsToUpdate = new List<LLM_utility_Configurations__c>();
        
        for (Integer i = 0; i < childObjects.size(); i++) {
            Property childObject = childObjects[i];
            LLM_utility_Configurations__c childObjectRecord = childRecordsToInsert[i];
            
            for (Property prop : childObject.childObjects) {
                LLM_utility_Configurations__c childFieldRecord = new LLM_utility_Configurations__c();
                childFieldRecord.Name = prop.fieldValue;
                childFieldRecord.isTestRecord__c = true;
                childFieldRecord.Related_Objects_or_Fields__c = childObjectRecord.Id;
                childFieldRecord.type__c = 'Field';
                //childFieldRecord.Related_Field__c = true;
                childFieldRecord.label__c = prop.fieldName;
                // childFieldRecord.IsFieldAvailable__c = true;
                childFieldRecord.Field_Description__c = prop.description;
                childRecordsToUpdate.add(childFieldRecord);
            }
        } 
        
        
        try{
             insert childRecordsToUpdate;
            
            success = true;
        }catch(dmlException e)
        {
            system.debug('error'+e.getMessage());
            success = false;
        }
        
        

        List<LLM_utility_Configurations__c> recordsToInsert = new List<LLM_utility_Configurations__c>();
        // recordsToInsert.addAll(parentRecords);
        recordsToInsert.addAll(childRecords);
                
        return success;
    }

    //return configrable objects
    

    @AuraEnabled
    public static list<string> returnConfigurableObjects(){
        list<String> configurableObjects = new list<String>();
        if( checkCruds())
        {
            
            list<LLM_utility_Configurations__c> objects = [select id,name from LLM_utility_Configurations__c where Related_Objects_or_Fields__c = null and isTestRecord__c = true WITH SECURITY_ENFORCED];
            for(LLM_utility_Configurations__c obj : objects)
            {
                configurableObjects.add(obj.name);
            }

            // if(!configurableObjects.isEmpty())
            // {
            //     fetchRelatedChildObjects(configurableObjects[0]);
            // }
            return configurableObjects;
        }
       return configurableObjects;
    }
    

    // for deletion of records

    @AuraEnabled
    public static boolean deleteConfigurationRecords(String jsonData)
    {

        list<LLM_utility_Configurations__c> recordsToDelete = new list<LLM_utility_Configurations__c>();
        
        Boolean success = false;
        //get id for objects 
       

         // Deserialize JSON data into a list of your wrapper class
         List<DeletionRecordsWrapper> wrapperList = (List<DeletionRecordsWrapper>)JSON.deserialize(jsonData, List<DeletionRecordsWrapper>.class);
        
         // List to store fields and object names
         List<String> fields = new List<String>();
         List<String> objectNames = new List<String>();
         
         // Iterate through the wrapper list to extract field and object name values
         for(DeletionRecordsWrapper wrapper : wrapperList) {
             fields.add(wrapper.label);
             objectNames.add(wrapper.objectName);
             
             
         }

            if(checkCruds())
            {
                recordsToDelete = [select id from LLM_utility_Configurations__c where Related_Objects_or_Fields__r.name in : objectNames and name in : fields and isTestRecord__c = true];
              
            }
         
        if(!recordsToDelete.isEmpty() && checkCruds())
        {
            
            try{
                delete recordsToDelete;

                success = true;
            }catch(Exception e)
            {
                System.debug('error'+e.getMessage());
                success = false;
            }
            return success;
        }
       
        return success;
    }



    // Custom settings form 

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getCustomSettingFieldNames() {

        Map<String, String> fieldLabelApiMap = new Map<String, String>();

        SObjectType customSettingType = LLMConfigurationCustomSetting__c.SObjectType;

        Map<String, SObjectField> fieldMap = customSettingType.getDescribe().fields.getMap();
        fieldLabelApiMap.put(LLMConfigurationCustomSetting__c.Name.getDescribe().getLabel(), LLMConfigurationCustomSetting__c.Name.getDescribe().getName());

        // Iterate through the fields and populate the map with label and API name
        for (String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            if (fieldDescribe.isCustom()) {
                fieldLabelApiMap.put(fieldDescribe.getLabel(), fieldDescribe.getName());
            }
        }
        System.debug('fieldMap'+ fieldLabelApiMap);
        return fieldLabelApiMap;
    }

    @AuraEnabled
    public static Boolean insertCustomSettingRecord(String jsonData) {
        Boolean success = false;
       system.debug('json'+jsonData);
      
       LLMConfigurationCustomSetting__c settingData = new LLMConfigurationCustomSetting__c();

       List<Object> rawSettingsList = (List<Object>) JSON.deserializeUntyped(jsonData);
        List<Map<String, String>> settingsList = new List<Map<String, String>>();

        // Iterate over the raw list of objects
        for (Object obj : rawSettingsList) {
            Map<String, Object> settingMap = (Map<String, Object>) obj;
            Map<String, String> convertedMap = new Map<String, String>();

            // Convert each key-value pair to string
            for (String key : settingMap.keySet()) {
                String value = String.valueOf(settingMap.get(key));
                convertedMap.put(key, value);
            }

            // Add the converted map to the settingsList
            settingsList.add(convertedMap);
        }
       //List<Map<String, String>> settingsList = (List<Map<String, String>>) JSON.deserializeUntyped(jsonData);
       for (Map<String, String> setting : settingsList) {
        String label = setting.get('label');
        String value = setting.get('value');
        
      //  label == deleted && value != null? obj.deleted = value : obj.deleted = null;
      switch on label {
        when 'Name' { settingData.Name = value != null ? value : null; }
        // when 'Additional Emails' { settingData.Additional_Emails__c = value != null ? value : null; }
        when 'Admin Email' { settingData.Admin_Email__c = value != null ? value : null; }
        // when 'Api limit per day' { settingData.Api_limit_per_day__c = value != null ? Decimal.valueOf(value) : null; }
        // when 'Api limit per hour' { settingData.Api_limit_per_hour__c = value != null ? Decimal.valueOf(value) : null; }
        // when 'Api limit per Minute' { settingData.Api_limit_per_Minute__c = value != null ? Decimal.valueOf(value) : null; }
        // when 'Case Additional Emails' { settingData.Case_Additional_Emails__c = value != null ? value : null; }
        // when 'LLM API Key' { settingData.LLM_API_Key__c = value != null ? value : null; }
        // when 'Threshold' { settingData.Threshold__c = value != null ? Decimal.valueOf(value) : null; }
        // when 'Token Limit per hour' { settingData.Token_Limit_per_hour__c = value != null ? Decimal.valueOf(value) : null; }
        // when 'Token limit per Minute' { settingData.Token_limit_per_Minute__c = value != null ? Decimal.valueOf(value) : null; }
        // when 'Total Api Limit' { settingData.Total_Api_Limit__c = value != null ? Decimal.valueOf(value) : null; }
        when else { success = false; }
       

    }
    System.debug('settingListToInsert '+settingData);
  
    }
    try{
        if(checkCruds())
        {
           insert settingData;
            success = true;
        }else{
            success = false;
        }
       
       
    }catch(Exception e)
    {
        System.debug('error'+ e.getMessage());
        success = false;
    }
    
     return success;
}


  
@AuraEnabled
    public static Boolean saveCaseFields( string jsonData)
    {
        Boolean success = false;
        System.debug('jsonData size: ' + jsonData.length());
    
        String parentCaseId;
        if (checkCruds()) {
            parentCaseId = [SELECT Id FROM LLM_utility_Configurations__c WHERE Name = 'Case' and isTestRecord__c = true].Id;
        }
    
        // Deserialize JSON data
        List<CaseFieldsWrapper> caseFieldsList = (List<CaseFieldsWrapper>) JSON.deserialize(jsonData, List<CaseFieldsWrapper>.class);
    
        // Extract labels from JSON data
        Set<String> labels = new Set<String>();
        for (CaseFieldsWrapper wrapper : caseFieldsList) {
            labels.add(wrapper.label);
        }
    
        // Query existing records with names matching the labels
        Map<String, LLM_utility_Configurations__c> existingRecordsMap = new Map<String, LLM_utility_Configurations__c>();
        for (LLM_utility_Configurations__c config : [
            SELECT Id, Name, Type__c, Label__c
            FROM LLM_utility_Configurations__c
            WHERE Label__c IN :labels AND Related_Objects_or_Fields__c = :parentCaseId AND isTestRecord__c = true WITH SECURITY_ENFORCED
        ]) {
            existingRecordsMap.put(config.Label__c, config);
        }
    
        List<LLM_utility_Configurations__c> recordsToInsertOrUpdate = new List<LLM_utility_Configurations__c>();
    
        for (CaseFieldsWrapper wrapper : caseFieldsList) {
            String newTypeValue = (wrapper.utilityType == 'Case Criteria') ? 'Case Matching Criteria' : 'Case Console Result Page';
    
            if (existingRecordsMap.containsKey(wrapper.label)) {
                // Update existing record
                LLM_utility_Configurations__c existingRecord = existingRecordsMap.get(wrapper.label);
    
                // Append new value to existing multi-select picklist values
                Set<String> typeValues = new Set<String>(existingRecord.Type__c != null ? existingRecord.Type__c.split(';') : new List<String>());
                typeValues.add(newTypeValue);
                existingRecord.Type__c = String.join(new List<String>(typeValues), ';');
    
                recordsToInsertOrUpdate.add(existingRecord);
            } else {
                // Insert new record
                recordsToInsertOrUpdate.add(new LLM_utility_Configurations__c(
                    Name = wrapper.label,
                    Label__c = wrapper.value,
                    isTestRecord__c = true,
                    Related_Objects_or_Fields__c = parentCaseId,
                    Type__c = newTypeValue
                ));
            }
        }
    
        
        upsert recordsToInsertOrUpdate;
    
        
    
        return success;
    }

// getting case picklist fields from salesforce
    @AuraEnabled(cacheable=true)
    public static List<CaseFieldsWrapper> getCasePicklistFields()
    {
        List<CaseFieldsWrapper> caseFieldsWrapperList = new List<CaseFieldsWrapper>();

        try {
            // Get the describe result for Case object
            Schema.DescribeSObjectResult caseDescribe = Case.SObjectType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = caseDescribe.fields.getMap();
            
            // Get existing records from LLM_utility_Configurations__c
            Map<String, LLM_utility_Configurations__c> existingRecordsMap = new Map<String, LLM_utility_Configurations__c>();
            for (LLM_utility_Configurations__c config : [
                SELECT Id, Name, Type__c, Label__c
                FROM LLM_utility_Configurations__c
                WHERE Related_Objects_or_Fields__c = :Case.SObjectType.getDescribe().getName() WITH SECURITY_ENFORCED
            ]) {
                existingRecordsMap.put(config.Label__c, config);
            }
            
            // Iterate through case fields and classify them
            for (String fieldName : fieldMap.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                CaseFieldsWrapper obj = new CaseFieldsWrapper();
                obj.label = fieldDescribe.getLabel();
                obj.value = fieldDescribe.getName();
                obj.type = String.valueOf(fieldDescribe.getType());
                obj.isPreselected = existingRecordsMap.containsKey(obj.label);
                
                caseFieldsWrapperList.add(obj);
            }
            
            System.debug('caseFieldsWrapperList ' + caseFieldsWrapperList);
            return caseFieldsWrapperList;
            
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            return caseFieldsWrapperList; // Or return an empty list or handle as required
        } 
     

        
    }


//Wrapper for casePicklistFields and Case field for mutiselect values

public class CaseFieldsWrapper{
   @AuraEnabled public  string label;
   @AuraEnabled public string value;
   @AuraEnabled public string type;
   @AuraEnabled public string utilityType;
   public Boolean isPreselected { get; set; }
}

    //check cruds
    public static boolean checkCruds()
    {
        
        
        return Schema.sObjectType.LLM_utility_Configurations__c.isAccessible() &&
               Schema.sObjectType.LLM_utility_Configurations__c.fields.Id.isAccessible() &&
               Schema.sObjectType.LLM_utility_Configurations__c.isCreateable() &&
               Schema.sObjectType.LLM_utility_Configurations__c.isUpdateable();

    }

    //cunstructor for 
    
    // Wrapper class to hold field details
    
    public class ObjectDataWrapper{
        @AuraEnabled public Map<string,ObjectsForConfigWrapper> childObjects{get;set;}
        @AuraEnabled public Map<string,ObjectsForConfigWrapper>  Fields{get;set;}
        
    }

    //Wrapper for deletion of records

    public class DeletionRecordsWrapper{
        public string label;
        public string objectName;
    }

  
    
    //  wrapper classes
    public class Property {
        public String fieldName;
        public String description;
        public String fieldValue;
        public List<Property> childObjects;
        
        public Property(String fieldName, String description, String fieldValue) {
            this.fieldName = fieldName;
            this.description = description;
            this.fieldValue = fieldValue;
            this.childObjects = new List<Property>();
        }
    }

    // configuration objects
    public class ObjectsForConfigWrapper{
        @AuraEnabled public string label;
        @AuraEnabled public boolean checked;
        @auraEnabled public string description;
    }
    
}