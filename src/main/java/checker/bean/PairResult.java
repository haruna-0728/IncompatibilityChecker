package checker.bean;

public class PairResult {
    private String drugNameA;
    private String drugNameB;
    private boolean dangerous;
    private String severity;
    private String reason;
    private String source;

    public String getDrugNameA() { return drugNameA; }
    public void setDrugNameA(String drugNameA) { this.drugNameA = drugNameA; }

    public String getDrugNameB() { return drugNameB; }
    public void setDrugNameB(String drugNameB) { this.drugNameB = drugNameB; }

    public boolean isDangerous() { return dangerous; }
    public void setDangerous(boolean dangerous) { this.dangerous = dangerous; }

    public String getSeverity() { return severity; }
    public void setSeverity(String severity) { this.severity = severity; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }
}