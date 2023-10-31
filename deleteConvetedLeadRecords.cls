/**
 * @description       : Batch class to delete converted leads which are 180 days old.
 * @author            : Akshay S
**/
global class deleteConvetedLeadRecords implements Database.Batchable<SObject>,Schedulable{

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Query for converted leads that are 180 days old or older
        Date cutoffDate = Date.today().addDays(-180);
        String query = 'SELECT Id FROM Lead WHERE IsConverted = true AND ConvertedDate < :cutoffDate';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        // Delete the converted lead records
        List<Lead> convertedLeadsToDelete = (List<Lead>)scope;
        delete convertedLeadsToDelete;
    }

    global void finish(Database.BatchableContext BC) {
        // Send an email notification to the system admin
        String[] toAddresses = new String[]{'admin@example.com'};
        String subject = 'Converted Lead Deletion Job Completed';
        String body = 'The batch job to delete old converted leads has completed successfully.';
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(toAddresses);
        email.setSubject(subject);
        email.setPlainTextBody(body);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
    }
    /**
    * @description schedular execution
    **/
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new deleteConvetedLeadRecords( ), 200);
    }
}
