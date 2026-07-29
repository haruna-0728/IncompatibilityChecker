package checker.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import checker.bean.Drug;
import checker.bean.Incompatibility;

public class DrugDAO {
    private static final String URL = "jdbc:mysql://localhost:3306/incompatibility_db";
    private static final String USER = "root";
    private static final String PASS = System.getenv("DB_PASSWORD");
    // 以下、既存のgetConnectionなどはそのまま
    
    // DBへの接続を取得する
    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("JDBCドライバが見つかりません", e);
        }
        return DriverManager.getConnection(URL, USER, PASS);
    }

    // 薬剤名(部分一致)で検索する
    public List<Drug> searchDrugs(String keyword) throws SQLException {
        List<Drug> list = new ArrayList<>();
        String sql = "SELECT drug_id, drug_name, drug_name_kana, category "
                   + "FROM drug_master WHERE drug_name LIKE ? OR drug_name_kana LIKE ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, "%" + keyword + "%");
            pstmt.setString(2, "%" + keyword + "%");

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Drug drug = new Drug();
                    drug.setDrugId(rs.getInt("drug_id"));
                    drug.setDrugName(rs.getString("drug_name"));
                    drug.setDrugNameKana(rs.getString("drug_name_kana"));
                    drug.setCategory(rs.getString("category"));
                    list.add(drug);
                }
            }
        }
        return list;
    }

    // 2剤の組み合わせが配合禁忌かどうかチェックする
    public Incompatibility checkIncompatibility(int drugId1, int drugId2) throws SQLException {
        // 登録ルール(小さい番号をA、大きい番号をB)に合わせて並び替える
        int idA = Math.min(drugId1, drugId2);
        int idB = Math.max(drugId1, drugId2);

        String sql = "SELECT im.incompatibility_id, im.drug_id_a, im.drug_id_b, "
                   + "im.severity, im.reason, im.source, "
                   + "da.drug_name AS name_a, db.drug_name AS name_b "
                   + "FROM incompatibility_master im "
                   + "JOIN drug_master da ON im.drug_id_a = da.drug_id "
                   + "JOIN drug_master db ON im.drug_id_b = db.drug_id "
                   + "WHERE im.drug_id_a = ? AND im.drug_id_b = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idA);
            pstmt.setInt(2, idB);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Incompatibility result = new Incompatibility();
                    result.setIncompatibilityId(rs.getInt("incompatibility_id"));
                    result.setDrugIdA(rs.getInt("drug_id_a"));
                    result.setDrugIdB(rs.getInt("drug_id_b"));
                    result.setSeverity(rs.getString("severity"));
                    result.setReason(rs.getString("reason"));
                    result.setSource(rs.getString("source"));
                    result.setDrugNameA(rs.getString("name_a"));
                    result.setDrugNameB(rs.getString("name_b"));
                    return result;
                }
            }
        }
        return null; // 該当なし = 禁忌情報なし
    
    }
 // 全ての配合禁忌情報を一括取得する(薬剤名JOIN込み)
    public List<Incompatibility> getAllIncompatibilities() throws SQLException {
        List<Incompatibility> list = new ArrayList<>();
        String sql = "SELECT im.incompatibility_id, im.drug_id_a, im.drug_id_b, "
                   + "im.severity, im.reason, im.source, "
                   + "da.drug_name AS name_a, db.drug_name AS name_b "
                   + "FROM incompatibility_master im "
                   + "JOIN drug_master da ON im.drug_id_a = da.drug_id "
                   + "JOIN drug_master db ON im.drug_id_b = db.drug_id";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                Incompatibility result = new Incompatibility();
                result.setIncompatibilityId(rs.getInt("incompatibility_id"));
                result.setDrugIdA(rs.getInt("drug_id_a"));
                result.setDrugIdB(rs.getInt("drug_id_b"));
                result.setSeverity(rs.getString("severity"));
                result.setReason(rs.getString("reason"));
                result.setSource(rs.getString("source"));
                result.setDrugNameA(rs.getString("name_a"));
                result.setDrugNameB(rs.getString("name_b"));
                list.add(result);
            }
        }
        return list;
    }
    
}