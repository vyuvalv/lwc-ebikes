public class ScreenRecordPicklist extends VisualEditor.DynamicPickList {
    public override VisualEditor.DataRow getDefaultValue(){

        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('None', 'none',true);

        return defaultValue;

    }

    public override VisualEditor.DynamicPickListRows getValues() {

        VisualEditor.DynamicPickListRows  allPicklistValus = new VisualEditor.DynamicPickListRows();
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('None', 'none',true);
        allPicklistValus.addRow(defaultValue);
        List<uiScreen__c> allActiveRecords = getAllDataRecords();

        for(uiScreen__c rec : allActiveRecords) {

             VisualEditor.DataRow value = new VisualEditor.DataRow(rec.Name,String.valueOf(rec.Id));

             allPicklistValus.addRow(value);

        }

        return allPicklistValus;

    }

    private static List<uiScreen__c> getAllDataRecords() {

        return [Select Id,Name From uiScreen__c];

    }
}





