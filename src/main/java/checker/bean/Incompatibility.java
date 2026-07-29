package checker.bean;

public class Incompatibility {
    private int incompatibilityId;
    private int drugIdA;
    private int drugIdB;
    private String severity;
    private String reason;
    private String source;

    // 検索結果表示用に、薬剤名も一緒に持たせておく
    private String drugNameA;
    private String drugNameB;

    public int getIncompatibilityId() {
        return incompatibilityId;
    }
    public void setIncompatibilityId(int incompatibilityId) {
        this.incompatibilityId = incompatibilityId;
    }
    public int getDrugIdA() {
        return drugIdA;
    }
    public void setDrugIdA(int drugIdA) {
        this.drugIdA = drugIdA;
    }
    public int getDrugIdB() {
        return drugIdB;
    }
    public void setDrugIdB(int drugIdB) {
        this.drugIdB = drugIdB;
    }
    public String getSeverity() {
        return severity;
    }
    public void setSeverity(String severity) {
        this.severity = severity;
    }
    public String getReason() {
        return reason;
    }
    public void setReason(String reason) {
        this.reason = reason;
    }
    public String getSource() {
        return source;
    }
    public void setSource(String source) {
        this.source = source;
    }
    public String getDrugNameA() {
        return drugNameA;
    }
    public void setDrugNameA(String drugNameA) {
        this.drugNameA = drugNameA;
    }
    public String getDrugNameB() {
        return drugNameB;
    }
    public void setDrugNameB(String drugNameB) {
        this.drugNameB = drugNameB;
    }
    
}