This zip containes three items:
1. UCHelper.class (and metadata xml)
2. UCHelperTest.class (and metadata xml)
3. Test_Object_Chatter_Sub__c.object

These are meant to be deployed as a package. Test code depends on the object 
included, but is meant only to have an initial test resource to deploy the Apex
code in question. 

UCHelper contains a single method subscribeUserToRecords(). This method accepts 
a list of any sObject, and the DescribeFieldResult for a single user lookup field.
With this data, it will subscribe data in the user field to the sObject records in 
the list to the field whose. System.asserts are performed on the sObject and the 
field in question. Tests include:
- Is the sObject to be subscribed enabled for chatter (done in Setup>Customize>Chatter>Feed Settings)
- Is DFR a reference field (relationship field)
- Is it only related to one other object (not polymorphous like Owner)
- Is it related to the User sObject

I strongly recommend not disabling this assert calls. They are in place to ensure
that testing fails if this method is used for the wrong purpose. 
