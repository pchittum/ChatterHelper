public without sharing class UCHelper {
	
	// abstracted method that will take a list of any sObject type, the name of some field that
	// points to a user record. Using this information it will create a chatter EntitySubscription.
	// second param must be passed in as <ObjectName>.<FieldName>.getDescribe()
	
	public static void subscribeUserToRecords(List<sObject> records, Schema.DescribeFieldResult subscriberField){
		List<EntitySubscription> subs = new List<EntitySubscription>();
		List<Database.SaveResult> srs;
		String userFieldName = subscriberField.getName();
		
		//verify we're given a lookup field with user data in it here I log it
		System.debug('***---> getReferenceTo' + subscriberField.getReferenceTo());
		System.debug('***---> getType' + subscriberField.getType());
		System.debug('***---> getReferenceTo size' + subscriberField.getReferenceTo().size());
		System.debug('***---> sObject supports feed' + records.getSobjectType().getDescribe().isFeedEnabled());
		
		// here I put asserts to ensure that another developer will use this correctly
		// these four checks check that the field passed in is an actual Reference type
		// which, in this case is a lookup. checks that there is no more than one related
		// object type, and that we are related to User. Maybe overkill, but I wanted to show
		// different kinds of check that could be done against generic metadata passed into
		// a method. Added the verification that the sObject has chatter feed turned on.
		System.assert(records.getSobjectType().getDescribe().isFeedEnabled(), 'This method will only work with an sObject which is enabled for Chatter feed.');//object is enabled for chatter feed
		System.assertEquals(Schema.DisplayType.Reference,subscriberField.getType(), 'This feature requires an input of a Lookup relationship field.'); //it is a reference type field
		System.assertEquals(1,subscriberField.getReferenceTo().size(), 'The field used to for the Chatter feed can only have a single related type. Owner and other multirelationship fields will not function.'); //there is only one related reference
		System.assertEquals(Schema.sObjectType.User,subscriberField.getReferenceTo().get(0).getDescribe(), 'Use of this method requires a User lookup field.'); //it is a reference to user
		
		// this is where I instantiate and create the new EntitySubs. sObject.get() returns
		// type Object, so explicit casting to ID is required. Initially I tried String.valueof()
		// and for some reason it wouldn't compile the typical String to ID conversion.  
		for (sObject record: records){
			//skip subscription if field is empty.
			if (record.get(userFieldName) != null){
			subs.add(new EntitySubscription(ParentId = (ID) record.get('Id'), SubscriberId = (ID) record.get(userFieldName)));
			}
		}
		
		// not entirely positive about doing all of this when I'm not all-or-nothing. maybe overkill?
		try{
			System.debug('Inserting list of ' + subs.size() + 'new subscriptions.');
			srs = Database.insert(subs,false);
		} catch (Exception e) {
			System.debug('An error occurred in a non-all-or-nothing insert \r' + e);
			throw e;
		} finally {
			if (srs.size() > 0){
				for (Database.SaveResult sr: srs){
					if (!sr.isSuccess()) System.debug(sr.getErrors());
				}
			}
		}
	}
}