package checker.bean;

import java.sql.Timestamp;

public class MemoEntry {
    private int memoId;
    private String drugNames;
    private String memoText;
    private String urgency;
    private String submitter;
    private boolean resolved;
    private Timestamp createdAt;

    public int getMemoId() {
        return memoId;
    }
    public void setMemoId(int memoId) {
        this.memoId = memoId;
    }
    public String getDrugNames() {
        return drugNames;
    }
    public void setDrugNames(String drugNames) {
        this.drugNames = drugNames;
    }
    public String getMemoText() {
        return memoText;
    }
    public void setMemoText(String memoText) {
        this.memoText = memoText;
    }
    public String getUrgency() {
        return urgency;
    }
    public void setUrgency(String urgency) {
        this.urgency = urgency;
    }
    public String getSubmitter() {
        return submitter;
    }
    public void setSubmitter(String submitter) {
        this.submitter = submitter;
    }
    public boolean isResolved() {
        return resolved;
    }
    public void setResolved(boolean resolved) {
        this.resolved = resolved;
    }
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}