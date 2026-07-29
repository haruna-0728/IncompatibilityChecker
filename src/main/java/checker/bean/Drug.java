
package checker.bean;

public class Drug {
    private int drugId;
    private String drugName;
    private String drugNameKana;
    private String category;

    public int getDrugId() {
        return drugId;
    }
    public void setDrugId(int drugId) {
        this.drugId = drugId;
    }
    public String getDrugName() {
        return drugName;
    }
    public void setDrugName(String drugName) {
        this.drugName = drugName;
    }
    public String getDrugNameKana() {
        return drugNameKana;
    }
    public void setDrugNameKana(String drugNameKana) {
        this.drugNameKana = drugNameKana;
    }
    public String getCategory() {
        return category;
    }
    public void setCategory(String category) {
        this.category = category;
    }
}