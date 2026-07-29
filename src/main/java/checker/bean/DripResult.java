package checker.bean;

public class DripResult {
    private String mode;
    private Double dripRate;         // ①通常輸液:滴下数(gtt/分)
    private Double startDripRate;    // ②輸血:開始時滴下数(gtt/分)
    private Double maintainDripRate; // ②輸血:維持時滴下数(gtt/分)
    private Double estimatedMinutes; // ②輸血:推定総所要時間(分)
    private Double mlPerHour;        // ③ヘパリン・④昇圧剤:投与速度(mL/時)
    private String category;
    private Double mlPerHourGeneric;
    private String endTime;
    private Double kaliumMeqPerHour;
    private Boolean kaliumExceeded;

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public Double getMlPerHourGeneric() { return mlPerHourGeneric; }
    public void setMlPerHourGeneric(Double mlPerHourGeneric) { this.mlPerHourGeneric = mlPerHourGeneric; }

    public String getEndTime() { return endTime; }
    public void setEndTime(String endTime) { this.endTime = endTime; }

    public Double getKaliumMeqPerHour() { return kaliumMeqPerHour; }
    public void setKaliumMeqPerHour(Double kaliumMeqPerHour) { this.kaliumMeqPerHour = kaliumMeqPerHour; }

    public Boolean getKaliumExceeded() { return kaliumExceeded; }
    public void setKaliumExceeded(Boolean kaliumExceeded) { this.kaliumExceeded = kaliumExceeded; }
    public String getMode() { return mode; }
    public void setMode(String mode) { this.mode = mode; }

    public Double getDripRate() { return dripRate; }
    public void setDripRate(Double dripRate) { this.dripRate = dripRate; }

    public Double getStartDripRate() { return startDripRate; }
    public void setStartDripRate(Double startDripRate) { this.startDripRate = startDripRate; }

    public Double getMaintainDripRate() { return maintainDripRate; }
    public void setMaintainDripRate(Double maintainDripRate) { this.maintainDripRate = maintainDripRate; }

    public Double getEstimatedMinutes() { return estimatedMinutes; }
    public void setEstimatedMinutes(Double estimatedMinutes) { this.estimatedMinutes = estimatedMinutes; }

    public Double getMlPerHour() { return mlPerHour; }
    public void setMlPerHour(Double mlPerHour) { this.mlPerHour = mlPerHour; }
}