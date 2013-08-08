/**
This test code is provided more as a template than anything. This helper method
makes the most sense to execute in the context of a trigger. But since it is not 
written with any purpose in mind, here, I'm testing the method call in isolation.

The object I'm testing is a custom object with a custom User lookup field. This 
code will have to be refactored to work in the context of some object that exists
in the destination org.

Furthermore, if you intend to execute this from a trigger, this creates a condition
where the stand-alone test will fail, if your trigger executes on the same object
you use in this test. it is for this purpose that I created a test-specific object
with a single user lookup field. 

If you implement this method as part of a trigger, drop this test code and write 
your own trigger-specific code.
 */
@isTest
private class UCHelperTest {
	
	//constants
	static final Integer kTestBatchSize = 50; //total records generated in object related to EntitySubscription
	static final Integer kTestSuccessBatchSize = 20; //total records with a populated user field
	static final User kTestUser;					//the user to subscribe to EntitySubscription
	
	// TODO: make sure this constant reflects the field on the object your testing in your org. 
	static final Schema.DescribeFieldResult kTestUserField = Test_Object_Chatter_Sub__c.Test_User__c.getDescribe(); //the DFR for the user field in the object
	
	static{
		kTestUser = [select id from User limit 1];
	}
	

    static testMethod void testChatterSubs() {
        
        // TODO: change this test sObject to one that fits your org and use case
        // If you were particularly clever you might rewrite this to use sObject instead of 
        // a specific sObject type. I was not feeling that clever today so I went the easy route
        // and am making you do the work to adapt this to your org. Sorry!
        List<Test_Object_Chatter_Sub__c> recsToInsert = new List<Test_Object_Chatter_Sub__c>();
        for (Integer i = 0; i < kTestBatchSize; i++){
        	recsToInsert.add(newObjectToChatter(kTestUserField,i));
        }
        Database.insert(recsToInsert);
        Test.startTest();
        UCHelper.subscribeUserToRecords(recsToInsert, kTestUserField);
        test.stopTest();
        
        // TODO: change this test sObject to one that fits your org and use case
        Map<Id,Test_Object_Chatter_Sub__c> testRecsMap = new Map<Id,Test_Object_Chatter_Sub__c>(recsToInsert);
        List<EntitySubscription> newsubs = [select id,SubscriberId from EntitySubscription where ParentId in: testRecsMap.keyset()];
        System.assertEquals(kTestSuccessBatchSize, newsubs.size(), 'The number of subscriptions doesn\'t match the number of records in the valid test set.');
        
        Integer incorrectUserCount = 0;
        for (EntitySubscription thissub: newsubs){
        	if (thissub.SubscriberId != kTestUser.id){
				incorrectUserCount++;
        	}
        }
        System.assertEquals(0,incorrectUserCount,'There are '+incorrectUserCount+' generated EntitySubscription records that do not match the test user');
        
    }
    
    //TODO: reimpliment this method for the correct sObject type you can test in your org
    // requirements: 
    static Test_Object_Chatter_Sub__c newObjectToChatter(Schema.DescribeFieldResult userField, Integer currIdx){
    	Test_Object_Chatter_Sub__c testRec = new Test_Object_Chatter_Sub__c();
    	if (currIdx < kTestSuccessBatchSize){
	    	testRec.put(userField.getName(),kTestUser.id);
    	}
    	return testRec;
    }
    
}