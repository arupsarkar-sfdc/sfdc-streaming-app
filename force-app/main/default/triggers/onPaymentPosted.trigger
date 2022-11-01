trigger onPaymentPosted on Payment_Event__e (after insert) {

    List<Payments__c> payments_posted = new List<Payments__c>();
    Map<Id, String> paymentsPosted = new Map<Id, String>();
    Set<Id> paymentIds = new Set<Id>();

    //loop through all payment events
    for(Payment_Event__e evt : Trigger.new) {
        System.debug(LoggingLevel.DEBUG, evt.Payment_Id__c);
        //put the external id and the confirmation # in a map
        paymentsPosted.put(evt.Payment_Id__c, evt.Confirmation_Number__c);
    }

    //query salesforce for the external id
    List<Payments__c> payments_updated = [SELECT Id, External_Id__c, Confirmation_Number__c
                                            FROM Payments__c 
                                            WHERE External_Id__c = :paymentsPosted.keySet()];
    for(Payments__c pmt : payments_updated) {
        Payments__c updPayment = new Payments__c();
        updPayment.id = pmt.id;
        updPayment.confirmation_number__c = paymentsPosted.get(pmt.External_Id__c);
        payments_posted.add(updPayment);
    }

    if(payments_posted.size() > 0) {
        update payments_posted;
    }
}